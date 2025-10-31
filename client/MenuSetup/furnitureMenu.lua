local MoveForwardPrompt, MoveBackwardPrompt, MoveLeftPrompt, MoveRightPrompt, MoveUpPrompt, MoveDownPrompt
local RotateYawPrompt, RotateYawLeftPrompt, RotatePitchPrompt, RotateBackwardPrompt, RotateRightPrompt, RotateLeftPrompt
local IncreasePrecisionPrompt, DecreasePrecisionPrompt, ConfirmPrompt, CancelPrompt
local FurnitureGroup = GetRandomIntInRange(0, 0xffffff)
local OwnedFurnitureCache = {}
local ActivePlacementItem = nil
local LastPlacementObject = nil
local FurnitureMenuOpen = false

local OpenFurnitureVendorItemMenu
local VendorPreviewObj = nil
local vendorCam

function ClearVendorPreview()
    if not VendorPreviewObj then return end
    if VendorPreviewObj.Remove then
        VendorPreviewObj:Remove()
    else
        local ent = VendorPreviewObj
        if type(ent) == "number" and DoesEntityExist(ent) then
            DeleteEntity(ent)
        end
    end
    VendorPreviewObj = nil
end

function CreateCamera()
    if vendorCam and DoesCamExist(vendorCam) then
        return
    end
    local vendorCfg = ActiveFurnitureVendor
    if not vendorCfg and Furniture and Furniture.Vendors and Furniture.Vendors[1] then
        vendorCfg = Furniture.Vendors[1]
    end
    if not vendorCfg and Config.FurnitureVendors and Config.FurnitureVendors[1] then
        vendorCfg = Config.FurnitureVendors[1]
    end

    local cameraCfg = (vendorCfg and vendorCfg.camera) or {}
    local creation = cameraCfg.creation or (Config.CameraCoords and Config.CameraCoords.creation)
    if not creation then return end

    vendorCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(vendorCam, creation.x, creation.y, creation.z + (creation.zOffset or 0.0))
    if creation.zoom then
        SetCamFov(vendorCam, creation.zoom)
    end
    SetCamActive(vendorCam, true)

    local lookAt = cameraCfg.lookAt
    if not lookAt and vendorCfg and vendorCfg.coords then
        if vendorCfg.coords.x then
            lookAt = vector3(vendorCfg.coords.x, vendorCfg.coords.y, vendorCfg.coords.z)
        elseif type(vendorCfg.coords[1]) == "table" and vendorCfg.coords[1].x then
            local first = vendorCfg.coords[1]
            lookAt = vector3(first.x, first.y, first.z)
        elseif type(vendorCfg.coords) == "vector3" then
            lookAt = vendorCfg.coords
        end
    end
    if not lookAt and Config.CameraCoords and Config.CameraCoords.creation then
        lookAt = vector3(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z)
    end
    if lookAt then
        PointCamAtCoord(vendorCam, lookAt.x, lookAt.y, lookAt.z)
    end
    RenderScriptCams(true, false, 0, false, false, 0)
end

function EndCam()
    RenderScriptCams(false, true, 1000, true, false, 0)
    DestroyCam(vendorCam, false)
    vendorCam = nil
    DestroyAllCams(true)
    SetFocusEntity(PlayerPedId())
    ActiveFurnitureVendor = nil
end

local function SpawnVendorItemAtCam(item)
    if not item then return end
    ClearVendorPreview()

    local vendorCfg = ActiveFurnitureVendor
    if not vendorCfg and Furniture and Furniture.Vendors and Furniture.Vendors[1] then
        vendorCfg = Furniture.Vendors[1]
    end
    if not vendorCfg and Config.FurnitureVendors and Config.FurnitureVendors[1] then
        vendorCfg = Config.FurnitureVendors[1]
    end

    local cameraCfg = (vendorCfg and vendorCfg.camera) or {}
    local cam = cameraCfg.itemPreview or cameraCfg.creation or (Config.CameraCoords and Config.CameraCoords.itemPreview)
    if not cam then
        cam = Config.CameraCoords and Config.CameraCoords.creation
    end
    if not cam then return end

    local model = item.propModel or item.model
    if not model then return end

    local obj = BccUtils.Objects:Create(model, cam.x, cam.y, cam.z, cam.h or 0.0, true, 'standard')
    obj:PlaceOnGround(true)
    VendorPreviewObj = obj
