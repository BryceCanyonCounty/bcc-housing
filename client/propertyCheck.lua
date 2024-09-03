local propertyCheckActive = false
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
        return                      -- Exit the handler if values are missing
    end

    devPrint("Starting private property check handler")

    propertyCheckActive = true
    local privatePropertyRadius = houseRadius + 20 -- Adjust the radius as needed
    local isInsidePrivateProperty = false          -- Track if the player is currently inside the property
    local lastNotificationTime = 0                 -- Track the last time a notification was shown

    while propertyCheckActive do
        Wait(1500) -- Run the loop continuously

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distanceToHouse = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, houseCoords.x, houseCoords.y, houseCoords.z, true)

        if distanceToHouse < privatePropertyRadius then
            if not isInsidePrivateProperty then
                -- First time entering the property
                VORPcore.NotifyBottomRight(_U("enteringPrivate"), 4000)
                isInsidePrivateProperty = true
                devPrint("Player has entered private property.")
                lastNotificationTime = GetGameTimer() -- Set the time for the first notification
            elseif GetGameTimer() - lastNotificationTime >= 8000 then
                -- Show the message every 10 seconds
                VORPcore.NotifyRightTip(_U("onPrivate"), 10000)
                lastNotificationTime = GetGameTimer() -- Update the time for the next notification
            end
        elseif isInsidePrivateProperty then
            -- Player has left the property
            VORPcore.NotifyBottomRight(_U("leavingPrivate"), 4000)
            isInsidePrivateProperty = false
            devPrint("Player has left private property.")
        end
    end
    devPrint("Property check loop has ended.")
end)

RegisterNetEvent('bcc-housing:StopPropertyCheck')
AddEventHandler('bcc-housing:StopPropertyCheck', function()
    propertyCheckActive = false
end)
