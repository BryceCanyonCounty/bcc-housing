RegisterServerEvent('bcc-housing:AdminGetAllHouses')
AddEventHandler('bcc-housing:AdminGetAllHouses', function()
    local _source = source
    print("AdminGetAllHouses triggered by source:", _source)

    -- Fetch all house data from the database
    local result = MySQL.query.await("SELECT * FROM bcchousing")
    if not result then
        print("Error: No house data found in the database.")
        return
    end
    print("House data retrieved from database:", #result, "houses found.")

    local allHouses = {}

    for _, houseInfo in ipairs(result) do
        local houseCharIdentifier = houseInfo.charidentifier
        print("Processing house with ID:", houseInfo.houseid, "and character identifier:", houseCharIdentifier)

        if houseCharIdentifier then
            -- Attempt to get character data from the characters table directly
            local characterData = MySQL.query.await("SELECT firstname, lastname FROM characters WHERE charidentifier = ?", { houseCharIdentifier })

            if characterData and #characterData > 0 then
                houseInfo.firstName = characterData[1].firstname
                houseInfo.lastName = characterData[1].lastname
                print("Character found in database - First Name:", houseInfo.firstName, "Last Name:", houseInfo.lastName)
            else
                houseInfo.firstName = "Unknown"
                houseInfo.lastName = "Unknown"
                print("Warning: No character data found for character identifier:", houseCharIdentifier)
            end
        else
            houseInfo.firstName = "Unknown"
            houseInfo.lastName = "Unknown"
            print("Warning: houseCharIdentifier is missing for house ID:", houseInfo.houseid)
        end

        table.insert(allHouses, houseInfo)
    end

    -- Confirm the structure and data being sent to the client
    print("All houses prepared for client:", allHouses)

    -- Send the data to the client
    TriggerClientEvent('bcc-housing:AdminManagementMenu', _source, allHouses)
end)

RegisterServerEvent('bcc-house:AdminManagementDelHouse', function(houseId)
    local _source = source
    local param = { ['houseid'] = houseId }
    exports.oxmysql:execute("DELETE FROM bcchousing WHERE houseid=@houseid", param, function(result)
        -- Assuming result.affectedRows holds the number of rows affected. Adjust if your result structure differs.
        if type(result) == "table" and result.affectedRows and result.affectedRows > 0 then
            VORPcore.NotifyLeft(_source, _U('housesDeleted'), "", "scoretimer_textures", "scoretimer_generic_tick", 5000)
        else
            VORPcore.NotifyLeft(_source, _U('failedDeleteHouse'), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
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
                VORPcore.NotifyLeft(_source, _U('radiusUpdatedSuccess'), "", "scoretimer_textures", "scoretimer_generic_tick", 5000)
            else
                VORPcore.NotifyLeft(_source, _U('radiusUpdatedFailed'), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
            end
        end)
end)

RegisterServerEvent('bcc-house:AdminManagementChangeInvLimit')
AddEventHandler('bcc-house:AdminManagementChangeInvLimit', function(houseId, invLimit)
    local _source = source
    local param = { ['houseid'] = houseId, ['invlimit'] = tostring(invLimit) }
    exports.oxmysql:execute("UPDATE bcchousing SET `invlimit`=@invlimit WHERE houseid=@houseid", param, function(result)
        if type(result) == "table" and result.affectedRows and result.affectedRows > 0 then
            VORPcore.NotifyLeft(_source, _U('invUpdatedSuccess'), "", "scoretimer_textures", "scoretimer_generic_tick", 5000)
        else
            VORPcore.NotifyLeft(_source, _U('invUpdatedFailed'), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
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
                VORPcore.NotifyLeft(_source, _U('taxUpdatedSuccess'), "", "scoretimer_textures", "scoretimer_generic_tick", 5000)
            else
                VORPcore.NotifyLeft(_source, _U('taxUpdatedFailed'), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
            end
        end)
end)
