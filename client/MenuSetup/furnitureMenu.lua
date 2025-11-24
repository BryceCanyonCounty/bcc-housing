local MoveForwardPrompt, MoveBackwardPrompt, MoveLeftPrompt, MoveRightPrompt, MoveUpPrompt, MoveDownPrompt
local RotateYawPrompt, RotateYawLeftPrompt, RotatePitchPrompt, RotateBackwardPrompt, RotateRightPrompt, RotateLeftPrompt
local IncreasePrecisionPrompt, DecreasePrecisionPrompt, ConfirmPrompt, CancelPrompt
local FurnitureGroup = GetRandomIntInRange(0, 0xffffff)

local OwnedFurnitureCache = {}
ActivePlacementItem, ActivePlacementHouseId = nil, nil
LastPlacementObject = nil
local FurnitureMenuOpen = false

local OpenFurnitureVendorItemMenu
local VendorPreviewObj = nil
local vendorCam
local VendorPreviewBaseHeading = 0.0
local VendorPreviewRotationIndex = 1
local VendorPreviewZoomIndex = 1
local VendorPreviewDefaultZoom = 60.0

local VendorRotationOptions = {}
for rot = 0, 330, 30 do
    VendorRotationOptions[#VendorRotationOptions + 1] = {
        display = (rot == 0 and "0°" or (tostring(rot) .. "°")),
        rotation = rot
    }
end
for idx, option in ipairs(VendorRotationOptions) do
    option.optionIndex = idx
end

local VendorZoomBaseLevels = { 35.0, 45.0, 55.0, 65.0, 75.0, 85.0 }
local VendorZoomOptions = {}

---------------------------------
-- Utility helpers
---------------------------------

local function UpdateVendorPreviewHeading(heading)
    if not VendorPreviewObj then return end
    if type(VendorPreviewObj) == "table" then
        if VendorPreviewObj.SetHeading then
            VendorPreviewObj:SetHeading(heading)
            return
        elseif VendorPreviewObj.GetObj then
            local obj = VendorPreviewObj:GetObj()
            if obj and DoesEntityExist(obj) then
                SetEntityHeading(obj, heading)
                return
            end
        end
    end
    if type(VendorPreviewObj) == "number" and DoesEntityExist(VendorPreviewObj) then
        SetEntityHeading(VendorPreviewObj, heading)
    end
end

local function BuildVendorZoomOptions(defaultZoom)
    local seen = {}
    local options = {}

    local function insertZoom(value)
        if not value or seen[value] then return end
        seen[value] = true
        options[#options + 1] = {
            display = string.format("Zoom %.0f", value),
            zoom = value
        }
    end

    for _, level in ipairs(VendorZoomBaseLevels) do
        insertZoom(level)
    end
    if defaultZoom then
        insertZoom(defaultZoom)
    end

    table.sort(options, function(a, b)
        return a.zoom < b.zoom
    end)

    local startIndex = 1
    local closestDiff = math.huge
    for idx, option in ipairs(options) do
        option.optionIndex = idx
        if defaultZoom then
            local diff = math.abs(option.zoom - defaultZoom)
            if diff < closestDiff then
                closestDiff = diff
                startIndex = idx
            end
        end
    end

    return options, startIndex
end

local function ApplyVendorPreviewRotation(index)
    local option = VendorRotationOptions[index]
    if not option then return end
    VendorPreviewRotationIndex = index
    local heading = (VendorPreviewBaseHeading + option.rotation) % 360
    UpdateVendorPreviewHeading(heading)
end

local function ApplyVendorPreviewZoom(index)
    if not vendorCam or not DoesCamExist(vendorCam) then return end
    local option = VendorZoomOptions[index]
    if not option then return end
    VendorPreviewZoomIndex = index
    VendorPreviewDefaultZoom = option.zoom
    SetCamFov(vendorCam, option.zoom)
end

local function NormalizeCoords(coords)
    if not coords then return nil end
    if type(coords) == "vector3" then return coords end
    if coords.x and coords.y and coords.z then
        return vector3(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z))
    end
    if coords[1] and coords[2] and coords[3] then
        return vector3(tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3]))
    end
    return nil
end

local function CacheHouseContext(context)
    if not context or not context.houseId then return nil end
    OwnedHouseContexts = OwnedHouseContexts or {}
    if context.coords then
        context.coords = NormalizeCoords(context.coords)
    end
    if context.radius then
        context.radius = tonumber(context.radius)
    end
    OwnedHouseContexts[context.houseId] = context
    return context
end

