-- Insert Your Main Client Side Code Here
HouseCoords, HouseRadius, HouseId, Owner, TpHouse, TpHouseInstance = nil, nil, nil, nil, nil, nil
HouseBlips, CreatedFurniture = {}, {}
local AdminAllowed = false
local OwnedHotels = {}

RegisterCommand(Config.AdminManagementMenuCommand, function() -- house creation command
    if AdminAllowed then
        HouseManagementMenu()
    end
end, false)

if Config.DevMode then
    -- Helper function for debugging
    function devPrint(message)
        print("^1[DEV MODE] ^4" .. message)
    end
else
    -- Define devPrint as a no-op function if DevMode is not enabled
    function devPrint(message)
    end
end

RegisterNetEvent('vorp:SelectedCharacter', function()
    TriggerServerEvent('bcc-housing:getPlayersInfo')
    TriggerEvent('bcc-housing:AdminCheck')
    TriggerServerEvent('bcc-housing:HotelDbRegistry')
    TriggerServerEvent('bcc-housing:CheckIfHasHouse')
    TriggerEvent('bcc-housing:ManageHotelBlips')
end)

CreateThread(function() -- Devmode area
    if Config.DevMode then
        RegisterCommand(Config.DevModeCommand, function()
            TriggerServerEvent('bcc-housing:getPlayersInfo')
            TriggerEvent('bcc-housing:AdminCheck')
            TriggerServerEvent('bcc-housing:HotelDbRegistry')
            TriggerServerEvent('bcc-housing:CheckIfHasHouse')
            TriggerEvent('bcc-housing:ManageHotelBlips')
        end, false)
    end
end)

RegisterNetEvent('bcc-housing:OwnsHouseClientHandler', function(houseTable, owner)
    local coords = json.decode(houseTable.house_coords)
    HouseCoords = vector3(coords.x, coords.y, coords.z)
    HouseRadius = houseTable.house_radius_limit
    HouseId = houseTable.houseid
    Owner = owner

    if houseTable.tpInt ~= 0 then
        TpHouse = houseTable.tpInt
        TpHouseInstance = houseTable.tpInstance
    end

    devPrint("House information set for House ID: " .. tostring(HouseId))

    -- ManageHouse Menu Setup
    TriggerEvent('bcc-housing:FurnCheckHandler')

    -- Create the blip for the owned house
    local uniqueName = houseTable.uniqueName
    for _, houseCfg in pairs(Houses) do
        if houseCfg.uniqueName == uniqueName then
            if houseCfg.blip.owned.active then
                local blip = BccUtils.Blips:SetBlip(houseCfg.blip.owned.name, houseCfg.blip.owned.sprite, 0.2, HouseCoords.x, HouseCoords.y, HouseCoords.z)
                Citizen.InvokeNative(0x662D364ABF16DE2F, houseCfg.Blip, joaat(Config.BlipColors[houseCfg.blip.owned.color])) -- BlipAddModifier
                table.insert(HouseBlips, blip)
                break
            end
        end
    end

    showManageOpt(HouseCoords.x, HouseCoords.y, HouseCoords.z, HouseId) -- Ensure HouseId is passed here
end)

AddEventHandler('bcc-housing:AdminCheck', function()
    local isAdmin = VORPcore.Callback.TriggerAwait('bcc-housing:CheckIfAdmin')
    if isAdmin then
        AdminAllowed = true
    end
end)

