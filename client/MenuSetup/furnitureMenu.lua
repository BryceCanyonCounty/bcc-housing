function FurnitureMenu()
    Inmenu = false
    MenuData.CloseAll()
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

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("creationMenuName"),
            align = 'top-left',
            elements = elements,
            lastmenu   = 'HousingManagementMenu'
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'chairs' then
                IndFurnitureTypeMenu('chairs')
            elseif data.current.value == 'benches' then
                IndFurnitureTypeMenu('benches')
            elseif data.current.value == 'tables' then
                IndFurnitureTypeMenu('tables')
            elseif data.current.value == 'beds' then
                IndFurnitureTypeMenu('beds')
            elseif data.current.value == 'lights' then
                IndFurnitureTypeMenu('lights')
            elseif data.current.value == 'post' then
                IndFurnitureTypeMenu('post')
            elseif data.current.value == 'couch' then
                IndFurnitureTypeMenu('couch')
            elseif data.current.value == 'seat' then
                IndFurnitureTypeMenu('seat')
            elseif data.current.value == 'shelf' then
                IndFurnitureTypeMenu('shelf')
            elseif data.current.value == 'sellownerfurn' then
                TriggerServerEvent('bcc-housing:GetOwnerFurniture', HouseId)
                MenuData.CloseAll()
            end
        end)
end

function IndFurnitureTypeMenu(type)
    local elements, furnConfigTable = {}, nil
    MenuData.CloseAll()
    if type == 'chairs' then
        furnConfigTable = Config.Furniture.Chairs
    elseif type == 'benches' then
        furnConfigTable = Config.Furniture.Benches
    elseif type == 'tables' then
        furnConfigTable = Config.Furniture.Tables
    elseif type == 'beds' then
        furnConfigTable = Config.Furniture.Beds
    elseif type == 'lights' then
        furnConfigTable = Config.Furniture.Lights
    elseif type == 'post' then
        furnConfigTable = Config.Furniture.Post
    elseif type == 'couch' then
        furnConfigTable = Config.Furniture.Couch
    elseif type == 'seat' then
        furnConfigTable = Config.Furniture.Seat
    elseif type == 'shelf' then
        furnConfigTable = Config.Furniture.Shelf
    end
    for k, v in pairs(furnConfigTable) do
        elements[#elements + 1] = {
            label = v.displayName,
            value = "furnItem" .. k,
            desc = _U("cost") .. tostring(v.costToBuy),
            info = v
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("creationMenuName"),
            subtext    = _U("StaticId_desc"),
            align      = 'top-left',
            elements   = elements,
            lastmenu   = 'FurnitureMenu',
            itemHeight = "4vh",
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                PlaceFurnitureIntoWorldMenu(data.current.info.propModel, data.current.info.costToBuy, data.current.info.displayName, data.current.info.sellFor)
            end
        end)
end

