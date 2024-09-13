InTpHouse, CurrentTpHouse, BreakHandleLoop = false, nil, false
local PlayerAccessibleHouses = {}

-- Handler to receive the accessible houses list from the server
RegisterNetEvent('bcc-housing:ReceiveAccessibleHouses')
AddEventHandler('bcc-housing:ReceiveAccessibleHouses', function(accessibleHouses)
    devPrint("Received accessible houses list from server")
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
    if houseId and hasAccessToHouse(houseId) then
        devPrint("Player has access to house ID: " .. tostring(houseId))
        TriggerServerEvent('bcc-house:OpenHouseInv', houseId)
    else
        devPrint("No access to this house ID: " .. tostring(houseId))
        VORPcore.NotifyLeft("No access to this house.", "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
    end
end)

-- Handler to receive the house ID for giving access
RegisterNetEvent('bcc-housing:receiveHouseId')
AddEventHandler('bcc-housing:receiveHouseId', function(houseId)
    if houseId then
        devPrint("Received House ID for giving access: " .. tostring(houseId))
        showAccessMenu(houseId)
    else
        devPrint("No house found associated with your character")
        VORPcore.NotifyLeft("No house found associated with your character.", "", "scoretimer_textures",
            "scoretimer_generic_cross", 5000)
    end
end)

-- Handler to receive the house ID for removing access
RegisterNetEvent('bcc-housing:receiveHouseIdremove')
AddEventHandler('bcc-housing:receiveHouseIdremove', function(houseId)
    if houseId then
        devPrint("Received House ID for remove access: " .. tostring(houseId))
        showRemoveAccessMenu(houseId)
    else
        devPrint("No house found associated with your character")
        VORPcore.NotifyLeft("No house found associated with your character.", "", "scoretimer_textures",
            "scoretimer_generic_cross", 5000)
    end
end)

function afterGivingAccess(houseId, playerId, playerServerId, completion)
    if houseId and playerId and playerServerId then
        TriggerServerEvent('bcc-housing:NewPlayerGivenAccess', playerId, houseId, playerServerId)
        -- Assume this is handled and a response is sent back from the server
        -- Simulating a response callback for the sake of example
        completion(true, "Access granted successfully.") -- Call completion with success and message
    else
        completion(false, "Missing necessary information for granting access.")
    end
end

function afterRemoveAccess(houseId, playerId)
    devPrint("Attempting to remove access with House ID: " .. tostring(houseId) .. ", Player ID: " .. tostring(playerId))
    if houseId and playerId then
        TriggerServerEvent('bcc-housing:RemovePlayerAccess', houseId, playerId)
    end
end

function showAccessMenu(houseId)
    devPrint("Showing access menu for House ID: " .. tostring(houseId))
    PlayerListMenuForGiveAccess(houseId, afterGivingAccess, "giveAccess")
end

-- Function to show the remove access menu
function showRemoveAccessMenu(houseId)
    devPrint("Showing access menu for House ID: " .. tostring(houseId))
    PlayerListMenuForRemoveAccess(houseId, afterRemoveAccess, "removeAccess")
end

-- Function to show the player list menu for giving access
function PlayerListMenuForGiveAccess(houseId, callback, context)
    devPrint("Opening player list menu for giving access to House ID: " .. tostring(houseId))
    BCCHousingMenu:Close()
    local players = GetPlayers()
    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)

    local playerListGiveMenuPage = BCCHousingMenu:RegisterPage("bcc-housing:playerListGiveMenuPage")
    playerListGiveMenuPage:RegisterElement("header", {
        value = _U("StaticId_desc"),
        slot = "header",
        style = {}
    })

    playerListGiveMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for k, v in pairs(players) do
        playerListGiveMenuPage:RegisterElement("button", {
            label = v.PlayerName,
            style = {}
        }, function()
            callback(houseId, v.staticid, v.serverId, function(success, message)
                VORPcore.NotifyRightTip(message, 4000)
                TriggerEvent('bcc-housing:openmenu', houseId, true)
            end)
        end)
    end

    playerListGiveMenuPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    playerListGiveMenuPage:RegisterElement("button", {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, true)
    end)

    playerListGiveMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    playerListGiveMenuPage:RegisterElement('textdisplay', {
        slot = "footer",
        value = "Select player from this list to own this house or to have access",
        style = {}
    })

    BCCHousingMenu:Open({ startupPage = playerListGiveMenuPage })
