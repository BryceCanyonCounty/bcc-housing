local furnStreamState = {}
local furnitureCheckHandlerStarted = false
OwnedHouseContexts = OwnedHouseContexts or {}

local function ClearSpawnedFurniture()
    if CreatedFurniture and #CreatedFurniture > 0 then
        for _, entity in ipairs(CreatedFurniture) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end
    CreatedFurniture = {}
end

BccUtils.RPC:Register("bcc-housing:ClearFurnitureEvent", function()
    ClearSpawnedFurniture()
end)

BccUtils.RPC:Register("bcc-housing:SpawnFurnitureEvent", function(params)
    if not params or not params.furniture then
        devPrint("SpawnFurnitureEvent RPC received without furniture data")
        return
    end

    local eventHouseId = tonumber(params.houseid) or HouseId
    local furnTable = params.furniture
    ClearSpawnedFurniture()
    devPrint("Cleared previously spawned furniture entities before respawn.")
    local spawnedCount = 0

    for _, furn in pairs(furnTable) do
        local modelHash = joaat(furn.model)
        if modelHash == 0 then
            devPrint("Invalid furniture model: " .. tostring(furn.model))
        else
            if not HasModelLoaded(modelHash) then
                RequestModel(modelHash)
                local attempts = 0
                while not HasModelLoaded(modelHash) and attempts < 40 do
                    Wait(50)
                    attempts = attempts + 1
                end
            end

            if not HasModelLoaded(modelHash) then
                devPrint("Failed to load furniture model: " .. tostring(furn.model))
            else
                local createdObject = Citizen.InvokeNative(0x9A294B2138ABB884, modelHash, furn.coords.x, furn.coords.y, furn.coords.z, true, true) -- CreateObjectNoOffset
                if createdObject ~= 0 then
                    SetEntityRotation(createdObject, furn.rotation.x, furn.rotation.y, furn.rotation.z, 2, true)
                    FreezeEntityPosition(createdObject, true)
                    SetEntityAsMissionEntity(createdObject, true, true)
                    table.insert(CreatedFurniture, createdObject)
                    spawnedCount = spawnedCount + 1
                else
                    devPrint("Failed to create furniture object for model: " .. tostring(furn.model))
                end

                SetModelAsNoLongerNeeded(modelHash)
            end
        end
    end

    devPrint("SpawnFurnitureEvent completed, spawned entities: " .. tostring(spawnedCount))
end)

function StartFurnCheckHandler()
    if furnitureCheckHandlerStarted then return end
    furnitureCheckHandlerStarted = true
    devPrint("Starting furniture check handler")

    CreateThread(function()
        while true do
            Wait(2000)

            local ped = PlayerPedId()
            if not ped or ped == 0 then
                goto continue
            end

            if not OwnedHouseContexts or not next(OwnedHouseContexts) then
                goto continue
            end

            local playerCoords = GetEntityCoords(ped)
            local nearestHouse, nearestDist = nil, nil

            for id, data in pairs(OwnedHouseContexts) do
                local coords = data.coords
                if coords then
                    local dist = #(playerCoords - coords)
                    local radius = data.radius or (Config and Config.DefaultMenuManageRadius) or 2.0

                    if not nearestDist or dist < nearestDist then
                        nearestHouse = data
                        nearestDist = dist
                    end

                    if dist < radius + 100.0 then
                        if furnStreamState[id] ~= "spawned" then
                            furnStreamState[id] = "spawned"
                            devPrint("Player within furniture radius, requesting spawn for house ID " .. tostring(id))

                            local ok = BccUtils.RPC:CallAsync("bcc-housing:FurniturePlacedCheck", {
                                houseid = id,
                                deletion = false,
                                close = true
                            })
                            if not ok then devPrint("Failed to request furniture spawn for " .. tostring(id)) end
                            Wait(500)
                        end
                    elseif dist > radius + 200.0 then
                        if furnStreamState[id] ~= "cleared" then
                            furnStreamState[id] = "cleared"
                            devPrint("Player left furniture radius, clearing props for house ID " .. tostring(id))
                            ClearSpawnedFurniture()
                            local ok = BccUtils.RPC:CallAsync("bcc-housing:FurniturePlacedCheck", {
                                houseid = id,
                                deletion = true
                            })
                            if not ok then devPrint("Failed to request furniture deletion for " .. tostring(id)) end
                            Wait(500)
                        end
                    end
                end
            end

            if nearestHouse and nearestDist then
                local activationRadius = (nearestHouse.radius or 2.0) + 5.0
                if nearestDist <= activationRadius then
                    if SetActiveHouseContext then
                        SetActiveHouseContext(nearestHouse)
                    end
                end
            end

            ::continue::
        end
    end)
end
