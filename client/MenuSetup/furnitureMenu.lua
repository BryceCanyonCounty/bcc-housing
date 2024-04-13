function FurnitureMenu()
    Inmenu = false
    VORPMenu.CloseAll()
    local elements = {
        { label = _U("chairs"), value = 'chairs', desc = _U("chairs_desc") },
        { label = _U("benches"), value = 'benches', desc = _U("benches_desc") },
        { label = _U("tables"), value = 'tables', desc = _U("tables_desc") },
        { label = _U("beds"), value = 'beds', desc = _U("beds_desc") },
        { label = _U("lights"), value = 'lights', desc = _U("lights_desc") },
        { label = _U("post"), value = 'post', desc = _U("post_desc") },
        { label = _U("couch"), value = 'couch', desc = _U("couch_desc") },
        { label = _U("seat"), value = 'seat', desc = _U("seat_desc") },
        { label = _U("shelf"), value = 'shelf', desc = _U("shelf_desc") },
        { label = _U("sellOwnerFurn"), value = 'sellownerfurn', desc = _U("sellOwnerFurn_desc") }
    }

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title = _U("creationMenuName"),
            align = 'top-left',
            elements = elements,
            lastmenu   = 'HousingManagementMenu'
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local selectedOption = {
                ['chairs'] = function()
                    IndFurnitureTypeMenu('chairs')
                end,
                ['benches'] = function()
                    IndFurnitureTypeMenu('benches')
                end,
                ['tables'] = function()
                    IndFurnitureTypeMenu('tables')
                end,
                ['beds'] = function()
                    IndFurnitureTypeMenu('beds')
                end,
                ['lights'] = function()
                    IndFurnitureTypeMenu('lights')
                end,
                ['post'] = function()
                    IndFurnitureTypeMenu('post')
                end,
                ['couch'] = function()
                    IndFurnitureTypeMenu('couch')
                end,
                ['seat'] = function()
                    IndFurnitureTypeMenu('seat')
                end,
                ['shelf'] = function()
                    IndFurnitureTypeMenu('shelf')
                end,
                ['sellownerfurn'] = function()
                    TriggerServerEvent('bcc-housing:GetOwnerFurniture', HouseId)
                    VORPMenu.CloseAll()
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

local menuCheck = false
function IndFurnitureTypeMenu(type)
    local elements, furnConfigTable = {}, nil
    menuCheck = false
    VORPMenu.CloseAll()
    local selectedFurnType = {
        ['chairs'] = function()
            furnConfigTable = Config.Furniture.Chairs
        end,
        ['benches'] = function()
            furnConfigTable = Config.Furniture.Benches
        end,
        ['tables'] = function()
            furnConfigTable = Config.Furniture.Tables
        end,
        ['beds'] = function()
            furnConfigTable = Config.Furniture.Beds
        end,
        ['lights'] = function()
            furnConfigTable = Config.Furniture.Lights
        end,
        ['post'] = function()
            furnConfigTable = Config.Furniture.Post
        end,
        ['couch'] = function()
            furnConfigTable = Config.Furniture.Couch
        end,
        ['seat'] = function()
            furnConfigTable = Config.Furniture.Seat
        end,
        ['shelf'] = function()
            furnConfigTable = Config.Furniture.Shelf
        end
    }

    if selectedFurnType[type] then
        selectedFurnType[type]()
    end

    for k, v in pairs(furnConfigTable) do
        elements[#elements + 1] = {
            label = v.displayName,
            value = "furnItem" .. k,
            desc = _U("cost") .. tostring(v.costToBuy),
            info = v
        }
    end

    VORPMenu.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("creationMenuName"),
            subtext    = _U("StaticId_desc"),
            align      = 'top-left',
            elements   = elements,
            lastmenu   = 'FurnitureMenu',
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                if not menuCheck then
                    PlaceFurnitureIntoWorldMenu(data.current.info.propModel, data.current.info.costToBuy, data.current.info.displayName, data.current.info.sellFor)
                end
            end
        end,
        function(data, menu)
            menu.close()
            FurnitureMenu()
        end)
end

