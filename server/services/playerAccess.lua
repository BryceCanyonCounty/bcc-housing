BccUtils.RPC:Register("bcc-housing:GetPlayersWithAccess", function(params, cb, recSource)
    local houseId = params.houseId
    devPrint("Fetching players with access for House ID: " .. tostring(houseId))

    -- Query to fetch allowed character IDs for the house
    local result = MySQL.query.await("SELECT allowed_ids FROM bcchousing WHERE houseid = ?", { houseId })

    if result and #result > 0 then
        local allowedIds = json.decode(result[1].allowed_ids)
        if allowedIds and #allowedIds > 0 then
            -- Convert the allowed IDs list into placeholders
            local placeholders = string.rep('?,', #allowedIds):sub(1, -2) -- e.g., "?,?"
            local query = "SELECT * FROM characters WHERE charidentifier IN (" .. placeholders .. ")"

            -- Fetch detailed character information
            local characterDetails = MySQL.query.await(query, allowedIds)
            if characterDetails and #characterDetails > 0 then
                for _, character in ipairs(characterDetails) do
                    devPrint("Character found: ID=" ..
                        character.charidentifier .. ", Name=" .. character.firstname .. " " .. character.lastname)
                end
                cb(characterDetails) -- Pass the character details back to the client
            else
                devPrint("No character details found for the allowed IDs.")
                cb({})
            end
        else
            devPrint("No allowed IDs found for House ID: " .. tostring(houseId))
            cb({})
        end
    else
        devPrint("No players found with access to house ID: " .. tostring(houseId))
        cb({})
    end
end)

RegisterServerEvent('bcc-housing:NewPlayerGivenAccess')
AddEventHandler('bcc-housing:NewPlayerGivenAccess', function(id, houseid, recSource)
    devPrint("NewPlayerGivenAccess event triggered with ID: " .. tostring(id) ..
        ", HouseID: " .. tostring(houseid) .. ", RecSource: " .. tostring(recSource)
    )
    local _source = source

    local param = {
        ['@houseid'] = houseid
    }
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

    local houseMaxResident
    for _, h in pairs(Config.HousesForSale) do
        if h.uniqueName == houseData.uniqueName then
            houseMaxResident = h.playerMax
            devPrint("Matching house configuration found, House has a " .. houseMaxResident .. " person limit.")
            break
        end
    end

    if not houseMaxResident or houseMaxResident <= #idsTable then
        devPrint("Resident limit exceeded: " .. #idsTable)
        VORPcore.NotifyRightTip(recSource, _U("notEnoughRoommateSlots"), 4000)
        VORPcore.NotifyRightTip(_source, _U("notEnoughRoommateSlots"), 4000)
        return
    end


    if not exists then
        table.insert(idsTable, id)
        local encodedIds = json.encode(idsTable)
        MySQL.update("UPDATE bcchousing SET allowed_ids = ? WHERE houseid = ?", { encodedIds, houseid },
            function(affectedRows)
                if affectedRows > 0 then
                    devPrint("Access list updated successfully for houseid: " .. tostring(houseid))
                    TriggerClientEvent('bcc-housing:ClientRecHouseLoad', recSource)
                else
                    devPrint("Update failed for houseid: " .. tostring(houseid))
                    if recSource then
                        VORPcore.NotifyRightTip(recSource, _U("giveAccesFailed"), 4000)
                    end
                end
            end
        )
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

RegisterServerEvent('bcc-housing:RemovePlayerAccess')
AddEventHandler('bcc-housing:RemovePlayerAccess', function(houseId, playerId)
    local src = source
    devPrint("Starting removal of player access. House ID: " ..
        tostring(houseId) .. ", Player ID: " .. tostring(playerId))

    -- Query to get the current list of allowed IDs for the house
    MySQL.query("SELECT allowed_ids FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId },
        function(result)
            if result and #result > 0 then
                local allowedIds = json.decode(result[1].allowed_ids) or {}
                devPrint("Current allowed IDs: " .. json.encode(allowedIds))

                -- Searching and removing the player ID from the allowed IDs list
                local found = false
                for i, id in ipairs(allowedIds) do
                    if id == playerId then
                        table.remove(allowedIds, i)
                        found = true
                        devPrint("Found and removed player ID from allowed list. Updated list: " ..
                            json.encode(allowedIds))
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
                        TriggerClientEvent('bcc-housing:ClientRecHouseLoad', src)
                        VORPcore.NotifyRightTip(src, _U("removeAccessTo") .. tostring(playerId))
                    else
                        devPrint("Failed to update database with new allowed IDs list.")
                        VORPcore.NotifyRightTip(src, _U("updateFailed"), 4000)
                    end
                end)
            else
                devPrint("No house found with ID: " .. tostring(houseId) .. " or allowed_ids is empty.")
                VORPcore.NotifyRightTip(src, _U("noSuchHouseId"), 4000)
            end
        end)
end)
