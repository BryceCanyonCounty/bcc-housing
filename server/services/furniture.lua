local function InsertFurnitureIntoDB(furnTable, houseId)
    DBG:Info("Inserting furniture into DB for house ID: " .. tostring(houseId))
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

local spawnedFurnitureByPlayer = {}

local function markHouseSpawnState(source, houseid, state)
    spawnedFurnitureByPlayer[source] = spawnedFurnitureByPlayer[source] or {}
    if state then
        spawnedFurnitureByPlayer[source][houseid] = true
        MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn=@src WHERE houseid=@houseid", {
            ['src'] = tostring(source),
            ['houseid'] = houseid
        })
    else
        spawnedFurnitureByPlayer[source][houseid] = nil
        if not next(spawnedFurnitureByPlayer[source]) then
            spawnedFurnitureByPlayer[source] = nil
        end
        MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn='none' WHERE houseid=@houseid", {
            ['houseid'] = houseid
        })
    end
end

BccUtils.RPC:Register("bcc-housing:FurniturePlacedCheck", function(params, cb, src)
    local houseid  = params and params.houseid
    local deletion = params and params.deletion
    local close    = params and params.close

    if not houseid then
        DBG:Info("bcc-housing: FurniturePlacedCheck missing houseid from src " .. tostring(src))
        return cb(false)
    end

    -- deletion branch
    if deletion then
        if spawnedFurnitureByPlayer[src] and spawnedFurnitureByPlayer[src][houseid] then
            markHouseSpawnState(src, houseid, false)
            BccUtils.RPC:Notify("bcc-housing:ClearFurnitureEvent", { houseid = houseid }, src)
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
        DBG:Error("Failed to decode furniture data for house ID " ..
        tostring(houseid) .. ": " .. tostring(decodedFurniture))
        return cb(false)
    end

    if type(decodedFurniture) ~= "table" or next(decodedFurniture) == nil then
        return cb(false)
    end

    if spawnedFurnitureByPlayer[src] and spawnedFurnitureByPlayer[src][houseid] then
        return cb(true) -- already spawned for this player/house
    end

    markHouseSpawnState(src, houseid, true)

    DBG:Info("Sending " ..
    tostring(#decodedFurniture) .. " furniture entries to player " .. tostring(src) .. " for house " .. tostring(houseid))

    -- Push the payload to the specific client via RPC Notify
    BccUtils.RPC:Notify("bcc-housing:SpawnFurnitureEvent", {
        furniture = decodedFurniture,
        houseid = houseid
    }, src)

    cb(true)
end)

function DelSpawnedFurn(source, houseid)
    if not spawnedFurnitureByPlayer[source] then return end

    local notifyClient = (BCCHousingResourceStopping ~= true)

    if houseid then
        markHouseSpawnState(source, houseid, false)
        if notifyClient then
            -- Tell the specific client to clear props for this house
            BccUtils.RPC:Notify("bcc-housing:ClearFurnitureEvent", { houseid = houseid }, source)
        end
        return
    end

    local hadEntries = false
    -- Clear all tracked houses for this player and notify to clear props
    for trackedHouseId in pairs(spawnedFurnitureByPlayer[source]) do
        hadEntries = true
        markHouseSpawnState(source, trackedHouseId, false)
    end
    if notifyClient and hadEntries then
        BccUtils.RPC:Notify("bcc-housing:ClearFurnitureEvent", {}, source)
    end
end

BccUtils.RPC:Register("bcc-housing:GetHouseFurnitureCount", function(params, cb, src)
    local houseId = params and params.houseId
    if not houseId then
        DBG:Info("GetHouseFurnitureCount called without houseId from src " .. tostring(src))
        return cb(false, "invalidHouseId")
    end

    local result = MySQL.query.await("SELECT furniture FROM bcchousing WHERE houseid=@houseid", { ['houseid'] = houseId })
    if not result or not result[1] then
        DBG:Info("GetHouseFurnitureCount found no data for house ID " .. tostring(houseId))
        return cb(true, 0)
    end

    local furnitureData = result[1].furniture
    if not furnitureData or furnitureData == '' or furnitureData == 'none' then
        return cb(true, 0)
    end

    local decodeOk, furnitureTable = pcall(json.decode, furnitureData)
    if not decodeOk or type(furnitureTable) ~= "table" then
        DBG:Error("GetHouseFurnitureCount failed to decode furniture data for house ID " ..
            tostring(houseId) .. ": " .. tostring(furnitureTable))
        return cb(false, "decodeError")
    end

    return cb(true, #furnitureTable)
end)

BccUtils.RPC:Register("bcc-housing:GetOwnerFurniture", function(params, cb, src)
    local houseId = params and params.houseId
    DBG:Info("Getting owner furniture for house ID: " .. tostring(houseId))
    if not houseId then
        local message = _U("invalidHouseId") or "Invalid house"
        NotifyClient(src, message, 4000, "error")
        return cb(false, message)
    end

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", { ['houseid'] = houseId })

    if not result or not result[1] then
        NotifyClient(src, _U("noFurn"), 4000, "info")
        DBG:Info("No house data found for house ID: " .. tostring(houseId))
        return cb(false, _U("noFurn"))
    end

    local houseData = result[1]
    local furnitureData = houseData.furniture

    if furnitureData == "none" or furnitureData == nil or furnitureData == "" then
        NotifyClient(src, _U("noFurn"), 4000, "info")
        DBG:Info("No furniture found for house ID: " .. tostring(houseId))
        return cb(false, _U("noFurn"))
    end

    local furniture, decodeErr = json.decode(furnitureData)
    if not furniture then
        DBG:Error("Error decoding furniture data: " .. tostring(decodeErr) .. ". Raw data: " .. tostring(furnitureData))
        NotifyClient(src, "Error loading furniture data.", 4000, "error")
        return cb(false, "Error loading furniture data.")
    end

    if #furniture == 0 then
        NotifyClient(src, _U("noFurn"), 4000, "info")
        DBG:Info("No furniture found for house ID: " .. tostring(houseId))
        return cb(false, _U("noFurn"))
    end

    for i, item in ipairs(furniture) do
        DBG:Info(string.format("Furniture Item %d: Model: %s, DisplayName: %s", i, item.model, item.displayName))
    end

    DBG:Info("Sending furniture data via RPC for house ID: " ..
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

    DBG:Info("Furniture sold, removing from table for house ID: " .. tostring(houseId))

    if not furnTable or not houseId or wholeFurnTable == nil or wholeFurnTableKey == nil then
        if cb then cb(false) end
        return
    end

    if ownershipStatus ~= 'purchased' then
        DBG:Info("ownershipStatus must be 'purchased' to allow selling.")
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
                    Discord:sendMessage(_U("furnWebHookSold") ..
                    character.charIdentifier ..
                    _U("furnWebHookSoldModel") ..
                    tostring(furnTable.model) .. _U("furnWebHookSoldPrice") .. tostring(furnTable.sellprice))
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
    local result = MySQL.query.await("SELECT items FROM bcchousing_ownedfurniture WHERE charidentifier=@charidentifier",
        {
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
    local updated = MySQL.update.await(
    "UPDATE bcchousing_ownedfurniture SET items=@items WHERE charidentifier=@charidentifier", params)
    if not updated or updated == 0 then
        MySQL.insert.await(
        "INSERT INTO bcchousing_ownedfurniture (charidentifier, items) VALUES (@charidentifier, @items)", params)
    end
end

local function generateFurnitureId()
    return tostring(os.time()) .. tostring(math.random(1000, 9999))
end

CreateThread(function()
    if not Furniture.MenuItem or Furniture.MenuItem == '' then
        return
    end
    exports.vorp_inventory:registerUsableItem(
        Furniture.MenuItem,
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

BccUtils.RPC:Register("bcc-housing:GiveFurnitureBook", function(_, cb, src)
    if not Furniture.MenuItem or Furniture.MenuItem == '' then
        DBG:Info("bcc-housing: Furniture.MenuItem not configured, cannot give book.")
        return cb(false, _U("furnitureBookUnavailable"))
    end

    local character = getCharacter(src)
    if not character then
        DBG:Info("bcc-housing: invalid character while giving furniture book for src " .. tostring(src))
        return cb(false, _U("unknownError"))
    end

    local hasItem = exports.vorp_inventory:getItem(src, Furniture.MenuItem)
    if hasItem then
        return cb(false, _U("alreadyHasFurnitureBook"))
    end

    local added = exports.vorp_inventory:addItem(src, Furniture.MenuItem, 1)
    if not added then
        DBG:Info("bcc-housing: vorp_inventory refused to add furniture book for src " .. tostring(src))
        return cb(false, _U("furnitureBookFailed"))
    end

    cb(true, _U("furnitureBookReceived"))
end)

BccUtils.RPC:Register("bcc-housing:RequestOwnedFurniture", function(params, cb, src)
    local character = getCharacter(src)
    if not character then
        DBG:Info("bcc-housing: invalid character for src " .. tostring(src))
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
        DBG:Info("bcc-housing: invalid character for src " .. tostring(src))
        return cb(false)
    end

    local furnCategory = Furniture[categoryIndex]
    local furnItem = furnCategory and furnCategory[itemIndex]
    if not furnItem then
        DBG:Info("bcc-housing: invalid furniture (" ..
        tostring(categoryIndex) .. ", " .. tostring(itemIndex) .. ") from " .. tostring(src))
        return cb(false)
    end

    local cost = tonumber(furnItem.costToBuy) or 0
    if cost <= 0 then
        DBG:Info("bcc-housing: invalid price for " .. tostring(furnItem.displayName) .. " (" .. tostring(cost) .. ")")
        return cb(false)
    end

    if character.money < cost then
        DBG:Info("bcc-housing: " ..
        tostring(src) ..
        " tried to buy " .. tostring(furnItem.displayName) .. " but lacks money (needs " .. tostring(cost) .. ")")
        return cb(false)
    end

    character.removeCurrency(0, cost)
    local ownedItems = loadOwnedFurniture(character.charIdentifier)
    local modelName = furnItem.propModel or furnItem.model
    if not modelName then
        DBG:Info("bcc-housing: furniture item missing model definition for " .. tostring(furnItem.displayName))
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
    local placementData = params and params.placementData

    local character     = getCharacter(src)
    if not character then
        DBG:Info("bcc-housing: invalid character for src " .. tostring(src))
        return cb(false)
    end

    if not ownedId or not placementData or not houseId then
        DBG:Info("bcc-housing: missing params for PlaceOwnedFurniture from src " .. tostring(src))
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
        DBG:Info("bcc-housing: owned furniture not found for src " .. tostring(src) .. " ownedId " .. tostring(ownedId))
        return cb(false)
    end

    if placementData.model ~= ownedEntry.model then
        DBG:Info("bcc-housing: model mismatch for src " ..
        tostring(src) ..
        " (owned " .. tostring(ownedEntry.model) .. ", provided " .. tostring(placementData.model) .. ")")
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
    DBG:Info("SellFurniture RPC invoked but not implemented; returning failure.")
    NotifyClient(src, _U('furnNotSold'), 4000, 'error')
    if cb then cb(false, { error = 'not_implemented' }) end
end)
