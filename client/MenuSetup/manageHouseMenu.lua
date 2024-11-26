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
        VORPcore.NotifyLeft(_U('noAccessToHouse'), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
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
        VORPcore.NotifyLeft(_U('noHouseFound'), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
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
        VORPcore.NotifyLeft(_U('noHouseFound'), "", "scoretimer_textures", "scoretimer_generic_cross", 5000)
    end
end)

function afterGivingAccess(houseId, playerId, playerServerId, completion)
    if houseId and playerId and playerServerId then
        TriggerServerEvent('bcc-housing:NewPlayerGivenAccess', playerId, houseId, playerServerId)
        -- Assume this is handled and a response is sent back from the server
        -- Simulating a response callback for the sake of example
        completion(true, _U('accessGranted')) -- Call completion with success and message
    else
        completion(false, _U('missingInfos'))
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
                housingAccessMenu:RouteTo()
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
        housingAccessMenu:RouteTo()
    end)

    playerListGiveMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = playerListGiveMenuPage:RegisterElement('textdisplay', {
        slot = "footer",
        value = _U('selectPlayerFromList'),
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

        local playerListRemoveMenuPage = BCCHousingMenu:RegisterPage("bcc-housing:playerListRemoveMenuPage")
        playerListRemoveMenuPage:RegisterElement("header", {
            value = _U('removeAccess'),
            slot = "header",
            style = {}
        })

        playerListRemoveMenuPage:RegisterElement('line', {
            slot = "header",
            style = {}
        })

        if #rplayers == 0 then
            devPrint("No players to display in menu")
            TextDisplay = playerListRemoveMenuPage:RegisterElement('textdisplay', {
                value = "You didn`t give acess to anyone",
                style = {}
            })
        end

        for k, v in pairs(rplayers) do
            devPrint("Adding button for player ID: " .. tostring(v.charidentifier)) -- Ensure charidentifier is correct
            playerListRemoveMenuPage:RegisterElement("button", {
                label = v.firstname .. " " .. v.lastname,                           -- Displaying player's name
                style = {}
            }, function()
                afterRemoveAccess(houseId, v.charidentifier)
                housingAccessMenu:RouteTo()
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
            housingAccessMenu:RouteTo()
        end)

        playerListRemoveMenuPage:RegisterElement('bottomline', {
            slot = "footer",
            style = {}
        })

        TextDisplay = playerListRemoveMenuPage:RegisterElement('textdisplay', {
            slot = "footer",
            value = _U('selectPlayerToRemove'),
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
            label = _U('giveAccesstoHouse'),
            style = {}
        }, function()
            housingAccessMenu = BCCHousingMenu:RegisterPage("bcc-housing:AccessPage")
            housingAccessMenu:RegisterElement('header', {
                value = _U('giveAccesstoHouse'),
                slot = 'header',
                style = {}
            })

            housingAccessMenu:RegisterElement('line', {
                style = {}
            })
            housingAccessMenu:RegisterElement('button', {
                label = _U("giveAccess"),
                style = {}
            }, function()
                devPrint("Requesting house ID for access for House ID: " .. tostring(houseId))
                TriggerServerEvent('bcc-housing:getHouseId', 'access', houseId)
            end)

            housingAccessMenu:RegisterElement('button', {
                label = _U("removeAccess"),
                style = {}
            }, function()
                devPrint("Requesting house ID for removing access for House ID: " .. tostring(houseId))
                TriggerServerEvent('bcc-housing:getHouseId', 'removeAccess', houseId)
            end)

            housingAccessMenu:RegisterElement('line', {
                slot = "footer",
                style = {}
            })

            housingAccessMenu:RegisterElement('button', {
                label = _U("backButton"),
                slot = "footer",
                style = {}
            }, function()
                housingMainMenu:RouteTo()
            end)

            housingAccessMenu:RegisterElement('bottomline', {
                style = {},
                slot = "footer"
            })

            BCCHousingMenu:Open({ startupPage = housingAccessMenu })
        end)

        housingMainMenu:RegisterElement('button', {
            label = "Doors",
            style = {}
        }, function()
            local doorManagementPage = BCCHousingMenu:RegisterPage('owner_door_management_page')

            -- Header
            doorManagementPage:RegisterElement('header', {
                value = _U("doorManagementTitle"),
                slot = "header",
                style = {}
            })

            doorManagementPage:RegisterElement('line', {
                slot = "header",
                style = {}
            })

            doorManagementPage:RegisterElement('button', {
                label = _U("createNewDoor"),
                style = {}
            }, function()
                BCCHousingMenu:Close()                         -- Close the menu before proceeding
                local playerId = GetPlayerServerId(PlayerId()) -- Get the current player's server ID
                local newDoorId = exports['bcc-doorlocks']:addPlayerToDoor(playerId)

                if newDoorId then
                    devPrint("Door created and player added successfully: " .. tostring(newDoorId))

                    -- Save the door to the house database using the RPC call
                    BccUtils.RPC:Call("bcc-housing:AddDoorToHouse", { houseId = houseId, newDoor = newDoorId },
                        function(success)
                            if success then
                                VORPcore.NotifyRightTip(_U("doorCreated"), 4000)
                            else
                                VORPcore.NotifyRightTip(_U("doorSaveFailed"), 4000)
                            end
                        end)
                else
                    VORPcore.NotifyRightTip(_U("doorCreationFailed"), 4000)
                end
            end)

            -- List Doors Button
            doorManagementPage:RegisterElement('button', {
                label = _U("listDoors"),
                style = {}
            }, function()
                local doorListPage = BCCHousingMenu:RegisterPage('door_list_management_page')

                -- Header
                doorListPage:RegisterElement('header', {
                    value = _U("doorManagementTitle"),
                    slot = "header",
                    style = {}
                })

                doorListPage:RegisterElement('line', {
                    slot = "header",
                    style = {}
                })

                -- Fetch doors for the current house ID using RPC
                local currentHouseId = houseId -- Replace with your actual house ID source
                if not currentHouseId then
                    VORPcore.NotifyRightTip(_U("invalidHouseId"), 4000)
                    return
                end

                BccUtils.RPC:Call("bcc-housing:GetDoorsByHouseId", { houseId = currentHouseId }, function(doors)
                    if not doors or #doors == 0 then
                        -- If no doors are found, display a message
                        doorListPage:RegisterElement('textdisplay', {
                            value = _U("noDoorsFound"),
                            slot = "content",
                            style = {}
                        })
                    else
                        -- Iterate through and list each door
                        for k, door in ipairs(doors) do
                            doorListPage:RegisterElement('button', {
                                label = _U("doorId") .. (door.doorid or k),
                                style = {}
                            }, function()
                                local doorOptionsPage = BCCHousingMenu:RegisterPage('door_options_page')

                                doorOptionsPage:RegisterElement('header', {
                                    value = _U("doorOptions") .. (door.doorid or ""),
                                    slot = "header",
                                    style = {}
                                })

                                doorOptionsPage:RegisterElement('line', {
                                    slot = "header",
                                    style = {}
                                })

                                -- Remove Door Button
                                doorOptionsPage:RegisterElement('button', {
                                    label = _U("removeDoor"),
                                    style = {}
                                }, function()
                                    local doorRemoveDoorPage = BCCHousingMenu:RegisterPage('door_options_page')

                                    doorRemoveDoorPage:RegisterElement('header', {
                                        value = _U("confirmDoorDelete") .. (door.doorid or ""),
                                        slot = "header",
                                        style = {}
                                    })

                                    doorRemoveDoorPage:RegisterElement('line', {
                                        slot = "header",
                                        style = {}
                                    })

                                    -- Confirm Remove Door Button
                                    doorRemoveDoorPage:RegisterElement('button', {
                                        label = _U("confirmYes"),
                                        style = {}
                                    }, function()
                                        -- Use RPC to remove the door
                                        BccUtils.RPC:Call("bcc-housing:DeleteDoor", { doorId = door.doorid },
                                            function(success)
                                                if success then
                                                    VORPcore.NotifyRightTip(_U("doorRemoved"), 4000)
                                                else
                                                    VORPcore.NotifyRightTip(_U("doorRemoveFailed"), 4000)
                                                end

                                                -- Route back to the door list page
                                                doorListPage:RouteTo()
                                            end)
                                    end)


                                    doorRemoveDoorPage:RegisterElement('button', {
                                        label = _U("confirmNo"),
                                        style = {}
                                    }, function()
                                        doorListPage:RouteTo()
                                    end)

                                    doorRemoveDoorPage:RegisterElement('line', {
                                        slot = "footer",
                                        style = {}
                                    })

                                    doorRemoveDoorPage:RegisterElement('button', {
                                        label = _U("backButton"),
                                        slot = "footer",
                                        style = {}
                                    }, function()
                                        doorOptionsPage:RouteTo()
                                    end)

                                    doorRemoveDoorPage:RegisterElement('bottomline', {
                                        slot = "footer",
                                        style = {}
                                    })

                                    BCCHousingMenu:Open({
                                        startupPage = doorRemoveDoorPage
                                    })
                                end)

                                -- Update Door Button
                                doorOptionsPage:RegisterElement('button', {
                                    label = _U('giveAccesstoDoor'),
                                    style = {}
                                }, function()
                                    -- Fetch players with access to the house using an RPC
                                    BccUtils.RPC:Call("bcc-housing:GetPlayersWithAccess", { houseId = houseId },
                                        function(players)
                                            if not players or #players == 0 then
                                                VORPcore.NotifyRightTip(_U('doorNoUsersWithAccess'), 4000)
                                                return
                                            end
                                            local giveAccessPage = BCCHousingMenu:RegisterPage('give_access_page')

                                            -- Header
                                            giveAccessPage:RegisterElement('header', {
                                                value = _U('doorSelectUser'),
                                                slot = "header",
                                                style = {}
                                            })

                                            giveAccessPage:RegisterElement('line', {
                                                slot = "header",
                                                style = {}
                                            })

                                            -- List players with access
                                            for _, player in ipairs(players) do
                                                giveAccessPage:RegisterElement('button', {
                                                    label = "ID: " ..
                                                    tostring(player.charidentifier) ..
                                                    " Name: " .. player.firstname .. " " .. player.lastname,
                                                    style = {}
                                                }, function()
                                                    if not door.doorid then
                                                        devPrint("Invalid door ID.")
                                                        return
                                                    end

                                                    -- Give access to the door using an RPC
                                                    BccUtils.RPC:Call("bcc-housing:GiveAccessToDoor",{ doorId = door.doorid, userId = player.charidentifier },
                                                        function(success)
                                                            if success then
                                                                BCCHousingMenu:Close()
                                                                VORPcore.NotifyObjective(
                                                                _U('doorAccessGranted') ..
                                                                player.firstname .. " " .. player.lastname, 4000)
                                                            else
                                                                BCCHousingMenu:Close()
                                                                VORPcore.NotifyObjective(
                                                                player.firstname ..
                                                                " " .. player.lastname .. _U('doorHasAccess'), 4000)
                                                            end
                                                        end)
                                                end)
                                            end

                                            giveAccessPage:RegisterElement('line', {
                                                slot = "footer",
                                                style = {}
                                            })

                                            -- Back button
                                            giveAccessPage:RegisterElement('button', {
                                                label = _U("backButton"),
                                                slot = "footer",
                                                style = {}
                                            }, function()
                                                doorOptionsPage:RouteTo()
                                            end)

                                            giveAccessPage:RegisterElement('bottomline', {
                                                slot = "footer",
                                                style = {}
                                            })

                                            BCCHousingMenu:Open({
                                                startupPage = giveAccessPage
                                            })
                                        end)
                                end)
                                -- Remove Player Access Button
                                doorOptionsPage:RegisterElement('button', {
                                    label = _U('removeAccessFromDoor'),
                                    style = {}
                                }, function()
                                    -- Fetch players with access to the house using an RPC
                                    BccUtils.RPC:Call("bcc-housing:GetPlayersWithAccess", { houseId = houseId },
                                        function(players)
                                            if not players or #players == 0 then
                                                VORPcore.NotifyRightTip(_U('doorNoUsersWithAccess'), 4000)
                                                return
                                            end

                                            local removeAccessPage = BCCHousingMenu:RegisterPage('remove_access_page')

                                            -- Header
                                            removeAccessPage:RegisterElement('header', {
                                                value = _U('doorSelectUserToRemove'),
                                                slot = "header",
                                                style = {}
                                            })

                                            removeAccessPage:RegisterElement('line', {
                                                slot = "header",
                                                style = {}
                                            })

                                            -- List players with access
                                            for _, player in ipairs(players) do
                                                removeAccessPage:RegisterElement('button', {
                                                    label = "ID: " .. tostring(player.charidentifier) ..
                                                        " Name: " .. player.firstname .. " " .. player.lastname,
                                                    style = {}
                                                }, function()
                                                    if not door.doorid then
                                                        devPrint("Invalid door ID.")
                                                        return
                                                    end

                                                    -- Remove access from the door using an RPC
                                                    BccUtils.RPC:Call("bcc-housing:RemoveAccessFromDoor",
                                                        { doorId = door.doorid, userId = player.charidentifier },
                                                        function(success)
                                                            if success then
                                                                doorOptionsPage:RouteTo()
                                                                VORPcore.NotifyObjective(
                                                                player.firstname ..
                                                                " " .. player.lastname .. _U('doorAccessRevoked'), 4000)
                                                            else
                                                                doorOptionsPage:RouteTo()
                                                                VORPcore.NotifyObjective(
                                                                _U('doorRemoveAccessFailed') ..
                                                                player.firstname .. " " .. player.lastname, 4000)
                                                            end
                                                        end)
                                                end)
                                            end

                                            removeAccessPage:RegisterElement('line', {
                                                slot = "footer",
                                                style = {}
                                            })

                                            -- Back button
                                            removeAccessPage:RegisterElement('button', {
                                                label = _U("backButton"),
                                                slot = "footer",
                                                style = {}
                                            }, function()
                                                doorOptionsPage:RouteTo()
                                            end)

                                            removeAccessPage:RegisterElement('bottomline', {
                                                slot = "footer",
                                                style = {}
                                            })

                                            BCCHousingMenu:Open({
                                                startupPage = removeAccessPage
                                            })
                                        end)
                                end)

                                -- Footer for Door Options
                                doorOptionsPage:RegisterElement('line', {
                                    slot = "footer",
                                    style = {}
                                })

                                doorOptionsPage:RegisterElement('button', {
                                    label = _U("backButton"),
                                    slot = "footer",
                                    style = {}
                                }, function()
                                    doorListPage:RouteTo()
                                end)

                                doorOptionsPage:RegisterElement('bottomline', {
                                    slot = "footer",
                                    style = {}
                                })

                                BCCHousingMenu:Open({
                                    startupPage = doorOptionsPage
                                })
                            end)
                        end
                    end

                    -- Footer for Door List Page
                    doorListPage:RegisterElement('line', {
                        slot = "footer",
                        style = {}
                    })

                    doorListPage:RegisterElement('button', {
                        label = _U("backButton"),
                        slot = "footer",
                        style = {}
                    }, function()
                        doorManagementPage:RouteTo()
                    end)

                    BCCHousingMenu:Open({
                        startupPage = doorListPage
                    })
                end)
            end)

            -- Footer
            doorManagementPage:RegisterElement('line', {
                slot = "footer",
                style = {}
            })

            doorManagementPage:RegisterElement('button', {
                label = _U("backButton"),
                slot = "footer",
                style = {}
            }, function()
                housingMainMenu:RouteTo()
            end)

            doorManagementPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })

            BCCHousingMenu:Open({
                startupPage = doorManagementPage
            })
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
            label = _U('sellHouseToPlayer'),
            style = {}
        }, function()
            sellHouseToPlayer(houseId)
        end)
    end

    housingMainMenu:RegisterElement('button', {
        label = _U("ledger"),
        style = {}
    }, function()
        local ledgerPage = BCCHousingMenu:RegisterPage('bcc-housing:ledger:page')
        ledgerPage:RegisterElement('header', {
            value = _U("ledger"),
            slot = "header",
            style = {}
        })

        ledgerPage:RegisterElement('button', {
            label = _U("checkledger"),
            style = {}
        }, function()
            TriggerServerEvent('bcc-housing:CheckLedger', houseId)
        end)

        ledgerPage:RegisterElement('button', {
            label = _U("ledger"),
            style = {}
        }, function()
            if houseId then
                TriggerEvent('bcc-housing:addLedger', houseId, isOwner)
            else
                devPrint("Error: HouseId is undefined or invalid.")
            end
        end)

        ledgerPage:RegisterElement('button', {
            label = _U('removeFromLedger'),
            style = {}
        }, function()
            if houseId then
                TriggerEvent('bcc-housing:removeLedger', houseId, isOwner)
            else
                devPrint("Error: HouseId is undefined or invalid.")
            end
        end)

        ledgerPage:RegisterElement('line', {
            slot = "footer",
            style = {}
        })

        ledgerPage:RegisterElement('button', {
            label = _U("backButton"),
            slot = "footer",
            style = {}
        }, function()
            TriggerEvent('bcc-housing:openmenu', houseId, isOwner)
        end)

        ledgerPage:RegisterElement('bottomline', {
            style = {},
            slot = "footer"
        })

        BCCHousingMenu:Open({ startupPage = ledgerPage })
    end)

    housingMainMenu:RegisterElement('bottomline', {
        style = {},
        slot = "footer"
    })

    if Config.UseImageAtBottomMenu then
        housingMainMenu:RegisterElement("html", {
            value = {
                string.format([[
                    <img width="750px" height="108px" style="margin: 0 auto;" src="%s" />
                ]], Config.HouseImageURL)
            },
            slot = "footer"
        })
    end
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

