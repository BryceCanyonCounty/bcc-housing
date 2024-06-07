---- House Creation DB Insert ----
RegisterServerEvent('bcc-housing:CreationDBInsert',
    function(tpHouse, owner, radius, doors, houseCoords, invLimit, ownerSource, taxAmount)
        local _source = source
        local taxes
        if tonumber(taxAmount) > 0 then
            taxes = tonumber(taxAmount)
        else
            taxes = 0
        end
        local character = VORPcore.getUser(_source).getUsedCharacter
        local param = nil
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
            exports.oxmysql:execute(
                "INSERT INTO bcchousing ( `charidentifier`,`house_radius_limit`,`doors`,`house_coords`,`invlimit`,`tax_amount`,`tpInt`,`tpInstance` ) VALUES ( @charidentifier,@radius,@doors,@houseCoords,@invlimit,@taxes,@tpInt,@tpInstance )",
                param)
            Discord:sendMessage(_U("houseCreatedWebhook") .. tostring(character.charIdentifier),
                _U("houseCreatedWebhookGivenToo") .. tostring(owner))
            Wait(1500)
            if ownerSource ~= nil then
                TriggerClientEvent('bcc-housing:ClientRecHouseLoad', ownerSource)
            end
        else
            VORPcore.NotifyRightTip(_source, _U("maxHousesReached"), 4000)
        end
    end)

---- Checking If player owns house, or has access to a house ----
RegisterServerEvent('bcc-housing:CheckIfHasHouse', function(passedSource)
    local _source
    if passedSource ~= nil then
        _source = tonumber(passedSource)
    else
        _source = source
    end
    local character = VORPcore.getUser(_source).getUsedCharacter

    ----- Owner Check -----
    exports.oxmysql:execute("SELECT * FROM bcchousing", function(result)
        if #result > 0 then
            for k, v in pairs(result) do
                -- VORPInv.removeInventory('Player_' .. v.houseid .. '_bcc-houseinv')
                -- Wait(50)
                VorpInv.registerInventory('Player_' .. v.houseid .. '_bcc-houseinv', _U("houseInv"),
                    tonumber(v.invlimit), true, true, true)
                if character.charIdentifier == tonumber(v.charidentifier) then
                    TriggerClientEvent('bcc-housing:OwnsHouseClientHandler', _source, v, true)
                else
                    local allowed_idsTable = json.decode(v.allowed_ids)
                    if allowed_idsTable then
                        for y, e in pairs(allowed_idsTable) do
                            if character.charIdentifier == tonumber(e) then
                                TriggerClientEvent('bcc-housing:OwnsHouseClientHandler', _source, v, false)
                            end
                        end
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent('bcc-housing:NewPlayerGivenAccess', function(id, houseid, recSource)
    local param = {
        ['newid'] = id,
        ['houseid'] = houseid
    }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)

    if #result >= 1 then
        local idsTable = result[1].allowed_ids == 'none' and {} or json.decode(result[1].allowed_ids)
        local exists = false

        for _, v in ipairs(idsTable) do
            if id == v then
                exists = true
                break
            end
        end

        if not exists then
            table.insert(idsTable, id)
            local param2 = {
                ['allowedids'] = json.encode(idsTable),
                ['houseid'] = houseid
            }
            exports.oxmysql:execute("UPDATE bcchousing SET allowed_ids=@allowedids WHERE houseid=@houseid", param2,
                function(affectedRows)
                    if recSource then
                        if affectedRows > 0 then
                            TriggerClientEvent('bcc-housing:ClientRecHouseLoad', recSource)
                        else
                            VORPcore.NotifyRightTip(_source, "Update failed, please try again.", 4000)
                        end
                    end
                end)
        end
    end

    -- Update door access
    if result and result[1] and result[1].doors then
        for _, doorId in ipairs(json.decode(result[1].doors) or {}) do
            updateDoorAccess(doorId, id)
        end
    end
end)

function updateDoorAccess(doorId, newId)
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
            exports.oxmysql:execute("UPDATE doorlocks SET ids_allowed=@ids_allowed WHERE doorid=@doorId", param)
        end
    end
end

RegisterServerEvent('bcc-house:OpenHouseInv', function(houseid) -- event to open the houses inventory
    local _source = source
    VorpInv.OpenInv(_source, 'Player_' .. houseid .. '_bcc-houseinv')
end)

RegisterServerEvent('bcc-housing:InsertFurnitureIntoDB', function(furnTable, houseId) -- Inserting new furniture into db
    local param = {
        ['houseid'] = houseId
    }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if result[1].furniture == 'none' then
        local param2 = {
            ['houseid'] = houseId,
            ['furn'] = json.encode({furnTable})
        } -- wrapping it in a table inside the json encode so it can be a proper table to be looped over
        exports.oxmysql:execute("UPDATE bcchousing SET furniture=@furn WHERE houseid=@houseid", param2)
    else
        -- add new table to old table
        local oldFurn = json.decode(result[1].furniture)
        table.insert(oldFurn, furnTable)
        local param2 = {
            ['houseid'] = houseId,
            ['furn'] = json.encode(oldFurn)
        }
        exports.oxmysql:execute("UPDATE bcchousing SET furniture=@furn WHERE houseid=@houseid", param2)
    end
end)

------ Keeping track of if the furniture is spawned for a house or note ----
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
                exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn=@source", param)
            end
        elseif tonumber(result[1].player_source_spawnedfurn) == _source then
            if deletion then
                DelSpawnedFurn(_source)
            end
        end
    end
end)

