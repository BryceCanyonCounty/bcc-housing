----- Pulling Essentials -----
VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
  VORPutils = utils
end)
TriggerEvent("menuapi:getData", function(call)
  MenuData = call
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