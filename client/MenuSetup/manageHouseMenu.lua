function HousingManagementMenu()
    Inmenu = true
    TriggerEvent('bcc-housing:MenuClose')
    MenuData.CloseAll()
    local elements = {
        { label = _U("houseInv"), value = 'openinv', desc = _U("houseInv_desc") },
    }
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
            end
        end)
end