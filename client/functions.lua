----- Pulling Essentials -----
VORPcore = exports.vorp_core:GetCore()

FeatherMenu = exports["feather-menu"].initiate()
BccUtils = exports["bcc-utils"].initiate()
MiniGame = exports["bcc-minigames"].initiate()

HousingInstance = {}

function HousingInstance.Set(bucketId)
    bucketId = tonumber(bucketId) or 0
    local success, response = BccUtils.RPC:CallAsync('bcc-housing:SetInstance', { bucketId = bucketId })
    if not success then
        devPrint("Failed to set instance: " .. tostring(response and response.error))
    end
    return success, response
end

function HousingInstance.Clear()
    local success, response = BccUtils.RPC:CallAsync('bcc-housing:LeaveInstance', {})
    if not success then
        devPrint("Failed to clear instance: " .. tostring(response and response.error))
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
        end
    }
)

local ManageHousePrompt = nil
local ManageHousePromptActive = false

function RemoveManagePrompt()
    if ManageHousePrompt then
        ManageHousePrompt:DeletePrompt()
        ManageHousePrompt = nil
    end
    ManageHousePromptActive = false
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
        print("^1[Notify] Invalid Config.Notify: " .. tostring(Config.Notify))
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
        print('Invalid model:', modelName)
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
    devPrint("Requesting players with access for House ID: " .. tostring(houseId))

    -- Use RPC to call the server-side function and handle the response
    BccUtils.RPC:Call("bcc-housing:GetPlayersWithAccess", { houseId = houseId }, function(result)
        if result and #result > 0 then
            devPrint("Number of players with access received: " .. tostring(#result))
            for _, player in ipairs(result) do
                devPrint("Player: ID=" .. player.charidentifier .. ", Name=" .. player.firstname .. " " .. player.lastname)
            end
            callback(result) -- Pass the result to the callback
        else
            devPrint("No players with access received.")
            callback({})
        end

    end)
end


function showManageOpt(x, y, z, houseId)
    RemoveManagePrompt()

    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    ManageHousePrompt = PromptGroup:RegisterPrompt(_U("openOwnerManage"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    ManageHousePromptActive = true

    devPrint("Setting up manage options for House ID: " .. tostring(houseId) .. " at coordinates: " .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z))

    local houseExists = false
    local success, data = BccUtils.RPC:CallAsync('bcc-housing:CheckIfHouseExists', { houseId = houseId })
    if success and data then
        houseExists = data.exists
    end

    if not houseExists then
        devPrint("House ID " .. tostring(houseId) .. " no longer exists. Deleting prompt.")
        RemoveManagePrompt()
        return
    end

    Citizen.CreateThread(function()
        while true do
            if not ManageHousePromptActive or not ManageHousePrompt then
                break
            end

            local playerPed = PlayerPedId()

            if IsEntityDead(playerPed) then goto END end

            if BreakHandleLoop then
                devPrint("Breaking handle loop for House ID: " .. tostring(houseId))
                break
            end

            if houseExists then
                local plc = GetEntityCoords(playerPed)
                local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, x, y, z, true)

                if dist < Config.DefaultMenuManageRadius then
                    PromptGroup:ShowGroup(_U("house"))

                    if ManageHousePromptActive and ManageHousePrompt and ManageHousePrompt:HasCompleted() then
                        devPrint("Prompt completed. Opening housing management menu for House ID: " .. tostring(houseId))
                        local successOwner, ownerData = BccUtils.RPC:CallAsync('bcc-housing:getHouseOwner', { houseId = houseId })
                        if successOwner and ownerData then
                            OpenHousingMainMenu(houseId, ownerData.isOwner, ownerData.ownershipStatus)
                        else
                            local err = ownerData and ownerData.error
                            if err then
                                Notify(err, 'error', 4000)
                            end
                        end
                    end
                elseif dist > 200 then
                    Wait(2000)
                end
            else
                Wait(1000)
            end
            ::END::
            Citizen.Wait(5)
        end

        if ManageHousePromptActive and ManageHousePrompt then
            ManageHousePrompt:DeletePrompt()
        end
        ManageHousePrompt = nil
        ManageHousePromptActive = false
    end)
end
AddEventHandler("onClientResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        -- Delete any created furniture
        if #CreatedFurniture > 0 then
            for k, v in pairs(CreatedFurniture) do
                DeleteObject(v)
            end
        end

        -- Remove any blips that were created
        if HouseBlips and next(HouseBlips) then
            for k, v in pairs(HouseBlips) do
                if v and v.rawblip then
                    BccUtils.Blips:RemoveBlip(v.rawblip)
                end
            end
            HouseBlips = {} -- Clear the table to prevent any stale references
        end

        -- Remove blips and npcs for all npc agents
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

        -- Remove blips from all hotels
        for _, hotelCfg in pairs(Hotels) do
            if hotelCfg.Blip then
                RemoveBlip(hotelCfg.Blip)
                hotelCfg.Blip = nil
            end
        end

        -- Notify the server to clean up any server-side resources
        RemoveManagePrompt()
        BCCHousingMenu:Close()
        BccUtils.RPC:CallAsync('bcc-housing:ServerSideRssStop', {})
    end
end)

-- Receive House Owner Information
BccUtils.RPC:Register('bcc-housing:receiveHouseOwner', function(params)
    if not params then return end
    devPrint("Received house owner information via RPC for House ID: " .. tostring(params.houseId))
    OpenHousingMainMenu(params.houseId, params.isOwner, params.ownershipStatus)
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