end

function PlayerListMenuForRemoveAccess(houseId, callback, context)
    devPrint("Opening player list menu for removing access to House ID: " .. tostring(houseId))
    BCCHousingMenu:Close()
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    -- Asynchronous call to get players with access
    GetPlayersWithAccess(houseId, function(rplayers)
        devPrint("Number of players with access: " .. #rplayers) -- This will print the count of players fetched

        if #rplayers == 0 then
            devPrint("No players to display in menu")
            -- Consider what action to take if no players are available
            return -- Optionally return if no players are available to display
        end

        local playerListRemoveMenuPage = BCCHousingMenu:RegisterPage("bcc-housing:playerListRemoveMenuPage")
        playerListRemoveMenuPage:RegisterElement("header", {
            value = "Remove Access",
            slot = "header",
            style = {}
        })

        playerListRemoveMenuPage:RegisterElement('line', {
            slot = "header",
            style = {}
        })

        for k, v in pairs(rplayers) do
            devPrint("Adding button for player ID: " .. tostring(v.charidentifier)) -- Ensure charidentifier is correct
            playerListRemoveMenuPage:RegisterElement("button", {
                label = v.firstname .. " " .. v.lastname,                           -- Displaying player's name
                style = {}
            }, function()
                afterRemoveAccess(houseId, v.charidentifier)
                TriggerEvent('bcc-housing:openmenu', houseId, true)
            end)
        end

        playerListRemoveMenuPage:RegisterElement('line', {
            slot = "footer",
            style = {}
        })

        playerListRemoveMenuPage:RegisterElement("button", {
            label = _U("backButton"),
            slot = "footer",
            style = {}
        }, function()
            TriggerEvent('bcc-housing:openmenu', houseId, true)
        end)

        playerListRemoveMenuPage:RegisterElement('bottomline', {
            slot = "footer",
            style = {}
        })

        playerListRemoveMenuPage:RegisterElement('textdisplay', {
            slot = "footer",
            value = "Select player from this list to remove access",
            style = {}
        })

        BCCHousingMenu:Open({ startupPage = playerListRemoveMenuPage })
    end)
end

AddEventHandler('bcc-housing:openmenu', function(houseId, isOwner)
    devPrint("Opening housing main menu for House ID: " .. tostring(houseId) .. ", Is Owner: " .. tostring(isOwner))

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    local housingMainMenu = BCCHousingMenu:RegisterPage("bcc-housing:MainPage")
    housingMainMenu:RegisterElement('header', {
        value = _U("creationMenuName"),
        slot = 'header',
        style = {}
    })

    housingMainMenu:RegisterElement('line', {
        style = {}
    })

    housingMainMenu:RegisterElement('button', {
        label = _U("houseInv"),
        style = {}
    }, function()
        devPrint("Requesting house ID for inventory for House ID: " .. tostring(houseId))
        TriggerServerEvent('bcc-housing:getHouseId', 'inv', houseId)
    end)

    if TpHouse ~= nil then
        if not InTpHouse then
            housingMainMenu:RegisterElement('button', {
                label = _U("enterTpHouse"),
                style = {}
            }, function()
                enterOrExitHouse(true, TpHouse)
            end)
        else
            housingMainMenu:RegisterElement('button', {
                label = _U("exitTpHouse"),
                style = {}
            }, function()
                enterOrExitHouse(false)
            end)
        end
    end

    if isOwner then
        housingMainMenu:RegisterElement('button', {
            label = _U("giveAccess"),
            style = {}
        }, function()
            devPrint("Requesting house ID for access for House ID: " .. tostring(houseId))
            TriggerServerEvent('bcc-housing:getHouseId', 'access', houseId)
        end)

        housingMainMenu:RegisterElement('button', {
            label = _U("removeAccess"),
            style = {}
        }, function()
            devPrint("Requesting house ID for removing access for House ID: " .. tostring(houseId))
            TriggerServerEvent('bcc-housing:getHouseId', 'removeAccess', houseId)
        end)

        housingMainMenu:RegisterElement('button', {
            label = _U("furniture"),
            style = {}
        }, function()
            FurnitureMenu(houseId)
        end)

        housingMainMenu:RegisterElement('button', {
            label = _U("sellHouse"),
            style = {}
        }, function()
            sellHouseConfirmation(houseId)
        end)

        housingMainMenu:RegisterElement('button', {
            label = "Sell house to a player",
            style = {}
        }, function()
            sellHouseToPlayer(houseId)
        end)
    end

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
            TriggerEvent('bcc-housing:addLedger', houseId, isOwner)
        else
            devPrint("Error: HouseId is undefined or invalid.")
        end
    end)

    housingMainMenu:RegisterElement('bottomline', {
        style = {},
        slot = "footer"
    })

    housingMainMenu:RegisterElement("html", {
        value = {
            [[
                <img width="750px" height="108px" style="margin: 0 auto;" src="https://i.ibb.co/vvX3DB1/550x185logo.png" />

            ]]
        },
        slot = "footer"
    })
    BCCHousingMenu:Open({ startupPage = housingMainMenu })
end)

