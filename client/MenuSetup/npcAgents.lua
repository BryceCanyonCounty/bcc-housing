local AgentPrompt
local AgentPromptGroupObj

local function StartAgentPrompt()
    AgentPromptGroupObj = BccUtils.Prompts:SetupPromptGroup()
    AgentPrompt = AgentPromptGroupObj:RegisterPrompt(
        _U("collectFromDealer"),
        BccUtils.Keys[Config.keys.collect],
        1,
        1,
        true,
        'customhold',
        {
            holdtime = 2000,
            tabIndex = 0
        }
    )
    if AgentPrompt and AgentPrompt.SetGroup then
        AgentPrompt:SetGroup(AgentPromptGroupObj.PromptGroup, 0)
    end
end

local function ManageShopBlips(shop, closed)
    local shopCfg = Agents[shop]

    if (closed and not shopCfg.blip.show.closed) or (not shopCfg.blip.show.open) then
        if Agents[shop].Blip then
            Agents[shop].Blip:Remove()
            Agents[shop].Blip = nil
        end
        return
    end

    if not Agents[shop].Blip then
        local coords = shopCfg.npc.coords

        Agents[shop].Blip = BccUtils.Blip:SetBlip(
            shopCfg.blip.name,
            shopCfg.blip.sprite,
            shopCfg.blip.scale or 0.2,
            coords.x,
            coords.y,
            coords.z
        )
    end

    local color = shopCfg.blip.color.open
    if shopCfg.shop.jobsEnabled then
        color = shopCfg.blip.color.job
    end
    if closed then
        color = shopCfg.blip.color.closed
    end

    local colorModifier = Config.BlipColors[color]
    if colorModifier and Agents[shop].Blip then
        local modifier = BccUtils.Blip:AddBlipModifier(Agents[shop].Blip, colorModifier)
        modifier:ApplyModifier()
    end
end

local function AddShopNpcs(shop)
    local shopCfg = Agents[shop]

    if not shopCfg.NPC then
        local coords = shopCfg.npc.coords
        local model = shopCfg.npc.model
        local heading = shopCfg.npc.heading

        -- Use BccUtils.Ped (PedAPI) to create the NPC
        shopCfg.NPC = BccUtils.Ped:Create(
            model,               -- modelhash (string or hash)
            coords.x,
            coords.y,
            coords.z,            -- PedAPI will place on ground
            heading,
            'world',             -- location
            true,                -- safeground
            nil,                 -- options
            shopCfg.npc.outfit,  -- optional outfit (can be nil)
            false                -- networked
            -- vector4 not needed
        )

        -- Extra flags like in your original code
        shopCfg.NPC:CanBeDamaged(false)
        shopCfg.NPC:Invincible(true)
        Wait(500)
        shopCfg.NPC:Freeze(true)
        shopCfg.NPC:SetBlockingOfNonTemporaryEvents(true)
    end
end

local function RemoveShopNpcs(shop)
    local shopCfg = Agents[shop]

    if shopCfg.NPC then
        shopCfg.NPC:Remove()
        shopCfg.NPC = nil
    end
end

CreateThread(function()
    StartAgentPrompt()

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000
        local hour = GetClockHours()

        if IsEntityDead(playerPed) then goto END end

        for shop, shopCfg in pairs(Agents) do
            local distance = #(playerCoords - shopCfg.npc.coords)
            local shopClosed = (shopCfg.shop.hours.active and hour >= shopCfg.shop.hours.close)
                or (shopCfg.shop.hours.active and hour < shopCfg.shop.hours.open)

            if shopClosed then
                ManageShopBlips(shop, true)
                RemoveShopNpcs(shop)

                if distance <= shopCfg.shop.distance then
                    sleep = 0

                    -- Show "closed / hours" text, disable prompt
                    if AgentPromptGroupObj then
                        AgentPromptGroupObj:ShowGroup(
                            shopCfg.shop.name ..
                            ' ' .. _U('hours') .. ' ' ..
                            shopCfg.shop.hours.open .. _U('hundred') ..
                            ' ' .. _U('to') .. ' ' ..
                            shopCfg.shop.hours.close .. _U('hundred'),
                            1, 0, 0, 0
                        )
                    end

                    if AgentPrompt then
                        AgentPrompt:EnabledPrompt(false)
                        AgentPrompt:TogglePrompt(false)
                    end
                end
            else
                ManageShopBlips(shop, false)

                if distance <= shopCfg.npc.distance then
                    if shopCfg.npc.active then
                        AddShopNpcs(shop)
                    end
                else
                    RemoveShopNpcs(shop)
                end

                if distance <= shopCfg.shop.distance then
                    sleep = 0

                    -- Show "open" prompt text, enable prompt
                    if AgentPromptGroupObj then
                        AgentPromptGroupObj:ShowGroup(shopCfg.shop.prompt, 1, 0, 0, 0)
                    end

                    if AgentPrompt then
                        AgentPrompt:EnabledPrompt(true)
                        AgentPrompt:TogglePrompt(true)

                        if AgentPrompt:HasCompleted(true) then
                            Wait(500) -- ensures it is not triggered multiple times

                            if shopCfg.shop.jobsEnabled then
                                local hasJob = BccUtils.RPC:CallAsync(
                                    'bcc-housing:CheckJob',
                                    { location = shop }
                                )
                                if not hasJob then
                                    Notify(_U('needJob'), "error", 4000)
                                    goto END
                                end
                            end

                            OpenCollectMoneyMenu()
                        end
                    end
                end
            end
        end

        ::END::
        Wait(sleep)
    end
end)

