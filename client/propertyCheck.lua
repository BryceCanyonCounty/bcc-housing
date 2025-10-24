local propertyCheckActive = false
local isInsidePrivateProperty = false
local propertyUIVisible = false
local propertyUISuppressed = false
local lastSuppressed = nil
local privateProperties = {}
local currentPropertyKey = nil

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

local function registerPrivateProperty(coords, radius)
    local vec = toVector3(coords)
    if not vec then
        devPrint("Invalid coordinates supplied for private property registration.")
        return
    end

    local key = propertyKeyFromVector(vec)
    local detectionRadius = (tonumber(radius) or 0.0) + 20.0
    local exitRadius = detectionRadius + 2.0
    privateProperties[key] = {
        coords = vec,
        enterRadius = detectionRadius,
        exitRadius = exitRadius
    }
    devPrint(("Registered private property: %s (enter %.2f / exit %.2f)"):format(key, detectionRadius, exitRadius))
end

local function showPropertyUI()
    if not propertyUIVisible then
        SendNUIMessage({ action = "showPropertyUI" })
        propertyUIVisible = true
        devPrint("Property UI shown")
    end
end

local function hidePropertyUI()
    if propertyUIVisible then
        SendNUIMessage({ action = "hidePropertyUI" })
        propertyUIVisible = false
        devPrint("Property UI hidden")
    end
end

RegisterCommand('hidePropertyUI', function()
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
                    devPrint("Private property check disabled; clearing current state.")
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
                        devPrint("Player has left private property (no properties registered).")
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

                for key, data in pairs(privateProperties) do
                    if data.coords and data.enterRadius then
                        local distance = #(playerCoords - data.coords)
                        local threshold = data.enterRadius
                        if isInsidePrivateProperty and currentPropertyKey == key then
                            threshold = data.exitRadius or (data.enterRadius + 2.0)
                        end

                        if distance <= threshold then
                            if not nearestDistance or distance < nearestDistance then
                                nearestDistance = distance
                                insideKey = key
                            end
                        end
                    end
                end

                if insideKey then
                    if not isInsidePrivateProperty or currentPropertyKey ~= insideKey then
                        isInsidePrivateProperty = true
                        currentPropertyKey = insideKey
                        Notify(_U("enteringPrivate"), "info", 3000)
                        if not propertyUISuppressed then
                            showPropertyUI()
                        end
                        devPrint("Player has entered private property.")
                    elseif not propertyUISuppressed and not propertyUIVisible then
                        showPropertyUI()
                    end
                elseif isInsidePrivateProperty then
                    isInsidePrivateProperty = false
                    currentPropertyKey = nil
                    Notify(_U("leavingPrivate"), "info", 4000)
                    hidePropertyUI()
                    devPrint("Player has left private property.")
                end
            end
        end
    end
end)

local function startPrivatePropertyCheck(houseCoords, houseRadius)
    if not Config.EnablePrivatePropertyCheck then
        devPrint("Private property check is disabled in the config.")
        return
    end

    if not houseCoords or not houseRadius then
        devPrint("Error: Missing houseCoords or houseRadius.")
        return
    end

    registerPrivateProperty(houseCoords, houseRadius)
end

local function stopPrivatePropertyCheck()
    privateProperties = {}
    propertyCheckActive = false
    isInsidePrivateProperty = false
    currentPropertyKey = nil
    if propertyUIVisible then
        hidePropertyUI()
    end
    devPrint("Property check has been stopped and all registered properties cleared.")
end

BccUtils.RPC:Register('bcc-housing:PrivatePropertyCheckHandler', function(params)
    if not params or not params.coords then return end
    startPrivatePropertyCheck(params.coords, params.radius)
end)

BccUtils.RPC:Register('bcc-housing:StopPropertyCheck', function()
    stopPrivatePropertyCheck()
end)
