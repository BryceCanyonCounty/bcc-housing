RegisterNetEvent('bcc-housing:AdminManagementMenu', function(allHouses)
    AdminManagementMenu(allHouses)
end)

RegisterNetEvent('bcc-housing:GetHouseInfo', function(houseInfo)
    AdminManagementMenuHouseChose(houseInfo)
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

    for k, houseInfo in pairs(allHouses) do
        adminMenuPage:RegisterElement('button', {
            label = "House Id : " .. houseInfo.houseid,
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
        style = {}
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
        "House ID: %s\nOwner ID: %s\nRadius: %s\nInventory Limit: %s\nTaxes: %s",
        tostring(houseInfo.houseid) or "N/A",
        tostring(houseInfo.charidentifier) or "N/A",
        tostring(houseInfo.house_radius_limit) or "N/A",
        tostring(houseInfo.invlimit) or "N/A",
        tostring(houseInfo.tax_amount) or "N/A"
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
        style = {}
    }, function()
        TriggerServerEvent('bcc-housing:AdminGetAllHouses')
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
        value = "Delete House",
        slot = "header",
        style = {}
    })

    deleteHousePage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    deleteHousePage:RegisterElement('subheader', {
        value = "Are you sure you want to delete this house?",
        slot = "header",
        style = {}
    })
    
    deleteHousePage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    
    deleteHousePage:RegisterElement('button', {
        label = "Yes",
        slot = "footer",
        style = {}
    }, function()
        TriggerServerEvent('bcc-house:AdminManagementDelHouse', houseInfo.houseid)
        BCCHousingMenu:Close()
    end)

    deleteHousePage:RegisterElement('button', {
        label = "No",
        slot = "footer",
        style = {}
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
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
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
            TriggerServerEvent('bcc-house:AdminManagementChangeHouseRadius', houseInfo.houseid, radiusValue)
            AdminManagementMenuHouseChose(houseInfo)
        else
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    changeRadiusPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
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
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
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
            TriggerServerEvent('bcc-house:AdminManagementChangeTaxAmount', houseInfo.houseid, taxAmount)
            AdminManagementMenuHouseChose(houseInfo)
        else
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    changeHouseTaxesPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
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
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
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
            TriggerServerEvent('bcc-house:AdminManagementChangeInvLimit', houseInfo.houseid, inventoryLimit)
            AdminManagementMenuHouseChose(houseInfo)
        else
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    changeHouseInventoryPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
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
