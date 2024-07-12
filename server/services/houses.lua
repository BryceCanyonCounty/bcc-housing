RegisterServerEvent('bcc-housing:CreationDBInsert', function(tpHouse, owner, radius, doors, houseCoords, invLimit, ownerSource, taxAmount)
    local _source = source
    local taxes = tonumber(taxAmount) > 0 and tonumber(taxAmount) or 0
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param

    if not tpHouse then
        param = {
            ['charidentifier'] = owner,
            ['radius'] = radius,
            ["doors"] = json.encode(doors),
            ['houseCoords'] = json.encode(houseCoords),
            ['invlimit'] = invLimit,
            ['taxes'] = taxes,
            ['tpInt'] = 0,
            ['tpInstance'] = 0
        }
    else
        param = {
            ['charidentifier'] = owner,
            ['radius'] = radius,
            ['doors'] = 'none',
            ['houseCoords'] = json.encode(houseCoords),
            ['invlimit'] = invLimit,
            ['taxes'] = taxes,
            ['tpInt'] = tpHouse,
            ['tpInstance'] = 52324 + _source
        }
    end

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE charidentifier=@charidentifier", param)
    if #result < Config.Setup.MaxHousePerChar then
        MySQL.insert("INSERT INTO bcchousing ( `charidentifier`,`house_radius_limit`,`doors`,`house_coords`,`invlimit`,`tax_amount`,`tpInt`,`tpInstance` ) VALUES ( @charidentifier,@radius,@doors,@houseCoords,@invlimit,@taxes,@tpInt,@tpInstance )", param)
        Discord:sendMessage(_U("houseCreatedWebhook") .. tostring(character.charIdentifier), _U("houseCreatedWebhookGivenToo") .. tostring(owner))
        Wait(1500)
        if ownerSource ~= nil then
            TriggerClientEvent('bcc-housing:ClientRecHouseLoad', ownerSource)
        end
    else
        VORPcore.NotifyRightTip(_source, _U("maxHousesReached"), 4000)
    end
end)

RegisterServerEvent('bcc-housing:CheckIfHasHouse')
AddEventHandler('bcc-housing:CheckIfHasHouse', function(passedSource)
    local _source = passedSource or source
    local character = VORPcore.getUser(_source).getUsedCharacter

    devPrint("Checking if player owns or has access to a house for character ID: " .. character.charIdentifier)

    MySQL.query("SELECT * FROM bcchousing", {}, function(result)
        local accessibleHouses = {}

        if #result > 0 then
            for k, v in pairs(result) do
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

                if character.charIdentifier == tonumber(v.charidentifier) then
                    table.insert(accessibleHouses, v.houseid)
                    TriggerClientEvent('bcc-housing:OwnsHouseClientHandler', _source, v, true)
                else
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

        TriggerClientEvent('bcc-housing:ReceiveAccessibleHouses', _source, accessibleHouses)
    end)
end)

RegisterServerEvent('bcc-house:OpenHouseInv')
AddEventHandler('bcc-house:OpenHouseInv', function(houseId)
    local src = source
    local user = VORPcore.getUser(src)
    local character = user.getUsedCharacter

    if character then
        local charIdentifier = character.charIdentifier
        devPrint("Opening house inventory for House ID: " .. tostring(houseId) .. " and character ID: " .. tostring(charIdentifier))

        MySQL.query("SELECT * FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId }, function(result)
            if result and #result > 0 then
                local houseData = result[1]

                if tostring(houseData.charidentifier) == tostring(charIdentifier) then
                    devPrint("Player is the owner of house ID: " .. tostring(houseId))
                    exports.vorp_inventory:openInventory(src, 'Player_' .. tostring(houseId) .. '_bcc-houseinv')
                else
                    local allowedIds = json.decode(houseData.allowed_ids) or {}
                    for _, id in ipairs(allowedIds) do
                        if tostring(id) == tostring(charIdentifier) then
                            devPrint("Player is allowed to access house ID: " .. tostring(houseId))
                            exports.vorp_inventory:openInventory(src, 'Player_' .. tostring(houseId) .. '_bcc-houseinv')
                            return
                        end
                    end
                    devPrint("Player does not have access to house inventory: " .. tostring(houseId))
                    VORPcore.NotifyLeft(src, "You do not have access to this house.", "", "generic_textures", "generic_cross", 5000)
                end
            else
                devPrint("Error: No results found for house ID: " .. tostring(houseId))
                VORPcore.NotifyLeft(src, "No house found with the given ID.", "", "generic_textures", "generic_cross", 5000)
            end
        end)
    else
        devPrint("Error: No character found for source: " .. tostring(src))
        VORPcore.NotifyLeft(src, "No character found.", "", "generic_textures", "generic_cross", 5000)
    end
end)

