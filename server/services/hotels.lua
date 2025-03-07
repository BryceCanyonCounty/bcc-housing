RegisterNetEvent('bcc-housing:HotelDbRegistry', function()
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier

    local result = MySQL.query.await('SELECT * FROM `bcchousinghotels` WHERE `charidentifier` = ?', { charId })
    if #result == 0 then
        MySQL.query.await('INSERT INTO `bcchousinghotels` (`charidentifier`) VALUES (?)', { charId })
        result = { { hotels = 'none' } }
    end

    local hotelsData = result[1].hotels
    if hotelsData ~= 'none' then
        local hotelsTable = json.decode(hotelsData)
        if hotelsTable and #hotelsTable > 0 then
            for _, hotelId in ipairs(hotelsTable) do
                TriggerClientEvent('bcc-housing:UpdateHotelTable', src, hotelId)
            end
        end
    else
        for _, hotelId in ipairs(result) do
            TriggerClientEvent('bcc-housing:UpdateHotelTable', src, hotelId)
        end
    end

    TriggerClientEvent('bcc-housing:MainHotelHandler', src)
end)

RegisterNetEvent('bcc-housing:HotelBought', function(hotelTable)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier

    local result = MySQL.query.await('SELECT * FROM `bcchousinghotels` WHERE `charidentifier` = ?', { charId })
    local ownedHotels = result[1] and result[1].hotels or 'none'

    if character.money < hotelTable.cost then
        VORPcore.NotifyRightTip(src, _U('noMoney'), 4000)
        return
    end

    local ownedHotelsTable = ownedHotels == 'none' and {} or json.decode(ownedHotels)
    table.insert(ownedHotelsTable, hotelTable.hotelId)
    local updatedHotels = json.encode(ownedHotelsTable)

    character.removeCurrency(0, hotelTable.cost)

    MySQL.query.await('UPDATE `bcchousinghotels` SET `hotels` = ? WHERE `charidentifier` = ?', { updatedHotels, charId })

    for _, hotelId in ipairs(ownedHotelsTable) do
        TriggerClientEvent('bcc-housing:UpdateHotelTable', src, hotelId)
    end
end)

RegisterServerEvent('bcc-housing:RegisterHotelInventory', function(hotelId)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier

    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered('bcc-housinginv:' .. tostring(hotelId) .. tostring(charId))
    if isRegistered then return end

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
end)

RegisterServerEvent('bcc-housing:HotelInvOpen', function(hotelId)
    local _source = source
    local user = VORPcore.getUser(_source)
    if not user then return end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier

    exports.vorp_inventory:openInventory(_source, 'bcc-housinginv:' .. tostring(hotelId) .. tostring(charId))
end)
