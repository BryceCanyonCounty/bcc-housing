
-- Event to handle the selling of a house
local function findHouseConfigByUniqueName(uniqueName)
    for _, config in pairs(Houses) do
        if config.uniqueName == uniqueName then
            return config
        end
    end
    return nil
end

local function handleSellHouse(src, houseIdParam, cb)
    local cbFn = type(cb) == 'function' and cb or nil
    local houseId = tonumber(houseIdParam)
    if not houseId then
        devPrint('handleSellHouse received invalid houseId: ' .. tostring(houseIdParam))
        if cbFn then cbFn(false, { error = 'invalid_house' }) end
        return
    end

    local user = VORPcore.getUser(src)
    if not user then
        devPrint('handleSellHouse: no VORP user for source ' .. tostring(src))
        if cbFn then cbFn(false, { error = 'no_user' }) end
        return
    end

    local character = user.getUsedCharacter
    if not character then
        devPrint('handleSellHouse: no character for source ' .. tostring(src))
        if cbFn then cbFn(false, { error = 'no_character' }) end
        return
    end

    local charIdentifier = character.charIdentifier
    devPrint(('Sell house request for houseId %s by charIdentifier %s'):format(tostring(houseId), tostring(charIdentifier)))

    MySQL.query('SELECT * FROM bcchousing WHERE houseid = ?', { houseId }, function(result)
        if not result or #result == 0 then
            devPrint('handleSellHouse: house not found for id ' .. tostring(houseId))
            if cbFn then cbFn(false, { error = 'house_not_found' }) end
            return
        end

        local houseData = result[1]
        if houseData.ownershipStatus ~= 'purchased' then
            devPrint('handleSellHouse: house is not purchased, cannot be sold')
            NotifyClient(src, _U('rentedHouseCannotBeSold'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'not_purchased' }) end
            return
        end

        if tostring(houseData.charidentifier) ~= tostring(charIdentifier) then
            devPrint('handleSellHouse: player does not own house ' .. tostring(houseId))
            NotifyClient(src, _U('noHouseOrNotOwner'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'not_owner' }) end
            return
        end

        local houseConfig = findHouseConfigByUniqueName(houseData.uniqueName)
        if not houseConfig then
            devPrint('handleSellHouse: config not found for uniqueName ' .. tostring(houseData.uniqueName))
            NotifyClient(src, _U('houseCannotBeSold'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'config_missing' }) end
            return
        end

        if not houseConfig.canSell then
            devPrint('handleSellHouse: house cannot be sold per config')
            NotifyClient(src, _U('houseCannotBeSold'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'cannot_sell' }) end
            return
        end

        local sellPrice = tonumber(houseConfig.sellPrice) or 0
        MySQL.update('DELETE FROM bcchousing WHERE houseid = ?', { houseData.houseid })

        if houseData.doors and houseData.doors ~= 'none' then
            local decodeOk, doorIdsJson = pcall(json.decode, houseData.doors)
            if decodeOk and type(doorIdsJson) == 'table' then
                for _, doorId in ipairs(doorIdsJson) do
                    MySQL.update('DELETE FROM doorlocks WHERE doorid = ?', { doorId })
                end
            end
        end

        local params = {
            ['@houseid'] = houseData.houseid,
            ['@identifier'] = charIdentifier,
            ['@amount'] = sellPrice
        }
        MySQL.insert('INSERT INTO bcchousing_transactions (houseid, identifier, amount) VALUES (@houseid, @identifier, @amount)', params)

        NotifyClient(src, _U('houseSoldSuccess', sellPrice), 4000, 'success')
        Discord:sendMessage('House sold by charIdentifier: ' .. tostring(charIdentifier) .. '\nHouse ID: ' .. tostring(houseId) .. ' was sold for $' .. tostring(sellPrice))

        local coords = houseConfig.menuCoords or {}
        local coordsPayload = {
            x = coords.x or 0.0,
            y = coords.y or 0.0,
            z = coords.z or 0.0
        }

        BccUtils.RPC:Notify('bcc-housing:showCollectMoneyPrompt', { coords = coordsPayload, houseId = houseId, amount = sellPrice }, src)
        BccUtils.RPC:Notify('bcc-housing:OwnsHouseClientHandler', { house = houseData, isOwner = false}, src)
        BccUtils.RPC:Notify('bcc-housing:StopPropertyCheck', {}, src)
        BccUtils.RPC:Notify('bcc-housing:clearBlips', { houseId = houseId }, src)
        BccUtils.RPC:Notify('bcc-housing:ReinitializeChecksAfterSale', {}, src)

        if cbFn then cbFn(true, { amount = sellPrice }) end
    end)
