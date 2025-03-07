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

CreateThread(function() --registering all inventories
    for _, hotel in pairs(Hotels) do
        Wait(50)        -- Slight delay to ensure proper removal before registration

        -- Register inventory for the hotel
        local data = {
            id = 'bcc-housinginv:' .. tostring(hotel.hotelId),
            name = _U("hotelInvName"),
            limit = tonumber(hotel.invSpace),
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
end)

RegisterServerEvent('bcc-housing:HotelInvOpen', function(hotelId)
    local _source = source
    exports.vorp_inventory:openInventory(_source, 'bcc-housinginv:' .. tostring(hotelId))
end)
