BccUtils.RPC:Register('bcc-housing:AdminManagementMenu', function(params)
    if params and params.houses then
        AdminManagementMenu(params.houses)
    end
end)

BccUtils.RPC:Register('bcc-housing:GetHouseInfo', function(params)
    if params then
        local houseInfo = params.houseInfo or params
        AdminManagementMenuHouseChose(houseInfo)
    end
end)

local function decodeAdminJson(value)
    if type(value) == 'string' and value ~= '' and value ~= 'null' then
        return json.decode(value)
    end

    return value
end

local function normalizeAdminHouseForPreview(houseInfo)
    if not houseInfo then
        return nil
    end

    local coords = decodeAdminJson(houseInfo.house_coords or houseInfo.houseCoords)
    if not coords or not coords.x or not coords.y or not coords.z then
        return nil
    end

    return {
        houseid = houseInfo.houseid,
        uniqueName = houseInfo.uniqueName,
        name = houseInfo.name,
        houseCoords = vector3(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0, tonumber(coords.z) or 0.0),
        menuCoords = vector3(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0, tonumber(coords.z) or 0.0),
        houseRadiusLimit = tonumber(houseInfo.house_radius_limit or houseInfo.houseRadiusLimit) or 0.0,
        polyPoints = decodeAdminJson(houseInfo.poly_points or houseInfo.polyPoints),
        polyMinZ = tonumber(houseInfo.poly_min_z or houseInfo.polyMinZ),
        polyMaxZ = tonumber(houseInfo.poly_max_z or houseInfo.polyMaxZ)
    }
end

local function previewAdminHouseArea(houseInfo)
    local previewHouse = normalizeAdminHouseForPreview(houseInfo)
    if not previewHouse then
        Notify(_U("houseAreaPreviewFailed"), "error", 4000)
        return
    end

    if not StartHouseAreaPreview then
        Notify(_U("houseAreaPreviewFailed"), "error", 4000)
        return
    end

    StartHouseAreaPreview(previewHouse)
    SuppressHousePreviewStopOnMenuClose = true
    if BCCHousingMenu then
        BCCHousingMenu:Close()
    end

    Notify(_U("houseAreaPreviewStarted", tostring(previewHouse.houseid or previewHouse.uniqueName or previewHouse.name or "N/A")), "success", 4000)
end

local function previewNearestAdminHouseArea(allHouses)
    if type(allHouses) ~= 'table' or #allHouses == 0 then
        Notify(_U("noNearbyHouseAreaPreview"), "error", 4000)
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestHouse = nil
    local nearestDistance = nil

    for _, houseInfo in pairs(allHouses) do
        local previewHouse = normalizeAdminHouseForPreview(houseInfo)
        if previewHouse and previewHouse.houseCoords then
            local distance = #(playerCoords - previewHouse.houseCoords)
            if not nearestDistance or distance < nearestDistance then
                nearestDistance = distance
                nearestHouse = houseInfo
            end
        end
    end

    if not nearestHouse or not nearestDistance or nearestDistance > 100.0 then
        Notify(_U("noNearbyHouseAreaPreview"), "error", 4000)
        return
    end

    previewAdminHouseArea(nearestHouse)
end

local function getOverdueAdminHouses(allHouses)
    local overdueHouses = {}

    if type(allHouses) ~= 'table' then
        return overdueHouses
    end

    for _, houseInfo in pairs(allHouses) do
        if tostring(houseInfo.taxes_collected) == 'overdue' then
            table.insert(overdueHouses, houseInfo)
        end
    end

    return overdueHouses
end

local function formatPurchasedAt(value)
    if not value or value == '' then
        return "N/A"
    end

    return tostring(value):sub(1, 16)
end

local function getConfigHouseCoords(houseInfo)
    if not houseInfo then
        return nil
    end

    local coords = houseInfo.menuCoords or houseInfo.houseCoords
    if not coords or not coords.x or not coords.y or not coords.z then
        return nil
    end

    return coords
