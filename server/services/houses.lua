-- Event to insert a house into the database when it is created
RegisterServerEvent('bcc-housing:CreationDBInsert')
AddEventHandler('bcc-housing:CreationDBInsert',
    function(tpHouse, owner, radius, doors, houseCoords, invLimit, ownerSource, taxAmount)
        local _source = source                                             -- Get the source of the event (the player who triggered it)
        local taxes = tonumber(taxAmount) > 0 and tonumber(taxAmount) or 0 -- Calculate the taxes, ensuring they are a positive number
        local character = VORPcore.getUser(_source).getUsedCharacter       -- Get the character object for the player
        local param                                                        -- Define a variable to hold the parameters for the database insertion

        -- Check if a teleport house is provided
        if not tpHouse then
            -- If no teleport house is provided, set up the parameters without teleport info
            param = {
                ['charidentifier'] = owner,
                ['radius'] = radius,
                ["doors"] = json.encode(doors),
                ['houseCoords'] = json.encode(houseCoords),
                ['invlimit'] = invLimit,
                ['taxes'] = taxes,
                ['tpInt'] = 0,
                ['tpInstance'] = 0,
                ['uniqueName'] = 'none'
            }
        else
            -- If a teleport house is provided, set up the parameters with teleport info
            param = {
                ['charidentifier'] = owner,
                ['radius'] = radius,
                ['doors'] = 'none',
                ['houseCoords'] = json.encode(houseCoords),
                ['invlimit'] = invLimit,
                ['taxes'] = taxes,
                ['tpInt'] = tpHouse,
                ['tpInstance'] = 52324 + _source, -- Generate a unique teleport instance based on the source
                ['uniqueName'] = 'none'
            }
        end

        -- Check if the character already owns too many houses
        local result = MySQL.query.await("SELECT * FROM bcchousing WHERE charidentifier=@charidentifier", param)
        if #result < Config.Setup.MaxHousePerChar then
            -- If the character can own more houses, insert the new house into the database
            MySQL.insert(
                "INSERT INTO bcchousing ( `charidentifier`,`house_radius_limit`,`doors`,`house_coords`,`invlimit`,`tax_amount`,`tpInt`,`tpInstance`, `uniqueName` ) VALUES ( @charidentifier,@radius,@doors,@houseCoords,@invlimit,@taxes,@tpInt,@tpInstance, @uniqueName )",
                param)

            -- Notify Discord about the new house creation
            Discord:sendMessage(_U("houseCreatedWebhook") ..
                tostring(character.charIdentifier) .. _U("houseCreatedWebhookGivenToo") .. tostring(owner))

            -- Wait for 1.5 seconds before proceeding
            Wait(1500)

            -- If the owner's source is provided, trigger the client event to load the house
            if ownerSource ~= nil then
                TriggerClientEvent('bcc-housing:ClientRecHouseLoad', ownerSource)
            end
        else
            -- If the character has reached the maximum number of houses, notify them
            VORPcore.NotifyRightTip(_source, _U("maxHousesReached"), 4000)
        end
    end)

RegisterServerEvent('bcc-housing:CheckIfHasHouse')
AddEventHandler('bcc-housing:CheckIfHasHouse', function(passedSource)
    local _source = passedSource or source
    local user = VORPcore.getUser(_source)
    if not user then return end
    local character = user.getUsedCharacter and user.getUsedCharacter

    if not character or not character.charIdentifier then
        print("Error: Character or charIdentifier is missing for player with source: " .. tostring(_source))
        return
    end

    devPrint("Checking if player owns or has access to a house for character ID: " .. character.charIdentifier)

    -- Query all houses from the database
    MySQL.query("SELECT * FROM bcchousing", {}, function(result)
        local accessibleHouses = {}     -- Initialize a table to hold accessible houses

        if #result > 0 then
            -- Loop through the results and check for ownership or access
            for k, v in pairs(result) do
                -- Trigger client event to check if the player is within private property radius
                TriggerClientEvent('bcc-housing:PrivatePropertyCheckHandler', _source, json.decode(v.house_coords),
                    v.house_radius_limit)

                -- Register the house inventory with the player's information
                local data = {
                    id = 'Player_' .. tostring(v.houseid) .. '_bcc-houseinv',
                    name = _U("houseInv"),
                    limit = tonumber(v.invlimit),
                    acceptWeapons = true,
                    shared = true,
                    ignoreItemStackLimit = true,
                    whitelistItems = false,
                    UsePermissions = false,
                    UseBlackList = false,
                    whitelistWeapons = false
                }
                exports.vorp_inventory:registerInventory(data)

                -- Check if the player is the owner of the house
                if character.charIdentifier == tonumber(v.charidentifier) then
                    table.insert(accessibleHouses, v.houseid)
                    TriggerClientEvent('bcc-housing:OwnsHouseClientHandler', _source, v, true)
                else
                    -- Check if the player is allowed access to the house
                    local allowed_idsTable = json.decode(v.allowed_ids)
                    if allowed_idsTable then
                        for y, e in pairs(allowed_idsTable) do
                            if character.charIdentifier == tonumber(e) then
                                table.insert(accessibleHouses, v.houseid)
                                TriggerClientEvent('bcc-housing:OwnsHouseClientHandler', _source, v, false)
                                break
                            end
                        end
                    end
                end
            end
        end

        -- Send the list of accessible houses to the client
        TriggerClientEvent('bcc-housing:ReceiveAccessibleHouses', _source, accessibleHouses)
    end)
end)


