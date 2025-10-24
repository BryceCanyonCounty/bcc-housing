local pendingInventoryLimits = {}

-- Event to insert a house into the database when it is created
local function handleCreationDBInsert(src, tpHouse, owner, radius, doors, houseCoords, invLimit, ownerSource, taxAmount, ownershipStatus, cb)
    local cbFn = type(cb) == 'function' and cb or nil
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
    if not tpHouse then
        param = {
            ['charidentifier'] = owner,
            ['radius'] = radius,
            ['doors'] = json.encode(doors),
            ['houseCoords'] = json.encode(houseCoords),
            ['invlimit'] = limitValue,
            ['taxes'] = taxes,
            ['tpInt'] = 0,
            ['tpInstance'] = 0,
            ['uniqueName'] = 'none',
            ['ownershipStatus'] = ownershipStatus,
        }
    else
        param = {
            ['charidentifier'] = owner,
            ['radius'] = radius,
            ['doors'] = 'none',
            ['houseCoords'] = json.encode(houseCoords),
            ['invlimit'] = limitValue,
            ['taxes'] = taxes,
            ['tpInt'] = tpHouse,
            ['tpInstance'] = 52324 + src,
            ['uniqueName'] = 'none',
            ['ownershipStatus'] = ownershipStatus,
        }
    end

    local result = MySQL.query.await('SELECT * FROM bcchousing WHERE charidentifier=@charidentifier', param)
    if #result < Config.Setup.MaxHousePerChar then
        MySQL.insert(
            'INSERT INTO bcchousing ( `charidentifier`,`house_radius_limit`,`doors`,`house_coords`,`invlimit`,`tax_amount`,`tpInt`,`tpInstance`, `uniqueName`, `ownershipStatus`) VALUES ( @charidentifier,@radius,@doors,@houseCoords,@invlimit,@taxes,@tpInt,@tpInstance, @uniqueName, @ownershipStatus )',
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
        if cbFn then cbFn(false, { error = 'max_houses' }) end
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
        cb
    )
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
    handleSetInventoryLimit(src, params and params.invLimit, params and params.houseId, cb)
end)


local function refreshPlayerHouses(targetSource)
    local user = VORPcore.getUser(targetSource)
    if not user then
        devPrint("refreshPlayerHouses: no user for source " .. tostring(targetSource))
        return nil
    end

    local character = user.getUsedCharacter
    if not character or not character.charIdentifier then
        devPrint("refreshPlayerHouses: missing character for source " .. tostring(targetSource))
        return nil
    end

    local charIdentifierString = tostring(character.charIdentifier)
    local charIdentifierNumber = tonumber(character.charIdentifier)

    devPrint("Checking if player owns or has access to a house for character ID: " .. charIdentifierString)

    local result = MySQL.query.await("SELECT * FROM bcchousing", {})
    local accessibleHouses = {}

    if result and #result > 0 then
        for _, v in ipairs(result) do
            local decodedCoords = json.decode(v.house_coords)
            BccUtils.RPC:Notify('bcc-housing:PrivatePropertyCheckHandler', { coords = decodedCoords, radius = v.house_radius_limit }, targetSource)

            local data = {
                id = 'Player_' .. tostring(v.houseid) .. '_bcc-houseinv',
                name = _U("houseInv"),
                limit = tonumber(v.invlimit),
                acceptWeapons = true,
                shared = true,
                ignoreItemStackLimit = true,
                whitelistItems = false,
                UsePermissions = false,
                UseBlackList = false,
                whitelistWeapons = false
            }
            exports.vorp_inventory:registerInventory(data)

            local ownerIdString = tostring(v.charidentifier)
            local ownerIdNumber = tonumber(v.charidentifier)

            if (charIdentifierNumber and ownerIdNumber and charIdentifierNumber == ownerIdNumber) or ownerIdString == charIdentifierString then
                table.insert(accessibleHouses, v.houseid)
                BccUtils.RPC:Notify('bcc-housing:OwnsHouseClientHandler', { house = v, isOwner = true }, targetSource)
            else
                local allowedIdsTable = (v.allowed_ids ~= nil and v.allowed_ids ~= 'none') and json.decode(v.allowed_ids) or nil
                if allowedIdsTable then
                    for _, allowedId in ipairs(allowedIdsTable) do
                        if tostring(allowedId) == charIdentifierString then
                            table.insert(accessibleHouses, v.houseid)
                            BccUtils.RPC:Notify('bcc-housing:OwnsHouseClientHandler', { house = v, isOwner = false }, targetSource)
                            break
                        end
                    end
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
        devPrint("CheckIfHasHouse RPC received invalid target source " .. tostring(targetSource))
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
    devPrint("Opening house inventory for House ID: " .. tostring(houseId) .. " and character ID: " .. tostring(charIdentifier))

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        devPrint("Error: No results found for house ID: " .. tostring(houseId))
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local houseData = result[1]

    local function openInventory()
        exports.vorp_inventory:openInventory(src, 'Player_' .. tostring(houseId) .. '_bcc-houseinv')
        if cb then cb(true) end
    end

    if tostring(houseData.charidentifier) == tostring(charIdentifier) then
        devPrint("Player is the owner of house ID: " .. tostring(houseId))
        openInventory()
        return
    end

    local allowedIds = json.decode(houseData.allowed_ids) or {}
    for _, id in ipairs(allowedIds) do
        if tostring(id) == tostring(charIdentifier) then
            devPrint("Player is allowed to access house ID: " .. tostring(houseId))
            openInventory()
            return
        end
    end

    devPrint("Player does not have access to house inventory: " .. tostring(houseId))
    NotifyClient(src, _U('noAccessToHouse'), 4000, 'error')
    if cb then cb(false, { error = _U('noAccessToHouse') }) end
