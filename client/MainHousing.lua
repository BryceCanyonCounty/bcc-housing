HouseCoords, HouseRadius, HouseId, Owner, TpHouse, TpHouseInstance, HouseOwnershipStatus, HouseTaxesOverdue = nil, nil, nil, nil, nil, nil, nil, nil
ActiveHouseId = nil
OwnedHouseContexts = OwnedHouseContexts or {}
HouseBlips, HotelBlips = {}, {}
local AdminAllowed = false
local OwnedHotels = {}
local HotelHandlerStarted = false

local DefaultHotelInterior = {
    enter = vector3(-325.29, 765.23, 121.64),
    inventory = vector3(-325.41, 766.9, 121.63),
    heading = 180.0
}

function SetActiveHouseContext(houseData)
    if not houseData then return end
    HouseCoords = houseData.coords or HouseCoords
    HouseRadius = houseData.radius or HouseRadius
    HouseId = houseData.houseId or HouseId
    ActiveHouseId = HouseId
    Owner = houseData.owner or Owner
    HouseOwnershipStatus = houseData.ownershipStatus or HouseOwnershipStatus
    HouseTaxesOverdue = houseData.taxesOverdue or HouseTaxesOverdue
    TpHouse = houseData.tpInt or houseData.tpHouse or TpHouse
    TpHouseInstance = houseData.tpInstance or TpHouseInstance
end

function GetHouseContext(houseId)
    if not houseId or not OwnedHouseContexts then return nil end
    return OwnedHouseContexts[houseId]
end

local function checkIfAdmin()
    local isAdmin = BccUtils.RPC:CallAsync('bcc-housing:CheckIfAdmin')
    AdminAllowed = isAdmin == true
    return AdminAllowed
end

RegisterCommand(Config.AdminManagementMenuCommand, function()
    if not AdminAllowed then
        checkIfAdmin()
    end

    if AdminAllowed then
        HouseManagementMenu()
    end
end, false)

if Config.OpenHousingMenuCommand and Config.OpenHousingMenuCommand ~= '' then
    RegisterCommand(Config.OpenHousingMenuCommand, function()
        if not HouseId then
            Notify(_U("noHouseFound"), 'error', 4000)
            return
        end

        if not HouseCoords then
            Notify(_U("noHouseFound"), 'error', 4000)
            return
        end

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local allowedRadius = tonumber(HouseRadius) or tonumber(Config.DefaultMenuManageRadius) or 2.0
        local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z,
            HouseCoords.x, HouseCoords.y, HouseCoords.z, true)

        if dist > allowedRadius then
            Notify(_U("needToBeNearHouse"), 'error', 4000)
            return
        end

        local successOwner, ownerData = BccUtils.RPC:CallAsync('bcc-housing:getHouseOwner', { houseId = HouseId })
        if successOwner and ownerData then
            OpenHousingMainMenu(HouseId, ownerData.isOwner, ownerData.ownershipStatus)
            return
        end

        local err = ownerData and ownerData.error or _U("noHouseOrNotOwner")
        Notify(err, 'error', 4000)
    end, false)
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    CreateThread(function()
        Wait(1000) -- wait for other scripts/player state to finish initializing after restart
        BccUtils.RPC:CallAsync('bcc-housing:CheckIfHasHouse', {})
    end)
end)

function ManageHotelBlips()
    for _, hotelCfg in pairs(Hotels) do
        if hotelCfg.blip and hotelCfg.blip.show and not hotelCfg.Blip then
            hotelCfg.Blip = BccUtils.Blips:SetBlip(hotelCfg.blip.name, hotelCfg.blip.sprite, hotelCfg.blip.scale, hotelCfg.location.x, hotelCfg.location.y, hotelCfg.location.z)
            local blipModifier = BccUtils.Blips:AddBlipModifier(hotelCfg.Blip, Config.BlipColors[hotelCfg.blip.color])
            blipModifier:ApplyModifier()
            table.insert(HotelBlips, hotelCfg.Blip)
        end
    end
end

RegisterNetEvent('vorp:SelectedCharacter', function()
    BccUtils.RPC:Notify('bcc-housing:getPlayersInfo', {})
    checkIfAdmin()
    local success, hotels = BccUtils.RPC:CallAsync('bcc-housing:HotelDbRegistry', {})
    if success and type(hotels) == 'table' then
        OwnedHotels = hotels
    else
        OwnedHotels = {}
    end
    BccUtils.RPC:CallAsync('bcc-housing:CheckIfHasHouse', {})
    ManageHotelBlips()
    if not HotelHandlerStarted then
        HotelHandlerStarted = true
        MainHotelHandler()
    end
end)

