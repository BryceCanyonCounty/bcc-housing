BccUtils.RPC:Register('bcc-housing:HotelDbRegistry', function(params, cb, src)
    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false) end
        return
    end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier

    local result = MySQL.query.await('SELECT * FROM `bcchousinghotels` WHERE `charidentifier` = ?', { charId })
    if #result == 0 then
        MySQL.query.await('INSERT INTO `bcchousinghotels` (`charidentifier`) VALUES (?)', { charId })
        result = { { hotels = 'none' } }
    end

    local hotelsData = result[1].hotels
    local ownedHotelsTable = {}
    if hotelsData ~= 'none' then
        local hotelsTable = json.decode(hotelsData)
        if hotelsTable and #hotelsTable > 0 then
            ownedHotelsTable = hotelsTable
        end
    end

    if cb then cb(true, ownedHotelsTable) end
end)

BccUtils.RPC:Register('bcc-housing:HotelBought', function(params, cb, src)
    local hotelTable = params and params.hotel
    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false, _U('noFurn')) end
        return
    end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier

    local result = MySQL.query.await('SELECT * FROM `bcchousinghotels` WHERE `charidentifier` = ?', { charId })
    local ownedHotels = result[1] and result[1].hotels or 'none'

    if not hotelTable or not hotelTable.cost or not hotelTable.hotelId then
        if cb then cb(false, nil, 'Invalid hotel data.') end
        return
    end

    if character.money < hotelTable.cost then
        NotifyClient(src, _U('noMoney'), 4000, "error")
        if cb then cb(false, nil, _U('noMoney')) end
        return
    end

    local ownedHotelsTable = ownedHotels == 'none' and {} or json.decode(ownedHotels)
    table.insert(ownedHotelsTable, hotelTable.hotelId)
    local updatedHotels = json.encode(ownedHotelsTable)

    character.removeCurrency(0, hotelTable.cost)

    MySQL.query.await('UPDATE `bcchousinghotels` SET `hotels` = ? WHERE `charidentifier` = ?', { updatedHotels, charId })

    if cb then cb(true, ownedHotelsTable, nil) end
end)

BccUtils.RPC:Register('bcc-housing:RegisterHotelInventory', function(params, cb, src)
    local hotelId = params and params.hotelId
    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false) end
        return
    end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier

    if not hotelId then
        if cb then cb(false) end
        return
    end

    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered('bcc-housinginv:' .. tostring(hotelId) .. tostring(charId))
    if isRegistered then
        if cb then cb(true) end
        return
    end

    for _, hotelCfg in pairs(Hotels) do
        if hotelCfg.hotelId == hotelId then
            local data = {
                id = 'bcc-housinginv:' .. tostring(hotelCfg.hotelId) .. tostring(charId),
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
    end
    if cb then cb(true) end
end)

BccUtils.RPC:Register('bcc-housing:HotelInvOpen', function(params, cb, src)
    local hotelId = params and params.hotelId
    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false) end
        return
    end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier

    if hotelId then
        exports.vorp_inventory:openInventory(src, 'bcc-housinginv:' .. tostring(hotelId) .. tostring(charId))
        if cb then cb(true) end
    else
        if cb then cb(false) end
    end
end)
