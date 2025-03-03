local MoveForwardPrompt, MoveBackwardPrompt, MoveLeftPrompt, MoveRightPrompt, MoveUpPrompt, MoveDownPrompt
local RotateYawPrompt, RotateYawLeftPrompt, RotatePitchPrompt, RotateBackwardPrompt, RotateRightPrompt, RotateLeftPrompt
local IncreasePrecisionPrompt, DecreasePrecisionPrompt, ConfirmPrompt, CancelPrompt
local FurnitureGroup = GetRandomIntInRange(0, 0xffffff)

function FurnitureMenu(houseId, ownershipStatus)
    BCCHousingMenu:Close() -- Close any previously opened menus

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

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

    furnitureMainMenu:RegisterElement('button', {
        label = _U("buyOwnerFurn"),
        style = {}
    }, function()
        buyFurnitureMenu(houseId, ownershipStatus)
    end)

    furnitureMainMenu:RegisterElement('button', {
        label = _U("sellOwnerFurn"),
        style = {}
    }, function()
        -- Trigger server event to fetch furniture data for the house
        TriggerServerEvent('bcc-housing:GetOwnerFurniture', houseId)
    end)

    furnitureMainMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Register a back button to return to the previous menu
    furnitureMainMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        TriggerEvent('bcc-housing:openmenu', houseId, true, ownershipStatus)
    end)

    furnitureMainMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    -- Open the menu with the configured main page
    BCCHousingMenu:Open({
        startupPage = furnitureMainMenu,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        }
    })
end

function buyFurnitureMenu(houseId, ownershipStatus)
    BCCHousingMenu:Close() -- Close any previously opened menus

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

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
    -- Register elements for each furniture item
    for index, category in pairs(Furniture) do
        --category.desc
        buyFurnitureMenu:RegisterElement('button', {
            label = category.name,
            style = {}
        }, function()
            -- Call to open the specific furniture type menu
            IndFurnitureTypeMenu(index, houseId, ownershipStatus)
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
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        FurnitureMenu(houseId, ownershipStatus)
    end)

    buyFurnitureMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    -- Open the menu with the configured main page
    BCCHousingMenu:Open({
        startupPage = buyFurnitureMenu,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        }
    })
end

function IndFurnitureTypeMenu(type, houseId, ownershipStatus)
    BCCHousingMenu:Close() -- Close any previously opened menus

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

    local furnConfigTable = Furniture[type]
    if not furnConfigTable then
        devPrint("Error: Invalid furniture type '" .. type .. "'. Available types are:")
        for key in pairs(Furniture) do
            devPrint(" - " .. key)
        end
        return -- Exit the function if the type is invalid
    end

    local furnitureTypeMenu = BCCHousingMenu:RegisterPage("bcc-housing-furniture-type-menu")
    furnitureTypeMenu:RegisterElement('header', {
        value = Furniture[type].titile,
        slot = 'header',
        style = {}
    })

    furnitureTypeMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for k, v in ipairs(furnConfigTable) do
        furnitureTypeMenu:RegisterElement('button', {
            label = v.displayName .. " - $" .. tostring(v.costToBuy),
            style = {}
        }, function()
            PlaceFurnitureIntoWorldPrompt(v.propModel, v.costToBuy, v.displayName, v.sellFor)
            BCCHousingMenu:Close()
        end)
    end

    furnitureTypeMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    furnitureTypeMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = "footer",
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        FurnitureMenu(houseId, ownershipStatus)
    end)

    furnitureTypeMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = furnitureTypeMenu,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        }
    })
end

