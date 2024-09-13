-- Event to handle the purchasing of a house
RegisterServerEvent('bcc-housing:buyHouse')
AddEventHandler('bcc-housing:buyHouse', function(houseCoords)
    local src = source                               -- Get the source of the event
    local User = VORPcore.getUser(src)               -- Get the user object for the player
    local Character = User.getUsedCharacter          -- Get the character object for the player
    local houseCoordsJson = json.encode(houseCoords) -- Encode the house coordinates for database comparison

    -- Check how many houses the player currently owns
    local param = { ['@charidentifier'] = Character.charIdentifier }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE charidentifier=@charidentifier", param)
    
    if #result >= Config.Setup.MaxHousePerChar then
        -- Notify the player that they have reached the house limit
        VORPcore.NotifyAvanced(src, _U('youOwnMaximum'), "generic_textures", "tick", "COLOR_RED", 4000)
        return
    end

    for _, house in pairs(Config.HousesForSale) do
        if house.uniqueName and #(house.houseCoords - houseCoords) < 0.1 then -- Check if the coordinates match and house has uniqueName
            if Character.money >= house.price then
                -- Check if the house already exists in the database by checking the unique name
                MySQL.query('SELECT * FROM bcchousing WHERE uniqueName = ?', { house.uniqueName }, function(result)
                    if not result[1] then
                        -- Clear the blips for the house that is being purchased
                        TriggerClientEvent('bcc-housing:clearBlips', src, house.houseId)

                        -- House not found, proceed with the purchase
                        local parameters = {
                            ['@charidentifier'] = Character.charIdentifier,
                            ['@house_coords'] = houseCoordsJson,
                            ['@house_radius_limit'] = house.houseRadiusLimit,
                            ['@doors'] = '[]', -- Placeholder for doors, to be updated after insertion
                            ['@invlimit'] = house.invLimit,
                            ['@tax_amount'] = house.taxAmount,
                            ['@tpInt'] = house.tpInt,
                            ['@tpInstance'] = house.tpInstance,
                            ['@uniqueName'] = house.uniqueName
                        }

                        -- Insert the new house into the database
                        MySQL.Async.execute(
                            "INSERT INTO `bcchousing` (`charidentifier`, `house_coords`, `house_radius_limit`, `doors`, `invlimit`, `tax_amount`, `tpInt`, `tpInstance`, `uniqueName`) VALUES (@charidentifier, @house_coords, @house_radius_limit, @doors, @invlimit, @tax_amount, @tpInt, @tpInstance, @uniqueName)",
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
                        Character.removeCurrency(0, house.price)

                        -- Notify the player that the house was purchased
                        TriggerClientEvent('bcc-housing:housePurchased', src, houseCoords)
                        VORPcore.NotifyAvanced(src, _U("housePurchaseSuccess", house.name, house.price), "inventory_items", "money_billstack", "COLOR_GREEN", 4000)
                        
                        -- Send a message to Discord
                        Discord:sendMessage("House purchased by charIdentifier: " .. tostring(Character.charIdentifier) .. "\nHouse: " .. house.name .. " was purchased for $" .. tostring(house.price) .. "\nCharacter Name: " .. Character.firstname .. " " .. Character.lastname)
							
                        -- Trigger the client-side to reload the house data
                        TriggerClientEvent('bcc-housing:ClientRecHouseLoad', src)
                    else
                        -- Notify the player if the house has already been purchased
                        VORPcore.NotifyAvanced(src, _U("housePurchaseFailed"), "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)
                    end
                end)
            else
                -- Notify the player if they do not have enough money
                VORPcore.NotifyAvanced(src, _U('notEnoughMoney'), "generic_textures", "tick", "COLOR_RED", 4000)
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

            -- Insert door into the `doorlocks` table
            MySQL.Async.insert(
                "INSERT INTO `doorlocks` (`doorinfo`, `jobsallowedtoopen`, `keyitem`, `locked`, `ids_allowed`) VALUES (?, ?, ?, ?, ?)",
                { doorinfo, jobsAllowed, keyItem, locked, idsAllowed }, function(doorId)
                    -- Debug: print the values to be inserted
                    devPrint("Door inserted with ID:", doorId)
                    table.insert(doorIds, doorId)

                    -- Once all doors are inserted, update the house with the door IDs
                    if #doorIds == #houseConfig.doors then
                        local doorIdsJson = json.encode(doorIds)
                        MySQL.Async.execute("UPDATE bcchousing SET doors = ? WHERE houseid = ?", { doorIdsJson, houseId },
                            function(affectedRows)
                                if affectedRows > 0 then
                                    devPrint("Updated house with door IDs:", doorIdsJson)
                                else
                                    devPrint("Failed to update house with door IDs.")
                                end
                            end)
                    end
                end
            )
        end
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
