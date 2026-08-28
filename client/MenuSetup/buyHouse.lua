PurchasedHouses = PurchasedHouses or {}
SuppressHousePreviewStopOnMenuClose = false
local purchasedHouseLookup = {}
local houseSaleBlipsDirty = true
local housePreviewState = {
    active = false,
    house = nil,
    zone = nil
}
local housePreviewPromptGroup
local housePreviewClosePrompt
local HOUSE_PREVIEW_GROUND_VISUAL_OFFSET = 0.12

local function houseCoordsKey(coords)
    if not coords then return nil end

    local x = math.floor((tonumber(coords.x) or 0.0) * 100 + 0.5)
    local y = math.floor((tonumber(coords.y) or 0.0) * 100 + 0.5)
    local z = math.floor((tonumber(coords.z) or 0.0) * 100 + 0.5)

    return x .. ':' .. y .. ':' .. z
end

local function rebuildPurchasedHouseLookup()
    purchasedHouseLookup = {}
    for _, coords in ipairs(PurchasedHouses) do
        local key = houseCoordsKey(coords)
        if key then
            purchasedHouseLookup[key] = true
        end
    end
    houseSaleBlipsDirty = true
end

local function isHousePurchased(house)
    local key = houseCoordsKey(house and house.houseCoords)
    return key and purchasedHouseLookup[key] == true
end

local function refreshHouseSaleBlips()
    if not houseSaleBlipsDirty then return end

    for _, house in pairs(Houses) do
        local isPurchased = isHousePurchased(house)
        local existingBlip = HouseBlips[house.uniqueName]

        if isPurchased and existingBlip then
            BccUtils.Blips:RemoveBlip(existingBlip.rawblip)
            HouseBlips[house.uniqueName] = nil
        elseif not isPurchased and house.blip.sale.active and not existingBlip then
            local houseSaleBlip = BccUtils.Blips:SetBlip(
                house.blip.sale.name, house.blip.sale.sprite, 0.2,
                house.menuCoords.x, house.menuCoords.y, house.menuCoords.z
            )
            HouseBlips[house.uniqueName] = houseSaleBlip

            local blipModifier = BccUtils.Blips:AddBlipModifier(
                houseSaleBlip,
                Config.BlipColors[house.blip.sale.color]
            )
            blipModifier:ApplyModifier()
        end
    end

    houseSaleBlipsDirty = false
end

local function normalizeHouseCurrencyType(rawCurrency, isRental)
    local currencyType = tonumber(rawCurrency)
    if currencyType == nil then
        currencyType = isRental and tonumber(Config.Setup.DefaultRentalCurrency) or 0
    end
    if currencyType ~= 0 and currencyType ~= 1 and currencyType ~= 2 then
        currencyType = 0
    end
    return currencyType
end

local function getCurrencyWord(currencyType)
    if currencyType == 1 then
        return _U('currencyGold')
    elseif currencyType == 2 then
        return _U('currencyRol')
    end
    return _U('currencyMoney')
end

local function getPromptCurrency(currencyType)
    if currencyType == 1 then
        return _U('promptCurrencyGold')
    elseif currencyType == 2 then
        return _U('promptCurrencyRol')
    end
    return _U('promptCurrencyMoney')
end

local function formatCurrencyAmount(currencyType, amount)
    local numericAmount = tonumber(amount or 0) or 0
    if currencyType == 0 then
        return '$' .. tostring(numericAmount)
    end
    return tostring(numericAmount) .. ' ' .. getCurrencyWord(currencyType)
end

local function isHouseRentalEnabled(house)
    if house == nil or house.allowRental == nil then
        return true
    end
    return house.allowRental == true
end

local function getPreviewCenter(house)
    if not house then
        return nil
    end

    if house.houseCoords then
        return house.houseCoords
    end

    return house.menuCoords
end

local function ensureHousePreviewPrompt()
    if housePreviewPromptGroup then
        return
    end

    housePreviewPromptGroup = BccUtils.Prompt:SetupPromptGroup()
    housePreviewClosePrompt = housePreviewPromptGroup:RegisterPrompt(
        _U("closePropertyPreview"),
        BccUtils.Keys[Config.keys.cancel],
        1, 1, true, 'click', nil
    )
end

function stopHouseAreaPreview()
    if housePreviewState.zone and housePreviewState.zone.destroy then
        housePreviewState.zone:destroy()
    end
    housePreviewState.zone = nil
    housePreviewState.active = false
    housePreviewState.house = nil
