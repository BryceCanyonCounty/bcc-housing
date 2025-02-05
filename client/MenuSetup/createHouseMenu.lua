-- Global variables to store house data
globalHouseData = {
    owner = nil,
    ownerSource = nil,
    radius = nil,
    houseCoords = nil,
    invLimit = nil,
    taxAmount = nil,
    doors = {}, -- Assuming doors data is gathered somewhere
    tpInt = nil,
    ownershipStatus = 'purchased',
}

-- When creating a house
local function afterSelectingOwner(tpHouse)
    CreateHouseMenu(tpHouse) -- This might initialize house creation or whatever is appropriate after selecting an owner
end

function PlayerListMenu(houseId, callback, context)
    BCCHousingMenu:Close()
    
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    
    local players = GetPlayers()
    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)

    local playerListMenupage = BCCHousingMenu:RegisterPage("bcc-housing:playerListMenupage")
    playerListMenupage:RegisterElement("header", {
        value = _U("StaticId_desc"),
        slot = "header",
        style = {}
    })

    playerListMenupage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for k, v in pairs(players) do
        playerListMenupage:RegisterElement("button", {
            label = Config.dontShowNames and ("ID - " .. v.serverId) or v.PlayerName,
            style = {}
        }, function()
            globalHouseData.owner = v.staticid
            globalHouseData.ownerSource = v.serverId

            -- Decide which notification to show based on the context
            if context == "setOwner" then
                VORPcore.NotifyRightTip(_U("OwnerSet"), 4000)
            elseif context == "giveAccess" then
                VORPcore.NotifyRightTip(_U("givenAccess"), 4000)
            end

            callback(tpHouse, context) -- Pass context to the callback if needed
        end)
    end
    playerListMenupage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    playerListMenupage:RegisterElement("button", {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        callback(tpHouse, context) -- Handle the back action appropriately
    end)

    playerListMenupage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = playerListMenupage:RegisterElement('textdisplay', {
        value = _U('selectPlayerFromList'),
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = playerListMenupage
    })
end

function doorCreationMenu()
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end
    
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    local doorCreationMenuPage = BCCHousingMenu:RegisterPage('door_creation_page')

    -- Add a header for creating doors
    doorCreationMenuPage:RegisterElement('header', {
        value = _U("createdDoorList"),
        slot = "header",
        style = {}
    })

    doorCreationMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Add a button for creating a new door
    doorCreationMenuPage:RegisterElement('button', {
        label = _U("createDoor")
    }, function()
        BCCHousingMenu:Close() -- Close the current menu before opening doorlocks
        local door = exports['bcc-doorlocks']:createDoor()
        if not globalHouseData.doors then
            globalHouseData.doors = {}
        end
        table.insert(globalHouseData.doors, door)
        SetTimeout(500, function() -- Delay to prevent immediate reopening; adjust time as needed
            CreateHouseMenu(false) -- Open the house creation menu again
        end)
    end)

    -- List existing doors
    for k, door in ipairs(globalHouseData.doors or {}) do
        doorCreationMenuPage:RegisterElement('button', {
            label = _U("doorId") .. door.id, -- Assuming each door has a unique 'id'
            style = {}
        }, function()
            devPrint("Selected door with ID:", door.id)
        end)
    end

    doorCreationMenuPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Register a back button
    doorCreationMenuPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        CreateHouseMenu(false) -- Ensure tpHouse is properly maintained throughout the navigation
    end)

    doorCreationMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = doorCreationMenuPage:RegisterElement('textdisplay', {
        value = _U("doorCreation_desc"),
        slot = "footer",
        style = {}
    })

    -- Open the door creation menu
    BCCHousingMenu:Open({
        startupPage = doorCreationMenuPage
    })
end