RegisterServerEvent('bcc-housing:NewPlayerGivenAccess')
AddEventHandler('bcc-housing:NewPlayerGivenAccess', function(id, houseid, recSource)
    devPrint("NewPlayerGivenAccess event triggered with ID: " .. tostring(id) .. ", HouseID: " .. tostring(houseid) .. ", RecSource: " .. tostring(recSource))

    local param = { ['@houseid'] = houseid }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = @houseid", param)

    if not result or #result == 0 then
        devPrint("Error: No results found for houseid: " .. tostring(houseid))
        return
    end

    local houseData = result[1]
    if not houseData then
        devPrint("Error: House data is nil for houseid: " .. tostring(houseid))
        return
    end

    local idsTable = {}
    if houseData.allowed_ids ~= 'none' and houseData.allowed_ids ~= nil then
        idsTable = json.decode(houseData.allowed_ids)
        if not idsTable then
            devPrint("Error: Failed to decode 'allowed_ids' for houseid: " .. tostring(houseid))
            return
        end
    end

    local exists = false
    for _, v in ipairs(idsTable) do
        if id == v then
            exists = true
            break
        end
    end
    devPrint("Exists check: " .. tostring(exists))

    if not exists then
        table.insert(idsTable, id)
        local encodedIds = json.encode(idsTable)
        MySQL.update("UPDATE bcchousing SET allowed_ids = ? WHERE houseid = ?", { encodedIds, houseid }, function(affectedRows)
            if affectedRows > 0 then
                devPrint("Access list updated successfully for houseid: " .. tostring(houseid))
                TriggerClientEvent('bcc-housing:ClientRecHouseLoad', recSource)
            else
                devPrint("Update failed for houseid: " .. tostring(houseid))
                if recSource then
                    VORPcore.NotifyRightTip(recSource, "Update failed, please try again.", 4000)
                end
            end
        end)
    else
        devPrint("ID already exists in the access list for houseid: " .. tostring(houseid))
    end

    if houseData.doors then
        local doors = json.decode(houseData.doors)
        if doors then
            for _, doorId in ipairs(doors) do
                devPrint("Updating door access for door ID: " .. tostring(doorId))
                updateDoorAccess(doorId, id, false)
            end
        else
            devPrint("Error: Failed to decode 'doors' for houseid: " .. tostring(houseid))
        end
    end
end)

function updateDoorAccess(doorId, newId)
    devPrint("Updating door access for door ID: " .. tostring(doorId) .. " with new ID: " .. tostring(newId))
    local result = MySQL.query.await("SELECT ids_allowed FROM doorlocks WHERE doorid=@doorId", {
        ['doorId'] = doorId
    })
    if result and #result > 0 then
        local allowedIdTable = json.decode(result[1].ids_allowed) or {}
        if not table.contains(allowedIdTable, newId) then
            table.insert(allowedIdTable, newId)
            local param = {
                ['ids_allowed'] = json.encode(allowedIdTable),
                ['doorId'] = doorId
            }
            MySQL.update("UPDATE doorlocks SET ids_allowed=@ids_allowed WHERE doorid=@doorId", param)
        end
    end
end

RegisterServerEvent('bcc-housing:InsertFurnitureIntoDB', function(furnTable, houseId)
    devPrint("Inserting furniture into DB for house ID: " .. tostring(houseId))
    local param = { ['houseid'] = houseId }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if result[1].furniture == 'none' then
        local param2 = {
            ['houseid'] = houseId,
            ['furn'] = json.encode({ furnTable })
        }
        MySQL.update("UPDATE bcchousing SET furniture=@furn WHERE houseid=@houseid", param2)
    else
        local oldFurn = json.decode(result[1].furniture)
        table.insert(oldFurn, furnTable)
        local param2 = {
            ['houseid'] = houseId,
            ['furn'] = json.encode(oldFurn)
        }
        MySQL.update("UPDATE bcchousing SET furniture=@furn WHERE houseid=@houseid", param2)
    end
end)

