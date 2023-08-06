InTpHouse, CurrentTpHouse, BreakHandleLoop = false, nil, false
function HousingManagementMenu()
    Inmenu = true
    VORPMenu.CloseAll()
    local elements = {
        { label = _U("houseInv"), value = 'openinv', desc = _U("houseInv_desc") },
    }
    if TpHouse ~= nil then
        if not InTpHouse then
            table.insert(elements, { label = _U("enterTpHouse"), value = 'entertp', desc = _U("enterTpHouse_desc") })
        else
            table.insert(elements, { label = _U("exitTpHouse"), value = 'exittp', desc = _U("exitTpHouse_desc") })
        end
    end
    if Owner then
        table.insert(elements, { label = _U("giveAccess"), value = 'giveaccess', desc = _U("giveAccess_desc") })
        table.insert(elements, { label = _U("furniture"), value = 'furniture', desc = _U("furniture_desc") })
        table.insert(elements, { label = _U("ledger"), value = 'ledger', desc = _U("ledger_desc") })
        table.insert(elements, { label = _U("checkledger"), value = 'checkledger', desc = _U("checkledger_desc") })
    end

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title = _U("creationMenuName"),
            align = 'top-left',
            elements = elements,
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local selectedOption = {
                ['giveaccess'] = function()
                    PlayerList('HousingManagementMenu')
                end,
                ['openinv'] = function()
                    TriggerServerEvent('bcc-house:OpenHouseInv', HouseId)
                end,
                ['furniture'] = function()
                    FurnitureMenu()
                end,
                ['ledger'] = function()
                    local myInput = {
                        type = "enableinput",                                               -- don't touch
                        inputType = "input",                                                -- input type
                        button = _U("Confirm"),                                             -- button name
                        placeholder = _U("ledgerAmountToInsert"),                               -- placeholder name
                        style = "block",                                                    -- don't touch
                        attributes = {
                            inputHeader = "",                                               -- header
                            type = "number",                                                -- inputype text, number,date,textarea ETC
                            pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
                            title = _U("InvalidInput"),                                     -- if input doesnt match show this message
                            style = "border-radius: 10px; background-color: ; border:none;" -- style
                        }
                    }
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if result ~= nil and type(result) == "number" and tonumber(result) > 0 then
                            TriggerServerEvent('bcc-housing:LedgerHandling', tonumber(result), HouseId)
                            VORPMenu.CloseAll()
                        else
                            VORPMenu.CloseAll()
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['checkledger'] = function()
                    TriggerServerEvent('bcc-housing:CheckLedger', HouseId)
                end,
                ['entertp'] = function()
                    local houseTable = nil
                    if tonumber(TpHouse) == 1 then
                        houseTable = Config.TpInteriors.Interior1
                        CurrentTpHouse = 1
                    elseif
                    tonumber(TpHouse) == 2 then
                        houseTable = Config.TpInteriors.Interior2
                        CurrentTpHouse = 2
                    end
                    VORPMenu.CloseAll()
                    Inmenu = false
                    BreakHandleLoop = true
                    Wait(50)
                    BreakHandleLoop = false
                    enterTpHouse(houseTable)
                end,
                ['exittp'] = function()
                    BreakHandleLoop = true
                    Wait(50)
                    BreakHandleLoop = false
                    VORPMenu.CloseAll()
                    SetEntityCoords(PlayerPedId(), HouseCoords.x, HouseCoords.y, HouseCoords.z)
                    FreezeEntityPosition(PlayerPedId(), true)
                    Wait(500)
                    FreezeEntityPosition(PlayerPedId(), false)
                    InTpHouse = false
                    showManageOpt(HouseCoords.x, HouseCoords.y, HouseCoords.z)
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function enterTpHouse(houseTable)
    InTpHouse = true
    local pped =  PlayerPedId()
    VORPcore.instancePlayers(tonumber(GetPlayerServerId(PlayerId())) + TpHouseInstance)
    SetEntityCoords(pped, houseTable.exitCoords.x, houseTable.exitCoords.y, houseTable.exitCoords.z)

    FreezeEntityPosition(pped, true) --done to prevent falling through ground
    Wait(1000)
    FreezeEntityPosition(pped, false)
    showManageOpt(houseTable.exitCoords.x, houseTable.exitCoords.y, houseTable.exitCoords.z)
end