function FurnitureMenu()
    BCCHousingMenu:Close() -- Ensures any previously opened menu is closed
    local furnitureMainMenu = BCCHousingMenu:RegisterPage("bcc-housing-furniture-menu")

    -- Header for the furniture menu
    furnitureMainMenu:RegisterElement('header', {
        value = _U("creationMenuName"),
        slot = 'header',
        style = {}
    })

    -- Define the furniture items with their actions
    local furnitureItems = {
        { label = _U("chairs"),        desc = _U("chairs_desc"),        action = 'Chairs' },
        { label = _U("benches"),       desc = _U("benches_desc"),       action = 'Benches' },
        { label = _U("tables"),        desc = _U("tables_desc"),        action = 'Tables' },
        { label = _U("beds"),          desc = _U("beds_desc"),          action = 'Beds' },
        { label = _U("lights"),        desc = _U("lights_desc"),        action = 'Lights' },
        { label = _U("post"),          desc = _U("post_desc"),          action = 'Post' },
        { label = _U("couch"),         desc = _U("couch_desc"),         action = 'Couch' },
        { label = _U("seat"),          desc = _U("seat_desc"),          action = 'Seat' },
        { label = _U("shelf"),         desc = _U("shelf_desc"),         action = 'Shelf' },
        { label = _U("sellOwnerFurn"), desc = _U("sellOwnerFurn_desc"), action = 'Sellownerfurn' }
    }

    -- Register elements for each furniture item
    for _, item in ipairs(furnitureItems) do
        furnitureMainMenu:RegisterElement('button', {
            label = item.label,
            style = {},
        }, function()
            -- Call to open the specific furniture type menu
            IndFurnitureTypeMenu(item.action)
        end)
    end

    -- Register a back button to return to the previous menu
    furnitureMainMenu:RegisterElement('button', {
        label = "Back",
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu')
    end)

    -- Open the menu with the configured main page
    BCCHousingMenu:Open({
        startupPage = furnitureMainMenu
    })
end

function IndFurnitureTypeMenu(type)
    BCCHousingMenu:Close() -- Close any existing Feather menus
    local furnConfigTable = Config.Furniture[type]

    if not furnConfigTable then
        print("Error: Invalid furniture type '" .. type .. "'. Available types are:")
        for key in pairs(Config.Furniture) do
            print(" - " .. key)
        end
        return -- Exit the function if the type is invalid
    end

    local furnitureTypeMenu = BCCHousingMenu:RegisterPage("bcc-housing-furniture-type-menu")

    -- Add a header to show which type of furniture is being selected
    furnitureTypeMenu:RegisterElement('header', {
        value = _U("creationMenuName") .. " - " .. _U(type),
        slot = 'header',
        style = {}
    })

    -- Register elements for each furniture item available in the chosen category
    for k, v in pairs(furnConfigTable) do
        furnitureTypeMenu:RegisterElement('button', {
            label = v.displayName .. " - " .. _U("cost") .. tostring(v.costToBuy),
            style = {},
        }, function()
            -- Call a function to handle placing the furniture into the world
            PlaceFurnitureIntoWorldMenu(v.propModel, v.costToBuy, v.displayName, v.sellFor)
        end)
    end

    -- Register a back button on the menu that routes back to the main furniture menu
    furnitureTypeMenu:RegisterElement('button', {
        label = "Back",
        style = {}
    }, function()
        FurnitureMenu() -- Assumes FurnitureMenu is the function to return to the main furniture menu
    end)

    -- Open the furniture type menu with the configured page
    BCCHousingMenu:Open({
        startupPage = furnitureTypeMenu
    })
end

function PlaceFurnitureIntoWorldMenu(model, cost, displayName, sellPrice)
    menuCheck = true
    local plc = GetEntityCoords(PlayerPedId())
    local createdObject = CreateObject(model, plc.x, plc.y + 2, plc.z, true, true)
    SetEntityCollision(createdObject, false, true)
    TriggerEvent('bcc-housing:CheckIfInRadius', createdObject)

    local furniturePlacementMenu = BCCHousingMenu:RegisterPage('furniture_placement_menu')
    local amountToMove = 0

    furniturePlacementMenu:RegisterElement('header', {
        value = _U("PlaceFurnitureTitle"),
        slot = 'header',
        style = {}
    })

    -- Slider for adjustment precision
    furniturePlacementMenu:RegisterElement('slider', {
        label = _U("amountToMove"),
        min = 0,
        max = 5,
        step = 0.1,
        value = amountToMove
    }, function(data)
        amountToMove = data.value
    end)

    -- Movement controls
    local directions = { 'forward', 'backward', 'left', 'right', 'up', 'down', 'rotatepitch', 'rotatebackward',
        'rotateright', 'rotateleft', 'rotateYaw', 'rotateYawLeft' }
    for _, direction in ipairs(directions) do
        furniturePlacementMenu:RegisterElement('button', {
            label = _U(direction),
            style = {},
        }, function()
            MoveFurniture(createdObject, direction, amountToMove)
        end)
    end

    -- Confirm placement
    furniturePlacementMenu:RegisterElement('button', {
        label = _U("Confirm"),
        style = {},
    }, function()
        if ConfirmFurniturePlacement(createdObject, model, cost, displayName, sellPrice) then
            BCCHousingMenu:Close()
            furnitureObj = createdObject
        else
            DeleteObject(createdObject)
            BCCHousingMenu:Close()
            VORPcore.NotifyRightTip(_U("toFar"), 4000)
        end
    end)

    -- Register a back button
    furniturePlacementMenu:RegisterElement('button', {
        label = _U("BackButton"),
        style = {}
    }, function()
        DeleteObject(createdObject)
        BCCHousingMenu:Close()
    end)

    BCCHousingMenu:Open({
        startupPage = furniturePlacementMenu
    })
end

function MoveFurniture(obj, direction, moveAmount)
    local coords = GetEntityCoords(obj)
    if direction == 'forward' then
        SetEntityCoords(obj, coords.x, coords.y + moveAmount, coords.z)
    elseif direction == 'backward' then
        SetEntityCoords(obj, coords.x, coords.y - moveAmount, coords.z)
        -- Add other direction handling here
    end
end

function ConfirmFurniturePlacement(obj, model, cost, displayName, sellPrice)
    local closeToHouse = closeToHouse(obj) -- Assuming closeToHouse is a function you have
    if closeToHouse then
        SetEntityCollision(obj, true, true)
        FreezeEntityPosition(obj, true)
        TriggerServerEvent('bcc-housing:BuyFurn', cost, NetworkGetNetworkIdFromEntity(obj), {
            model = model,
            coords = GetEntityCoords(obj),
            rotation = GetEntityRotation(obj),
            displayName = displayName,
            sellprice = sellPrice
        })
        return true
    end
    return false
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

RegisterNetEvent('bcc-housing:ClientFurnBought',
    function(furnitureCreatedTable, entId)                                              --event to store the furn after it has been paid for
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
    BCCHousingMenu:Close() -- Close any existing Feather menus
    local sellFurnMenu = BCCHousingMenu:RegisterPage("bcc-housing-sell-furniture-menu")

    -- Add a header to the menu for clarity
    sellFurnMenu:RegisterElement('header', {
        value = _U("sellOwnerFurn"),
        slot = 'header',
        style = {}
    })

    -- Register a button for each furniture item in the provided table
    for k, v in pairs(furnTable) do
        sellFurnMenu:RegisterElement('button', {
            label = v.displayName .. " - " .. _U("sellFor") .. tostring(v.sellprice),
            style = {},
        }, function()
            -- Logic to handle selling furniture
            for idx, entity in pairs(CreatedFurniture) do
                local storedFurnCoord = GetEntityCoords(entity)
                local firstVec = vector3(storedFurnCoord.x, storedFurnCoord.y, storedFurnCoord.z)
                local secondVec = vector3(v.coords.x, v.coords.y, v.coords.z)
                if #(firstVec - secondVec) < 0.5 then
                    table.remove(CreatedFurniture, idx)
                    DeleteEntity(entity)
                    break
                end
            end
            TriggerServerEvent('bcc-housing:FurnSoldRemoveFromTable', v, HouseId, furnTable, k)
        end)
    end

    -- Register a back button on the menu that routes back to the main furniture menu
    sellFurnMenu:RegisterElement('button', {
        label = "Back",
        style = {}
    }, function()
        FurnitureMenu() -- Assumes FurnitureMenu is the function to return to the main furniture menu
    end)

    -- Open the furniture selling menu with the configured page
    BCCHousingMenu:Open({
        startupPage = sellFurnMenu
    })
end)

RegisterNetEvent('bcc-housing:ClientCloseAllMenus', function()
    MenuData.CloseAll()
end)