-- Helper function to manage entering or exiting houses
function enterOrExitHouse(enter, tpHouseIndex)
    BCCHousingMenu.Close()
    if enter then
        devPrint("Entering house with tpHouseIndex: " .. tostring(tpHouseIndex))
        local houseTable = Config.TpInteriors["Interior" .. tostring(tpHouseIndex)]
        CurrentTpHouse = tpHouseIndex
        enterTpHouse(houseTable)
    else
        devPrint("Exiting house")
        SetEntityCoords(PlayerPedId(), HouseCoords.x, HouseCoords.y, HouseCoords.z)
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(500)
        FreezeEntityPosition(PlayerPedId(), false)
        InTpHouse = false
        showManageOpt(HouseCoords.x, HouseCoords.y, HouseCoords.z)
    end
end

RegisterNetEvent('bcc-housing:addLedger')
AddEventHandler('bcc-housing:addLedger', function(houseId, isOwner)
    devPrint("Adding ledger for House ID: " .. tostring(houseId))
    local AddLedgerPage = BCCHousingMenu:RegisterPage('add_ledger_page')
    local amountToInsert = nil

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

    AddLedgerPage:RegisterElement('button', {
        label = _U("Confirm"),
        style = {}
    }, function()
        if amountToInsert then
            devPrint("Submitting ledger update for amount: " .. tostring(amountToInsert))
            TriggerServerEvent('bcc-housing:LedgerHandling', amountToInsert, houseId)
            BCCHousingMenu:Close()
        else
            devPrint("Error: Amount not set or invalid.")
        end
    end)

    AddLedgerPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    AddLedgerPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, isOwner)
    end)

    AddLedgerPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({ startupPage = AddLedgerPage })
end)

function enterTpHouse(houseTable)
    devPrint("Entering TP house")
    InTpHouse = true
    local pped = PlayerPedId()
    VORPcore.instancePlayers(tonumber(GetPlayerServerId(PlayerId())) + TpHouseInstance)
    SetEntityCoords(pped, houseTable.exitCoords.x, houseTable.exitCoords.y, houseTable.exitCoords.z)

    FreezeEntityPosition(pped, true)
    Wait(1000)
    FreezeEntityPosition(pped, false)
    showManageOpt(houseTable.exitCoords.x, houseTable.exitCoords.y, houseTable.exitCoords.z)
end