CreateThread(function() -- Devmode area
    if Config.DevMode then
        --RegisterCommand(Config.DevModeCommand, function()
            BccUtils.RPC:Notify('bcc-housing:getPlayersInfo', {})
            checkIfAdmin()
            local success, hotels = BccUtils.RPC:CallAsync('bcc-housing:HotelDbRegistry', {})
            if success and type(hotels) == 'table' then
                OwnedHotels = hotels
            else
                OwnedHotels = {}
            end
            BccUtils.RPC:CallAsync('bcc-housing:CheckIfHasHouse', {})
            ManageHotelBlips()
            if not HotelHandlerStarted then
                HotelHandlerStarted = true
                MainHotelHandler()
            end
        --end, false)
    end
end)

local function handleOwnsHouseClient(houseTable, owner)
    local coords = json.decode(houseTable.house_coords)
    local vectorCoords = vector3(coords.x, coords.y, coords.z)
    local radius = houseTable.house_radius_limit
    local houseId = houseTable.houseid
    local ownershipStatus = houseTable.ownershipStatus
    local tpInt = houseTable.tpInt ~= 0 and houseTable.tpInt or nil
    local tpInstance = houseTable.tpInstance
    local taxesStatus = houseTable.taxes_collected
    local taxesOverdue = taxesStatus and tostring(taxesStatus) == 'overdue'

    local houseContext = {
        coords = vectorCoords,
        radius = radius,
        houseId = houseId,
        owner = owner,
        ownershipStatus = ownershipStatus,
        taxesOverdue = taxesOverdue,
        tpInt = tpInt,
        tpInstance = tpInstance
    }

    OwnedHouseContexts[houseId] = houseContext

    if not HouseId or HouseId == houseId or ActiveHouseId == houseId then
        SetActiveHouseContext(houseContext)
    end

    DBG:Info("House information set for House ID: " .. tostring(houseId))

    StartFurnCheckHandler()

    local houseCfgFound = false
    local uniqueName = houseTable.uniqueName
    for _, houseCfg in pairs(Houses) do
        if houseCfg.uniqueName == uniqueName then
            houseCfgFound = true
            if houseCfg.blip.owned.active then
                local blip = BccUtils.Blips:SetBlip(houseCfg.blip.owned.name, houseCfg.blip.owned.sprite, 0.2, vectorCoords.x, vectorCoords.y, vectorCoords.z)
                local blipModifier = BccUtils.Blips:AddBlipModifier(blip, Config.BlipColors[houseCfg.blip.owned.color])
                blipModifier:ApplyModifier()
                table.insert(HouseBlips, blip)
                break
            end
        end
    end

    if not houseCfgFound and Config.HouseBlip.active then
        local houseBlip = Config.HouseBlip
        local blip = BccUtils.Blips:SetBlip(houseBlip.name, houseBlip.sprite, 0.2, vectorCoords.x, vectorCoords.y, vectorCoords.z)
        local blipModifier = BccUtils.Blips:AddBlipModifier(blip, Config.BlipColors[houseBlip.color])
        blipModifier:ApplyModifier()
        table.insert(HouseBlips, blip)
    end

    if taxesOverdue then
        Notify(_U("taxesOverdue"), 'error', 5000)
    else
        showManageOpt(vectorCoords.x, vectorCoords.y, vectorCoords.z, houseId, houseContext)
    end
end

BccUtils.RPC:Register('bcc-housing:OwnsHouseClientHandler', function(params)
    if not params then return end
    if params.house then
        handleOwnsHouseClient(params.house, params.isOwner)
    else
        handleOwnsHouseClient(params, params.isOwner)
    end
end)

