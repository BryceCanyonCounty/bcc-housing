RegisterNetEvent('bcc-housing:AdminManagementMenu', function(allHouses)
    AdminManagementMenu(allHouses)
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

    -- Dynamically add house options to the menu
    for k, houseInfo in pairs(allHouses) do
        adminMenuPage:RegisterElement('button', {
            label = _U("ownerHouseId") .. houseInfo.houseid,
            style = {}
        }, function()
            AdminManagementMenuHouseChose(houseInfo)
        end)
    end

    -- Register a back button
    adminMenuPage:RegisterElement('button', {
        label = _U("backButton"),
        style = {}
    }, function()
        HouseManagementMenu() -- Assuming this method exists to go back to the previous menu
    end)

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

    -- Options for house management
    local options = {
        { label = _U("delHouse"),            desc = _U("delHouse_desc"),            action = 'delhouse' },
        { label = _U("changeHouseRadius"),   desc = _U("changeHouseRadius_desc"),   action = 'changeradius' },
        { label = _U("changeHouseInvLimit"), desc = _U("changeHouseInvLimit_desc"), action = 'changeinvlimit' },
        { label = _U("changeHouseTaxes"),    desc = _U("changeHouseTaxes_desc"),    action = 'changetaxes' }
    }

    for _, option in ipairs(options) do
        houseOptionsPage:RegisterElement('button', {
            label = option.label,
            desc = option.desc,
            style = {}
        }, function()
            handleHouseOption(option.action, houseInfo)
        end)
    end

    -- Register a back button
    houseOptionsPage:RegisterElement('button', {
        label = _U("backButton"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-housing:AdminGetAllHouses') -- This should reopen the admin menu listing all houses
    end)

    -- Open the house options menu
    BCCHousingMenu:Open({
        startupPage = houseOptionsPage
    })
end

function handleHouseOption(action, houseInfo)
    -- This function would handle each action by triggering server events or input dialogs
    if action == 'delhouse' then
        TriggerServerEvent('bcc-house:AdminManagementDelHouse', houseInfo.houseid)
    elseif action == 'changeradius' then
        requestInputAndExecute("Enter new radius:", "number", function(input)
            TriggerServerEvent('bcc-house:AdminManagementChangeHouseRadius', houseInfo.houseid, tonumber(input))
        end)
    elseif action == 'changeinvlimit' then
        requestInputAndExecute("Enter new inventory limit:", "number", function(input)
            TriggerServerEvent('bcc-house:AdminManagementChangeInvLimit', houseInfo.houseid, tonumber(input))
        end)
    elseif action == 'changetaxes' then
        requestInputAndExecute("Enter new tax amount:", "number", function(input)
            TriggerServerEvent('bcc-house:AdminManagementChangeTaxAmount', houseInfo.houseid, tonumber(input))
        end)
    end
end

function requestInputAndExecute(title, inputType, callback)
    -- This function would handle input dialogs
    -- Here you need to integrate or utilize an input dialog function based on your menu system
end
