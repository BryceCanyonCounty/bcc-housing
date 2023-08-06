---- Variables ----
local ownerId, houseRadius, doors, houseCoords, InvLimit, ownerSource, taxAmount, tpInt = nil, nil, {}, nil, nil, nil, nil, nil
Inmenu = false

------ Main House Creation ------
function TpOptMenu()
    Inmenu = true
    VORPMenu.CloseAll()
    local elements = {
        { label = _U("nonTp"), value = 'nontp', desc = _U("nonTp_desc") },
        { label = _U("Tp"), value = 'tp', desc = _U("Tp_desc") },
    }
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
            if data.current.value == 'nontp' then
                CreateHouseMenu(false)
            elseif data.current.value == 'tp' then
                IntChoice()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end


function CreateHouseMenu(tp)
    Inmenu = true
    VORPMenu.CloseAll()
    local elements = {
        { label = _U("setOwner"), value = 'setowner', desc = _U("setOwner_desc") },
        { label = _U("setRadius"), value = 'setradius', desc = _U("setRadius_desc") },
        { label = _U("houseCoords"), value = 'setHouseCoords', desc = _U("houseCoords_desc") },
        { label = _U("setInvLimit"), value = 'setInvLimit', desc = _U("setInvLimit_desc") },
        { label = _U("taxAmount"), value = 'settaxamount', desc = _U("taxAmount_desc") },
    }
    if not tp and tp ~= nil then --nil check is needed
        table.insert(elements, { label = _U("doorCreation"), value = 'doorcreation', desc = _U("doorCreation_desc") })
    end
    table.insert(elements, { label = _U("Confirm"), value = 'confirm', desc = "" }) --placed here to always keep option at the bottom


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
                ['setowner'] = function()
                    PlayerList('CreateHouseMenu', tp)
                end,
                ['setradius'] = function()
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if tonumber(result) > 0 then
                            houseRadius = tonumber(result)
                            VORPcore.NotifyRightTip(_U("radiusSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['doorcreation'] = function()
                    doorCreationMenu()
                end,
                ['setHouseCoords'] = function()
                    houseCoords = GetEntityCoords(PlayerPedId())
                    VORPcore.NotifyRightTip(_U("houseCoordsSet"), 4000)
                end,
                ['setInvLimit'] = function()
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if tonumber(result) > 0 then
                            InvLimit = tonumber(result)
                            VORPcore.NotifyRightTip(_U("invLimitSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['settaxamount'] = function()
                    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
                        if tonumber(result) > 0 then
                            taxAmount = tonumber(result)
                            VORPcore.NotifyRightTip(_U("taxAmountSet"), 4000)
                        else
                            VORPcore.NotifyRightTip(_U("InvalidInput"), 4000)
                        end
                    end)
                end,
                ['confirm'] = function()
                    VORPMenu.CloseAll()
                    local tpHouse = false
                    if tpInt ~= nil then
                        tpHouse = tpInt
                    end
                    TriggerServerEvent('bcc-housing:CreationDBInsert', tpHouse, ownerId, houseRadius, doors, houseCoords, InvLimit, ownerSource, taxAmount)
                    doors, ownerId, houseCoords, houseRadius, ownerSource = nil, nil, nil, nil, nil
                    VORPcore.NotifyRightTip(_U("houseCreated"), 4000)
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

--------- Show the player list credit to vorp admin for this
function doorCreationMenu()
    Inmenu = false
    local doorMenuElements = {}
    VORPMenu.CloseAll()

    if #doorMenuElements == 0 or nil then
        table.insert(doorMenuElements, { label = _U("createDoor"), value = 'doorcreation', desc = "" })
    end
    for k, v in pairs(doors) do
        doorMenuElements[#doorMenuElements + 1] = {
            label = _U("doorId") .. v,
            value = "door" .. k,
            desc = "" .. "<span style=color:MediumSeaGreen;> ",
            info = v
        }
    end

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title      = _U("creationMenuName"),
            subtext    = _U("createdDoorList"),
            align      = 'top-left',
            elements   = doorMenuElements,
            lastmenu   = 'CreateHouseMenu',
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'doorcreation' then
                VORPMenu.CloseAll()
                local door = exports['bcc-doorlocks']:createDoor()
                table.insert(doors, door)
                while true do
                    Wait(10)
                    if #VORPMenu.GetOpenedMenus() <= 0 then
                        doorCreationMenu() break
                    end
                end
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

--------- Show the player list credit to vorp admin for this
function PlayerList(lastmenu, tpHouse)
    VORPMenu.CloseAll()
    Inmenu = false
    local elements = {}
    local players = GetPlayers()

    table.sort(players, function(a, b)
        return a.serverId < b.serverId
    end)

    for k, playersInfo in pairs(players) do
        elements[#elements + 1] = {
            label = playersInfo.PlayerName .. "<br> " .. _U("CharacterStaticId") .. ' ' .. playersInfo.staticid,
            value = "players" .. k,
            desc = _U("StaticId") .. "<span style=color:MediumSeaGreen;> ",
            info = playersInfo
        }
    end

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title      = _U("creationMenuName"),
            subtext    = _U("StaticId_desc"),
            align      = 'top-left',
            elements   = elements,
            lastmenu   = lastmenu,
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                if lastmenu == 'CreateHouseMenu' then
                    ownerId = data.current.info.staticid
                    ownerSource = data.current.info.serverId
                    VORPcore.NotifyRightTip(_U("OwnerSet"), 4000)
                    VORPMenu.CloseAll()
                    CreateHouseMenu(tpHouse)
                elseif lastmenu == 'HousingManagementMenu' then
                    VORPcore.NotifyRightTip(_U("givenAccess"), 4000)
                    TriggerServerEvent('bcc-housing:NewPlayerGivenAccess', data.current.info.staticid, HouseId, data.current.info.serverId)
                end
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

------ Main House Creation ------
function IntChoice()
    Inmenu = true
    VORPMenu.CloseAll()
    local elements = {
        { label = _U("Int1"), value = 'int1', desc = "" },
        { label = _U("Int2"), value = 'int2', desc = "" },
    }
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
            if data.current.value == 'int1' then
                tpInt = 1
                CreateHouseMenu(true)
            elseif data.current.value == 'int2' then
                tpInt = 2
                CreateHouseMenu(true)
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

RegisterNetEvent('bcc-housing:ClientRecHouseLoad', function(recOwnerSource) --Used to load houses after given one or given access so you dont have to relog to gain access
    TriggerServerEvent('bcc-housing:CheckIfHasHouse', recOwnerSource)
end)