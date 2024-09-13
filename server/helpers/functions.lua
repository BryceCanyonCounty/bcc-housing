---- Pulling Essentials -----
VORPcore = exports.vorp_core:GetCore()

BccUtils = exports['bcc-utils'].initiate()

Discord = BccUtils.Discord.setup(Config.WebhookLink, Config.WebhookTitle, Config.WebhookAvatar)

DbUpdated = false -- Use this to stop taxes from running till db has been made

-- Initialize an empty table to hold player data
local PlayersTable = {}

-- Event to handle player data retrieval
RegisterServerEvent('bcc-housing:GetPlayers')
AddEventHandler('bcc-housing:GetPlayers', function()
    local _source = source
    local data = {}
    local players = GetPlayers() -- Fetch all current players on the server

    if players and #players > 0 then
        for _, playerId in ipairs(players) do
            local User = VORPcore.getUser(playerId)
            if User then
                local Character = User.getUsedCharacter -- Calling the method correctly
                if Character then
                    -- Check if firstname and lastname are not nil and provide default values if they are
                    local firstname = Character.firstname or "Unknown"
                    local lastname = Character.lastname or "Player"
                    local playerName = firstname .. ' ' .. lastname
                    data[tostring(playerId)] = {
                        serverId = playerId,
                        PlayerName = playerName,
                        staticid = Character.charIdentifier,
                    }
                end
            end
        end
    else
        devPrint("No players returned from GetPlayers() or list is empty")
    end
    TriggerClientEvent("bcc-housing:SendPlayers", _source, data)
end)

-- Event to update PlayersTable with player information for availability checks
RegisterServerEvent("bcc-housing:getPlayersInfo")
AddEventHandler("bcc-housing:getPlayersInfo", function()
    local _source = source
    if not table.contains(PlayersTable, _source) then
        table.insert(PlayersTable, _source) -- Prevent duplicate entries
    end
end)

-- Helper function to check for duplicates in PlayersTable
function table.contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

if Config.DevMode then
    -- Helper function for debugging
    function devPrint(message)
        print("^1[DEV MODE] ^4" .. message)
    end
else
    -- Define devPrint as a no-op function if DevMode is not enabled
    function devPrint(message) end
end

RegisterServerEvent('bcc-housing:ServerSideRssStop', function()
    MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn='none'")
end)

AddEventHandler('playerDropped', function()
    DelSpawnedFurn(source) --This will trigger the function inside furniture.lua
end)