local function RequestHouseContext(houseId)
    if not houseId then return nil end
    local success, ctx = BccUtils.RPC:CallAsync('bcc-housing:GetHouseContext', { houseId = houseId })
    if success and ctx then
        return CacheHouseContext(ctx)
    end
    return nil
end

local function GetClosestCachedHouseContext(pedCoords)
    if not pedCoords or not OwnedHouseContexts then return nil end
    local closestCtx, closestDist = nil, nil
    for _, ctx in pairs(OwnedHouseContexts) do
        if ctx.coords then
            local dist = #(pedCoords - ctx.coords)
            if not closestDist or dist < closestDist then
                closestDist = dist
                closestCtx = ctx
            end
        end
    end
    return closestCtx
end

local function LoadFurnitureModel(modelName)
    if not modelName then return nil, "missing model" end
    local hash = modelName
    if type(modelName) == "string" then
        hash = joaat(modelName)
    end

    if hash == 0 or not IsModelValid(hash) then
        return nil, "invalid model"
    end

    if not HasModelLoaded(hash) then
        RequestModel(hash, false)
        local attempts = 0
        while not HasModelLoaded(hash) and attempts < 100 do
            Citizen.Wait(50)
            attempts = attempts + 1
        end
    end

    if not HasModelLoaded(hash) then
        return nil, "failed to load model"
    end

    return hash
end

function ClearVendorPreview()
    if not VendorPreviewObj then return end
    if type(VendorPreviewObj) == "table" and VendorPreviewObj.Remove then
        VendorPreviewObj:Remove()
    else
        local ent = VendorPreviewObj
        if type(ent) == "number" and DoesEntityExist(ent) then
            DeleteEntity(ent)
        end
    end
    VendorPreviewObj = nil
    VendorPreviewBaseHeading = 0.0
    VendorPreviewRotationIndex = 1
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
        VendorPreviewDefaultZoom = creation.zoom
    else
        VendorPreviewDefaultZoom = GetCamFov(vendorCam)
    end
    VendorPreviewZoomIndex = 1
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
    VendorPreviewZoomIndex = 1
    DestroyAllCams(true)
    SetFocusEntity(PlayerPedId())
    ActiveFurnitureVendor = nil
end

local function SpawnVendorItemAtCam(item)
    DBG:Info("SpawnVendorItemAtCam called")

    if not item then
        DBG:Error("SpawnVendorItemAtCam: no item provided")
        return
    end
    DBG:Info("SpawnVendorItemAtCam: item provided: " .. tostring(item.name or item.model or "unknown"))

    ClearVendorPreview()
    DBG:Info("SpawnVendorItemAtCam: cleared previous vendor preview")

    local vendorCfg = ActiveFurnitureVendor
    DBG:Info("SpawnVendorItemAtCam: ActiveFurnitureVendor " .. (vendorCfg and "found" or "nil"))

    if not vendorCfg and Furniture and Furniture.Vendors and Furniture.Vendors[1] then
        vendorCfg = Furniture.Vendors[1]
        DBG:Info("SpawnVendorItemAtCam: using Furniture.Vendors[1] as vendorCfg")
    end

    if not vendorCfg and Config.FurnitureVendors and Config.FurnitureVendors[1] then
        vendorCfg = Config.FurnitureVendors[1]
        DBG:Info("SpawnVendorItemAtCam: using Config.FurnitureVendors[1] as vendorCfg")
    end

    if not vendorCfg then
        DBG:Error("SpawnVendorItemAtCam: vendorCfg still nil, aborting")
        return
    end

    local cameraCfg = (vendorCfg and vendorCfg.camera) or {}
    DBG:Info("SpawnVendorItemAtCam: cameraCfg loaded: " .. (cameraCfg and "yes" or "no"))

    local cam = cameraCfg.itemPreview or cameraCfg.creation or (Config.CameraCoords and Config.CameraCoords.itemPreview)
    if not cam then
        DBG:Info("SpawnVendorItemAtCam: no cam from vendor, trying Config.CameraCoords.creation")
        cam = Config.CameraCoords and Config.CameraCoords.creation
    end

    if not cam then
        DBG:Error("SpawnVendorItemAtCam: no valid camera coordinates found, aborting")
        return
    end

    DBG:Info(string.format("SpawnVendorItemAtCam: camera coords x=%.2f y=%.2f z=%.2f h=%.2f", cam.x, cam.y, cam.z, cam.h or 0.0))

    local model = item.propModel or item.model
    if not model then
        DBG:Error("SpawnVendorItemAtCam: item has no model/propModel")
        return
    end
    DBG:Info("SpawnVendorItemAtCam: model to spawn: " .. tostring(model))

    DBG:Info("SpawnVendorItemAtCam: attempting object create...")
    local obj = BccUtils.Objects:Create(
        model,
        cam.x, cam.y, cam.z,
        cam.h or 0.0,
        false,
        "no_offset"
    )

    DBG:Info("SpawnVendorItemAtCam: object created: " .. (obj and "success" or "FAILED"))

    obj:PlaceOnGround(true)
    obj:SetAsMission(true)
    DBG:Info("SpawnVendorItemAtCam: object placed on ground")

    VendorPreviewObj = obj
    VendorPreviewBaseHeading = cam.h or 0.0
    VendorPreviewRotationIndex = 1

    DBG:Info("SpawnVendorItemAtCam: updating preview heading to " .. tostring(VendorPreviewBaseHeading))
    UpdateVendorPreviewHeading(VendorPreviewBaseHeading)

    DBG:Info("SpawnVendorItemAtCam complete")
