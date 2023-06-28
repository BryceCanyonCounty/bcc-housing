---- Pulling Essentials -----
VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
BccUtils = exports['bcc-utils'].initiate()
local discord = BccUtils.Discord.setup(Config.WebhookLink, 'bcc-housing', 'https://steamuserimages-a.akamaihd.net/ugc/1759186614239848553/8C42E78A07CB85399889CD5C82C63235F6C61F0F/?imw=637&imh=358&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true')

------ Commands Admin Check --------
RegisterServerEvent('bcc-housing:AdminCheck', function()
  local _source = source
  local character = VORPcore.getUser(_source).getUsedCharacter
  local admin = false
  for k, v in pairs(Config.AdminSteamIds) do
    if character.identifier == v.steamid then
      admin = true
      TriggerClientEvent('bcc-housing:AdminClientCatch', _source, true) break
    end
  end
  if not admin then
    for k, v in pairs(Config.ALlowedJobs) do
      if character.job == v.jobname then
        TriggerClientEvent('bcc-housing:AdminClientCatch', _source, true) break
      end
    end
  end
end)

--get players info list
PlayersTable = {}
RegisterServerEvent('bcc-housing:GetPlayers')
AddEventHandler('bcc-housing:GetPlayers', function()
  local _source, data = source, {}

  for _, player in ipairs(PlayersTable) do
    local User = VORPcore.getUser(player)
    if User then
      local Character = User.getUsedCharacter                             --get player info
      local playername = Character.firstname .. ' ' .. Character.lastname --player char name
      data[tostring(player)] = {
        serverId = player,
        PlayerName = playername,
        staticid = Character.charIdentifier,
      }
    end
  end
  TriggerClientEvent("bcc-housing:SendPlayers", _source, data)
end)

-- check if staff is available
RegisterServerEvent("bcc-housing:getPlayersInfo", function(source)
  local _source = source
  PlayersTable[#PlayersTable + 1] = _source -- add all players
end)

---- House Creation DB Insert ----
RegisterServerEvent('bcc-housing:CreationDBInsert', function(owner, radius, doors, houseCoords, invLimit, ownerSource, taxAmount)
  local _source = source
  local taxes
  if tonumber(taxAmount) > 0 then
    taxes = tonumber(taxAmount)
  else
    taxes = 0
  end
  local character = VORPcore.getUser(_source).getUsedCharacter
  local param = { ['charidentifier'] = owner, ['radius'] = radius, ["doors"] = json.encode(doors), ['houseCoords'] = json.encode(houseCoords), ['invlimit'] = invLimit, ['taxes'] = taxes }
  local result = MySQL.query.await("SELECT * FROM bcchousing WHERE charidentifier=@charidentifier", param)
  if #result < Config.Setup.MaxHousePerChar then
    exports.oxmysql:execute("INSERT INTO bcchousing ( `charidentifier`,`house_radius_limit`,`doors`,`house_coords`,`invlimit`,`tax_amount` ) VALUES ( @charidentifier,@radius,@doors,@houseCoords,@invlimit,@taxes )", param)
    discord:sendMessage(_U("houseCreatedWebhook") .. tostring(character.charIdentifier), _U("houseCreatedWebhookGivenToo") .. tostring(owner))
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
    if result[1].player_source_spawnedfurn == 'none' and close == true then
      if result[1].furniture ~= 'none' then
        local furn = json.decode(result[1].furniture)
        TriggerClientEvent('bcc-housing:SpawnFurnitureEvent', _source, furn)
        exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn=@source", param)
      end
    elseif tonumber(result[1].player_source_spawnedfurn) == _source then
      if deletion then
        delSpawnedFurn(_source)
      end
    end
  end
end)

RegisterServerEvent('bcc-housing:StoreFurnForDeletion', function(entId, houseid) --this is used to store the entity id of each piece of furniture in the table for when it is deleted
  if storedFurn[source] == nil then
    storedFurn[source] = {}
    local param = { ['houseid'] = houseid, ['source'] = tostring(source) }
    exports.oxmysql:execute("UPDATE bcchousing SET player_source_spawnedfurn=@source", param)
  end
  table.insert(storedFurn[source], entId)
end)

AddEventHandler('playerDropped', function() --when you leave checks if you had furn spawned in and if so it deletes it
  delSpawnedFurn(source)
end)

function delSpawnedFurn(source) --funct to del furniture if the source is the player who spawned the furniture
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
    discord:sendMessage(_U("furnWebHookBought") .. tostring(character.charIdentifier), _U("furnWebHookBoughtModel") .. tostring(furnitureCreatedTable.model) .. _U("furnWebHookSoldPrice") .. tostring(cost))
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
  local param = { ['houseid'] = houseid, ['source'] = tostring(_source) }
  local result = MySQL.query.await("SELECT * FROM bcchousing WHERE houseid=@houseid", param)

  for k, v in pairs(storedFurn[tonumber(result[1].player_source_spawnedfurn)]) do
    local netEntId = NetworkGetEntityFromNetworkId(v)
    local storedFurnCoord = GetEntityCoords(netEntId)
    local firstVec = vector3(tonumber(storedFurnCoord.x), tonumber(storedFurnCoord.y), tonumber(storedFurnCoord.z))
    local secondVec = vector3(tonumber(furnTable.coords.x), tonumber(furnTable.coords.y), tonumber(furnTable.coords.z))
    local dist = #(firstVec - secondVec)

    if dist < 0.5 then --used as a way to check if the loop is on the correct piece of furniture
      table.remove(storedFurn[tonumber(result[1].player_source_spawnedfurn)], k)
      table.remove(wholeFurnTable, tonumber(wholeFurnTableKey))
      DeleteEntity(netEntId)

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
      discord:sendMessage(_U("furnWebHookSold") .. character.charIdentifier, _U("furnWebHookSoldModel") .. tostring(furnTable.model) .. _U("furnWebHookSoldPrice") .. tostring(furnTable.sellprice))
      TriggerClientEvent('bcc-housing:ClientCloseAllMenus', _source) break
    end
  end
end)

