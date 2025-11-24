BccUtils.RPC:Register("bcc-housing:GetPlayersWithAccess", function(params, cb, recSource)
    local houseId = params.houseId
    DBG:Info("Fetching players with access for House ID: " .. tostring(houseId))

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
                    DBG:Info("Character found: ID=" ..
                        character.charidentifier .. ", Name=" .. character.firstname .. " " .. character.lastname)
                end
                cb(characterDetails) -- Pass the character details back to the client
            else
                DBG:Info("No character details found for the allowed IDs.")
                cb({})
            end
        else
            DBG:Info("No allowed IDs found for House ID: " .. tostring(houseId))
            cb({})
        end
    else
        DBG:Info("No players found with access to house ID: " .. tostring(houseId))
        cb({})
    end
end)

BccUtils.RPC:Register('bcc-housing:NewPlayerGivenAccess', function(params, cb, src)
    local id = params and params.charIdentifier
    local houseid = params and params.houseId
    local recSource = params and params.recSource

    if not id or not houseid then
        if cb then cb(false) end
        return
    end

    DBG:Info("NewPlayerGivenAccess event triggered with ID: " .. tostring(id) ..
        ", HouseID: " .. tostring(houseid) .. ", RecSource: " .. tostring(recSource)
    )
    local _source = src

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = ?", { houseid })

    if not result or #result == 0 then
        DBG:Error("Error: No results found for houseid: " .. tostring(houseid))
        NotifyClient(_source, _U("noSuchHouseId"), 4000, "error")
        if cb then cb(false) end
        return
    end

    local houseData = result[1]
    if not houseData then
        DBG:Error("Error: House data is nil for houseid: " .. tostring(houseid))
        NotifyClient(_source, _U("noSuchHouseId"), 4000, "error")
        if cb then cb(false) end
        return
    end

    local idsTable = {}
    if houseData.allowed_ids ~= 'none' and houseData.allowed_ids ~= nil then
        idsTable = json.decode(houseData.allowed_ids)
        if not idsTable then
            DBG:Error("Error: Failed to decode 'allowed_ids' for houseid: " .. tostring(houseid))
            if cb then cb(false) end
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
    DBG:Info("Exists check: " .. tostring(exists))

    local houseMaxResident
    for _, h in pairs(Houses) do
        if h.uniqueName == houseData.uniqueName then
            houseMaxResident = h.playerMax
            DBG:Info("Matching house configuration found, House has a " .. houseMaxResident .. " person limit.")
            break
        end
    end

    if not houseMaxResident or houseMaxResident <= #idsTable then
        DBG:Info("Resident limit exceeded: " .. #idsTable)
        NotifyClient(recSource, _U("notEnoughRoommateSlots"), 4000, "error")
        NotifyClient(_source, _U("notEnoughRoommateSlots"), 4000, "error")
        if cb then cb(false) end
        return
    end


    if not exists then
        table.insert(idsTable, id)
        local encodedIds = json.encode(idsTable)
        local affectedRows = MySQL.update.await("UPDATE bcchousing SET allowed_ids = ? WHERE houseid = ?", { encodedIds, houseid })
        if affectedRows > 0 then
            DBG:Info("Access list updated successfully for houseid: " .. tostring(houseid))
            if recSource then
                BccUtils.RPC:Notify('bcc-housing:ClientRecHouseLoad', {}, recSource)
            end
        else
            DBG:Info("Update failed for houseid: " .. tostring(houseid))
            if recSource then
                NotifyClient(recSource, _U("giveAccesFailed"), 4000, "error")
            end
            if cb then cb(false) end
            return
        end
    else
        DBG:Info("ID already exists in the access list for houseid: " .. tostring(houseid))
        if cb then cb(false) end
        return
    end

    if houseData.doors then
        local doors = json.decode(houseData.doors)
        if doors then
            for _, doorId in ipairs(doors) do
                DBG:Info("Updating door access for door ID: " .. tostring(doorId))
                updateDoorAccess(doorId, id)
            end
        else
            DBG:Error("Error: Failed to decode 'doors' for houseid: " .. tostring(houseid))
        end
    end
    if cb then cb(true) end
end)

BccUtils.RPC:Register('bcc-housing:RemovePlayerAccess', function(params, cb, src)
    local houseId = params and params.houseId
    local playerId = params and params.playerId
    if not houseId or not playerId then
        if cb then cb(false) end
        return
    end

    DBG:Info("Starting removal of player access. House ID: " ..
        tostring(houseId) .. ", Player ID: " .. tostring(playerId))

    local result = MySQL.query.await("SELECT allowed_ids FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        DBG:Info("No house found with ID: " .. tostring(houseId) .. " or allowed_ids is empty.")
        NotifyClient(src, _U("noSuchHouseId"), 4000, "error")
        if cb then cb(false) end
        return
    end

    local allowedIds = json.decode(result[1].allowed_ids) or {}
    DBG:Info("Current allowed IDs: " .. json.encode(allowedIds))

    local found = false
    for i, id in ipairs(allowedIds) do
        if id == playerId then
            table.remove(allowedIds, i)
            found = true
            DBG:Info("Found and removed player ID from allowed list. Updated list: " ..
                json.encode(allowedIds))
            break
        end
    end

    if not found then
        DBG:Info("Player ID not found in allowed list, nothing to remove.")
        NotifyClient(src, _U("updateFailed"), 4000, "error")
        if cb then cb(false) end
        return
    end

    local affectedRows = MySQL.update.await("UPDATE bcchousing SET allowed_ids = ? WHERE houseid = ?", {
        json.encode(allowedIds),
        houseId
    })

    if affectedRows and affectedRows > 0 then
        DBG:Info("Removed player access successfully for Player ID: " .. tostring(playerId))
        BccUtils.RPC:Notify('bcc-housing:ClientRecHouseLoad', {}, src)
        NotifyClient(src, _U("removeAccessTo") .. tostring(playerId), 4000, "success")
        if cb then cb(true) end
    else
        DBG:Error("Failed to update database with new allowed IDs list.")
        NotifyClient(src, _U("updateFailed"), 4000, "error")
        if cb then cb(false) end
    end
end)
