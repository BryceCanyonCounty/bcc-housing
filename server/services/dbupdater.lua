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

local function getDefaultPurchasedAtFromTaxDay()
    local taxDay = tonumber(Config.TaxDay) or 1
    taxDay = math.max(1, math.min(taxDay, 31))

    local date = os.date("*t")
    local year = date.year
    local month = date.month - 1
    if month < 1 then
        month = 12
        year = year - 1
    end

    local day = math.min(taxDay, daysInMonth(year, month))
    return ("%04d-%02d-%02d 00:00:00"):format(year, month, day)
end

CreateThread(function()
    -- Create the bcchousing table if it doesn't exist
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcchousing` (
            `charidentifier` varchar(50) NOT NULL,
            `house_coords` LONGTEXT NOT NULL,
            `house_radius_limit` varchar(100) NOT NULL,
            `houseid` int NOT NULL AUTO_INCREMENT,
            `furniture` LONGTEXT NOT NULL DEFAULT 'none',
            `doors` LONGTEXT NOT NULL DEFAULT 'none',
            `allowed_ids` LONGTEXT NOT NULL DEFAULT 'none',
            `invlimit` varchar(50) NOT NULL DEFAULT 200,
            `player_source_spawnedfurn` varchar(50) NOT NULL DEFAULT 'none',
            `taxes_collected` varchar(50) NOT NULL DEFAULT 'false',
            `ledger` float NOT NULL DEFAULT 0,
            `tax_amount` float NOT NULL DEFAULT 0,
            PRIMARY KEY `houseid` (`houseid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Add tpInt and tpInstance columns to bcchousing if they don't exist
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `tpInt` int(10) DEFAULT 0")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `tpInstance` int(10) DEFAULT 0")
	MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `uniqueName` VARCHAR(255) NOT NULL")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `ownershipStatus` ENUM('purchased', 'rented') NOT NULL DEFAULT 'purchased'")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `purchaseCurrencyType` TINYINT NOT NULL DEFAULT 0")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `inventory_current_stage` int(10) NOT NULL DEFAULT 0")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `poly_points` LONGTEXT NULL")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `poly_min_z` DOUBLE NULL")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `poly_max_z` DOUBLE NULL")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `property_deed` LONGTEXT NULL")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `purchased_at` DATETIME NULL DEFAULT NULL")
    local lastTaxProcessedColumnCount = tonumber(MySQL.scalar.await([[
        SELECT COUNT(*)
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'bcchousing'
          AND COLUMN_NAME = 'last_tax_processed_at'
    ]])) or 0
    local hadLastTaxProcessedColumn = lastTaxProcessedColumnCount > 0
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `last_tax_processed_at` DATE NULL DEFAULT NULL")
    if not hadLastTaxProcessedColumn then
        MySQL.update.await("UPDATE `bcchousing` SET `last_tax_processed_at` = CURDATE() WHERE `last_tax_processed_at` IS NULL")
    end
    MySQL.query.await("UPDATE `bcchousing` SET `purchased_at` = ? WHERE `purchased_at` IS NULL", {
        getDefaultPurchasedAtFromTaxDay()
    })

    -- Create the bcchousinghotels table if it doesn't exist
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcchousinghotels` (
            `charidentifier` varchar(50) NOT NULL,
            `hotels` LONGTEXT NOT NULL DEFAULT 'none'
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Add index to bcchousinghotels if it doesn't exist
    MySQL.query.await([[
        CREATE INDEX IF NOT EXISTS `idx_charidentifier` ON `bcchousinghotels` (`charidentifier`);
    ]])

    -- Create the bcchousing_transactions table if it doesn't exist
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcchousing_transactions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `houseid` int(11) NOT NULL,
            `identifier` varchar(50) NOT NULL,
            `amount` int(11) NOT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcchousing_ownedfurniture` (
            `charidentifier` varchar(50) NOT NULL,
            `items` LONGTEXT NOT NULL DEFAULT '[]',
            PRIMARY KEY (`charidentifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    DbUpdated = true

    print("Database tables for \x1b[35m\x1b[1m*bcc-housing*\x1b[0m created or updated \x1b[32msuccessfully\x1b[0m.")
end)