local storedFurn = {}
RegisterServerEvent('bcc-housing:FurniturePlacedCheck', function(houseid, deletion, close)
    local _source = source
    local param = {
        ['houseid'] = houseid,
        ['source'] = tostring(_source)
    }

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if result[1] then
        if result[1].player_source_spawnedfurn == 'none' and close then
            if result[1].furniture ~= 'none' then
                local furn = json.decode(result[1].furniture)
                TriggerClientEvent('bcc-housing:SpawnFurnitureEvent', _source, furn)
                MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn=@source", param)
            end
        elseif tonumber(result[1].player_source_spawnedfurn) == _source then
            if deletion then
                DelSpawnedFurn(_source)
            end
        end
    end
end)

RegisterServerEvent('bcc-housing:StoreFurnForDeletion', function(entId, houseid)
    local _source = source
    devPrint("Storing furniture for deletion with entity ID: " .. tostring(entId) .. " for house ID: " .. tostring(houseid))

    if storedFurn[_source] == nil then
        storedFurn[_source] = {}
        local param = {
            ['houseid'] = houseid,
            ['source'] = tostring(_source)
        }
        MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn=@source", param)
    end
    table.insert(storedFurn[_source], entId)
end)

AddEventHandler('playerDropped', function()
    devPrint("Player dropped event for source: " .. tostring(source))
    DelSpawnedFurn(source)
end)

function DelSpawnedFurn(source)
    local result = MySQL.query.await("SELECT * FROM bcchousing")
    local houseFurnDeleted = nil
    if #result > 0 then
        for k, v in pairs(result) do
            if source == tonumber(v.player_source_spawnedfurn) then
                houseFurnDeleted = v
                if storedFurn[source] ~= nil then
                    for w, e in pairs(storedFurn[source]) do
                        local netEntId = NetworkGetEntityFromNetworkId(e)
                        if DoesEntityExist(netEntId) then
                            DeleteEntity(netEntId)
                        end
                    end
                end
            end
        end
    end
    if houseFurnDeleted ~= nil then
        local param = {
            ['resetvar'] = 'none',
            ['houseid'] = houseFurnDeleted.houseid
        }
        MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn=@resetvar WHERE houseid=@houseid", param)
    end
end

RegisterServerEvent('bcc-housing:BuyFurn', function(cost, entId, furnitureCreatedTable)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    devPrint("Buying furniture with cost: " .. tostring(cost) .. " and entity ID: " .. tostring(entId))

    if character.money >= tonumber(cost) then
        character.removeCurrency(0, tonumber(cost))
        TriggerClientEvent('bcc-housing:ClientFurnBought', _source, furnitureCreatedTable, entId)
        Discord:sendMessage(_U("furnWebHookBought") .. tostring(character.charIdentifier), _U("furnWebHookBoughtModel") .. tostring(furnitureCreatedTable.model) .. _U("furnWebHookSoldPrice") .. tostring(cost))
    else
        VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
        TriggerClientEvent('bcc-housing:ClientFurnBoughtFail', _source)
    end
end)

RegisterServerEvent('bcc-housing:ServerSideRssStop', function()
    devPrint("Server side RSS stop event triggered")
    MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn='none'")
end)

RegisterServerEvent('bcc-housing:GetOwnerFurniture', function(houseId)
    devPrint("Getting owner furniture for house ID: " .. tostring(houseId))
    local param = { ['houseid'] = houseId }
    local _source = source
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)

    if result and #result > 0 then
        local houseData = result[1]
        local furnitureData = houseData.furniture or '[]'

        local furniture, decodeErr = json.decode(furnitureData)
        if not decodeErr and furniture then
            if #furniture > 0 then
                TriggerClientEvent('bcc-housing:SellOwnedFurnMenu', _source, furniture)
            else
                VORPcore.NotifyRightTip(_source, _U("noFurn"), 4000)
            end
        else
            devPrint("Error decoding furniture data: " .. tostring(decodeErr))
            VORPcore.NotifyRightTip(_source, "Error loading furniture data.", 4000)
        end
    else
        VORPcore.NotifyRightTip(_source, _U("noFurn"), 4000)
    end
