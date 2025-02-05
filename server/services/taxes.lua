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
                    local param = { ['houseid'] = v.houseid, ['taxamount'] = tonumber(v.tax_amount) }
                    if v.taxes_collected == 'false' then
                        if tonumber(v.ledger) < tonumber(v.tax_amount) then
                            exports.oxmysql:execute("DELETE FROM bcchousing WHERE houseid=@houseid", param)
                            Discord:sendMessage(_U("houseIdWebhook") .. tostring(v.houseid), _U("taxPaidFailedWebhook"))
                        else
                            exports.oxmysql:execute(
                                "UPDATE bcchousing SET ledger=ledger-@taxamount, taxes_collected='true' WHERE houseid=@houseid",
                                param)
                            Discord:sendMessage(_U("houseIdWebhook") .. tostring(v.houseid), _U("taxPaidWebhook"))
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
    end
end)