-- Event to open the house inventory
RegisterServerEvent('bcc-house:OpenHouseInv')
AddEventHandler('bcc-house:OpenHouseInv', function(houseId)
    local src = source                      -- Get the source of the event
    local user = VORPcore.getUser(src)      -- Get the user object for the player
    local character = user.getUsedCharacter -- Get the character object for the player

    if character then
        local charIdentifier = character.charIdentifier -- Get the character identifier
        devPrint("Opening house inventory for House ID: " ..
            tostring(houseId) .. " and character ID: " .. tostring(charIdentifier))

        -- Query the database to find the house by ID
        MySQL.query("SELECT * FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId }, function(result)
            if result and #result > 0 then
                local houseData = result[1] -- Get the house data from the query result

                -- Check if the player is the owner of the house
                if tostring(houseData.charidentifier) == tostring(charIdentifier) then
                    devPrint("Player is the owner of house ID: " .. tostring(houseId))
                    exports.vorp_inventory:openInventory(src, 'Player_' .. tostring(houseId) .. '_bcc-houseinv')
                else
                    -- Check if the player is allowed access to the house inventory
                    local allowedIds = json.decode(houseData.allowed_ids) or {}
                    for _, id in ipairs(allowedIds) do
                        if tostring(id) == tostring(charIdentifier) then
                            devPrint("Player is allowed to access house ID: " .. tostring(houseId))
                            exports.vorp_inventory:openInventory(src, 'Player_' .. tostring(houseId) .. '_bcc-houseinv')
                            return
                        end
                    end
                    -- Notify the player if they do not have access
                    devPrint("Player does not have access to house inventory: " .. tostring(houseId))
                    VORPcore.NotifyLeft(src, "You do not have access to this house.", "", "generic_textures",
                        "generic_cross", 5000)
                end
            else
                -- Notify the player if no house was found
                devPrint("Error: No results found for house ID: " .. tostring(houseId))
                VORPcore.NotifyLeft(src, "No house found with the given ID.", "", "generic_textures", "generic_cross",
                    5000)
            end
        end)
    else
        -- Notify the player if no character was found
        devPrint("Error: No character found for source: " .. tostring(src))
        VORPcore.NotifyLeft(src, "No character found.", "", "generic_textures", "generic_cross", 5000)
    end
end)

-- Function to update door access for a specific door ID
function updateDoorAccess(doorId, newId)
    devPrint("Updating door access for door ID: " .. tostring(doorId) .. " with new ID: " .. tostring(newId))
    -- Query the database to get the allowed IDs for the door
    local result = MySQL.query.await("SELECT ids_allowed FROM doorlocks WHERE doorid=@doorId", { ['doorId'] = doorId })
    if result and #result > 0 then
        local allowedIdTable = json.decode(result[1].ids_allowed) or {}
        -- Check if the new ID is not already in the allowed IDs
        if not table.contains(allowedIdTable, newId) then
            table.insert(allowedIdTable, newId)
            local param = {
                ['ids_allowed'] = json.encode(allowedIdTable),
                ['doorId'] = doorId
            }
            -- Update the door locks with the new allowed IDs
            MySQL.update("UPDATE doorlocks SET ids_allowed=@ids_allowed WHERE doorid=@doorId", param)
        end
    end
end

