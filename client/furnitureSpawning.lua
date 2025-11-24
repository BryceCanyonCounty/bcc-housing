local furnStreamState = {}
local furnitureCheckHandlerStarted = false
OwnedHouseContexts = OwnedHouseContexts or {}
CreatedFurniture = {}

function ClearSpawnedFurniture()
    local count = (CreatedFurniture and #CreatedFurniture) or 0
    DBG:Info(("[ClearSpawnedFurniture] Attempting to delete %d spawned furniture entities"):format(count))
    if CreatedFurniture and #CreatedFurniture > 0 then
        for _, entity in ipairs(CreatedFurniture) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
                DBG:Info(("[ClearSpawnedFurniture] Deleted entity id %s"):format(tostring(entity)))
            else
                DBG:Info(("[ClearSpawnedFurniture] Entity id %s no longer exists"):format(tostring(entity)))
            end
        end
    end
    CreatedFurniture = {}
    DBG:Info("[ClearSpawnedFurniture] Finished clearing furniture list")
end

BccUtils.RPC:Register("bcc-housing:ClearFurnitureEvent", function(params, cb)
    local hid = params and params.houseid
    DBG:Info(("[ClearFurnitureEvent] RPC received%s, clearing furniture") :format(hid and (" for houseId " .. tostring(hid)) or ""))

    -- Protect ClearSpawnedFurniture in pcall
    local ok, err = pcall(function()
        -- If ClearSpawnedFurniture needs params/house/source, pass them here
        -- Example guesses (you know the real signature):
        -- ClearSpawnedFurniture(hid, src)
        ClearSpawnedFurniture()
    end)

    if not ok then
        DBG:Error("[ClearFurnitureEvent] ClearSpawnedFurniture failed: " .. tostring(err))
    else
        DBG:Info("[ClearFurnitureEvent] ClearSpawnedFurniture finished successfully")
    end

    if cb then cb(true) end
end)

RegisterNetEvent("bcc-housing:ClearFurnitureEvent", function()
    DBG:Info("[ClearFurnitureEvent] Plain net event received, clearing furniture")
    ClearSpawnedFurniture()
end)

-- Fallbacks to catch resource stop/unload on the client
AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    ClearSpawnedFurniture()
end)

AddEventHandler("onClientResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DBG:Info("[ClearFurnitureEvent] onClientResourceStop received, clearing furniture locally")
    ClearSpawnedFurniture()
end)

BccUtils.RPC:Register("bcc-housing:SpawnFurnitureEvent", function(params)
    if not params or not params.furniture then
        DBG:Info("SpawnFurnitureEvent RPC received without furniture data")
        return
    end

    local eventHouseId = tonumber(params.houseid) or HouseId
    local furnTable = params.furniture
    ClearSpawnedFurniture()
    DBG:Info("Cleared previously spawned furniture entities before respawn.")
    local spawnedCount = 0

    for _, furn in pairs(furnTable) do
        local modelHash = joaat(furn.model)
        if modelHash == 0 then
            DBG:Warning("Invalid furniture model: " .. tostring(furn.model))
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
                DBG:Error("Failed to load furniture model: " .. tostring(furn.model))
            else
                local createdObject = CreateObjectNoOffset(
                    modelHash,
                    furn.coords.x,
                    furn.coords.y,
                    furn.coords.z,
                    false,  -- isNetwork
                    false,  -- netMissionEntity
                    false,  -- dynamic
                    false   -- extra flag (same as other script)
                )

                if createdObject ~= 0 then
                    SetEntityRotation(createdObject, furn.rotation.x, furn.rotation.y, furn.rotation.z, 2, true)
                    FreezeEntityPosition(createdObject, true)
                    SetEntityAsMissionEntity(createdObject, true, true)
                    table.insert(CreatedFurniture, createdObject)
                    spawnedCount = spawnedCount + 1
                else
                    DBG:Error("Failed to create furniture object for model: " .. tostring(furn.model))
                end

                SetModelAsNoLongerNeeded(modelHash)
            end
        end
    end

    DBG:Info("SpawnFurnitureEvent completed, spawned entities: " .. tostring(spawnedCount))
end)

function StartFurnCheckHandler()
    if furnitureCheckHandlerStarted then return end
    furnitureCheckHandlerStarted = true
    DBG:Info("Starting furniture check handler")

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

            -- configurable spawn/despawn distance
            local spawnDespawnDistance = (Furniture and Furniture.SpawnDespawn) or 200.0

            for id, data in pairs(OwnedHouseContexts) do
                local coords = data.coords
                if coords then
                    local dist = #(playerCoords - coords)
                    local radius = data.radius or (Furniture and Furniture.DefaultMenuManageRadius) or 2.0

                    if not nearestDist or dist < nearestDist then
                        nearestHouse = data
                        nearestDist = dist
                    end

                    -- SPAWN furniture when within Furniture.SpawnDespawn
                    if dist < spawnDespawnDistance then
                        if furnStreamState[id] ~= "spawned" then
                            furnStreamState[id] = "spawned"
                            DBG:Info(("Player within furniture spawn distance (%.1f), requesting spawn for house ID %s"):format(
                                spawnDespawnDistance, tostring(id))
                            )

                            local ok = BccUtils.RPC:CallAsync("bcc-housing:FurniturePlacedCheck", {
                                houseid = id,
                                deletion = false,
                                close = true
                            })
                            if not ok then
                                DBG:Error("Failed to request furniture spawn for " .. tostring(id))
                            end
                            Wait(500)
                        end

                    -- DESPAWN furniture when beyond Furniture.SpawnDespawn
                    elseif dist > spawnDespawnDistance then
                        if furnStreamState[id] ~= "cleared" then
                            furnStreamState[id] = "cleared"
                            DBG:Info(("Player outside furniture despawn distance (%.1f), clearing props for house ID %s"):format(
                                spawnDespawnDistance, tostring(id))
                            )

                            ClearSpawnedFurniture()
                            local ok = BccUtils.RPC:CallAsync("bcc-housing:FurniturePlacedCheck", {
                                houseid = id,
                                deletion = true
                            })
                            if not ok then
                                DBG:Error("Failed to request furniture deletion for " .. tostring(id))
                            end
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