local furnObj = nil
function PlaceFurnitureIntoWorldMenu(model, cost, displayName, sellPrice)
    local plc, amountToMove = GetEntityCoords(PlayerPedId()), 0
    local createdObject = CreateObject(model, plc.x, plc.y + 2, plc.z, true, true)
    SetEntityCollision(createdObject, false, true)
    TriggerEvent('bcc-housing:CheckIfInRadius', createdObject)

    MenuData.CloseAll()
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

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("creationMenuName"),
            subtext    = _U("StaticId_desc"),
            align      = 'top-left',
            elements   = elements,
            lastmenu   = 'FurnitureMenu',
            itemHeight = "4vh",
        },
        function(data)
            if data.current == 'backup' then
                DeleteObject(createdObject)
                _G[data.trigger]()
            end
            if data.current.value == 'forward' then
                local co = GetEntityCoords(createdObject)
                SetEntityCoords(createdObject, co.x, co.y + amountToMove, co.z)
            elseif data.current.value == 'backward' then
                local co = GetEntityCoords(createdObject)
                SetEntityCoords(createdObject, co.x, co.y - amountToMove, co.z)
            elseif data.current.value == 'left' then
                local co = GetEntityCoords(createdObject)
                SetEntityCoords(createdObject, co.x - amountToMove, co.y, co.z)
            elseif data.current.value == 'right' then
                local co = GetEntityCoords(createdObject)
                SetEntityCoords(createdObject, co.x + amountToMove, co.y, co.z)
            elseif data.current.value == 'up' then
                local co = GetEntityCoords(createdObject)
                SetEntityCoords(createdObject, co.x, co.y, co.z + amountToMove)
            elseif data.current.value == 'down' then
                local co = GetEntityCoords(createdObject)
                SetEntityCoords(createdObject, co.x, co.y, co.z - amountToMove)
            elseif data.current.value == 'rotatepitch' then
                local cr = GetEntityRotation(createdObject)
                local pitch, roll, yaw = table.unpack(cr)
                SetEntityRotation(createdObject, pitch + amountToMove, roll, yaw)
            elseif data.current.value == 'rotatebackward' then
                local cr = GetEntityRotation(createdObject)
                local pitch, roll, yaw = table.unpack(cr)
                SetEntityRotation(createdObject, pitch - amountToMove, roll, yaw)
            elseif data.current.value == 'rotateright' then
                local cr = GetEntityRotation(createdObject)
                local pitch, roll, yaw = table.unpack(cr)
                SetEntityRotation(createdObject, pitch, roll + amountToMove, yaw)
            elseif data.current.value == 'rotateleft' then
                local cr = GetEntityRotation(createdObject)
                local pitch, roll, yaw = table.unpack(cr)
                SetEntityRotation(createdObject, pitch, roll - amountToMove, yaw)
            elseif data.current.value == 'rotateyaw' then
                local cr = GetEntityRotation(createdObject)
                local pitch, roll, yaw = table.unpack(cr)
                SetEntityRotation(createdObject, pitch, roll, yaw + amountToMove)
            elseif data.current.value == 'rotateyawleft' then
                local cr = GetEntityRotation(createdObject)
                local pitch, roll, yaw = table.unpack(cr)
                SetEntityRotation(createdObject, pitch, roll, yaw - amountToMove)
            elseif data.current.value == 'confirm' then
                local close = closeToHosue(createdObject)
                if close then
                    local co = GetEntityCoords(createdObject)
                    local cr = GetEntityRotation(createdObject)
                    FreezeEntityPosition(createdObject)
                    local furnitureCreatedTable = { model = model, coords = co, rotation = cr, displayName = displayName, sellprice = sellPrice }
                    SetEntityCollision(createdObject, true, true)
                    local entId = NetworkGetNetworkIdFromEntity(createdObject)
                    furnObj = createdObject
                    TriggerServerEvent('bcc-housing:BuyFurn', cost, entId, furnitureCreatedTable)
                else
                    VORPcore.NotifyRightTip(_U("toFar"), 4000)
                end
                MenuData.CloseAll()
            else
                amountToMove = data.current.value
            end
        end)

end

function closeToHosue(object) --make sure the obj is close to house before placing
    local coords = GetEntityCoords(object)
    if GetDistanceBetweenCoords(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z), tonumber(HouseCoords.x), tonumber(HouseCoords.y), tonumber(HouseCoords.z), false) <= tonumber(HouseRadius) then
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
    MenuData.CloseAll()
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

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("sellOwnerFurn"),
            subtext    = "",
            align      = 'top-left',
            elements   = elements,
            lastmenu   = 'FurnitureMenu',
            itemHeight = "4vh",
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                TriggerServerEvent('bcc-housing:FurnSoldRemoveFromTable', data.current.info, HouseId, furnTable, data.current.info2)
            end
        end)
end)

RegisterNetEvent('bcc-housing:ClientCloseAllMenus', function()
    MenuData.CloseAll()
end)