end

BccUtils.RPC:Register('bcc-housing:sellHouse', function(params, cb, src)
    handleSellHouse(src, params and params.houseId, cb)
end)


-- Sell House With Inventory
local function handleSellHouseToPlayerWithInventory(src, houseIdParam, targetPlayerIdParam, salePriceParam, cb)
    local cbFn = type(cb) == 'function' and cb or nil
    local houseId = tonumber(houseIdParam)
    local targetPlayerId = tonumber(targetPlayerIdParam)
    local salePrice = tonumber(salePriceParam)

    if not houseId then
        NotifyClient(src, 'Invalid house ID.', 4000, 'error')
        if cbFn then cbFn(false, { error = 'invalid_house' }) end
        return
    end

    if not targetPlayerId or not GetPlayerName(targetPlayerId) then
        NotifyClient(src, 'Target player not found.', 4000, 'error')
        if cbFn then cbFn(false, { error = 'target_not_found' }) end
        return
    end

    if not salePrice or salePrice <= 0 then
        NotifyClient(src, 'Invalid sale price.', 4000, 'error')
        if cbFn then cbFn(false, { error = 'invalid_price' }) end
        return
    end

    local user = VORPcore.getUser(src)
    local targetUser = VORPcore.getUser(targetPlayerId)
    if not user or not targetUser then
        NotifyClient(src, _U('houseNotOwnedOrExist'), 4000, 'error')
        if cbFn then cbFn(false, { error = 'user_missing' }) end
        return
    end

    local character = user.getUsedCharacter
    local targetCharacter = targetUser.getUsedCharacter
    if not character or not targetCharacter then
        if cbFn then cbFn(false, { error = 'character_missing' }) end
        return
    end

    local charIdentifier = character.charIdentifier
    local targetCharIdentifier = targetCharacter.charIdentifier

    MySQL.query('SELECT * FROM bcchousing WHERE houseid = ? AND charidentifier = ?', { houseId, charIdentifier }, function(result)
        if not result or #result == 0 then
            NotifyClient(src, _U('houseNotOwnedOrExist'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'house_not_owned' }) end
            return
        end

        local ownedByTarget = MySQL.query.await('SELECT * FROM bcchousing WHERE charidentifier = ?', { targetCharIdentifier })
        if #ownedByTarget >= Config.Setup.MaxHousePerChar then
            NotifyClient(src, _U('buyerMaxHouses'), 4000, 'error')
            NotifyClient(targetPlayerId, _U('maxHouses'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'buyer_house_limit' }) end
            return
        end

        if targetCharacter.money < salePrice then
            NotifyClient(src, _U('buyerNoMoney'), 4000, 'error')
            NotifyClient(targetPlayerId, _U('notEnoughMoney'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'buyer_no_money' }) end
            return
        end

        targetCharacter.removeCurrency(0, salePrice)

        local affectedRows = MySQL.update.await(
            'UPDATE bcchousing SET charidentifier = ? WHERE houseid = ?',
            { targetCharIdentifier, houseId }
        )

        if affectedRows == 0 then
            devPrint('handleSellHouseToPlayerWithInventory: failed to update houseId ' .. tostring(houseId))
            if cbFn then cbFn(false, { error = 'update_failed' }) end
            return
        end

        local params = {
            ['@houseid'] = houseId,
            ['@identifier'] = charIdentifier,
            ['@amount'] = salePrice
        }
        MySQL.insert('INSERT INTO bcchousing_transactions (houseid, identifier, amount) VALUES (@houseid, @identifier, @amount)', params)

        NotifyClient(src, _U('houseSoldSuccess', salePrice), 4000, 'success')
        NotifyClient(targetPlayerId, _U('housePurchasedSuccess', salePrice), 4000, 'success')

        BccUtils.RPC:Notify('bcc-housing:ClientRecHouseLoad', {}, targetPlayerId)
        BccUtils.RPC:Notify('bcc-housing:ClientRecHouseLoad', {}, src)

        Discord:sendMessage('House ID: ' ..
            tostring(houseId) ..
            ' was sold with inventory by charIdentifier: ' ..
            tostring(charIdentifier) ..
            ' to charIdentifier: ' .. tostring(targetCharIdentifier) .. ' for $' .. tostring(salePrice))

        if cbFn then cbFn(true, { amount = salePrice }) end
    end)