end

local function getConfigHouseLabel(houseInfo)
    local houseName = houseInfo.name or _U("house")
    local uniqueName = houseInfo.uniqueName or "N/A"

    return _U("configHouseTpLabel", tostring(houseName), tostring(uniqueName))
end

function AdminConfigHousesMenu()
    if BCCHousingMenu then
        BCCHousingMenu:Close()
    end

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local configHousesPage = BCCHousingMenu:RegisterPage('admin_config_houses_page')

    configHousesPage:RegisterElement('header', {
        value = _U("manageConfigHouses"),
        slot = "header",
        style = {}
    })

    configHousesPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    local configHouses = {}
    for _, houseInfo in pairs(Houses or {}) do
        table.insert(configHouses, houseInfo)
    end

    table.sort(configHouses, function(a, b)
        return tostring(a.uniqueName or a.name or "") < tostring(b.uniqueName or b.name or "")
    end)

    if #configHouses == 0 then
        configHousesPage:RegisterElement('textdisplay', {
            value = _U("noConfigHouses"),
            slot = "content",
            style = {}
        })
    end

    for _, houseInfo in ipairs(configHouses) do
        configHousesPage:RegisterElement('button', {
            label = getConfigHouseLabel(houseInfo),
            style = {}
        }, function()
            local coords = getConfigHouseCoords(houseInfo)
            if not coords then
                Notify(_U("configHouseCoordsMissing", tostring(houseInfo.uniqueName or "N/A")), "error", 4000)
                return
            end

            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
            BCCHousingMenu:Close()
            Notify(_U("configHouseTeleported", tostring(houseInfo.uniqueName or "N/A")), "success", 4000)
        end)
    end

    configHousesPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    configHousesPage:RegisterElement('button', {
        label = _U("previewNearestHouseArea"),
        slot = "footer",
        style = {}
    }, function()
        previewNearestAdminHouseArea(configHouses)
    end)

    configHousesPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = { ['position'] = 'relative', ['z-index'] = 9 }
    }, function()
        HouseManagementMenu()
    end)

    configHousesPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = configHousesPage
    })
end

function AdminManagementMenu(allHouses)
    if BCCHousingMenu then
        BCCHousingMenu:Close() 
    end

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local adminMenuPage = BCCHousingMenu:RegisterPage('admin_management_menu_page')

    adminMenuPage:RegisterElement('header', {
        value = _U("adminManagmentMenu"),
        slot = 'header',
        style = {}
    })

    adminMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for _, houseInfo in pairs(allHouses) do
        -- Get owner's first and last name with fallback to "Unknown" if data is missing
        local ownerFirstName = houseInfo.firstName or "Unknown"
        local ownerLastName = houseInfo.lastName or "Unknown"
        local ownershipStatus = tostring(houseInfo.ownershipStatus or "purchased")
        local holderLabel = ownershipStatus == "rented" and _U("tenantLabel") or _U("ownerLabel")
        local uniqueName = houseInfo.uniqueName and tostring(houseInfo.uniqueName) or "N/A"

        -- Register a button for each house with the owner's name and house ID
        adminMenuPage:RegisterElement('button', {
            label = _U("adminHouseListLabelWithUnique", tostring(houseInfo.houseid), uniqueName, holderLabel, ownerFirstName .. " " .. ownerLastName),
            style = {}
        }, function()
            AdminManagementMenuHouseChose(houseInfo)
        end)
    end

    adminMenuPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    adminMenuPage:RegisterElement('button', {
        label = _U("previewNearestHouseArea"),
        slot = "footer",
        style = {}
    }, function()
        previewNearestAdminHouseArea(allHouses)
    end)

    adminMenuPage:RegisterElement('button', {
        label = _U("overdueHouses"),
        slot = "footer",
        style = {}
    }, function()
        local overdueHouses = getOverdueAdminHouses(allHouses)
        if #overdueHouses == 0 then
            Notify(_U("noOverdueHouses"), "info", 4000)
            return
        end

        AdminManagementMenu(overdueHouses)
    end)

    adminMenuPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        HouseManagementMenu()
    end)

    adminMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = adminMenuPage
    })
