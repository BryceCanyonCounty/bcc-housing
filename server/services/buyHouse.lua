-- Event to handle the purchasing of a house
RegisterServerEvent('bcc-housing:buyHouse')
AddEventHandler('bcc-housing:buyHouse', function(houseCoords, moneyType)
    local src = source                               -- Get the source of the event
    local User = VORPcore.getUser(src)               -- Get the user object for the player
    local Character = User.getUsedCharacter          -- Get the character object for the player
    local houseCoordsJson = json.encode(houseCoords) -- Encode the house coordinates for database comparison

    -- Check how many houses the player currently owns
    local param = { ['@charidentifier'] = Character.charIdentifier }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE charidentifier=@charidentifier", param)

    if #result >= Config.Setup.MaxHousePerChar then
        -- Notify the player that they have reached the house limit
        VORPcore.NotifyAvanced(src, _U('youOwnMaximum'), "generic_textures", "tick", "COLOR_WHITE", 4000)
        return
    end

    for _, house in pairs(Config.HousesForSale) do
        if house.uniqueName and #(house.houseCoords - houseCoords) < 0.1 then -- Check if the coordinates match and house has uniqueName
            local moneyAmount
            if moneyType == 0 then
                moneyAmount = house.price
            elseif moneyType == 1 then
                moneyAmount = house.rentalDeposit
            end
            if (moneyType == 0 and Character.money >= moneyAmount) or
                (moneyType == 1 and Character.gold >= moneyAmount) then
                -- Check if the house already exists in the database by checking the unique name
                MySQL.query('SELECT * FROM bcchousing WHERE uniqueName = ?', { house.uniqueName }, function(result)
                    if not result[1] then
                        -- Clear the blips for the house that is being purchased
                        TriggerClientEvent('bcc-housing:clearBlips', src, house.houseId)

                        local houseAction
                        if moneyType == 0 then
                            houseAction = 'purchased'
                        else
                            houseAction = 'rented'
                        end

                        -- House not found, proceed with the purchase
                        local parameters = {
                            ['@charidentifier'] = Character.charIdentifier,
                            ['@house_coords'] = houseCoordsJson,
                            ['@house_radius_limit'] = house.houseRadiusLimit,
                            ['@doors'] = '[]', -- Placeholder for doors, to be updated after insertion
                            ['@invlimit'] = house.invLimit,
                            ['@tax_amount'] = moneyType == 0 and house.taxAmount or house.rentCharge,
                            ['@tpInt'] = house.tpInt,
                            ['@tpInstance'] = house.tpInstance,
                            ['@uniqueName'] = house.uniqueName,
                            ['@ownershipStatus'] = houseAction,
                        }

                        -- Insert the new house into the database
                        MySQL.Async.execute(
                            "INSERT INTO `bcchousing` (`charidentifier`, `house_coords`, `house_radius_limit`, `doors`, `invlimit`, `tax_amount`, `tpInt`, `tpInstance`, `uniqueName`, `ownershipStatus`) VALUES (@charidentifier, @house_coords, @house_radius_limit, @doors, @invlimit, @tax_amount, @tpInt, @tpInstance, @uniqueName, @ownershipStatus)",
                            parameters, function(rowsChanged)
                                -- After house purchase, handle door insertion
                                if rowsChanged > 0 then
                                    -- After house insert, get the inserted house's unique ID to update its doors
                                    MySQL.Async.fetchScalar("SELECT houseid FROM bcchousing WHERE house_coords = ?",
                                        { houseCoordsJson }, function(houseId)
                                        insertHouseDoors(house.doors, Character.charIdentifier, houseId, house.uniqueName)
                                    end)
                                else
                                    devPrint("Error: Failed to insert house into bcchousing.")
                                end
                            end
                        )

                        -- Deduct the money from the player
                        Character.removeCurrency(moneyType, moneyAmount)

                        -- Notify the player that the house was purchased
                        TriggerClientEvent('bcc-housing:housePurchased', src, houseCoords)
                        VORPcore.NotifyAvanced(src, _U("housePurchaseSuccess", house.name, moneyAmount), "inventory_items", "money_billstack", "COLOR_WHITE", 4000)

                        -- Send a message to Discord
                        local currency = " **Unknown currency**"
                        if moneyType == 0 then
                            currency = " **Dolars**"
                        elseif moneyType == 1 then
                            currency = " **Gold bars**"
                        end
                        Discord:sendMessage("House purchased by charIdentifier: " .. tostring(Character.charIdentifier) .. "\nHouse: " .. house.name .. " was **" .. houseAction .. "** for $" .. tostring(moneyAmount) .. currency .. "\nCharacter Name: " .. Character.firstname .. " " .. Character.lastname)

                        -- Trigger the client-side to reload the house data
                        TriggerClientEvent('bcc-housing:ClientRecHouseLoad', src)
                    else
                        -- Notify the player if the house has already been purchased
                        VORPcore.NotifyAvanced(src, _U("housePurchaseFailed"), "generic_textures", "tick", "COLOR_WHITE", 4000)
                    end
                end)
            else
                -- Notify the player if they do not have enough money
                if moneyType == 0 then
                    VORPcore.NotifyAvanced(src, _U('notEnoughMoney'), "scoretimer_textures", "scoretimer_generic_cross", "COLOR_WHITE", 4000)
                else
                    VORPcore.NotifyAvanced(src, _U('notEnoughGold'), "scoretimer_textures", "scoretimer_generic_cross", "COLOR_WHITE", 4000)
                end
            end
            break
        end
    end
end)

