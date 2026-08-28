----- Pulling Essentials -----
VORPcore = exports.vorp_core:GetCore()

FeatherMenu = exports["feather-menu"].initiate()
MiniGame = exports["bcc-minigames"].initiate()

HousingInstance = {}

local function normalizePolyPoints(points)
    if type(points) ~= "table" or #points < 3 then
        return nil
    end

    local normalized = {}
    for _, point in ipairs(points) do
        local x = point.x or point[1]
        local y = point.y or point[2]
        if x and y then
            local z = point.z or point[3]
            local normalizedPoint = {
                x = tonumber(x) or 0.0,
                y = tonumber(y) or 0.0
            }
            if z then
                normalizedPoint.z = tonumber(z) or 0.0
            end
            normalized[#normalized + 1] = normalizedPoint
        end
    end

    if #normalized < 3 then
        return nil
    end

    return normalized
end

function NormalizeHousingPolyPoints(points)
    return normalizePolyPoints(points)
end

local function polyPointsHaveZ(points)
    if type(points) ~= "table" then
        return false
    end

    for _, point in ipairs(points) do
        if point.z or point[3] then
            return true
        end
    end

    return false
end

local function isPointInsidePolyXY(points, point)
    local inside = false
    local j = #points

    for i = 1, #points do
        local pi = points[i]
        local pj = points[j]

        if ((pi.y > point.y) ~= (pj.y > point.y)) then
            local crossX = ((pj.x - pi.x) * (point.y - pi.y) / ((pj.y - pi.y) + 0.000001)) + pi.x
            if point.x < crossX then
                inside = not inside
            end
        end

        j = i
    end

    return inside
end

local function getPointGroundZ(point)
    if not point then
        return nil
    end

    local foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(point.x, point.y, (point.z or 0.0) + 3.0)
    if foundGround then
        return groundZ
    end

    return point.z
end

local function getPolyPointZRange(points)
    local minZ, maxZ
    for _, point in ipairs(points or {}) do
        local pointZ = tonumber(point.z)
        if pointZ then
            minZ = minZ and math.min(minZ, pointZ) or pointZ
            maxZ = maxZ and math.max(maxZ, pointZ) or pointZ
        end
    end

    return minZ, maxZ
end

function CreateHousingPolyZone(name, points, minZ, maxZ, debugPoly)
    local normalized = normalizePolyPoints(points)
    if not normalized then
        return nil
    end

    local vectors = {}
    for _, point in ipairs(normalized) do
        vectors[#vectors + 1] = vector2(point.x, point.y)
    end

    return PolyZone:Create(vectors, {
        name = name or 'bcc-housing-zone',
        minZ = tonumber(minZ),
        maxZ = tonumber(maxZ),
        debugPoly = debugPoly == true and not polyPointsHaveZ(normalized)
    })
end

function IsPointInsideHousingArea(areaContext, point)
    if not areaContext or not point then
        return false
    end

    if polyPointsHaveZ(areaContext.polyPoints) then
        local points = NormalizeHousingPolyPoints(areaContext.polyPoints)
        if points and isPointInsidePolyXY(points, point) then
            local lowestPointZ, highestPointZ = getPolyPointZRange(points)
            local minZ = tonumber(areaContext.polyMinZ) or lowestPointZ
            local maxZ = tonumber(areaContext.polyMaxZ) or (highestPointZ and highestPointZ + 5.0)
            if minZ and maxZ then
                return point.z >= (minZ - 2.0) and point.z <= (maxZ + 2.0)
            end

            return true
        end

        return false
    end

    if areaContext.zone and areaContext.zone.isPointInside then
        return areaContext.zone:isPointInside(point)
    end

    local coords = areaContext.coords
    local radius = tonumber(areaContext.radius)
    if not coords or not radius or radius <= 0 then
        return false
    end

    return GetDistanceBetweenCoords(point.x, point.y, point.z, coords.x, coords.y, coords.z, true) <= radius
end

function HousingInstance.Set(bucketId)
    bucketId = tonumber(bucketId) or 0
    local success, response = BccUtils.RPC:CallAsync('bcc-housing:SetInstance', { bucketId = bucketId })
    if not success then
        DBG:Error("Failed to set instance: " .. tostring(response and response.error))
    end
    return success, response
end

function HousingInstance.Clear()
    local success, response = BccUtils.RPC:CallAsync('bcc-housing:LeaveInstance', {})
    if not success then
        -- Use the local debug instance to avoid nil access when the RPC fails
        DBG:Error("Failed to clear instance: " .. tostring(response and response.error))
    end
    return success, response
end

function HousingInstance.Compute(offset)
    offset = tonumber(offset) or 0
    return GetPlayerServerId(PlayerId()) + offset
end

function HousingInstance.Auto(offset)
    local bucketId = HousingInstance.Compute(offset)
    HousingInstance.Set(bucketId)
    return bucketId
end

BCCHousingMenu = FeatherMenu:RegisterMenu("bcc:housing:mainmenu",
    {
        top = "5%",
        left = "5%",
        ['720width'] = '400px',
        ['1080width'] = '500px',
        ['2kwidth'] = '600px',
        ['4kwidth'] = '800px',
        style = {
            --['font-size'] = '18px',
        },
        contentslot = {
            style = {
                ['height'] = '450px',
                ['min-height'] = '300px'
            }
        },
        draggable = true
    },
    {
        opened = function()
            DisplayRadar(false)
        end,
        closed = function()
            DisplayRadar(true)
            ClearVendorPreview()
            EndCam()
            if stopHouseAreaPreview then
                if SuppressHousePreviewStopOnMenuClose then
                    SuppressHousePreviewStopOnMenuClose = false
                else
                    stopHouseAreaPreview()
                end
            end
        end
    }
)

local ManageHousePrompts = {}

function RemoveManagePrompt(houseId)
    if houseId then
        local promptData = ManageHousePrompts[houseId]
        if promptData and promptData.prompt then
            promptData.prompt:DeletePrompt()
        end
        ManageHousePrompts[houseId] = nil
        return
    end

    for id, promptData in pairs(ManageHousePrompts) do
        if promptData.prompt then
            promptData.prompt:DeletePrompt()
        end
        ManageHousePrompts[id] = nil
    end
end

function Notify(message, typeOrDuration, maybeDuration, overrides)
    overrides = overrides or {}
    local opts = Config.NotifyOptions or {}

    local notifyType = opts.type or "info"
    local notifyDuration = opts.autoClose or 4000

    if type(typeOrDuration) == "string" then
        notifyType = typeOrDuration
        notifyDuration = tonumber(maybeDuration) or notifyDuration
    elseif type(typeOrDuration) == "number" then
        notifyDuration = typeOrDuration
    end

    local notifyPosition = overrides.position or opts.position or "bottom-center"
    local notifyTransition = overrides.transition or opts.transition or "slide"
    local notifyIcon = overrides.icon
    if notifyIcon == nil then notifyIcon = opts.icon end
    local hideProgressBar = overrides.hideProgressBar
    if hideProgressBar == nil then hideProgressBar = opts.hideProgressBar end
    local rtl = overrides.rtl
    if rtl == nil then rtl = opts.rtl end

    if Config.Notify == "feather-menu" then
        FeatherMenu:Notify({
            message = message,
            type = notifyType,
            autoClose = notifyDuration,
            position = notifyPosition,
            transition = notifyTransition,
            icon = notifyIcon,
            hideProgressBar = hideProgressBar,
            rtl = rtl or false,
            style = overrides.style or opts.style or {},
            toastStyle = overrides.toastStyle or opts.toastStyle or {},
            progressStyle = overrides.progressStyle or opts.progressStyle or {}
        })
    elseif Config.Notify == "vorp-core" then
        VORPcore.NotifyRightTip(message, notifyDuration)
    else
        DBG:Info("^1[Notify] Invalid Config.Notify: " .. tostring(Config.Notify))
    end
end

BccUtils.RPC:Register("bcc-housing:NotifyClient", function(data)
    if not data or not data.message then return end

    local notifyType = data.type
    local duration = tonumber(data.duration)

    Notify(data.message, notifyType, duration)
end)

function LoadModel(model, modelName)
    if not IsModelValid(model) then
        DBG:Warning('Invalid model:', modelName)
        return
    end

    RequestModel(model, false)

    local timeout = 10000
    local startTime = GetGameTimer()

    while not HasModelLoaded(model) do
        if GetGameTimer() - startTime > timeout then
            print('Failed to load model:', modelName)
            return
        end
        Wait(10)
    end
end

-------- Get Players Function --------
function GetPlayers()
    local success, playersData = BccUtils.RPC:CallAsync("bcc-housing:GetPlayers", {})
    if success and type(playersData) == "table" then
        return playersData
    end
    return {}
end

function GetPlayersWithAccess(houseId, callback)
    DBG:Info("Requesting players with access for House ID: " .. tostring(houseId))

    -- Use RPC to call the server-side function and handle the response
    BccUtils.RPC:Call("bcc-housing:GetPlayersWithAccess", { houseId = houseId }, function(result)
        if result and #result > 0 then
            DBG:Info("Number of players with access received: " .. tostring(#result))
            for _, player in ipairs(result) do
                DBG:Info("Player: ID=" .. player.charidentifier .. ", Name=" .. player.firstname .. " " .. player.lastname)
            end
            callback(result) -- Pass the result to the callback
        else
            DBG:Info("No players with access received.")
            callback({})
        end

    end)
end


function showManageOpt(x, y, z, houseId, houseContext)
    RemoveManagePrompt(houseId)

    local promptGroup = BccUtils.Prompts:SetupPromptGroup()
    local promptHandle = promptGroup:RegisterPrompt(_U("openOwnerManage"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'click', nil)
    local radiusValue = 2.0
    ManageHousePrompts[houseId] = {
        prompt = promptHandle,
        group = promptGroup,
        coords = vector3(x, y, z),
        active = true,
        radius = radiusValue,
        context = houseContext
    }

    DBG:Info("Setting up manage options for House ID: " .. tostring(houseId) .. " at coordinates: " .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z))

    local houseExists = false
    local success, data = BccUtils.RPC:CallAsync('bcc-housing:CheckIfHouseExists', { houseId = houseId })
    if success and data then
        houseExists = data.exists
    end

    if not houseExists then
        DBG:Info("House ID " .. tostring(houseId) .. " no longer exists. Deleting prompt.")
        RemoveManagePrompt(houseId)
        return
    end

    Citizen.CreateThread(function()
        local promptVisible = false
        local lastOverdueNoticeAt = 0
        while true do
            local sleep = 500
            local promptData = ManageHousePrompts[houseId]
            if not promptData or not promptData.active or not promptData.prompt then
                break
            end

            local playerPed = PlayerPedId()
            if IsEntityDead(playerPed) then
                promptVisible = false
                goto END
            end

            if BreakHandleLoop then
                DBG:Info("Breaking handle loop for House ID: " .. tostring(houseId))
                break
            end

            if houseExists then
                local plc = GetEntityCoords(playerPed)
                local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, x, y, z, true)
                local openRadius = tonumber(promptData.radius) or 2.0
                local closeRadius = openRadius + 0.35

                if dist < openRadius or (promptVisible and dist < closeRadius) then
                    sleep = 0
                    promptVisible = true
                    promptData.group:ShowGroup(_U("house"))

                    if promptData.prompt:HasCompleted() then
                        DBG:Info("Prompt completed. Opening housing management menu for House ID: " .. tostring(houseId))
                        local ctx = promptData.context or GetHouseContext and GetHouseContext(houseId)
                        if ctx then
                            SetActiveHouseContext(ctx)
                        end

                        local successOwner, ownerData = BccUtils.RPC:CallAsync('bcc-housing:getHouseOwner', { houseId = houseId })
                        if successOwner and ownerData then
                            if ownerData.taxesOverdue then
                                local now = GetGameTimer()
                                if now - lastOverdueNoticeAt > 3000 then
                                    lastOverdueNoticeAt = now
                                    Notify(_U("taxesOverdue"), 'error', 5000)
                                    Notify(_U("overdueDiscordContact"), 'info', 7000)
                                end
                                goto END
                            end

                            local ctx = GetHouseContext and GetHouseContext(houseId)
                            if ctx then
                                ctx.taxesOverdue = false
                                ctx.taxPaymentReleased = ownerData.taxPaymentReleased == true
                                SetActiveHouseContext(ctx)
                            elseif HouseId and tonumber(houseId) == tonumber(HouseId) then
                                HouseTaxesOverdue = false
                                HouseTaxPaymentReleased = ownerData.taxPaymentReleased == true
                            end

                            OpenHousingMainMenu(houseId, ownerData.isOwner, ownerData.ownershipStatus, ownerData.taxPaymentReleased)
                        else
                            local err = ownerData and ownerData.error
                            if err then
                                Notify(err, 'error', 4000)
                            end
                        end
                    end
                else
                    promptVisible = false
                    if dist > 200 then
                        sleep = 2000
                    elseif dist < 50 then
                        sleep = 100
                    end
                end
            else
                promptVisible = false
                sleep = 1000
            end
            ::END::
            Citizen.Wait(sleep)
        end

        RemoveManagePrompt(houseId)
    end)
end

AddEventHandler("onClientResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        SendNUIMessage({ action = "controls:update", controls = {} })
        -- Delete any created furniture
        DBG:Info(("[ResourceStop] Cleaning up %d created furniture entities"):format(
            (CreatedFurniture and #CreatedFurniture) or 0))
        if CreatedFurniture and #CreatedFurniture > 0 then
            for _, entity in ipairs(CreatedFurniture) do
                if DoesEntityExist(entity) then
                    DeleteEntity(entity)
                    DBG:Info(("[ResourceStop] Deleted entity id %s"):format(tostring(entity)))
                else
                    DBG:Info(("[ResourceStop] Entity id %s already removed"):format(tostring(entity)))
                end
            end
            CreatedFurniture = {}
        end

        -- Remove any blips that were created
        if HouseBlips and next(HouseBlips) then
            for k, v in pairs(HouseBlips) do
                if v and v.rawblip then
                    BccUtils.Blips:RemoveBlip(v.rawblip)
                end
            end
            HouseBlips = {}
        end

        for _, shopCfg in pairs(Agents) do
            if shopCfg.Blip then
                RemoveBlip(shopCfg.Blip)
                shopCfg.Blip = nil
            end
            if shopCfg.NPC then
                DeleteEntity(shopCfg.NPC)
                shopCfg.NPC = nil
            end
        end

        if HotelBlips and next(HotelBlips) then
            for k, v in pairs(HotelBlips) do
                if v and v.rawblip then
                    BccUtils.Blips:RemoveBlip(v.rawblip)
                end
            end
            HotelBlips = {}
        end
        for _, hotelCfg in pairs(Hotels) do
            hotelCfg.Blip = nil
        end
        
        RemoveManagePrompt()
        ClearSpawnedFurniture()
        BCCHousingMenu:Close()
        BccUtils.RPC:CallAsync('bcc-housing:ServerSideRssStop', {})
    end
end)

-- Receive House Owner Information
BccUtils.RPC:Register('bcc-housing:receiveHouseOwner', function(params)
    if not params then return end
    DBG:Info("Received house owner information via RPC for House ID: " .. tostring(params.houseId))
    OpenHousingMainMenu(params.houseId, params.isOwner, params.ownershipStatus, params.taxPaymentReleased)
end)

function HandlePlayerDeathAndCloseMenu()
    local playerPed = PlayerPedId()

    -- Check if the player is already dead
    if IsEntityDead(playerPed) then
        BCCHousingMenu:Close() -- Close the menu if the player is dead
        return true            -- Return true to indicate the player is dead and the menu was closed
    end

    -- If the player is not dead, start monitoring for death while the menu is open
    CreateThread(function()
        while true do
            if IsEntityDead(playerPed) then
                BCCHousingMenu:Close() -- Close the menu if the player dies while in the menu
                return                 -- Stop the loop since the player is dead and the menu is closed
            end
            Wait(1000)                 -- Check every second
        end
    end)

    return false -- Return false to indicate the player is alive and the menu can open
end
