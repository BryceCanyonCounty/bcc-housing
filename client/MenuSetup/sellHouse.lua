function sellHouseConfirmation(houseId)
    if not houseId then
        devPrint("Error: houseInfo is nil")
        return
    end

    if BCCHousingMenu then
        BCCHousingMenu:Close()
    end
    
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    
    local sellHouseConfirmation = BCCHousingMenu:RegisterPage("sell_house_page_confirmation")

    sellHouseConfirmation:RegisterElement('header', {
        value = _U('sellHouse'),
        slot = "header",
        style = {}
    })

    sellHouseConfirmation:RegisterElement('html', {
        value = string.format([[
            <div style="
                text-align: center;
                padding: 20px;
                color: #FFF3E0;
                max-width: 400px;
                margin: 0 auto;
            ">
                <p style="font-size: 20px; font-weight: bold; margin: 0;">
                    %s
                </p>
            </div>
        ]], _U('sellConfirmationText')),  -- Using the localized text
        style = {}
    })

    sellHouseConfirmation:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    sellHouseConfirmation:RegisterElement('button', {
        label = _U('Yes'),
        slot = "footer",
        style = {}
    }, function()
        TriggerServerEvent('bcc-housing:sellHouse', houseId)
        BCCHousingMenu:Close()
    end)

    sellHouseConfirmation:RegisterElement('button', {
        label = _U('No'),
        slot = "footer",
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, true)
    end)

    sellHouseConfirmation:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = sellHouseConfirmation:RegisterElement('textdisplay', {
        value = _U('sellHouseIrreversible'),
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = sellHouseConfirmation
    })
end

function sellHouseToPlayer(houseId)
    if not houseId then
        devPrint("Error: houseId is nil")
        return
    end

    if BCCHousingMenu then
        BCCHousingMenu:Close()
    end

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    
    local sellHouseToPlayer = BCCHousingMenu:RegisterPage("sell_house_toPlayer_page")

    sellHouseToPlayer:RegisterElement('header', {
        value = "Sell House To a Player",
        slot = "header",
        style = {}
    })

    sellHouseToPlayer:RegisterElement('line', {
        style = {}
    })

    -- Button to sell house with inventory
    sellHouseToPlayer:RegisterElement('button', {
        label = "Sell house with inventory",
        style = {}
    }, function()
        OpenSellHouseToPlayerMenu(houseId, true) -- true indicates selling with inventory
    end)

    -- Button to sell house without inventory
    sellHouseToPlayer:RegisterElement('button', {
        label = "Sell house without inventory",
        style = {}
    }, function()
        OpenSellHouseToPlayerMenu(houseId, false) -- false indicates selling without inventory
    end)

    sellHouseToPlayer:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    sellHouseToPlayer:RegisterElement('button', {
        label = "Back",
        slot = "footer",
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, true)
    end)

    sellHouseToPlayer:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = sellHouseToPlayer:RegisterElement('textdisplay', {
        value = "Sell this house to a player? Please choose one option",
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = sellHouseToPlayer
    })
end

function OpenSellHouseToPlayerMenu(houseId, withInventory)

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    
    local nearbyPlayers = GetNearbyPlayers()
    local sellHouseToPlayerMenu = BCCHousingMenu:RegisterPage("sell_house_player_select")

    sellHouseToPlayerMenu:RegisterElement('header', {
        value = _U('selectPlayer'),
        slot = "header"
    })

    if #nearbyPlayers > 0 then
        for _, player in ipairs(nearbyPlayers) do
            sellHouseToPlayerMenu:RegisterElement('button', {
                label = _U('sellTo') .. GetPlayerName(GetPlayerFromServerId(player.id)),
                style = {}
            }, function()
                OpenConfirmSellHouseMenu(houseId, player.id, GetPlayerName(GetPlayerFromServerId(player.id)),
                withInventory)
            end)
        end
    else
        sellHouseToPlayerMenu:RegisterElement('textdisplay', {
            value = _U('noNearbyFound'),
            style = { color = 'red', ['text-align'] = 'center', ['margin-top'] = '10px' }
        })
    end

    sellHouseToPlayerMenu:RegisterElement('button', {
        label = _U('backButton'),
        slot = "footer",
        style = {}
    }, function()
        sellHouseToPlayer(houseId)
    end)

    BCCHousingMenu:Open({ startupPage = sellHouseToPlayerMenu })
end

function OpenConfirmSellHouseMenu(houseId, targetPlayerId, targetPlayerName, withInventory)
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end
    
    local confirmMenu = BCCHousingMenu:RegisterPage("confirmSellHouseMenu")
    local salePrice = Config.DefaultSellPricetoPlayer -- Get the sale price from your config

    confirmMenu:RegisterElement('header', { 
        value = _U('confirmSale'),
        slot = 'header'
    })
    
    confirmMenu:RegisterElement('html', {
        value = string.format([[
            <div style="
                text-align: center;
                padding: 20px;
                color: #FFF3E0;
                max-width: 400px;
                margin: 0 auto;
            ">
                <p style="font-size: 20px; font-weight: bold; margin: 0;">
                    %s
                </p>
            </div>
        ]], string.format(_U('confirmSellText'), targetPlayerName, salePrice)),
        style = {}
    })
    
    confirmMenu:RegisterElement('button', {
        label = _U('Yes'),
        style = {}
    }, function()
        if withInventory then
            TriggerServerEvent('bcc-housing:sellHouseToPlayerWithInventory', houseId, targetPlayerId, salePrice)
        else
            TriggerServerEvent('bcc-housing:sellHouseToPlayerWithoutInventory', houseId, targetPlayerId, salePrice)
        end
        BCCHousingMenu:Close()
    end)

    confirmMenu:RegisterElement('button', { 
        label = _U('No'), 
        style = {}
    }, function()
        OpenSellHouseToPlayerMenu(houseId, withInventory)
    end)

    BCCHousingMenu:Open({ startupPage = confirmMenu })
end

function GetNearbyPlayers()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyPlayers = {}

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if distance < 3.0 then
                table.insert(nearbyPlayers, { id = GetPlayerServerId(player), distance = distance })
                devPrint("Found nearby player:", GetPlayerServerId(player))
            end
        end
    end

    return nearbyPlayers
end
