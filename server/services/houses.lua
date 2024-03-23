---- House Creation DB Insert ----
RegisterServerEvent('bcc-housing:CreationDBInsert', function(tpHouse, owner, radius, doors, houseCoords, invLimit, ownerSource, taxAmount)
    local _source = source
    local taxes
    if tonumber(taxAmount) > 0 then
      taxes = tonumber(taxAmount)
    else
      taxes = 0
    end
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = nil
    if not tpHouse then
      param = { ['charidentifier'] = owner, ['radius'] = radius, ["doors"] = json.encode(doors), ['houseCoords'] = json.encode(houseCoords), ['invlimit'] = invLimit, ['taxes'] = taxes, ['tpInt'] = 0, ['tpInstance'] = 0 }
    else
      param = { ['charidentifier'] = owner, ['radius'] = radius, ['doors'] = 'none', ['houseCoords'] = json.encode(houseCoords), ['invlimit'] = invLimit, ['taxes'] = taxes, ['tpInt'] = tpHouse, ['tpInstance'] = 52324 + _source }
    end
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE charidentifier=@charidentifier", param)
    if #result < Config.Setup.MaxHousePerChar then
      exports.oxmysql:execute("INSERT INTO bcchousing ( `charidentifier`,`house_radius_limit`,`doors`,`house_coords`,`invlimit`,`tax_amount`,`tpInt`,`tpInstance` ) VALUES ( @charidentifier,@radius,@doors,@houseCoords,@invlimit,@taxes,@tpInt,@tpInstance )", param)
      Discord:sendMessage(_U("houseCreatedWebhook") .. tostring(character.charIdentifier), _U("houseCreatedWebhookGivenToo") .. tostring(owner))
      Wait(1500)
      if ownerSource ~= nil then
        TriggerClientEvent('bcc-housing:ClientRecHouseLoad', ownerSource)
      end
    else
      VORPcore.NotifyRightTip(_source, _U("maxHousesReached"), 4000)
    end
end)

---- Checking If player owns house, or has access to a house ----
RegisterServerEvent('bcc-housing:CheckIfHasHouse', function(passedSource)
    local _source
    if passedSource ~= nil then
      _source = tonumber(passedSource)
    else
      _source = source
    end
    local character = VORPcore.getUser(_source).getUsedCharacter
  
    ----- Owner Check -----
    exports.oxmysql:execute("SELECT * FROM bcchousing", function(result)
      if #result > 0 then
        for k, v in pairs(result) do
          VORPInv.removeInventory('Player_' .. v.houseid .. '_bcc-houseinv')
          Wait(50)
          VORPInv.registerInventory('Player_' .. v.houseid .. '_bcc-houseinv', _U("houseInv"), tonumber(v.invlimit), true, true, true)
          if character.charIdentifier == tonumber(v.charidentifier) then
            TriggerClientEvent('bcc-housing:OwnsHouseClientHandler', _source, v, true)
          else
            local allowed_idsTable = json.decode(v.allowed_ids)
            if allowed_idsTable then
              for y, e in pairs(allowed_idsTable) do
                if character.charIdentifier == tonumber(e) then
                  TriggerClientEvent('bcc-housing:OwnsHouseClientHandler', _source, v, false)
                end
              end
            end
          end
        end
      end
    end)
end)

