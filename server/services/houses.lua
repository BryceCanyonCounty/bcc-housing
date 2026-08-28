local pendingInventoryLimits = {}

local function encodePolyPoints(points)
    if type(points) ~= 'table' or #points < 3 then
        return nil
    end

    local normalized = {}
    for _, point in ipairs(points) do
        local x = point.x or point[1]
        local y = point.y or point[2]
        if x and y then
            local z = point.z or point[3]
            local normalizedPoint = {
                x = tonumber(x) or 0.0,
                y = tonumber(y) or 0.0
            }
            if z then
                normalizedPoint.z = tonumber(z) or 0.0
            end
            normalized[#normalized + 1] = normalizedPoint
        end
    end

    if #normalized < 3 then
        return nil
    end

    return json.encode(normalized)
end

local function decodePolyPoints(payload)
    if not payload or payload == '' or payload == 'null' then
        return nil
    end

    local decoded = payload
    if type(payload) == 'string' then
        decoded = json.decode(payload)
    end

    if type(decoded) ~= 'table' or #decoded < 3 then
        return nil
    end

    local normalized = {}
    for _, point in ipairs(decoded) do
        local x = point.x or point[1]
        local y = point.y or point[2]
        if x and y then
            local z = point.z or point[3]
            local normalizedPoint = {
                x = tonumber(x) or 0.0,
                y = tonumber(y) or 0.0
            }
            if z then
                normalizedPoint.z = tonumber(z) or 0.0
            end
            normalized[#normalized + 1] = normalizedPoint
        end
    end

    if #normalized < 3 then
        return nil
    end

    return normalized
end

local function getHouseInventoryId(houseId, ownershipStatus)
    local suffix = ownershipStatus == 'rented' and '_bcc-houseinv_rent' or '_bcc-houseinv'
    return 'Player_' .. tostring(houseId) .. suffix
end

local function getStageBonus(stage)
    local bonus = 0
    if ConfigHousingInventory and ConfigHousingInventory.stages then
        for _, cfg in ipairs(ConfigHousingInventory.stages) do
            if stage >= (cfg.stage or 0) then
                bonus = bonus + (cfg.slotIncrease or 0)
            end
        end
    end
    return bonus
end

local function getNextInventoryStage(currentStage)
    if not ConfigHousingInventory or not ConfigHousingInventory.stages then return nil end

    for _, cfg in ipairs(ConfigHousingInventory.stages) do
        if (cfg.stage or 0) > currentStage then
            return cfg
        end
    end

    return nil
end

local function calculateBaseInventoryLimit(invLimit, ownershipStatus)
    local baseLimit = tonumber(invLimit) or 200
    if ownershipStatus == 'rented' then
        local multiplier = tonumber(Config.Setup.RentedInventoryLimitMultiplier) or 1
        local computedLimit = math.floor(baseLimit * multiplier)
        if computedLimit <= 0 then
            computedLimit = baseLimit
        end
        baseLimit = math.min(baseLimit, computedLimit)
    end
    return baseLimit
end

local function calculateFinalInventoryLimit(invLimit, ownershipStatus, stage)
    local currentStage = tonumber(stage) or 0
    local baseLimit = calculateBaseInventoryLimit(invLimit, ownershipStatus)
    local bonus = getStageBonus(currentStage)
    return baseLimit + bonus, baseLimit, bonus
end

local function formatPurchasedAt(value)
    if not value or value == '' then
        return nil
    end

    local timestamp = tonumber(value)
    if timestamp then
        if timestamp > 9999999999 then
            timestamp = math.floor(timestamp / 1000)
        end

        return os.date("%Y-%m-%d %H:%M", timestamp)
    end

    return tostring(value):sub(1, 16)
end

local function ensureHouseInventoryRegistered(houseId, houseData, forcedLimit)
    if not houseData then return end

    local finalLimit = forcedLimit
    if not finalLimit then
        finalLimit = select(1, calculateFinalInventoryLimit(houseData.invlimit, houseData.ownershipStatus, houseData.inventory_current_stage))
    end

    local inventoryId = getHouseInventoryId(houseId, houseData.ownershipStatus)
    if not exports.vorp_inventory:isCustomInventoryRegistered(inventoryId) then
        exports.vorp_inventory:registerInventory({
            id = inventoryId,
            name = _U("houseInv"),
            limit = finalLimit,
            acceptWeapons = true,
            shared = true,
            ignoreItemStackLimit = true,
            whitelistItems = false,
            UsePermissions = false,
            UseBlackList = false,
            whitelistWeapons = false
        })
    end

    pcall(function()
        exports.vorp_inventory:updateCustomInventorySlots(inventoryId, finalLimit)
    end)

    return inventoryId, finalLimit
end

-- Event to insert a house into the database when it is created
local function handleCreationDBInsert(src, tpHouse, owner, radius, doors, houseCoords, invLimit, ownerSource, taxAmount, ownershipStatus, polyPoints, polyMinZ, polyMaxZ, purchaseCurrencyType, cb)
    local cbFn = type(cb) == 'function' and cb or nil
    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cbFn then cbFn(false) end
        return
    end

    local taxesValue = tonumber(taxAmount)
    local taxes = (taxesValue and taxesValue > 0) and taxesValue or 0

    local user = VORPcore.getUser(src)
    if not user then
        if cbFn then cbFn(false, { error = 'no_user' }) end
        return
    end

    local character = user.getUsedCharacter
    if not character then
        if cbFn then cbFn(false, { error = 'no_character' }) end
        return
    end

    local limitValue = tonumber(invLimit) or (pendingInventoryLimits[src] and tonumber(pendingInventoryLimits[src].invLimit))
    if not limitValue then
        limitValue = invLimit
    end

    local param
    local numericRadius = tonumber(radius) or 0
    local encodedPolyPoints = encodePolyPoints(polyPoints)
    if not tpHouse then
        param = {
            ['charidentifier'] = owner,
            ['radius'] = numericRadius,
            ['doors'] = json.encode(doors),
            ['houseCoords'] = json.encode(houseCoords),
            ['invlimit'] = limitValue,
            ['taxes'] = taxes,
            ['tpInt'] = 0,
            ['tpInstance'] = 0,
            ['uniqueName'] = 'none',
            ['ownershipStatus'] = ownershipStatus,
            ['purchaseCurrencyType'] = tonumber(purchaseCurrencyType) or 0,
            ['polyPoints'] = encodedPolyPoints,
            ['polyMinZ'] = tonumber(polyMinZ),
            ['polyMaxZ'] = tonumber(polyMaxZ),
        }
    else
        param = {
            ['charidentifier'] = owner,
            ['radius'] = numericRadius,
            ['doors'] = 'none',
            ['houseCoords'] = json.encode(houseCoords),
            ['invlimit'] = limitValue,
            ['taxes'] = taxes,
            ['tpInt'] = tpHouse,
            ['tpInstance'] = 52324 + src,
            ['uniqueName'] = 'none',
            ['ownershipStatus'] = ownershipStatus,
            ['purchaseCurrencyType'] = tonumber(purchaseCurrencyType) or 0,
            ['polyPoints'] = encodedPolyPoints,
            ['polyMinZ'] = tonumber(polyMinZ),
            ['polyMaxZ'] = tonumber(polyMaxZ),
        }
    end

    local result = MySQL.query.await('SELECT * FROM bcchousing WHERE charidentifier=@charidentifier', param)
    if #result < Config.Setup.MaxHousePerChar then
        MySQL.insert(
            'INSERT INTO bcchousing ( `charidentifier`,`house_radius_limit`,`doors`,`house_coords`,`invlimit`,`tax_amount`,`tpInt`,`tpInstance`, `uniqueName`, `ownershipStatus`, `purchaseCurrencyType`, `poly_points`, `poly_min_z`, `poly_max_z`, `purchased_at`) VALUES ( @charidentifier,@radius,@doors,@houseCoords,@invlimit,@taxes,@tpInt,@tpInstance, @uniqueName, @ownershipStatus, @purchaseCurrencyType, @polyPoints, @polyMinZ, @polyMaxZ, NOW() )',
            param
        )

        Discord:sendMessage(_U('houseCreatedWebhook') ..
            tostring(character.charIdentifier) .. _U('houseCreatedWebhookGivenToo') .. tostring(owner))

        Wait(1500)

        if ownerSource ~= nil then
            BccUtils.RPC:Notify('bcc-housing:ClientRecHouseLoad', {}, ownerSource)
        end

        pendingInventoryLimits[src] = nil

        if cbFn then cbFn(true) end
    else
        NotifyClient(src, _U('maxHousesReached'), 4000, 'error')
        pendingInventoryLimits[src] = nil
        if cbFn then cbFn(false) end
    end
end

BccUtils.RPC:Register('bcc-housing:CreationDBInsert', function(params, cb, src)
    handleCreationDBInsert(
        src,
        params and params.tpHouse,
        params and params.owner,
        params and params.radius,
        params and params.doors,
        params and params.houseCoords,
        params and params.invLimit,
        params and params.ownerSource,
        params and params.taxAmount,
        params and params.ownershipStatus,
        params and params.polyPoints,
        params and params.polyMinZ,
        params and params.polyMaxZ,
        params and params.purchaseCurrencyType,
        cb
    )
end)

BccUtils.RPC:Register('bcc-housing:SaveExistingHousePolyZone', function(params, cb, src)
    local houseId = tonumber(params and params.houseId)
    local polyPoints = params and params.polyPoints
    local polyMinZ = tonumber(params and params.polyMinZ)
    local polyMaxZ = tonumber(params and params.polyMaxZ)

    if not houseId then
        if cb then cb(false, { error = 'invalid_house' }) end
        return
    end

    local user = VORPcore.getUser(src)
    local character = user and user.getUsedCharacter
    local allowed = character and character.group == Config.adminGroup

    if not allowed then
        for _, jobCfg in ipairs(Config.ALlowedJobs or {}) do
            if character and character.job == jobCfg.jobname then
                allowed = true
                break
            end
        end
    end

    if not allowed then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local encodedPolyPoints = encodePolyPoints(polyPoints)
    if not encodedPolyPoints then
        if cb then cb(false, { error = 'invalid_poly' }) end
        return
    end

    local affectedRows = MySQL.update.await(
        'UPDATE bcchousing SET poly_points = ?, poly_min_z = ?, poly_max_z = ? WHERE houseid = ?',
        { encodedPolyPoints, polyMinZ, polyMaxZ, houseId }
    )

    if not affectedRows or affectedRows <= 0 then
        if cb then cb(false, { error = 'update_failed' }) end
        return
    end

    if cb then
        cb(true, {
            houseId = houseId,
            polyPoints = decodePolyPoints(encodedPolyPoints),
            polyMinZ = polyMinZ,
            polyMaxZ = polyMaxZ
        })
    end
end)

local function handleSetInventoryLimit(src, invLimitParam, houseIdParam, cb)
    local cbFn = type(cb) == 'function' and cb or nil
    local invLimitValue = tonumber(invLimitParam)

    if not invLimitValue or invLimitValue <= 0 then
        if cbFn then cbFn(false, { error = 'invalid_inv_limit' }) end
        return
    end

    pendingInventoryLimits[src] = { invLimit = invLimitValue, houseId = houseIdParam }
    if cbFn then cbFn(true, { invLimit = invLimitValue, houseId = houseIdParam }) end
end

BccUtils.RPC:Register('bcc-housing:SetInventoryLimit', function(params, cb, src)
    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    handleSetInventoryLimit(src, params and params.invLimit, params and params.houseId, cb)
end)


local function refreshPlayerHouses(targetSource)
    local user = VORPcore.getUser(targetSource)
    if not user then
        DBG:Info("refreshPlayerHouses: no user for source " .. tostring(targetSource))
        return nil
    end

    local character = user.getUsedCharacter
    if not character or not character.charIdentifier then
        DBG:Info("refreshPlayerHouses: missing character for source " .. tostring(targetSource))
        return nil
    end

    local charIdentifierString = tostring(character.charIdentifier)
    local charIdentifierNumber = tonumber(character.charIdentifier)

    DBG:Info("Checking if player owns or has access to a house for character ID: " .. charIdentifierString)

    local result = MySQL.query.await("SELECT * FROM bcchousing", {})
    local accessibleHouses = {}

    if result and #result > 0 then
        for _, v in ipairs(result) do
            v.purchased_at_formatted = formatPurchasedAt(v.purchased_at)
            local decodedCoords = json.decode(v.house_coords)
            local ownerIdString = tostring(v.charidentifier)
            local ownerIdNumber = tonumber(v.charidentifier)
            local hasAccessToProperty = (charIdentifierNumber and ownerIdNumber and charIdentifierNumber == ownerIdNumber) or ownerIdString == charIdentifierString

            if not hasAccessToProperty then
                local allowedIdsTable = (v.allowed_ids ~= nil and v.allowed_ids ~= 'none') and json.decode(v.allowed_ids) or nil
                if allowedIdsTable then
                    for _, allowedId in ipairs(allowedIdsTable) do
                        if tostring(allowedId) == charIdentifierString then
                            hasAccessToProperty = true
                            break
                        end
                    end
                end
            end

            BccUtils.RPC:Notify('bcc-housing:PrivatePropertyCheckHandler', {
                coords = decodedCoords,
                radius = v.house_radius_limit,
                houseid = v.houseid,
                polyPoints = decodePolyPoints(v.poly_points),
                polyMinZ = tonumber(v.poly_min_z),
                polyMaxZ = tonumber(v.poly_max_z),
                hasAccess = hasAccessToProperty
            }, targetSource)

            local currentStage = tonumber(v.inventory_current_stage) or 0
            local finalLimit = select(1, calculateFinalInventoryLimit(v.invlimit, v.ownershipStatus, currentStage))
            ensureHouseInventoryRegistered(v.houseid, v, finalLimit)

            if (charIdentifierNumber and ownerIdNumber and charIdentifierNumber == ownerIdNumber) or ownerIdString == charIdentifierString then
                table.insert(accessibleHouses, v.houseid)
                
                -- ✅ Notify player they own this house and show the ID
                BccUtils.RPC:Notify('bcc-housing:OwnsHouseClientHandler', { house = v, isOwner = true }, targetSource)
                BccUtils.RPC:Notify('bcc-housing:ShowMessage', { message = "You own house ID: " .. tostring(v.houseid) }, targetSource)
                DBG:Info("Player " .. charIdentifierString .. " owns house ID: " .. tostring(v.houseid))
            else
                if hasAccessToProperty then
                    table.insert(accessibleHouses, v.houseid)
                    BccUtils.RPC:Notify('bcc-housing:OwnsHouseClientHandler', { house = v, isOwner = false }, targetSource)
                end
            end
        end
    end

    BccUtils.RPC:Notify('bcc-housing:ReceiveAccessibleHouses', { houses = accessibleHouses }, targetSource)
    return accessibleHouses
end

BccUtils.RPC:Register('bcc-housing:CheckIfHasHouse', function(params, cb, src)
    local targetSource = params and params.targetSource
    if targetSource and GetPlayerName(targetSource) == nil then
        DBG:Info("CheckIfHasHouse RPC received invalid target source " .. tostring(targetSource))
        if cb then cb(false, { error = 'invalid_target' }) end
        return
    end

    local accessible = refreshPlayerHouses(targetSource or src)
    if not accessible then
        if cb then cb(false, { error = 'no_character' }) end
        return
    end

    if cb then
        if targetSource and targetSource ~= src then
            cb(true)
        else
            cb(true, accessible)
        end
    end
end)


-- Event to open the house inventory
BccUtils.RPC:Register('bcc-house:OpenHouseInv', function(params, cb, src)
    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local character = user.getUsedCharacter
    if not character then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local charIdentifier = character.charIdentifier
    DBG:Info("Opening house inventory for House ID: " .. tostring(houseId) .. " and character ID: " .. tostring(charIdentifier))

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        DBG:Error("Error: No results found for house ID: " .. tostring(houseId))
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local houseData = result[1]
    local taxStatus = tostring(houseData.taxes_collected)
    if taxStatus == 'overdue' or taxStatus == 'released' then
        NotifyClient(src, _U("taxesOverdue"), 5000, 'error')
        if cb then cb(false, { error = _U("taxesOverdue"), taxesOverdue = taxStatus == 'overdue', taxPaymentReleased = taxStatus == 'released' }) end
        return
    end

    local finalLimit = select(1, calculateFinalInventoryLimit(houseData.invlimit, houseData.ownershipStatus, houseData.inventory_current_stage))
    local inventoryId = ensureHouseInventoryRegistered(houseId, houseData, finalLimit)

    local function openInventory()
        exports.vorp_inventory:openInventory(src, inventoryId)
        if cb then cb(true) end
    end

    if tostring(houseData.charidentifier) == tostring(charIdentifier) then
        DBG:Info("Player is the owner of house ID: " .. tostring(houseId))
        openInventory()
        return
    end

    local allowedIds = json.decode(houseData.allowed_ids) or {}
    for _, id in ipairs(allowedIds) do
        if tostring(id) == tostring(charIdentifier) then
            DBG:Info("Player is allowed to access house ID: " .. tostring(houseId))
            openInventory()
            return
        end
    end

    DBG:Info("Player does not have access to house inventory: " .. tostring(houseId))
    NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
    if cb then cb(false) end
end)

BccUtils.RPC:Register('bcc-house:AdminOpenHouseInv', function(params, cb, src)
    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    if not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local houseData = result[1]
    local finalLimit = select(1, calculateFinalInventoryLimit(houseData.invlimit, houseData.ownershipStatus, houseData.inventory_current_stage))
    local inventoryId = ensureHouseInventoryRegistered(houseId, houseData, finalLimit)
    exports.vorp_inventory:openInventory(src, inventoryId)

    if cb then cb(true) end
end)

BccUtils.RPC:Register('bcc-housing:GetInventoryStages', function(params, cb, src)
    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local result = MySQL.query.await("SELECT invlimit, ownershipStatus, taxes_collected, charidentifier, inventory_current_stage FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local user = VORPcore.getUser(src)
    local character = user and user.getUsedCharacter
    local charIdentifier = character and character.charIdentifier

    local row = result[1]
    local taxStatus = tostring(row.taxes_collected)
    if taxStatus == 'overdue' or taxStatus == 'released' then
        if cb then cb(false, { error = _U("taxesOverdue"), taxesOverdue = taxStatus == 'overdue', taxPaymentReleased = taxStatus == 'released' }) end
        return
    end

    local currentStage = tonumber(row.inventory_current_stage) or 0
    local finalLimit, baseLimit, bonus = calculateFinalInventoryLimit(row.invlimit, row.ownershipStatus, currentStage)
    local nextStage = getNextInventoryStage(currentStage)

    if cb then
        cb(true, {
            inventory_current_stage = currentStage,
            nextStage = nextStage or false,
            finalLimit = finalLimit,
            baseLimit = baseLimit,
            bonus = bonus,
            isOwner = charIdentifier and tostring(row.charidentifier) == tostring(charIdentifier) or false
        })
    end
end)

BccUtils.RPC:Register('bcc-housing:UpgradeInventory', function(params, cb, src)
    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false, { error = 'no_user' }) end
        return
    end

    local character = user.getUsedCharacter
    if not character then
        if cb then cb(false, { error = 'no_character' }) end
        return
    end

    local result = MySQL.query.await("SELECT invlimit, ownershipStatus, charidentifier, inventory_current_stage FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local row = result[1]
    if tostring(row.charidentifier) ~= tostring(character.charIdentifier) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local currentStage = tonumber(row.inventory_current_stage) or 0
    local nextStage = getNextInventoryStage(currentStage)
    if not nextStage or tonumber(nextStage.stage) ~= tonumber(params and params.nextStage or 0) then
        if cb then cb(false, { error = 'invalid_stage' }) end
        return
    end

    local stageCost = tonumber(nextStage.cost) or 0
    if character.money < stageCost then
        if cb then cb(false, { error = 'notEnoughCash' }) end
        return
    end

    character.removeCurrency(0, stageCost)
    MySQL.update.await("UPDATE bcchousing SET inventory_current_stage = ? WHERE houseid = ?", { nextStage.stage, houseId })

    local finalLimit = select(1, calculateFinalInventoryLimit(row.invlimit, row.ownershipStatus, nextStage.stage))
    ensureHouseInventoryRegistered(houseId, {
        invlimit = row.invlimit,
        ownershipStatus = row.ownershipStatus,
        inventory_current_stage = nextStage.stage
    }, finalLimit)

    if cb then
        cb(true, {
            newStage = nextStage.stage,
            finalLimit = finalLimit
        })
    end
end)

-- Function to update door access for a specific door ID
function updateDoorAccess(doorId, newId)
    -- Get the door object using the API
    local door = DoorLocksAPI:GetDoorById(doorId)
    if not door then
        DBG:Info("Door ID " .. tostring(doorId) .. " not found.")
        return
    end

    DBG:Info("Updating door access for door ID: " .. tostring(doorId) .. " with new ID: " .. tostring(newId))

    -- Get the current allowed IDs
    local allowedIds = door:GetAllowedIds()

    -- Ensure the new ID is not already in the list
    if not table.contains(allowedIds, newId) then
        table.insert(allowedIds, newId)
        -- Update the allowed IDs using the API method
        door:UpdateAllowedIds(allowedIds)
        DBG:Info("Door access updated successfully for door ID: " .. tostring(doorId))
    else
        DBG:Info("ID " .. tostring(newId) .. " is already allowed for door ID: " .. tostring(doorId))
    end
end

BccUtils.RPC:Register("bcc-housing:GetDoorsByHouseId", function(params, cb, recSource)
    local houseId = params and params.houseId
    if not houseId then
        cb(nil) -- Return nil to indicate an invalid house ID
        return
    end
    if not IsHouseOwner(recSource, houseId) and not IsHousingAdmin(recSource) then
        NotifyClient(recSource, _U('noAccessToHouse'), 4000, 'error')
        cb(nil)
        return
    end

    -- Fetch the doors JSON for the given house ID from bcchousing
    local houseResult = MySQL.query.await("SELECT doors FROM bcchousing WHERE houseid = ?", { houseId })

    if houseResult and #houseResult > 0 then
        local houseDoors = json.decode(houseResult[1].doors or "[]")

        -- Validate each door ID by checking if it exists in the doorlocks table
        local validDoors = {}
        for _, doorId in ipairs(houseDoors) do
            local door = DoorLocksAPI:GetDoorById(doorId)
            if door then
                table.insert(validDoors, {
                    doorid = door.id,
                    doorinfo = door:GetDoorInfo()
                })
            end            
        end

        cb(validDoors) -- Return the valid doors
    else
        cb({}) -- Return an empty table if no doors are found in bcchousing
    end
end)

BccUtils.RPC:Register("bcc-housing:GetAllowedIdsForHouse", function(params, cb, recSource)
    local houseId = params and params.houseId

    if not houseId then
        cb(nil) -- Invalid parameters
        return
    end
    if not IsHouseOwner(recSource, houseId) and not IsHousingAdmin(recSource) then
        NotifyClient(recSource, _U('noAccessToHouse'), 4000, 'error')
        cb(nil)
        return
    end

    -- Fetch allowed IDs for the house
    local result = MySQL.query.await("SELECT allowed_ids FROM bcchousing WHERE houseid = ?", { houseId })

    if result and #result > 0 then
        local allowedIds = json.decode(result[1].allowed_ids or "[]")
        cb(allowedIds) -- Return allowed IDs
    else
        cb(nil) -- No house or allowed IDs found
    end
end)

-- Register the RPC for adding a door to a house
BccUtils.RPC:Register("bcc-housing:AddDoorToHouse", function(params, cb, recSource)
    local houseId = params and params.houseId
    local newDoor = params and params.newDoor

    if not houseId or not newDoor then
        cb(false) -- Invalid parameters
        return
    end

    if not IsHouseOwner(recSource, houseId) and not IsHousingAdmin(recSource) then
        NotifyClient(recSource, _U('noAccessToHouse'), 4000, 'error')
        cb(false)
        return
    end

    -- Fetch the current doors for the specified house
    local result = MySQL.query.await("SELECT doors FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        cb(false) -- House not found
        return
    end

    -- Decode the current doors or initialize an empty table
    local currentDoors = json.decode(result[1].doors or "[]")

    -- Add the new door to the list
    table.insert(currentDoors, newDoor)

    -- Update the doors in the database
    local updatedDoors = json.encode(currentDoors)
    local success = MySQL.query.await("UPDATE bcchousing SET doors = ? WHERE houseid = ?", { updatedDoors, houseId })

    if success then
        cb(true) -- Door added successfully
    else
        cb(false) -- Failed to update the database
    end
end)

BccUtils.RPC:Register("bcc-housing:GiveAccessToDoor", function(params, cb, src)
    local doorId = params and params.doorId
    local userId = params and params.userId

    DBG:Info("DEBUG: Received doorId: " .. tostring(doorId) .. ", userId: " .. tostring(userId))

    if not doorId or not userId then
        DBG:Warning("Invalid parameters for GiveAccessToDoor: Door ID or User ID is missing.")
        cb(false)
        return
    end
    if not IsDoorOwnedByCharacter(src, doorId) and not IsHousingAdmin(src) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        cb(false)
        return
    end
    local door = DoorLocksAPI:GetDoorById(doorId)
    
    if not door then
        DBG:Info("Door ID not found in API: " .. tostring(doorId))
        cb(false)
        return
    end

    -- Fetch current allowed IDs using the API
    local idsAllowed = DoorLocksAPI:GetDoorById(doorId):GetAllowedIds()

    -- Check if the user already has access
    if not table.contains(idsAllowed, userId) then
        table.insert(idsAllowed, userId)

        -- Update the allowed IDs for the door using the API
        DoorLocksAPI:GetDoorById(doorId):UpdateAllowedIds(idsAllowed)

        DBG:Info("Access granted to user ID: " .. tostring(userId) .. " for door ID: " .. tostring(doorId))
        cb(true)
    else
        DBG:Info("User ID: " .. tostring(userId) .. " already has access to door ID: " .. tostring(doorId))
        cb(false)
    end
end)

BccUtils.RPC:Register("bcc-housing:RemoveAccessFromDoor", function(params, cb, recSource)
    local doorId = params and params.doorId
    local userId = params and params.userId

    if not doorId or not userId then
        DBG:Warning("Invalid parameters for RemoveAccessFromDoor: Door ID or User ID is missing.")
        cb(false)
        return
    end
    if not IsDoorOwnedByCharacter(recSource, doorId) and not IsHousingAdmin(recSource) then
        NotifyClient(recSource, _U('noAccessToHouse'), 4000, 'error')
        cb(false)
        return
    end

    -- Access the DoorLocksAPI
    local door = DoorLocksAPI:GetDoorById(doorId)

    if not door then
        DBG:Info("Door ID not found in API: " .. tostring(doorId))
        cb(false)
        return
    end

    -- Fetch current allowed IDs using the API
    local idsAllowed = door:GetAllowedIds()

    -- Check if the user has access
    for index, allowedId in ipairs(idsAllowed) do
        if allowedId == userId then
            table.remove(idsAllowed, index)

            -- Update the allowed IDs for the door using the API
            door:UpdateAllowedIds(idsAllowed)

            DBG:Info("Access removed for user ID: " .. tostring(userId) .. " from door ID: " .. tostring(doorId))
            cb(true)
            return
        end
    end

    DBG:Info("User ID: " .. tostring(userId) .. " did not have access to door ID: " .. tostring(doorId))
    cb(false)
end)

BccUtils.RPC:Register("bcc-housing:DeleteDoor", function(params, cb, recSource)
    local doorId = params and params.doorId

    if not doorId then
        DBG:Warning("Invalid door ID received for deletion.")
        cb(false)
        return
    end
    if not IsDoorOwnedByCharacter(recSource, doorId) and not IsHousingAdmin(recSource) then
        NotifyClient(recSource, _U('noAccessToHouse'), 4000, 'error')
        cb(false)
        return
    end

    local door = DoorLocksAPI:GetDoorById(doorId)

    if not door then
        DBG:Info("Door not found in API for deletion. Door ID: " .. tostring(doorId))
        cb(false)
        return
    end

    -- Delete the door
    door:DeleteDoor()
    DBG:Info("Door deleted successfully. Door ID: " .. tostring(doorId))
    cb(true)
end)

-- Event to handle ledger updates for houses (both add and remove)
local function handleLedgerHandling(src, amountParam, houseIdParam, isAdding, cb)
    local cbFn = type(cb) == 'function' and cb or nil
    local amountNumber = tonumber(amountParam)
    local houseIdNumber = tonumber(houseIdParam)

    if not amountNumber or amountNumber <= 0 or not houseIdNumber then
        if cbFn then cbFn(false, { error = 'invalid_params' }) end
        return
    end

    local user = VORPcore.getUser(src)
    if not user then
        if cbFn then cbFn(false, { error = 'no_user' }) end
        return
    end

    local character = user.getUsedCharacter
    if not character then
        if cbFn then cbFn(false, { error = 'no_character' }) end
        return
    end

    local queryResult = MySQL.query.await('SELECT ledger, tax_amount, taxes_collected, ownershipStatus, uniqueName, charidentifier, purchaseCurrencyType FROM bcchousing WHERE houseid = ?', { houseIdNumber })
    if not queryResult or #queryResult == 0 then
        NotifyClient(src, _U('noHouseFound'), 5000, 'error')
        if cbFn then cbFn(false) end
        return
    end

    local row = queryResult[1]
    if tostring(row.charidentifier) ~= tostring(character.charIdentifier) then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cbFn then cbFn(false) end
        return
    end
    local ledger = tonumber(row.ledger) or 0
    local taxAmount = tonumber(row.tax_amount) or 0
    local ownershipStatus = row.ownershipStatus
    local currency = tonumber(row.purchaseCurrencyType) or 0
    local uniqueName = row.uniqueName

    if ownershipStatus ~= 'purchased' and ownershipStatus ~= 'rented' then
        DBG:Info('handleLedgerHandling: Unknown ownershipStatus ' .. tostring(ownershipStatus))
        if cbFn then cbFn(false, { error = 'unknown_status' }) end
        return
    end

    if uniqueName then
        for _, house in pairs(Houses) do
            if house.uniqueName == uniqueName then
                local houseCurrency = tonumber(house.currencyType)
                if houseCurrency ~= 0 and houseCurrency ~= 1 and houseCurrency ~= 2 then
                    houseCurrency = nil
                end

                if ownershipStatus == 'rented' then
                    houseCurrency = houseCurrency or tonumber(Config.Setup.DefaultRentalCurrency) or 1
                    if houseCurrency ~= 0 and houseCurrency ~= 1 and houseCurrency ~= 2 then
                        houseCurrency = 1
                    end
                else
                    houseCurrency = houseCurrency or 0
                end

                if row.purchaseCurrencyType == nil then
                    currency = houseCurrency
                end
                break
            end
        end
    end

    if ownershipStatus == 'rented' and currency == 0 and (not uniqueName or uniqueName == 'none') then
        local defaultRentalCurrency = tonumber(Config.Setup.DefaultRentalCurrency) or 1
        if defaultRentalCurrency ~= 0 and defaultRentalCurrency ~= 1 and defaultRentalCurrency ~= 2 then
            defaultRentalCurrency = 1
        end
        currency = defaultRentalCurrency
    end

    if isAdding then
        local taxStatus = tostring(row.taxes_collected)
        local isReleasedForPayment = taxStatus == 'released'

        if taxStatus == 'overdue' then
            NotifyClient(src, _U('overdueDiscordContact'), 7000, 'error')
            if cbFn then cbFn(false) end
            return
        end

        local maxInsertAmount = taxAmount - ledger
        if maxInsertAmount <= 0 then
            NotifyClient(src, _U('maxAmountStored'), 5000, 'info')
            if cbFn then cbFn(false) end
            return
        end

        local insertionAmount = math.min(amountNumber, maxInsertAmount)
        if insertionAmount <= 0 then
            NotifyClient(src, _U('maxAmountStored'), 5000, 'info')
            if cbFn then cbFn(false) end
            return
        end

        if currency == 0 and character.money < insertionAmount then
            NotifyClient(src, _U('noMoney'), 5000, 'error')
            if cbFn then cbFn(false) end
            return
        elseif currency == 1 and character.gold < insertionAmount then
            NotifyClient(src, _U('noGold'), 5000, 'error')
            if cbFn then cbFn(false) end
            return
        elseif currency == 2 and (tonumber(character.rol) or 0) < insertionAmount then
            NotifyClient(src, _U('noRol'), 5000, 'error')
            if cbFn then cbFn(false) end
            return
        end

        character.removeCurrency(currency, insertionAmount)

        local affectedRows
        local taxesPaid = false
        if isReleasedForPayment and (ledger + insertionAmount) >= taxAmount then
            local remainingLedger = math.max((ledger + insertionAmount) - taxAmount, 0)
            affectedRows = MySQL.update.await(
                'UPDATE bcchousing SET ledger = ?, taxes_collected = ? WHERE houseid = ? AND charidentifier = ?',
                { remainingLedger, 'true', houseIdNumber, character.charIdentifier }
            )
            taxesPaid = true
        else
            affectedRows = MySQL.update.await(
                'UPDATE bcchousing SET ledger = ledger + ? WHERE houseid = ? AND charidentifier = ? AND ledger + ? <= tax_amount',
                { insertionAmount, houseIdNumber, character.charIdentifier, insertionAmount }
            )
        end

        if affectedRows and affectedRows > 0 then
            if currency == 0 then
                NotifyClient(src, _U('ledgerAmountInserted') .. ' $' .. insertionAmount, 5000, 'success')
            elseif currency == 1 then
                NotifyClient(src, _U('ledgerGoldAmountInserted') .. insertionAmount, 5000, 'success')
            else
                NotifyClient(src, _U('ledgerRolAmountInserted') .. insertionAmount, 5000, 'success')
            end
            if cbFn then cbFn(true, {
                ledgerChange = insertionAmount,
                action = 'add',
                taxesPaid = taxesPaid
            }) end
            return
        else
            character.addCurrency(currency, insertionAmount)
            NotifyClient(src, _U('ledgerUpdateFailed'), 5000, 'error')
            if cbFn then cbFn(false) end
            return
        end
    else
        if ledger < amountNumber then
            NotifyClient(src, _U('notEnoughFunds'), 5000, 'error')
            if cbFn then cbFn(false) end
            return
        end

        local affectedRows = MySQL.update.await(
            'UPDATE bcchousing SET ledger = ledger - ? WHERE houseid = ? AND charidentifier = ? AND ledger >= ?',
            { amountNumber, houseIdNumber, character.charIdentifier, amountNumber }
        )
        if affectedRows and affectedRows > 0 then
            character.addCurrency(currency, amountNumber)
            if currency == 0 then
                NotifyClient(src, _U('ledgerAmountRemoved') .. ' $' .. amountNumber, 5000, 'success')
            elseif currency == 1 then
                NotifyClient(src, _U('ledgerGoldAmountRemoved') .. amountNumber, 5000, 'success')
            else
                NotifyClient(src, _U('ledgerRolAmountRemoved') .. amountNumber, 5000, 'success')
            end
            if cbFn then cbFn(true, { ledgerChange = amountNumber, action = 'remove' }) end
            return
        else
            NotifyClient(src, _U('ledgerUpdateFailed'), 5000, 'error')
            if cbFn then cbFn(false) end
            return
        end
    end
end

BccUtils.RPC:Register('bcc-housing:LedgerHandling', function(params, cb, src)
    handleLedgerHandling(
        src,
        params and params.amount,
        params and params.houseid,
        params and params.isAdding,
        cb
    )
end)


local function handleCheckLedger(src, houseIdParam, cb)
    local cbFn = type(cb) == 'function' and cb or nil
    local houseId = tonumber(houseIdParam)
    if not houseId then
        if cbFn then cbFn(false, { error = 'invalid_house' }) end
        return
    end

    DBG:Info('Checking ledger for house ID: ' .. tostring(houseId))
    local result = MySQL.query.await('SELECT ledger, tax_amount FROM bcchousing WHERE houseid=@houseid', { ['houseid'] = houseId })
    if result and #result > 0 then
        NotifyClient(src, tostring(result[1].ledger) .. '/' .. tostring(result[1].tax_amount), 5000, 'info')
        if cbFn then cbFn(true, { ledger = tonumber(result[1].ledger) or 0, taxAmount = tonumber(result[1].tax_amount) or 0 }) end
    else
        if cbFn then cbFn(false, { error = 'house_not_found' }) end
    end
end

BccUtils.RPC:Register('bcc-housing:CheckLedger', function(params, cb, src)
    handleCheckLedger(src, params and params.houseid, cb)
end)


BccUtils.RPC:Register('bcc-housing:getHouseId', function(params, cb, src)
    local context = params and params.context
    local houseId = params and params.houseId

    if not context or not houseId then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local character = user.getUsedCharacter
    if not character then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local charIdentifier = character.charIdentifier
    DBG:Info(("getHouseId RPC invoked with charidentifier %s for House ID %s"):format(tostring(charIdentifier), tostring(houseId)))

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        DBG:Error("Error: No results found for house ID: " .. tostring(houseId))
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local houseData = result[1]
    local ownerCharId = tostring(houseData.charidentifier)
    local isOwner = ownerCharId == tostring(charIdentifier)
    local hasAccess = isOwner

    if context == 'access' or context == 'removeAccess' then
        DBG:Info(("[ACCESS CMD] charidentifier %s targeting house %s | owner charidentifier %s | isOwner: %s"):format(
            tostring(charIdentifier), tostring(houseId), ownerCharId, tostring(isOwner)))
    else
        DBG:Info(("[HOUSE CMD] context %s | charidentifier %s | house %s | owner charidentifier %s | isOwner: %s"):format(
            tostring(context), tostring(charIdentifier), tostring(houseId), ownerCharId, tostring(isOwner)))
    end

    if not hasAccess then
        local allowedIds = json.decode(houseData.allowed_ids) or {}
        for _, id in ipairs(allowedIds) do
            if tostring(id) == tostring(charIdentifier) then
                hasAccess = true
                break
            end
        end
    end

    if not hasAccess then
        DBG:Info("Player does not have access to the house ID: " .. tostring(houseId))
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    if (context == 'access' or context == 'removeAccess') and not isOwner then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    if cb then
        cb(true, {
            houseId = houseId,
            context = context,
            ownershipStatus = houseData.ownershipStatus,
            isOwner = isOwner
        })
    end
end)

BccUtils.RPC:Register('bcc-housing:getHouseOwner', function(params, cb, src)
    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local character = user.getUsedCharacter
    if not character then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local charIdentifier = character.charIdentifier
    DBG:Info(("getHouseOwner RPC invoked with charidentifier %s for House ID %s"):format(tostring(charIdentifier), tostring(houseId)))

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId })
    if not result or #result == 0 then
        DBG:Error("Error: No results found for house ID: " .. tostring(houseId))
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local houseData = result[1]
    local isOwner = tostring(houseData.charidentifier) == tostring(charIdentifier)
    local taxStatus = tostring(houseData.taxes_collected)
    local taxesOverdue = taxStatus == 'overdue'
    local taxPaymentReleased = taxStatus == 'released'

    if cb then
        cb(true, {
            houseId = houseId,
            isOwner = isOwner,
            ownershipStatus = houseData.ownershipStatus,
            taxesOverdue = taxesOverdue,
            taxPaymentReleased = taxPaymentReleased
        })
    end
end)

BccUtils.RPC:Register('bcc-housing:GetHouseContext', function(params, cb, src)
    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local user = VORPcore.getUser(src)
    if not user then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local character = user.getUsedCharacter
    if not character then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local charIdentifier = tostring(character.charIdentifier)
    local result = MySQL.query.await(
        "SELECT house_coords, house_radius_limit, tpInt, tpInstance, ownershipStatus, taxes_collected, purchased_at, charidentifier, allowed_ids, poly_points, poly_min_z, poly_max_z FROM bcchousing WHERE houseid = ?",
        { houseId })

    if not result or #result == 0 then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local row = result[1]
    local taxStatus = tostring(row.taxes_collected)
    if taxStatus == 'overdue' or taxStatus == 'released' then
        if cb then cb(false, { error = _U("taxesOverdue"), taxesOverdue = taxStatus == 'overdue', taxPaymentReleased = taxStatus == 'released' }) end
        return
    end

    local ownerIdentifier = tostring(row.charidentifier or '')
    local hasAccess = ownerIdentifier == charIdentifier

    if not hasAccess then
        local allowedIds = {}
        if row.allowed_ids and row.allowed_ids ~= '' then
            local decoded = json.decode(row.allowed_ids)
            if type(decoded) == "table" then
                allowedIds = decoded
            end
        end

        for _, allowed in ipairs(allowedIds) do
            if tostring(allowed) == charIdentifier then
                hasAccess = true
                break
            end
        end
    end

    if not hasAccess then
        NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
        if cb then cb(false) end
        return
    end

    local coords = row.house_coords and json.decode(row.house_coords) or nil
    if not coords or not coords.x then
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local context = {
        coords = coords,
        radius = tonumber(row.house_radius_limit),
        polyPoints = decodePolyPoints(row.poly_points),
        polyMinZ = tonumber(row.poly_min_z),
        polyMaxZ = tonumber(row.poly_max_z),
        houseId = tonumber(houseId),
        ownershipStatus = row.ownershipStatus,
        purchasedAt = row.purchased_at,
        purchasedAtFormatted = formatPurchasedAt(row.purchased_at),
        tpInt = row.tpInt ~= 0 and row.tpInt or nil,
        tpInstance = row.tpInstance
    }

    if cb then cb(true, context) end
end)

BccUtils.RPC:Register('bcc-housing:CheckIfHouseExists', function(params, cb, src)
    local houseId = params and params.houseId
    if not houseId then
        if cb then cb(false, { exists = false, houseId = nil }) end
        return
    end

    local result = MySQL.query.await('SELECT houseid FROM bcchousing WHERE houseid = ?', { houseId })
    local exists = result and #result > 0

    if cb then cb(true, { exists = exists, houseId = houseId }) end
end)
