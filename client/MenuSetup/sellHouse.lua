function sellHouseConfirmation(houseId, ownershipStatus)
    if not houseId then
        devPrint("Error: houseInfo is nil")
        return
    end

    if ownershipStatus ~= "purchased" then
        devPrint("Error: cannot sold rented house to player")
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
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, true, ownershipStatus)
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

function sellHouseToPlayer(houseId, ownershipStatus)
    if not houseId then
        devPrint("Error: houseId is nil")
        return
    end

    if ownershipStatus ~= "purchased" then
        devPrint("Error: cannot sold rented house to player")
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
        value = _U("sellHouseToPlayer"),
        slot = "header",
        style = {}
    })

    sellHouseToPlayer:RegisterElement('line', {
        style = {}
    })

    -- Button to sell house with inventory
    sellHouseToPlayer:RegisterElement('button', {
        label = _U("sellHouseWithInv"),
        style = {}
    }, function()
        OpenSellHouseToPlayerMenu(houseId, true, ownershipStatus) -- true indicates selling with inventory
    end)

    -- Button to sell house without inventory
    sellHouseToPlayer:RegisterElement('button', {
        label = _U("sellHouseWithoutInv"),
        style = {}
    }, function()
        OpenSellHouseToPlayerMenu(houseId, false, ownershipStatus) -- false indicates selling without inventory
    end)

    sellHouseToPlayer:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    sellHouseToPlayer:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, true, ownershipStatus)
    end)

    sellHouseToPlayer:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = sellHouseToPlayer:RegisterElement('html', {
        value = _U("sellHouseDesc"),
        slot = "footer",
        style = {
            ["font-size"] = "16px",
            ["color"] = "#ffffff",
            ["text-align"] = "center",
            ["line-height"] = "1.5",
            ["margin-top"] = "10px"
        }
    })

    BCCHousingMenu:Open({
        startupPage = sellHouseToPlayer
    })
end

function OpenSellHouseToPlayerMenu(houseId, withInventory, ownershipStatus)

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
        local salePrice = Config.DefaultSellPricetoPlayer -- Get the sale price from your config
        InputField = sellHouseToPlayerMenu:RegisterElement('input', {
            label = _U('setPriceToPlayer'),
            placeholder = tostring(salePrice),
            value = salePrice,
            -- persist = false,
            style = {
                -- ['background-image'] = 'none',
                -- ['background-color'] = '#E8E8E8',
                -- ['color'] = 'black',
                -- ['border-radius'] = '6px'
            }
        }, function(data)
            local temp = tonumber(data.value)
            if temp and temp > 0 then
                salePrice = temp
            else
                InputField:update({value = salePrice})
            end
        end)

        for _, player in ipairs(nearbyPlayers) do
            local targetId = GetPlayerFromServerId(player.id)
            local showPlayer = Config.dontShowNames and player.id or GetPlayerName(targetId)
            sellHouseToPlayerMenu:RegisterElement('button', {
                label = _U('sellTo') .. showPlayer,
                style = {}
            }, function()
                OpenConfirmSellHouseMenu(houseId, player.id, showPlayer, withInventory, ownershipStatus, salePrice)
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
        sellHouseToPlayer(houseId, ownershipStatus)
    end)

    BCCHousingMenu:Open({ startupPage = sellHouseToPlayerMenu })
end

function OpenConfirmSellHouseMenu(houseId, targetPlayerId, targetPlayerName, withInventory, ownershipStatus, salePrice)
    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    if salePrice < 0 then
        return
    end

    local confirmMenu = BCCHousingMenu:RegisterPage("confirmSellHouseMenu")

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
        ]], _U('confirmSellText', targetPlayerName, salePrice)),
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
        OpenSellHouseToPlayerMenu(houseId, withInventory, ownershipStatus)
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