end

function FurnitureMenu(houseId, ownershipStatus, ownedFurniture)
    houseId = houseId or HouseId
    ownershipStatus = ownershipStatus or HouseOwnershipStatus
    if ownedFurniture then
        OwnedFurnitureCache = ownedFurniture
    end

    if not houseId then
        FurnitureMenuOpen = false
        Notify(_U("noHouseSelected"), 4000)
        return
    end

    FurnitureMenuOpen = false

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local furnitureMainMenu = BCCHousingMenu:RegisterPage("bcc-housing-owned-furniture-menu")

    furnitureMainMenu:RegisterElement('header', {
        value = _U("ownedFurnitureHeader"),
        slot = 'header',
        style = {}
    })

    furnitureMainMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    if not OwnedFurnitureCache or #OwnedFurnitureCache == 0 then
        furnitureMainMenu:RegisterElement('textdisplay', {
            value = _U("noUnplacedFurniture"),
            slot = 'content',
            style = {}
        })
    else
        table.sort(OwnedFurnitureCache, function(a, b)
            if a.displayName == b.displayName then
                return (a.id or "") < (b.id or "")
            end
            return (a.displayName or "") < (b.displayName or "")
        end)

        for _, item in ipairs(OwnedFurnitureCache) do
            local label = item.displayName or item.model
            if item.category and item.category ~= '' then
                label = label .. " (" .. item.category .. ")"
            end
            furnitureMainMenu:RegisterElement('button', {
                label = label,
                style = {}
            }, function()
                FurnitureMenuOpen = false
                ActivePlacementItem = item
                BCCHousingMenu:Close()
                PlaceFurnitureIntoWorldPrompt(item)
            end)
        end
    end

    furnitureMainMenu:RegisterElement('line', {
        slot = "content",
        style = {}
    })

    furnitureMainMenu:RegisterElement('button', {
        label = _U("sellOwnerFurn"),
        style = {}
    }, function()
        local success, furnDataOrMessage, ownershipStatus = BccUtils.RPC:CallAsync("bcc-housing:GetOwnerFurniture",
            { houseId = houseId })
        if success then
            SellOwnedFurnitureMenu(houseId, furnDataOrMessage or {}, ownershipStatus)
        else
            if furnDataOrMessage then
                Notify(furnDataOrMessage, "error", 4000)
            else
                Notify(_U("noFurn"), "info", 4000)
            end
        end
    end)

    furnitureMainMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    furnitureMainMenu:RegisterElement('button', {
        label = _U("closeButton"),
        slot = 'footer',
        style = { ['position'] = 'relative', ['z-index'] = 9 }
    }, function()
        FurnitureMenuOpen = false
        BCCHousingMenu:Close()
    end)

    furnitureMainMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    FurnitureMenuOpen = true
    BCCHousingMenu:Open({
        startupPage = furnitureMainMenu,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        }
    })
end

