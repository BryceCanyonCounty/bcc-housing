--------- Show the player list credit to vorp admin for this
RegisterCommand(Config.AdminManagementMenuCommand, function()
    if AdminAllowed then
        TriggerServerEvent('bcc-housing:AdminGetAllHouses')
    end
end)

RegisterNetEvent('bcc-housing:AdminManagementMenu', function(allHouses)
    MenuData.CloseAll()
    Inmenu = true
    TriggerEvent('bcc-housing:MenuClose')
    local elements = {}

    for k, houseInfo in pairs(allHouses) do
        elements[#elements + 1] = {
            label = _U("ownerHouseId") ..  houseInfo.houseid,
            value = "house" .. k,
            desc = _U("selectThisHouse") .. "<span style=color:MediumSeaGreen;> ",
            info = houseInfo
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("adminManagmentMenu"),
            subtext    = "",
            align      = 'top-left',
            elements   = elements,
            itemHeight = "4vh"
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                MenuData.CloseAll()
                AdminManagementMenuHouseChose(data.current.info)
            end
        end)
end)

function AdminManagementMenuHouseChose(houseTable)
    local elements = {
        { label = _U("delHouse"), value = 'delhouse', desc = _U("delHouse_desc") },
        { label = _U("changeHouseRadius"), value = 'changeradius', desc = _U("changeHouseRadius_desc") },
        { label = _U("changeHouseInvLimit"), value = 'changeinvlimit', desc = _U("changeHouseInvLimit_desc") },
        { label = _U("changeHouseTaxes"), value = 'changetaxes', desc = _U("changeHouseTaxes_desc") }
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("adminManagmentMenu"),
            align = 'top-left',
            elements = elements
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local myInput = { --input var used for all the options below since they are all number inputs
                type = "enableinput",                                               -- don't touch
                inputType = "input",                                                -- input type
                button = _U("Confirm"),                                             -- button name
                placeholder = _U("insertAmount"),                               -- placeholder name
                style = "block",                                                    -- don't touch
                attributes = {
                    inputHeader = "",                                               -- header
                    type = "number",                                                -- inputype text, number,date,textarea ETC
                    pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
                    title = _U("InvalidInput"),                                     -- if input doesnt match show this message
                    style = "border-radius: 10px; background-color: ; border:none;" -- style
                }
            }
            local selectedOption = {
                ['delhouse'] = function()
                    TriggerServerEvent('bcc-house:AdminManagementDelHouse', houseTable.houseid)
                    VORPcore.NotifyRightTip(_U("housesDeleted"), 4000)
                    MenuData.CloseAll()
                end,
                ['changeradius'] = function()
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if tonumber(result) > 0 then
                            TriggerServerEvent('bcc-house:AdminManagementChangeHouseRadius', houseTable.houseid, tonumber(result))
                            VORPcore.NotifyRightTip(_U("radiusSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['changeinvlimit'] = function()
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if tonumber(result) > 0 then
                            TriggerServerEvent('bcc-house:AdminManagementChangeInvLimit', houseTable.houseid, tonumber(result))
                            VORPcore.NotifyRightTip(_U("invLimitSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['changetaxes'] = function()
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if tonumber(result) > 0 then
                            TriggerServerEvent('bcc-house:AdminManagementChangeTaxAmount', houseTable.houseid, tonumber(result))
                            VORPcore.NotifyRightTip(_U("taxAmountSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end