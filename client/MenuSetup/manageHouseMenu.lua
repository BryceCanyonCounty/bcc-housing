InTpHouse, CurrentTpHouse, BreakHandleLoop = false, nil, false

local PlayerAccessibleHouses = {}

-- Handler to receive the accessible houses list from the server
RegisterNetEvent('bcc-housing:ReceiveAccessibleHouses')
AddEventHandler('bcc-housing:ReceiveAccessibleHouses', function(accessibleHouses)
    devPrint("Received accessible houses list from server")
    -- Store the accessible houses in a client-side variable
    PlayerAccessibleHouses = accessibleHouses
end)

-- Function to check if the player has access to a specific house
function hasAccessToHouse(houseId)
    for _, id in ipairs(PlayerAccessibleHouses) do
        if id == houseId then
            devPrint("Player has access to house ID: " .. tostring(houseId))
            return true
        end
    end
    devPrint("Player does not have access to house ID: " .. tostring(houseId))
    return false
end

-- Handler to receive the house ID for opening the inventory
RegisterNetEvent('bcc-housing:receiveHouseIdinv')
AddEventHandler('bcc-housing:receiveHouseIdinv', function(houseId)
    if houseId then
        devPrint("Received House ID for inventory: " .. tostring(houseId))
        if PlayerAccessibleHouses and hasAccessToHouse(houseId) then
            devPrint("Player has access to house ID: " .. tostring(houseId))
            TriggerServerEvent('bcc-house:OpenHouseInv', houseId)
        else
            devPrint("Player does not have access to house ID: " .. tostring(houseId))
            VORPcore.NotifyLeft("No access to this house.", "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
        end
    else
        devPrint("No House ID received or no house associated with the character")
        VORPcore.NotifyLeft("No house found associated with your character.", "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
    end
end)

-- Handler to receive the house ID for giving access
RegisterNetEvent('bcc-housing:receiveHouseId')
AddEventHandler('bcc-housing:receiveHouseId', function(houseId)
    if houseId then
        devPrint("Received House ID for giving access: " .. tostring(houseId))
        showAccessMenu(houseId)
    else
        devPrint("No House ID received or no house associated with the character")
        VORPcore.NotifyLeft("No house found associated with your character.", "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
    end
end)

function showAccessMenu(houseId)
    devPrint("Showing access menu for House ID: " .. tostring(houseId))
    PlayerListMenuForGiveAccess(houseId, afterGivingAccess, "giveAccess")
end

function afterGivingAccess(houseId, playerId, playerServerId, completion)
    devPrint("Granting access: HouseID=" .. tostring(houseId) .. ", PlayerID=" .. tostring(playerId))
    if houseId and playerId and playerServerId then
        TriggerServerEvent('bcc-housing:NewPlayerGivenAccess', playerId, houseId, playerServerId)
        completion(true, "Access granted successfully.")
    else
        completion(false, "Missing necessary information for granting access.")
    end
end

function PlayerListMenuForGiveAccess(houseId, callback, context)
    devPrint("Opening player list menu for giving access to House ID: " .. tostring(houseId))
    BCCHousingMenu:Close()
    local players = GetPlayers()
    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)

    local playerListGiveMenupage = BCCHousingMenu:RegisterPage("bcc-housing:playerListGiveMenupage")
    playerListGiveMenupage:RegisterElement("header", {
        value = _U("StaticId_desc"),
        slot = "header",
        style = {}
    })

    playerListGiveMenupage:RegisterElement('line', {
        slot = "header",
        style = {}
    })
    
    for k, v in pairs(players) do
        playerListGiveMenupage:RegisterElement("button", {
            label = v.PlayerName,
            style = {}
        }, function()
            callback(houseId, v.staticid, v.serverId, function(success, message)
                VORPcore.NotifyRightTip(message, 4000) -- Feedback to user
                BCCHousingMenu:Close()  -- Close the menu after action is completed
            end)
        end)
    end

    playerListGiveMenupage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    playerListGiveMenupage:RegisterElement("button", {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu')
    end)

    playerListGiveMenupage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = playerListGiveMenupage:RegisterElement('textdisplay', {
        slot = "footer",
        value = "Select player from this list to own this house or to have access",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = playerListGiveMenupage
    })
end

-- Handler to open the housing main menu
AddEventHandler('bcc-housing:openmenu', function(houseId)
    devPrint("Opening housing main menu for House ID: " .. tostring(houseId))
    TriggerEvent('bcc-housing:MenuClose')
    BCCHousingMenu:Close()

    -- Register the main page for Housing
    local housingMainMenu = BCCHousingMenu:RegisterPage("bcc-housing:MainPage")
    housingMainMenu:RegisterElement('header', {
        value = _U("creationMenuName"),
        slot = 'header',
        style = {}
    })

    housingMainMenu:RegisterElement('line', {
        style = {}
    })

    -- Add button to open house inventory
    housingMainMenu:RegisterElement('button', {
        label = _U("houseInv"),
        style = {}
    }, function()
        devPrint("Requesting house ID for inventory for House ID: " .. tostring(houseId))
        TriggerServerEvent('bcc-housing:getHouseId', 'inv', houseId) -- Pass the house ID directly
    end)

    if TpHouse ~= nil then
        if not InTpHouse then
            housingMainMenu:RegisterElement('button', {
                label = _U("enterTpHouse"),
                style = {}
            }, function()
                enterOrExitHouse(true, TpHouse) -- Handles entering the house
            end)
        else
            housingMainMenu:RegisterElement('button', {
                label = _U("exitTpHouse"),
                style = {}
            }, function()
                enterOrExitHouse(false) -- Handles exiting the house
            end)
        end
    end

    -- Add button to give access to a house
    housingMainMenu:RegisterElement('button', {
        label = _U("giveAccess"),
        style = {}
    }, function()
        devPrint("Requesting house ID for access for House ID: " .. tostring(houseId))
        TriggerServerEvent('bcc-housing:getHouseId', 'access', houseId) -- Pass the house ID directly
    end)

    housingMainMenu:RegisterElement('button', {
        label = _U("furniture"),
        style = {}
    }, function()
        FurnitureMenu()
    end)

    housingMainMenu:RegisterElement('button', {
        label = _U("checkledger"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-housing:CheckLedger', houseId)
    end)

    housingMainMenu:RegisterElement('button', {
        label = _U("ledger"),
        style = {}
    }, function()
        if houseId then
            TriggerEvent('bcc-housing:addLedger', houseId)
        else
            devPrint("Error: HouseId is undefined or invalid.")
        end
    end)

    -- Footer elements outside the loop
    housingMainMenu:RegisterElement('bottomline', {
        style = {}
    })

    -- Open the menu with the configured main page
    BCCHousingMenu:Open({
        startupPage = housingMainMenu
    })
end)

-- Helper function to manage entering or exiting houses
function enterOrExitHouse(enter, tpHouseIndex)
    BCCHousingMenu.Close() -- Close the menu before changing the scene
    if enter then
        devPrint("Entering house with tpHouseIndex: " .. tostring(tpHouseIndex))
        -- Logic to handle entering the house
        local houseTable = Config.TpInteriors["Interior" .. tostring(tpHouseIndex)]
        CurrentTpHouse = tpHouseIndex
        enterTpHouse(houseTable)
    else
        devPrint("Exiting house")
        -- Logic to handle exiting the house
        SetEntityCoords(PlayerPedId(), HouseCoords.x, HouseCoords.y, HouseCoords.z)
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(500)
        FreezeEntityPosition(PlayerPedId(), false)
        InTpHouse = false
        showManageOpt(HouseCoords.x, HouseCoords.y, HouseCoords.z)
    end
end

RegisterNetEvent('bcc-housing:addLedger')
AddEventHandler('bcc-housing:addLedger', function(houseId)
    devPrint("Adding ledger for House ID: " .. tostring(houseId))
    local AddLedgerPage = BCCHousingMenu:RegisterPage('add_ledger_page')
    local amountToInsert = nil -- Variable to store the amount to insert

    -- Header for the ledger page
    AddLedgerPage:RegisterElement('header', {
        value = _U('ledger'),
        slot = 'header',
        style = {}
    })
    AddLedgerPage:RegisterElement('input', {
        label = _U('taxAmount'),
        placeholder = _U("ledgerAmountToInsert"),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        if data.value and tonumber(data.value) and tonumber(data.value) > 0 then
            amountToInsert = tonumber(data.value)
        else
            amountToInsert = nil
            devPrint("Invalid input for amount.")
        end
    end)

    -- Confirm button to process the ledger update
    AddLedgerPage:RegisterElement('button', {
        label = _U("Confirm"),
        style = {},
    }, function()
        if amountToInsert then
            devPrint("Submitting ledger update for amount: " .. tostring(amountToInsert))
            TriggerServerEvent('bcc-housing:LedgerHandling', amountToInsert, houseId)
            BCCHousingMenu:Close() -- Close the menu after submitting
        else
            devPrint("Error: Amount not set or invalid.")
        end
    end)

    AddLedgerPage:RegisterElement('button', {
        label = "Back",
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu')
    end)

    -- Open the menu with the newly created page
    BCCHousingMenu:Open({
        startupPage = AddLedgerPage
    })
end)

function enterTpHouse(houseTable)
    devPrint("Entering TP house")
    InTpHouse = true
    local pped = PlayerPedId()
    VORPcore.instancePlayers(tonumber(GetPlayerServerId(PlayerId())) + TpHouseInstance)
    SetEntityCoords(pped, houseTable.exitCoords.x, houseTable.exitCoords.y, houseTable.exitCoords.z)

    FreezeEntityPosition(pped, true) -- done to prevent falling through ground
    Wait(1000)
    FreezeEntityPosition(pped, false)
    showManageOpt(houseTable.exitCoords.x, houseTable.exitCoords.y, houseTable.exitCoords.z)
end
