---- Pulling Essentials -----
VORPcore = exports.vorp_core:GetCore()
DoorLocksAPI = exports['bcc-doorlocks']:getDoorLocksAPI()
BccUtils = exports['bcc-utils'].initiate()

Discord = BccUtils.Discord.setup(Config.WebhookLink, Config.WebhookTitle, Config.WebhookAvatar)

DbUpdated = false -- Use this to stop taxes from running till db has been made

-- Initialize an empty table to hold player data
local PlayersTable = {}

-- Event to handle player data retrieval
BccUtils.RPC:Register('bcc-housing:GetPlayers', function(params, cb, src)
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
                    table.insert(data, {
                        serverId = playerId,
                        PlayerName = playerName,
                        staticid = Character.charIdentifier,
                    })
                end
            end
        end
    else
        devPrint("No players returned from GetPlayers() or list is empty")
    end
    if cb then cb(true, data) else return data end
end)

-- Event to update PlayersTable with player information for availability checks
BccUtils.RPC:Register("bcc-housing:getPlayersInfo", function(params, cb, src)
    if not table.contains(PlayersTable, src) then
        table.insert(PlayersTable, src) -- Prevent duplicate entries
    end
    if cb then cb(true) end
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
        print("^1[DEV MODE] ^4" .. message .. "^0")
    end
else
    -- Define devPrint as a no-op function if DevMode is not enabled
    function devPrint(message) end
end

function NotifyClient(src, message, durationOrType, maybeDuration)
    local defaultDuration = (Config.NotifyOptions and Config.NotifyOptions.autoClose) or 4000
    local defaultType = (Config.NotifyOptions and Config.NotifyOptions.type) or "info"

    local notifyType = defaultType
    local duration = defaultDuration

    if type(durationOrType) == "string" then
        notifyType = durationOrType
        duration = tonumber(maybeDuration) or defaultDuration
    elseif type(durationOrType) == "number" then
        duration = durationOrType
        if type(maybeDuration) == "string" then
            notifyType = maybeDuration
        end
    elseif durationOrType ~= nil then
        duration = defaultDuration
    end

    if maybeDuration == nil and notifyType ~= defaultType and type(durationOrType) == "string" then
        duration = defaultDuration
    end

    if Config.Notify == "feather-menu" then
        BccUtils.RPC:Notify("bcc-housing:NotifyClient", {
            message = message,
            type = notifyType,
            duration = duration
        }, src)
    elseif Config.Notify == "vorp-core" then
        VORPcore.NotifyRightTip(src, message, duration)
    else
        print("^1[Notify] Invalid Config.Notify: " .. tostring(Config.Notify))
    end
end

BccUtils.RPC:Register('bcc-housing:ServerSideRssStop', function(_, cb, src)
    MySQL.update("UPDATE bcchousing SET player_source_spawnedfurn='none'")
    if cb then cb(true) end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if src then
        DelSpawnedFurn(src) --This will trigger the function inside furniture.lua
    end
end)
