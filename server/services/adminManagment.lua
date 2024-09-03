RegisterServerEvent('bcc-housing:AdminGetAllHouses', function()
    local _source = source
    local result = MySQL.query.await("SELECT * FROM bcchousing")
    TriggerClientEvent('bcc-housing:AdminManagementMenu', _source, result)
end)

RegisterServerEvent('bcc-house:AdminManagementDelHouse', function(houseId)
    local _source = source
    local param = { ['houseid'] = houseId }
    exports.oxmysql:execute("DELETE FROM bcchousing WHERE houseid=@houseid", param, function(result)
        -- Assuming result.affectedRows holds the number of rows affected. Adjust if your result structure differs.
        if type(result) == "table" and result.affectedRows and result.affectedRows > 0 then
            VORPcore.NotifyLeft(_source, "House Deleted Sucessfully", "", "scoretimer_textures",
                "scoretimer_generic_tick", 5000)
        else
            VORPcore.NotifyLeft(_source, "Failed to delete house.", "", "scoretimer_textures", "scoretimer_generic_cross",
                5000)
        end
    end)
end)

RegisterServerEvent('bcc-house:AdminManagementChangeHouseRadius')
AddEventHandler('bcc-house:AdminManagementChangeHouseRadius', function(houseId, radius)
    local _source = source
    local param = { ['houseid'] = houseId, ['house_radius_limit'] = radius }
    exports.oxmysql:execute("UPDATE bcchousing SET `house_radius_limit`=@house_radius_limit WHERE houseid=@houseid",
        param, function(result)
            if type(result) == "table" and result.affectedRows and result.affectedRows > 0 then
                VORPcore.NotifyLeft(_source, "House radius updated successfully.", "", "scoretimer_textures",
                    "scoretimer_generic_tick", 5000)
            else
                VORPcore.NotifyLeft(_source, "Failed to update house radius.", "", "scoretimer_textures",
                    "scoretimer_generic_cross", 5000)
            end
        end)
end)

RegisterServerEvent('bcc-house:AdminManagementChangeInvLimit')
AddEventHandler('bcc-house:AdminManagementChangeInvLimit', function(houseId, invLimit)
    local _source = source
    local param = { ['houseid'] = houseId, ['invlimit'] = tostring(invLimit) }
    exports.oxmysql:execute("UPDATE bcchousing SET `invlimit`=@invlimit WHERE houseid=@houseid", param, function(result)
        if type(result) == "table" and result.affectedRows and result.affectedRows > 0 then
            VORPcore.NotifyLeft(_source, "Inventory limit updated successfully.", "", "scoretimer_textures",
                "scoretimer_generic_tick", 5000)
        else
            VORPcore.NotifyLeft(_source, "Failed to update inventory limit.", "", "scoretimer_textures",
                "scoretimer_generic_cross", 5000)
        end
    end)
end)

RegisterServerEvent('bcc-house:AdminManagementChangeTaxAmount')
AddEventHandler('bcc-house:AdminManagementChangeTaxAmount', function(houseId, tax)
    local _source = source
    local param = { ['houseid'] = houseId, ['tax_amount'] = tax }
    exports.oxmysql:execute("UPDATE bcchousing SET `tax_amount`=@tax_amount WHERE houseid=@houseid", param,
        function(result)
            if type(result) == "table" and result.affectedRows and result.affectedRows > 0 then
                VORPcore.NotifyLeft(_source, "Tax amount updated successfully.", "", "scoretimer_textures",
                    "scoretimer_generic_tick", 5000)
            else
                VORPcore.NotifyLeft(_source, "Failed to update tax amount.", "", "scoretimer_textures",
                    "scoretimer_generic_cross", 5000)
            end
        end)
end)
