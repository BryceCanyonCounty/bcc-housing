RegisterNetEvent('bcc-housing:SpawnFurnitureEvent', function(furnTable)
    CreatedFurniture = {}
    for k, v in pairs(furnTable) do
        local model = joaat(v.model)
        local createdObject = CreateObject(model, v.coords.x, v.coords.y, v.coords.z, true, true)
        SetEntityHeading(v.coords.h)
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
        local plc = GetEntityCoords(PlayerPedId())
        local dist =
            GetDistanceBetweenCoords(plc.x, plc.y, plc.z, HouseCoords.x, HouseCoords.y, HouseCoords.z, true)
        if dist < HouseRadius + 20 then
            TriggerServerEvent('bcc-housing:FurniturePlacedCheck', HouseId, false, true)
            Wait(1500)
        elseif dist > HouseRadius + 100 then
            TriggerServerEvent('bcc-housing:FurniturePlacedCheck', HouseId, true)
            Wait(2000)
        end
    end
end)
