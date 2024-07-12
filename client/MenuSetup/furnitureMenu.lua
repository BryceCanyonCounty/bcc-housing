function FurnitureMenu(houseId)
    BCCHousingMenu:Close() -- Ensures any previously opened menu is closed
    local furnitureMainMenu = BCCHousingMenu:RegisterPage("bcc-housing-furniture-menu")

    -- Header for the furniture menu
    furnitureMainMenu:RegisterElement('header', {
        value = _U("creationMenuName"),
        slot = 'header',
        style = {}
    })

    furnitureMainMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Register a back button to return to the previous menu
    furnitureMainMenu:RegisterElement('button', {
        label = _U("buyOwnerFurn"),
        style = {}
    }, function()
        buyFurnitureMenu(houseId)
    end)

    -- Register a back button to return to the previous menu
    furnitureMainMenu:RegisterElement('button', {
        label = _U("sellOwnerFurn"),
        style = {}
    }, function()
        GetOwnedFurniture(houseId)
    end)

    furnitureMainMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Register a back button to return to the previous menu
    furnitureMainMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, true)
    end)

    furnitureMainMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    -- Open the menu with the configured main page
    BCCHousingMenu:Open({
        startupPage = furnitureMainMenu
    })
end

function buyFurnitureMenu(houseId)
    BCCHousingMenu:Close() -- Ensures any previously opened menu is closed
    local buyFurnitureMenu = BCCHousingMenu:RegisterPage("bcc-housing-furniture-menu")

    -- Header for the furniture menu
    buyFurnitureMenu:RegisterElement('header', {
        value = _U("creationMenuName"),
        slot = 'header',
        style = {}
    })

    buyFurnitureMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Define the furniture items with their actions
    local furnitureItems = { {
        label = _U("chairs"),
        desc = _U("chairs_desc"),
        action = 'chairs'
    }, {
        label = _U("benches"),
        desc = _U("benches_desc"),
        action = 'benches'
    }, {
        label = _U("tables"),
        desc = _U("tables_desc"),
        action = 'tables'
    }, {
        label = _U("beds"),
        desc = _U("beds_desc"),
        action = 'beds'
    }, {
        label = _U("lights"),
        desc = _U("lights_desc"),
        action = 'lights'
    }, {
        label = _U("post"),
        desc = _U("post_desc"),
        action = 'post'
    }, {
        label = _U("couch"),
        desc = _U("couch_desc"),
        action = 'couch'
    }, {
        label = _U("seat"),
        desc = _U("seat_desc"),
        action = 'seat'
    }, {
        label = _U("shelf"),
        desc = _U("shelf_desc"),
        action = 'shelf'
    } }

    -- Register elements for each furniture item
    for _, item in ipairs(furnitureItems) do
        buyFurnitureMenu:RegisterElement('button', {
            label = item.label,
            style = {}
        }, function()
            -- Call to open the specific furniture type menu
            IndFurnitureTypeMenu(item.action, houseId)
        end)
    end

    buyFurnitureMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Register a back button to return to the previous menu
    buyFurnitureMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        FurnitureMenu(houseId)
    end)

    buyFurnitureMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    -- Open the menu with the configured main page
    BCCHousingMenu:Open({
        startupPage = buyFurnitureMenu
    })
end

function IndFurnitureTypeMenu(type, houseId)
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
    furnitureTypeMenu:RegisterElement('header', {
        value = _U("creationMenuName") .. " - " .. _U(type),
        slot = 'header',
        style = {}
    })

    furnitureTypeMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for k, v in pairs(furnConfigTable) do
        furnitureTypeMenu:RegisterElement('button', {
            label = v.displayName .. " - $" .. tostring(v.costToBuy),
            style = {}
        }, function()
            PlaceFurnitureIntoWorldMenu(v.propModel, v.costToBuy, v.displayName, v.sellFor)
        end)
    end
    
    furnitureTypeMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    furnitureTypeMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        FurnitureMenu(houseId)
    end)

    furnitureTypeMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = furnitureTypeMenu
    })