end

function StartHouseAreaPreview(house)
    stopHouseAreaPreview()
    ensureHousePreviewPrompt()
    housePreviewState.house = house
    if house and type(house.polyPoints) == 'table' and #house.polyPoints >= 3 then
        local vectors = {}
        for _, point in ipairs(house.polyPoints) do
            vectors[#vectors + 1] = vector2(point.x, point.y)
        end

        housePreviewState.zone = PolyZone:Create(vectors, {
            name = 'bcc-housing-house-preview',
            debugPoly = true,
            minZ = tonumber(house.polyMinZ),
            maxZ = tonumber(house.polyMaxZ),
            debugColors = {
                walls = { 30, 150, 255 },
                outline = { 30, 150, 255 }
            }
        })
    end
    housePreviewState.active = true
end

local function drawRadiusPreview(house)
    local center = getPreviewCenter(house)
    local radius = tonumber(house and house.houseRadiusLimit) or 0.0
    if not center or radius <= 0 then
        return
    end

    local floorZ = tonumber(house and house.polyMinZ) or center.z
    local maxZ = tonumber(house and house.polyMaxZ) or (floorZ + 4.0)
    local height = math.max(0.2, maxZ - floorZ)

    DrawMarker(
        0x6903B113,
        center.x, center.y, floorZ + (height * 0.5),
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        radius * 2.0, radius * 2.0, height,
        30, 150, 255, 80,
        false, false, 2, 0, false, false, false
    )
end

local function drawPolyPreview(house)
    if not house or type(house.polyPoints) ~= 'table' or #house.polyPoints < 3 then
        return false
    end

    local floorZ = tonumber(house.polyMinZ) or (house.houseCoords and house.houseCoords.z) or 0.0
    for index, point in ipairs(house.polyPoints) do
        local pointFloorZ = tonumber(point.z) or floorZ
        DrawMarker(
            2,
            point.x, point.y, pointFloorZ + HOUSE_PREVIEW_GROUND_VISUAL_OFFSET,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.14, 0.14, 0.14,
            30, 150, 255, 170,
            false, true, 2, false, nil, nil, false
        )

        if index > 1 then
            local prevPoint = house.polyPoints[index - 1]
            local prevFloorZ = tonumber(prevPoint.z) or floorZ
            DrawLine(
                prevPoint.x, prevPoint.y, prevFloorZ + HOUSE_PREVIEW_GROUND_VISUAL_OFFSET,
                point.x, point.y, pointFloorZ + HOUSE_PREVIEW_GROUND_VISUAL_OFFSET,
                30, 150, 255, 220
            )
        end
    end

    if #house.polyPoints > 2 then
        local firstPoint = house.polyPoints[1]
        local lastPoint = house.polyPoints[#house.polyPoints]
        local firstFloorZ = tonumber(firstPoint.z) or floorZ
        local lastFloorZ = tonumber(lastPoint.z) or floorZ
        DrawLine(
            lastPoint.x, lastPoint.y, lastFloorZ + HOUSE_PREVIEW_GROUND_VISUAL_OFFSET,
            firstPoint.x, firstPoint.y, firstFloorZ + HOUSE_PREVIEW_GROUND_VISUAL_OFFSET,
            30, 150, 255, 120
        )
    end

    return true
end

CreateThread(function()
    while true do
        if housePreviewState.active and housePreviewState.house then
            Wait(0)
            if not drawPolyPreview(housePreviewState.house) then
                drawRadiusPreview(housePreviewState.house)
            end
            if housePreviewPromptGroup and housePreviewClosePrompt then
                housePreviewPromptGroup:ShowGroup(_U("propertyPreviewActive"))
                if housePreviewClosePrompt:HasCompleted() then
                    stopHouseAreaPreview()
                end
            end
        else
            Wait(300)
        end
    end
end)

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
        DBG:Error("Failed to fetch purchased houses via RPC")
    end
    rebuildPurchasedHouseLookup()

    local PromptGroup = BccUtils.Prompt:SetupPromptGroup()
    local BuyHousePrompt = PromptGroup:RegisterPrompt(
        _U("moreInfo"),
        BccUtils.Keys[Config.keys.buy],
        1, 1, true, 'click', nil
    )

    while true do
        local playerPed = PlayerPedId()
        local sleep = 1000
        if not IsEntityDead(playerPed) then
            local playerCoords = GetEntityCoords(playerPed)
            refreshHouseSaleBlips()

            for _, house in pairs(Houses) do
                if not isHousePurchased(house) then
                    local distance = GetDistanceBetweenCoords(playerCoords, house.menuCoords, true)

                    if distance < house.menuRadius then
                        sleep = 0
                        local purchaseCurrency = normalizeHouseCurrencyType(house.currencyType, false)
                        local rentalEnabled = isHouseRentalEnabled(house)
                        local rentalCurrency = normalizeHouseCurrencyType(house.currencyType, true)
                        local promptCurrency = getPromptCurrency(rentalCurrency)
                        local promptPrice = tostring(house.price or 0)
                        local promptRent = tostring(house.rentalDeposit or 0)
                        if not rentalEnabled then
                            PromptGroup:ShowGroup(_U("buyPricePromptNoRent", promptPrice, getPromptCurrency(purchaseCurrency)))
                        else
                            if purchaseCurrency ~= rentalCurrency then
                                promptCurrency = getPromptCurrency(purchaseCurrency) .. ' / ' .. getPromptCurrency(rentalCurrency)
                            end
                            PromptGroup:ShowGroup(_U("buyPricePrompt", promptPrice, promptRent, promptCurrency))
                        end
                        if BuyHousePrompt:HasCompleted() then
                            OpenBuyHouseMenu(house)
                        end
                    end

                    if house.showmarker and distance < 100 then
                        sleep = 0
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
        end
        Wait(sleep)
    end
end)


BccUtils.RPC:Register('bcc-housing:housePurchased', function(params)
    if not params then return end
    local coords = params.houseCoords or params
    if type(coords) == "table" and coords.x and coords.y and coords.z then
        table.insert(PurchasedHouses, vector3(coords.x, coords.y, coords.z))
        rebuildPurchasedHouseLookup()
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
        rebuildPurchasedHouseLookup()
    end
end)

function OpenBuyHouseMenu(house)
    if not house then
        DBG:Info("OpenBuyHouseMenu: missing 'house' param"); return
    end

    DBG:Info("Opening buy house menu for house with coordinates: " .. tostring(house.houseCoords))

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local price        = tonumber(house.price or 0) or 0
    local sellPrice    = tonumber(house.sellPrice or 0) or 0
    local purchaseCurrency = normalizeHouseCurrencyType(house.currencyType, false)
    local rentalCurrency = normalizeHouseCurrencyType(house.currencyType, true)
    local rentalEnabled = isHouseRentalEnabled(house)
    local canSell      = not not house.canSell and purchaseCurrency ~= 2
    local rentalDep    = tonumber(house.rentalDeposit or 0) or 0
    local rentCharge   = tonumber(house.rentCharge or 0) or 0
    local playerMax    = tonumber(house.playerMax or 1) or 1
    local invLimit     = tonumber(house.invLimit or 0) or 0
    local taxAmount    = tonumber(house.taxAmount or 0) or 0
    local houseName    = house.name or "House"
    local isAdmin      = BccUtils.RPC:CallAsync('bcc-housing:CheckIfAdmin') == true

    local buyHouseMenu = BCCHousingMenu:RegisterPage("bcc-housing:BuyHousePage")
    local currencyWord = getCurrencyWord(rentalCurrency)
    local highlightedCurrencyWord
    if rentalCurrency == 0 then
        highlightedCurrencyWord = '<span style="color:#28A745; font-weight: bold;">' .. currencyWord .. '</span>'
    elseif rentalCurrency == 1 then
        highlightedCurrencyWord = '<span style="color: gold; font-weight: bold;">' .. currencyWord .. '</span>'
    else
        highlightedCurrencyWord = '<span style="color:#6ec1ff; font-weight: bold;">' .. currencyWord .. '</span>'
    end
    local currencyAmountColor = rentalCurrency == 0 and '#28A745' or (rentalCurrency == 1 and '#DAA520' or '#6ec1ff')
    local depositAmountText = formatCurrencyAmount(rentalCurrency, rentalDep)
    local rentChargeAmountText = formatCurrencyAmount(rentalCurrency, rentCharge)
    local rentButtonAmount = depositAmountText
    local buyPriceText = formatCurrencyAmount(purchaseCurrency, price)
    local sellPriceText = formatCurrencyAmount(purchaseCurrency, sellPrice)
    local taxAmountText = formatCurrencyAmount(purchaseCurrency, taxAmount)

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
            _U('listSellPrice') .. '<strong>' .. sellPriceText .. '</strong></p>'
    else
        sellLine =
            '<p style="font-size:18px; margin-bottom: 10px;">' ..
            _U('listCanSell') .. '<strong>' .. _U('No') .. '</strong></p>'
    end

    local rentalLines
    if rentalEnabled then
        rentalLines =
            '<p style="font-size:18px; margin-bottom: 10px;">' ..
            _U('rentalDeposit', highlightedCurrencyWord) .. '<strong style="color:' .. currencyAmountColor .. ';">' .. depositAmountText .. '</strong></p>' ..
            '<p style="font-size:18px; margin-bottom: 10px;">' ..
            _U('rentCharge', highlightedCurrencyWord) .. '<strong style="color:' .. currencyAmountColor .. ';">' .. rentChargeAmountText .. '</strong></p>'
    else
        rentalLines =
            '<p style="font-size:18px; margin-bottom: 10px;">' ..
            _U('rentalStatusLabel') .. '<strong>' .. _U('rentalDisabledLabel') .. '</strong></p>'
    end

    local uniqueNameLine = ''
    if isAdmin then
        uniqueNameLine =
            '<p style="font-size:18px; margin-bottom: 10px;">' ..
            _U('houseDetailsUniqueName', '<strong>' .. tostring(house.uniqueName or "N/A") .. '</strong>') .. '</p>'
    end

    local htmlContent =
        '<div style="text-align:center; margin: 20px;">' ..
        uniqueNameLine ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('listBuyPrice') .. '<strong style="color:#28A745;">' .. buyPriceText .. '</strong></p>' ..
        sellLine ..
        rentalLines ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('listRoomateLim') .. '<strong>' .. tostring(playerMax) .. '</strong></p>' ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('listInvLimit') .. '<strong>' .. tostring(invLimit) .. '</strong></p>' ..
        '<p style="font-size:18px; margin-bottom: 10px;">' ..
        _U('listTaxAmount') .. '<strong style="color:#DC3545;">' .. taxAmountText .. '</strong></p>' ..
        '</div>'


    buyHouseMenu:RegisterElement("html", {
        value = { htmlContent },
        slot = 'content',
        style = {}
    })

    buyHouseMenu:RegisterElement('line', { style = {}, slot = 'footer' })

    buyHouseMenu:RegisterElement('button', {
        label = _U('showPropertyPreview'),
        style = {},
        slot = "footer"
    }, function()
        StartHouseAreaPreview(house)
        SuppressHousePreviewStopOnMenuClose = true
        BCCHousingMenu:Close()
    end)

    buyHouseMenu:RegisterElement('button', {
        label = _U('buyHouseForCurrency', buyPriceText),
        style = {},
        slot = "footer"
    }, function()
        stopHouseAreaPreview()
        BCCHousingMenu:Close()
        local success, err = BccUtils.RPC:CallAsync('bcc-housing:buyHouse', {
            houseCoords = house.houseCoords,
            moneyType = 0 -- Cash
        })
        if not success then
            DBG:Info("House purchase RPC failed: " .. tostring(err and err.error))
        end
    end)

    if rentalEnabled then
        buyHouseMenu:RegisterElement('button', {
            label = _U('rentHouseFor', rentButtonAmount),
            style = {},
            slot = "footer"
        }, function()
            stopHouseAreaPreview()
            BCCHousingMenu:Close()
            local success, err = BccUtils.RPC:CallAsync('bcc-housing:buyHouse', {
                houseCoords = house.houseCoords,
                moneyType = 1 -- Rental
            })
            if not success then
                DBG:Info("House rental RPC failed: " .. tostring(err and err.error))
            end
        end)
    end

    buyHouseMenu:RegisterElement('button', {
        label = _U('cancel'),
        style = { ['position'] = 'relative', ['z-index'] = 9 },
        slot = "footer"
    }, function()
        stopHouseAreaPreview()
        BCCHousingMenu:Close()
    end)

    buyHouseMenu:RegisterElement('bottomline', { style = {}, slot = "footer" })

    BCCHousingMenu:Open({ startupPage = buyHouseMenu })
end
