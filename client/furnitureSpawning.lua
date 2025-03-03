RegisterNetEvent('bcc-housing:SpawnFurnitureEvent', function(furnTable)
    CreatedFurniture = {}

    for _, furn in pairs(furnTable) do
        local model = joaat(furn.model)
        local createdObject = Citizen.InvokeNative(0x9A294B2138ABB884, model, furn.coords.x, furn.coords.y, furn.coords.z, true, true) -- CreateObjectNoOffset
        SetEntityRotation(createdObject, furn.rotation.x, furn.rotation.y, furn.rotation.z, 2, true)
        FreezeEntityPosition(createdObject, true)
        table.insert(CreatedFurniture, createdObject)

        local entId = NetworkGetNetworkIdFromEntity(createdObject)
        Wait(10)
        TriggerServerEvent('bcc-housing:StoreFurnForDeletion', entId, HouseId)
    end
end)

AddEventHandler('bcc-housing:FurnCheckHandler', function() -- event to spawn, and del furniture based on distance to house
    devPrint("Starting furniture check handler")

    while true do
        Wait(2000)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - HouseCoords)

        if distance < HouseRadius + 20 then
            TriggerServerEvent('bcc-housing:FurniturePlacedCheck', HouseId, false, true)
            Wait(1500)
        elseif distance > HouseRadius + 100 then
            TriggerServerEvent('bcc-housing:FurniturePlacedCheck', HouseId, true)
            Wait(2000)
        end
    end
end)
