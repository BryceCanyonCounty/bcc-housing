local vendorPrompts = {}
local CreatedVendorBlips = {}
local CreatedVendorNpcs  = {}

CreateThread(function()
    if Config.FurnitureVendors and #Config.FurnitureVendors > 0 then
        for _, vendor in ipairs(Config.FurnitureVendors) do
            if vendor.coords then
                local coords = vendor.coords
                if type(coords) == "table" then
                    coords = vector3(coords.x, coords.y, coords.z)
                end

                -- Prompt group & key
                local promptGroup = BccUtils.Prompts:SetupPromptGroup()
                local keyName     = vendor.key or Config.keys.buy or "G"
                local keyControl  = BccUtils.Keys[keyName] or BccUtils.Keys["G"]
                local prompt      = promptGroup:RegisterPrompt(_U("furnitureVendorPrompt"), keyControl, 1, 1, true, "hold", { timedeventhash = "MEDIUM_TIMED_EVENT" })

                -- Create blip (inline)
                local blipWrapper = nil
                if vendor.blip then
                    local blipCfg = vendor.blip
                    blipWrapper = BccUtils.Blips:SetBlip( blipCfg.name, blipCfg.sprite, blipCfg.scale, coords.x, coords.y, coords.z )
                    if blipWrapper and blipCfg.color and Config.BlipColors[blipCfg.color] then
                        local modifier = BccUtils.Blips:AddBlipModifier(blipWrapper, Config.BlipColors[blipCfg.color])
                        modifier:ApplyModifier()
                    end
                    if blipWrapper then
                        CreatedVendorBlips[#CreatedVendorBlips + 1] = blipWrapper
                    end
                end

                -- Create NPC (inline)
                local npcWrapper = nil
                if vendor.npc then
                    local npcCfg   = vendor.npc
                    local model    = npcCfg.model
                    local zOffset  = npcCfg.zOffset or -1.0
                    local heading  = npcCfg.heading or 0.0

                    npcWrapper = BccUtils.Ped:Create(
                        model, coords.x, coords.y, coords.z + zOffset, heading,
                        "world", false, nil, nil, true, nil
                    )

                    if npcWrapper then
                        local ped = npcWrapper:GetPed()
                        npcWrapper:Freeze(true)
                        npcWrapper:Invincible(true)
                        npcWrapper:CanBeDamaged(false)
                        npcWrapper:SetHeading(heading)
                        npcWrapper:SetBlockingOfNonTemporaryEvents(true)

                        if npcCfg.scenario then
                            TaskStartScenarioInPlaceHash(ped, GetHashKey(npcCfg.scenario), 0, true, 0, 0, false)
                        end

                        CreatedVendorNpcs[#CreatedVendorNpcs + 1] = npcWrapper
                    end
                end

                vendorPrompts[#vendorPrompts + 1] = {
                    config = vendor,
                    coords = coords,
                    group  = promptGroup,
                    prompt = prompt,
                    blip   = blipWrapper,
                    npc    = npcWrapper
                }
            end
        end
    end

    if #vendorPrompts == 0 then return end

    -- Main loop
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, vendorData in ipairs(vendorPrompts) do
            local vendorCfg = vendorData.config
            local coords    = vendorData.coords or vendorCfg.coords
            local distance  = #(playerCoords - coords)

            if distance <= (vendorCfg.radius or 2.0) then
                sleep = 0
                vendorData.group:ShowGroup(vendorCfg.name or _U("furnitureVendorTitle"))
                if vendorData.prompt:HasCompleted() then
                    local previewCfg    = vendorCfg.preview or {}
                    local previewHeading = previewCfg.heading
                        or vendorCfg.previewHeading
                        or (vendorCfg.npc and vendorCfg.npc.heading)
                        or 0.0
                    FurnitureVendorMenu()
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for _, v in pairs(CreatedVendorBlips) do
            v:Remove()
        end
        for _, v in pairs(CreatedVendorNpcs) do
            v:Remove()
        end
        BCCHousingMenu:Close()
    end
end)