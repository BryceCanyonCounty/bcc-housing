-- Event to handle the selling of a house
RegisterServerEvent('bcc-housing:sellHouse')
AddEventHandler('bcc-housing:sellHouse', function(houseId)
    local src = source                              -- Get the source of the event
    local User = VORPcore.getUser(src)              -- Get the user object for the player
    local Character = User.getUsedCharacter         -- Get the character object for the player
    local charIdentifier = Character.charIdentifier -- Get the character identifier

    devPrint("Sell house event triggered for houseId: " ..
    tostring(houseId) .. " by player with charIdentifier: " .. tostring(charIdentifier))

    -- Query the database to find the house based on houseId
    MySQL.query('SELECT * FROM bcchousing WHERE houseid = ?', { houseId }, function(result)
        if result and #result > 0 then
            local houseData = result[1] -- Get the house data from the query result
            devPrint("House found in database: " .. json.encode(houseData))

            -- Check if the player is the owner of the house
            if houseData.charidentifier == tostring(charIdentifier) then
                devPrint("Player is the owner of the house with houseId: " .. tostring(houseId))

                -- Find the corresponding house configuration
                local houseConfig = nil
                for _, h in pairs(Config.HousesForSale) do
                    if h.houseCoords == json.decode(houseData.house_coords) then
                        houseConfig = h
                        devPrint("Matching house configuration found: " .. json.encode(houseConfig))
                        break
                    end
                end

                -- Set the sell price based on the house configuration
                local sellPrice = Config.DefaultSellPrice -- Use the value from Config
                if houseConfig and houseConfig.canSell then
                    sellPrice = houseConfig.sellPrice or 50000
                end
                devPrint("Sell price set to: $" .. tostring(sellPrice))

                -- Remove the house from the database
                MySQL.update('DELETE FROM bcchousing WHERE houseid = ?', { houseData.houseid })
                devPrint("House deleted from database with houseId: " .. tostring(houseData.houseid))

                -- Insert the transaction into the `bcchousing_transactions` table
                local params = {
                    ['@houseid'] = houseData.houseid,
                    ['@identifier'] = charIdentifier,
                    ['@amount'] = sellPrice
                }
                MySQL.insert(
                'INSERT INTO bcchousing_transactions (houseid, identifier, amount) VALUES (@houseid, @identifier, @amount)',
                    params)
                devPrint("House sale transaction inserted into `bcchousing_transactions` table: " .. json.encode(params))

                -- Notify the player that the house was sold
                VORPcore.NotifyAvanced(src, "Successfully sold for $" .. sellPrice, "inventory_items", "money_billstack",
                    "COLOR_GREEN", 4000)
                devPrint("Player notified of successful house sale.")

                -- Send a message to Discord
                Discord:sendMessage("House sold by charIdentifier: " ..
                tostring(charIdentifier) ..
                "\nHouse ID: " .. tostring(houseId) .. " was sold for $" .. tostring(sellPrice))

                -- Trigger the client-side prompt for collecting money
                if houseConfig then
                    TriggerClientEvent('bcc-housing:showCollectMoneyPrompt', src, houseConfig.menuCoords.x,
                        houseConfig.menuCoords.y, houseConfig.menuCoords.z, houseId, sellPrice)
                end

                -- Trigger the client-side handler to update the UI or perform other actions
                TriggerClientEvent('bcc-housing:OwnsHouseClientHandler', src, houseData, false) -- false indicates the house is no longer owned

                -- Stop the property check on the client side
                TriggerClientEvent('bcc-housing:StopPropertyCheck', src)

                -- Clear the blips for the sold house
                TriggerClientEvent('bcc-housing:clearBlips', src, houseId)

                -- Reinitialize checks if necessary
                TriggerClientEvent('bcc-housing:ReinitializeChecksAfterSale', src)
            else
                -- Notify the player if they are not the owner of the house
                devPrint("Player is not the owner of the house with houseId: " .. tostring(houseId))
                VORPcore.NotifyAvanced(src, "You do not own this house.", "generic_textures", "cross", "COLOR_RED", 4000)
            end
        else
            -- Notify the player if no house was found
            devPrint("No house found in database for houseId: " .. tostring(houseId))
            VORPcore.NotifyAvanced(src, "House not found.", "generic_textures", "cross", "COLOR_RED", 4000)
        end
    end)
end)

