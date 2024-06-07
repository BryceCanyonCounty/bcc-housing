InTpHouse, CurrentTpHouse, BreakHandleLoop = false, nil, false

local inmenu = false

AddEventHandler('bcc-housing:MenuClose', function()
    Citizen.CreateThread(function()   -- Ensure this runs in a separate thread
        if not inmenu then return end -- Exit if not in a menu
        while inmenu do
            Wait(5)
            if IsControlJustReleased(0, 0x156F7119) then -- B (space) to exit
                if BCCHousingMenu and BCCHousingMenu.isOpen then
                    BCCHousingMenu:Close()
                    inmenu = false
                end
            end
        end
    end)
end)

AddEventHandler('bcc-housing:openmenu', function(tp)
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
        slot = "header",
        style = {}
    })

    housingMainMenu:RegisterElement('button', {
        label = _U("houseInv"),
        style = {}
    }, function()
        TriggerServerEvent('bcc-house:OpenHouseInv', HouseId)
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

    housingMainMenu:RegisterElement('button', {
        label = _U("giveAccess"),
        style = {}
    }, function()
        -- To open from the house management or access giving menu
        PlayerListMenu(tp, afterGivingAccess, "giveAccess")
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
        TriggerServerEvent('bcc-housing:CheckLedger', HouseId)
    end)

    housingMainMenu:RegisterElement('button', {
        label = _U("ledger"),
        style = {}
    }, function()
        if HouseId then
            TriggerEvent('bcc-housing:addLedger', HouseId)
        else
            print("Error: HouseId is undefined or invalid.")
        end
    end)

    -- Footer elements outside the loop
    housingMainMenu:RegisterElement('bottomline', {
        value = _U("houseInv_desc"),
        slot = 'footer',
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
        -- Logic to handle entering the house
        local houseTable = Config.TpInteriors["Interior" .. tostring(tpHouseIndex)]
        CurrentTpHouse = tpHouseIndex
        enterTpHouse(houseTable)
    else
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
            print("Invalid input for amount.")
        end
    end)

    -- Confirm button to process the ledger update
    AddLedgerPage:RegisterElement('button', {
        label = "confirm",
        style = {},
    }, function()
        if amountToInsert then
            TriggerServerEvent('bcc-housing:LedgerHandling', amountToInsert, houseId)
            BCCHousingMenu:Close() -- Close the menu after submitting
        else
            print("Error: Amount not set or invalid.")
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
    InTpHouse = true
    local pped = PlayerPedId()
    VORPcore.instancePlayers(tonumber(GetPlayerServerId(PlayerId())) + TpHouseInstance)
    SetEntityCoords(pped, houseTable.exitCoords.x, houseTable.exitCoords.y, houseTable.exitCoords.z)

    FreezeEntityPosition(pped, true) --done to prevent falling through ground
    Wait(1000)
    FreezeEntityPosition(pped, false)
    showManageOpt(houseTable.exitCoords.x, houseTable.exitCoords.y, houseTable.exitCoords.z)
end
