-- Event to handle the purchasing of a house
RegisterServerEvent('bcc-housing:buyHouse')
AddEventHandler('bcc-housing:buyHouse', function(houseCoords)
    local src = source                               -- Get the source of the event
    local User = VORPcore.getUser(src)               -- Get the user object for the player
    local Character = User.getUsedCharacter          -- Get the character object for the player
    local houseCoordsJson = json.encode(houseCoords) -- Encode the house coordinates for database comparison

    for _, house in pairs(Config.HousesForSale) do
        if #(house.houseCoords - houseCoords) < 0.1 then -- Check if the coordinates match
            if Character.money >= house.price then
                -- Check if the house already exists in the database by checking the coordinates
                MySQL.query('SELECT * FROM bcchousing WHERE house_coords = ?', { houseCoordsJson }, function(result)
                    if not result[1] then
                        -- Clear the blips for the house that is being purchased
                        TriggerClientEvent('bcc-housing:clearBlips', src, house.houseId)

                        -- House not found, proceed with the purchase
                        local parameters = {
                            ['@charidentifier'] = Character.charIdentifier,
                            ['@house_coords'] = houseCoordsJson,
                            ['@house_radius_limit'] = house.houseRadiusLimit,
                            ['@furniture'] = house.furniture,
                            ['@doors'] = house.doors,
                            ['@allowed_ids'] = house.allowedIds,
                            ['@invlimit'] = house.invLimit,
                            ['@player_source_spawnedfurn'] = house.playerSourceSpawnedFurn,
                            ['@taxes_collected'] = house.taxesCollected,
                            ['@ledger'] = house.ledger,
                            ['@tax_amount'] = house.taxAmount,
                            ['@tpInt'] = house.tpInt,
                            ['@tpInstance'] = house.tpInstance
                        }

                        -- Insert the new house into the database
                        MySQL.insert.await(
                            "INSERT INTO `bcchousing` (`charidentifier`, `house_coords`, `house_radius_limit`, `furniture`, `doors`, `allowed_ids`, `invlimit`, `player_source_spawnedfurn`, `taxes_collected`, `ledger`, `tax_amount`, `tpInt`, `tpInstance`) VALUES (@charidentifier, @house_coords, @house_radius_limit, @furniture, @doors, @allowed_ids, @invlimit, @player_source_spawnedfurn, @taxes_collected, @ledger, @tax_amount, @tpInt, @tpInstance)",
                            parameters, function(result) end)

                        -- Deduct the money from the player
                        Character.removeCurrency(0, house.price)

                        -- Notify the player that the house was purchased
                        TriggerClientEvent('bcc-housing:housePurchased', src, houseCoords)
                        VORPcore.NotifyAvanced(src, "You have successfully purchased for $" .. house.price, "inventory_items", "money_billstack", "COLOR_GREEN", 4000)

                        -- Send a message to Discord
                        Discord:sendMessage("House purchased by charIdentifier: " ..
                            tostring(Character.charIdentifier) ..
                            "\nHouse: " ..
                            house.name ..
                            " was purchased for $" ..
                            tostring(house.price) .. "\nCharacter Name: " .. Character.firstname .. " " .. Character
                            .lastname)

                        -- Trigger the client-side to reload the house data
                        TriggerClientEvent('bcc-housing:ClientRecHouseLoad', src)
                    else
                        -- Notify the player if the house has already been purchased
                        VORPcore.NotifyAvanced(src, "This house has already been purchased by another player.", "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)
                    end
                end)
            else
                -- Notify the player if they do not have enough money
                VORPcore.NotifyAvanced(src, "You do not have enough money to buy this house.", "generic_textures", "tick", "COLOR_RED", 4000)
            end
            break
        end
    end
end)

-- Event to retrieve all purchased houses
RegisterNetEvent('bcc-housing:getPurchasedHouses')
AddEventHandler('bcc-housing:getPurchasedHouses', function()
    local src = source         -- Get the source of the event
    local purchasedHouses = {} -- Initialize a table to hold purchased houses

    -- Query the database for all purchased houses
    MySQL.query('SELECT house_coords FROM bcchousing', {}, function(results)
        if #results > 0 then
            for _, house in ipairs(results) do
                local houseCoords = json.decode(house.house_coords)                                     -- Decode the house coordinates
                if houseCoords and type(houseCoords) == "table" then
                    table.insert(purchasedHouses, vector3(houseCoords.x, houseCoords.y, houseCoords.z)) -- Insert the coordinates into the table
                else
                    print("Error: house_coords is not a valid table or couldn't be decoded")
                end
            end
        end

        -- Send the list of purchased houses to the client
        TriggerClientEvent('bcc-housing:sendPurchasedHouses', src, purchasedHouses)
    end)
end)
