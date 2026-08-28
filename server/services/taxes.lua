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

local function parseMysqlDate(value)
    if not value or value == '' then return nil end

    local year, month, day = tostring(value):match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    if not year or not month or not day then return nil end

    return {
        year = year,
        month = month,
        day = day
    }
end

local function daysInMonth(year, month)
    if month == 2 then
        local leapYear = (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
        return leapYear and 29 or 28
    end

    if month == 4 or month == 6 or month == 9 or month == 11 then
        return 30
    end

    return 31
end

local function compareDateParts(left, right)
    if left.year ~= right.year then return left.year < right.year and -1 or 1 end
    if left.month ~= right.month then return left.month < right.month and -1 or 1 end
    if left.day ~= right.day then return left.day < right.day and -1 or 1 end
    return 0
end

local function previousMonth(date)
    local year = date.year
    local month = date.month - 1
    if month < 1 then
        month = 12
        year = year - 1
    end

    return { year = year, month = month, day = 1 }
end

local function getLatestDueDate(purchasedAt, currentDate)
    local purchasedDate = parseMysqlDate(purchasedAt)
    if not purchasedDate then return nil end

    local dueMonth = {
        year = currentDate.year,
        month = currentDate.month,
        day = 1
    }
    local billingDay = math.min(purchasedDate.day, daysInMonth(dueMonth.year, dueMonth.month))
    local dueDate = {
        year = dueMonth.year,
        month = dueMonth.month,
        day = billingDay
    }

    if compareDateParts(currentDate, dueDate) < 0 then
        dueMonth = previousMonth(dueMonth)
        dueDate = {
            year = dueMonth.year,
            month = dueMonth.month,
            day = math.min(purchasedDate.day, daysInMonth(dueMonth.year, dueMonth.month))
        }
    end

    if dueDate.year == purchasedDate.year and dueDate.month == purchasedDate.month then
        return nil
    end

    if compareDateParts(dueDate, purchasedDate) <= 0 then
        return nil
    end

    return dueDate
end

local function formatDateKey(date)
    return date and ("%04d-%02d-%02d"):format(date.year, date.month, date.day) or nil
end

CreateThread(function() --Tax handling
    while not DbUpdated do
        Wait(1000)
    end

    if not Config.collectTaxes then
        return
    end

    local lastProcessedDate = nil
    while Config.collectTaxes do
        local currentDate = {
            year = tonumber(os.date("%Y")),
            month = tonumber(os.date("%m")),
            day = tonumber(os.date("%d"))
        }
        local currentDateKey = formatDateKey(currentDate)

        if currentDateKey ~= lastProcessedDate then
            lastProcessedDate = currentDateKey
            local result = MySQL.query.await("SELECT * FROM bcchousing")
            if #result > 0 then
                for k, v in pairs(result) do
                    local taxAmount = tonumber(v.tax_amount) or 0
                    local ledgerAmount = tonumber(v.ledger) or 0
                    local latestDueDate = getLatestDueDate(v.purchased_at, currentDate)
                    local latestDueKey = formatDateKey(latestDueDate)
                    local lastProcessedDate = parseMysqlDate(v.last_tax_processed_at)
                    local hasUnprocessedDue = latestDueDate and
                        (not lastProcessedDate or compareDateParts(lastProcessedDate, latestDueDate) < 0)

                    if hasUnprocessedDue then
                        local taxStatus = tostring(v.taxes_collected)
                        if taxStatus == 'overdue' or taxStatus == 'released' then
                            MySQL.update.await(
                                "UPDATE bcchousing SET last_tax_processed_at = ? WHERE houseid = ?",
                                { latestDueKey, v.houseid }
                            )
                        elseif ledgerAmount < taxAmount then
                            MySQL.update.await(
                                "UPDATE bcchousing SET taxes_collected = 'overdue', last_tax_processed_at = ? WHERE houseid = ?",
                                { latestDueKey, v.houseid }
                            )
                            sendTaxWebhook(v, "overdue")
                        else
                            MySQL.update.await(
                                "UPDATE bcchousing SET ledger = ledger - ?, taxes_collected = 'true', last_tax_processed_at = ? WHERE houseid = ?",
                                { taxAmount, latestDueKey, v.houseid }
                            )
                            sendTaxWebhook(v, "paid")
                        end
                    end
                end
            end
        end

        Wait(60 * 60 * 1000)
    end
end)