end

function PlaceFurnitureIntoWorldMenu(model, cost, displayName, sellPrice)
    menuCheck = true
    local playerPed = PlayerPedId()
    local placementCoords = GetEntityCoords(playerPed)
    local createdObject = CreateObject(model, placementCoords.x, placementCoords.y + 2, placementCoords.z, true, true,
        true)
    SetEntityCollision(createdObject, false, true)
    TriggerEvent('bcc-housing:CheckIfInRadius', createdObject)

    local amountToMove = 0.1 -- default movement precision

    local furniturePlacementMenu = BCCHousingMenu:RegisterPage('furniture_placement_menu')

    furniturePlacementMenu:RegisterElement('header', {
        value = _U("placeFurniture"),
        slot = 'header',
        style = {}
    })

    furniturePlacementMenu:RegisterElement('line', {
        slot = "header",
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
            style = {}
        }, function()
            MoveFurniture(createdObject, direction, amountToMove)
        end)
    end

    furniturePlacementMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Confirm placement
    furniturePlacementMenu:RegisterElement('button', {
        label = _U("Confirm"),
        slot = "footer",
        style = {}
    }, function()
        SetEntityCollision(createdObject, true, true)
        if ConfirmFurniturePlacement(createdObject, model, cost, displayName, sellPrice) then
            FreezeEntityPosition(createdObject, true)
            BCCHousingMenu:Close()
            -- Successful placement handling
            TriggerServerEvent('bcc-housing:SaveFurnitureData', {
                model = model,
                coords = GetEntityCoords(createdObject),
                heading = GetEntityHeading(createdObject)
            })
        else
            DeleteObject(createdObject)
            BCCHousingMenu:Close()
            VORPcore.NotifyRightTip(_U("toFar"), 4000)
        end
    end)

    -- Register a back button
    furniturePlacementMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        DeleteObject(createdObject)
        TriggerEvent('bcc-housing:openmenu')
    end)

    furniturePlacementMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = furniturePlacementMenu
    })
end

function MoveFurniture(obj, direction, moveAmount)
    local coords = GetEntityCoords(obj)
    local rot = GetEntityRotation(obj, 2) -- Get rotation in degrees.

    if direction == "forward" then
        SetEntityCoords(obj, coords.x, coords.y + moveAmount, coords.z)
    elseif direction == "backward" then
        SetEntityCoords(obj, coords.x, coords.y - moveAmount, coords.z)
    elseif direction == "left" then
        SetEntityCoords(obj, coords.x - moveAmount, coords.y, coords.z)
    elseif direction == "right" then
        SetEntityCoords(obj, coords.x + moveAmount, coords.y, coords.z)
    elseif direction == "up" then
        SetEntityCoords(obj, coords.x, coords.y, coords.z + moveAmount)
    elseif direction == "down" then
        SetEntityCoords(obj, coords.x, coords.y, coords.z - moveAmount)
    elseif direction == "rotatepitch" then
        SetEntityRotation(obj, rot.x + moveAmount, rot.y, rot.z, 2, true)
    elseif direction == "rotatebackward" then
        SetEntityRotation(obj, rot.x - moveAmount, rot.y, rot.z, 2, true)
    elseif direction == "rotateright" then
        SetEntityRotation(obj, rot.x, rot.y + moveAmount, rot.z, 2, true)
    elseif direction == "rotateleft" then
        SetEntityRotation(obj, rot.x, rot.y - moveAmount, rot.z, 2, true)
    elseif direction == "rotateYaw" then
        SetEntityRotation(obj, rot.x, rot.y, rot.z + moveAmount, 2, true)
    elseif direction == "rotateYawLeft" then
        SetEntityRotation(obj, rot.x, rot.y, rot.z - moveAmount, 2, true)
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

