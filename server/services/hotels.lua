local function findHotelConfig(hotelId)
    local numericHotelId = tonumber(hotelId)
    if not numericHotelId then return nil end

    for _, hotel in pairs(Hotels or {}) do
        if tonumber(hotel.hotelId) == numericHotelId then
            return hotel
        end
    end

    return nil
end

local function loadOwnedHotels(charId)
    local result = MySQL.query.await('SELECT `hotels` FROM `bcchousinghotels` WHERE `charidentifier` = ?', { charId })
    local payload = result and result[1] and result[1].hotels
    if not payload or payload == '' or payload == 'none' then
        return {}
    end

    local ok, hotels = pcall(json.decode, payload)
    return ok and type(hotels) == 'table' and hotels or {}
end

local function ownsHotel(charId, hotelId)
    for _, ownedHotelId in ipairs(loadOwnedHotels(charId)) do
        if tonumber(ownedHotelId) == tonumber(hotelId) then
            return true
        end
    end
    return false
end

BccUtils.RPC:Register('bcc-housing:HotelDbRegistry', function(params, cb, src)
    local user = VORPcore.getUser(src)
    if not user then if cb then cb(false) end return end

    local character = user.getUsedCharacter
    if not character or not character.charIdentifier then
        if cb then cb(false) end
        return
    end
    local charId = character.charIdentifier

    local result = MySQL.query.await('SELECT * FROM `bcchousinghotels` WHERE `charidentifier` = ?', { charId })
    if #result == 0 then
        MySQL.query.await('INSERT INTO `bcchousinghotels` (`charidentifier`, `hotels`) VALUES (?, ?)', { charId, 'none' })
        result = { { hotels = 'none' } }
    end

    local hotelsData = result[1].hotels or 'none'
    local ownedHotelsTable = {}
    if hotelsData ~= 'none' then
        local ok, hotelsTable = pcall(json.decode, hotelsData)
        if ok and type(hotelsTable) == 'table' and #hotelsTable > 0 then
            ownedHotelsTable = hotelsTable
        end
    end

    if cb then cb(true, ownedHotelsTable) end
end)

BccUtils.RPC:Register('bcc-housing:HotelBought', function(params, cb, src)
    local requestedHotel = params and params.hotel
    local hotelTable = findHotelConfig(requestedHotel and requestedHotel.hotelId)
    local user = VORPcore.getUser(src)
    if not user then if cb then cb(false) end return end

    local character = user.getUsedCharacter
    if not character or not character.charIdentifier then
        if cb then cb(false) end
        return
    end
    local charId = character.charIdentifier

    local hotelCost = hotelTable and tonumber(hotelTable.cost)
    if not hotelTable or not hotelCost or hotelCost <= 0 then
        if cb then cb(false) end
        return
    end

    if ownsHotel(charId, hotelTable.hotelId) then
        NotifyClient(src, _U('hotelAlreadyOwned'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    if character.money < hotelCost then
        NotifyClient(src, _U('noMoney'), 4000, "error")
        if cb then cb(false) end
        return
    end

    MySQL.query.await('INSERT INTO `bcchousinghotels` (`charidentifier`, `hotels`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `charidentifier` = VALUES(`charidentifier`)', { charId, 'none' })

    local ownedHotelsTable = loadOwnedHotels(charId)
    table.insert(ownedHotelsTable, hotelTable.hotelId)
    local updatedHotels = json.encode(ownedHotelsTable)

    character.removeCurrency(0, hotelCost)
    MySQL.query.await('UPDATE `bcchousinghotels` SET `hotels` = ? WHERE `charidentifier` = ?', { updatedHotels, charId })

    if cb then cb(true, ownedHotelsTable) end
end)

BccUtils.RPC:Register('bcc-housing:RegisterHotelInventory', function(params, cb, src)
    local hotelId = params and params.hotelId
    local user = VORPcore.getUser(src)
    if not user then if cb then cb(false) end return end

    local character = user.getUsedCharacter
    if not character or not character.charIdentifier then
        if cb then cb(false) end
        return
    end
    local charId = character.charIdentifier

    local hotelCfg = findHotelConfig(hotelId)
    if not hotelCfg or not ownsHotel(charId, hotelCfg.hotelId) then
        NotifyClient(src, _U('hotelNotOwned'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local invId = 'bcc-housinginv:' .. tostring(hotelCfg.hotelId) .. tostring(charId)
    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered(invId)
    if isRegistered then if cb then cb(true) end return end

    local data = {
        id = invId,
        name = _U("hotelInvName"),
        limit = tonumber(hotelCfg.invSpace),
        acceptWeapons = true,
        shared = false,
        ignoreItemStackLimit = true,
        whitelistItems = false,
        UsePermissions = false,
        UseBlackList = false,
        whitelistWeapons = false
    }
    exports.vorp_inventory:registerInventory(data)
    if cb then cb(true) end
end)

BccUtils.RPC:Register('bcc-housing:HotelInvOpen', function(params, cb, src)
    local hotelId = params and params.hotelId
    local user = VORPcore.getUser(src)
    if not user then if cb then cb(false) end return end

    local character = user.getUsedCharacter
    if not character or not character.charIdentifier then
        if cb then cb(false) end
        return
    end
    local charId = character.charIdentifier

    local hotelCfg = findHotelConfig(hotelId)
    if not hotelCfg or not ownsHotel(charId, hotelCfg.hotelId) then
        NotifyClient(src, _U('hotelNotOwned'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local invId = 'bcc-housinginv:' .. tostring(hotelCfg.hotelId) .. tostring(charId)
    if not exports.vorp_inventory:isCustomInventoryRegistered(invId) then
        local data = {
            id = invId,
            name = _U("hotelInvName"),
            limit = tonumber(hotelCfg.invSpace),
            acceptWeapons = true,
            shared = false,
            ignoreItemStackLimit = true,
            whitelistItems = false,
            UsePermissions = false,
            UseBlackList = false,
            whitelistWeapons = false
        }
        exports.vorp_inventory:registerInventory(data)
    end

    exports.vorp_inventory:openInventory(src, invId)
    if cb then cb(true) end
end)
