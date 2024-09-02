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
            `ledger` int NOT NULL DEFAULT 0,
            `tax_amount` int NOT NULL DEFAULT 0,
            PRIMARY KEY `houseid` (`houseid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Create the bcchousinghotels table if it doesn't exist
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcchousinghotels` (
            `charidentifier` varchar(50) NOT NULL,
            `hotels` LONGTEXT NOT NULL DEFAULT 'none'
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Add tpInt and tpInstance columns to bcchousing if they don't exist
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `tpInt` int(10) DEFAULT 0")
    MySQL.query.await("ALTER TABLE `bcchousing` ADD COLUMN IF NOT EXISTS `tpInstance` int(10) DEFAULT 0")

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

    DbUpdated = true

    print("Database tables for \x1b[35m\x1b[1m*bcc-housing*\x1b[0m created or updated \x1b[32msuccessfully\x1b[0m.")

end)
