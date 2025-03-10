local propertyCheckActive = false

-- Command to toggle the NUI
RegisterCommand('hidePropertyUI', function(source, args)
    SendNUIMessage({
        action = "hidePropertyUI"
    })
end, false)

RegisterNetEvent('bcc-housing:PrivatePropertyCheckHandler')
AddEventHandler('bcc-housing:PrivatePropertyCheckHandler', function(houseCoords, houseRadius)
    -- Check if the property check is enabled
    if not Config.EnablePrivatePropertyCheck then
        devPrint("Private property check is disabled in the config.")
        return -- Exit the handler if the check is disabled
    end

    -- Check if houseCoords and houseRadius are provided
    if not houseCoords or not houseRadius then
        devPrint("Error: Missing houseCoords or houseRadius.")
        propertyCheckActive = false -- Stop the check if values are missing
        return -- Exit the handler if values are missing
    end

    devPrint("Starting private property check handler")

    propertyCheckActive = true
    local privatePropertyRadius = houseRadius + 20 -- Adjust the radius as needed
    local isInsidePrivateProperty = false -- Track if the player is currently inside the property

    while propertyCheckActive do
        Wait(1500) -- Run the loop continuously

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distanceToHouse = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, houseCoords.x, houseCoords.y, houseCoords.z, true)

        if distanceToHouse < privatePropertyRadius then
            if not isInsidePrivateProperty then
                -- First time entering the property
                VORPcore.NotifyRightTip(_U("enteringPrivate"), 3000)
                Wait(4000)
                SendNUIMessage({
                    action = "showPropertyUI"
                })
                isInsidePrivateProperty = true
                devPrint("Player has entered private property.")
            end
        elseif isInsidePrivateProperty then
            -- Player has left the property
            VORPcore.NotifyRightTip(_U("leavingPrivate"), 4000)
            SendNUIMessage({
                action = "hidePropertyUI"
            })
            isInsidePrivateProperty = false
            devPrint("Player has left private property.")
        end
    end

    -- Ensure the UI is hidden when the loop ends
    SendNUIMessage({
        action = "hidePropertyUI"
    })

    devPrint("Property check loop has ended.")
end)

RegisterNetEvent('bcc-housing:StopPropertyCheck')
AddEventHandler('bcc-housing:StopPropertyCheck', function()
    propertyCheckActive = false

    -- Ensure the UI is hidden when property check stops
    SendNUIMessage({
        action = "hidePropertyUI"
    })

    devPrint("Property check has been stopped.")
end)
