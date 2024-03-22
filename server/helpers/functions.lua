---- Pulling Essentials -----
VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
BccUtils = exports['bcc-utils'].initiate()
Discord = BccUtils.Discord.setup(Config.WebhookLink, 'bcc-housing', 'https://steamuserimages-a.akamaihd.net/ugc/1759186614239848553/8C42E78A07CB85399889CD5C82C63235F6C61F0F/?imw=637&imh=358&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true')

DbUpdated = false -- Use this to stop taxes from running till db has been made

--get players info list
PlayersTable = {}
RegisterServerEvent('bcc-housing:GetPlayers', function()
  local _source, data = source, {}

  for _, player in ipairs(PlayersTable) do
    local User = VORPcore.getUser(player)
    if User then
      local Character = User.getUsedCharacter                             --get player info
      local playername = Character.firstname .. ' ' .. Character.lastname --player char name
      data[tostring(player)] = {
        serverId = player,
        PlayerName = playername,
        staticid = Character.charIdentifier,
      }
    end
  end
  TriggerClientEvent("bcc-housing:SendPlayers", _source, data)
end)

-- check if staff is available
RegisterServerEvent("bcc-housing:getPlayersInfo", function(source)
  local _source = source
  PlayersTable[#PlayersTable + 1] = _source -- add all players
end)