local purchasedHouses = {}

Citizen.CreateThread(function()
    local HouseDealerPrompt = BccUtils.Prompts:SetupPromptGroup()
    local collectMoneyPrompt = HouseDealerPrompt:RegisterPrompt(_U("collectFromDealer"), BccUtils.Keys[Config.keys.collect], 1, 1, true, 'hold', { timedeventhash = 'MEDIUM_TIMED_EVENT' })

    for _, dealer in pairs(Config.houseDealer) do
        if dealer.CreateNPC then
            dealerPed = BccUtils.Ped:Create('A_M_O_SDUpperClass_01', dealer.NpcCoords.x, dealer.NpcCoords.y, dealer.NpcCoords.z - 1, 0, 'world', false)
            dealerPed:Freeze()
            dealerPed:SetHeading(dealer.NpcHeading)
            dealerPed:Invincible()

            if dealer.BlipName and dealer.BlipSprite then
                local dealerBlip = BccUtils.Blips:SetBlip(dealer.BlipName, dealer.BlipSprite, 5.0, dealer.NpcCoords.x, dealer.NpcCoords.y, dealer.NpcCoords.z)
            end
        end
    end

    while true do
        Wait(1)
        local playerPed = PlayerPedId()

        if IsEntityDead(playerPed) then goto END end
        for _, dealer in pairs(Config.houseDealer) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = #(playerCoords - dealer.NpcCoords)
            if dist < 3 then
                HouseDealerPrompt:ShowGroup(_U("houseDealer"))

                if collectMoneyPrompt:HasCompleted() then
                    -- Open the menu to collect money
                    TriggerEvent('bcc-housing:openCollectMoneyMenu')
                    break
                end
            end
        end
        ::END::
    end
end)

CreateThread(function()
    -- Request the purchased houses list from the server when the resource starts
    TriggerServerEvent('bcc-housing:getPurchasedHouses')
    local PromptGroup = BccUtils.Prompt:SetupPromptGroup()
    local BuyHousePrompt = PromptGroup:RegisterPrompt("More Info", BccUtils.Keys[Config.keys.buy], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })                                                                                                               -- Register your first prompt

    while true do
        Wait(0) -- Run the loop continuously

        local playerCoords = GetEntityCoords(PlayerPedId())
        local playerPed = PlayerPedId()

        if IsEntityDead(playerPed) then goto END end
        
        for _, house in pairs(Houses) do
            local isPurchased = false

            -- Check if the house has been purchased
            for _, purchasedHouse in pairs(purchasedHouses) do
                if #(house.houseCoords - purchasedHouse) < 0.1 then
                    isPurchased = true
                    break
                end
            end

            -- If the house is purchased and blip exists, remove it
            if isPurchased and HouseBlips[house.uniqueName] then
                BccUtils.Blips:RemoveBlip(HouseBlips[house.uniqueName].rawblip)
                HouseBlips[house.uniqueName] = nil
            elseif not isPurchased then
                local distance = GetDistanceBetweenCoords(playerCoords, house.menuCoords, true)

                -- Only create blips if forSaleBlips is true and blip hasn't been created yet
                if house.forSaleBlips and not HouseBlips[house.uniqueName] then
                    local houseSaleBlip = BccUtils.Blips:SetBlip(house.blipname, house.saleBlipSprite, 0.2, house.menuCoords.x, house.menuCoords.y, house.menuCoords.z)
                    
                    HouseBlips[house.uniqueName] = houseSaleBlip
                    
                    local blipModifier = BccUtils.Blips:AddBlipModifier(houseSaleBlip, Config.BlipColors[house.saleBlipModifier])
                    blipModifier:ApplyModifier()
                end

                if distance < house.menuRadius then
                    PromptGroup:ShowGroup(_U("buyPricePrompt", house.price, house.rentalDeposit))
                    if BuyHousePrompt:HasCompleted() then
                        TriggerEvent('bcc-housing:openBuyHouseMenu', house)
                    end
                end
                if house.showmarker and distance < 100 then
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, house.menuCoords.x, house.menuCoords.y, house.menuCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.3, 0, 128, 0, 155, false, false, false, 0, false, false, false)
                end
            end
        end
        ::END::
    end
end)

RegisterNetEvent('bcc-housing:sendPurchasedHouses')
AddEventHandler('bcc-housing:sendPurchasedHouses', function(houses)
    purchasedHouses = houses
end)

RegisterNetEvent('bcc-housing:housePurchased')
AddEventHandler('bcc-housing:housePurchased', function(houseCoords)
    table.insert(purchasedHouses, houseCoords)
end)

RegisterNetEvent('bcc-housing:ReinitializeChecksAfterSale')
AddEventHandler('bcc-housing:ReinitializeChecksAfterSale', function()
    -- Reinitialize the house purchase list
    TriggerServerEvent('bcc-housing:getPurchasedHouses')
end)