function OpenFurnitureVendorItemMenu(categoryIndex, itemIndex)
    local furnConfigTable = Furniture[categoryIndex]
    if not furnConfigTable then
        devPrint("Vendor preview missing category index: " .. tostring(categoryIndex))
        return
    end

    itemIndex = math.floor(tonumber(itemIndex) or 1)
    if itemIndex < 1 then itemIndex = 1 end
    local item = furnConfigTable[itemIndex]
    if not item then
        Notify(_U("invalidFurnitureItem"), "error", 4000)
        return
    end
    CreateCamera()
    SpawnVendorItemAtCam(item)
    local itemPage = BCCHousingMenu:RegisterPage("bcc-housing-furniture-vendor-item-" .. categoryIndex .. "-" .. itemIndex)
    itemPage:RegisterElement('header', {
        value = furnConfigTable.title,
        slot = 'header',
        style = {}
    })

    itemPage:RegisterElement('subheader', {
        value = 'Selecteaza articol',
        slot = 'header',
        style = {}
    })

    itemPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    local arrowOptions = {}
    for idx, arrowItem in ipairs(furnConfigTable) do
        arrowOptions[#arrowOptions + 1] = {
            display = arrowItem.displayName,
            itemIndex = idx
        }
    end

    if #arrowOptions > 1 then
        itemPage:RegisterElement('arrows', {
            label = 'Furniture',
            start = itemIndex,
            options = arrowOptions,
            persist = true
        }, function(data)
            if not data then return end
            local value = data.value
            local newIndex = value and (value.itemIndex or value)
            if type(newIndex) == 'string' then
                newIndex = tonumber(newIndex)
            end
            if not newIndex or newIndex == itemIndex then return end
            OpenFurnitureVendorItemMenu(categoryIndex, newIndex)
        end)

        itemPage:RegisterElement('line', {
            slot = 'content',
            style = {}
        })

    end
    local price = tonumber(item.costToBuy) or 0
    itemPage:RegisterElement('textdisplay', {
        value = "Price : " .. price .. " $",
        slot = 'content',
        style = {}
    })

    itemPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    itemPage:RegisterElement('button', {
        label = _U("buyOwnerFurn"),
        slot = 'footer',
        style = {}
    }, function()
        local success = BccUtils.RPC:CallAsync("bcc-housing:PurchaseFurnitureItem", {
            categoryIndex = categoryIndex,
            itemIndex = itemIndex
        })

        if not success then
            local reason = _U("unknownError")
            Notify(reason, "error", 4000)
            return
        end

        Notify(_U("furnAddedToBook"), "success", 4000)
    end)
    itemPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {}
    }, function()
        ClearVendorPreview()
        FurnitureVendorMenu()
    end)

    itemPage:RegisterElement('button', {
        label = _U("closeButton"),
        slot = 'footer',
        style = { ['position'] = 'relative', ['z-index'] = 9 }
    }, function()
        ClearVendorPreview()
        EndCam()
        BCCHousingMenu:Close()
    end)

    itemPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    if item.desc or furnConfigTable.desc then
        itemPage:RegisterElement('textdisplay', {
            value = item.desc or furnConfigTable.desc,
            slot = 'footer',
            style = {}
        })
    end

    BCCHousingMenu:Open({
        startupPage = itemPage,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        }
    })
end

function OpenFurnitureVendorCategoryMenu(categoryIndex)
    local furnConfigTable = Furniture[categoryIndex]
    if not furnConfigTable then
        devPrint("Invalid furniture category index: " .. tostring(categoryIndex))
        return
    end
    OpenFurnitureVendorItemMenu(categoryIndex, 1)
end

function FurnitureVendorMenu()
    if not ActiveFurnitureVendor then
        if Furniture and Furniture.Vendors and Furniture.Vendors[1] then
            ActiveFurnitureVendor = Furniture.Vendors[1]
        elseif Config.FurnitureVendors and Config.FurnitureVendors[1] then
            ActiveFurnitureVendor = Config.FurnitureVendors[1]
        end
    end
    CreateCamera()
    ClearVendorPreview()
    FurnitureMenuOpen = false

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local vendorMenu = BCCHousingMenu:RegisterPage("bcc-housing-furniture-vendor")
    vendorMenu:RegisterElement('header', {
        value = _U("furnitureVendorTitle"),
        slot = 'header',
        style = {}
    })

    vendorMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for index, category in ipairs(Furniture) do
        vendorMenu:RegisterElement('button', {
            label = category.title,
            style = {}
        }, function()
            OpenFurnitureVendorCategoryMenu(index)
        end)
    end

    vendorMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    vendorMenu:RegisterElement('button', {
        label = _U("closeButton"),
        slot = "footer",
        style = { ['position'] = 'relative', ['z-index'] = 9 }
    }, function()
        ClearVendorPreview()
        EndCam()
        BCCHousingMenu:Close()
    end)

    vendorMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCHousingMenu:Open({
        startupPage = vendorMenu,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        }
    })
