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
        style = {},
        contentslot = {
            style = {
                ["height"] = "450px",
                ["min-height"] = "250px"
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

    RegisterNetEvent("bcc-housing:ReceivePlayersWithAccess", function(result)
        -- Debugging the data received from the server
        devPrint("Received players data from server for House ID: " .. tostring(houseId))
        devPrint("Number of players with access received: " .. tostring(#result))

        -- Trigger the callback with the results
        callback(result)
    end)

    -- Trigger the server event to fetch players with access
    TriggerServerEvent("bcc-housing:getPlayersWithAccess", houseId)
end

function showManageOpt(x, y, z, houseId)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("openOwnerManage"), Config.keys.manage, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    devPrint("Setting up manage options for House ID: " .. tostring(houseId) .. " at coordinates: " .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z))

    while true do
        Wait(5)
        if BreakHandleLoop then
            devPrint("Breaking handle loop for House ID: " .. tostring(houseId))
            break
        end

        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, x, y, z, true)
        
        if dist < 2 then
            PromptGroup:ShowGroup(_U("house"))

            if firstprompt:HasCompleted() then
                devPrint("Prompt completed. Opening housing management menu for House ID: " .. tostring(houseId))
                TriggerServerEvent('bcc-housing:getHouseOwner', houseId)
            end
        elseif dist > 200 then
            Wait(2000)
        end
    end
end

-- Receive House Owner Information
RegisterNetEvent('bcc-housing:receiveHouseOwner')
AddEventHandler('bcc-housing:receiveHouseOwner', function(houseId, isOwner)
    devPrint("Received house owner information for House ID: " .. tostring(houseId) .. ", Is Owner: " .. tostring(isOwner))
    TriggerEvent('bcc-housing:openmenu', houseId, isOwner)
end)
