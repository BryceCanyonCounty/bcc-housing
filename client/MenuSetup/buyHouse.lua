-- ensure table exists
PurchasedHouses = PurchasedHouses or {}

CreateThread(function()
    -- Request the purchased houses list from the server when the resource starts
    local success, houses = BccUtils.RPC:CallAsync('bcc-housing:getPurchasedHouses', {})
    if success and type(houses) == 'table' then
        PurchasedHouses = {}
        for _, coords in ipairs(houses) do
            if type(coords) == "table" and coords.x and coords.y and coords.z then
                PurchasedHouses[#PurchasedHouses + 1] = vector3(coords.x, coords.y, coords.z)
            else
                PurchasedHouses[#PurchasedHouses + 1] = coords
            end
        end
    else
        devPrint("Failed to fetch purchased houses via RPC")
    end

    local PromptGroup = BccUtils.Prompt:SetupPromptGroup()
    local BuyHousePrompt = PromptGroup:RegisterPrompt(
        _U("moreInfo"),
        BccUtils.Keys[Config.keys.buy],
        1, 1, true, 'click', nil
    )

    while true do
        Wait(0)

        local playerPed = PlayerPedId()
        if IsEntityDead(playerPed) then goto END end

        local playerCoords = GetEntityCoords(playerPed)

        for _, house in pairs(Houses) do
            local isPurchased = false

            -- Check if the house has been purchased
            for _, purchasedHouse in pairs(PurchasedHouses) do
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

                -- Only create blips if blip.sale.active is true and blip hasn't been created yet
                if house.blip.sale.active and not HouseBlips[house.uniqueName] then
                    local houseSaleBlip = BccUtils.Blips:SetBlip(
                        house.blip.sale.name, house.blip.sale.sprite, 0.2,
                        house.menuCoords.x, house.menuCoords.y, house.menuCoords.z
                    )
                    HouseBlips[house.uniqueName] = houseSaleBlip

                    local blipModifier = BccUtils.Blips:AddBlipModifier(houseSaleBlip,
                        Config.BlipColors[house.blip.sale.color])
                    blipModifier:ApplyModifier()
                end

                if distance < house.menuRadius then
                    local rentalCurrency = house.currencyType
                    if rentalCurrency == nil then
                        rentalCurrency = Config.Setup.DefaultRentalCurrency
                    end
                    rentalCurrency = tonumber(rentalCurrency) or 1
                    if rentalCurrency ~= 0 then
                        rentalCurrency = 1
                    end
                    local promptCurrency = rentalCurrency == 0 and _U('promptCurrencyMoney') or _U('promptCurrencyGold')
                    local promptPrice = tostring(house.price or 0)
                    local promptRent = tostring(house.rentalDeposit or 0)
                    PromptGroup:ShowGroup(_U("buyPricePrompt", promptPrice, promptRent, promptCurrency))
                    if BuyHousePrompt:HasCompleted() then
                        OpenBuyHouseMenu(house)
                    end
                end

                if house.showmarker and distance < 100 then
                    DrawMarker(0x94FDAE17,
                        house.menuCoords.x, house.menuCoords.y, house.menuCoords.z - 1,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        1.0, 1.0, 0.3,
                        0, 128, 0, 155,
                        false, false, false, 0, false, false, false
                    )
                end
            end
        end
        ::END::
    end
end)


BccUtils.RPC:Register('bcc-housing:housePurchased', function(params)
    if not params then return end
    local coords = params.houseCoords or params
    if type(coords) == "table" and coords.x and coords.y and coords.z then
        table.insert(PurchasedHouses, vector3(coords.x, coords.y, coords.z))
    end
end)

BccUtils.RPC:Register('bcc-housing:ReinitializeChecksAfterSale', function()
    local success, houses = BccUtils.RPC:CallAsync('bcc-housing:getPurchasedHouses', {})
    if success and type(houses) == "table" then
        PurchasedHouses = {}
        for _, coords in ipairs(houses) do
            if type(coords) == "table" and coords.x and coords.y and coords.z then
                PurchasedHouses[#PurchasedHouses + 1] = vector3(coords.x, coords.y, coords.z)
            else
                PurchasedHouses[#PurchasedHouses + 1] = coords
            end
        end
    end
end)

function OpenBuyHouseMenu(house)
    if not house then
        devPrint("OpenBuyHouseMenu: missing 'house' param"); return
    end

    devPrint("Opening buy house menu for house with coordinates: " .. tostring(house.houseCoords))

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local price        = tonumber(house.price or 0) or 0
    local sellPrice    = tonumber(house.sellPrice or 0) or 0
    local canSell      = not not house.canSell
    local rentalDep    = tonumber(house.rentalDeposit or 0) or 0
    local rentCharge   = tonumber(house.rentCharge or 0) or 0
    local playerMax    = tonumber(house.playerMax or 1) or 1
    local invLimit     = tonumber(house.invLimit or 0) or 0
    local taxAmount    = tonumber(house.taxAmount or 0) or 0
    local houseName    = house.name or "House"

    local buyHouseMenu = BCCHousingMenu:RegisterPage("bcc-housing:BuyHousePage")
    local rentalCurrency = house.currencyType
    if rentalCurrency == nil then
        rentalCurrency = Config.Setup.DefaultRentalCurrency
    end
    rentalCurrency = tonumber(rentalCurrency) or 1
    if rentalCurrency ~= 0 then
        rentalCurrency = 1
    end
    local currencyWord = rentalCurrency == 0 and _U('currencyMoney') or _U('currencyGold')
    local highlightedCurrencyWord
    if rentalCurrency == 0 then
        highlightedCurrencyWord = '<span style="color:#28A745; font-weight: bold;">' .. currencyWord .. '</span>'
    else
        highlightedCurrencyWord = '<span style="color: gold; font-weight: bold;">' .. currencyWord .. '</span>'
    end
    local currencyAmountColor = rentalCurrency == 0 and '#28A745' or '#DAA520'
    local depositAmountText = rentalCurrency == 0 and ('$' .. tostring(rentalDep)) or (tostring(rentalDep) .. ' ' .. currencyWord)
    local rentChargeAmountText = rentalCurrency == 0 and ('$' .. tostring(rentCharge)) or (tostring(rentCharge) .. ' ' .. currencyWord)
    local rentButtonAmount = depositAmountText

    buyHouseMenu:RegisterElement('header', {
        value = _U("confirmHousePurchase"),
        slot = 'header',
        style = {}
    })

    buyHouseMenu:RegisterElement('subheader', {
        value = houseName,
        slot = "content",
        style = {}
    })

    buyHouseMenu:RegisterElement('line', { style = {}, slot = 'content' })

    local sellLine
    if canSell then
        sellLine =
            '<p style="font-size:18px; margin-bottom: 10px;">' ..
            _U('listSellPrice') .. '$<strong>' .. tostring(sellPrice) .. '</strong></p>'
    else
        sellLine =
            '<p style="font-size:18px; margin-bottom: 10px;">' ..
            _U('listCanSell') .. '<strong>' .. _U('No') .. '</strong></p>'
    end

    local htmlContent =
        '<div style="text-align:center; margin: 20px;">' ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('listBuyPrice') .. '$<strong style="color:#28A745;">' .. tostring(price) .. '</strong></p>' ..
        sellLine ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('rentalDeposit', highlightedCurrencyWord) .. '<strong style="color:' .. currencyAmountColor .. ';">' .. depositAmountText .. '</strong></p>' ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('rentCharge', highlightedCurrencyWord) .. '<strong style="color:' .. currencyAmountColor .. ';">' .. rentChargeAmountText .. '</strong></p>' ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('listRoomateLim') .. '<strong>' .. tostring(playerMax) .. '</strong></p>' ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('listInvLimit') .. '<strong>' .. tostring(invLimit) .. '</strong></p>' ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('listTaxAmount') .. '$<strong style="color:#DC3545;">' .. tostring(taxAmount) .. '</strong></p>' ..
        '</div>'


    buyHouseMenu:RegisterElement("html", {
        value = { htmlContent },
        slot = 'content',
        style = {}
    })

    buyHouseMenu:RegisterElement('line', { style = {}, slot = 'footer' })

    buyHouseMenu:RegisterElement('button', {
        label = _U('buyHouseFor') .. price,
        style = {},
        slot = "footer"
    }, function()
        BCCHousingMenu:Close()
        local success, err = BccUtils.RPC:CallAsync('bcc-housing:buyHouse', {
            houseCoords = house.houseCoords,
            moneyType = 0 -- Cash
        })
        if not success then
            devPrint("House purchase RPC failed: " .. tostring(err and err.error))
        end
    end)

    buyHouseMenu:RegisterElement('button', {
        label = _U('rentHouseFor', rentButtonAmount),
        style = {},
        slot = "footer"
    }, function()
        BCCHousingMenu:Close()
        local success, err = BccUtils.RPC:CallAsync('bcc-housing:buyHouse', {
            houseCoords = house.houseCoords,
            moneyType = 1 -- Rental
        })
        if not success then
            devPrint("House rental RPC failed: " .. tostring(err and err.error))
        end
    end)

    buyHouseMenu:RegisterElement('button', {
        label = _U('cancel'),
        style = { ['position'] = 'relative', ['z-index'] = 9 },
        slot = "footer"
    }, function()
        BCCHousingMenu:Close()
    end)

    buyHouseMenu:RegisterElement('bottomline', { style = {}, slot = "footer" })

    BCCHousingMenu:Open({ startupPage = buyHouseMenu })
end
