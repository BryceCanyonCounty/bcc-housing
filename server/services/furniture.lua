local function InsertFurnitureIntoDB(furnTable, houseId)
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
end

local storedFurn = {}
local spawnedFurnitureByPlayer = {}

local function resetHouseTrackingForPlayer(source, houseid)
    if storedFurn[source] then
        storedFurn[source][houseid] = nil
        if not next(storedFurn[source]) then
            storedFurn[source] = nil
        end
    end

    if spawnedFurnitureByPlayer[source] then
        spawnedFurnitureByPlayer[source][houseid] = nil
        if not next(spawnedFurnitureByPlayer[source]) then
            spawnedFurnitureByPlayer[source] = nil
        end
    end
end

local function deleteTrackedFurniture(source, houseid)
    if storedFurn[source] and storedFurn[source][houseid] then
        for _, netId in ipairs(storedFurn[source][houseid]) do
            local entity = NetworkGetEntityFromNetworkId(netId)
            if entity ~= 0 and DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
        devPrint(("Deleted %d spawned furniture entities for player %s at house %s"):format(#storedFurn[source][houseid], tostring(source), tostring(houseid)))
    end

    local param = {
        ['resetvar'] = 'none',
        ['houseid'] = houseid
    }
    MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn=@resetvar WHERE houseid=@houseid", param)

    resetHouseTrackingForPlayer(source, houseid)
end

BccUtils.RPC:Register("bcc-housing:FurniturePlacedCheck", function(params, cb, src)
    local houseid  = params and params.houseid
    local deletion = params and params.deletion
    local close    = params and params.close

    if not houseid then
        devPrint("bcc-housing: FurniturePlacedCheck missing houseid from src " .. tostring(src))
        return cb(false)
    end

    -- deletion branch
    if deletion then
        if spawnedFurnitureByPlayer[src] and spawnedFurnitureByPlayer[src][houseid] then
            deleteTrackedFurniture(src, houseid)
        end
        return cb(true)
    end

    if not close then
        return cb(false)
    end

    local param = { ['houseid'] = houseid }
    local result = MySQL.query.await("SELECT furniture FROM bcchousing WHERE houseid=@houseid", param)
    if not result or not result[1] then
        return cb(false)
    end

    local furnitureData = result[1].furniture
    if furnitureData == nil or furnitureData == '' or furnitureData == 'none' then
        return cb(false)
    end

    local decodeOk, decodedFurniture = pcall(json.decode, furnitureData)
    if not decodeOk then
        devPrint("Failed to decode furniture data for house ID " .. tostring(houseid) .. ": " .. tostring(decodedFurniture))
        return cb(false)
    end

    if type(decodedFurniture) ~= "table" or next(decodedFurniture) == nil then
        return cb(false)
    end

    storedFurn[src] = storedFurn[src] or {}
    if spawnedFurnitureByPlayer[src] and spawnedFurnitureByPlayer[src][houseid] then
        return cb(true) -- already spawned for this player/house
    end

    storedFurn[src][houseid] = {}
    spawnedFurnitureByPlayer[src] = spawnedFurnitureByPlayer[src] or {}
    spawnedFurnitureByPlayer[src][houseid] = true

    devPrint("Sending " .. tostring(#decodedFurniture) .. " furniture entries to player " .. tostring(src) .. " for house " .. tostring(houseid))

    -- Push the payload to the specific client via RPC Notify
    BccUtils.RPC:Notify("bcc-housing:SpawnFurnitureEvent", { furniture = decodedFurniture }, src)

    cb(true)
end)

BccUtils.RPC:Register("bcc-housing:StoreFurnForDeletion", function(params, cb, src)
    local entId = params and params.entId
    local houseid = params and params.houseid
    if not houseid or not entId then
        if cb then cb(false) end
        return
    end

    storedFurn[src] = storedFurn[src] or {}
    storedFurn[src][houseid] = storedFurn[src][houseid] or {}

    table.insert(storedFurn[src][houseid], entId)
    devPrint(("Tracking furniture entity %s for player %s at house %s"):format(tostring(entId), tostring(src), tostring(houseid)))
    if cb then cb(true) end
end)

function DelSpawnedFurn(source, houseid)
    if not storedFurn[source] then return end

    if houseid then
        devPrint(("Requested cleanup for player %s house %s"):format(tostring(source), tostring(houseid)))
        deleteTrackedFurniture(source, houseid)
        return
    end

    local trackedHouses = {}
    for trackedHouseId in pairs(storedFurn[source]) do
        trackedHouses[#trackedHouses + 1] = trackedHouseId
    end

    for _, trackedHouseId in ipairs(trackedHouses) do
        deleteTrackedFurniture(source, trackedHouseId)
    end

    devPrint(("Completed cleanup for player %s across %d houses"):format(tostring(source), #trackedHouses))
end

BccUtils.RPC:Register("bcc-housing:GetOwnerFurniture", function(params, cb, src)
    local houseId = params and params.houseId
    devPrint("Getting owner furniture for house ID: " .. tostring(houseId))
    if not houseId then
        local message = _U("invalidHouseId") or "Invalid house"
        NotifyClient(src, message, 4000, "error")
        return cb(false, message)
    end

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", { ['houseid'] = houseId })

    if not result or not result[1] then
        NotifyClient(src, _U("noFurn"), 4000, "info")
        devPrint("No house data found for house ID: " .. tostring(houseId))
        return cb(false, _U("noFurn"))
    end

    local houseData = result[1]
    local furnitureData = houseData.furniture

    if furnitureData == "none" or furnitureData == nil or furnitureData == "" then
        NotifyClient(src, _U("noFurn"), 4000, "info")
        devPrint("No furniture found for house ID: " .. tostring(houseId))
        return cb(false, _U("noFurn"))
    end

    local furniture, decodeErr = json.decode(furnitureData)
    if not furniture then
        devPrint("Error decoding furniture data: " .. tostring(decodeErr) .. ". Raw data: " .. tostring(furnitureData))
        NotifyClient(src, "Error loading furniture data.", 4000, "error")
        return cb(false, "Error loading furniture data.")
    end

    if #furniture == 0 then
        NotifyClient(src, _U("noFurn"), 4000, "info")
        devPrint("No furniture found for house ID: " .. tostring(houseId))
        return cb(false, _U("noFurn"))
    end

    for i, item in ipairs(furniture) do
        devPrint(string.format("Furniture Item %d: Model: %s, DisplayName: %s", i, item.model, item.displayName))
    end

    devPrint("Sending furniture data via RPC for house ID: " ..
        tostring(houseId) .. " with " .. tostring(#furniture) .. " items.")
    return cb(true, furniture, houseData.ownershipStatus)
end)

BccUtils.RPC:Register('bcc-housing:FurnSoldRemoveFromTable', function(params, cb, src)
    local furnTable = params and params.furnTable
    local houseId = params and params.houseId
    local wholeFurnTable = params and params.wholeFurnTable
    local wholeFurnTableKey = params and params.wholeFurnTableKey
    local ownershipStatus = params and params.ownershipStatus
    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false) end
        return
    end
    local character = user.getUsedCharacter

    devPrint("Furniture sold, removing from table for house ID: " .. tostring(houseId))

    if not furnTable or not houseId or wholeFurnTable == nil or wholeFurnTableKey == nil then
        if cb then cb(false) end
        return
    end

    if ownershipStatus ~= 'purchased' then
        devPrint("ownershipStatus must be 'purchased' to allow selling.")
        if cb then cb(false) end
        return
    end

    if wholeFurnTable and tonumber(wholeFurnTableKey) and wholeFurnTable[tonumber(wholeFurnTableKey)] then
        table.remove(wholeFurnTable, tonumber(wholeFurnTableKey))
        local newDbTable = 'none'
        if #wholeFurnTable > 0 then
            newDbTable = json.encode(wholeFurnTable)
        end

        local updateParams = {
            ['houseid'] = houseId,
            ['newFurnTable'] = newDbTable
        }
        MySQL.update("UPDATE bcchousing SET furniture=@newFurnTable WHERE houseid=@houseid", updateParams,
            function(affectedRows)
                if affectedRows > 0 then
                    NotifyClient(src, _U("furnSold"), 4000, "success")
                    character.addCurrency(0, tonumber(furnTable.sellprice))
                    Discord:sendMessage(_U("furnWebHookSold") .. character.charIdentifier .. _U("furnWebHookSoldModel") .. tostring(furnTable.model) .. _U("furnWebHookSoldPrice") .. tostring(furnTable.sellprice))
                else
                    NotifyClient(src, _U("furnNotSold"), 4000, "error")
                end
            end)
    else
        NotifyClient(src, _U("furnNotSoldInvalid"), 4000, "error")
        if cb then cb(false) end
        return
    end

    BccUtils.RPC:Notify("bcc-housing:SellOwnedFurnMenu", {
        houseId = houseId,
        furniture = wholeFurnTable,
        ownershipStatus = ownershipStatus
    }, src)

    if cb then cb(true) end
end)

local function getCharacter(source)
    local user = VORPcore.getUser(source)
    if not user then return nil end
    return user.getUsedCharacter
end

local function loadOwnedFurniture(charIdentifier)
    if not charIdentifier then return {} end
    local result = MySQL.query.await("SELECT items FROM bcchousing_ownedfurniture WHERE charidentifier=@charidentifier", {
        ['charidentifier'] = charIdentifier
    })

    if result and result[1] and result[1].items and result[1].items ~= '' then
        local ok, decoded = pcall(json.decode, result[1].items)
        if ok and type(decoded) == 'table' then
            return decoded
        end
    end

    return {}
end

local function saveOwnedFurniture(charIdentifier, items)
    if not charIdentifier then return end
    local encoded = json.encode(items or {})
    local params = {
        ['charidentifier'] = charIdentifier,
        ['items'] = encoded
    }
    local updated = MySQL.update.await("UPDATE bcchousing_ownedfurniture SET items=@items WHERE charidentifier=@charidentifier", params)
    if not updated or updated == 0 then
        MySQL.insert.await("INSERT INTO bcchousing_ownedfurniture (charidentifier, items) VALUES (@charidentifier, @items)", params)
    end
end

local function generateFurnitureId()
    return tostring(os.time()) .. tostring(math.random(1000, 9999))
end

CreateThread(function()
    if not Config.FurnitureMenuItem or Config.FurnitureMenuItem == '' then
        return
    end
    exports.vorp_inventory:registerUsableItem(
        Config.FurnitureMenuItem,
        function(data)
            local src = data.source
            local character = getCharacter(src)
            if not character then return end

            local ownedItems = loadOwnedFurniture(character.charIdentifier)
            BccUtils.RPC:Notify("bcc-housing:OpenFurnitureBook", { ownedFurniture = ownedItems }, src)
            exports.vorp_inventory:closeInventory(src)
        end,
        GetCurrentResourceName()
    )
end)

BccUtils.RPC:Register("bcc-housing:RequestOwnedFurniture", function(params, cb, src)
    local character = getCharacter(src)
    if not character then
        devPrint("bcc-housing: invalid character for src " .. tostring(src))
        return cb(false)
    end

    local ownedItems = loadOwnedFurniture(character.charIdentifier)
    BccUtils.RPC:Notify("bcc-housing:OwnedFurnitureSync", { ownedItems = ownedItems }, src)
    cb(true)
end)

BccUtils.RPC:Register("bcc-housing:PurchaseFurnitureItem", function(params, cb, src)
    local categoryIndex = tonumber(params.categoryIndex)
    local itemIndex = tonumber(params.itemIndex)

    local character = getCharacter(src)
    if not character then
        devPrint("bcc-housing: invalid character for src " .. tostring(src))
        return cb(false)
    end

    local furnCategory = Furniture[categoryIndex]
    local furnItem = furnCategory and furnCategory[itemIndex]
    if not furnItem then
        devPrint("bcc-housing: invalid furniture (" .. tostring(categoryIndex) .. ", " .. tostring(itemIndex) .. ") from " .. tostring(src))
        return cb(false)
    end

    local cost = tonumber(furnItem.costToBuy) or 0
    if cost <= 0 then
        devPrint("bcc-housing: invalid price for " .. tostring(furnItem.displayName) .. " (" .. tostring(cost) .. ")")
        return cb(false)
    end

    if character.money < cost then
        devPrint("bcc-housing: " .. tostring(src) .. " tried to buy " .. tostring(furnItem.displayName) .. " but lacks money (needs " .. tostring(cost) .. ")")
        return cb(false)
    end

    -- Charge player
    character.removeCurrency(0, cost)

    -- Save purchased furniture
    local ownedItems = loadOwnedFurniture(character.charIdentifier)
local modelName = furnItem.propModel or furnItem.model
    if not modelName then
        devPrint("bcc-housing: furniture item missing model definition for " .. tostring(furnItem.displayName))
        return cb(false)
    end

    local entry = {
        id          = generateFurnitureId(),
        model       = modelName,
        displayName = furnItem.displayName,
        sellprice   = furnItem.sellFor,
        category    = furnCategory.name or '',
        cost        = cost
    }

    table.insert(ownedItems, entry)
    saveOwnedFurniture(character.charIdentifier, ownedItems)

    BccUtils.RPC:Notify("bcc-housing:OwnedFurnitureSync", { ownedItems = ownedItems }, src) 
    -- Discord logging
    Discord:sendMessage(
        _U("furnWebHookBought")
        .. tostring(character.charIdentifier)
        .. _U("furnWebHookBoughtModel")
        .. tostring(modelName)
        .. _U("furnWebHookSoldPrice")
        .. tostring(cost)
    )

    cb(true)
end)

BccUtils.RPC:Register("bcc-housing:PlaceOwnedFurniture", function(params, cb, src)
    local ownedId       = params and params.ownedId
    local houseId       = params and params.houseId
    local entId         = params and params.entId
    local placementData = params and params.placementData

    local character = getCharacter(src)
    if not character then
        devPrint("bcc-housing: invalid character for src " .. tostring(src))
        return cb(false)
    end

    if not ownedId or not placementData or not houseId then
        devPrint("bcc-housing: missing params for PlaceOwnedFurniture from src " .. tostring(src))
        return cb(false)
    end

    local ownedItems = loadOwnedFurniture(character.charIdentifier)
    local ownedIndex, ownedEntry = nil, nil
    for idx, entry in ipairs(ownedItems) do
        if entry.id == ownedId then
            ownedIndex = idx
            ownedEntry = entry
            break
        end
    end

    if not ownedEntry then
        devPrint("bcc-housing: owned furniture not found for src " .. tostring(src) .. " ownedId " .. tostring(ownedId))
        return cb(false)
    end

    if placementData.model ~= ownedEntry.model then
        devPrint("bcc-housing: model mismatch for src " .. tostring(src) .. " (owned " .. tostring(ownedEntry.model) .. ", provided " .. tostring(placementData.model) .. ")")
        return cb(false)
    end

    table.remove(ownedItems, ownedIndex)
    saveOwnedFurniture(character.charIdentifier, ownedItems)

    placementData.displayName = placementData.displayName or ownedEntry.displayName
    placementData.sellprice   = placementData.sellprice or ownedEntry.sellprice

    InsertFurnitureIntoDB(placementData, houseId)

    BccUtils.RPC:Notify("bcc-housing:OwnedFurnitureSync", { ownedItems = ownedItems }, src)

    Discord:sendMessage(
        _U("furnWebHookPlaced")
        .. tostring(character.charIdentifier)
        .. _U("furnWebHookBoughtModel")
        .. tostring(placementData.model)
    )

    cb(true)
end)

BccUtils.RPC:Register('bcc-housing:SellFurniture', function(params, cb, src)
    devPrint("SellFurniture RPC invoked but not implemented; returning failure.")
    NotifyClient(src, _U('furnNotSold'), 4000, 'error')
    if cb then cb(false, { error = 'not_implemented' }) end
end)