end

function AdminManagementMenuHouseChose(houseInfo)
    if BCCHousingMenu then
        BCCHousingMenu:Close()
    end

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local houseOptionsPage = BCCHousingMenu:RegisterPage('house_options_page')

    houseOptionsPage:RegisterElement('header', {
        value = _U("selectThisHouse"),
        slot = "header",
        style = {}
    })

    houseOptionsPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    local purchaseCurrencyType = tonumber(houseInfo.purchaseCurrencyType) or 0
    local purchaseCurrencyLabel = _U("currencyMoney")
    if purchaseCurrencyType == 1 then
        purchaseCurrencyLabel = _U("currencyGold")
    elseif purchaseCurrencyType == 2 then
        purchaseCurrencyLabel = _U("currencyRol")
    end

    local ownerFirstName = houseInfo.firstName or "Unknown"
    local ownerLastName = houseInfo.lastName or "Unknown"
    local taxStatus = tostring(houseInfo.taxes_collected or "false")

    local houseDetails = string.format(
        _U("houseDetailsHouseID", houseInfo.houseid and tostring(houseInfo.houseid) or "N/A") .. "\n" ..
        _U("houseDetailsUniqueName", houseInfo.uniqueName and tostring(houseInfo.uniqueName) or "N/A") .. "\n" ..
        _U("houseDetailsOwnerName", ownerFirstName .. " " .. ownerLastName) .. "\n" ..
        _U("houseDetailsOwnerID", houseInfo.charidentifier and tostring(houseInfo.charidentifier) or "N/A") .. "\n" ..
        _U("houseDetailsStatus", _U(tostring(houseInfo.ownershipStatus or "purchased"))) .. "\n" ..
        _U("houseDetailsPurchaseCurrency", purchaseCurrencyLabel) .. "\n" ..
        _U("housePurchasedAt", formatPurchasedAt(houseInfo.purchased_at_formatted or houseInfo.purchased_at)) .. "\n" ..
        _U("houseDetailsRadius", houseInfo.house_radius_limit and tostring(houseInfo.house_radius_limit) or "N/A") ..
        "\n" ..
        _U("houseDetailsInvLimit", houseInfo.invlimit and tostring(houseInfo.invlimit) or "N/A") .. "\n" ..
        _U("houseDetailsTaxes", houseInfo.tax_amount and tostring(houseInfo.tax_amount) or "N/A") .. "\n" ..
        _U("houseDetailsLedger", houseInfo.ledger and tostring(houseInfo.ledger) or "0") .. "\n" ..
        _U("houseDetailsTaxStatus", _U(taxStatus))
    )

    houseOptionsPage:RegisterElement('textdisplay', {
        value = houseDetails,
        slot = "content",
        style = {
            marginBottom = "20px"
        }
    })

    houseOptionsPage:RegisterElement('line', {
        style = {}
    })

    houseOptionsPage:RegisterElement('button', {
        label = _U("delHouse"),
        style = {}
    }, function()
        deleteHouse(houseInfo)
    end)

    houseOptionsPage:RegisterElement('button', {
        label = _U("changeHouseRadius"),
        style = {}
    }, function()
        changeHouseRadius(houseInfo)
    end)

    houseOptionsPage:RegisterElement('button', {
        label = _U("previewHouseArea"),
        style = {}
    }, function()
        previewAdminHouseArea(houseInfo)
    end)

    houseOptionsPage:RegisterElement('button', {
        label = _U("changeHouseInvLimit"),
        style = {}
    }, function()
        changeHouseInventory(houseInfo)
    end)

    houseOptionsPage:RegisterElement('button', {
        label = _U("changeHouseTaxes"),
        style = {}
    }, function()
        changeHouseTaxes(houseInfo)
    end)

    if taxStatus == "overdue" then
        houseOptionsPage:RegisterElement('button', {
            label = _U("releaseHouseTaxPayment"),
            style = {}
        }, function()
            local success = BccUtils.RPC:CallAsync('bcc-house:AdminReleaseHouseTaxPayment', {
                houseId = houseInfo.houseid
            })

            if success then
                houseInfo.taxes_collected = "released"
                AdminManagementMenuHouseChose(houseInfo)
            end
        end)
    end

    houseOptionsPage:RegisterElement('button', {
        label = _U("openHouseInventory"),
        style = {}
    }, function()
        local success, result = BccUtils.RPC:CallAsync('bcc-house:AdminOpenHouseInv', {
            houseId = houseInfo.houseid
        })

        if not success then
            Notify((result and result.error) or _U("failedOpenHouseInventory"), "error", 4000)
        end
    end)

    houseOptionsPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    houseOptionsPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = { ['position'] = 'relative', ['z-index'] = 9 }
    }, function()
        local success, houses = BccUtils.RPC:CallAsync('bcc-housing:AdminGetAllHouses', {})
        if success and houses then
            AdminManagementMenu(houses)
        else
            DBG:Error("Failed to refresh admin house list: " .. tostring(houses and houses.error))
        end
    end)

    houseOptionsPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = houseOptionsPage
    })
