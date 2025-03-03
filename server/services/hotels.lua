----- Hotel Area ----
RegisterServerEvent('bcc-housing:HotelDbRegistry', function() --registering each player
    local _source = source
    local user = VORPcore.getUser(_source)
    if not user then return end
    local character = user.getUsedCharacter and user.getUsedCharacter
    local param = { ['charidentifier'] = character.charIdentifier }
    local result = MySQL.query.await("SELECT * FROM bcchousinghotels WHERE charidentifier=@charidentifier", param)
    if #result == 0 then
        exports.oxmysql:execute("INSERT INTO bcchousinghotels ( `charidentifier` ) VALUES ( @charidentifier )", param)
    else
        for k, v in pairs(result) do
            TriggerClientEvent('bcc-housing:HousingTableUpdate', _source, v)
        end
    end
    Wait(1000)
    local result2 = MySQL.query.await("SELECT * FROM bcchousinghotels WHERE charidentifier=@charidentifier", param)
    if result2[1].hotels ~= 'none' then
        local hotelsTable = json.decode(result2[1].hotels)
        if #hotelsTable > 0 then
            for k, v in pairs(hotelsTable) do
                TriggerClientEvent('bcc-housing:HousingTableUpdate', _source, v)
            end
        end
    end
    TriggerClientEvent('bcc-housing:MainHotelHandler', _source)
end)

RegisterServerEvent('bcc-housing:HotelBought', function(hotelTable)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['charidentifier'] = character.charIdentifier }
    local result = MySQL.query.await("SELECT * FROM bcchousinghotels WHERE charidentifier=@charidentifier", param)
    local ownedHotels = result[1].hotels
    local tableToInsert = nil
    if ownedHotels == 'none' then
        if character.money >= hotelTable.cost then
            character.removeCurrency(0, hotelTable.cost)
            tableToInsert = json.encode({ hotelTable.hotelId })
        else
            VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
        end
    else
        local ownedHotels2 = json.decode(ownedHotels)
        if character.money >= hotelTable.cost then
            table.insert(ownedHotels2, hotelTable.hotelId)
            character.removeCurrency(0, hotelTable.cost)
            tableToInsert = json.encode(ownedHotels2)
        else
            VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
        end
    end
    if tableToInsert ~= nil then
        local param2 = { ['charidentifier'] = character.charIdentifier, ['hotelsTable'] = tableToInsert }
        exports.oxmysql:execute("UPDATE bcchousinghotels SET hotels=@hotelsTable WHERE charidentifier=@charidentifier",
            param2)
        for k, v in pairs(json.decode(tableToInsert)) do
            TriggerClientEvent('bcc-housing:HousingTableUpdate', _source, v)
        end
    end
end)

CreateThread(function() --registering all inventories
    for k, v in pairs(Hotels) do
        Wait(50)        -- Slight delay to ensure proper removal before registration

        -- Register inventory for the hotel
        local data = {
            id = 'bcc-housinginv:' .. tostring(v.hotelId),
            name = _U("hotelInvName"),
            limit = tonumber(v.invSpace),
            acceptWeapons = true,
            shared = true,
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