end

local function HandleFurniturePlaced(entId)
    local furnObj = NetworkGetEntityFromNetworkId(entId)
    if furnObj and DoesEntityExist(furnObj) then
        table.insert(CreatedFurniture, furnObj)
    else
        devPrint("Error: Furniture entity does not exist, could not add to CreatedFurniture.")
        Notify(_U("furnNotPlaced"), "error", 4000)
        return false
    end

    if HouseId then
        BccUtils.RPC:Notify('bcc-housing:StoreFurnForDeletion', {
            entId = entId,
            houseid = HouseId
        })
    end

    LastPlacementObject = nil
    ActivePlacementItem = nil
    Notify(_U("furnPlaced"), "success", 4000)
    return true
end

BccUtils.RPC:Register('bcc-housing:OpenFurnitureBook', function(params)
    local ownedFurniture = params and params.ownedFurniture or {}
    OwnedFurnitureCache = ownedFurniture
    FurnitureMenu(HouseId, HouseOwnershipStatus, OwnedFurnitureCache)
end)

BccUtils.RPC:Register("bcc-housing:OwnedFurnitureSync", function(params)
    OwnedFurnitureCache = params.ownedItems or {}
    if FurnitureMenuOpen then
        FurnitureMenu(HouseId, HouseOwnershipStatus, OwnedFurnitureCache)
    end
end)

RegisterNetEvent('bcc-housing:OpenFurnitureVendor', function()
    if Furniture and Furniture.Vendors and Furniture.Vendors[1] then
        ActiveFurnitureVendor = Furniture.Vendors[1]
    elseif Config.FurnitureVendors and Config.FurnitureVendors[1] then
        ActiveFurnitureVendor = Config.FurnitureVendors[1]
    end
    CreateCamera()
    ClearVendorPreview()
    FurnitureVendorMenu()
end)


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

function PlaceFurnitureIntoWorldPrompt(itemData)
    if not itemData or not itemData.model then
        devPrint("Invalid furniture item passed to placement prompt.")
        return
    end
    local model = itemData.model
    local displayName = itemData.displayName or itemData.model
    local sellPrice = itemData.sellprice or 0
    local ownedId = itemData.id

    local playerPed = PlayerPedId()
    local placementCoords = GetEntityCoords(playerPed)
    local createdObject = CreateObject(model, placementCoords.x, placementCoords.y + 1, placementCoords.z, true, true,
        true)
    if createdObject == 0 then
        devPrint("Failed to create furniture object for model: " .. tostring(model))
        Notify(_U("furnNotPlaced"), "error", 4000)
        return
    end

    LastPlacementObject = createdObject
    SetEntityCollision(createdObject, false, true)
    TriggerEvent('bcc-housing:CheckIfInRadius', createdObject)
    local amountToMove = 1.0 -- default movement precision

    -- Notify player of controls
    Notify(_U('furnitureControls'), 5000)

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
                Notify(_U("movementIncreased") .. amountToMove, 1000)
            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, DecreasePrecisionPrompt) then
                amountToMove = amountToMove - 0.1
                Notify(_U("movementDecreased") .. amountToMove, 1000)
            end

            -- Confirm placement
            if Citizen.InvokeNative(0xC92AC953F0A982AE, ConfirmPrompt) then
                SetEntityCollision(createdObject, true, true)
                if ConfirmFurniturePlacement(createdObject, {
                        model = model,
                        displayName = displayName,
                        sellprice = sellPrice,
                        ownedId = ownedId
                    }) then
                    FreezeEntityPosition(createdObject, true)
                    ActivePlacementItem = nil
                    LastPlacementObject = nil
                else
                    DeleteObject(createdObject)
                    Notify(_U("toFar"), "error", 4000)
                    ActivePlacementItem = nil
                    LastPlacementObject = nil
                end
                break -- Exit loop
            end

            -- Cancel placement
            if Citizen.InvokeNative(0xC92AC953F0A982AE, CancelPrompt) then
                DeleteObject(createdObject)
                Notify(_U("placementCanceled"), 4000)
                ActivePlacementItem = nil
                LastPlacementObject = nil
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