end

BccUtils.RPC:Register('bcc-housing:sellHouseToPlayerWithInventory', function(params, cb, src)
    handleSellHouseToPlayerWithInventory(
        src,
        params and params.houseId,
        params and params.targetPlayerId,
        params and params.salePrice,
        cb
    )
end)


-- Sell House Without Inventory
local function handleSellHouseToPlayerWithoutInventory(src, houseIdParam, targetPlayerIdParam, salePriceParam, cb)
    local cbFn = type(cb) == 'function' and cb or nil
    local houseId = tonumber(houseIdParam)
    local targetPlayerId = tonumber(targetPlayerIdParam)
    local salePrice = tonumber(salePriceParam)

    if not houseId then
        NotifyClient(src, 'Invalid house ID.', 4000, 'error')
        if cbFn then cbFn(false, { error = 'invalid_house' }) end
        return
    end

    if not targetPlayerId or not GetPlayerName(targetPlayerId) then
        NotifyClient(src, 'Target player not found.', 4000, 'error')
        if cbFn then cbFn(false, { error = 'target_not_found' }) end
        return
    end

    if not salePrice or salePrice <= 0 then
        NotifyClient(src, 'Invalid sale price.', 4000, 'error')
        if cbFn then cbFn(false, { error = 'invalid_price' }) end
        return
    end

    local user = VORPcore.getUser(src)
    local targetUser = VORPcore.getUser(targetPlayerId)
    if not user or not targetUser then
        NotifyClient(src, _U('noHouseOrNotOwner'), 4000, 'error')
        if cbFn then cbFn(false, { error = 'user_missing' }) end
        return
    end

    local character = user.getUsedCharacter
    local targetCharacter = targetUser.getUsedCharacter
    if not character or not targetCharacter then
        if cbFn then cbFn(false, { error = 'character_missing' }) end
        return
    end

    local charIdentifier = character.charIdentifier
    local targetCharIdentifier = targetCharacter.charIdentifier

    MySQL.query('SELECT * FROM bcchousing WHERE houseid = ? AND charidentifier = ?', { houseId, charIdentifier }, function(result)
        if not result or #result == 0 then
            NotifyClient(src, _U('noHouseOrNotOwner'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'house_not_owned' }) end
            return
        end

        local ownedByTarget = MySQL.query.await('SELECT * FROM bcchousing WHERE charidentifier = ?', { targetCharIdentifier })
        if #ownedByTarget >= Config.Setup.MaxHousePerChar then
            NotifyClient(src, _U('buyerMaxHouses'), 4000, 'error')
            NotifyClient(targetPlayerId, _U('maxHouses'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'buyer_house_limit' }) end
            return
        end

        if targetCharacter.money < salePrice then
            NotifyClient(src, _U('buyerNoMoney'), 4000, 'error')
            NotifyClient(targetPlayerId, _U('noMoneyToBuyHouse'), 4000, 'error')
            if cbFn then cbFn(false, { error = 'buyer_no_money' }) end
            return
        end

        targetCharacter.removeCurrency(0, salePrice)

        local affectedRows = MySQL.update.await(
            'UPDATE bcchousing SET charidentifier = ?, furniture = "none", doors = "none" WHERE houseid = ?',
            { targetCharIdentifier, houseId }
        )

        if affectedRows == 0 then
            devPrint('handleSellHouseToPlayerWithoutInventory: failed to update houseId ' .. tostring(houseId))
            if cbFn then cbFn(false, { error = 'update_failed' }) end
            return
        end

        local params = {
            ['@houseid'] = houseId,
            ['@identifier'] = charIdentifier,
            ['@amount'] = salePrice
        }
        MySQL.insert('INSERT INTO bcchousing_transactions (houseid, identifier, amount) VALUES (@houseid, @identifier, @amount)', params)

        NotifyClient(src, _U('houseSoldWithoutInventory', salePrice), 4000, 'success')
        NotifyClient(targetPlayerId, _U('housePurchasedWithoutInventory', salePrice), 4000, 'success')

        BccUtils.RPC:Notify('bcc-housing:ClientRecHouseLoad', {}, targetPlayerId)
        BccUtils.RPC:Notify('bcc-housing:ClientRecHouseLoad', {}, src)

        Discord:sendMessage('House ID: ' ..
            tostring(houseId) ..
            ' was sold without inventory by charIdentifier: ' ..
            tostring(charIdentifier) ..
            ' to charIdentifier: ' .. tostring(targetCharIdentifier) .. ' for $' .. tostring(salePrice))

        if cbFn then cbFn(true, { amount = salePrice }) end
    end)