end

function deleteHouse(houseInfo)
    if not houseInfo then
        print("Error: houseInfo is nil")
        return
    end

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    if BCCHousingMenu then
        BCCHousingMenu:Close()
    end

    local deleteHousePage = BCCHousingMenu:RegisterPage("delete_house_page")

    deleteHousePage:RegisterElement('header', {
        value = _U("delHouse"),
        slot = "header",
        style = {}
    })

    deleteHousePage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    deleteHousePage:RegisterElement('subheader', {
        value = _U("delHouse_desc"),
        slot = "header",
        style = {}
    })

    deleteHousePage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    deleteHousePage:RegisterElement('button', {
        label = _U("confirmYes"),
        slot = "footer",
        style = {}
    }, function()
        local success, err = BccUtils.RPC:CallAsync('bcc-house:AdminManagementDelHouse', { houseId = houseInfo.houseid })
        if not success then
            DBG:Info("AdminManagementDelHouse RPC failed: " .. tostring(err and err.error))
        end
        BCCHousingMenu:Close()
    end)

    deleteHousePage:RegisterElement('button', {
        label = _U("confirmNo"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        AdminManagementMenuHouseChose(houseInfo)
    end)

    deleteHousePage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = deleteHousePage:RegisterElement('textdisplay', {
        value = _U("delHouse_desc"),
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = deleteHousePage
    })
end

function changeHouseRadius(houseInfo)
    if BCCHousingMenu then
        BCCHousingMenu:Close()
    end

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local changeRadiusPage = BCCHousingMenu:RegisterPage("set_radius_page")
    changeRadiusPage:RegisterElement('header', {
        value = _U("setRadius"),
        slot = "header",
        style = {}
    })

    local radiusValue = nil

    changeRadiusPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    changeRadiusPage:RegisterElement('input', {
        label = _U("insertAmount"),
        placeholder = _U("setRadius"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        if data.value and tonumber(data.value) > 0 then
            radiusValue = tonumber(data.value)
        else
            radiusValue = nil
            Notify(_U("InvalidInput"), "error", 4000)
        end
    end)

    changeRadiusPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    changeRadiusPage:RegisterElement('button', {
        label = _U("Confirm"),
        slot = "footer",
        style = {},
    }, function()
        if radiusValue then
            local success, err = BccUtils.RPC:CallAsync('bcc-house:AdminManagementChangeHouseRadius', {
                houseId = houseInfo.houseid,
                radius = radiusValue
            })
            if not success then
                DBG:Info("AdminManagementChangeHouseRadius RPC failed: " .. tostring(err and err.error))
            end
            AdminManagementMenuHouseChose(houseInfo)
        else
            Notify(_U("InvalidInput"), "error", 4000)
        end
    end)

    changeRadiusPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        AdminManagementMenuHouseChose(houseInfo)
    end)

    changeRadiusPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = changeRadiusPage:RegisterElement('textdisplay', {
        value = _U("changeHouseRadius_desc"),
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = changeRadiusPage
    })
end

function changeHouseTaxes(houseInfo)
    if BCCHousingMenu then
        BCCHousingMenu:Close()
    end

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local changeHouseTaxesPage = BCCHousingMenu:RegisterPage("set_tax_amount_page")

    changeHouseTaxesPage:RegisterElement('header', {
        value = _U("taxAmount"),
        slot = "header",
        style = {}
    })

    changeHouseTaxesPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    local taxAmount = nil

    changeHouseTaxesPage:RegisterElement('input', {
        label = _U("insertAmount"),
        placeholder = _U("insertAmount"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        if data.value and tonumber(data.value) and tonumber(data.value) > 0 then
            taxAmount = tonumber(data.value)
        else
            taxAmount = nil
            Notify(_U("InvalidInput"), "error", 4000)
        end
    end)

    changeHouseTaxesPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    changeHouseTaxesPage:RegisterElement('button', {
        label = _U("Confirm"),
        slot = "footer",
        style = {},
    }, function()
        if taxAmount then
            local success, err = BccUtils.RPC:CallAsync('bcc-house:AdminManagementChangeTaxAmount', {
                houseId = houseInfo.houseid,
                tax = taxAmount
            })
            if not success then
                DBG:Info("AdminManagementChangeTaxAmount RPC failed: " .. tostring(err and err.error))
            end
            AdminManagementMenuHouseChose(houseInfo)
        else
            Notify(_U("InvalidInput"), "error", 4000)
        end
    end)

    changeHouseTaxesPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        AdminManagementMenuHouseChose(houseInfo)
    end)

    changeHouseTaxesPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = changeHouseTaxesPage:RegisterElement('textdisplay', {
        value = _U("changeHouseTaxes_desc"),
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = changeHouseTaxesPage
    })
end

function changeHouseInventory(houseInfo)
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local changeHouseInventoryPage = BCCHousingMenu:RegisterPage('inventory_limit_page')
    local inventoryLimit = nil

    changeHouseInventoryPage:RegisterElement('header', {
        value = _U('setInvLimit'),
        slot = 'header',
        style = {}
    })

    changeHouseInventoryPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    changeHouseInventoryPage:RegisterElement('input', {
        label = _U('setInvLimit'),
        placeholder = _U("insertAmount"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        if data.value and tonumber(data.value) and tonumber(data.value) > 0 then
            inventoryLimit = tonumber(data.value)
        else
            inventoryLimit = nil
            Notify(_U("InvalidInput"), "error", 4000)
        end
    end)

    changeHouseInventoryPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    changeHouseInventoryPage:RegisterElement('button', {
        label = _U('Confirm'),
        slot = "footer",
        style = {},
    }, function()
        if inventoryLimit then
            local success, err = BccUtils.RPC:CallAsync('bcc-house:AdminManagementChangeInvLimit', {
                houseId = houseInfo.houseid,
                invLimit = inventoryLimit
            })
            if not success then
                DBG:Info("AdminManagementChangeInvLimit RPC failed: " .. tostring(err and err.error))
            end
            AdminManagementMenuHouseChose(houseInfo)
        else
            Notify(_U("InvalidInput"), "error", 4000)
        end
    end)

    changeHouseInventoryPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        AdminManagementMenuHouseChose(houseInfo)
    end)

    changeHouseInventoryPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = changeHouseInventoryPage:RegisterElement('textdisplay', {
        value = _U("changeHouseInvLimit_desc"),
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = changeHouseInventoryPage
    })
end
