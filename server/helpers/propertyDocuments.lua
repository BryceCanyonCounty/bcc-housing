local function getCharacterName(character)
    if not character then return _U("propertyUnknown") end

    local firstName = character.firstname or ""
    local lastName = character.lastname or ""
    local fullName = (firstName .. " " .. lastName):gsub("^%s+", ""):gsub("%s+$", "")

    return fullName ~= "" and fullName or _U("propertyUnknown")
end

local function getHouseDocumentConfig()
    local cfg = Config.PropertyDocuments or {}

    return {
        enabled = cfg.enabled ~= false,
        item = cfg.houseItem or "property_deed",
        removePreviousDeedOnTransfer = cfg.removePreviousDeedOnTransfer ~= false
    }
end

local function buildHouseDeedMetadata(character, houseConfig, houseId, ownershipStatus)
    local houseName = (houseConfig and houseConfig.name) or
        (houseConfig and houseConfig.uniqueName) or
        _U("propertyHouseNumber", tostring(houseId))
    local ownerName = getCharacterName(character)
    local statusText = ownershipStatus == "rented" and _U("propertyRental") or _U("propertyOwnership")
    local unknownText = _U("propertyUnknown")

    return {
        label = statusText .. " - " .. houseName,
        description = table.concat({
            _U("propertyDeedType") .. statusText,
            _U("propertyDeedProperty") .. houseName,
            _U("propertyDeedOwner") .. ownerName,
            _U("propertyDeedCid") .. tostring(character and character.charIdentifier or unknownText),
            _U("propertyDeedHouseId") .. tostring(houseId or unknownText),
            _U("propertyDeedIssuedAt") .. os.date("%Y-%m-%d %H:%M:%S")
        }, "<br>"),
        documentType = "property_deed",
        propertyType = "house",
        propertyName = houseName,
        propertyId = tostring(houseId or ""),
        uniqueName = tostring(houseConfig and houseConfig.uniqueName or ""),
        ownerName = ownerName,
        ownerCharIdentifier = tostring(character and character.charIdentifier or ""),
        ownershipStatus = tostring(ownershipStatus or "purchased"),
        issuedAt = os.date("%Y-%m-%d %H:%M:%S")
    }
end

local function findHouseConfigByUniqueName(uniqueName)
    for _, house in pairs(Houses or {}) do
        if house.uniqueName == uniqueName then
            return house
        end
    end
    return nil
end

function GiveHousePropertyDocument(source, character, houseConfig, houseId, ownershipStatus, cb)
    local cbFn = type(cb) == "function" and cb or nil
    local cfg = getHouseDocumentConfig()
    if not cfg.enabled or not houseId or not character then
        if cbFn then cbFn(false, "invalid_document") end
        return
    end

    local metadata = buildHouseDeedMetadata(character, houseConfig, houseId, ownershipStatus)

    if not source then
        MySQL.update('UPDATE bcchousing SET property_deed = ? WHERE houseid = ?', { json.encode(metadata), houseId })
        if cbFn then cbFn(true, metadata) end
        return
    end

    local canCarry = exports.vorp_inventory:canCarryItem(source, cfg.item, 1)
    if canCarry == false then
        NotifyClient(source, _U("propertyDeedInventoryFull"), 4000, "error")
        if cbFn then cbFn(false, "inventory_full") end
        return
    end

    exports.vorp_inventory:addItem(source, cfg.item, 1, metadata, function(success)
        if success == false then
            NotifyClient(source, _U("propertyDeedIssueFailed"), 4000, "error")
            if cbFn then cbFn(false, "add_item_failed") end
            return
        end

        MySQL.update('UPDATE bcchousing SET property_deed = ? WHERE houseid = ?', { json.encode(metadata), houseId })
        if cbFn then cbFn(true, metadata) end
    end)
end

function RemoveHousePropertyDocument(source, houseId)
    local cfg = getHouseDocumentConfig()
    if not cfg.enabled or not cfg.removePreviousDeedOnTransfer or not source or not houseId then return end

    exports.vorp_inventory:getItemContainingMetadata(source, cfg.item, {
        documentType = "property_deed",
        propertyType = "house",
        propertyId = tostring(houseId)
    }, function(item)
        if item and item.id then
            exports.vorp_inventory:subItemById(source, item.id, nil, nil, 1)
        end
    end)
end

BccUtils.RPC:Register("bcc-housing:GetOwnedPropertyDocuments", function(_, cb, src)
    local user = VORPcore.getUser(src)
    local character = user and user.getUsedCharacter
    if not character then
        cb(false, { error = "no_character" })
        return
    end

    local rows = MySQL.query.await([[
        SELECT houseid, uniqueName, ownershipStatus, property_deed
        FROM bcchousing
        WHERE charidentifier = ?
        ORDER BY houseid DESC
    ]], { character.charIdentifier }) or {}

    local items = {}
    for _, row in ipairs(rows) do
        local houseConfig = findHouseConfigByUniqueName(row.uniqueName)
        items[#items + 1] = {
            houseId = row.houseid,
            name = (houseConfig and houseConfig.name) or row.uniqueName or _U("propertyHouseNumber", tostring(row.houseid)),
            ownershipStatus = row.ownershipStatus,
            hasDocument = row.property_deed ~= nil and row.property_deed ~= ""
        }
    end

    cb(true, items)
end)

BccUtils.RPC:Register("bcc-housing:IssuePropertyDocument", function(params, cb, src)
    local houseId = tonumber(params and params.houseId)
    if not houseId then
        cb(false, { error = "invalid_house" })
        return
    end

    local user = VORPcore.getUser(src)
    local character = user and user.getUsedCharacter
    if not character then
        cb(false, { error = "no_character" })
        return
    end

    local rows = MySQL.query.await([[
        SELECT houseid, charidentifier, uniqueName, ownershipStatus
        FROM bcchousing
        WHERE houseid = ? AND charidentifier = ?
        LIMIT 1
    ]], { houseId, character.charIdentifier }) or {}

    local house = rows[1]
    if not house then
        NotifyClient(src, _U("propertyNotOwned"), 4000, "error")
        cb(false)
        return
    end

    local houseConfig = findHouseConfigByUniqueName(house.uniqueName) or {
        name = house.uniqueName,
        uniqueName = house.uniqueName
    }

    GiveHousePropertyDocument(src, character, houseConfig, house.houseid, house.ownershipStatus, function(success, result)
        if success then
            NotifyClient(src, _U("propertyDeedIssued"), 4000, "success")
            cb(true, { houseId = house.houseid })
        else
            cb(false)
        end
    end)
end)