function MainHotelHandler()
    DBG:Info("Initializing main hotel handler")

    local buyGroup = BccUtils.Prompts:SetupPromptGroup()
    local buyPrompt = buyGroup:RegisterPrompt(_U("promptBuy"), BccUtils.Keys[Config.keys.buy], 1, 1, true, 'click', nil)

    local enterGroup = BccUtils.Prompts:SetupPromptGroup()
    local enterPrompt = enterGroup:RegisterPrompt(_U("promptEnterHotel"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'click', nil)

    local inventoryGroup = BccUtils.Prompts:SetupPromptGroup()
    local inventoryPrompt = inventoryGroup:RegisterPrompt(_U("hotelInvName"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'click', nil)

    local leaveGroup = BccUtils.Prompts:SetupPromptGroup()
    local leavePrompt = leaveGroup:RegisterPrompt(_U("promptLeaveHotel"), BccUtils.Keys[Config.keys.manage], 1, 1, true, 'click', nil)

    local inHotel, hotelInside, instanceNumber, coordsWhenEntered = false, nil, 0, nil
    local interiorEnterCoords, interiorInventoryCoords, interiorHeading = nil, nil, nil

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
                                    BccUtils.RPC:CallAsync('bcc-housing:RegisterHotelInventory', { hotelId = hotelId })
                                    local player = PlayerId()
                                    DBG:Info("Entering hotel: " .. tostring(hotelId))
                                    inHotel = true
                                    hotelInside = hotel
                                    coordsWhenEntered = playerCoords
                                    local interiorCfg = hotel.interior or {}
                                    interiorEnterCoords = interiorCfg.enter or DefaultHotelInterior.enter
                                    interiorInventoryCoords = interiorCfg.inventory or DefaultHotelInterior.inventory
                                    interiorHeading = interiorCfg.heading or DefaultHotelInterior.heading
                                    SetEntityCoords(playerPed, interiorEnterCoords.x, interiorEnterCoords.y, interiorEnterCoords.z, false, false, false, false)
                                    if interiorHeading then
                                        SetEntityHeading(playerPed, interiorHeading)
                                    end
                                    local serverId = GetPlayerServerId(player)
                                    instanceNumber = math.random(1, 100000 + serverId)
                                    local bucketId = serverId + instanceNumber
                                    HousingInstance.Set(bucketId)
                                    break
                                end
                            end
                        end
                    end

                    if not isOwned then
                        buyGroup:ShowGroup(hotel.name .. _U("promptGroupName") .. tostring(hotel.cost))
                        if buyPrompt:HasCompleted() then
                            DBG:Info("Buying hotel: " .. tostring(hotel.hotelId))
                            local success, updatedHotels, errorMsg = BccUtils.RPC:CallAsync('bcc-housing:HotelBought', { hotel = hotel })
                            if success and type(updatedHotels) == 'table' then
                                OwnedHotels = updatedHotels
                            elseif errorMsg then
                                Notify(errorMsg, 'error', 4000)
                            end
                        end
                    end
                end
            end

        elseif inHotel and hotelInside then
            sleep = 0
            local inventoryCoords = interiorInventoryCoords or DefaultHotelInterior.inventory
            local distance = #(playerCoords - inventoryCoords)
            if distance < 1 then
                inventoryGroup:ShowGroup(hotelInside.name)
                if inventoryPrompt:HasCompleted() then
                    DBG:Info("Opening hotel inventory: " .. tostring(hotelInside.hotelId))
                    BccUtils.RPC:CallAsync('bcc-housing:HotelInvOpen', { hotelId = hotelInside.hotelId })
                end
            else
                leaveGroup:ShowGroup(hotelInside.name)
                if leavePrompt:HasCompleted() then
                    if coordsWhenEntered then
                        DBG:Info("Leaving hotel: " .. tostring(hotelInside.hotelId))
                        SetEntityCoords(PlayerPedId(), coordsWhenEntered.x, coordsWhenEntered.y, coordsWhenEntered.z, false, false, false, false)
                        inHotel = false
                        hotelInside = nil
                        coordsWhenEntered = nil
                        interiorEnterCoords, interiorInventoryCoords, interiorHeading = nil, nil, nil
                        HousingInstance.Clear()
                    end
                end
            end
        end
        Wait(sleep)
    end
end

local function clearHouseBlips(houseId)
    if HouseBlips[houseId] then
        BccUtils.Blips:RemoveBlip(HouseBlips[houseId].rawblip) 
        HouseBlips[houseId] = nil
    end

    if HouseBlips and next(HouseBlips) then
        for _, blipData in pairs(HouseBlips) do
            if blipData and blipData.rawblip then
                BccUtils.Blips:RemoveBlip(blipData.rawblip)
            end
        end
        HouseBlips = {}
    end
end

BccUtils.RPC:Register('bcc-housing:clearBlips', function(params)
    local houseId = params and params.houseId or params
    if houseId then
        clearHouseBlips(houseId)
    end
end)
