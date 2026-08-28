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
    polyPoints = {},
    polyMinZ = nil,
    polyMaxZ = nil,
}

-- When creating a house
local function afterSelectingOwner(tpHouse)
    CreateHouseMenu(tpHouse) -- This might initialize house creation or whatever is appropriate after selecting an owner
end

local function ensurePolyState()
    globalHouseData.polyPoints = globalHouseData.polyPoints or {}
end

local function canUseHousingPolyCommand()
    local allowed = BccUtils.RPC:CallAsync('bcc-housing:CheckIfAdmin')
    return allowed == true
end

local housingPolyPrompts = {}
local housingPolyCapture = {
    active = false,
    targetHouseId = nil,
    saveMode = 'new'
}
local housingPolyPreviewZone = nil
local DEFAULT_HOUSING_POLY_CEILING_OFFSET = 5.0
local HOUSING_POLY_GROUND_VISUAL_OFFSET = 0.12

local function getCurrentGroundZ(coords)
    if not coords then
        return nil
    end

    local foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z + 1.0)
    if foundGround then
        return groundZ
    end

    return coords.z
end

local function getPolySummary()
    ensurePolyState()
    return {
        pointCount = #globalHouseData.polyPoints,
        minZ = globalHouseData.polyMinZ,
        maxZ = globalHouseData.polyMaxZ
    }
end

local function refreshPolyVerticalBounds()
    ensurePolyState()
    local minZ, maxZ

    for _, point in ipairs(globalHouseData.polyPoints) do
        local pointZ = tonumber(point.z)
        if pointZ then
            minZ = minZ and math.min(minZ, pointZ) or pointZ
            maxZ = maxZ and math.max(maxZ, pointZ) or pointZ
        end
    end

    if minZ and maxZ then
        globalHouseData.polyMinZ = minZ
        globalHouseData.polyMaxZ = maxZ + DEFAULT_HOUSING_POLY_CEILING_OFFSET
        return true
    end

    return false
end

local function cleanupHousingPolyPreview()
    if housingPolyPreviewZone and housingPolyPreviewZone.destroy then
        housingPolyPreviewZone:destroy()
    end
    housingPolyPreviewZone = nil
end