-- Function to insert doors into the doorlocks table and update the bcchousing table
function insertHouseDoors(doors, charidentifier, houseId, uniqueName)
    local doorIds = {} -- Store door ids to update the house later

    -- Get the house configuration from the uniqueName to ensure correct doors are inserted
    local houseConfig = nil
    for _, house in pairs(Config.HousesForSale) do
        if house.uniqueName == uniqueName then
            houseConfig = house
            break
        end
    end

    if houseConfig and houseConfig.doors and #houseConfig.doors > 0 then
        -- Insert each door specific to the house's unique configuration
        for _, door in pairs(houseConfig.doors) do
            local doorinfo = door.doorinfo
            local locked = door.locked and 'true' or 'false'
            local jobsAllowed = '[]' -- Default no jobs allowed
            local keyItem = 'none'   -- Default key item
            local idsAllowed = '[' .. charidentifier .. ']'

            local doorData = MySQL.query.await('SELECT * FROM `doorlocks` WHERE `doorinfo` = ?', { doorinfo })
            if not doorData then
                devPrint("Database query failed while checking if the door exists.")
                -- VORPcore.NotifyRightTip(_source, _U("dbError"), 4000)
                return
            end
            if #doorData == 0 then
                -- Insert the door if it doesn't exist
                local doorId = MySQL.insert.await(
                    "INSERT INTO doorlocks (doorinfo, jobsallowedtoopen, keyitem, locked, ids_allowed) VALUES (?, ?, ?, ?, ?)",
                    { doorinfo, jobsAllowed, keyItem, locked, idsAllowed }
                )
                devPrint("Door inserted into DB with jobs: " .. jobsAllowed .. ", key: " .. keyItem .. ", ids: " .. idsAllowed)

                TriggerClientEvent('bcc-doorlocks:ClientSetDoorStatus', -1, json.decode(doorinfo), locked, true, false, false)

                -- Debug: print the values to be inserted
                devPrint("Door inserted with ID: ", doorId)
                table.insert(doorIds, doorId)

                -- VORPcore.NotifyRightTip(_source, _U("doorCreated"), 4000)
            else
                devPrint("Door already exists in DB")
                local affectedRows = MySQL.update.await(
                    "UPDATE doorlocks SET jobsallowedtoopen = ?, keyitem = ?, locked = ?, ids_allowed = ? WHERE doorinfo = ?",
                    { jobsAllowed, keyItem, locked, idsAllowed, doorinfo }
                )
                assert(affectedRows > 0, "Failed to update doorlocks table with new values.")
                devPrint("Door updated in DB with jobs: " .. jobsAllowed .. ", key: " .. keyItem .. ", ids: " .. idsAllowed)

                if #doorData > 1 then
                    print("Multiple doors found with the same doorinfo:", doorData[0].doorinfo)
                    print("Multiple doors found with the same doorinfo:", doorData[1].doorinfo)
                end
                -- TriggerClientEvent('bcc-doorlocks:ClientSetDoorStatus', -1, json.decode(doorinfo), locked, false, false, false)
                for i = 1, #doorData do
                    local doorId = doorData[i].doorid
                    devPrint("Door inserted with ID: ", doorId)
                    table.insert(doorIds, doorId)
                end
                -- VORPcore.NotifyRightTip(_source, _U("doorExists"), 4000)
            end
        end

        -- Once all doors are inserted, update the house with the door IDs
        if #doorIds ~= #houseConfig.doors then
            devPrint("Failed to insert all doors for the house.", #doorIds .. " from " .. #houseConfig.doors)
        end
        local doorIdsJson = json.encode(doorIds)
        MySQL.Async.execute("UPDATE bcchousing SET doors = ? WHERE houseid = ?", { doorIdsJson, houseId },
            function(affectedRows)
                if affectedRows > 0 then
                    devPrint("Updated house with door IDs:" .. doorIdsJson)
                else
                    devPrint("Failed to update house with door IDs.")
                end
            end
        )
    else
        devPrint("No doors found for the house.")
    end
end

-- Event to retrieve all purchased houses
RegisterNetEvent('bcc-housing:getPurchasedHouses')
AddEventHandler('bcc-housing:getPurchasedHouses', function()
    local src = source         -- Get the source of the event
    local purchasedHouses = {} -- Initialize a table to hold purchased houses

    -- Query the database for all purchased houses by uniqueName
    MySQL.query('SELECT uniqueName FROM bcchousing', {}, function(results)
        if #results > 0 then
            for _, house in ipairs(results) do
                for _, configHouse in pairs(Config.HousesForSale) do
                    if house.uniqueName == configHouse.uniqueName then
                        table.insert(purchasedHouses, configHouse.houseCoords) -- Insert the house coordinates from config
                    end
                end
            end
        end

        -- Send the list of purchased houses to the client
        TriggerClientEvent('bcc-housing:sendPurchasedHouses', src, purchasedHouses)
    end)
end)