-- Event to handle ledger updates for houses (both add and remove)
RegisterServerEvent('bcc-housing:LedgerHandling')
AddEventHandler('bcc-housing:LedgerHandling', function(amount, houseid, isAdding)
    local _source = source                                       -- Get the source of the event
    local character = VORPcore.getUser(_source).getUsedCharacter -- Get the character object for the player
    local amountNumber = tonumber(amount)                        -- Convert the amount to a number
    local houseIdNumber = tonumber(houseid)                      -- Convert the house ID to a number

    devPrint("Handling ledger for amount: " .. tostring(amountNumber) .. " and house ID: " .. tostring(houseIdNumber) .. (isAdding and " (Adding)" or " (Removing)"))

    -- Validate the input data
    if not amountNumber or not houseIdNumber then
        devPrint("Invalid input data. Amount: " .. tostring(amount) .. " House ID: " .. tostring(houseid))
        return
    end

    -- Query the database to get the current ledger and tax amount for the house
    MySQL.query("SELECT ledger, tax_amount FROM bcchousing WHERE houseid = ?", { houseIdNumber }, function(result)
        if result and #result > 0 then
            local ledger = tonumber(result[1].ledger)                               -- Get the current ledger amount
            local tax_amount = tonumber(result[1].tax_amount)                       -- Get the current tax amount

            if isAdding then
                -- Adding logic
                local maxInsertAmount = tax_amount - ledger                         -- Calculate the maximum amount that can be inserted
                local insertionAmount = math.min(amountNumber, maxInsertAmount)     -- Determine the actual amount to insert

                if insertionAmount > 0 then
                    -- Check if the player has enough money
                    if character.money >= insertionAmount then
                        character.removeCurrency(0, insertionAmount) -- Deduct the money from the player's account
                        -- Update the ledger in the database
                        MySQL.update("UPDATE bcchousing SET ledger = ledger + ? WHERE houseid = ?",
                            { insertionAmount, houseIdNumber }, function(affectedRows)
                                if affectedRows > 0 then
                                    -- Notify the player of the successful ledger update
                                    VORPcore.NotifyLeft(_source, _U("ledgerAmountInserted") .. " $" .. insertionAmount, "", "inventory_items", "money_moneystack", 5000)
                                else
                                    -- Notify the player if the ledger update failed
                                    VORPcore.NotifyLeft(_source, _U("ledgerUpdateFailed"), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
                                end
                            end)
                    else
                        -- Notify the player if they do not have enough money
                        VORPcore.NotifyLeft(_source, _U("noMoney"), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
                    end
                else
                    -- Notify the player if the maximum amount of money is already stored
                    VORPcore.NotifyLeft(_source, _U('maxAmountStored'), "", "menu_textures", "menu_icon_alert", 5000)
                end
            else
                -- Removing logic
                if ledger >= amountNumber then
                    character.addCurrency(0, amountNumber)
                    -- Update the ledger in the database by subtracting the amount
                    MySQL.update("UPDATE bcchousing SET ledger = ledger - ? WHERE houseid = ?",
                        { amountNumber, houseIdNumber }, function(affectedRows)
                            if affectedRows > 0 then
                                -- Notify the player of the successful ledger update
                                VORPcore.NotifyLeft(_source, _U("ledgerAmountRemoved") .. " $" .. amountNumber, "", "inventory_items", "money_moneystack", 5000)
                            else
                                -- Notify the player if the ledger update failed
                                VORPcore.NotifyLeft(_source, _U("ledgerUpdateFailed"), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
                            end
                        end)
                else
                    -- Notify the player if there is not enough money in the ledger
                    VORPcore.NotifyLeft(_source, _U('notEnoughFunds'), "", "menu_textures", "menu_icon_alert", 5000)
                end
            end
        else
            -- Notify the player if no house was found
            VORPcore.NotifyLeft(_source, _U("noHouseFound"), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
        end
    end)
end)

-- Event to check the ledger balance of a house
RegisterServerEvent('bcc-housing:CheckLedger')
AddEventHandler('bcc-housing:CheckLedger', function(houseid)
    local _source =
    source                                                                                     -- Get the source of the event
    devPrint("Checking ledger for house ID: " .. tostring(houseid))
    local param = { ['houseid'] = houseid }                                                    -- Set up the parameters for the query
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param) -- Query the database for the house's ledger
    if #result > 0 then
        -- Notify the player of the current ledger balance and tax amount
        VORPcore.NotifyLeft(_source, tostring(result[1].ledger) .. '/' .. tostring(result[1].tax_amount), "",
            "menu_textures", "menu_icon_alert", 5000)
    end
end)

-- Event to retrieve house ID and perform actions based on the context
RegisterServerEvent('bcc-housing:getHouseId')
AddEventHandler('bcc-housing:getHouseId', function(context, houseId)
    local src = source                      -- Get the source of the event
    local user = VORPcore.getUser(src)      -- Get the user object for the player
    local character = user.getUsedCharacter -- Get the character object for the player

    if character then
        local charIdentifier = character.charIdentifier -- Get the character identifier
        devPrint("getHouseId event triggered with charidentifier: " ..
            tostring(charIdentifier) .. " for House ID: " .. tostring(houseId))

        if houseId then
            -- Query the database to retrieve house data based on the house ID
            MySQL.query("SELECT * FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId }, function(result)
                if result and #result > 0 then
                    local houseData = result[1] -- Get the house data from the query result
                    local hasAccess = false

                    -- Check if the player is the owner of the house
                    if tostring(houseData.charidentifier) == tostring(charIdentifier) then
                        devPrint("Player is the owner of house ID: " .. tostring(houseId))
                        hasAccess = true
                    else
                        -- Check if the player is allowed access to the house
                        local allowedIds = json.decode(houseData.allowed_ids) or {}
                        for _, id in ipairs(allowedIds) do
                            if tostring(id) == tostring(charIdentifier) then
                                devPrint("Player is allowed to access house ID: " .. tostring(houseId))
                                hasAccess = true
                                break
                            end
                        end
                    end

                    -- Perform actions based on the context provided
                    if hasAccess then
                        if context == 'inv' then
                            devPrint("Opening house inventory for House ID: " ..
                                tostring(houseId) .. " and character ID: " .. tostring(charIdentifier))
                            TriggerClientEvent('bcc-housing:receiveHouseIdinv', src, houseId)
                        elseif context == 'access' then
                            devPrint("Granting access to House ID: " ..
                                tostring(houseId) .. " for character ID: " .. tostring(charIdentifier))
                            TriggerClientEvent('bcc-housing:receiveHouseId', src, houseId)
                        elseif context == 'removeAccess' then
                            devPrint("Opening Remove access to House ID: " ..
                                tostring(houseId) .. " for character ID: " .. tostring(charIdentifier))
                            TriggerClientEvent('bcc-housing:receiveHouseIdremove', src, houseId)
                        end
                    else
                        -- Notify the client if the player does not have access to the house
                        devPrint("Player does not have access to the house ID: " .. tostring(houseId))
                        TriggerClientEvent('bcc-housing:receiveHouseId', src, nil)
                    end
                else
                    -- Notify the client if no house was found
                    devPrint("Error: No results found for house ID: " .. tostring(houseId))
                    TriggerClientEvent('bcc-housing:receiveHouseId', src, nil)
                end
            end)
        else
            -- Notify the client if no house ID was provided
            devPrint("Error: No house ID provided")
            TriggerClientEvent('bcc-housing:receiveHouseId', src, nil)
        end
    else
        -- Notify the client if no character was found
        devPrint("Error: No character found for source: " .. tostring(src))
        TriggerClientEvent('bcc-housing:receiveHouseId', src, nil)
    end
end)

-- Event to get the owner of a house based on the house ID
RegisterServerEvent('bcc-housing:getHouseOwner')
AddEventHandler('bcc-housing:getHouseOwner', function(houseId)
    local src = source                      -- Get the source of the event
    local user = VORPcore.getUser(src)      -- Get the user object for the player
    local character = user.getUsedCharacter -- Get the character object for the player

    if character then
        local charIdentifier = character.charIdentifier -- Get the character identifier
        devPrint("getHouseOwner event triggered with charidentifier: " ..
            tostring(charIdentifier) .. " for House ID: " .. tostring(houseId))

        if houseId then
            -- Query the database to retrieve house data based on the house ID
            MySQL.query("SELECT * FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId }, function(result)
                if result and #result > 0 then
                    local houseData = result[1] -- Get the house data from the query result
                    local isOwner = tostring(houseData.charidentifier) == tostring(charIdentifier)

                    -- Notify the client about the house owner
                    devPrint("Owner of House ID: " ..
                        tostring(houseId) .. " is charidentifier: " .. tostring(houseData.charidentifier))
                    TriggerClientEvent('bcc-housing:receiveHouseOwner', src, houseId, isOwner)
                else
                    -- Notify the client if no house was found
                    devPrint("Error: No results found for house ID: " .. tostring(houseId))
                    TriggerClientEvent('bcc-housing:receiveHouseOwner', src, houseId, nil)
                end
            end)
        else
            -- Notify the client if no house ID was provided
            devPrint("Error: No house ID provided")
            TriggerClientEvent('bcc-housing:receiveHouseOwner', src, houseId, nil)
        end
    else
        -- Notify the client if no character was found
        devPrint("Error: No character found for source: " .. tostring(src))
        TriggerClientEvent('bcc-housing:receiveHouseOwner', src, houseId, nil)
    end
end)

-- Event to check if a house exists in the database
RegisterNetEvent('bcc-housing:CheckIfHouseExists')
AddEventHandler('bcc-housing:CheckIfHouseExists', function(houseId)
    local src = source -- Get the source of the event

    -- Query the database to check if the house ID exists
    MySQL.Async.fetchScalar('SELECT houseid FROM bcchousing WHERE houseid = @houseid', { ['@houseid'] = houseId },
        function(result)
            local exists = result ~= nil -- Determine if the house exists
            -- Notify the client about the house's existence status
            TriggerClientEvent('bcc-housing:HouseExistenceChecked', src, exists, houseId)
        end)
end)