AddEventHandler('bcc-housing:openCollectMoneyMenu', function()
    devPrint("Opening collect money menu")

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    -- Request the list of sold houses from the server
    TriggerServerEvent('bcc-housing:requestSoldHouses')

    -- Listen for the response from the server with the sold houses
    RegisterNetEvent('bcc-housing:receiveSoldHouses')
    AddEventHandler('bcc-housing:receiveSoldHouses', function(soldHouses)
        local collectMoneyMenu = BCCHousingMenu:RegisterPage("bcc-housing:CollectMoneyPage")

        collectMoneyMenu:RegisterElement('header', {
            value = _U("houseSaleMoney"),
            slot = 'header',
            style = {}
        })

        collectMoneyMenu:RegisterElement('line', {
            style = {}
        })

        if #soldHouses > 0 then
            for _, house in ipairs(soldHouses) do
                collectMoneyMenu:RegisterElement('textdisplay', {
                    value = string.format(_U("houseId") .. "%d" .. _U("soldFor") .. "$%d", house.houseId, house.amount),
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
            TriggerServerEvent('bcc-housing:collectHouseSaleMoneyFromNpc')
            BCCHousingMenu:Close()
        end)

        collectMoneyMenu:RegisterElement('button', {
            label = _U("backButton"),
            style = {['position'] = 'relative', ['z-index'] = 9,},
            slot = "footer"
        }, function()
            BCCHousingMenu:Close()
        end)

        collectMoneyMenu:RegisterElement('bottomline', {
            style = {},
            slot = "footer"
        })

        BCCHousingMenu:Open({ startupPage = collectMoneyMenu })
    end)
end)

AddEventHandler('bcc-housing:openBuyHouseMenu', function(house)
    devPrint("Opening buy house menu for house with coordinates: " .. tostring(house.houseCoords))

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    local buyHouseMenu = BCCHousingMenu:RegisterPage("bcc-housing:BuyHousePage")

    buyHouseMenu:RegisterElement('header', {
        value = _U("confirmHousePurchase"),
        slot = 'header',
        style = {}
    })

    buyHouseMenu:RegisterElement('subheader', {
        value = house.name,
        slot = "content",
        style = {}
    })

    buyHouseMenu:RegisterElement('line', {
        style = {},
        slot = 'content',
    })

    local htmlContent = [[
        <div style="text-align:center; margin: 20px;">]] ..
            [[<p style="font-size:18px; margin-bottom: 10px;">]] .. _U('listBuyPrice')   .. [[$<strong style="color:#28A745;">]] .. tonumber(house.price or 0) .. [[</strong>]] .. [[</p>]] ..
            (house.canSell and
            ([[<p style="font-size:18px; margin-bottom: 10px;">]] .. _U('listSellPrice')  .. [[$<strong>]] .. tonumber(house.sellPrice or 0) .. [[</strong>]] .. [[</p>]]) or -- <strong style="color:#17A2B8;">$%d</strong></p>
            ([[<p style="font-size:18px; margin-bottom: 10px;">]] .. _U('listCanSell')    .. [[<strong>]] .. tostring(house.canSell and _U('Yes') or _U('No')) .. [[</strong>]] .. [[</p>]])) .. -- [[<strong style="color:#FFC107;">]] .. [[</strong></p>]] ..
            [[<p style="font-size:18px; margin-bottom: 10px;">]] .. _U('rentalDeposit')  .. [[<strong>]] .. tonumber(house.rentalDeposit) .. [[</strong>]] .. [[</p>]] ..
            [[<p style="font-size:18px; margin-bottom: 10px;">]] .. _U('rentCharge')     .. [[<strong>]] .. tonumber(house.rentCharge) .. [[</strong>]] .. [[</p>]] ..
            [[<p style="font-size:18px; margin-bottom: 10px;">]] .. _U('listRoomateLim') .. [[<strong>]] .. tonumber(house.playerMax or 1) .. [[</strong>]] .. [[</p>]] ..
            [[<p style="font-size:18px; margin-bottom: 10px;">]] .. _U('listInvLimit')   .. [[<strong>]] .. tonumber(house.invLimit or 0) .. [[</strong>]] .. [[</p>]] ..
            [[<p style="font-size:18px; margin-bottom: 10px;">]] .. _U('listTaxAmount')  .. [[$<strong style="color:#DC3545;">]] .. tonumber(house.taxAmount or 0) .. [[</strong>]] .. [[</p>]] .. [[
        </div>
    ]]


    buyHouseMenu:RegisterElement("html", {
        value = { htmlContent },
        slot = 'content',
        style = {}
    })

    buyHouseMenu:RegisterElement('line', {
        style = {},
        slot = 'footer',
    })

    buyHouseMenu:RegisterElement('button', {
        label = _U('buyHouseFor') .. house.price,
        style = {},
        slot = "footer"
    }, function()
        local moneyType = 0 -- Cash
        TriggerServerEvent('bcc-housing:buyHouse', house.houseCoords, moneyType)
        BCCHousingMenu:Close()
    end)

    buyHouseMenu:RegisterElement('button', {
        label = _U('buyGoldHouseFor', house.rentalDeposit),
        style = {},
        slot = "footer"
    }, function()
        local moneyType = 1 -- Gold
        TriggerServerEvent('bcc-housing:buyHouse', house.houseCoords, moneyType)
        BCCHousingMenu:Close()
    end)

    buyHouseMenu:RegisterElement('button', {
        label = _U('cancel'),
        style = {['position'] = 'relative', ['z-index'] = 9,},
        slot = "footer"
    }, function()
        BCCHousingMenu:Close()
    end)

    buyHouseMenu:RegisterElement('bottomline', {
        style = {},
        slot = "footer"
    })

    BCCHousingMenu:Open({ startupPage = buyHouseMenu })
end)
