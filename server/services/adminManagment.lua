local function formatPurchasedAt(value)
    if not value or value == '' then
        return nil
    end

    local timestamp = tonumber(value)
    if timestamp then
        if timestamp > 9999999999 then
            timestamp = math.floor(timestamp / 1000)
        end

        return os.date("%Y-%m-%d %H:%M", timestamp)
    end

    return tostring(value):sub(1, 16)
end

local function collectAdminHouseData()
    local result = MySQL.query.await('SELECT * FROM bcchousing')
    if not result then
        DBG:Error('Error: No house data found in the database.')
        return {}
    end
    DBG:Info('House data retrieved from database:', #result, 'houses found.')

    local allHouses = {}

    for _, houseInfo in ipairs(result) do
        local houseCharIdentifier = houseInfo.charidentifier
        houseInfo.purchased_at_formatted = formatPurchasedAt(houseInfo.purchased_at)
        DBG:Info('Processing house with ID:', houseInfo.houseid, 'and character identifier:', houseCharIdentifier)

        if houseCharIdentifier then
            local characterData = MySQL.query.await('SELECT firstname, lastname FROM characters WHERE charidentifier = ?', { houseCharIdentifier })

            if characterData and #characterData > 0 then
                houseInfo.firstName = characterData[1].firstname
                houseInfo.lastName = characterData[1].lastname
                DBG:Info('Character found in database - First Name:', houseInfo.firstName, 'Last Name:', houseInfo.lastName)
            else
                houseInfo.firstName = 'Unknown'
                houseInfo.lastName = 'Unknown'
                DBG:Info('Warning: No character data found for character identifier:', houseCharIdentifier)
            end
        else
            houseInfo.firstName = 'Unknown'
            houseInfo.lastName = 'Unknown'
            DBG:Info('Warning: houseCharIdentifier is missing for house ID:', houseInfo.houseid)
        end

        table.insert(allHouses, houseInfo)
    end

    DBG:Info('All houses prepared for client:', allHouses)
    return allHouses
end

local function pushAdminHouseData(src, houses)
    BccUtils.RPC:Notify('bcc-housing:AdminManagementMenu', { houses = houses }, src)
end

BccUtils.RPC:Register('bcc-housing:AdminGetAllHouses', function(_, cb, src)
    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    DBG:Info('AdminGetAllHouses RPC triggered by source:', src)
    local houses = collectAdminHouseData()
    pushAdminHouseData(src, houses)
    if cb then cb(true, houses) end
end)

BccUtils.RPC:Register('bcc-house:AdminManagementDelHouse', function(params, cb, src)
    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { error = 'invalid_house' }) end
        return
    end

    local param = { ['houseid'] = houseId }
    exports.oxmysql:execute("DELETE FROM bcchousing WHERE houseid=@houseid", param, function(result)
        local success = type(result) == "table" and result.affectedRows and result.affectedRows > 0
        if success then
            NotifyClient(src, _U('housesDeleted'), 5000, "success")
            if cb then cb(true) end
        else
            NotifyClient(src, _U('failedDeleteHouse'), 5000, "error")
            if cb then cb(false) end
        end
    end)
end)

BccUtils.RPC:Register('bcc-house:AdminManagementChangeHouseRadius', function(params, cb, src)
    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local houseId = params and params.houseId
    local radius = params and params.radius
    if not houseId or not radius then
        if cb then cb(false, { error = 'invalid_params' }) end
        return
    end

    local param = { ['houseid'] = houseId, ['house_radius_limit'] = radius }
    exports.oxmysql:execute("UPDATE bcchousing SET `house_radius_limit`=@house_radius_limit WHERE houseid=@houseid",
        param, function(result)
            local success = type(result) == "table" and result.affectedRows and result.affectedRows > 0
            if success then
                NotifyClient(src, _U('radiusUpdatedSuccess'), 5000, "success")
                if cb then cb(true) end
            else
                NotifyClient(src, _U('radiusUpdatedFailed'), 5000, "error")
                if cb then cb(false) end
            end
        end)
end)

BccUtils.RPC:Register('bcc-house:AdminManagementChangeInvLimit', function(params, cb, src)
    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local houseId = params and params.houseId
    local invLimit = params and params.invLimit
    if not houseId or not invLimit then
        if cb then cb(false, { error = 'invalid_params' }) end
        return
    end

    local param = { ['houseid'] = houseId, ['invlimit'] = tostring(invLimit) }
    exports.oxmysql:execute("UPDATE bcchousing SET `invlimit`=@invlimit WHERE houseid=@houseid", param, function(result)
        local success = type(result) == "table" and result.affectedRows and result.affectedRows > 0
        if success then
            NotifyClient(src, _U('invUpdatedSuccess'), 5000, "success")
            if cb then cb(true) end
        else
            NotifyClient(src, _U('invUpdatedFailed'), 5000, "error")
            if cb then cb(false) end
        end
    end)
end)

BccUtils.RPC:Register('bcc-house:AdminManagementChangeTaxAmount', function(params, cb, src)
    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local houseId = params and params.houseId
    local tax = params and params.tax
    if not houseId or not tax then
        if cb then cb(false, { error = 'invalid_params' }) end
        return
    end

    local param = { ['houseid'] = houseId, ['tax_amount'] = tax }
    exports.oxmysql:execute("UPDATE bcchousing SET `tax_amount`=@tax_amount WHERE houseid=@houseid", param,
        function(result)
        local success = type(result) == "table" and result.affectedRows and result.affectedRows > 0
        if success then
            NotifyClient(src, _U('taxUpdatedSuccess'), 5000, "success")
            if cb then cb(true) end
        else
            NotifyClient(src, _U('taxUpdatedFailed'), 5000, "error")
            if cb then cb(false) end
        end
        end)
end)

BccUtils.RPC:Register('bcc-house:AdminReleaseHouseTaxPayment', function(params, cb, src)
    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { error = 'invalid_house' }) end
        return
    end

    local affectedRows = MySQL.update.await(
        "UPDATE bcchousing SET taxes_collected = 'released' WHERE houseid = ? AND taxes_collected = 'overdue'",
        { houseId }
    )

    if affectedRows and affectedRows > 0 then
        NotifyClient(src, _U('taxPaymentReleasedAdmin'), 5000, 'success')
        if cb then cb(true) end
        return
    end

    NotifyClient(src, _U('taxPaymentReleaseFailed'), 5000, 'error')
    if cb then cb(false) end
end)