function IntChoice()
    BCCHousingMenu:Close() -- Ensure no other menus are open
    
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    
    -- Initialize the interior choice menu page
    local interiorChoiceMenuPage = BCCHousingMenu:RegisterPage('interior_choice_page')

    interiorChoiceMenuPage:RegisterElement('header', {
        value = _U("Tp"),
        slot = "header",
        style = {}
    })

    interiorChoiceMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Add a button for choosing Interior 1
    interiorChoiceMenuPage:RegisterElement('button', {
        label = _U("Int1")
    }, function()
        tpInt = 1             -- Assuming tpInt is a variable that stores the chosen interior type
        CreateHouseMenu(true) -- Assuming this function initializes the house creation process
    end)

    -- Add a button for choosing Interior 2
    interiorChoiceMenuPage:RegisterElement('button', {
        label = _U("Int2")
    }, function()
        tpInt = 2
        CreateHouseMenu(true)
    end)

    interiorChoiceMenuPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Register a back button on the menu
    interiorChoiceMenuPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        HouseManagementMenu()
    end)

    interiorChoiceMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = interiorChoiceMenuPage:RegisterElement('textdisplay', {
        value = _U("SelectInterior_desc"),
        slot = "footer",
        style = {}
    })

    -- Open the interior choice menu
    BCCHousingMenu:Open({
        startupPage = interiorChoiceMenuPage
    })
end

function HouseManagementMenu(allHouses)
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    -- Initialize the teleport options menu page
    local HouseManagementList = BCCHousingMenu:RegisterPage("tp_options_page")

    -- Add a header for teleport options
    HouseManagementList:RegisterElement('header', {
        value = _U("adminManagmentMenu"),
        slot = "header",
        style = {}
    })

    HouseManagementList:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Add a button for the non-teleport option
    HouseManagementList:RegisterElement('button', {
        label = _U("nonTp"),
        style = {}
    }, function()
        CreateHouseMenu(false)
    end)

    -- Add a button for the teleport option
    HouseManagementList:RegisterElement('button', {
        label = _U("Tp"),
        style = {}
    }, function()
        IntChoice()
    end)

    HouseManagementList:RegisterElement('button', {
        label = _U('manageAllHouses'),
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        TriggerServerEvent('bcc-housing:AdminGetAllHouses')
    end)

    HouseManagementList:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = HouseManagementList:RegisterElement('textdisplay', {
        value = _U("HousingOptionDescr"),
        slot = "footer",
        style = {}
    })

    -- Open the teleport options menu
    BCCHousingMenu:Open({
        startupPage = HouseManagementList
    })
end

function CreateHouseMenu(tp, refresh)
    if refresh then
        BCCHousingMenu:Close() -- Close the current menu before reopening
    end
    
    tp = tp or false           -- Default to false if tp isn't provided
    devPrint("Adjusted tp in CreateHouseMenu:", tp)
    -- Close any existing menus, assuming BCCHousingMenu is your FeatherMenu instance
    BCCHousingMenu:Close()

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    -- Register the main page for housing creation
    local createHouseMenu = BCCHousingMenu:RegisterPage("bcc-housing-create-menu")

    -- Add a header to the menu
    createHouseMenu:RegisterElement('header', {
        value = _U("nonTp"),
        slot = 'header',
        style = {}
    })

    createHouseMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    createHouseMenu:RegisterElement('button', {
        label = _U("setOwner"),
        style = {}
    }, function()
        PlayerListMenu(tp, afterSelectingOwner, "setOwner")
    end)

    createHouseMenu:RegisterElement('button', {
        label = _U("setRadius"),
        style = {}
    }, function()
        setRadius()
    end)

    createHouseMenu:RegisterElement('button', {
        label = _U("houseCoords"),
        style = {}
    }, function()
        globalHouseData.houseCoords = GetEntityCoords(PlayerPedId())
        devPrint("house coords set to:", globalHouseData.houseCoords)
        VORPcore.NotifyRightTip(_U("houseCoordsSet"), 4000)
    end)

    createHouseMenu:RegisterElement('button', {
        label = _U("setInvLimit"),
        style = {}
    }, function()
        setInvLimit(tpHouse)
    end)

    createHouseMenu:RegisterElement('arrows', {
        label = _U("selectOwnershipType"),
        start = 1,
        options = {
            {
                display = _U("purchased"),
                extra = "purchased"
            },
            {
                display = _U("rented"),
                extra = "rented"
            },
            -- "purchased",
            -- "rented",
        },
        persist = true,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        },
    }, function(data)
        -- This gets triggered whenever the arrow selected value changes
        -- print("arrows ownershipStatus", (data.value), data.value.extra) ---@todo remove
        globalHouseData.ownershipStatus = data.value.extra ---@todo need a test!!!
        devPrint("house sell type set to:", globalHouseData.ownershipStatus)
    end)

    createHouseMenu:RegisterElement('button', {
        label = _U("taxAmount"),
        style = {}
    }, function()
        setTaxAmount()
    end)

    if tp ~= true then -- This treats nil as false
        createHouseMenu:RegisterElement('button', {
            label = _U("doorCreation"),
            style = {}
        }, function()
            doorCreationMenu()
        end)
    end

    createHouseMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    createHouseMenu:RegisterElement('button', {
        label = _U("Confirm"),
        slot = "footer",
        style = {}
    }, function()
        confirmCreation(globalHouseData)
        HouseManagementMenu()
    end)

    -- Register a back button on the menu
    createHouseMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        HouseManagementMenu()
    end)

    createHouseMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = createHouseMenu:RegisterElement('textdisplay', {
        value = _U("nonTp_desc"),
        slot = "footer",
        style = {}
    })

    -- Open the menu with the configured page
    BCCHousingMenu:Open({
        startupPage = createHouseMenu
    })