CreateThread(function() --Tax handling
  local date = os.date("%d")
  local result = MySQL.query.await("SELECT * FROM bcchousing")
  if tonumber(date) == tonumber(Config.TaxDay) then --for some reason these have to be tonumbered
    if #result > 0 then
      for k, v in pairs(result) do
        local param = { ['houseid'] = v.houseid, ['taxamount'] = tonumber(v.tax_amount) }
        if v.taxes_collected == 'false' then
          if tonumber(v.ledger) < tonumber(v.tax_amount) then
            exports.oxmysql:execute("DELETE FROM bcchousing WHERE houseid=@houseid", param)
            discord:sendMessage(_U("houseIdWebhook") .. tostring(v.houseid), _U("taxPaidFailedWebhook"))
          else
            exports.oxmysql:execute("UPDATE bcchousing SET ledger=ledger-@taxamount, taxes_collected='true' WHERE houseid=@houseid", param)
            discord:sendMessage(_U("houseIdWebhook") .. tostring(v.houseid), _U("taxPaidWebhook"))
          end
        end
      end
    end
  elseif tonumber(date) == tonumber(Config.TaxResetDay) then
    if #result > 0 then
      for k, v in pairs(result) do
        local param = { ['houseid'] = v.houseid }
        exports.oxmysql:execute("UPDATE bcchousing SET taxes_collected='false' WHERE houseid=@houseid", param)
      end
    end
  end
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

----- Hotel Area ----
RegisterServerEvent('bcc-housing:HotelDbRegistry', function() --registering each player
  local _source = source
  local character = VORPcore.getUser(_source).getUsedCharacter
  local param = { ['charidentifier'] = character.charIdentifier }
  local result = MySQL.query.await("SELECT * FROM bcchousinghotels WHERE charidentifier=@charidentifier", param)
  if #result == 0 then
    exports.oxmysql:execute("INSERT INTO bcchousinghotels ( `charidentifier` ) VALUES ( @charidentifier )", param)
  else
    for k, v in pairs(result) do
      TriggerClientEvent('bcc-housing:HousingTableUpdate',  _source, v)
    end
  end
  local result2 = MySQL.query.await("SELECT * FROM bcchousinghotels WHERE charidentifier=@charidentifier", param)
  if result2[1].hotels ~= 'none' then
    local hotelsTable = json.decode(result2[1].hotels)
    if #hotelsTable > 0 then
      for k, v in pairs(hotelsTable) do
        TriggerClientEvent('bcc-housing:HousingTableUpdate', _source, v)
      end
    end
  end
  TriggerClientEvent('bcc-housing:MainHotelHandler', _source)
end)

RegisterServerEvent('bcc-housing:HotelBought', function(hotelTable)
  local _source = source
  local character = VORPcore.getUser(_source).getUsedCharacter
  local param = { ['charidentifier'] = character.charIdentifier }
  local result = MySQL.query.await("SELECT * FROM bcchousinghotels WHERE charidentifier=@charidentifier", param)
  local ownedHotels = result[1].hotels
  local tableToInsert = nil
  if ownedHotels == 'none' then
    if character.money >= hotelTable.cost then
      character.removeCurrency(0, hotelTable.cost)
      tableToInsert = json.encode({hotelTable.hotelId})
    else
      VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
    end
  else
    local ownedHotels2 = json.decode(ownedHotels)
    if character.money >= hotelTable.cost then
      table.insert(ownedHotels2, hotelTable.hotelId)
      character.removeCurrency(0, hotelTable.cost)
      tableToInsert = json.encode(ownedHotels2)
    else
      VORPcore.NotifyRightTip(_source, _U("noMoney"), 4000)
    end
  end
  if tableToInsert ~= nil then
    local param2 = { ['charidentifier'] = character.charIdentifier, ['hotelsTable'] = tableToInsert }
    exports.oxmysql:execute("UPDATE bcchousinghotels SET hotels=@hotelsTable WHERE charidentifier=@charidentifier", param2)
    for k, v in pairs(json.decode(tableToInsert)) do
      TriggerClientEvent('bcc-housing:HousingTableUpdate', _source, v)
    end
  end
end)

CreateThread(function() --registering all inventories
  for k, v in pairs(Config.Hotels) do
    VORPInv.removeInventory('bcc-housinginv:' .. v.hotelId)
    Wait(50)
    VORPInv.registerInventory('bcc-housinginv:' .. v.hotelId, _U("hotelInvName"), v.invSpace, true, false, true)
  end
end)

RegisterServerEvent('bcc-housing:HotelInvOpen', function(hotelId)
  local _source = source
  VORPInv.OpenInv(_source, 'bcc-housinginv:' .. hotelId)
end)

BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-housing')