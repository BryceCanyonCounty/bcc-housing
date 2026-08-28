local propertyCheckActive = false
local isInsidePrivateProperty = false
local propertyUIVisible = false
local propertyUISuppressed = false
local lastSuppressed = nil
local privateProperties = {}
local currentPropertyKey = nil
local propertyExitMisses = 0

local menuVisible = false

local function truthy(value)
    return value == true or value == 1 or value == -1
end

local function toVector3(coords)
    if not coords then return nil end
    if type(coords) == "vector3" then
        return coords
    elseif type(coords) == "table" then
        local x = coords.x or coords[1]
        local y = coords.y or coords[2]
        local z = coords.z or coords[3]
        if x and y and z then
            return vector3(tonumber(x) or 0.0, tonumber(y) or 0.0, tonumber(z) or 0.0)
        end
    end
    return nil
end

local function propertyKeyFromVector(vec)
    if not vec then return nil end
    return string.format("%.2f:%.2f:%.2f", vec.x, vec.y, vec.z)
end

local function registerPrivateProperty(coords, radius, houseId, polyPoints, polyMinZ, polyMaxZ, hasAccess)
    local vec = toVector3(coords)
    if not vec then
        DBG:Warning("Invalid coordinates supplied for private property registration.")
        return
    end

    local key = houseId and ('house:%s'):format(tostring(houseId)) or propertyKeyFromVector(vec)
    local detectionRadius = tonumber(radius) or 0.0
    local exitRadius = detectionRadius + 2.0
    local houseIdNumber = tonumber(houseId)
    local normalizedPoly = NormalizeHousingPolyPoints(polyPoints)
    local zone = CreateHousingPolyZone(
        ('bcc-housing-private-%s'):format(tostring(houseIdNumber or key)),
        normalizedPoly,
        polyMinZ,
        polyMaxZ,
        Config.DevMode == true
    )
    privateProperties[key] = {
        coords = vec,
        enterRadius = detectionRadius,
        exitRadius = exitRadius,
        houseid = houseIdNumber,
        polyPoints = normalizedPoly,
        polyMinZ = tonumber(polyMinZ),
        polyMaxZ = tonumber(polyMaxZ),
        hasAccess = hasAccess == true,
        zone = zone,
        spawnState = "cleared",
        devContextCreated = false
    }
    DBG:Info(("Registered private property: %s (enter %.2f / exit %.2f)"):format(key, detectionRadius, exitRadius))
end
local function devModeControlsProperty(entry, distance)
    if not Config.DevMode or not entry or not entry.houseid then
        return false
    end

    local spawnRadius = (entry.enterRadius or 0.0) + 100.0
    if distance <= spawnRadius then
        OwnedHouseContexts = OwnedHouseContexts or {}
        if not OwnedHouseContexts[entry.houseid] then
                            OwnedHouseContexts[entry.houseid] = {
                                coords = entry.coords,
                                radius = entry.enterRadius or Config.DefaultMenuManageRadius or 2.0,
                                polyPoints = entry.polyPoints,
                                polyMinZ = entry.polyMinZ,
                                polyMaxZ = entry.polyMaxZ,
                                zone = entry.zone,
                                houseId = entry.houseid,
                                owner = "devmode",
                                ownershipStatus = "devmode"
            }
        end

        entry.devContextCreated = true

        if SetActiveHouseContext then
            SetActiveHouseContext(OwnedHouseContexts[entry.houseid])
        end

        if StartFurnCheckHandler then
            StartFurnCheckHandler()
        end

        entry.spawnState = "dev_controlled"
        return true
    end

    if entry.spawnState == "dev_controlled" then
        return true
    end

    return false
end

local function showPropertyUI()
    if not propertyUIVisible then
        SendNUIMessage({
            action = "showPropertyUI",
            propertyImage = {
                visible = true,
                title = _U("enteringPrivate") or "Private Property",
                subtitle = ""
            }
        })
        propertyUIVisible = true
        DBG:Info("Property UI shown")
    end
end

local function hidePropertyUI()
    if propertyUIVisible then
        SendNUIMessage({
            action = "hidePropertyUI",
            propertyImage = {
                visible = false
            }
        })
        propertyUIVisible = false
        DBG:Info("Property UI hidden")
    end
end

RegisterCommand(Config.HidePropertyUICommand, function(_, args)
    hidePropertyUI()
end, false)

