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
    devPrint("Storing furniture for deletion with entity ID: " ..
        tostring(entId) .. " for house ID: " .. tostring(houseid))

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
        Discord:sendMessage(_U("furnWebHookBought") ..
        tostring(character.charIdentifier) ..
        _U("furnWebHookBoughtModel") ..
        tostring(furnitureCreatedTable.model) .. _U("furnWebHookSoldPrice") .. tostring(cost))
    else
        VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
        TriggerClientEvent('bcc-housing:ClientFurnBoughtFail', _source)
    end
end)

RegisterServerEvent('bcc-housing:GetOwnerFurniture', function(houseId)
    devPrint("Getting owner furniture for house ID: " .. tostring(houseId))
    local param = { ['houseid'] = houseId }
    local _source = source
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)

    if result and #result > 0 then
        local houseData = result[1]
        local furnitureData = houseData.furniture

        -- Handle the case where furnitureData is "none"
        if furnitureData == "none" or furnitureData == nil or furnitureData == "" then
            VORPcore.NotifyRightTip(_source, _U("noFurn"), 4000)
            devPrint("No furniture found for house ID: " .. tostring(houseId))
            return
        end

        -- Attempt to decode the furniture data if it's not "none"
        local furniture, decodeErr = json.decode(furnitureData)
        if furniture then
            -- If the furniture table is empty, notify the player
            if #furniture == 0 then
                VORPcore.NotifyRightTip(_source, _U("noFurn"), 4000)
                devPrint("No furniture found for house ID: " .. tostring(houseId))
            else
                -- Log and trigger the event if furniture is found
                for i, item in ipairs(furniture) do
                    devPrint(string.format("Furniture Item %d: Model: %s, DisplayName: %s", i, item.model,
                        item.displayName))
                end
                devPrint("Triggering SellOwnedFurnMenu event for house ID: " ..
                    tostring(houseId) .. " with " .. tostring(#furniture) .. " items.")
                TriggerClientEvent('bcc-housing:SellOwnedFurnMenu', _source, houseId, furniture, houseData.ownershipStatus)
            end
        else
            -- Log the decoding error and notify the player
            devPrint("Error decoding furniture data: " ..
                tostring(decodeErr) .. ". Raw data: " .. tostring(furnitureData))
            VORPcore.NotifyRightTip(_source, "Error loading furniture data.", 4000)
        end
    else
        -- Notify the player if no house data was found
        VORPcore.NotifyRightTip(_source, _U("noFurn"), 4000)
        devPrint("No house data found for house ID: " .. tostring(houseId))
    end
end)

RegisterServerEvent('bcc-housing:FurnSoldRemoveFromTable',
    function(furnTable, houseId, wholeFurnTable, wholeFurnTableKey, ownershipStatus)
        local _source = source
        local character = VORPcore.getUser(_source).getUsedCharacter
        devPrint("Furniture sold, removing from table for house ID: " .. tostring(houseId))

        if ownershipStatus ~= 'purchased' then
            devPrint("ownershipStatus must be 'purchased' to allow selling.")
            return error()
        end

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
            MySQL.update("UPDATE bcchousing SET furniture=@newFurnTable WHERE houseid=@houseid", params,
                function(affectedRows)
                    if affectedRows > 0 then
                        VORPcore.NotifyRightTip(_source, _U("furnSold"), 4000)
                        character.addCurrency(0, tonumber(furnTable.sellprice))
                        Discord:sendMessage(_U("furnWebHookSold") .. character.charIdentifier .. _U("furnWebHookSoldModel") .. tostring(furnTable.model) .. _U("furnWebHookSoldPrice") .. tostring(furnTable.sellprice))
                    else
                        VORPcore.NotifyRightTip(_source, _U("furnNotSold"), 4000)
                    end
                end)
        else
            VORPcore.NotifyRightTip(_source, _U("furnNotSoldInvalid"), 4000)
        end

        TriggerClientEvent('bcc-housing:SellOwnedFurnMenu', _source, houseId, wholeFurnTable, ownershipStatus)
    end)
