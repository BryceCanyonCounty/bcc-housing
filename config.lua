Config = {}

Config.defaultlang = 'en_lang' --set your language here

Config.DevMode = false --False on live server

Config.Setup = {
    MaxHousePerChar = 2, --Maximum allowed houses per character
}

Config.TaxDay = 23 --This is the number day of each month that taxes will be collected on
Config.TaxResetDay = 24 --This MUST be the day after TaxDay set above!!! (do not change either of these dates if the current date is one of the 2 for ex if its the 22 or 23rd day do not change these dates it will break the code)

Config.WebhookLink = 'youlink' --insert your webhook link here if you want webhooks

Config.CreateHouseCommand = 'createHouse' --the name of the command to create a house


Config.Hotels = {
    {
        hotelId = 1, --Make sure this is a unique number for each hotel (once set do not change it will break!)
        location = {x = -322.12, y = 767.12, z = 121.63}, --location of where you will buy and enter the hotel room
        cost = 50, --cost to buy the hotel room
        invSpace = 200, --Amount of inventory room the hotel will have
    },
}

Config.Furniture = {
    Chairs = {
        { propModel = 'p_chairnbx02x', displayName = 'Wooden Chair', costToBuy = 100, sellFor = 50 },
        { propModel = 'p_chairironnbx01x', displayName = 'Iron Chair', costToBuy = 200, sellFor = 50 },
    },
    Benches = {
        { propModel = 'p_benchironnbx01x', displayName = 'Iron Bench', costToBuy = 400, sellFor = 50 },
        { propModel = 'p_benchnbx01x', displayName = 'Wood bench', costToBuy = 300, sellFor = 50 },
    },
    Tables = {
        { propModel = 'mp009_p_mp009_cratetable01x', displayName = 'Crate Table', costToBuy = 400, sellFor = 50 },
        { propModel = 'mp007_p_table_nat01x', displayName = 'Wood Table', costToBuy = 600, sellFor = 50 },
    },
    Beds = {
        { propModel = 'p_bed03x', displayName = 'Wood Bed', costToBuy = 200, sellFor = 50 },
        { propModel = 'p_bed01x', displayName = 'Basic Bed', costToBuy = 100, sellFor = 50 },
    },
    Lights = {
        { propModel = 'p_lightpolenbx04x', displayName = 'Light Pole', costToBuy = 150, sellFor = 50 },
        { propModel = 'p_hanginglightnbx01x', displayName = 'Hanging Light', costToBuy = 100, sellFor = 50 },
    },
    Misc = {
        { propModel = 'p_lightpolenbx04x', displayName = 'Light Pole', costToBuy = 150, sellFor = 50 },
        { propModel = 'p_lightpolenbx04x', displayName = 'Light Pole', costToBuy = 150, sellFor = 50 },
    }
}

---------- Admin Configuration (Anyone listed here will be able to create and delete ranches!) -----------
Config.AdminSteamIds = {
    {
        steamid = 'steam:11000013707db22', --insert players steam id
    }, --to add more just copy this table paste and change id
}