RegisterServerEvent('bcc-housing:StoreFurnForDeletion',
    function(entId, houseid) -- this is used to store the entity id of each piece of furniture in the table for when it is deleted
        local _source = source
        if storedFurn[_source] == nil then
            storedFurn[_source] = {}
            local param = {
                ['houseid'] = houseid,
                ['source'] = tostring(_source)
            }
            exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn=@source", param)
        end
        table.insert(storedFurn[_source], entId)
    end)

AddEventHandler('playerDropped', function() -- when you leave checks if you had furn spawned in and if so it deletes it
    DelSpawnedFurn(source)
end)

function DelSpawnedFurn(source) -- funct to del furniture if the source is the player who spawned the furniture
    local result = MySQL.query.await("SELECT * FROM bcchousing")
    local houseFurnDeleted = nil
    if #result > 0 then
        for k, v in pairs(result) do
            if source == tonumber(v.player_source_spawnedfurn) then -- compares the source listed in db to the players source and if they match then
                houseFurnDeleted = v
                if storedFurn[source] ~= nil then -- if the furniture stored is not nil then
                    for w, e in pairs(storedFurn[source]) do
                        local netEntId = NetworkGetEntityFromNetworkId(e)
                        if DoesEntityExist(netEntId) then -- Checking if the ent still exists that way if it has been deleted client it doesnt try and delete (safety check basically)
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
        exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn=@resetvar WHERE houseid=@houseid",
            param)
    end
end

RegisterServerEvent('bcc-housing:BuyFurn', function(cost, entId, furnitureCreatedTable)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    if character.money >= tonumber(cost) then
        character.removeCurrency(0, tonumber(cost))
        TriggerClientEvent('bcc-housing:ClientFurnBought', _source, furnitureCreatedTable, entId)
        Discord:sendMessage(_U("furnWebHookBought") .. tostring(character.charIdentifier),
            _U("furnWebHookBoughtModel") .. tostring(furnitureCreatedTable.model) .. _U("furnWebHookSoldPrice") ..
                tostring(cost))
    else
        VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
        TriggerClientEvent('bcc-housing:ClientFurnBoughtFail', _source)
    end
end)

RegisterServerEvent('bcc-housing:ServerSideRssStop',
    function() -- used to reset all houses spawn source to default incase someone restarts the script live to prevent errors
        exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn='none'")
    end)

RegisterServerEvent('bcc-housing:GetOwnerFurniture', function(houseId)
    local param = {
        ['houseid'] = houseId
    }
    local _source = source
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)

    if result and #result > 0 then
        local houseData = result[1]
        local furnitureData = houseData.furniture or '[]' -- Default to empty JSON array if nil

        -- Try to decode JSON safely
        local furniture, decodeErr = json.decode(furnitureData)
        if not decodeErr and furniture then
            if #furniture > 0 then
                TriggerClientEvent('bcc-housing:SellOwnedFurnMenu', _source, furniture)
            else
                VORPcore.NotifyRightTip(_source, _U("noFurn"), 4000)
            end
        else
            print("Error decoding furniture data: ", decodeErr)
            VORPcore.NotifyRightTip(_source, "Error loading furniture data.", 4000)
        end
    else
        VORPcore.NotifyRightTip(_source, _U("noFurn"), 4000)
    end
end)

