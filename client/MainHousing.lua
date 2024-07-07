--Insert Your Main Client Side Code Here
HouseCoords, HouseRadius, HouseId, AdminAllowed, Owner, HouseBlips, OwnedHotels, TpHouse, TpHouseInstance = nil, nil, nil, false, nil, {}, {}, nil, nil

RegisterCommand(Config.AdminManagementMenuCommand, function() --house creation command
    if AdminAllowed then
        HouseManagementMenu()
    end
end)

if Config.DevMode then
    -- Helper function for debugging
    function devPrint(message)
        print("^1[DEV] ^0" .. message)
    end
else
    -- Define devPrint as a no-op function if DevMode is not enabled
    function devPrint(message) end
end

RegisterNetEvent('vorp:SelectedCharacter') --init loading
AddEventHandler('vorp:SelectedCharacter', function()
    local player = GetPlayerServerId(tonumber(PlayerId())) --credit vorp_admin
    Wait(200)
    TriggerServerEvent("bcc-housing:getPlayersInfo", player) --credit vorp_admin
    TriggerServerEvent('bcc-housing:AdminCheck')
    TriggerServerEvent('bcc-housing:HotelDbRegistry')
    TriggerServerEvent('bcc-housing:CheckIfHasHouse')
end)

CreateThread(function() --Devmode area
    if Config.DevMode then
        RegisterCommand('HousingDev', function()
            local player = GetPlayerServerId(tonumber(PlayerId())) --credit vorp_admin
            Wait(200)
            TriggerServerEvent("bcc-housing:getPlayersInfo", player) --credit vorp_admin
            TriggerServerEvent('bcc-housing:AdminCheck')
            TriggerServerEvent('bcc-housing:HotelDbRegistry')
            TriggerServerEvent('bcc-housing:CheckIfHasHouse')
        end)
    end
end)

RegisterNetEvent('bcc-housing:OwnsHouseClientHandler')
AddEventHandler('bcc-housing:OwnsHouseClientHandler', function(houseTable, owner)
    HouseCoords = json.decode(houseTable.house_coords)
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
    local blip = BccUtils.Blips:SetBlip(_U("houseBlip"), 'blip_mp_base', 0.2, HouseCoords.x, HouseCoords.y, HouseCoords.z)
    table.insert(HouseBlips, blip)
    showManageOpt(HouseCoords.x, HouseCoords.y, HouseCoords.z, HouseId) -- Ensure HouseId is passed here
end)

RegisterNetEvent('bcc-housing:AdminClientCatch', function(var) --admin check catch
    if var then
        AdminAllowed = true
    end
end)

AddEventHandler('bcc-housing:FurnCheckHandler', function() --event to spawn, and del furniture based on distance to house
    devPrint("Starting furniture check handler")
    while true do
        Wait(2000)
        local plc = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, HouseCoords.x, HouseCoords.y, HouseCoords.z, true)
        if dist < HouseRadius + 20 then
            --devPrint("Player is near the house. Spawning furniture.")
            TriggerServerEvent('bcc-housing:FurniturePlacedCheck', HouseId, false, true)
            Wait(1500)
        elseif dist > HouseRadius + 100 then
            devPrint("Player is far from the house. Deleting furniture.")
            TriggerServerEvent('bcc-housing:FurniturePlacedCheck', HouseId, true)
            Wait(2000)
        end
    end
end)

--Hotel area --
RegisterNetEvent('bcc-housing:MainHotelHandler', function()
    devPrint("Initializing main hotel handler")
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("promptBuy"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    local PromptGroup2 = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt2 = PromptGroup2:RegisterPrompt(_U("promptEnterHotel"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    local PromptGroup3 = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt3 = PromptGroup3:RegisterPrompt(_U("hotelInvName"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    local PromptGroup4 = BccUtils.Prompts:SetupPromptGroup()
    local firstprompt4 = PromptGroup4:RegisterPrompt(_U("promptLeaveHotel"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    local inHotel, hotelInside, instanceNumber, coordsWhenEntered = false, nil, 0, nil
    while true do
        Wait(5)
        local plc = GetEntityCoords(PlayerPedId())
        if not inHotel then
            for k, v in pairs(Config.Hotels) do
                if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, v.location.x, v.location.y, v.location.z, true) < 2 then
                    if #OwnedHotels > 0 then
                        for r, u in pairs(OwnedHotels) do
                            if v.hotelId == u then
                                PromptGroup2:ShowGroup(_U("promptHotel"))
                                if firstprompt2:HasCompleted() then
                                    devPrint("Entering hotel: " .. tostring(v.hotelId))
                                    inHotel = true
                                    hotelInside = v
                                    coordsWhenEntered = plc
                                    SetEntityCoords(PlayerPedId(), -325.29, 765.23, 121.64)
                                    instanceNumber = math.random(1, 100000 + tonumber(GetPlayerServerId(PlayerPedId())))
                                    VORPcore.instancePlayers(tonumber(GetPlayerServerId(PlayerId())) + instanceNumber)
                                end
                            else
                                PromptGroup:ShowGroup(_U("promptGroupName") .. tostring(v.cost))
                                if firstprompt:HasCompleted() then
                                    devPrint("Buying hotel: " .. tostring(v.hotelId))
                                    TriggerServerEvent('bcc-housing:HotelBought', v)
                                end
                            end
                        end
                    else
                        PromptGroup:ShowGroup(_U("promptGroupName") .. tostring(v.cost))
                        if firstprompt:HasCompleted() then
                            devPrint("Buying hotel: " .. tostring(v.hotelId))
                            TriggerServerEvent('bcc-housing:HotelBought', v)
                        end
                    end
                end
            end
        else
            if GetDistanceBetweenCoords(plc.x, plc.y, plc.z, -325.41, 766.9, 121.63) < 1 then
                PromptGroup3:ShowGroup(_U("promptHotel"))
                if firstprompt3:HasCompleted() then
                    devPrint("Opening hotel inventory: " .. tostring(hotelInside.hotelId))
                    TriggerServerEvent('bcc-housing:HotelInvOpen', hotelInside.hotelId)
                end
            else
                PromptGroup4:ShowGroup(_U("promptHotel"))
                if firstprompt4:HasCompleted() then
                    devPrint("Leaving hotel: " .. tostring(hotelInside.hotelId))
                    SetEntityCoords(PlayerPedId(), coordsWhenEntered.x, coordsWhenEntered.y, coordsWhenEntered.z)
                    inHotel = false
                    VORPcore.instancePlayers(0) --removes the player from instance
                end
            end
        end
    end
end)

RegisterNetEvent('bcc-housing:HousingTableUpdate', function(houseId) --event to update the housing table
    devPrint("Updating housing table with house ID: " .. tostring(houseId))
    table.insert(OwnedHotels, houseId)
end)