function StartFurniturePlacementPrompts()
    -- Debug: Check if BccUtils is loaded
    if BccUtils then
        devPrint("BccUtils initialized successfully")
    else
        devPrint("Error: BccUtils not initialized")
    end
    if BccUtils and BccUtils.Keys then
        devPrint("Keys table exists")
    else
        devPrint("Error: Keys table not found in BccUtils")
    end

    if BccUtils and BccUtils.Keys and BccUtils.Keys['R'] then
        PromptSetControlAction(MoveForwardPrompt, BccUtils.Keys['R'])
    else
        devPrint("Error: Key 'R' not found in Keys table")
    end
    -- Register movement prompts
    MoveForwardPrompt = PromptRegisterBegin()
    PromptSetControlAction(MoveForwardPrompt, BccUtils.Keys['R'])
    PromptSetText(MoveForwardPrompt, CreateVarString(10, 'LITERAL_STRING', _U("forward")))
    PromptSetStandardMode(MoveForwardPrompt, true)
    PromptSetGroup(MoveForwardPrompt, FurnitureGroup, 0)
    PromptRegisterEnd(MoveForwardPrompt)

    MoveBackwardPrompt = PromptRegisterBegin()
    PromptSetControlAction(MoveBackwardPrompt, BccUtils.Keys['E'])
    PromptSetText(MoveBackwardPrompt, CreateVarString(10, 'LITERAL_STRING', _U("backward")))
    PromptSetStandardMode(MoveBackwardPrompt, true)
    PromptSetGroup(MoveBackwardPrompt, FurnitureGroup, 0)
    PromptRegisterEnd(MoveBackwardPrompt)

    MoveLeftPrompt = PromptRegisterBegin()
    PromptSetControlAction(MoveLeftPrompt, BccUtils.Keys['LEFT'])
    PromptSetText(MoveLeftPrompt, CreateVarString(10, 'LITERAL_STRING', _U("left")))
    PromptSetStandardMode(MoveLeftPrompt, true)
    PromptSetGroup(MoveLeftPrompt, FurnitureGroup, 0)
    PromptRegisterEnd(MoveLeftPrompt)

    MoveRightPrompt = PromptRegisterBegin()
    PromptSetControlAction(MoveRightPrompt, BccUtils.Keys['RIGHT'])
    PromptSetText(MoveRightPrompt, CreateVarString(10, 'LITERAL_STRING', _U("right")))
    PromptSetStandardMode(MoveRightPrompt, true)
    PromptSetGroup(MoveRightPrompt, FurnitureGroup, 0)
    PromptRegisterEnd(MoveRightPrompt)

    MoveUpPrompt = PromptRegisterBegin()
    PromptSetControlAction(MoveUpPrompt, BccUtils.Keys['UP'])
    PromptSetText(MoveUpPrompt, CreateVarString(10, 'LITERAL_STRING', _U("up")))
    PromptSetStandardMode(MoveUpPrompt, true)
    PromptSetGroup(MoveUpPrompt, FurnitureGroup, 0)
    PromptRegisterEnd(MoveUpPrompt)

    MoveDownPrompt = PromptRegisterBegin()
    PromptSetControlAction(MoveDownPrompt, BccUtils.Keys['DOWN'])
    PromptSetText(MoveDownPrompt, CreateVarString(10, 'LITERAL_STRING', _U("down")))
    PromptSetStandardMode(MoveDownPrompt, true)
    PromptSetGroup(MoveDownPrompt, FurnitureGroup, 0)
    PromptRegisterEnd(MoveDownPrompt)

    -- Register rotation prompts
    RotateYawPrompt = PromptRegisterBegin()
    PromptSetControlAction(RotateYawPrompt, BccUtils.Keys['UP'])
    PromptSetText(RotateYawPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotateYaw")))
    PromptSetStandardMode(RotateYawPrompt, true)
    PromptSetGroup(RotateYawPrompt, FurnitureGroup, 1)
    PromptRegisterEnd(RotateYawPrompt)

    RotateYawLeftPrompt = PromptRegisterBegin()
    PromptSetControlAction(RotateYawLeftPrompt, BccUtils.Keys['DOWN'])
    PromptSetText(RotateYawLeftPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotateYawLeft")))
    PromptSetStandardMode(RotateYawLeftPrompt, true)
    PromptSetGroup(RotateYawLeftPrompt, FurnitureGroup, 1)
    PromptRegisterEnd(RotateYawLeftPrompt)

    RotatePitchPrompt = PromptRegisterBegin()
    PromptSetControlAction(RotatePitchPrompt, BccUtils.Keys['E'])
    PromptSetText(RotatePitchPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotatepitch")))
    PromptSetStandardMode(RotatePitchPrompt, true)
    PromptSetGroup(RotatePitchPrompt, FurnitureGroup, 1)
    PromptRegisterEnd(RotatePitchPrompt)

    RotateBackwardPrompt = PromptRegisterBegin()
    PromptSetControlAction(RotateBackwardPrompt, BccUtils.Keys['R'])
    PromptSetText(RotateBackwardPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotatebackward")))
    PromptSetStandardMode(RotateBackwardPrompt, true)
    PromptSetGroup(RotateBackwardPrompt, FurnitureGroup, 1)
    PromptRegisterEnd(RotateBackwardPrompt)

    RotateRightPrompt = PromptRegisterBegin()
    PromptSetControlAction(RotateRightPrompt, BccUtils.Keys['RIGHT'])
    PromptSetText(RotateRightPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotateright")))
    PromptSetStandardMode(RotateRightPrompt, true)
    PromptSetGroup(RotateRightPrompt, FurnitureGroup, 1)
    PromptRegisterEnd(RotateRightPrompt)

    RotateLeftPrompt = PromptRegisterBegin()
    PromptSetControlAction(RotateLeftPrompt, BccUtils.Keys['LEFT'])
    PromptSetText(RotateLeftPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotateleft")))
    PromptSetStandardMode(RotateLeftPrompt, true)
    PromptSetGroup(RotateLeftPrompt, FurnitureGroup, 1)
    PromptRegisterEnd(RotateLeftPrompt)

    IncreasePrecisionPrompt = PromptRegisterBegin()
    PromptSetControlAction(IncreasePrecisionPrompt, BccUtils.Keys['UP'])
    PromptSetText(IncreasePrecisionPrompt, CreateVarString(10, 'LITERAL_STRING', _U("increasePrecision")))
    PromptSetStandardMode(IncreasePrecisionPrompt, true)
    PromptSetGroup(IncreasePrecisionPrompt, FurnitureGroup, 2)
    PromptRegisterEnd(IncreasePrecisionPrompt)

    DecreasePrecisionPrompt = PromptRegisterBegin()
    PromptSetControlAction(DecreasePrecisionPrompt, BccUtils.Keys['DOWN'])
    PromptSetText(DecreasePrecisionPrompt, CreateVarString(10, 'LITERAL_STRING', _U("decreasePrecision")))
    PromptSetStandardMode(DecreasePrecisionPrompt, true)
    PromptSetGroup(DecreasePrecisionPrompt, FurnitureGroup, 2)
    PromptRegisterEnd(DecreasePrecisionPrompt)

    -- Register confirmation and cancel prompts
    ConfirmPrompt = PromptRegisterBegin()
    PromptSetControlAction(ConfirmPrompt, BccUtils.Keys['SPACEBAR'])
    PromptSetText(ConfirmPrompt, CreateVarString(10, 'LITERAL_STRING', _U("confirmPlacement")))
    PromptSetStandardMode(ConfirmPrompt, true)
    PromptSetGroup(ConfirmPrompt, FurnitureGroup, 3)
    PromptRegisterEnd(ConfirmPrompt)

    CancelPrompt = PromptRegisterBegin()
    PromptSetControlAction(CancelPrompt, BccUtils.Keys['BACKSPACE'])
    PromptSetText(CancelPrompt, CreateVarString(10, 'LITERAL_STRING', _U("cancelPlacement")))
    PromptSetStandardMode(CancelPrompt, true)
    PromptSetGroup(CancelPrompt, FurnitureGroup, 3)
    PromptRegisterEnd(CancelPrompt)
end

function PlaceFurnitureIntoWorldPrompt(model, cost, displayName, sellPrice)
    local playerPed = PlayerPedId()
    local placementCoords = GetEntityCoords(playerPed)
    local createdObject = CreateObject(model, placementCoords.x, placementCoords.y + 1, placementCoords.z, true, true,
        true)
    SetEntityCollision(createdObject, false, true)
    TriggerEvent('bcc-housing:CheckIfInRadius', createdObject)

    local amountToMove = 1.0 -- default movement precision

    -- Notify player of controls
    VORPcore.NotifyRightTip(_U('furnitureControls'), 5000)

    -- Main loop for handling prompt inputs
    Citizen.CreateThread(function()
        StartFurniturePlacementPrompts()
        while true do
            local playerPed = PlayerPedId()
            if IsEntityDead(playerPed) then goto END end
            Citizen.Wait(0)
            PromptSetEnabled(ConfirmPrompt, true)
            PromptSetEnabled(CancelPrompt, true)
            -- Set active group for this frame
            PromptSetActiveGroupThisFrame(FurnitureGroup, CreateVarString(10, 'LITERAL_STRING', _U("movementControls")),
                4, 0, 0, 0)
            PromptSetEnabled(MoveForwardPrompt, true)
            PromptSetEnabled(MoveBackwardPrompt, true)
            PromptSetEnabled(MoveLeftPrompt, true)
            PromptSetEnabled(MoveRightPrompt, true)
            PromptSetEnabled(MoveUpPrompt, true)
            PromptSetEnabled(MoveDownPrompt, true)
            PromptSetEnabled(RotateYawPrompt, true)
            PromptSetEnabled(RotateYawLeftPrompt, true)
            PromptSetEnabled(RotatePitchPrompt, true)    -- Added
            PromptSetEnabled(RotateBackwardPrompt, true) -- Added
            PromptSetEnabled(RotateRightPrompt, true)    -- Added
            PromptSetEnabled(RotateLeftPrompt, true)     -- Added
            PromptSetEnabled(IncreasePrecisionPrompt, true)
            PromptSetEnabled(DecreasePrecisionPrompt, true)

            local step = amountToMove * 0.1
            if Citizen.InvokeNative(0xC92AC953F0A982AE, MoveForwardPrompt) then
                MoveFurniture(createdObject, "forward", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, MoveBackwardPrompt) then
                MoveFurniture(createdObject, "backward", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, MoveLeftPrompt) then
                MoveFurniture(createdObject, "left", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, MoveRightPrompt) then
                MoveFurniture(createdObject, "right", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, MoveUpPrompt) then
                MoveFurniture(createdObject, "up", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, MoveDownPrompt) then
                MoveFurniture(createdObject, "down", step)
            end

            step = amountToMove * 5
            -- Handle rotation prompts
            if Citizen.InvokeNative(0xC92AC953F0A982AE, RotateYawPrompt) then
                MoveFurniture(createdObject, "rotateYaw", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, RotateYawLeftPrompt) then
                MoveFurniture(createdObject, "rotateYawLeft", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, RotatePitchPrompt) then
                MoveFurniture(createdObject, "rotatepitch", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, RotateBackwardPrompt) then
                MoveFurniture(createdObject, "rotatebackward", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, RotateRightPrompt) then
                MoveFurniture(createdObject, "rotateright", step)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, RotateLeftPrompt) then
                MoveFurniture(createdObject, "rotateleft", step)
            end

            -- Adjust precision
            if Citizen.InvokeNative(0xC92AC953F0A982AE, IncreasePrecisionPrompt) then
                amountToMove = amountToMove + 0.1
                VORPcore.NotifyRightTip(_U("movementIncreased") .. amountToMove, 1000)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, DecreasePrecisionPrompt) then
                amountToMove = amountToMove - 0.1
                VORPcore.NotifyRightTip(_U("movementDecreased") .. amountToMove, 1000)
            end

            -- Confirm placement
            if Citizen.InvokeNative(0xC92AC953F0A982AE, ConfirmPrompt) then
                SetEntityCollision(createdObject, true, true)
                if ConfirmFurniturePlacement(createdObject, model, cost, displayName, sellPrice) then
                    FreezeEntityPosition(createdObject, true)
                    TriggerServerEvent('bcc-housing:SaveFurnitureData', {
                        model = model,
                        coords = GetEntityCoords(createdObject),
                        heading = GetEntityHeading(createdObject)
                    })
                else
                    DeleteObject(createdObject)
                    VORPcore.NotifyRightTip(_U("toFar"), 4000)
                end
                break -- Exit loop
            end

            -- Cancel placement
            if Citizen.InvokeNative(0xC92AC953F0A982AE, CancelPrompt) then
                DeleteObject(createdObject)
                VORPcore.NotifyRightTip(_U("placementCanceled"), 4000)
                break -- Exit loop
            end
            :: END ::
        end

        -- Cleanup prompts after loop ends
        PromptDelete(MoveForwardPrompt)
        PromptDelete(MoveBackwardPrompt)
        PromptDelete(MoveLeftPrompt)
        PromptDelete(MoveRightPrompt)
        PromptDelete(MoveUpPrompt)
        PromptDelete(MoveDownPrompt)
        PromptDelete(RotateYawPrompt)
        PromptDelete(RotateYawLeftPrompt)
        PromptDelete(RotatePitchPrompt)    -- Added
        PromptDelete(RotateBackwardPrompt) -- Added
        PromptDelete(RotateRightPrompt)    -- Added
        PromptDelete(RotateLeftPrompt)     -- Added
        PromptDelete(IncreasePrecisionPrompt)
        PromptDelete(DecreasePrecisionPrompt)
        PromptDelete(ConfirmPrompt)
        PromptDelete(CancelPrompt)
    end)
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

function closeToHouse(object)
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
    local furnObj = NetworkGetEntityFromNetworkId(entId)

    if DoesEntityExist(furnObj) then
        table.insert(CreatedFurniture, furnObj)
    else
        devPrint("Error: Furniture entity does not exist, could not add to CreatedFurniture.")
        VORPcore.NotifyRightTip(_U("furnNotPlaced"), 4000)
        return
    end

    TriggerServerEvent('bcc-housing:InsertFurnitureIntoDB', furnitureCreatedTable, HouseId)

    -- Store the furniture entity for potential deletion later
    TriggerServerEvent('bcc-housing:StoreFurnForDeletion', entId, HouseId)

    VORPcore.NotifyRightTip(_U("furnPlaced"), 4000)
end)


RegisterNetEvent('bcc-housing:ClientFurnBoughtFail', function()
    DeleteObject(furnObj)
    furnObj = nil
end)

-- Function to trigger server event
function GetOwnedFurniture(houseId)
    devPrint("Requesting furniture for house ID:", houseId) -- Debug print
    TriggerServerEvent('bcc-housing:GetOwnerFurniture', houseId)
end

-- Helper function to handle the sale of furniture (implement as needed)
function SellFurniture(furniture)
    devPrint("Selling furniture:", furniture.model)
    -- You can add server event here to handle the backend sale process
    TriggerServerEvent('bcc-housing:SellFurniture', furniture)
end

function SellOwnedFurnitureMenu(houseId, furnTable, ownershipStatus)
    devPrint("Opening SellOwnedFurnitureMenu with houseId: " .. tostring(houseId))
    BCCHousingMenu:Close() -- Close any previously opened menus

    if HandlePlayerDeathAndCloseMenu() then
        return -- Skip opening the menu if the player is dead
    end

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
                    local dist = Vdist(storedFurnCoord.x, storedFurnCoord.y, storedFurnCoord.z, v.coords.x, v.coords.y,
                        v.coords.z)
                    if dist < 1.0 then -- Check if the distance is less than 1 meter
                        DeleteEntity(entity)
                        table.remove(CreatedFurniture, idx)
                        TriggerServerEvent('bcc-housing:FurnSoldRemoveFromTable', v, houseId, furnTable, k, ownershipStatus)
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
            value = _U('noFurnAvailable'),
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
        style = {['position'] = 'relative', ['z-index'] = 9,}
    }, function()
        FurnitureMenu(houseId, ownershipStatus)
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
        startupPage = sellFurnMenu,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        }
    })
end

function GetOwnedFurniture(houseId)
    devPrint("Requesting furniture for house ID: " .. tostring(houseId))
    TriggerServerEvent('bcc-housing:GetOwnerFurniture', houseId)
end

RegisterNetEvent('bcc-housing:SellOwnedFurnMenu')
AddEventHandler('bcc-housing:SellOwnedFurnMenu', function(houseId, furnTable, ownershipStatus)
    devPrint("Opening Sell Owned Furniture Menu for House ID: " .. tostring(houseId))
    if type(furnTable) == "table" then
        SellOwnedFurnitureMenu(houseId, furnTable, ownershipStatus)
    else
        devPrint("Error: furnTable is not a table")
    end
end)