local furnObj = nil
function PlaceFurnitureIntoWorldMenu(model, cost, displayName, sellPrice)
    menuCheck = true
    local plc, amountToMove = GetEntityCoords(PlayerPedId()), 0
    local createdObject = CreateObject(model, plc.x, plc.y + 2, plc.z, true, true)
    SetEntityCollision(createdObject, false, true)
    TriggerEvent('bcc-housing:CheckIfInRadius', createdObject)

    VORPMenu.CloseAll()
    local elements = {
        { label = _U("amountToMove"), value = 0, desc = _U("amountToMove_desc"), type = 'slider', min = 0, max = 5, hop = 0.1 }, --Thanks to jannings for this line of code
        { label = _U("forward"), value = 'forward', desc = _U("forward_desc") },
        { label = _U("backward"), value = 'backward', desc = _U("backward_desc") },
        { label = _U("left"), value = 'left', desc = _U("left_desc") },
        { label = _U("right"), value = 'right', desc = _U("right_desc") },
        { label = _U("up"), value = 'up', desc = _U("up_desc") },
        { label = _U("down"), value = 'down', desc = _U("down_desc") },
        { label = _U("rotatepitch"), value = 'rotatepitch', desc = _U("rotatepitch_desc") },
        { label = _U("rotatebackward"), value = 'rotatebackward', desc = _U("rotatebackward_desc") },
        { label = _U("rotateright"), value = 'rotateright', desc = _U("rotateright_desc") },
        { label = _U("rotateleft"), value = 'rotateleft', desc = _U("rotateleft_desc") },
        { label = _U("rotateYaw"), value = 'rotateyaw', desc = _U("rotateYaw_desc") },
        { label = _U("rotateYawLeft"), value = 'rotateyawleft', desc = _U("rotateYawLeft_desc") },
        { label = _U("Confirm"), value = 'confirm', desc = "" }
    }

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title      = _U("creationMenuName"),
            subtext    = _U("StaticId_desc"),
            align      = 'top-left',
            elements   = elements,
            lastmenu   = 'FurnitureMenu',
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current == 'backup' then
                DeleteObject(createdObject)
                _G[data.trigger]()
            end
            local selectedOption = {
                ['forward'] = function()
                    local co = GetEntityCoords(createdObject)
                    SetEntityCoords(createdObject, co.x, co.y + amountToMove, co.z)
                end,
                ['backward'] = function()
                    local co = GetEntityCoords(createdObject)
                    SetEntityCoords(createdObject, co.x, co.y - amountToMove, co.z)
                end,
                ['left'] = function()
                    local co = GetEntityCoords(createdObject)
                    SetEntityCoords(createdObject, co.x - amountToMove, co.y, co.z)
                end,
                ['right'] = function()
                    local co = GetEntityCoords(createdObject)
                    SetEntityCoords(createdObject, co.x + amountToMove, co.y, co.z)
                end,
                ['up'] = function()
                    local co = GetEntityCoords(createdObject)
                    SetEntityCoords(createdObject, co.x, co.y, co.z + amountToMove)
                end,
                ['down'] = function()
                    local co = GetEntityCoords(createdObject)
                    SetEntityCoords(createdObject, co.x, co.y, co.z - amountToMove)
                end,
                ['rotatepitch'] = function()
                    local cr = GetEntityRotation(createdObject)
                    local pitch, roll, yaw = table.unpack(cr)
                    SetEntityRotation(createdObject, pitch + amountToMove, roll, yaw)
                end,
                ['rotatebackward'] = function()
                    local cr = GetEntityRotation(createdObject)
                    local pitch, roll, yaw = table.unpack(cr)
                    SetEntityRotation(createdObject, pitch - amountToMove, roll, yaw)
                end,
                ['rotateright'] = function()
                    local cr = GetEntityRotation(createdObject)
                    local pitch, roll, yaw = table.unpack(cr)
                    SetEntityRotation(createdObject, pitch, roll + amountToMove, yaw)
                end,
                ['rotateleft'] = function()
                    local cr = GetEntityRotation(createdObject)
                    local pitch, roll, yaw = table.unpack(cr)
                    SetEntityRotation(createdObject, pitch, roll - amountToMove, yaw)
                end,
                ['rotateyaw'] = function()
                    local cr = GetEntityRotation(createdObject)
                    local pitch, roll, yaw = table.unpack(cr)
                    SetEntityRotation(createdObject, pitch, roll, yaw + amountToMove)
                end,
                ['rotateyawleft'] = function()
                    local cr = GetEntityRotation(createdObject)
                    local pitch, roll, yaw = table.unpack(cr)
                    SetEntityRotation(createdObject, pitch, roll, yaw - amountToMove)
                end,
                ['confirm'] = function()
                    local close = closeToHosue(createdObject)
                    if close then
                        SetEntityCollision(createdObject, true, true)
                        FreezeEntityPosition(createdObject)
                        local co = GetEntityCoords(createdObject)
                        local coords = { x = co.x, y = co.y, z = co.z, h = GetEntityHeading(createdObject) }
                        local cr = GetEntityRotation(createdObject)
                        local furnitureCreatedTable = { model = model, coords = coords, rotation = cr, displayName = displayName, sellprice = sellPrice }
                        local entId = NetworkGetNetworkIdFromEntity(createdObject)
                        furnObj = createdObject
                        TriggerServerEvent('bcc-housing:BuyFurn', cost, entId, furnitureCreatedTable)
                    else
                        VORPcore.NotifyRightTip(_U("toFar"), 4000)
                        DeleteObject(createdObject)
                    end
                    menuCheck = false
                    VORPMenu.CloseAll()
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            else
                amountToMove = data.current.value
            end
        end,
        function(data, menu)
            menu.close()
            FurnitureMenu()
        end)
