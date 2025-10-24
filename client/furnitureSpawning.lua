local furnStreamState = nil

BccUtils.RPC:Register("bcc-housing:SpawnFurnitureEvent", function(params)
    if not params or not params.furniture then
        devPrint("SpawnFurnitureEvent RPC received without furniture data")
        return
    end

    local furnTable = params.furniture
    if CreatedFurniture and #CreatedFurniture > 0 then
        for _, entity in ipairs(CreatedFurniture) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
        devPrint("Cleared previously spawned furniture entities before respawn.")
    end

    CreatedFurniture = {}
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

                    Wait(0)
                    local entId = NetworkGetNetworkIdFromEntity(createdObject)
                    if entId and entId ~= 0 then
                        BccUtils.RPC:Notify('bcc-housing:StoreFurnForDeletion', {
                            entId = entId,
                            houseid = HouseId
                        })
                    else
                        devPrint("Failed to obtain network ID for furniture model: " .. tostring(furn.model))
                    end
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
    devPrint("Starting furniture check handler")

    CreateThread(function()
        while true do
            Wait(2000)

            local ped = PlayerPedId()
            if not ped or ped == 0 then
                goto continue
            end

            if not HouseCoords then
                goto continue
            end

            local playerCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - HouseCoords)

            -- Within range: spawn furniture
            if distance < HouseRadius + 20.0 then
                if furnStreamState ~= "spawned" then
                    furnStreamState = "spawned"
                    devPrint("Player within furniture radius, requesting spawn for house ID " .. tostring(HouseId))
                end

                local ok = BccUtils.RPC:CallAsync("bcc-housing:FurniturePlacedCheck", {
                    houseid = HouseId,
                    deletion = false,
                    close = true
                })

                if not ok then devPrint("Failed to request furniture spawn for " .. tostring(HouseId)) end
                Wait(1500)

            elseif distance > HouseRadius + 100.0 then
                if furnStreamState ~= "cleared" then
                    furnStreamState = "cleared"
                    devPrint("Player left furniture radius, requesting deletion for house ID " .. tostring(HouseId))
                end

                local ok = BccUtils.RPC:CallAsync("bcc-housing:FurniturePlacedCheck", {
                    houseid = HouseId,
                    deletion = true
                })

                if not ok then devPrint("Failed to request furniture deletion for " .. tostring(HouseId)) end
                Wait(2000)
            end

            ::continue::
        end
    end)
end