local function refreshHousingPolyPreview()
    cleanupHousingPolyPreview()
    ensurePolyState()
    if #globalHouseData.polyPoints < 3 then
        return
    end

    local vectors = {}
    for _, point in ipairs(globalHouseData.polyPoints) do
        vectors[#vectors + 1] = vector2(point.x, point.y)
    end

    housingPolyPreviewZone = PolyZone:Create(vectors, {
        name = 'bcc-housing-poly-preview',
        debugPoly = true,
        minZ = globalHouseData.polyMinZ,
        maxZ = globalHouseData.polyMaxZ,
        debugColors = {
            walls = { 0, 180, 90 },
            outline = { 0, 180, 90 }
        }
    })
end

local function notifyPolyHelp()
    Notify('/' .. tostring(Config.HousingPolyZoneCommand) ..
        ' start | edit <houseId> | stop | status | export', 'info', 7000)
end

local function exportCurrentPolyZone()
    ensurePolyState()

    if #globalHouseData.polyPoints < 3 then
        Notify('At least 3 poly points are required before export', 'error', 4000)
        return
    end

    local lines = {
        'polyPoints = {'
    }

    for _, point in ipairs(globalHouseData.polyPoints) do
        lines[#lines + 1] = ('    { x = %.2f, y = %.2f, z = %.2f },'):format(
            tonumber(point.x) or 0.0,
            tonumber(point.y) or 0.0,
            tonumber(point.z) or tonumber(globalHouseData.polyMinZ) or 0.0
        )
    end

    lines[#lines + 1] = '},'
    lines[#lines + 1] = ('polyMinZ = %.2f,'):format(tonumber(globalHouseData.polyMinZ) or 0.0)
    lines[#lines + 1] = ('polyMaxZ = %.2f,'):format(tonumber(globalHouseData.polyMaxZ) or 0.0)

    local exportText = table.concat(lines, '\n')
    print('[bcc-housing] Housing Poly Export:\n' .. exportText)
    Notify('Polyzone exported to F8/client console', 'success', 5000)
end

local function addCurrentPolyPoint()
    ensurePolyState()
    local coords = GetEntityCoords(PlayerPedId())
    local groundZ = getCurrentGroundZ(coords)
    globalHouseData.polyPoints[#globalHouseData.polyPoints + 1] = {
        x = coords.x,
        y = coords.y,
        z = groundZ
    }
    refreshPolyVerticalBounds()
    refreshHousingPolyPreview()
    Notify(("Poly point #%d saved | floor %.2f | ceiling %.2f"):format(
        #globalHouseData.polyPoints,
        globalHouseData.polyMinZ,
        globalHouseData.polyMaxZ
    ), "success", 4000)
end

local function undoCurrentPolyPoint()
    ensurePolyState()
    if #globalHouseData.polyPoints > 0 then
        table.remove(globalHouseData.polyPoints)
        if not refreshPolyVerticalBounds() then
            globalHouseData.polyMinZ = nil
            globalHouseData.polyMaxZ = nil
        end
        refreshHousingPolyPreview()
        Notify("Last poly point removed", "success", 4000)
    else
        Notify("No poly points to remove", "error", 4000)
    end
end

local function setCurrentPolyFloor()
    local coords = GetEntityCoords(PlayerPedId())
    local groundZ = getCurrentGroundZ(coords)
    globalHouseData.polyMinZ = groundZ
    refreshHousingPolyPreview()
    Notify(("Poly floor set to %.2f"):format(groundZ), "success", 4000)
end

local function setCurrentPolyCeiling()
    local baseMinZ = tonumber(globalHouseData.polyMinZ)
    if not baseMinZ then
        local coords = GetEntityCoords(PlayerPedId())
        baseMinZ = getCurrentGroundZ(coords)
        globalHouseData.polyMinZ = baseMinZ
    end

    globalHouseData.polyMaxZ = baseMinZ + DEFAULT_HOUSING_POLY_CEILING_OFFSET
    refreshHousingPolyPreview()
    Notify(("Poly ceiling set to %.2f (floor + %.1f)"):format(globalHouseData.polyMaxZ, DEFAULT_HOUSING_POLY_CEILING_OFFSET), "success", 4000)
end

local function clearCurrentPolyZone()
    cleanupHousingPolyPreview()
    globalHouseData.polyPoints = {}
    globalHouseData.polyMinZ = nil
    globalHouseData.polyMaxZ = nil
    Notify("Poly zone cleared", "success", 4000)
end

local function getHousingPolyKeyCode(keyName, fallback)
    if not keyName or keyName == '' then return fallback end
    keyName = keyName:upper()
    return (BccUtils.Keys and BccUtils.Keys[keyName]) or fallback
end

local function deleteHousingPolyPrompts()
    for _, prompt in pairs(housingPolyPrompts) do
        if type(prompt) == 'table' and prompt.DeletePrompt then
            prompt:DeletePrompt()
        end
    end
    housingPolyPrompts = {}
end

local function ensureHousingPolyPromptGroup()
    if housingPolyPrompts.group then return end
    housingPolyPrompts.group = BccUtils.Prompts:SetupPromptGroup()
    housingPolyPrompts.add = housingPolyPrompts.group:RegisterPrompt('Add point', getHousingPolyKeyCode(Config.HousingPolyPointPromptKey, 0xE30CD707), 1, 1, true, 'click', { tabIndex = 0 })
    housingPolyPrompts.undo = housingPolyPrompts.group:RegisterPrompt('Undo last point', getHousingPolyKeyCode(Config.HousingPolyUndoPromptKey, 0x156F7119), 1, 1, true, 'click', { tabIndex = 1 })
    housingPolyPrompts.save = housingPolyPrompts.group:RegisterPrompt('Save polyzone', getHousingPolyKeyCode(Config.HousingPolySavePromptKey, 0xC7B5340A), 1, 1, true, 'click', { tabIndex = 2 })
    housingPolyPrompts.cancel = housingPolyPrompts.group:RegisterPrompt('Cancel', getHousingPolyKeyCode(Config.HousingPolyCancelPromptKey, 0x8CC9CD42), 1, 1, true, 'click', { tabIndex = 3 })
    housingPolyPrompts.floor = housingPolyPrompts.group:RegisterPrompt('Set floor', getHousingPolyKeyCode(Config.HousingPolyFloorPromptKey, 0x3C3DD371), 1, 1, true, 'click', { tabIndex = 4 })
    housingPolyPrompts.ceiling = housingPolyPrompts.group:RegisterPrompt('Set ceiling', getHousingPolyKeyCode(Config.HousingPolyCeilingPromptKey, 0x446258B6), 1, 1, true, 'click', { tabIndex = 5 })
end

local function stopHousingPolyCapture(skipNotify)
    cleanupHousingPolyPreview()
    deleteHousingPolyPrompts()
    housingPolyCapture.active = false
    housingPolyCapture.targetHouseId = nil
    housingPolyCapture.saveMode = 'new'
    if not skipNotify then
        Notify('Housing polyzone capture stopped', 'info', 4000)
    end
end

local function drawHousingPolyDebug()
    ensurePolyState()
    if #globalHouseData.polyPoints == 0 then
        return
    end

    local fallbackFloorZ = tonumber(globalHouseData.polyMinZ)
    if not fallbackFloorZ then
        local playerCoords = GetEntityCoords(PlayerPedId())
        fallbackFloorZ = getCurrentGroundZ(playerCoords)
    end

    for index, point in ipairs(globalHouseData.polyPoints) do
        local pointGroundZ = tonumber(point.z) or getCurrentGroundZ({
            x = point.x,
            y = point.y,
            z = (fallbackFloorZ or 0.0) + 1.0
        }) or fallbackFloorZ or 0.0

        DrawMarker(
            2,
            point.x, point.y, pointGroundZ + HOUSING_POLY_GROUND_VISUAL_OFFSET,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.14, 0.14, 0.14,
            0, 180, 90, 180,
            false, true, 2, false, nil, nil, false
        )

        if index > 1 then
            local prevPoint = globalHouseData.polyPoints[index - 1]
            local prevPointGroundZ = tonumber(prevPoint.z) or getCurrentGroundZ({
                x = prevPoint.x,
                y = prevPoint.y,
                z = (fallbackFloorZ or pointGroundZ or 0.0) + 1.0
            }) or pointGroundZ
            DrawLine(
                prevPoint.x, prevPoint.y, prevPointGroundZ + HOUSING_POLY_GROUND_VISUAL_OFFSET,
                point.x, point.y, pointGroundZ + HOUSING_POLY_GROUND_VISUAL_OFFSET,
                0, 180, 90, 220
            )
        end
    end

    if #globalHouseData.polyPoints > 2 then
        local firstPoint = globalHouseData.polyPoints[1]
        local lastPoint = globalHouseData.polyPoints[#globalHouseData.polyPoints]
        local firstPointGroundZ = tonumber(firstPoint.z) or getCurrentGroundZ({
            x = firstPoint.x,
            y = firstPoint.y,
            z = (fallbackFloorZ or 0.0) + 1.0
        }) or fallbackFloorZ or 0.0
        local lastPointGroundZ = tonumber(lastPoint.z) or getCurrentGroundZ({
            x = lastPoint.x,
            y = lastPoint.y,
            z = (fallbackFloorZ or firstPointGroundZ or 0.0) + 1.0
        }) or firstPointGroundZ

        DrawLine(
            lastPoint.x, lastPoint.y, lastPointGroundZ + HOUSING_POLY_GROUND_VISUAL_OFFSET,
            firstPoint.x, firstPoint.y, firstPointGroundZ + HOUSING_POLY_GROUND_VISUAL_OFFSET,
            0, 180, 90, 120
        )
    end
end

local function saveHousingPolyCapture()
    ensurePolyState()
    if #globalHouseData.polyPoints < 3 then
        Notify('At least 3 poly points are required', 'error', 4000)
        return
    end

    if housingPolyCapture.saveMode == 'existing' and housingPolyCapture.targetHouseId then
        local success, response = BccUtils.RPC:CallAsync('bcc-housing:SaveExistingHousePolyZone', {
            houseId = housingPolyCapture.targetHouseId,
            polyPoints = globalHouseData.polyPoints,
            polyMinZ = globalHouseData.polyMinZ,
            polyMaxZ = globalHouseData.polyMaxZ
        })
        if not success then
            Notify('Failed to save house polyzone', 'error', 4000)
            return
        end
        Notify(('Polyzone saved for house ID %s'):format(tostring(housingPolyCapture.targetHouseId)), 'success', 5000)
        BccUtils.RPC:CallAsync('bcc-housing:CheckIfHasHouse', {})
        stopHousingPolyCapture(true)
        return
    end

    Notify('Polyzone saved in current creation data. Confirm the house to write it to database.', 'success', 6000)
    stopHousingPolyCapture(true)
end

local function startHousingPolyCapture(mode, houseId)
    if housingPolyCapture.active then
        stopHousingPolyCapture(true)
    end

    ensurePolyState()
    if mode == 'existing' then
        clearCurrentPolyZone()
        housingPolyCapture.targetHouseId = tonumber(houseId)
        housingPolyCapture.saveMode = 'existing'
        Notify(('Polyzone capture started for house ID %s'):format(tostring(housingPolyCapture.targetHouseId)), 'info', 5000)
    else
        housingPolyCapture.targetHouseId = nil
        housingPolyCapture.saveMode = 'new'
        Notify('Polyzone capture started for new house', 'info', 5000)
    end

    housingPolyCapture.active = true
    ensureHousingPolyPromptGroup()
end

RegisterCommand(Config.HousingPolyZoneCommand, function(_, args)
    if not canUseHousingPolyCommand() then
        Notify('You do not have permission to use this command.', 'error', 4000)
        return
    end

    local action = args and args[1] and string.lower(args[1]) or 'help'

    if action == 'start' then
        clearCurrentPolyZone()
        startHousingPolyCapture('new')
        return
    end

    if action == 'edit' then
        local houseId = tonumber(args and args[2])
        if not houseId then
            Notify('Usage: /' .. tostring(Config.HousingPolyZoneCommand) .. ' edit <houseId>', 'error', 5000)
            return
        end
        startHousingPolyCapture('existing', houseId)
        return
    end

    if action == 'stop' then
        stopHousingPolyCapture()
        return
    end

    if action == 'status' then
        local summary = getPolySummary()
        Notify(("Poly points: %d | floor: %s | ceiling: %s"):format(
            summary.pointCount,
            summary.minZ and string.format('%.2f', summary.minZ) or 'unset',
            summary.maxZ and string.format('%.2f', summary.maxZ) or 'unset'
        ), 'info', 7000)
        return
    end

    if action == 'export' then
        exportCurrentPolyZone()
        return
    end

    notifyPolyHelp()
end, false)

CreateThread(function()
    while true do
        if housingPolyCapture.active and housingPolyPrompts.group then
            Wait(0)
            local summary = getPolySummary()
            local modeLabel = housingPolyCapture.saveMode == 'existing'
                and ('Edit House %s'):format(tostring(housingPolyCapture.targetHouseId))
                or 'New House'
            local promptText = ('Housing PolyZone (%s)\nPoints: %d | MinZ: %s | MaxZ: %s'):format(
                modeLabel,
                summary.pointCount,
                summary.minZ and string.format('%.2f', summary.minZ) or 'unset',
                summary.maxZ and string.format('%.2f', summary.maxZ) or 'unset'
            )
            housingPolyPrompts.group:ShowGroup(promptText, 6, 0, 0, 0)

            if housingPolyPrompts.add and housingPolyPrompts.add:HasCompleted(true) then
                addCurrentPolyPoint()
            end

            if housingPolyPrompts.undo and housingPolyPrompts.undo:HasCompleted(true) then
                undoCurrentPolyPoint()
            end

            if housingPolyPrompts.floor and housingPolyPrompts.floor:HasCompleted(true) then
                setCurrentPolyFloor()
            end

            if housingPolyPrompts.ceiling and housingPolyPrompts.ceiling:HasCompleted(true) then
                setCurrentPolyCeiling()
            end

            if housingPolyPrompts.save and housingPolyPrompts.save:HasCompleted(true) then
                saveHousingPolyCapture()
            end

            if housingPolyPrompts.cancel and housingPolyPrompts.cancel:HasCompleted(true) then
                stopHousingPolyCapture()
            end

            drawHousingPolyDebug()
        else
            Wait(400)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    stopHousingPolyCapture(true)
end)

function PlayerListMenu(houseId, callback, context)
    BCCHousingMenu:Close()
    
    if HandlePlayerDeathAndCloseMenu() then
        return
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
                Notify(_U("OwnerSet"), "success", 4000)
            elseif context == "giveAccess" then
                Notify(_U("givenAccess"), "success", 4000)
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
        return
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
            DBG:Info("Selected door with ID:", door.id)
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
        return
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
        return
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
        style = { ['position'] = 'relative', ['z-index'] = 9 }
    }, function()
        local success, houses = BccUtils.RPC:CallAsync('bcc-housing:AdminGetAllHouses', {})
        if success and houses then
            AdminManagementMenu(houses) -- directly open the admin management menu
        else
            DBG:Error("Failed to retrieve admin houses: " .. tostring(houses and houses.error))
        end
    end)

    HouseManagementList:RegisterElement('button', {
        label = _U('manageConfigHouses'),
        style = { ['position'] = 'relative', ['z-index'] = 9 }
    }, function()
        AdminConfigHousesMenu()
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
    DBG:Info("Adjusted tp in CreateHouseMenu:", tp)
    -- Close any existing menus, assuming BCCHousingMenu is your FeatherMenu instance
    BCCHousingMenu:Close()

    if HandlePlayerDeathAndCloseMenu() then
        return
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
        DBG:Info("house coords set to:", globalHouseData.houseCoords)
        Notify(_U("houseCoordsSet"), "success", 4000)
    end)

    createHouseMenu:RegisterElement('button', {
        label = "Add Poly Point",
        style = {}
    }, function()
        addCurrentPolyPoint()
    end)

    createHouseMenu:RegisterElement('button', {
        label = "Undo Poly Point",
        style = {}
    }, function()
        undoCurrentPolyPoint()
    end)

    createHouseMenu:RegisterElement('button', {
        label = "Set Poly Floor",
        style = {}
    }, function()
        setCurrentPolyFloor()
    end)

    createHouseMenu:RegisterElement('button', {
        label = "Set Poly Ceiling",
        style = {}
    }, function()
        setCurrentPolyCeiling()
    end)

    createHouseMenu:RegisterElement('button', {
        label = "Clear Poly Zone",
        style = {}
    }, function()
        clearCurrentPolyZone()
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
        DBG:Info("house sell type set to:", globalHouseData.ownershipStatus)
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
        return
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
            DBG:Info("Radius set to:", globalHouseData.radius)
        else
            globalHouseData.radius = nil -- Ensure radius is nil if input is invalid
            DBG:Warning("Invalid input for amount.")
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
            Notify(_U("radiusSet"), "success", 4000)
            CreateHouseMenu(tpHouse) -- Optionally return to the house creation menu
        else
            Notify(_U("InvalidInput"), "error", 4000)
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
        return
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
            DBG:Info("Tax amount set to:", globalHouseData.taxAmount)
        else
            globalHouseData.taxAmount = nil -- Reset if invalid input
            DBG:Warning("Invalid input for tax amount.")
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
            Notify(_U("taxAmountSet"), "success", 4000)
            CreateHouseMenu(tpHouse) -- Optionally navigate back to the house creation menu
        else
            Notify(_U("InvalidInput"), "error", 4000)
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
        return
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
            DBG:Info("Inventory limit set to:", globalHouseData.invLimit)
        else
            globalHouseData.invLimit = nil
            DBG:Warning("Invalid input for inventory limit.")
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
            local success, err = BccUtils.RPC:CallAsync('bcc-housing:SetInventoryLimit', {
                invLimit = globalHouseData.invLimit,
                houseId = houseId
            })
            if not success then
                DBG:Error("Failed to set inventory limit via RPC: " .. tostring(err and err.error))
            end
            CreateHouseMenu(tpHouse) -- Optionally navigate back to the house creation menu
            Notify(_U("invLimitSet"), "success", 4000)
        else
            DBG:Error("Error: Inventory limit not set or invalid.")
            Notify(_U("InvalidInput"), "error", 4000)
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
        DBG:Error("Error: Data object is nil")
        return
    end
    local hasPoly = globalHouseData.polyPoints and #globalHouseData.polyPoints >= 3
    if not globalHouseData.owner or (not globalHouseData.radius and not hasPoly) or not globalHouseData.doors or not globalHouseData.houseCoords or not globalHouseData.invLimit or not globalHouseData.ownerSource or not globalHouseData.taxAmount then
        DBG:Error("Error: One or more required fields are missing in the data object")
        return
    end
    local tpHouse = false
    if tpInt ~= nil then
        tpHouse = tpInt
    end
    -- Assuming data contains all necessary information
    local success, err = BccUtils.RPC:CallAsync('bcc-housing:CreationDBInsert', {
        tpHouse = tpHouse,
        owner = globalHouseData.owner,
        radius = globalHouseData.radius,
        doors = globalHouseData.doors,
        houseCoords = globalHouseData.houseCoords,
        invLimit = globalHouseData.invLimit,
        ownerSource = globalHouseData.ownerSource,
        taxAmount = globalHouseData.taxAmount,
        ownershipStatus = globalHouseData.ownershipStatus,
        polyPoints = globalHouseData.polyPoints,
        polyMinZ = globalHouseData.polyMinZ,
        polyMaxZ = globalHouseData.polyMaxZ
    })
    if not success then
        DBG:Info("CreationDBInsert RPC failed: " .. tostring(err and err.error))
    end
    -- Debug to confirm data contents
    DBG:Info("Sending data to server:", tpHouse, globalHouseData.owner, globalHouseData.radius, globalHouseData.doors, globalHouseData.houseCoords, globalHouseData.invLimit, globalHouseData.ownerSource, globalHouseData.taxAmount)
end

BccUtils.RPC:Register('bcc-housing:ClientRecHouseLoad', function()
    BccUtils.RPC:CallAsync('bcc-housing:CheckIfHasHouse', {})
end)