CreateThread(function()
    while true do
        Wait(100)

        local ped               = PlayerPedId()
        local paused            = IsPauseMenuActive()
        local cinematicOpen     = truthy(IsInCinematicMode())
        local cinematicCam      = IsCinematicCamRendering() or false
        local mapOpen           = truthy(IsUiappActiveByHash(`MAP`))
        local loading           = truthy(IsLoadingScreenVisible())
        local screenFadedOut    = IsScreenFadedOut()
        local screenFadedIn     = IsScreenFadedIn()
        local screenFadingOut   = IsScreenFadingOut()
        local screenFadingIn    = IsScreenFadingIn()
        local gameplayHint      = IsGameplayHintActive()
        local shopBrowsing      = truthy(IsUiappActiveByHash(`SHOP_BROWSING`))
        local dead              = (ped ~= 0 and IsEntityDead(ped))
        local inventoryOpen     = (LocalPlayer and LocalPlayer.state and LocalPlayer.state.IsInvActive == true)

        local suppressed = paused
            or loading
            or screenFadedOut
            or screenFadingOut
            or screenFadingIn
            or (not screenFadedIn and not screenFadingIn)
            or cinematicOpen
            or cinematicCam
            or mapOpen
            or gameplayHint
            or dead
            or shopBrowsing
            or inventoryOpen
            or menuVisible

        if suppressed ~= lastSuppressed then
            lastSuppressed = suppressed
            propertyUISuppressed = suppressed

            if propertyUISuppressed then
                hidePropertyUI()
            else
                if propertyCheckActive and isInsidePrivateProperty then
                    showPropertyUI()
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        if not Config.EnablePrivatePropertyCheck then
            if propertyCheckActive or isInsidePrivateProperty then
                propertyCheckActive = false
                if isInsidePrivateProperty then
                    isInsidePrivateProperty = false
                    currentPropertyKey = nil
                    hidePropertyUI()
                    DBG:Info("Private property check disabled; clearing current state.")
                end
            end
        else
            if next(privateProperties) == nil then
                if propertyCheckActive or isInsidePrivateProperty then
                    propertyCheckActive = false
                    if isInsidePrivateProperty then
                        isInsidePrivateProperty = false
                        currentPropertyKey = nil
                        Notify(_U("leavingPrivate"), "info", 4000)
                        hidePropertyUI()
                        DBG:Info("Player has left private property (no properties registered).")
                    else
                        hidePropertyUI()
                    end
                end
            else
                propertyCheckActive = true

                local ped = PlayerPedId()
                local playerCoords = GetEntityCoords(ped)
                local insideKey = nil
                local nearestDistance = nil
                local currentInside = false

                for key, data in pairs(privateProperties) do
                    if data.coords and data.enterRadius then
                        local distance = #(playerCoords - data.coords)

                        if data.houseid then
                            local spawnHandledByDev = devModeControlsProperty(data, distance)
                            if not spawnHandledByDev then
                                local spawnRadius = (data.enterRadius or 0.0) + 100.0
                                local clearRadius = (data.enterRadius or 0.0) + 200.0
                                if distance <= spawnRadius then
                                    if data.spawnState ~= "spawned" and data.spawnState ~= "pending_spawn" then
                                        data.spawnState = "pending_spawn"
                                        local ok = BccUtils.RPC:CallAsync("bcc-housing:FurniturePlacedCheck", {
                                            houseid = data.houseid,
                                            deletion = false,
                                            close = true
                                        })
                                        data.spawnState = ok and "spawned" or "cleared"
                                    end
                                elseif distance > clearRadius and data.spawnState == "spawned" then
                                    data.spawnState = "pending_clear"
                                    local ok = BccUtils.RPC:CallAsync("bcc-housing:FurniturePlacedCheck", {
                                        houseid = data.houseid,
                                        deletion = true
                                    })
                                    data.spawnState = ok and "cleared" or "spawned"
                                end
                            end
                        end

                        local hasPolyArea = type(data.polyPoints) == "table" and #data.polyPoints >= 3
                        local insideArea = IsPointInsideHousingArea(data, playerCoords)
                        if not insideArea and not hasPolyArea then
                            local threshold = data.enterRadius
                            if isInsidePrivateProperty and currentPropertyKey == key then
                                threshold = data.exitRadius or (data.enterRadius + 2.0)
                            end
                            insideArea = threshold and threshold > 0 and distance <= threshold
                        end

                        if insideArea and not data.hasAccess then
                            if currentPropertyKey == key then
                                currentInside = true
                                nearestDistance = distance
                                insideKey = key
                            elseif not currentInside and (not nearestDistance or distance < nearestDistance) then
                                nearestDistance = distance
                                insideKey = key
                            end
                        end
                    end
                end

                if insideKey then
                    propertyExitMisses = 0
                    if not isInsidePrivateProperty or currentPropertyKey ~= insideKey then
                        isInsidePrivateProperty = true
                        currentPropertyKey = insideKey
                        Notify(_U("enteringPrivate"), "info", 3000)
                        if not propertyUISuppressed then
                            showPropertyUI()
                        end
                        DBG:Info("Player has entered private property.")
                    elseif not propertyUISuppressed and not propertyUIVisible then
                        showPropertyUI()
                    end
                elseif isInsidePrivateProperty then
                    propertyExitMisses = propertyExitMisses + 1
                    if propertyExitMisses >= 3 then
                        propertyExitMisses = 0
                        isInsidePrivateProperty = false
                        currentPropertyKey = nil
                        Notify(_U("leavingPrivate"), "info", 4000)
                        hidePropertyUI()
                        DBG:Info("Player has left private property.")
                    end
                else
                    propertyExitMisses = 0
                end
            end
        end
    end
end)

local function startPrivatePropertyCheck(houseCoords, houseRadius, houseId, polyPoints, polyMinZ, polyMaxZ, hasAccess)
    if not Config.EnablePrivatePropertyCheck then
        DBG:Info("Private property check is disabled in the config.")
        return
    end

    if not houseCoords then
        DBG:Error("Error: Missing houseCoords.")
        return
    end

    registerPrivateProperty(houseCoords, houseRadius, houseId, polyPoints, polyMinZ, polyMaxZ, hasAccess)
end

local function stopPrivatePropertyCheck()
    privateProperties = {}
    propertyCheckActive = false
    isInsidePrivateProperty = false
    currentPropertyKey = nil
    if propertyUIVisible then
        hidePropertyUI()
    end
    DBG:Info("Property check has been stopped and all registered properties cleared.")
end

BccUtils.RPC:Register('bcc-housing:PrivatePropertyCheckHandler', function(params)
    if not params or not params.coords then return end
    startPrivatePropertyCheck(params.coords, params.radius, params.houseid, params.polyPoints, params.polyMinZ, params.polyMaxZ, params.hasAccess)
end)

BccUtils.RPC:Register('bcc-housing:StopPropertyCheck', function()
    stopPrivatePropertyCheck()
end)