---- Handling a new player given access to home ----
RegisterServerEvent('bcc-housing:NewPlayerGivenAccess', function(id, houseid, recSource)
    local param = { ['newid'] = id, ['houseid'] = houseid }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    local exists = false
    if #result >= 1 then
      if result[1].allowed_ids == 'none' then
        local param2 = { ['allowedids'] = json.encode({id}), ['houseid'] = houseid }
        exports.oxmysql:execute("UPDATE bcchousing SET allowed_ids=@allowedids WHERE houseid=@houseid", param2)
        Wait(1500)
        if recSource ~= nil then
          TriggerClientEvent('bcc-housing:ClientRecHouseLoad', tonumber(recSource), recSource)
        end
      else
        local idsTable = json.decode(result[1].allowed_ids)
        for k, v in pairs(idsTable) do
          if id == v then
            exists = true
          else
            table.insert(idsTable, {id})
          end
        end
        if not exists then
          local param2 = { ['allowedids'] = json.encode(idsTable), ['houseid'] = houseid }
          exports.oxmysql:execute("UPDATE bcchousing SET allowed_ids=@allowedids WHERE houseid=@houseid", param2)
          Wait(1500)
          if recSource ~= nil then
            TriggerClientEvent('bcc-housing:ClientRecHouseLoad', tonumber(recSource), recSource)
          end
        end
      end
    end
  
    for k, v in pairs(json.decode(result[1].doors)) do
      local param2 = { ['doorId'] = v }
      local result2 = MySQL.query.await("SELECT * FROM doorlocks WHERE doorid=@doorId", param2)
      if string.len(result2[1].ids_allowed) == 2 then -- Thanks to Apo, this gets however many characters are in this string allowing us to check if the json entry is empty '[]' or has character '[2,3]'
        local param3 = { ['allowedid'] = json.encode({id}), ['doorId'] = v }
        exports.oxmysql:execute("UPDATE doorlocks SET ids_allowed=@allowedid WHERE doorid=@doorId", param3)
      else
        local allowedIdTable = json.decode(result2[1].ids_allowed)
        for p, e in pairs(allowedIdTable) do
          if id == e then break
          else
            table.insert(allowedIdTable, id)
            local param3 = { ['allowedIds'] = json.encode(allowedIdTable), ['doorId'] = v }
            exports.oxmysql:execute("UPDATE doorlocks SET ids_allowed=@allowedIds WHERE doorid=@doorId", param3)
          end
        end
      end
    end
end)

RegisterServerEvent('bcc-house:OpenHouseInv', function(houseid) --event to open the houses inventory
    local _source = source
    VORPInv.OpenInv(_source, 'Player_' .. houseid .. '_bcc-houseinv')
end)
  
RegisterServerEvent('bcc-housing:InsertFurnitureIntoDB', function(furnTable, houseId) --Inserting new furniture into db
    local param = { ['houseid'] = houseId }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if result[1].furniture == 'none' then
      local param2 = { ['houseid'] = houseId, ['furn'] = json.encode({furnTable}) } --wrapping it in a table inside the json encode so it can be a proper table to be looped over
      exports.oxmysql:execute("UPDATE bcchousing SET furniture=@furn WHERE houseid=@houseid", param2)
    else
      --add new table to old table
      local oldFurn = json.decode(result[1].furniture)
      table.insert(oldFurn, furnTable)
      local param2 = { ['houseid'] = houseId, ['furn'] = json.encode(oldFurn) }
      exports.oxmysql:execute("UPDATE bcchousing SET furniture=@furn WHERE houseid=@houseid", param2)
    end
end)
  
  ------ Keeping track of if the furniture is spawned for a house or note ----
local storedFurn = {}
RegisterServerEvent('bcc-housing:FurniturePlacedCheck', function(houseid, deletion, close)
    local _source = source
    local param = { ['houseid'] = houseid, ['source'] = tostring(_source) }
  
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if result[1] then
      if result[1].player_source_spawnedfurn == 'none' and close then
        if result[1].furniture ~= 'none' then
          local furn = json.decode(result[1].furniture)
          TriggerClientEvent('bcc-housing:SpawnFurnitureEvent', _source, furn)
          exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn=@source", param)
        end
      elseif tonumber(result[1].player_source_spawnedfurn) == _source then
        if deletion then
          DelSpawnedFurn(_source)
        end
      end
    end
end)
  
RegisterServerEvent('bcc-housing:StoreFurnForDeletion', function(entId, houseid) --this is used to store the entity id of each piece of furniture in the table for when it is deleted
    local _source = source
    if storedFurn[_source] == nil then
      storedFurn[_source] = {}
      local param = { ['houseid'] = houseid, ['source'] = tostring(_source) }
      exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn=@source", param)
    end
    table.insert(storedFurn[_source], entId)
end)

AddEventHandler('playerDropped', function() --when you leave checks if you had furn spawned in and if so it deletes it
    DelSpawnedFurn(source)
end)


