-- NPC Real Estate Agents

local AgentPrompt
local AgentGroup = GetRandomIntInRange(0, 0xffffff)

local function StartAgentPrompt()
    AgentPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(AgentPrompt, BccUtils.Keys[Config.keys.collect])
    UiPromptSetText(AgentPrompt, CreateVarString(10, 'LITERAL_STRING', _U("collectFromDealer")))
    UiPromptSetEnabled(AgentPrompt, true)
    UiPromptSetVisible(AgentPrompt, true)
    UiPromptSetHoldMode(AgentPrompt, 2000)
    UiPromptSetGroup(AgentPrompt, AgentGroup, 0)
    UiPromptRegisterEnd(AgentPrompt)
end

local function ManageShopBlips(shop, closed)
    local shopCfg = Agents[shop]

    if (closed and not shopCfg.blip.show.closed) or (not shopCfg.blip.show.open) then
        if Agents[shop].Blip then
            RemoveBlip(Agents[shop].Blip)
            Agents[shop].Blip = nil
        end
        return
    end

    if not Agents[shop].Blip then
        shopCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, shopCfg.npc.coords) -- BlipAddForCoords
        SetBlipSprite(shopCfg.Blip, shopCfg.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, shopCfg.Blip, shopCfg.blip.name) -- SetBlipNameFromPlayerString
    end

    local color = shopCfg.blip.color.open
    if shopCfg.shop.jobsEnabled then color = shopCfg.blip.color.job end
    if closed then color = shopCfg.blip.color.closed end
    Citizen.InvokeNative(0x662D364ABF16DE2F, Agents[shop].Blip, joaat(Config.BlipColors[color])) -- BlipAddModifier
end

local function AddShopNpcs(shop)
    local shopCfg = Agents[shop]

    if not shopCfg.NPC then
        local modelName = shopCfg.npc.model
        local model = joaat(modelName)

        LoadModel(model, modelName)

        shopCfg.NPC = CreatePed(model, shopCfg.npc.coords.x, shopCfg.npc.coords.y, shopCfg.npc.coords.z -1, shopCfg.npc.heading, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, shopCfg.NPC, true) -- SetRandomOutfitVariation
        SetEntityCanBeDamaged(shopCfg.NPC, false)
        SetEntityInvincible(shopCfg.NPC, true)
        Wait(500)
        FreezeEntityPosition(shopCfg.NPC, true)
        SetBlockingOfNonTemporaryEvents(shopCfg.NPC, true)
    end
end

local function RemoveShopNpcs(shop)
    local shopCfg = Agents[shop]

    if shopCfg.NPC then
        DeleteEntity(shopCfg.NPC)
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
            local shopClosed = (shopCfg.shop.hours.active and hour >= shopCfg.shop.hours.close) or (shopCfg.shop.hours.active and hour < shopCfg.shop.hours.open)

            if shopClosed then
                ManageShopBlips(shop, true)
                RemoveShopNpcs(shop)

                if distance <= shopCfg.shop.distance then
                    sleep = 0
                    UiPromptSetActiveGroupThisFrame(AgentGroup, CreateVarString(10, 'LITERAL_STRING', shopCfg.shop.name .. ' ' .. _U('hours') .. ' ' ..
                    shopCfg.shop.hours.open .. _U('hundred') .. ' ' .. _U('to') .. ' ' .. shopCfg.shop.hours.close .. _U('hundred')))
                    UiPromptSetEnabled(AgentPrompt, false)
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
                    UiPromptSetActiveGroupThisFrame(AgentGroup, CreateVarString(10, 'LITERAL_STRING', shopCfg.shop.prompt))
                    UiPromptSetEnabled(AgentPrompt, true)
                    if UiPromptHasHoldModeCompleted(AgentPrompt) then
                        Wait(500) -- ensures it is not triggered multiple times
                        if shopCfg.shop.jobsEnabled then
                            local hasJob = BccUtils.RPC:CallAsync('bcc-housing:CheckJob', { location = shop })
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
        ::END::
        Wait(sleep)
    end
end)


function OpenCollectMoneyMenu()
    DBG:Error("Opening collect money menu")

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