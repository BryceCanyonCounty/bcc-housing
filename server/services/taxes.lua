local function formatMoney(value)
    return string.format("%.2f", tonumber(value) or 0)
end

local function sendTaxWebhook(house, status)
    local taxAmount = tonumber(house.tax_amount) or 0
    local ledgerBefore = tonumber(house.ledger) or 0

    if status == "paid" then
        local ledgerAfter = math.max(ledgerBefore - taxAmount, 0)
        local description = table.concat({
            _U("houseIdWebhook") .. tostring(house.houseid),
            _U("taxAmountWebhook") .. formatMoney(taxAmount),
            _U("ledgerBeforeWebhook") .. formatMoney(ledgerBefore),
            _U("ledgerAfterWebhook") .. formatMoney(ledgerAfter)
        }, "\n")
        Discord:sendMessage(_U("taxPaidWebhook"), description)
        return
    end

    local shortfall = math.max(taxAmount - ledgerBefore, 0)
    local description = table.concat({
        _U("houseIdWebhook") .. tostring(house.houseid),
        _U("taxAmountWebhook") .. formatMoney(taxAmount),
        _U("ledgerBeforeWebhook") .. formatMoney(ledgerBefore),
        _U("taxShortfallWebhook") .. formatMoney(shortfall)
    }, "\n")
    Discord:sendMessage(_U("taxPaidFailedWebhook"), description)
end

CreateThread(function() --Tax handling
    while not DbUpdated do
        Wait(1000)
    end
    if Config.collectTaxes then -- Check if tax collection is enabled
        local date = os.date("%d")
        local result = MySQL.query.await("SELECT * FROM bcchousing")
        if tonumber(date) == tonumber(Config.TaxDay) then -- for some reason these have to be tonumbered
            if #result > 0 then
                for k, v in pairs(result) do
                    local taxAmount = tonumber(v.tax_amount) or 0
                    local ledgerAmount = tonumber(v.ledger) or 0
                    local param = { ['houseid'] = v.houseid, ['taxamount'] = taxAmount }
                    if v.taxes_collected == 'false' or v.taxes_collected == 'overdue' then
                        if ledgerAmount < taxAmount then
                            exports.oxmysql:execute("UPDATE bcchousing SET taxes_collected='overdue' WHERE houseid=@houseid", param)
                            sendTaxWebhook(v, "overdue")
                        else
                            exports.oxmysql:execute(
                                "UPDATE bcchousing SET ledger=ledger-@taxamount, taxes_collected='true' WHERE houseid=@houseid",
                                param)
                            sendTaxWebhook(v, "paid")
                        end
                    end
                end
            end
        elseif tonumber(date) == tonumber(Config.TaxResetDay) then
            if #result > 0 then
                for k, v in pairs(result) do
                    if v.taxes_collected == 'true' then
                        local param = { ['houseid'] = v.houseid }
                        exports.oxmysql:execute("UPDATE bcchousing SET taxes_collected='false' WHERE houseid=@houseid", param)
                    end
                end
            end
        end
    end
end)
