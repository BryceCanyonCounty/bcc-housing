----- Pulling Essentials -----
VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
  VORPutils = utils
end)
VORPMenu = {}
TriggerEvent("vorp_menu:getData", function(cb)
  VORPMenu = cb
end)
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

function showManageOpt(x, y, z)
  local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
  local firstprompt = PromptGroup:RegisterPrompt(_U("openOwnerManage"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
  while true do
    Wait(5)
    if BreakHandleLoop then break end
    local plc = GetEntityCoords(PlayerPedId())
    local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, x, y, z, true)
    if dist < 2 then
      PromptGroup:ShowGroup(_U("house"))
      if firstprompt:HasCompleted() then
        HousingManagementMenu()
      end
    elseif dist > 200 then
      Wait(2000)
    end
  end
end