end

BccUtils.RPC:Register('bcc-housing:sellHouseToPlayerWithoutInventory', function(params, cb, src)
    handleSellHouseToPlayerWithoutInventory(
        src,
        params and params.houseId,
        params and params.targetPlayerId,
        params and params.salePrice,
        cb
    )
end)

BccUtils.RPC:Register('bcc-housing:RequestSoldHouses', function(params, cb, src)
    local user = VORPcore.getUser(src)
    if not user then return cb(false) end

    local character = user.getUsedCharacter
    local charId = character.charIdentifier
    local soldHouses = {}

    local result = MySQL.query.await('SELECT * FROM `bcchousing_transactions` WHERE `identifier` = ?', { charId })
    if result and #result > 0 then
        for _, house in ipairs(result) do
            soldHouses[#soldHouses + 1] = {
                houseId = house.houseid,
                amount = house.amount
            }
        end
    end

    cb(soldHouses)
end)

-- Event to collect house sale money from an NPC
local function handleCollectHouseSaleMoney(src, cb)
    local cbFn = type(cb) == 'function' and cb or nil
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

    local charIdentifier = character.charIdentifier
    local transactions = MySQL.query.await('SELECT * FROM bcchousing_transactions WHERE identifier = ?', { charIdentifier })

    if transactions and #transactions > 0 then
        local totalAmount = 0
        for _, transaction in ipairs(transactions) do
            totalAmount = totalAmount + (tonumber(transaction.amount) or 0)
        end

        if totalAmount > 0 then
            character.addCurrency(0, totalAmount)
        end

        MySQL.update('DELETE FROM bcchousing_transactions WHERE identifier = ?', { charIdentifier })

        NotifyClient(src, _U('collectedHouseSalesMoney', totalAmount), 4000, 'success')
        Discord:sendMessage('House sale money collected by charIdentifier: ' ..
            tostring(charIdentifier) .. '\nCollected $' .. tostring(totalAmount) .. ' from house sales.')

        if cbFn then cbFn(true, { amount = totalAmount }) end
    else
        NotifyClient(src, _U('noMoneyToCollect'), 4000, 'error')
        if cbFn then cbFn(false, { error = 'no_transactions' }) end
    end
end

BccUtils.RPC:Register('bcc-housing:collectHouseSaleMoneyFromNpc', function(_, cb, src)
    handleCollectHouseSaleMoney(src, cb)
end)
