----- Pulling Essentials -----
VORPcore = exports.vorp_core:GetCore()

FeatherMenu = exports["feather-menu"].initiate()
BccUtils = exports["bcc-utils"].initiate()
MiniGame = exports["bcc-minigames"].initiate()

BCCHousingMenu = FeatherMenu:RegisterMenu("bcc:housing:mainmenu",
    {
        top = "5%",
        left = "5%",
        ["720width"] = "500px",
        ["1080width"] = "600px",
        ["2kwidth"] = "700px",
        ["4kwidth"] = "900px",
        style = {
            --['font-size'] = '18px',
        },
        contentslot = {
            style = {
                -- ['height'] = '350px',
                ['max-height'] = '500px', -- дозволяє обмежити висоту вмісту, додаючи можливість прокрутки вмісту, якщо він перевищує певну висоту.
                ['min-height'] = '350px', -- дозволяє обмежити висоту вмісту, додаючи можливість прокрутки вмісту, якщо він перевищує певну висоту.
                -- ["height"] = "450px",
                -- ["min-height"] = "250px"
                ['position'] = 'relative', ['z-index'] = 9,
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
        end
    }
)

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
    TriggerServerEvent("bcc-housing:GetPlayers")
    local playersData = {}
    RegisterNetEvent("bcc-housing:SendPlayers", function(result)
        playersData = result
    end)

    while next(playersData) == nil do
        Wait(10)
    end
    return playersData
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
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local ManageHousePrompt = PromptGroup:RegisterPrompt(_U("openOwnerManage"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    devPrint("Setting up manage options for House ID: " .. tostring(houseId) .. " at coordinates: " .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z))

    -- Variable to track if the house exists
    local houseExists = false

    -- Check if the house exists on the server
    TriggerServerEvent('bcc-housing:CheckIfHouseExists', houseId)

    -- Listen for the server's response to determine if the house exists
    RegisterNetEvent('bcc-housing:HouseExistenceChecked')
    AddEventHandler('bcc-housing:HouseExistenceChecked', function(exists, checkedHouseId)
        if checkedHouseId == houseId then
            houseExists = exists
            if not exists then
                devPrint("House ID " .. tostring(houseId) .. " no longer exists. Deleting prompt.")
                ManageHousePrompt:DeletePrompt()
                --BreakHandleLoop = true -- Break the loop if the house no longer exists
            end
        end
    end)

    Citizen.CreateThread(function()
        while true do
            local playerPed = PlayerPedId()

            if IsEntityDead(playerPed) then goto END end

            -- Break the loop if handle loop is broken
            if BreakHandleLoop then
                devPrint("Breaking handle loop for House ID: " .. tostring(houseId))
                break
            end

            -- Only proceed if the house exists
            if houseExists then
                local plc = GetEntityCoords(playerPed)
                local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, x, y, z, true)

                if dist < Config.DefaultMenuManageRadius then
                    PromptGroup:ShowGroup(_U("house"))

                    if ManageHousePrompt:HasCompleted() then
                        devPrint("Prompt completed. Opening housing management menu for House ID: " .. tostring(houseId))
                        TriggerServerEvent('bcc-housing:getHouseOwner', houseId)
                    end
                elseif dist > 200 then
                    Wait(2000) -- If far from house, reduce the frequency of checks
                end
            else
                Wait(1000) -- Wait before checking again if the house exists
            end
            ::END::
            Citizen.Wait(5) -- Delay loop execution to prevent excessive CPU usage
        end
    end)
end

--- Cleanup/ deletion on leave ----
AddEventHandler("onResourceStop", function(resource)
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

        -- Notify the server to clean up any server-side resources
        TriggerServerEvent('bcc-housing:ServerSideRssStop')
        BCCHousingMenu:Close()
    end
end)

-- Receive House Owner Information
RegisterNetEvent('bcc-housing:receiveHouseOwner')
AddEventHandler('bcc-housing:receiveHouseOwner', function(houseId, isOwner, ownershipStatus)
    devPrint("Received house owner information for House ID: " .. tostring(houseId) .. ", Is Owner: " .. tostring(isOwner) .. " and House is " .. ownershipStatus)
    TriggerEvent('bcc-housing:openmenu', houseId, isOwner, ownershipStatus)
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
