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

    local adminMenuPage = BCCHousingMenu:RegisterPage('admin_management_menu_page')

    -- Add a header to the menu
    adminMenuPage:RegisterElement('header', {
        value = _U("adminManagmentMenu"),
        slot = 'header',
        style = {}
    })

    adminMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Dynamically add house options to the menu
    for k, houseInfo in pairs(allHouses) do
        adminMenuPage:RegisterElement('button', {
            label = "Owner ID: " .. houseInfo.charidentifier .. "  -  House Id : " .. houseInfo.houseid,
            style = {}
        }, function()
            AdminManagementMenuHouseChose(houseInfo)
        end)
    end

    adminMenuPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Register a back button
    adminMenuPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        HouseManagementMenu() -- Assuming this method exists to go back to the previous menu
    end)

    adminMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    -- Open the menu with the configured page
    BCCHousingMenu:Open({
        startupPage = adminMenuPage
    })
end

function AdminManagementMenuHouseChose(houseInfo)
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end

    local houseOptionsPage = BCCHousingMenu:RegisterPage('house_options_page')

    -- Add a header for house options
    houseOptionsPage:RegisterElement('header', {
        value = _U("selectThisHouse"),
        slot = "header",
        style = {}
    })

    houseOptionsPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Delete House button
    houseOptionsPage:RegisterElement('button', {
        label = _U("delHouse"),
        style = {}
    }, function()
        deleteHouse(houseInfo)
    end)

    --Change House Radius button
    houseOptionsPage:RegisterElement('button', {
        label = _U("changeHouseRadius"),
        style = {}
    }, function()
        changeHouseRadius(houseInfo)
    end)

    --Change House Inventory button
    houseOptionsPage:RegisterElement('button', {
        label = _U("changeHouseInvLimit"),
        style = {}
    }, function()
        changeHouseInventory(houseInfo)
    end)

    --Change House Taxes button
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

    -- Register a back button
    houseOptionsPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        TriggerServerEvent('bcc-housing:AdminGetAllHouses') -- This should reopen the admin menu listing all houses
    end)

    houseOptionsPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    -- Open the house options menu
    BCCHousingMenu:Open({
        startupPage = houseOptionsPage
    })
end

function deleteHouse(houseInfo)
    if not houseInfo then
        print("Error: houseInfo is nil")
        return -- Exit the function if houseInfo is nil
    end

    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end

    -- Initialize the teleport options menu page
    local deleteHousePage = BCCHousingMenu:RegisterPage("delete_house_page") -- Ensure the page name is unique and descriptive

    -- Add a header for deletion confirmation
    deleteHousePage:RegisterElement('header', {
        value = "Delete House",
        slot = "header",
        style = {}
    })

    deleteHousePage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Add a subheader asking for confirmation
    deleteHousePage:RegisterElement('subheader', {
        value = "Are you sure you want to delete this house?",
        slot = "header",
        style = {}
    })

    -- Yes button for deletion
    deleteHousePage:RegisterElement('button', {
        label = "Yes",
        style = {}
    }, function()
        TriggerServerEvent('bcc-house:AdminManagementDelHouse', houseInfo.houseid)
        BCCHousingMenu:Close() -- Close the menu after the action
    end)

    -- No button to cancel deletion
    deleteHousePage:RegisterElement('button', {
        label = "No",
        style = {}
    }, function()
        AdminManagementMenuHouseChose(houseInfo) -- Potentially return to the previous house-specific menu
    end)

    deleteHousePage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = deleteHousePage:RegisterElement('textdisplay', {
        value = _U("delHouse_desc"),
        style = {}
    })

    -- Open the menu with the newly created page
    BCCHousingMenu:Open({
        startupPage = deleteHousePage
    })
end

function changeHouseRadius(houseInfo)
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end

    local changeRadiusPage = BCCHousingMenu:RegisterPage("set_radius_page")
    changeRadiusPage:RegisterElement('header', {
        value = _U("setRadius"),
        slot = "header",
        style = {}
    })

    local radiusValue = nil -- Define a variable to hold the radius outside the callbacks

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
            radiusValue = tonumber(data.value) -- Store the radius value
            --VORPcore.NotifyRightTip(_U("radiusSet"), 4000)
        else
            radiusValue = nil -- Ensure radius is nil if input is invalid
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
        if radiusValue then -- Check the stored radius value
            TriggerServerEvent('bcc-house:AdminManagementChangeHouseRadius', houseInfo.houseid, radiusValue)
            --VORPcore.NotifyRightTip(_U("radiusSet"), 4000)
            AdminManagementMenuHouseChose(houseInfo) -- Optionally go back to house options
        else
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    changeRadiusPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        AdminManagementMenuHouseChose(houseInfo) -- Go back to house options
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
        BCCHousingMenu:Close() -- Ensure no other menus are open
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

    local taxAmount = nil -- Define a variable to hold the tax amount outside the callbacks

    changeHouseTaxesPage:RegisterElement('input', {
        label = _U("insertAmount"),
        placeholder = _U("insertAmount"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        if data.value and tonumber(data.value) and tonumber(data.value) > 0 then
            taxAmount = tonumber(data.value) -- Store the tax amount value
            --VORPcore.NotifyRightTip(_U("taxAmountReady"), 4000)
        else
            taxAmount = nil -- Ensure tax amount is nil if input is invalid
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
        if taxAmount then -- Check the stored tax amount value
            TriggerServerEvent('bcc-house:AdminManagementChangeTaxAmount', houseInfo.houseid, taxAmount)
            --VORPcore.NotifyRightTip(_U("taxAmountSet"), 4000)
            AdminManagementMenuHouseChose(houseInfo) -- Optionally go back to house options
        else
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    changeHouseTaxesPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        AdminManagementMenuHouseChose(houseInfo) -- Go back to house options
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

    local changeHouseInventoryPage = BCCHousingMenu:RegisterPage('inventory_limit_page')
    local inventoryLimit = nil -- Define a local variable to store the inventory limit

    -- Header for the inventory limit page
    changeHouseInventoryPage:RegisterElement('header', {
        value = _U('setInvLimit'),
        slot = 'header',
        style = {}
    })

    changeHouseInventoryPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Input for entering the inventory limit
    changeHouseInventoryPage:RegisterElement('input', {
        label = _U('setInvLimit'),
        placeholder = _U("insertAmount"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        if data.value and tonumber(data.value) and tonumber(data.value) > 0 then
            inventoryLimit = tonumber(data.value) -- Set the valid inventory limit
            --VORPcore.NotifyRightTip(_U("invLimitReady"), 4000) -- Feedback that the input is ready
        else
            inventoryLimit = nil -- Reset if input is invalid
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    changeHouseInventoryPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Confirm button to process the inventory limit
    changeHouseInventoryPage:RegisterElement('button', {
        label = _U('Confirm'),
        slot = "footer",
        style = {},
    }, function()
        if inventoryLimit then -- Check if the inventory limit is set
            TriggerServerEvent('bcc-house:AdminManagementChangeInvLimit', houseInfo.houseid, inventoryLimit)
            --VORPcore.NotifyRightTip(_U("invLimitSet"), 4000)
            AdminManagementMenuHouseChose(houseInfo) -- Return to house options menu
        else
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    -- Register a back button
    changeHouseInventoryPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        AdminManagementMenuHouseChose(houseInfo) -- Return to house options menu
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
    -- Open the menu with the newly created page
    BCCHousingMenu:Open({
        startupPage = changeHouseInventoryPage
    })
end