function OpenCollectMoneyMenu()
    DBG:Info("Opening collect money menu")

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local soldHouses = BccUtils.RPC:CallAsync('bcc-housing:RequestSoldHouses')
    if soldHouses == false then return end

    local collectMoneyMenu = BCCHousingMenu:RegisterPage("bcc-housing:CollectMoneyPage")

    collectMoneyMenu:RegisterElement('header', {
        value = _U("houseSaleMoney"),
        slot = 'header',
        style = {}
    })

    collectMoneyMenu:RegisterElement('line', { style = {} })

    if #soldHouses > 0 then
        for _, house in ipairs(soldHouses) do
            collectMoneyMenu:RegisterElement('textdisplay', {
                value = string.format(
                    "%s%d%s$%d",
                    _U("houseId"),
                    house.houseId,
                    _U("soldFor"),
                    house.amount
                ),
                slot = 'content',
                style = {}
            })
        end
    else
        collectMoneyMenu:RegisterElement('textdisplay', {
            value = _U("noHouseSold"),
            slot = 'content',
            style = {}
        })
    end

    collectMoneyMenu:RegisterElement('line', {
        style = {},
        slot = "footer"
    })

    collectMoneyMenu:RegisterElement('button', {
        label = _U("collectMoney"),
        style = {},
        slot = "footer"
    }, function()
        local success, response = BccUtils.RPC:CallAsync('bcc-housing:collectHouseSaleMoneyFromNpc', {})
        if not success then
            DBG:Error("Failed to collect house sale money: " .. tostring(response and response.error))
        end
        BCCHousingMenu:Close()
    end)

    collectMoneyMenu:RegisterElement('button', {
        label = _U("issuePropertyDocument"),
        style = {},
        slot = "footer"
    }, function()
        OpenIssuePropertyDocumentMenu()
    end)

    collectMoneyMenu:RegisterElement('button', {
        label = _U("backButton"),
        style = {},
        slot = "footer"
    }, function()
        BCCHousingMenu:Close()
    end)

    collectMoneyMenu:RegisterElement('bottomline', {
        style = {},
        slot = "footer"
    })

    BCCHousingMenu:Open({ startupPage = collectMoneyMenu })
end

function OpenIssuePropertyDocumentMenu()
    local success, houses = BccUtils.RPC:CallAsync('bcc-housing:GetOwnedPropertyDocuments', {})
    if not success then
        DBG:Error("Failed to fetch owned property documents: " .. tostring(houses and houses.error))
        return
    end

    local documentMenu = BCCHousingMenu:RegisterPage("bcc-housing:IssuePropertyDocumentPage")

    documentMenu:RegisterElement('header', {
        value = _U("propertyDocuments"),
        slot = 'header',
        style = {}
    })

    documentMenu:RegisterElement('line', { style = {} })

    if #houses > 0 then
        for _, house in ipairs(houses) do
            local status = house.hasDocument and _U("propertyDocumentExists") or _U("propertyDocumentMissing")
            documentMenu:RegisterElement('button', {
                label = _U(
                    "propertyDocumentListLabel",
                    house.name or _U("propertyDefaultHouseName"),
                    tostring(house.houseId),
                    status
                ),
                style = {},
                slot = "content"
            }, function()
                local issued, response = BccUtils.RPC:CallAsync('bcc-housing:IssuePropertyDocument', {
                    houseId = house.houseId
                })
                if not issued then
                    DBG:Error("Failed to issue property document: " .. tostring(response and response.error))
                    return
                end
                BCCHousingMenu:Close()
            end)
        end
    else
        documentMenu:RegisterElement('textdisplay', {
            value = _U("noOwnedProperties"),
            slot = 'content',
            style = {}
        })
    end

    documentMenu:RegisterElement('line', {
        style = {},
        slot = "footer"
    })

    documentMenu:RegisterElement('button', {
        label = _U("backButton"),
        style = {},
        slot = "footer"
    }, function()
        OpenCollectMoneyMenu()
    end)

    documentMenu:RegisterElement('bottomline', {
        style = {},
        slot = "footer"
    })

    documentMenu:RouteTo()
end

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if AgentPrompt and AgentPrompt.DeletePrompt then
        AgentPrompt:DeletePrompt()
        AgentPrompt = nil
    end
    AgentPromptGroupObj = nil

    -- Remove all shop NPCs
    for shop, shopCfg in pairs(Agents) do
        if shopCfg.NPC then
            shopCfg.NPC:Remove()
            shopCfg.NPC = nil
        end

        -- Remove all shop blips
        if shopCfg.Blip then
            shopCfg.Blip:Remove()
            shopCfg.Blip = nil
        end
    end

    print("^3[NPC-AGENTS] Cleaned NPCs & Blips on resource stop.^0")
end)
