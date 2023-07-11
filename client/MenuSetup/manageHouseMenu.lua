InTpHouse = false
CurrentTpHouse = nil
BreakHandleLoop = false
function HousingManagementMenu()
    Inmenu = true
    TriggerEvent('bcc-housing:MenuClose')
    MenuData.CloseAll()
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

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("creationMenuName"),
            align = 'top-left',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'giveaccess' then
                PlayerList('HousingManagementMenu')
            elseif data.current.value == 'openinv' then
                TriggerServerEvent('bcc-house:OpenHouseInv', HouseId)
            elseif data.current.value == 'furniture' then
                FurnitureMenu()
            elseif data.current.value == 'ledger' then
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
                    if tonumber(result) > 0 then
                        TriggerServerEvent('bcc-housing:LedgerHandling', tonumber(result), HouseId)
                        MenuData.CloseAll()
                    else
                        VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                    end
                end)
            elseif data.current.value == 'checkledger' then
                TriggerServerEvent('bcc-housing:CheckLedger', HouseId)
            elseif data.current.value == 'entertp' then
                local houseTable = nil
                if tonumber(TpHouse) == 1 then
                    houseTable = Config.TpInteriors.Interior1
                    CurrentTpHouse = 1
                elseif
                tonumber(TpHouse) == 2 then
                    houseTable = Config.TpInteriors.Interior2
                    CurrentTpHouse = 2
                end
                MenuData.CloseAll()
                Inmenu = false
                BreakHandleLoop = true
                Wait(50)
                BreakHandleLoop = false
                enterTpHouse(houseTable)
            elseif data.current.value == "exittp" then
                BreakHandleLoop = true
                Wait(50)
                BreakHandleLoop = false
                MenuData.CloseAll()
                SetEntityCoords(PlayerPedId(), HouseCoords.x, HouseCoords.y, HouseCoords.z)
                FreezeEntityPosition(PlayerPedId(), true)
                Wait(500)
                FreezeEntityPosition(PlayerPedId(), false)
                InTpHouse = false
                showManageOpt(HouseCoords.x, HouseCoords.y, HouseCoords.z)
            end
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