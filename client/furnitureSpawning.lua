CreatedFurniture = {}
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

--- Cleanup/ deletion on leave ----
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if #CreatedFurniture > 0 then
            for k, v in pairs(CreatedFurniture) do
                DeleteObject(v)
            end
            for k, v in pairs(HouseBlips) do
                VORPutils.Blips:RemoveBlip(v.rawblip)
            end
        end
        TriggerServerEvent('bcc-housing:ServerSideRssStop')
    end
end)