-- Sell House With Inventory
RegisterServerEvent('bcc-housing:sellHouseToPlayerWithInventory')
AddEventHandler('bcc-housing:sellHouseToPlayerWithInventory', function(houseId, targetPlayerId, salePrice)
    local src = source
    local User = VORPcore.getUser(src)
    local Character = User.getUsedCharacter
    local charIdentifier = Character.charIdentifier

    local TargetUser = VORPcore.getUser(targetPlayerId)
    local TargetCharacter = TargetUser.getUsedCharacter
    local targetCharIdentifier = TargetCharacter.charIdentifier

    -- Validate that the houseId is provided
    if not houseId then
        VORPcore.NotifyAvanced(src, "Invalid house ID.", "generic_textures", "cross", "COLOR_RED", 4000)
        return
    end

    -- Check if the house exists and is owned by the player
    MySQL.query('SELECT * FROM bcchousing WHERE houseid = ? AND charidentifier = ?', { houseId, charIdentifier },
        function(result)
            if result and #result > 0 then
                local houseData = result[1]

                -- Check if the buyer has enough money
                if TargetCharacter.money >= salePrice then
                    -- Deduct the money from the buyer
                    TargetCharacter.removeCurrency(0, salePrice)

                    -- Update the house owner in the database
                    MySQL.update('UPDATE bcchousing SET charidentifier = ? WHERE houseid = ?',
                        { targetCharIdentifier, houseId })

                    -- Insert the transaction into the `bcc-transactions` table
                    local params = {
                        ['@houseid'] = houseId,
                        ['@identifier'] = targetCharIdentifier,
                        ['@amount'] = salePrice
                    }
                    MySQL.insert(
                    'INSERT INTO bcc_transactions (houseid, identifier, amount) VALUES (@houseid, @identifier, @amount)',
                        params)

                    -- Notify both players
                    VORPcore.NotifyAvanced(src, "Successfully sold the house for $" .. salePrice, "inventory_items",
                        "money_billstack", "tick", "COLOR_green", 4000)
                    VORPcore.NotifyAvanced(targetPlayerId, "Successfully purchased the house for $" .. salePrice,
                        "inventory_items", "money_billstack", "COLOR_GREEN", 4000)

                    -- Notify other clients about the change
                    TriggerClientEvent('bcc-housing:ClientRecHouseLoad', targetPlayerId)
                    TriggerClientEvent('bcc-housing:ClientRecHouseLoad', src)

                    -- Optionally, send a message to Discord
                    Discord:sendMessage("House ID: " ..
                    tostring(houseId) ..
                    " was sold with inventory by charIdentifier: " ..
                    tostring(charIdentifier) ..
                    " to charIdentifier: " .. tostring(targetCharIdentifier) .. " for $" .. tostring(salePrice))
                else
                    -- Notify the seller that the buyer does not have enough money
                    VORPcore.NotifyAvanced(src, "The buyer does not have enough money.", "inventory_items",
                        "money_billstack", "COLOR_RED", 4000)
                    VORPcore.NotifyAvanced(targetPlayerId, "You do not have enough money", "inventory_items",
                        "money_billstack", "COLOR_red", 4000)
                end
            else
                -- Notify the player if they do not own the house or the house does not exist
                VORPcore.NotifyAvanced(src, "You do not own this house or the house does not exist.", "generic_textures",
                    "cross", "COLOR_red", 4000)
            end
        end)
end)

