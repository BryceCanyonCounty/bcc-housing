local CreatedVendorBlips = {}
local CreatedVendorNpcs  = {}
ActiveFurnitureVendor    = nil

local furnitureVendors = (Furniture and Furniture.Vendors) or Config.FurnitureVendors or {}

local function removeExistingVendorPed(coords, model)
    if not coords then return end
    local modelHash = nil
    if model then
        modelHash = type(model) == "string" and joaat(model) or model
    end
    local pedList = GetGamePool('CPed')
    for i = 1, #pedList do
        local ped = pedList[i]
        if not IsPedAPlayer(ped) then
            local pedCoords = GetEntityCoords(ped)
            if #(pedCoords - coords) < 1.0 then
                if not modelHash or GetEntityModel(ped) == modelHash then
                    SetEntityAsMissionEntity(ped, true, true)
                    DeletePed(ped)
                end
            end
        end
    end
end

local function cleanupFurnitureVendors()
    if ClearVendorPreview then
        ClearVendorPreview()
    end
    if EndCam then
        EndCam()
    end
    for _, blip in pairs(CreatedVendorBlips) do
        if blip then
            if type(blip) == "table" and blip.Remove then
                blip:Remove()
            elseif blip.rawblip then
                RemoveBlip(blip.rawblip)
            else
                RemoveBlip(blip)
            end
        end
    end
    for _, pedWrapper in pairs(CreatedVendorNpcs) do
        if pedWrapper then
            if type(pedWrapper) == "table" and pedWrapper.Remove then
                pedWrapper:Remove()
            elseif type(pedWrapper) == "table" and pedWrapper.GetPed then
                local ped = pedWrapper:GetPed()
                if ped and DoesEntityExist(ped) then
                    DeletePed(ped)
                end
            elseif DoesEntityExist(pedWrapper) then
                DeletePed(pedWrapper)
            end
        end
    end
    CreatedVendorBlips = {}
    CreatedVendorNpcs  = {}
    ActiveFurnitureVendor = nil
    if BCCHousingMenu and BCCHousingMenu.Close then
        BCCHousingMenu:Close()
    end
end

CleanupFurnitureVendors = cleanupFurnitureVendors

CreateThread(function()
    cleanupFurnitureVendors()
    devPrint("Furniture vendors thread started")

    if not furnitureVendors or #furnitureVendors == 0 then
        devPrint("No furniture vendors configured.")
        return
    end

    local vendorPromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local vendorPrompt = vendorPromptGroup:RegisterPrompt(_U('furnitureVendorPrompt'), BccUtils.Keys[Config.keys.buy],
        1, 1, true, 'click', nil)

    for _, vendor in ipairs(furnitureVendors) do
        local coordsList = {}
        if vendor.coords then
            if vendor.coords.x ~= nil then
                coordsList[1] = vector3(vendor.coords.x, vendor.coords.y, vendor.coords.z)
            elseif type(vendor.coords) == "vector3" then
                coordsList[1] = vendor.coords
            elseif type(vendor.coords) == "table" then
                for i, coord in ipairs(vendor.coords) do
                    if coord.x ~= nil then
                        coordsList[i] = vector3(coord.x, coord.y, coord.z)
                    elseif type(coord) == "vector3" then
                        coordsList[i] = coord
                    end
                end
            end
        end
        if #coordsList == 0 then
            devPrint("Furniture vendor missing coordinates")
        end

        local headingList = {}
        if type(vendor.NpcHeading) == "table" then
            for i = 1, #coordsList do
                local headingValue = vendor.NpcHeading[i]
                headingList[i] = headingValue ~= nil and headingValue or (vendor.npc and vendor.npc.heading) or 0.0
            end
        else
            local defaultHeading = (vendor.npc and vendor.npc.heading) or 0.0
            for i = 1, #coordsList do
                headingList[i] = defaultHeading
            end
        end

        for i, coord in ipairs(coordsList) do
            if vendor.blip and (vendor.blip.show == nil or vendor.blip.show) then
                local label = vendor.blip.label or vendor.blip.name or vendor.name or _U('furnitureVendorTitle')
                local blipWrapper = BccUtils.Blips:SetBlip(label, vendor.blip.sprite, vendor.blip.scale or 0.2,
                    coord.x, coord.y, coord.z)
                if blipWrapper then
                    if vendor.blip.color and Config.BlipColors and Config.BlipColors[vendor.blip.color] then
                        local modifier = BccUtils.Blips:AddBlipModifier(blipWrapper, Config.BlipColors[vendor.blip.color])
                        if modifier and modifier.ApplyModifier then
                            modifier:ApplyModifier()
                        end
                    end
                    CreatedVendorBlips[#CreatedVendorBlips + 1] = blipWrapper
                end
            end
        end

        for i, coord in ipairs(coordsList) do
            if vendor.npc and (vendor.npc.show == nil or vendor.npc.show) then
                removeExistingVendorPed(coord, vendor.npc.model)
                local pedWrapper = BccUtils.Ped:Create(
                    vendor.npc.model,
                    coord.x, coord.y, coord.z + (vendor.npc.zOffset or -1.0),
                    headingList[i] or (vendor.npc.heading or 0.0),
                    'world', false, nil, nil, true, nil
                )
                if pedWrapper then
                    pedWrapper:Freeze(true)
                    pedWrapper:SetHeading(headingList[i] or 0.0)
                    pedWrapper:Invincible(true)
                    pedWrapper:CanBeDamaged(false)
                    pedWrapper:SetBlockingOfNonTemporaryEvents(true)
                    if vendor.npc.scenario then
                        TaskStartScenarioInPlaceHash(pedWrapper:GetPed(), GetHashKey(vendor.npc.scenario), 0, true, 0, 0, false)
                    end
                    CreatedVendorNpcs[#CreatedVendorNpcs + 1] = pedWrapper
                end
            end
        end
    end

    while true do
        ::CONTINUE::
        local playerPed = PlayerPedId()
        if IsEntityDead(playerPed) then
            Wait(1000)
            goto CONTINUE
        end

        local playerCoords = GetEntityCoords(playerPed)
        for _, vendor in ipairs(furnitureVendors) do
            local coordsArray = {}
            if vendor.coords then
                if vendor.coords.x ~= nil then
                    coordsArray[1] = vector3(vendor.coords.x, vendor.coords.y, vendor.coords.z)
                elseif type(vendor.coords) == "vector3" then
                    coordsArray[1] = vendor.coords
                elseif type(vendor.coords) == "table" then
                    for i, coord in ipairs(vendor.coords) do
                        if coord.x ~= nil then
                            coordsArray[i] = vector3(coord.x, coord.y, coord.z)
                        elseif type(coord) == "vector3" then
                            coordsArray[i] = coord
                        end
                    end
                end
            end

            for _, coord in ipairs(coordsArray) do
                local distance = #(playerCoords - coord)
                if distance <= (vendor.radius or 2.0) then
                    ActiveFurnitureVendor = vendor
                    vendorPromptGroup:ShowGroup(vendor.name or _U('furnitureVendorTitle'))
                    if vendorPrompt:HasCompleted() then
                        devPrint("Furniture vendor prompt completed")
                        FurnitureVendorMenu()
                    end
                end
            end
        end

        Wait(5)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        cleanupFurnitureVendors()
    end
end)

AddEventHandler("onClientResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        cleanupFurnitureVendors()
    end
end)