function DelSpawnedFurn(source) --funct to del furniture if the source is the player who spawned the furniture
    local result = MySQL.query.await("SELECT * FROM bcchousing")
    local houseFurnDeleted = nil
    if #result > 0 then
      for k, v in pairs(result) do
        if source == tonumber(v.player_source_spawnedfurn) then --compares the source listed in db to the players source and if they match then
          houseFurnDeleted = v
          if storedFurn[source] ~= nil then --if the furniture stored is not nil then
            for w, e in pairs(storedFurn[source]) do
              local netEntId = NetworkGetEntityFromNetworkId(e)
              if DoesEntityExist(netEntId) then --Checking if the ent still exists that way if it has been deleted client it doesnt try and delete (safety check basically)
                DeleteEntity(netEntId)
              end
            end
          end
        end
      end
    end
    if houseFurnDeleted ~= nil then
      local param = { ['resetvar'] = 'none', ['houseid'] = houseFurnDeleted.houseid }
      exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn=@resetvar WHERE houseid=@houseid", param)
    end
end
  
RegisterServerEvent('bcc-housing:BuyFurn', function(cost, entId, furnitureCreatedTable)
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    if character.money >= tonumber(cost) then
      character.removeCurrency(0, tonumber(cost))
      TriggerClientEvent('bcc-housing:ClientFurnBought', _source, furnitureCreatedTable, entId)
      Discord:sendMessage(_U("furnWebHookBought") .. tostring(character.charIdentifier), _U("furnWebHookBoughtModel") .. tostring(furnitureCreatedTable.model) .. _U("furnWebHookSoldPrice") .. tostring(cost))
    else
      VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
      TriggerClientEvent('bcc-housing:ClientFurnBoughtFail', _source)
    end
end)
  
RegisterServerEvent('bcc-housing:ServerSideRssStop', function() --used to reset all houses spawn source to default incase someone restarts the script live to prevent errors
    exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn='none'")
end)
  
RegisterServerEvent('bcc-housing:GetOwnerFurniture', function(houseid) --event to handler returning all owned furniture to open the selling menu
    local param = { ['houseid'] = houseid }
    local _source = source
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if result[1] then
      if result[1].furniture ~= 'none' then
        TriggerClientEvent('bcc-housing:SellOwnedFurnMenu', _source, json.decode(result[1].furniture))
      else
        VORPcore.NotifyRightTip(_source, _U("noFurn"), 4000)
      end
    end
end)
  
RegisterServerEvent('bcc-housing:FurnSoldRemoveFromTable', function(furnTable, houseid, wholeFurnTable, wholeFurnTableKey) --selling furn handler
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
  
    table.remove(wholeFurnTable, tonumber(wholeFurnTableKey))
    local newDbTable
    if #wholeFurnTable > 0 then
      newDbTable = json.encode(wholeFurnTable)
    else
      newDbTable = 'none'
    end
      local newParam = { ['houseid'] = houseid, ['newFurnTable'] = newDbTable }
      exports.oxmysql:execute("UPDATE bcchousing SET furniture=@newFurnTable WHERE houseid=@houseid", newParam)
      VORPcore.NotifyRightTip(_source, _U("furnSold"), 4000)
      character.addCurrency(0, tonumber(furnTable.sellprice))
      Discord:sendMessage(_U("furnWebHookSold") .. character.charIdentifier, _U("furnWebHookSoldModel") .. tostring(furnTable.model) .. _U("furnWebHookSoldPrice") .. tostring(furnTable.sellprice))
      TriggerClientEvent('bcc-housing:ClientCloseAllMenus', _source)
end)
  
RegisterServerEvent('bcc-housing:LedgerHandling', function(amountToInsert, houseid) --handling money insertion
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local param = { ['houseid'] = houseid, ['amountToInsert'] = tonumber(amountToInsert) }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if #result > 0 then
      if result[1].ledger + tonumber(amountToInsert) <= result[1].tax_amount then
        if character.money >= tonumber(amountToInsert) then
          character.removeCurrency(0, tonumber(amountToInsert))
          VORPcore.NotifyRightTip(_source, _U("ledgerAmountInesrted"), 4000)
          exports.oxmysql:execute("UPDATE bcchousing SET ledger=ledger+@amountToInsert WHERE houseid=@houseid", param)
        else
          VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
        end
      else
        VORPcore.NotifyRightTip(_source, _U("maxMoney"), 4000)
      end
    end
end)

RegisterServerEvent('bcc-housing:CheckLedger', function(houseid) --check ledger handler
    local _source = source
    local param = { ['houseid'] = houseid }
    local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)
    if #result > 0 then
      VORPcore.NotifyRightTip(_source, tostring(result[1].ledger) .. '/' .. tostring(result[1].tax_amount))
    end
end)