-- Event to open the add ledger page
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

    AddLedgerPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    AddLedgerPage:RegisterElement('button', {
        label = _U("Confirm"),
        slot = "footer",
        style = {}
    }, function()
        if amountToInsert then
            devPrint("Submitting ledger update for amount: " .. tostring(amountToInsert) .. " (Adding)")
            TriggerServerEvent('bcc-housing:LedgerHandling', amountToInsert, houseId, true) -- true for adding
            BCCHousingMenu:Close()
        else
            devPrint("Error: Amount not set or invalid.")
        end
    end)

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

-- Event to open the remove ledger page
RegisterNetEvent('bcc-housing:removeLedger')
AddEventHandler('bcc-housing:removeLedger', function(houseId, isOwner)
    devPrint("Remove ledger for House ID: " .. tostring(houseId))
    local RemoveLedgerPage = BCCHousingMenu:RegisterPage('remove_ledger_page')
    local amountToInsert = nil

    RemoveLedgerPage:RegisterElement('header', {
        value = _U('ledger'),
        slot = 'header',
        style = {}
    })

    RemoveLedgerPage:RegisterElement('input', {
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

    RemoveLedgerPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    RemoveLedgerPage:RegisterElement('button', {
        label = _U("Confirm"),
        slot = "footer",
        style = {}
    }, function()
        if amountToInsert then
            devPrint("Submitting ledger update for amount: " .. tostring(amountToInsert) .. " (Removing)")
            TriggerServerEvent('bcc-housing:LedgerHandling', amountToInsert, houseId, false) -- false for removing
            BCCHousingMenu:Close()
        else
            devPrint("Error: Amount not set or invalid.")
        end
    end)

    RemoveLedgerPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, isOwner)
    end)

    RemoveLedgerPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({ startupPage = RemoveLedgerPage })
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