function closeToHouse(object) -- make sure the obj is close to house before placing
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
    if GetDistanceBetweenCoords(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z), tonumber(compCoords.x),
            tonumber(compCoords.y), tonumber(compCoords.z), false) <= radius then
        return true
    else
        return false
    end
end

RegisterNetEvent('bcc-housing:ClientFurnBought', function(furnitureCreatedTable, entId)
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

-- Function to trigger server event
function GetOwnedFurniture(houseId)
    print("Requesting furniture for house ID:", houseId) -- Debug print
    TriggerServerEvent('bcc-housing:GetOwnerFurniture', houseId)
end

-- Helper function to handle the sale of furniture (implement as needed)
function SellFurniture(furniture)
    print("Selling furniture:", furniture.model)
    -- You can add server event here to handle the backend sale process
    TriggerServerEvent('bcc-housing:SellFurniture', furniture)
end

function SellOwnedFurnitureMenu(houseId,furnTable)
    devPrint("Opening SellOwnedFurnitureMenu with houseId: " .. tostring(houseId))

    -- Close any previously opened menus
    BCCHousingMenu:Close()

    -- Initialize the sell furniture menu page
    local sellFurnMenu = BCCHousingMenu:RegisterPage("bcc-housing-sell-furniture-menu")

    -- Add a header for clarity
    sellFurnMenu:RegisterElement('header', {
        value = _U("sellOwnerFurn"),
        slot = 'header',
        style = {}
    })

    -- Check if the furniture table is not nil and has items
    if furnTable and #furnTable > 0 then
        for k, v in pairs(furnTable) do
            sellFurnMenu:RegisterElement('button', {
                label = v.displayName .. " - " .. _U("sellFor") .. tostring(v.sellprice),
                style = {}
            }, function()
                -- Logic to handle selling furniture
                local sold = false
                for idx, entity in ipairs(CreatedFurniture) do
                    local storedFurnCoord = GetEntityCoords(entity)
                    local dist = Vdist(storedFurnCoord.x, storedFurnCoord.y, storedFurnCoord.z, v.coords.x, v.coords.y, v.coords.z)
                    if dist < 1.0 then -- Check if the distance is less than 1 meter
                        DeleteEntity(entity)
                        table.remove(CreatedFurniture, idx)
                        TriggerServerEvent('bcc-housing:FurnSoldRemoveFromTable', v, houseId, furnTable, k)
                        VORPcore.NotifyRightTip(_U("furnSold"), 4000)
                        sold = true
                        break
                    end
                end
                if not sold then
                    VORPcore.NotifyRightTip(_U("furnNotSold"), 4000) -- Notify if the furniture was not found or could not be sold
                end
            end)
        end
    else
        sellFurnMenu:RegisterElement('textdisplay', {
            value = "No furniture Available",
            slot = 'content',
            style = {}
        })
    end

    sellFurnMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Add a back button to return to the main furniture menu
    sellFurnMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {}
    }, function()
        FurnitureMenu(houseId)
    end)

    sellFurnMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    sellFurnMenu:RegisterElement('textdisplay', {
        value = _U("sellOwnerFurn_desc"),
        slot = "footer",
        style = {}
    })

    -- Open the menu with the configured page
    BCCHousingMenu:Open({
        startupPage = sellFurnMenu
    })
end

RegisterNetEvent('bcc-housing:ClientCloseAllMenus', function()
    BCCHousingMenu:Close()
end)

function GetOwnedFurniture(houseId)
    devPrint("Requesting furniture for house ID: " .. tostring(houseId))
    TriggerServerEvent('bcc-housing:GetOwnerFurniture', houseId)
end

RegisterNetEvent('bcc-housing:SellOwnedFurnMenu')
AddEventHandler('bcc-housing:SellOwnedFurnMenu', function(houseId, furnTable)
    devPrint("Opening Sell Owned Furniture Menu for House ID: " .. tostring(houseId))
    if type(furnTable) == "table" then
        SellOwnedFurnitureMenu(houseId, furnTable)
    else
        devPrint("Error: furnTable is not a table")
    end
end)