RegisterServerEvent('bcc-housing:FurnSoldRemoveFromTable',
    function(furnTable, houseId, wholeFurnTable, wholeFurnTableKey)
        local _source = source
        local character = VORPcore.getUser(_source).getUsedCharacter()

        -- Ensure the furniture table key is valid before attempting to remove an entry
        if wholeFurnTable and tonumber(wholeFurnTableKey) and wholeFurnTable[tonumber(wholeFurnTableKey)] then
            table.remove(wholeFurnTable, tonumber(wholeFurnTableKey))
            local newDbTable = 'none' -- Default to 'none' if the table is empty after removal
            if #wholeFurnTable > 0 then
                newDbTable = json.encode(wholeFurnTable) -- Only encode if there's still data
            end

            local params = {
                ['houseid'] = houseId,
                ['newFurnTable'] = newDbTable
            }
            exports.oxmysql:execute("UPDATE bcchousing SET furniture=@newFurnTable WHERE houseid=@houseid", params,
                function(affectedRows)
                    if affectedRows > 0 then
                        -- Notify the user of a successful sale
                        VORPcore.NotifyRightTip(_source, _U("furnSold"), 4000)
                        -- Add the sell price to the user's currency
                        character.addCurrency(0, tonumber(furnTable.sellprice))
                        -- Optionally, send a Discord notification about the sale
                        Discord:sendMessage(_U("furnWebHookSold") .. character.charIdentifier,
                            _U("furnWebHookSoldModel") .. tostring(furnTable.model) .. _U("furnWebHookSoldPrice") ..
                                tostring(furnTable.sellprice))
                    else
                        -- Notify the user of a failure to update the database
                        VORPcore.NotifyRightTip(_source, _U("furnNotSold"), 4000)
                    end
                end)
        else
            -- Notify the user if the furniture key was invalid
            VORPcore.NotifyRightTip(_source, _U("furnNotSoldInvalid"), 4000)
        end

        -- Close all menus on the client side after the operation
        TriggerClientEvent('bcc-housing:ClientCloseAllMenus', _source)
    end)

RegisterServerEvent('bcc-housing:LedgerHandling')
AddEventHandler('bcc-housing:LedgerHandling', function(amountToInsert, houseid)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local amountToInsertNumber = tonumber(amountToInsert)
    local houseIdNumber = tonumber(houseid)

    if not amountToInsertNumber or not houseIdNumber then
        print("Invalid input data. Amount:", amountToInsert, "House ID:", houseid)
        return
    end

    MySQL.query("SELECT ledger, tax_amount FROM bcchousing WHERE houseid = ?", {houseIdNumber}, function(result)
        if result and #result > 0 then
            local ledger = tonumber(result[1].ledger)
            local tax_amount = tonumber(result[1].tax_amount)
            local maxInsertAmount = tax_amount - ledger

            -- Calculate the allowable insertion amount
            local insertionAmount = math.min(amountToInsertNumber, maxInsertAmount)

            if insertionAmount > 0 then
                if character.money >= insertionAmount then
                    character.removeCurrency(0, insertionAmount)
                    -- Update the ledger with the calculated insertion amount
                    MySQL.update("UPDATE bcchousing SET ledger = ledger + ? WHERE houseid = ?",
                        {insertionAmount, houseIdNumber}, function(affectedRows)
                            if affectedRows > 0 then
                                VORPcore.NotifyLeft(_source, _U("ledgerAmountInesrted") .. " $" .. insertionAmount, "",
                                    "inventory_items", "money_moneystack", 5000)
                            else
                                VORPcore.NotifyLeft(_source, _U("ledgerUpdateFailed"), "", "scoretimer_textures",
                                    "scoretimer_generic_cross", 5000)
                            end
                        end)
                else
                    VORPcore.NotifyLeft(_source, _U("noMoney"), "", "scoretimer_textures", "scoretimer_generic_cross",
                        5000)
                end
            else
                VORPcore.NotifyLeft(_source, "Maximum amount of money is already stored", "", "menu_textures",
                    "menu_icon_alert", 5000)
            end
        else
            VORPcore.NotifyLeft(_source, _U("noHouseFound"), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
        end
    end)
end)

RegisterServerEvent('bcc-housing:CheckLedger', function(houseid) -- check ledger handler
    local _source = source
    local param = {
        ['houseid'] = houseid
    }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if #result > 0 then
        VORPcore.NotifyLeft(_source, tostring(result[1].ledger) .. '/' .. tostring(result[1].tax_amount), "", "menu_textures", "menu_icon_alert", 5000)
    end
end)