end

---------------------------------
-- Furniture Menu (book) etc.
---------------------------------

function FurnitureMenu(houseId, ownershipStatus, ownedFurniture)
    houseId = houseId or HouseId
    ownershipStatus = ownershipStatus or HouseOwnershipStatus
    if ownedFurniture then
        OwnedFurnitureCache = ownedFurniture
    end

    if not houseId then
        local pedCoords = GetEntityCoords(PlayerPedId())
        local closestCtx = GetClosestCachedHouseContext(pedCoords)
        if closestCtx and closestCtx.houseId then
            houseId = closestCtx.houseId
            if SetActiveHouseContext then
                SetActiveHouseContext(closestCtx)
            else
                HouseCoords = closestCtx.coords or HouseCoords
                HouseRadius = closestCtx.radius or HouseRadius
                HouseId = closestCtx.houseId
            end
        end
    end

    ActivePlacementHouseId = houseId

    if not houseId then
        FurnitureMenuOpen = false
        Notify(_U("noHouseSelected"), 4000)
        return
    end

    FurnitureMenuOpen = false

    if HandlePlayerDeathAndCloseMenu() then
        return
    end
    local houseFurnitureCount = 0
    if ownershipStatus == 'purchased' then
        local countSuccess, countResult = BccUtils.RPC:CallAsync("bcc-housing:GetHouseFurnitureCount", { houseId = houseId })
        if countSuccess then
            houseFurnitureCount = tonumber(countResult) or 0
        else
            DBG:Info("Failed to fetch furniture count for house ID " .. tostring(houseId))
        end
    end

    local furnitureMainMenu = BCCHousingMenu:RegisterPage("bcc-housing-owned-furniture-menu")

    furnitureMainMenu:RegisterElement('header', {
        value = _U("boughtFurnitureHeader"),
        slot = 'header',
        style = {}
    })

    furnitureMainMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })
    
    if ownershipStatus == 'purchased' then
        furnitureMainMenu:RegisterElement('textdisplay', {
            value = _U("furnitureHouseCount", tostring(houseId), tostring(houseFurnitureCount)),
            slot = 'content',
            style = {}
        })
    end

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

        for idx, item in ipairs(OwnedFurnitureCache) do
            local label = item.displayName or item.model
            if item.category and item.category ~= '' then
                label = label .. " (" .. item.category .. ")"
            end
            label = string.format("%d. %s", idx, label)
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

    furnitureMainMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    furnitureMainMenu:RegisterElement('button', {
        label = _U("sellOwnerFurn"),
        slot = "footer",
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
        DBG:Error("Vendor preview missing category index: " .. tostring(categoryIndex))
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
    local itemPage = BCCHousingMenu:RegisterPage("bcc-housing-furniture-vendor-item-" ..
        categoryIndex .. "-" .. itemIndex)

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

    if VendorPreviewObj then
        itemPage:RegisterElement('arrows', {
            label = _U("vendorRotatePreview"),
            start = VendorPreviewRotationIndex,
            options = VendorRotationOptions,
            persist = true
        }, function(data)
            if not data or not data.value then return end
            local index = data.value.optionIndex
            if not index then return end
            ApplyVendorPreviewRotation(index)
        end)

        itemPage:RegisterElement('line', {
            slot = 'content',
            style = {}
        })
    end

    if vendorCam and DoesCamExist(vendorCam) then
        VendorZoomOptions, VendorPreviewZoomIndex = BuildVendorZoomOptions(VendorPreviewDefaultZoom)
        itemPage:RegisterElement('arrows', {
            label = _U("vendorZoomPreview"),
            start = VendorPreviewZoomIndex,
            options = VendorZoomOptions,
            persist = true
        }, function(data)
            if not data or not data.value then return end
            local index = data.value.optionIndex
            if not index then return end
            ApplyVendorPreviewZoom(index)
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
        DBG:Error("Invalid furniture category index: " .. tostring(categoryIndex))
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

    vendorMenu:RegisterElement('button', {
        label = _U("getFurnitureBook"),
        style = {}
    }, function()
        local success, message = BccUtils.RPC:CallAsync("bcc-housing:GiveFurnitureBook", {})
        if success then
            Notify(message or _U("furnitureBookReceived"), "success", 4000)
        else
            Notify(message or _U("furnitureBookFailed"), "error", 4000)
        end
    end)

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

---------------------------------
-- Placement helpers
---------------------------------

local function HandleFurniturePlaced(placementHouseId, furnObj)
    if not furnObj or not DoesEntityExist(furnObj) then
        DBG:Error("Furniture entity does not exist, could not add to CreatedFurniture.")
        Notify(_U("furnNotPlaced"), "error", 4000)
        return false
    end

    table.insert(CreatedFurniture, furnObj)

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

---------------------------------
-- PROMPTS via PromptsAPI
---------------------------------

-- Create all prompts for furniture placement using PromptsAPI
function StartFurniturePlacementPrompts()
    MoveForwardPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(MoveForwardPrompt, BccUtils.Keys['R'])
    UiPromptSetText(MoveForwardPrompt, CreateVarString(10, 'LITERAL_STRING', _U("forward")))
    UiPromptSetStandardMode(MoveForwardPrompt, true)
    UiPromptSetGroup(MoveForwardPrompt, FurnitureGroup, 0)
    UiPromptRegisterEnd(MoveForwardPrompt)

    MoveBackwardPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(MoveBackwardPrompt, BccUtils.Keys['E'])
    UiPromptSetText(MoveBackwardPrompt, CreateVarString(10, 'LITERAL_STRING', _U("backward")))
    UiPromptSetStandardMode(MoveBackwardPrompt, true)
    UiPromptSetGroup(MoveBackwardPrompt, FurnitureGroup, 0)
    UiPromptRegisterEnd(MoveBackwardPrompt)

    MoveLeftPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(MoveLeftPrompt, BccUtils.Keys['LEFT'])
    UiPromptSetText(MoveLeftPrompt, CreateVarString(10, 'LITERAL_STRING', _U("left")))
    UiPromptSetStandardMode(MoveLeftPrompt, true)
    UiPromptSetGroup(MoveLeftPrompt, FurnitureGroup, 0)
    UiPromptRegisterEnd(MoveLeftPrompt)

    MoveRightPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(MoveRightPrompt, BccUtils.Keys['RIGHT'])
    UiPromptSetText(MoveRightPrompt, CreateVarString(10, 'LITERAL_STRING', _U("right")))
    UiPromptSetStandardMode(MoveRightPrompt, true)
    UiPromptSetGroup(MoveRightPrompt, FurnitureGroup, 0)
    UiPromptRegisterEnd(MoveRightPrompt)

    MoveUpPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(MoveUpPrompt, BccUtils.Keys['UP'])
    UiPromptSetText(MoveUpPrompt, CreateVarString(10, 'LITERAL_STRING', _U("up")))
    UiPromptSetStandardMode(MoveUpPrompt, true)
    UiPromptSetGroup(MoveUpPrompt, FurnitureGroup, 0)
    UiPromptRegisterEnd(MoveUpPrompt)

    MoveDownPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(MoveDownPrompt, BccUtils.Keys['DOWN'])
    UiPromptSetText(MoveDownPrompt, CreateVarString(10, 'LITERAL_STRING', _U("down")))
    UiPromptSetStandardMode(MoveDownPrompt, true)
    UiPromptSetGroup(MoveDownPrompt, FurnitureGroup, 0)
    UiPromptRegisterEnd(MoveDownPrompt)

    RotateYawPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(RotateYawPrompt, BccUtils.Keys['UP'])
    UiPromptSetText(RotateYawPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotateYaw")))
    UiPromptSetStandardMode(RotateYawPrompt, true)
    UiPromptSetGroup(RotateYawPrompt, FurnitureGroup, 1)
    UiPromptRegisterEnd(RotateYawPrompt)

    RotateYawLeftPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(RotateYawLeftPrompt, BccUtils.Keys['DOWN'])
    UiPromptSetText(RotateYawLeftPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotateYawLeft")))
    UiPromptSetStandardMode(RotateYawLeftPrompt, true)
    UiPromptSetGroup(RotateYawLeftPrompt, FurnitureGroup, 1)
    UiPromptRegisterEnd(RotateYawLeftPrompt)

    RotatePitchPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(RotatePitchPrompt, BccUtils.Keys['E'])
    UiPromptSetText(RotatePitchPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotatepitch")))
    UiPromptSetStandardMode(RotatePitchPrompt, true)
    UiPromptSetGroup(RotatePitchPrompt, FurnitureGroup, 1)
    UiPromptRegisterEnd(RotatePitchPrompt)

    RotateBackwardPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(RotateBackwardPrompt, BccUtils.Keys['R'])
    UiPromptSetText(RotateBackwardPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotatebackward")))
    UiPromptSetStandardMode(RotateBackwardPrompt, true)
    UiPromptSetGroup(RotateBackwardPrompt, FurnitureGroup, 1)
    UiPromptRegisterEnd(RotateBackwardPrompt)

    RotateRightPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(RotateRightPrompt, BccUtils.Keys['RIGHT'])
    UiPromptSetText(RotateRightPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotateright")))
    UiPromptSetStandardMode(RotateRightPrompt, true)
    UiPromptSetGroup(RotateRightPrompt, FurnitureGroup, 1)
    UiPromptRegisterEnd(RotateRightPrompt)

    RotateLeftPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(RotateLeftPrompt, BccUtils.Keys['LEFT'])
    UiPromptSetText(RotateLeftPrompt, CreateVarString(10, 'LITERAL_STRING', _U("rotateleft")))
    UiPromptSetStandardMode(RotateLeftPrompt, true)
    UiPromptSetGroup(RotateLeftPrompt, FurnitureGroup, 1)
    UiPromptRegisterEnd(RotateLeftPrompt)

    IncreasePrecisionPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(IncreasePrecisionPrompt, BccUtils.Keys['UP'])
    UiPromptSetText(IncreasePrecisionPrompt, CreateVarString(10, 'LITERAL_STRING', _U("increasePrecision")))
    UiPromptSetStandardMode(IncreasePrecisionPrompt, true)
    UiPromptSetGroup(IncreasePrecisionPrompt, FurnitureGroup, 2)
    UiPromptRegisterEnd(IncreasePrecisionPrompt)

    DecreasePrecisionPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(DecreasePrecisionPrompt, BccUtils.Keys['DOWN'])
    UiPromptSetText(DecreasePrecisionPrompt, CreateVarString(10, 'LITERAL_STRING', _U("decreasePrecision")))
    UiPromptSetStandardMode(DecreasePrecisionPrompt, true)
    UiPromptSetGroup(DecreasePrecisionPrompt, FurnitureGroup, 2)
    UiPromptRegisterEnd(DecreasePrecisionPrompt)

    ConfirmPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(ConfirmPrompt, BccUtils.Keys['SPACEBAR'])
    UiPromptSetText(ConfirmPrompt, CreateVarString(10, 'LITERAL_STRING', _U("confirmPlacement")))
    UiPromptSetStandardMode(ConfirmPrompt, true)
    UiPromptSetGroup(ConfirmPrompt, FurnitureGroup, 3)
    UiPromptRegisterEnd(ConfirmPrompt)

    CancelPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(CancelPrompt, BccUtils.Keys['BACKSPACE'])
    UiPromptSetText(CancelPrompt, CreateVarString(10, 'LITERAL_STRING', _U("cancelPlacement")))
    UiPromptSetStandardMode(CancelPrompt, true)
    UiPromptSetGroup(CancelPrompt, FurnitureGroup, 3)
    UiPromptRegisterEnd(CancelPrompt)
end
---------------------------------
-- Placement logic using prompts
---------------------------------

function PlaceFurnitureIntoWorldPrompt(itemData)
    if not itemData or not itemData.model then
        DBG:Error("Invalid furniture item passed to placement prompt.")
        return
    end

    local model = itemData.model
    local displayName = itemData.displayName or itemData.model
    local sellPrice = itemData.sellprice or 0
    local ownedId = itemData.id

    local playerPed = PlayerPedId()
    local placementCoords = GetEntityCoords(playerPed)
    local modelHash, err = LoadFurnitureModel(model)
    if not modelHash then
        DBG:Error(("Failed to load furniture model %s: %s"):format(tostring(model), tostring(err)))
        Notify(_U("furnNotPlaced"), "error", 4000)
        return
    end

    -- Use BccUtils Objects wrapper, but resolve actual entity for native calls
    local createdWrapper = BccUtils.Objects:Create(
        model,
        placementCoords.x,
        placementCoords.y + 1,
        placementCoords.z,
        false,
        "no_offset"
    )

    DBG:Info("PlaceFurnitureIntoWorldPrompt: object created: " .. (createdWrapper and "success" or "FAILED"))

    if not createdWrapper then
        DBG:Error("Failed to create furniture object wrapper for model: " .. tostring(model))
        Notify(_U("furnNotPlaced"), "error", 4000)
        return
    end

    createdWrapper:PlaceOnGround(true)
    createdWrapper:SetAsMission(true)

    local createdObject = createdWrapper
    if type(createdWrapper) == "table" and createdWrapper.GetObj then
        createdObject = createdWrapper:GetObj()
    end

    if not createdObject or createdObject == 0 or not DoesEntityExist(createdObject) then
        DBG:Error("Failed to resolve entity from furniture object for model: " .. tostring(model))
        Notify(_U("furnNotPlaced"), "error", 4000)
        return
    end

    SetModelAsNoLongerNeeded(modelHash)

    LastPlacementObject = createdObject
    SetEntityCollision(createdObject, false, true)
    TriggerEvent('bcc-housing:CheckIfInRadius', createdObject)
    local amountToMove = 1.0 -- default movement precision

    -- Notify player of controls
    Notify(_U('furnitureControls'), 5000)

    Citizen.CreateThread(function()
        StartFurniturePlacementPrompts()

        local followPlayer = true
        
        while true do
            local ped = PlayerPedId()
            if IsEntityDead(ped) then goto END end

            Citizen.Wait(0)
            UiPromptSetEnabled(ConfirmPrompt, true)
            UiPromptSetEnabled(CancelPrompt, true)
            UiPromptSetActiveGroupThisFrame(FurnitureGroup, CreateVarString(10, 'LITERAL_STRING', _U("movementControls")), 4, 0, 0, 0)
            UiPromptSetEnabled(MoveForwardPrompt, true)
            UiPromptSetEnabled(MoveBackwardPrompt, true)
            UiPromptSetEnabled(MoveLeftPrompt, true)
            UiPromptSetEnabled(MoveRightPrompt, true)
            UiPromptSetEnabled(MoveUpPrompt, true)
            UiPromptSetEnabled(MoveDownPrompt, true)
            UiPromptSetEnabled(RotateYawPrompt, true)
            UiPromptSetEnabled(RotateYawLeftPrompt, true)
            UiPromptSetEnabled(RotatePitchPrompt, true)
            UiPromptSetEnabled(RotateBackwardPrompt, true)
            UiPromptSetEnabled(RotateRightPrompt, true)
            UiPromptSetEnabled(RotateLeftPrompt, true)
            UiPromptSetEnabled(IncreasePrecisionPrompt, true)
            UiPromptSetEnabled(DecreasePrecisionPrompt, true)

            ------------------------------------------------
            -- TEMPORARY FOLLOW: object in front of player
            ------------------------------------------------
            if followPlayer and createdObject and DoesEntityExist(createdObject) then
                local pedCoords  = GetEntityCoords(ped)
                local pedForward = GetEntityForwardVector(ped)
                local offset     = 1.5 -- distance in front of player

                local newX = pedCoords.x + pedForward.x * offset
                local newY = pedCoords.y + pedForward.y * offset

                -- keep same Z as player (no expensive ground probes)
                SetEntityCoordsNoOffset(createdObject, newX, newY, pedCoords.z, false, false, false)
                SetEntityHeading(createdObject, GetEntityHeading(ped))
            end

            ------------------------------------------------
            -- MOVEMENT (TAB 0) – first use breaks follow
            ------------------------------------------------
            local step = amountToMove * 0.1

            if UiPromptHasStandardModeCompleted(MoveForwardPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "forward", step)

            elseif UiPromptHasStandardModeCompleted(MoveBackwardPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "backward", step)

            elseif UiPromptHasStandardModeCompleted(MoveLeftPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "left", step)

            elseif UiPromptHasStandardModeCompleted(MoveRightPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "right", step)

            elseif UiPromptHasStandardModeCompleted(MoveUpPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "up", step)

            elseif UiPromptHasStandardModeCompleted(MoveDownPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "down", step)
            end

            ------------------------------------------------
            -- ROTATION (TAB 1) – also breaks follow
            ------------------------------------------------
            step = amountToMove * 5

            if UiPromptHasStandardModeCompleted(RotateYawPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "rotateYaw", step)

            elseif UiPromptHasStandardModeCompleted(RotateYawLeftPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "rotateYawLeft", step)

            elseif UiPromptHasStandardModeCompleted(RotatePitchPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "rotatepitch", step)

            elseif UiPromptHasStandardModeCompleted(RotateBackwardPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "rotatebackward", step)

            elseif UiPromptHasStandardModeCompleted(RotateRightPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "rotateright", step)

            elseif UiPromptHasStandardModeCompleted(RotateLeftPrompt, 0) then
                followPlayer = false
                MoveFurniture(createdObject, "rotateleft", step)
            end

            ------------------------------------------------
            -- PRECISION (TAB 2) – optional but also breaks follow
            ------------------------------------------------
            if UiPromptHasStandardModeCompleted(IncreasePrecisionPrompt, 0) then
                followPlayer = false
                amountToMove = amountToMove + 0.1
                Notify(_U("movementIncreased") .. amountToMove, 1000)

            elseif UiPromptHasStandardModeCompleted(DecreasePrecisionPrompt, 0) then
                followPlayer = false
                amountToMove = amountToMove - 0.1
                Notify(_U("movementDecreased") .. amountToMove, 1000)
            end

            ------------------------------------------------
            -- CONFIRM (TAB 3)
            ------------------------------------------------
            if UiPromptHasStandardModeCompleted(ConfirmPrompt, 0) then
                SetEntityCollision(createdObject, true, true)
                if ConfirmFurniturePlacement(createdObject, {
                    model       = model,
                    displayName = displayName,
                    sellprice   = sellPrice,
                    ownedId     = ownedId
                }) then
                    FreezeEntityPosition(createdObject, true)
                    ActivePlacementItem = nil
                    LastPlacementObject = nil
                else
                    if createdWrapper and type(createdWrapper) == "table" and createdWrapper.Remove then
                        createdWrapper:Remove()
                    elseif type(createdObject) == "table" and createdObject.Remove then
                        createdObject:Remove()
                    elseif createdObject and createdObject ~= 0 and DoesEntityExist(createdObject) then
                        DeleteObject(createdObject)
                    end
                    ActivePlacementItem = nil
                    LastPlacementObject = nil
                end
                break
            end

            ------------------------------------------------
            -- CANCEL (TAB 3)
            ------------------------------------------------
             if UiPromptHasStandardModeCompleted(CancelPrompt, 0) then
                if createdWrapper and type(createdWrapper) == "table" and createdWrapper.Remove then
                    createdWrapper:Remove()
                elseif type(createdObject) == "table" and createdObject.Remove then
                    createdObject:Remove()
                elseif createdObject and createdObject ~= 0 and DoesEntityExist(createdObject) then
                    DeleteObject(createdObject)
                end
                Notify(_U("placementCanceled"), 4000)
                ActivePlacementItem = nil
                LastPlacementObject = nil
                break
            end

            ::END::
        end

        -- Cleanup prompts after loop ends
        UiPromptDelete(MoveForwardPrompt)
        PromptDelete(MoveBackwardPrompt)
        PromptDelete(MoveLeftPrompt)
        PromptDelete(MoveRightPrompt)
        PromptDelete(MoveUpPrompt)
        PromptDelete(MoveDownPrompt)
        PromptDelete(RotateYawPrompt)
        PromptDelete(RotateYawLeftPrompt)
        PromptDelete(RotatePitchPrompt)
        PromptDelete(RotateBackwardPrompt)
        PromptDelete(RotateRightPrompt)
        PromptDelete(RotateLeftPrompt)
        PromptDelete(IncreasePrecisionPrompt)
        PromptDelete(DecreasePrecisionPrompt)
        PromptDelete(ConfirmPrompt)
        PromptDelete(CancelPrompt)
    end)
end

function MoveFurniture(obj, direction, moveAmount)
    if not obj then return end

    -- handle wrapper or raw entity
    local entity = obj
    if type(obj) == "table" and obj.GetObj then
        entity = obj:GetObj()
    end
    if not entity or entity == 0 or not DoesEntityExist(entity) then return end

    local coords = GetEntityCoords(entity)
    local rot = GetEntityRotation(entity, 2) -- Get rotation in degrees.

    if direction == "forward" then
        SetEntityCoords(entity, coords.x, coords.y + moveAmount, coords.z)
    elseif direction == "backward" then
        SetEntityCoords(entity, coords.x, coords.y - moveAmount, coords.z)
    elseif direction == "left" then
        SetEntityCoords(entity, coords.x - moveAmount, coords.y, coords.z)
    elseif direction == "right" then
        SetEntityCoords(entity, coords.x + moveAmount, coords.y, coords.z)
    elseif direction == "up" then
        SetEntityCoords(entity, coords.x, coords.y, coords.z + moveAmount)
    elseif direction == "down" then
        SetEntityCoords(entity, coords.x, coords.y, coords.z - moveAmount)
    elseif direction == "rotatepitch" then
        SetEntityRotation(entity, rot.x + moveAmount, rot.y, rot.z, 2, true)
    elseif direction == "rotatebackward" then
        SetEntityRotation(entity, rot.x - moveAmount, rot.y, rot.z, 2, true)
    elseif direction == "rotateright" then
        SetEntityRotation(entity, rot.x, rot.y + moveAmount, rot.z, 2, true)
    elseif direction == "rotateleft" then
        SetEntityRotation(entity, rot.x, rot.y - moveAmount, rot.z, 2, true)
    elseif direction == "rotateYaw" then
        SetEntityRotation(entity, rot.x, rot.y, rot.z + moveAmount, 2, true)
    elseif direction == "rotateYawLeft" then
        SetEntityRotation(entity, rot.x, rot.y, rot.z - moveAmount, 2, true)
    end
end

function ConfirmFurniturePlacement(obj, placementContext)
    if not placementContext or not placementContext.ownedId then
        return false
    end

    local placementHouseId = HouseId or ActivePlacementHouseId or ActiveHouseId
    if not placementHouseId then
        Notify(_U("noHouseSelected"), "error", 4000)
        return false
    end
    ActivePlacementHouseId = placementHouseId

    local isClose = closeToHouse(obj)
    if not isClose then
        Notify(_U("toFar"), "error", 4000)
        return false
    end

    -- finalize the object locally
    SetEntityCollision(obj, true, true)
    FreezeEntityPosition(obj, true)

    -- RPC instead of TriggerServerEvent
    local success = BccUtils.RPC:CallAsync("bcc-housing:PlaceOwnedFurniture", {
        ownedId = placementContext.ownedId,
        houseId = placementHouseId,
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

    HandleFurniturePlaced(placementHouseId, obj)
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
    if GetDistanceBetweenCoords(
        tonumber(coords.x), tonumber(coords.y), tonumber(coords.z),
        tonumber(compCoords.x), tonumber(compCoords.y), tonumber(compCoords.z),
        false
    ) <= radius then
        return true
    else
        return false
    end
end

-- Helper function to handle the sale of furniture (implement as needed)
function SellFurniture(furniture)
    DBG:Info("Selling furniture: " .. tostring(furniture.model))
    BccUtils.RPC:CallAsync('bcc-housing:SellFurniture', { furniture = furniture })
end

function SellOwnedFurnitureMenu(houseId, furnTable, ownershipStatus)
    DBG:Info("Opening SellOwnedFurnitureMenu with houseId: " .. tostring(houseId))
    BCCHousingMenu:Close() -- Close any previously opened menus

    if HandlePlayerDeathAndCloseMenu() then
        return
    end

    local sellFurnMenu = BCCHousingMenu:RegisterPage("bcc-housing-sell-furniture-menu")

    sellFurnMenu:RegisterElement('header', {
        value = _U("sellOwnerFurn"),
        slot = 'header',
        style = {}
    })

    if furnTable and #furnTable > 0 then
        for k, v in pairs(furnTable) do
            sellFurnMenu:RegisterElement('button', {
                label = v.displayName .. " - " .. _U("sellFor") .. tostring(v.sellprice),
                style = {}
            }, function()
                local sold = false
                local attempted = false
                for idx, entity in ipairs(CreatedFurniture) do
                    local storedFurnCoord = GetEntityCoords(entity)
                    local dist = Vdist(
                        storedFurnCoord.x, storedFurnCoord.y, storedFurnCoord.z,
                        v.coords.x, v.coords.y, v.coords.z
                    )
                    if dist < 1.0 then
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

    BCCHousingMenu:Open({
        startupPage = sellFurnMenu,
        sound = {
            action = "SELECT",
            soundset = "RDRO_Character_Creator_Sounds"
        }
    })
end

function GetOwnedFurniture(houseId)
    DBG:Info("Requesting furniture for house ID: " .. tostring(houseId))
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
    DBG:Info("Opening Sell Owned Furniture Menu for House ID: " .. tostring(houseId))
    if type(furnTable) == "table" then
        SellOwnedFurnitureMenu(houseId, furnTable, ownershipStatus)
    else
        DBG:Error("SellOwnedFurnMenu: furnTable is not a table")
    end
end)