end

function closeToHosue(object) --make sure the obj is close to house before placing
    local coords = GetEntityCoords(object)
    local compCoords = HouseCoords
    local radius = tonumber(HouseRadius)
    if CurrentTpHouse ~= nil and InTpHouse then
        if CurrentTpHouse == 1 then
            compCoords = Config.TpInteriors.Interior1.exitCoords
            radius = Config.TpInteriors.Interior1.furnRadius
        elseif CurrentTpHouse == 2 then
            compCoords = Config.TpInteriors.Interior2.exitCoords
            radius = Config.TpInteriors.Interior2.furnRadius
        end
    end
    if GetDistanceBetweenCoords(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z), tonumber(compCoords.x), tonumber(compCoords.y), tonumber(compCoords.z), false) <= radius then
        return true
    else
        return false
    end
end

RegisterNetEvent('bcc-housing:ClientFurnBought', function(furnitureCreatedTable, entId) --event to store the furn after it has been paid for
    TriggerServerEvent('bcc-housing:InsertFurnitureIntoDB', furnitureCreatedTable, HouseId)
    TriggerServerEvent('bcc-housing:StoreFurnForDeletion', entId, HouseId)
    table.insert(CreatedFurniture, furnObj)
    furnObj = nil
    VORPcore.NotifyRightTip(_U("furnPlaced"), 4000)
end)

RegisterNetEvent('bcc-housing:ClientFurnBoughtFail', function()
    DeleteObject(furnObj)
    furnObj = nil
end)

RegisterNetEvent('bcc-housing:SellOwnedFurnMenu', function(furnTable)
    VORPMenu.CloseAll()
    local elements = {}

    for k, v in pairs(furnTable) do
        elements[#elements + 1] = {
            label = v.displayName,
            value = "sellfurn" .. k,
            desc = _U("sellFor") .. tostring(v.sellprice),
            info = v,
            info2 = k
        }
    end

    VORPMenu.Open('default', GetCurrentResourceName(), 'vorp_menu',
        {
            title      = _U("sellOwnerFurn"),
            subtext    = "",
            align      = 'top-left',
            elements   = elements,
            lastmenu   = 'FurnitureMenu',
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                for k, v in pairs(CreatedFurniture) do
                    local storedFurnCoord = GetEntityCoords(v)
                    local firstVec = vector3(tonumber(storedFurnCoord.x), tonumber(storedFurnCoord.y), tonumber(storedFurnCoord.z))
                    local secondVec = vector3(tonumber(data.current.info.coords.x), tonumber(data.current.info.coords.y), tonumber(data.current.info.coords.z))
                    local dist = #(firstVec - secondVec)
                    if dist < 0.5 then --used as a way to check if the loop is on the correct piece of furniture
                      table.remove(CreatedFurniture, k)
                      DeleteEntity(v)
                    end
                end
                TriggerServerEvent('bcc-housing:FurnSoldRemoveFromTable', data.current.info, HouseId, furnTable, data.current.info2)
            end
        end,
        function(data, menu)
            menu.close()
            FurnitureMenu()
        end)
end)

RegisterNetEvent('bcc-housing:ClientCloseAllMenus', function()
    VORPMenu.CloseAll()
end)