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

function AdminManagementMenu(allHouses)
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
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

        -- Register a button for each house with the owner's name and house ID
        adminMenuPage:RegisterElement('button', {
            label = "House ID: " .. houseInfo.houseid .. " | Owner: " .. ownerFirstName .. " " .. ownerLastName,
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
        return -- Skip opening the menu if the player is dead
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

    local houseDetails = string.format(
        _U("houseDetailsHouseID", houseInfo.houseid and tostring(houseInfo.houseid) or "N/A") .. "\n" ..
        _U("houseDetailsOwnerID", houseInfo.charidentifier and tostring(houseInfo.charidentifier) or "N/A") .. "\n" ..
        _U("houseDetailsRadius", houseInfo.house_radius_limit and tostring(houseInfo.house_radius_limit) or "N/A") ..
        "\n" ..
        _U("houseDetailsInvLimit", houseInfo.invlimit and tostring(houseInfo.invlimit) or "N/A") .. "\n" ..
        _U("houseDetailsTaxes", houseInfo.tax_amount and tostring(houseInfo.tax_amount) or "N/A")
        ---@todo add ownershipStatus ?
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
            devPrint("Failed to refresh admin house list: " .. tostring(houses and houses.error))
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
        return -- Skip opening the menu if the player is dead
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
            devPrint("AdminManagementDelHouse RPC failed: " .. tostring(err and err.error))
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
        return -- Skip opening the menu if the player is dead
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
                devPrint("AdminManagementChangeHouseRadius RPC failed: " .. tostring(err and err.error))
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
        return -- Skip opening the menu if the player is dead
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
                devPrint("AdminManagementChangeTaxAmount RPC failed: " .. tostring(err and err.error))
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
        return -- Skip opening the menu if the player is dead
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
                devPrint("AdminManagementChangeInvLimit RPC failed: " .. tostring(err and err.error))
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