end)

RegisterServerEvent('bcc-housing:FurnSoldRemoveFromTable', function(furnTable, houseId, wholeFurnTable, wholeFurnTableKey)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    devPrint("Furniture sold, removing from table for house ID: " .. tostring(houseId))

    if wholeFurnTable and tonumber(wholeFurnTableKey) and wholeFurnTable[tonumber(wholeFurnTableKey)] then
        table.remove(wholeFurnTable, tonumber(wholeFurnTableKey))
        local newDbTable = 'none'
        if #wholeFurnTable > 0 then
            newDbTable = json.encode(wholeFurnTable)
        end

        local params = {
            ['houseid'] = houseId,
            ['newFurnTable'] = newDbTable
        }
        MySQL.update("UPDATE bcchousing SET furniture=@newFurnTable WHERE houseid=@houseid", params, function(affectedRows)
            if affectedRows > 0 then
                VORPcore.NotifyRightTip(_source, _U("furnSold"), 4000)
                character.addCurrency(0, tonumber(furnTable.sellprice))
                Discord:sendMessage(_U("furnWebHookSold") .. character.charIdentifier, _U("furnWebHookSoldModel") .. tostring(furnTable.model) .. _U("furnWebHookSoldPrice") .. tostring(furnTable.sellprice))
            else
                VORPcore.NotifyRightTip(_source, _U("furnNotSold"), 4000)
            end
        end)
    else
        VORPcore.NotifyRightTip(_source, _U("furnNotSoldInvalid"), 4000)
    end

    TriggerClientEvent('bcc-housing:ClientCloseAllMenus', _source)
end)

