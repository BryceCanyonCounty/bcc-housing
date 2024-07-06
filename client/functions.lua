----- Pulling Essentials -----
VORPcore = exports.vorp_core:GetCore()

FeatherMenu = exports['feather-menu'].initiate()
BccUtils = exports['bcc-utils'].initiate()

BCCHousingMenu = FeatherMenu:RegisterMenu('bcc:housing:mainmenu', {
  top = '50%',
  right = '10%',
  ['720width'] = '500px',
  ['1080width'] = '600px',
  ['2kwidth'] = '700px',
  ['4kwidth'] = '900px',
  style = {
    --['height'] = '500px',
    ['border'] = '5px solid white',
    --['background-image'] = 'none',
    ['background-color'] = '#515A5A'
  },
  contentslot = {
    style = {
      ['height'] = '500px',
      --['min-height'] = '300px'
    }
  },
  draggable = true
})

BccUtils = exports['bcc-utils'].initiate()
MiniGame = exports['bcc-minigames'].initiate()

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

function showManageOpt(x, y, z, houseId)
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("openOwnerManage"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    
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
            ---devPrint("Player is within 2 units of the house. Showing prompt for House ID: " .. tostring(houseId))
            PromptGroup:ShowGroup(_U("house"))
            
            if firstprompt:HasCompleted() then
                devPrint("Prompt completed. Opening housing management menu for House ID: " .. tostring(houseId))
                TriggerEvent('bcc-housing:openmenu', houseId) -- Pass the houseId to the event
            end
        elseif dist > 200 then
            devPrint("Player is more than 200 units away from the house. Waiting before next check.")
            Wait(2000)
        end
    end
end