function ConfirmFurniturePlacement(obj, placementContext)
    if not placementContext or not placementContext.ownedId then
        return false
    end

    if not HouseId then
        Notify(_U("noHouseSelected"), "error", 4000)
        return false
    end

    local isClose = closeToHouse(obj)
    if not isClose then
        return false
    end

    -- finalize the object locally
    SetEntityCollision(obj, true, true)
    FreezeEntityPosition(obj, true)

    local entId = NetworkGetNetworkIdFromEntity(obj)

    -- RPC instead of TriggerServerEvent
    local success = BccUtils.RPC:CallAsync("bcc-housing:PlaceOwnedFurniture", {
        ownedId = placementContext.ownedId,
        houseId = HouseId,
        entId = entId,
        placementData = {
            model = placementContext.model,
            coords = GetEntityCoords(obj),
            rotation = GetEntityRotation(obj),
            displayName = placementContext.displayName,
            sellprice = placementContext.sellprice
        }
    })

    if not success then
        Notify(_U("furnNotPlaced"), "error", 4000)
        return false
    end

    HandleFurniturePlaced(entId)
    return true
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

-- Helper function to handle the sale of furniture (implement as needed)
function SellFurniture(furniture)
    devPrint("Selling furniture:", furniture.model)
    -- You can add server logic here to handle the backend sale process
    BccUtils.RPC:CallAsync('bcc-housing:SellFurniture', { furniture = furniture })
end

function SellOwnedFurnitureMenu(houseId, furnTable, ownershipStatus)
    devPrint("Opening SellOwnedFurnitureMenu with houseId: " .. tostring(houseId))
    BCCHousingMenu:Close() -- Close any previously opened menus

    if HandlePlayerDeathAndCloseMenu() then
        return
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
                local attempted = false
                for idx, entity in ipairs(CreatedFurniture) do
                    local storedFurnCoord = GetEntityCoords(entity)
                    local dist = Vdist(storedFurnCoord.x, storedFurnCoord.y, storedFurnCoord.z, v.coords.x, v.coords.y,
                        v.coords.z)
                    if dist < 1.0 then -- Check if the distance is less than 1 meter
                        attempted = true
                        local ok = BccUtils.RPC:CallAsync('bcc-housing:FurnSoldRemoveFromTable', {
                            furnTable = v,
                            houseId = houseId,
                            wholeFurnTable = furnTable,
                            wholeFurnTableKey = k,
                            ownershipStatus = ownershipStatus
                        })

                        if ok then
                            DeleteEntity(entity)
                            table.remove(CreatedFurniture, idx)
                            sold = true
                        else
                            Notify(_U("furnNotSold"), "error", 4000)
                        end
                        break
                    end
                end
                if not sold and not attempted then
                    Notify(_U("furnNotSold"), "error", 4000)
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
        style = { ['position'] = 'relative', ['z-index'] = 9, }
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
    local success, furnDataOrMessage, ownershipStatus = BccUtils.RPC:CallAsync("bcc-housing:GetOwnerFurniture",
        { houseId = houseId })
    if success then
        SellOwnedFurnitureMenu(houseId, furnDataOrMessage or {}, ownershipStatus)
    else
        if furnDataOrMessage then
            Notify(furnDataOrMessage, "error", 4000)
        else
            Notify(_U("noFurn"), "info", 4000)
        end
    end
end

BccUtils.RPC:Register("bcc-housing:SellOwnedFurnMenu", function(params)
    if not params then return end
    local houseId = params.houseId
    local furnTable = params.furniture
    local ownershipStatus = params.ownershipStatus
    devPrint("Opening Sell Owned Furniture Menu for House ID: " .. tostring(houseId))
    if type(furnTable) == "table" then
        SellOwnedFurnitureMenu(houseId, furnTable, ownershipStatus)
    else
        devPrint("Error: furnTable is not a table")
    end
end)