RegisterServerEvent('bcc-housing:LedgerHandling')
AddEventHandler('bcc-housing:LedgerHandling', function(amountToInsert, houseid)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local amountToInsertNumber = tonumber(amountToInsert)
    local houseIdNumber = tonumber(houseid)

    devPrint("Handling ledger for amount: " .. tostring(amountToInsertNumber) .. " and house ID: " .. tostring(houseIdNumber))

    if not amountToInsertNumber or not houseIdNumber then
        devPrint("Invalid input data. Amount: " .. tostring(amountToInsert) .. " House ID: " .. tostring(houseid))
        return
    end

    MySQL.query("SELECT ledger, tax_amount FROM bcchousing WHERE houseid = ?", { houseIdNumber }, function(result)
        if result and #result > 0 then
            local ledger = tonumber(result[1].ledger)
            local tax_amount = tonumber(result[1].tax_amount)
            local maxInsertAmount = tax_amount - ledger

            local insertionAmount = math.min(amountToInsertNumber, maxInsertAmount)

            if insertionAmount > 0 then
                if character.money >= insertionAmount then
                    character.removeCurrency(0, insertionAmount)
                    MySQL.update("UPDATE bcchousing SET ledger = ledger + ? WHERE houseid = ?", { insertionAmount, houseIdNumber }, function(affectedRows)
                        if affectedRows > 0 then
                            VORPcore.NotifyLeft(_source, _U("ledgerAmountInesrted") .. " $" .. insertionAmount, "", "inventory_items", "money_moneystack", 5000)
                        else
                            VORPcore.NotifyLeft(_source, _U("ledgerUpdateFailed"), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
                        end
                    end)
                else
                    VORPcore.NotifyLeft(_source, _U("noMoney"), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
                end
            else
                VORPcore.NotifyLeft(_source, "Maximum amount of money is already stored", "", "menu_textures", "menu_icon_alert", 5000)
            end
        else
            VORPcore.NotifyLeft(_source, _U("noHouseFound"), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
        end
    end)
end)

RegisterServerEvent('bcc-housing:CheckLedger')
AddEventHandler('bcc-housing:CheckLedger', function(houseid)
    local _source = source
    devPrint("Checking ledger for house ID: " .. tostring(houseid))
    local param = { ['houseid'] = houseid }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if #result > 0 then
        VORPcore.NotifyLeft(_source, tostring(result[1].ledger) .. '/' .. tostring(result[1].tax_amount), "", "menu_textures", "menu_icon_alert", 5000)
    end
end)

RegisterServerEvent('bcc-housing:getHouseId')
AddEventHandler('bcc-housing:getHouseId', function(context, houseId)
    local src = source
    local user = VORPcore.getUser(src)
    local character = user.getUsedCharacter

    if character then
        local charIdentifier = character.charIdentifier
        devPrint("getHouseId event triggered with charidentifier: " .. tostring(charIdentifier) .. " for House ID: " .. tostring(houseId))

        if houseId then
            MySQL.query("SELECT * FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId }, function(result)
                if result and #result > 0 then
                    local houseData = result[1]
                    local hasAccess = false

                    if tostring(houseData.charidentifier) == tostring(charIdentifier) then
                        devPrint("Player is the owner of house ID: " .. tostring(houseId))
                        hasAccess = true
                    else
                        local allowedIds = json.decode(houseData.allowed_ids) or {}
                        for _, id in ipairs(allowedIds) do
                            if tostring(id) == tostring(charIdentifier) then
                                devPrint("Player is allowed to access house ID: " .. tostring(houseId))
                                hasAccess = true
                                break
                            end
                        end
                    end

                    if hasAccess then
                        if context == 'inv' then
                            devPrint("Opening house inventory for House ID: " .. tostring(houseId) .. " and character ID: " .. tostring(charIdentifier))
                            TriggerClientEvent('bcc-housing:receiveHouseIdinv', src, houseId)
                        elseif context == 'access' then
                            devPrint("Granting access to House ID: " .. tostring(houseId) .. " for character ID: " .. tostring(charIdentifier))
                            TriggerClientEvent('bcc-housing:receiveHouseId', src, houseId)
                        elseif context == 'removeAccess' then
                            devPrint("Opening Remove access to House ID: " .. tostring(houseId) .. " for character ID: " .. tostring(charIdentifier))
                            TriggerClientEvent('bcc-housing:receiveHouseIdremove', src, houseId)
                        end
                    else
                        devPrint("Player does not have access to the house ID: " .. tostring(houseId))
                        TriggerClientEvent('bcc-housing:receiveHouseId', src, nil)
                    end
                else
                    devPrint("Error: No results found for house ID: " .. tostring(houseId))
                    TriggerClientEvent('bcc-housing:receiveHouseId', src, nil)
                end
            end)
        else
            devPrint("Error: No house ID provided")
            TriggerClientEvent('bcc-housing:receiveHouseId', src, nil)
        end
    else
        devPrint("Error: No character found for source: " .. tostring(src))
        TriggerClientEvent('bcc-housing:receiveHouseId', src, nil)
    end
end)

RegisterServerEvent('bcc-housing:getHouseOwner')
AddEventHandler('bcc-housing:getHouseOwner', function(houseId)
    local src = source
    local user = VORPcore.getUser(src)
    local character = user.getUsedCharacter

    if character then
        local charIdentifier = character.charIdentifier
        devPrint("getHouseOwner event triggered with charidentifier: " .. tostring(charIdentifier) .. " for House ID: " .. tostring(houseId))

        if houseId then
            MySQL.query("SELECT * FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId }, function(result)
                if result and #result > 0 then
                    local houseData = result[1]
                    local isOwner = tostring(houseData.charidentifier) == tostring(charIdentifier)

                    devPrint("Owner of House ID: " .. tostring(houseId) .. " is charidentifier: " .. tostring(houseData.charidentifier))
                    TriggerClientEvent('bcc-housing:receiveHouseOwner', src, houseId, isOwner)
                else
                    devPrint("Error: No results found for house ID: " .. tostring(houseId))
                    TriggerClientEvent('bcc-housing:receiveHouseOwner', src, houseId, nil)
                end
            end)
        else
            devPrint("Error: No house ID provided")
            TriggerClientEvent('bcc-housing:receiveHouseOwner', src, houseId, nil)
        end
    else
        devPrint("Error: No character found for source: " .. tostring(src))
        TriggerClientEvent('bcc-housing:receiveHouseOwner', src, houseId, nil)
    end
end)

RegisterServerEvent('bcc-housing:getPlayersWithAccess')
AddEventHandler('bcc-housing:getPlayersWithAccess', function(houseId)
    local src = source
    devPrint("Fetching players with access for House ID: " .. tostring(houseId))

    -- Query to fetch allowed character IDs for the house
    MySQL.query("SELECT allowed_ids FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId }, function(result)
        if result and #result > 0 then
            local allowedIds = json.decode(result[1].allowed_ids)
            if allowedIds and #allowedIds > 0 then
                -- Convert the allowed IDs list into a comma-separated string for the SQL query
                local allowedIdsString = table.concat(allowedIds, ',')
                
                -- Fetching detailed character information from the database
                MySQL.query("SELECT * FROM characters WHERE charidentifier IN (" .. allowedIdsString .. ")", {}, function(characterDetails)
                    if characterDetails and #characterDetails > 0 then
                        for _, character in ipairs(characterDetails) do
                            devPrint("Character found: ID=" .. character.charidentifier .. ", Name=" .. character.firstname .. " " .. character.lastname)
                        end
                        -- Send character details back to the client
                        TriggerClientEvent('bcc-housing:ReceivePlayersWithAccess', src, characterDetails)
                    else
                        devPrint("No character details found for the allowed IDs")
                        TriggerClientEvent('bcc-housing:ReceivePlayersWithAccess', src, {})
                    end
                end)
            else
                devPrint("No allowed IDs found for House ID: " .. tostring(houseId))
                TriggerClientEvent('bcc-housing:ReceivePlayersWithAccess', src, {})
            end
        else
            devPrint("No players found with access to house ID: " .. tostring(houseId))
            TriggerClientEvent('bcc-housing:ReceivePlayersWithAccess', src, {})
        end
    end)
end)

RegisterServerEvent('bcc-housing:RemovePlayerAccess')
AddEventHandler('bcc-housing:RemovePlayerAccess', function(houseId, playerId)
    local src = source
    devPrint("Starting removal of player access. House ID: " .. tostring(houseId) .. ", Player ID: " .. tostring(playerId))

    -- Query to get the current list of allowed IDs for the house
    MySQL.query("SELECT allowed_ids FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId }, function(result)
        if result and #result > 0 then
            local allowedIds = json.decode(result[1].allowed_ids) or {}
            devPrint("Current allowed IDs: " .. json.encode(allowedIds))

            -- Searching and removing the player ID from the allowed IDs list
            local found = false
            for i, id in ipairs(allowedIds) do
                if id == playerId then
                    table.remove(allowedIds, i)
                    found = true
                    devPrint("Found and removed player ID from allowed list. Updated list: " .. json.encode(allowedIds))
                    break
                end
            end

            if not found then
                devPrint("Player ID not found in allowed list, nothing to remove.")
                TriggerClientEvent('bcc-housing:PlayerAccessRemovalFailed', src, houseId, playerId, "Player ID not in allowed list.")
                return
            end

            -- Updating the allowed IDs list in the database
            MySQL.update("UPDATE bcchousing SET allowed_ids = @allowedids WHERE houseid = @houseid", {
                ['@allowedids'] = json.encode(allowedIds),
                ['@houseid'] = houseId
            }, function(affectedRows)
                if affectedRows > 0 then
                    devPrint("Removed player access successfully for Player ID: " .. tostring(playerId))
                    VORPcore.NotifyRightTip(src, "Removed player access successfully for Player ID: " .. tostring(playerId))
                else
                    devPrint("Failed to update database with new allowed IDs list.")
                    VORPcore.NotifyRightTip(src, 'Failed to update database with new allowed IDs list.')
                    --TriggerClientEvent('bcc-housing:PlayerAccessRemovalFailed', src, houseId, playerId, "Database update failed.")
                end
            end)
        else
            devPrint("No house found with ID: " .. tostring(houseId) .. " or allowed_ids is empty.")
            TriggerClientEvent('bcc-housing:PlayerAccessRemovalFailed', src, houseId, playerId, "No such house ID or empty allowed list.")
        end
    end)
end)
