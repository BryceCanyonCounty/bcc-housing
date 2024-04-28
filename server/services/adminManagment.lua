RegisterServerEvent('bcc-housing:AdminGetAllHouses', function()
    local _source = source
    local result = MySQL.query.await("SELECT * FROM bcchousing")
    TriggerClientEvent('bcc-housing:AdminManagementMenu', _source, result)
end)

RegisterServerEvent('bcc-house:AdminManagementDelHouse', function(houseId)
    local param = { ['houseid'] = houseId }
    exports.oxmysql:execute("DELETE FROM bcchousing WHERE houseid=@houseid", param)
end)

RegisterServerEvent('bcc-house:AdminManagementChangeHouseRadius', function(houseId, radius)
    local param = { ['houseid'] = houseId, ['house_radius_limit'] = radius }
    exports.oxmysql:execute("UPDATE bcchousing SET `house_radius_limit`=@house_radius_limit WHERE houseid=@houseid",
        param)
end)

RegisterServerEvent('bcc-house:AdminManagementChangeInvLimit', function(houseId, invLimit)
    local param = { ['houseid'] = houseId, ['invlimit'] = tostring(invLimit) }
    exports.oxmysql:execute("UPDATE bcchousing SET `invlimit`=@invlimit WHERE houseid=@houseid", param)
end)

RegisterServerEvent('bcc-house:AdminManagementChangeTaxAmount', function(houseId, tax)
    local param = { ['houseid'] = houseId, ['tax_amount'] = tax }
    exports.oxmysql:execute("UPDATE bcchousing SET `tax_amount`=@tax_amount WHERE houseid=@houseid", param)
end)