end)

-- Function to update door access for a specific door ID
function updateDoorAccess(doorId, newId)
    -- Get the door object using the API
    local door = DoorLocksAPI:GetDoorById(doorId)
    if not door then
        devPrint("Door ID " .. tostring(doorId) .. " not found.")
        return
    end

    devPrint("Updating door access for door ID: " .. tostring(doorId) .. " with new ID: " .. tostring(newId))

    -- Get the current allowed IDs
    local allowedIds = door:GetAllowedIds()

    -- Ensure the new ID is not already in the list
    if not table.contains(allowedIds, newId) then
        table.insert(allowedIds, newId)
        -- Update the allowed IDs using the API method
        door:UpdateAllowedIds(allowedIds)
        devPrint("Door access updated successfully for door ID: " .. tostring(doorId))
    else
        devPrint("ID " .. tostring(newId) .. " is already allowed for door ID: " .. tostring(doorId))
    end
end

BccUtils.RPC:Register("bcc-housing:GetDoorsByHouseId", function(params, cb, recSource)
    local houseId = params.houseId
    if not houseId then
        cb(nil) -- Return nil to indicate an invalid house ID
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
    local houseId = params.houseId

    if not houseId then
        cb(nil) -- Invalid parameters
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
    local houseId = params.houseId
    local newDoor = params.newDoor

    if not houseId or not newDoor then
        cb(false) -- Invalid parameters
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

BccUtils.RPC:Register("bcc-housing:GiveAccessToDoor", function(params, cb)
    local doorId = params.doorId
    local userId = params.userId

    devPrint("DEBUG: Received doorId: " .. tostring(doorId) .. ", userId: " .. tostring(userId))

    if not doorId or not userId then
        devPrint("Invalid parameters for GiveAccessToDoor: Door ID or User ID is missing.")
        cb(false)
        return
    end
    local door = DoorLocksAPI:GetDoorById(doorId)
    
    if not door then
        devPrint("Door ID not found in API: " .. tostring(doorId))
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

        devPrint("Access granted to user ID: " .. tostring(userId) .. " for door ID: " .. tostring(doorId))
        cb(true)
    else
        devPrint("User ID: " .. tostring(userId) .. " already has access to door ID: " .. tostring(doorId))
        cb(false)
    end
end)

BccUtils.RPC:Register("bcc-housing:RemoveAccessFromDoor", function(params, cb, recSource)
    local doorId = params.doorId
    local userId = params.userId

    if not doorId or not userId then
        devPrint("Invalid parameters for RemoveAccessFromDoor: Door ID or User ID is missing.")
        cb(false)
        return
    end

    -- Access the DoorLocksAPI
    local door = DoorLocksAPI:GetDoorById(doorId)

    if not door then
        devPrint("Door ID not found in API: " .. tostring(doorId))
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

            devPrint("Access removed for user ID: " .. tostring(userId) .. " from door ID: " .. tostring(doorId))
            cb(true)
            return
        end
    end

    devPrint("User ID: " .. tostring(userId) .. " did not have access to door ID: " .. tostring(doorId))
    cb(false)
end)

BccUtils.RPC:Register("bcc-housing:DeleteDoor", function(params, cb, recSource)
    local doorId = params.doorId

    if not doorId then
        devPrint("Invalid door ID received for deletion.")
        cb(false)
        return
    end

    local door = DoorLocksAPI:GetDoorById(doorId)

    if not door then
        devPrint("Door not found in API for deletion. Door ID: " .. tostring(doorId))
        cb(false)
        return
    end

    -- Delete the door
    door:DeleteDoor()
    devPrint("Door deleted successfully. Door ID: " .. tostring(doorId))
    cb(true)
end)

-- Event to handle ledger updates for houses (both add and remove)
local function handleLedgerHandling(src, amountParam, houseIdParam, isAdding, cb)
    local cbFn = type(cb) == 'function' and cb or nil
    local amountNumber = tonumber(amountParam)
    local houseIdNumber = tonumber(houseIdParam)

    if not amountNumber or not houseIdNumber then
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

    local queryResult = MySQL.query.await('SELECT ledger, tax_amount, ownershipStatus FROM bcchousing WHERE houseid = ?', { houseIdNumber })
    if not queryResult or #queryResult == 0 then
        NotifyClient(src, _U('noHouseFound'), 5000, 'error')
        if cbFn then cbFn(false, { error = 'house_not_found' }) end
        return
    end

    local row = queryResult[1]
    local ledger = tonumber(row.ledger) or 0
    local taxAmount = tonumber(row.tax_amount) or 0
    local ownershipStatus = row.ownershipStatus
    local currency

    if ownershipStatus == 'purchased' then
        currency = 0
    elseif ownershipStatus == 'rented' then
        currency = 1
    else
        devPrint('handleLedgerHandling: Unknown ownershipStatus ' .. tostring(ownershipStatus))
        if cbFn then cbFn(false, { error = 'unknown_status' }) end
        return
    end

    if isAdding then
        local maxInsertAmount = taxAmount - ledger
        if maxInsertAmount <= 0 then
            NotifyClient(src, _U('maxAmountStored'), 5000, 'info')
            if cbFn then cbFn(false, { error = 'ledger_full' }) end
            return
        end

        local insertionAmount = math.min(amountNumber, maxInsertAmount)
        if insertionAmount <= 0 then
            NotifyClient(src, _U('maxAmountStored'), 5000, 'info')
            if cbFn then cbFn(false, { error = 'ledger_full' }) end
            return
        end

        if currency == 0 and character.money < insertionAmount then
            NotifyClient(src, _U('noMoney'), 5000, 'error')
            if cbFn then cbFn(false, { error = 'no_money' }) end
            return
        elseif currency == 1 and character.gold < insertionAmount then
            NotifyClient(src, _U('noGold'), 5000, 'error')
            if cbFn then cbFn(false, { error = 'no_gold' }) end
            return
        end

        character.removeCurrency(currency, insertionAmount)
        local affectedRows = MySQL.update.await('UPDATE bcchousing SET ledger = ledger + ? WHERE houseid = ?', { insertionAmount, houseIdNumber })
        if affectedRows and affectedRows > 0 then
            if ownershipStatus == 'purchased' then
                NotifyClient(src, _U('ledgerAmountInserted') .. ' $' .. insertionAmount, 5000, 'success')
            else
                NotifyClient(src, _U('ledgerGoldAmountInserted') .. insertionAmount, 5000, 'success')
            end
            if cbFn then cbFn(true, { ledgerChange = insertionAmount, action = 'add' }) end
            return
        else
            NotifyClient(src, _U('ledgerUpdateFailed'), 5000, 'error')
            if cbFn then cbFn(false, { error = 'update_failed' }) end
            return
        end
    else
        if ledger < amountNumber then
            NotifyClient(src, _U('notEnoughFunds'), 5000, 'error')
            if cbFn then cbFn(false, { error = 'insufficient_ledger' }) end
            return
        end

        character.addCurrency(currency, amountNumber)
        local affectedRows = MySQL.update.await('UPDATE bcchousing SET ledger = ledger - ? WHERE houseid = ?', { amountNumber, houseIdNumber })
        if affectedRows and affectedRows > 0 then
            if ownershipStatus == 'purchased' then
                NotifyClient(src, _U('ledgerAmountRemoved') .. ' $' .. amountNumber, 5000, 'success')
            else
                NotifyClient(src, _U('ledgerGoldAmountRemoved') .. amountNumber, 5000, 'success')
            end
            if cbFn then cbFn(true, { ledgerChange = amountNumber, action = 'remove' }) end
            return
        else
            NotifyClient(src, _U('ledgerUpdateFailed'), 5000, 'error')
            if cbFn then cbFn(false, { error = 'update_failed' }) end
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

    devPrint('Checking ledger for house ID: ' .. tostring(houseId))
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
    devPrint(("getHouseId RPC invoked with charidentifier %s for House ID %s"):format(tostring(charIdentifier), tostring(houseId)))

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = ?", { houseId })
    if not result or #result == 0 then
        devPrint("Error: No results found for house ID: " .. tostring(houseId))
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local houseData = result[1]
    local isOwner = tostring(houseData.charidentifier) == tostring(charIdentifier)
    local hasAccess = isOwner

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
        devPrint("Player does not have access to the house ID: " .. tostring(houseId))
        if cb then cb(false, { error = _U('noAccessToHouse') }) end
        return
    end

    if (context == 'access' or context == 'removeAccess') and not isOwner then
        if cb then cb(false, { error = _U('noAccessToHouse') }) end
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
    devPrint(("getHouseOwner RPC invoked with charidentifier %s for House ID %s"):format(tostring(charIdentifier), tostring(houseId)))

    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid = @houseid", { ['@houseid'] = houseId })
    if not result or #result == 0 then
        devPrint("Error: No results found for house ID: " .. tostring(houseId))
        if cb then cb(false, { error = _U('noHouseFound') }) end
        return
    end

    local houseData = result[1]
    local isOwner = tostring(houseData.charidentifier) == tostring(charIdentifier)

    if cb then
        cb(true, {
            houseId = houseId,
            isOwner = isOwner,
            ownershipStatus = houseData.ownershipStatus
        })
    end
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