-- Sell House Without Inventory
RegisterServerEvent('bcc-housing:sellHouseToPlayerWithoutInventory')
AddEventHandler('bcc-housing:sellHouseToPlayerWithoutInventory', function(houseId, targetPlayerId, salePrice)
    local src = source
    local User = VORPcore.getUser(src)
    local Character = User.getUsedCharacter
    local charIdentifier = Character.charIdentifier

    local TargetUser = VORPcore.getUser(targetPlayerId)
    local TargetCharacter = TargetUser.getUsedCharacter
    local targetCharIdentifier = TargetCharacter.charIdentifier

    -- Validate that the houseId is provided
    if not houseId then
        VORPcore.NotifyAvanced(src, "Invalid house ID.", "generic_textures", "cross", "COLOR_PURE_WHITE", 4000)
        return
    end

    -- Check if the house exists and is owned by the player
    MySQL.query('SELECT * FROM bcchousing WHERE houseid = ? AND charidentifier = ?', { houseId, charIdentifier },
        function(result)
            if result and #result > 0 then
                local houseData = result[1]

                -- Check if the buyer has enough money
                if TargetCharacter.money >= salePrice then
                    -- Deduct the money from the buyer
                    TargetCharacter.removeCurrency(0, salePrice)

                    -- Update the house owner in the database and remove inventory data
                    MySQL.update(
                    'UPDATE bcchousing SET charidentifier = ?, furniture = NULL, doors = NULL WHERE houseid = ?',
                        { targetCharIdentifier, houseId })

                    -- Insert the transaction into the `bcc-transactions` table
                    local params = {
                        ['@houseid'] = houseId,
                        ['@identifier'] = targetCharIdentifier,
                        ['@amount'] = salePrice
                    }
                    MySQL.insert(
                    'INSERT INTO bcc_transactions (houseid, identifier, amount) VALUES (@houseid, @identifier, @amount)',
                        params)

                    -- Notify both players
                    VORPcore.NotifyAvanced(src,
                        "You have successfully sold the house without inventory for $" .. salePrice, "generic_textures",
                        "tick", "COLOR_PURE_WHITE", 4000)
                    VORPcore.NotifyAvanced(targetPlayerId,
                        "You have successfully purchased the house without inventory for $" .. salePrice,
                        "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)

                    -- Notify other clients about the change
                    TriggerClientEvent('bcc-housing:ClientRecHouseLoad', targetPlayerId)
                    TriggerClientEvent('bcc-housing:ClientRecHouseLoad', src)

                    -- Optionally, send a message to Discord
                    Discord:sendMessage("House ID: " ..
                    tostring(houseId) ..
                    " was sold without inventory by charIdentifier: " ..
                    tostring(charIdentifier) ..
                    " to charIdentifier: " .. tostring(targetCharIdentifier) .. " for $" .. tostring(salePrice))
                else
                    -- Notify the seller that the buyer does not have enough money
                    VORPcore.NotifyAvanced(src, "The buyer does not have enough money.", "generic_textures", "cross",
                        "COLOR_PURE_WHITE", 4000)
                    VORPcore.NotifyAvanced(targetPlayerId, "No Money",
                        "You do not have enough money to purchase this house.", "generic_textures", "cross",
                        "COLOR_PURE_WHITE", 4000)
                end
            else
                -- Notify the player if they do not own the house or the house does not exist
                VORPcore.NotifyAvanced(src, "You do not own this house or the house does not exist.", "generic_textures",
                    "cross", "COLOR_PURE_WHITE", 4000)
            end
        end)
end)

-- Event to request the list of houses sold by a player
RegisterServerEvent('bcc-housing:requestSoldHouses')
AddEventHandler('bcc-housing:requestSoldHouses', function()
    local src = source                              -- Get the source of the event
    local User = VORPcore.getUser(src)              -- Get the user object for the player
    local Character = User.getUsedCharacter         -- Get the character object for the player
    local charIdentifier = Character.charIdentifier -- Get the character identifier

    -- Query the database to get the list of houses sold by this player
    MySQL.query('SELECT * FROM bcchousing_transactions WHERE identifier = @identifier',
        { ['@identifier'] = charIdentifier }, function(results)
        local soldHouses = {}

        -- Loop through the results and add the house information to the soldHouses table
        if results and #results > 0 then
            for _, result in ipairs(results) do
                table.insert(soldHouses, {
                    houseId = result.houseid,
                    amount = result.amount
                })
            end
        end
        -- Send the list of sold houses to the client
        TriggerClientEvent('bcc-housing:receiveSoldHouses', src, soldHouses)
    end)
end)

-- Event to collect house sale money from an NPC
RegisterServerEvent('bcc-housing:collectHouseSaleMoneyFromNpc')
AddEventHandler('bcc-housing:collectHouseSaleMoneyFromNpc', function()
    local src = source                              -- Get the source of the event
    local User = VORPcore.getUser(src)              -- Get the user object for the player
    local Character = User.getUsedCharacter         -- Get the character object for the player
    local charIdentifier = Character.charIdentifier -- Get the character identifier

    -- Query the database to check if there's any money to collect from the sale
    MySQL.query('SELECT * FROM bcchousing_transactions WHERE identifier = @identifier',
        { ['@identifier'] = charIdentifier }, function(result)
        if result and #result > 0 then
            local totalAmount = 0

            -- Calculate the total amount of money to collect
            for _, transaction in ipairs(result) do
                totalAmount = totalAmount + transaction.amount
            end

            -- Add the money to the player's account
            Character.addCurrency(0, totalAmount)

            -- Delete the transactions from the database
            MySQL.update('DELETE FROM bcchousing_transactions WHERE identifier = @identifier',
                { ['@identifier'] = charIdentifier })

            -- Notify the player of the collected money
            VORPcore.NotifyAvanced(src, "You have collected $" .. totalAmount .. " from your house sales.",
                "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)

            -- Send a message to Discord
            Discord:sendMessage("House sale money collected by charIdentifier: " ..
            tostring(charIdentifier) .. "\nCollected $" .. tostring(totalAmount) .. " from house sales.")
        else
            -- Notify the player if there is no money to collect
            VORPcore.NotifyAvanced(src, "You have no money to collect.", "generic_textures", "cross", "COLOR_PURE_WHITE",
                4000)
        end
    end)
end)