RegisterNetEvent('bcc-housing:MainHotelHandler', function()
    devPrint("Initializing main hotel handler")

    local buyGroup = BccUtils.Prompts:SetupPromptGroup()
    local buyPrompt = buyGroup:RegisterPrompt(_U("promptBuy"), BccUtils.Keys[Config.keys.buy], 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    local enterGroup = BccUtils.Prompts:SetupPromptGroup()
    local enterPrompt = enterGroup:RegisterPrompt(_U("promptEnterHotel"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    local inventoryGroup = BccUtils.Prompts:SetupPromptGroup()
    local inventoryPrompt = inventoryGroup:RegisterPrompt(_U("hotelInvName"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    local leaveGroup = BccUtils.Prompts:SetupPromptGroup()
    local leavePrompt = leaveGroup:RegisterPrompt(_U("promptLeaveHotel"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    local inHotel, hotelInside, instanceNumber, coordsWhenEntered = false, nil, 0, nil

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if not inHotel then
            for _, hotel in pairs(Hotels) do
                local distance = #(playerCoords - hotel.location)
                if distance < 2 then
                    sleep = 0
                    local isOwned = false

                    if #OwnedHotels > 0 then
                        for _, hotelId in pairs(OwnedHotels) do
                            if hotel.hotelId == hotelId then
                                isOwned = true
                                enterGroup:ShowGroup(hotel.name)
                                if enterPrompt:HasCompleted() then
                                    TriggerServerEvent('bcc-housing:RegisterHotelInventory', hotelId)
                                    local player = PlayerId()
                                    devPrint("Entering hotel: " .. tostring(hotelId))
                                    inHotel = true
                                    hotelInside = hotel
                                    coordsWhenEntered = playerCoords
                                    SetEntityCoords(playerPed, -325.29, 765.23, 121.64, false, false, false, false)
                                    instanceNumber = math.random(1, 100000 + tonumber(GetPlayerServerId(player)))
                                    VORPcore.instancePlayers(tonumber(GetPlayerServerId(player)) + instanceNumber)
                                    break
                                end
                            end
                        end
                    end

                    if not isOwned then
                        buyGroup:ShowGroup(hotel.name .. _U("promptGroupName") .. tostring(hotel.cost))
                        if buyPrompt:HasCompleted() then
                            devPrint("Buying hotel: " .. tostring(hotel.hotelId))
                            TriggerServerEvent('bcc-housing:HotelBought', hotel)
                        end
                    end
                end
            end

        elseif inHotel and hotelInside then
            sleep = 0
            local coords = vector3(-325.41, 766.9, 121.63)
            local distance = #(playerCoords - coords)
            if distance < 1 then
                inventoryGroup:ShowGroup(hotelInside.name)
                if inventoryPrompt:HasCompleted() then
                    devPrint("Opening hotel inventory: " .. tostring(hotelInside.hotelId))
                    TriggerServerEvent('bcc-housing:HotelInvOpen', hotelInside.hotelId)
                end
            else
                leaveGroup:ShowGroup(hotelInside.name)
                if leavePrompt:HasCompleted() then
                    if coordsWhenEntered then
                        devPrint("Leaving hotel: " .. tostring(hotelInside.hotelId))
                        SetEntityCoords(PlayerPedId(), coordsWhenEntered.x, coordsWhenEntered.y, coordsWhenEntered.z, false, false, false, false)
                        inHotel = false
                        VORPcore.instancePlayers(0) -- removes the player from instance
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('bcc-housing:ManageHotelBlips', function()
    for _, hotelCfg in pairs(Hotels) do
        if hotelCfg.blip.show then
            if not hotelCfg.Blip then
                hotelCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, hotelCfg.location) -- BlipAddForCoords
                SetBlipSprite(hotelCfg.Blip, hotelCfg.blip.sprite, true)
                Citizen.InvokeNative(0x9CB1A1623062F402, hotelCfg.Blip, hotelCfg.blip.name) -- SetBlipName
                Citizen.InvokeNative(0x662D364ABF16DE2F, hotelCfg.Blip, joaat(Config.BlipColors[hotelCfg.blip.color])) -- BlipAddModifier
            end
        end
    end
end)

RegisterNetEvent('bcc-housing:UpdateHotelTable', function(hotelId) -- event to update the housing table
    devPrint("Updating hotel table with hotel ID: " .. tostring(hotelId))
    table.insert(OwnedHotels, hotelId)
end)

-- Function to clear blips and prompts for a specific house
RegisterNetEvent('bcc-housing:clearBlips', function(houseId)
    -- Clear the blip for the sold house
    if HouseBlips[houseId] then
        BccUtils.Blips:RemoveBlip(HouseBlips[houseId].rawblip) -- Assuming HouseBlips[houseId] has a rawblip field
        HouseBlips[houseId] = nil
    end

    -- Optionally, clear all remaining blips and prompts if necessary
    if #HouseBlips > 0 then
        for k, v in pairs(HouseBlips) do
            BccUtils.Blips:RemoveBlip(v.rawblip)
        end
        HouseBlips = {} -- Clear the table to prevent any stale references
    end
end)