end

---Set House Radius function
function setRadius()
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end
    
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    
    -- Initialize the teleport options menu page
    local setRadiusPage = BCCHousingMenu:RegisterPage("set_radius_page")

    -- Add a header for teleport options
    setRadiusPage:RegisterElement('header', {
        value = _U("setRadius"),
        slot = "header",
        style = {}
    })

    setRadiusPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Input for entering the radius
    setRadiusPage:RegisterElement('input', {
        label = _U("insertAmount"),
        placeholder = _U("setRadius"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        -- Check the input value for validity
        if data.value and tonumber(data.value) and tonumber(data.value) > 0 then
            globalHouseData.radius = tonumber(data.value) -- Correctly assign to globalHouseData
            devPrint("Radius set to:", globalHouseData.radius)
        else
            globalHouseData.radius = nil -- Ensure radius is nil if input is invalid
            devPrint("Invalid input for amount.")
        end
    end)

    setRadiusPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Confirm button to process and confirm the radius setting
    setRadiusPage:RegisterElement('button', {
        label = _U("Confirm"),
        style = {},
        slot = "footer",
    }, function()
        if globalHouseData.radius then
            VORPcore.NotifyRightTip(_U("radiusSet"), 4000)
            CreateHouseMenu(tpHouse) -- Optionally return to the house creation menu
        else
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    -- Register a back button
    setRadiusPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        CreateHouseMenu(tpHouse)
    end)

    setRadiusPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = setRadiusPage:RegisterElement('textdisplay', {
        value = _U("setRadius_desc"),
        slot = "footer",
        style = {}
    })

    -- Open the menu with the newly created page
    BCCHousingMenu:Open({
        startupPage = setRadiusPage
    })
end

---Set Tax Amount function
function setTaxAmount()
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    -- Initialize the tax amount settings menu page
    local setTaxAmountPage = BCCHousingMenu:RegisterPage("set_tax_amount_page")

    -- Add a header for tax amount settings
    setTaxAmountPage:RegisterElement('header', {
        value = _U("creationMenuName"),
        slot = "header",
        style = {}
    })

    setTaxAmountPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Input for entering the tax amount
    setTaxAmountPage:RegisterElement('input', {
        label = _U("insertAmount"),
        placeholder = _U("insertAmount"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        -- Validate the input from the user
        if data.value and tonumber(data.value) and tonumber(data.value) > 0 then
            globalHouseData.taxAmount = tonumber(data.value) -- Correctly update globalHouseData for tax amount
            devPrint("Tax amount set to:", globalHouseData.taxAmount)
        else
            globalHouseData.taxAmount = nil -- Reset if invalid input
            devPrint("Invalid input for tax amount.")
        end
    end)

    setTaxAmountPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Confirm button to process and confirm the tax amount setting
    setTaxAmountPage:RegisterElement('button', {
        label = _U("Confirm"),
        slot = "footer",
        style = {},
    }, function()
        if globalHouseData.taxAmount then
            VORPcore.NotifyRightTip(_U("taxAmountSet"), 4000)
            CreateHouseMenu(tpHouse) -- Optionally navigate back to the house creation menu
        else
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    -- Register a back button
    setTaxAmountPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        CreateHouseMenu(tpHouse)
    end)

    setTaxAmountPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = setTaxAmountPage:RegisterElement('textdisplay', {
        value = _U("taxAmount_desc"),
        slot = "footer",
        style = {}
    })

    -- Open the menu with the newly created page
    BCCHousingMenu:Open({
        startupPage = setTaxAmountPage
    })
end

---Set Inventory limit function
function setInvLimit(houseId)
    if BCCHousingMenu then
        BCCHousingMenu:Close() -- Ensure no other menus are open
    end
    
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    
    local inventoryLimitPage = BCCHousingMenu:RegisterPage('inventory_limit_page')

    -- Header for the inventory limit page
    inventoryLimitPage:RegisterElement('header', {
        value = _U('setInvLimit'),
        slot = 'header',
        style = {}
    })

    inventoryLimitPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Input for entering the inventory limit
    inventoryLimitPage:RegisterElement('input', {
        label = _U('setInvLimit'),
        placeholder = _U("insertAmount"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        -- Validate the input from the user
        if data.value and tonumber(data.value) and tonumber(data.value) > 0 then
            globalHouseData.invLimit = tonumber(data.value)
            devPrint("Inventory limit set to:", globalHouseData.invLimit)
        else
            globalHouseData.invLimit = nil
            devPrint("Invalid input for inventory limit.")
        end
    end)

    inventoryLimitPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Confirm button to process the inventory limit
    inventoryLimitPage:RegisterElement('button', {
        label = _U('Confirm'),
        slot = "footer",
        style = {},
    }, function()
        if globalHouseData.invLimit then
            TriggerServerEvent('bcc-housing:SetInventoryLimit', globalHouseData.invLimit, houseId)
            CreateHouseMenu(tpHouse) -- Optionally navigate back to the house creation menu
            VORPcore.NotifyRightTip(_U("invLimitSet"), 4000)
        else
            devPrint("Error: Inventory limit not set or invalid.")
            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
        end
    end)

    -- Register a back button
    inventoryLimitPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        CreateHouseMenu(tpHouse) -- Optionally go back to the main menu of house creation
    end)

    inventoryLimitPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = inventoryLimitPage:RegisterElement('textdisplay', {
        value = _U("setInvLimit_desc"),
        slot = "footer",
        style = {}
    })

    -- Open the menu with the newly created page
    BCCHousingMenu:Open({
        startupPage = inventoryLimitPage
    })
end

-- Confirm House Creation function
function confirmCreation(globalHouseData)
    if not globalHouseData then
        devPrint("Error: Data object is nil")
        return
    end
    if not globalHouseData.owner or not globalHouseData.radius or not globalHouseData.doors or not globalHouseData.houseCoords or not globalHouseData.invLimit or not globalHouseData.ownerSource or not globalHouseData.taxAmount then
        devPrint("Error: One or more required fields are missing in the data object")
        return
    end
    local tpHouse = false
    if tpInt ~= nil then
        tpHouse = tpInt
    end
    -- Assuming data contains all necessary information
    TriggerServerEvent('bcc-housing:CreationDBInsert', tpHouse, globalHouseData.owner, globalHouseData.radius,
        globalHouseData.doors, globalHouseData.houseCoords, globalHouseData.invLimit, globalHouseData.ownerSource,
        globalHouseData.taxAmount, globalHouseData.ownershipStatus)
    -- Debug to confirm data contents
    devPrint("Sending data to server:", tpHouse, globalHouseData.owner, globalHouseData.radius, globalHouseData.doors, globalHouseData.houseCoords, globalHouseData.invLimit, globalHouseData.ownerSource, globalHouseData.taxAmount)
end

--Used to load houses after given one or given access so you dont have to relog to gain access
RegisterNetEvent('bcc-housing:ClientRecHouseLoad', function(recOwnerSource)
    TriggerServerEvent('bcc-housing:CheckIfHasHouse', recOwnerSource)
end)
