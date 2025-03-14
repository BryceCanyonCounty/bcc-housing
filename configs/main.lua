Config = {
    -- Set your language here
    defaultlang = 'en_lang',
    -----------------------------------------------------

    DevMode = false,               -- False on live server
    DevModeCommand = "HousingDev", -- This command need to be sent after restarting the resource
    -----------------------------------------------------

    keys = {
        manage = 'G',  -- [G] Manage House
        collect = 'G', -- [G] Collect money from selling house
        buy = 'G',     -- [B] Buy house
    },
    -----------------------------------------------------

    -- Set your admin group here
    adminGroup = 'admin',
    -----------------------------------------------------

    -- Jobs that will be able to make houses just like the admins can above. Useful for real estate jobs
    ALlowedJobs = {
        { jobname = 'realtor' }, --to add more just copy/paste and change job name
    },
    -----------------------------------------------------

    -- Admin Commands
    AdminManagementMenuCommand = 'HousingManager', --the name of the command for admins to manage all houses
    -----------------------------------------------------

    --Maximum allowed houses per character
    Setup = {
        MaxHousePerChar = 1,
    },
    -----------------------------------------------------

    collectTaxes = false,
    -- Tax Day for checking the ledger and collect
    TaxDay = 26,      --This is the number day of each month that taxes will be collected on
    TaxResetDay = 27, --This MUST be the day after TaxDay set above!!! (do not change either of these dates if the current date is one of the 2 for ex if its the 22 or 23rd day do not change these dates it will break the code)
    -----------------------------------------------------

    -- Discord Webhooks
    WebhookLink = '', --insert your webhook link here if you want webhooks
    WebhookTitle = 'BCC-Housing',
    WebhookAvatar = 'https://bcc-scripts.com/servericons/provision_jail_keys.png',
    -----------------------------------------------------

    doors = { -- Turn off/on the door buttons in house menu
        createNewDoors = true,
        removeDoors = true
    },
    -----------------------------------------------------

    EnablePrivatePropertyCheck = true, -- Set true if you want to see a message that you enterd private property
    -----------------------------------------------------

    UseImageAtBottomMenu = true,
    HouseImageURL = [[<img style="margin: 0 auto; max-width: 20vw; max-height: 15vh; width: auto; height: auto;" src="]] ..
        "https://bcc-scripts.com/servericons/provision_jail_keys.png" .. [[" />]],
    --<img width="750px" height="108px" style="margin: 0 auto;" src="https://bcc-scripts.com/servericons/ammo_arrow_tracking.png" /> -- Add your desired image URL here
    -----------------------------------------------------

    dontShowNames = false, -- If true, player ID will be shown in Player List menu instead of player name
    -----------------------------------------------------

    -- TP Houses
    -- Here you need to add coordinates for interiors which doors cannot be open, you need to enter in the house with Noclip and get the coords
    -- Make sure you add the cordinates before create the TP House
    TpInteriors = {
        Interior1 = {
            exitCoords = vector3(-1103.15, -2252.92, 50.65),
            furnRadius = 10
        },
        Interior2 = {
            exitCoords = vector3(-63.74, 14.05, 76.6),
            furnRadius = 10
        },
        Interior3 = {
            exitCoords = vector3(-60.36, 1238.86, 170.79),
            furnRadius = 10
        },
    },
    -----------------------------------------------------

    SellToPlayer = false,             -- Set to false if you don't want players to sell houses to other players
    DefaultSellPricetoPlayer = 50000, -- Default sell price for houses to a player
    -----------------------------------------------------

    -- Global Blip Settings for menu created owned houses (not for owned houses by config)
    HouseBlip = {
        active = true,           -- Show blip for owned houses
        name = 'Your House',     -- Name of the owned blip on the map
        sprite = 'blip_mp_base', -- Set sprite of the owned blip
        color = 'WHITE',         -- Set color of the owned blip (see BlipColors below)
    },
    -----------------------------------------------------

    DefaultMenuManageRadius = 1.2,
    -----------------------------------------------------

    BlipColors = {
        LIGHT_BLUE    = 'BLIP_MODIFIER_MP_COLOR_1',
        DARK_RED      = 'BLIP_MODIFIER_MP_COLOR_2',
        PURPLE        = 'BLIP_MODIFIER_MP_COLOR_3',
        ORANGE        = 'BLIP_MODIFIER_MP_COLOR_4',
        TEAL          = 'BLIP_MODIFIER_MP_COLOR_5',
        LIGHT_YELLOW  = 'BLIP_MODIFIER_MP_COLOR_6',
        PINK          = 'BLIP_MODIFIER_MP_COLOR_7',
        GREEN         = 'BLIP_MODIFIER_MP_COLOR_8',
        DARK_TEAL     = 'BLIP_MODIFIER_MP_COLOR_9',
        RED           = 'BLIP_MODIFIER_MP_COLOR_10',
        LIGHT_GREEN   = 'BLIP_MODIFIER_MP_COLOR_11',
        TEAL2         = 'BLIP_MODIFIER_MP_COLOR_12',
        BLUE          = 'BLIP_MODIFIER_MP_COLOR_13',
        DARK_PUPLE    = 'BLIP_MODIFIER_MP_COLOR_14',
        DARK_PINK     = 'BLIP_MODIFIER_MP_COLOR_15',
        DARK_DARK_RED = 'BLIP_MODIFIER_MP_COLOR_16',
        GRAY          = 'BLIP_MODIFIER_MP_COLOR_17',
        PINKISH       = 'BLIP_MODIFIER_MP_COLOR_18',
        YELLOW_GREEN  = 'BLIP_MODIFIER_MP_COLOR_19',
        DARK_GREEN    = 'BLIP_MODIFIER_MP_COLOR_20',
        BRIGHT_BLUE   = 'BLIP_MODIFIER_MP_COLOR_21',
        BRIGHT_PURPLE = 'BLIP_MODIFIER_MP_COLOR_22',
        YELLOW_ORANGE = 'BLIP_MODIFIER_MP_COLOR_23',
        BLUE2         = 'BLIP_MODIFIER_MP_COLOR_24',
        TEAL3         = 'BLIP_MODIFIER_MP_COLOR_25',
        TAN           = 'BLIP_MODIFIER_MP_COLOR_26',
        OFF_WHITE     = 'BLIP_MODIFIER_MP_COLOR_27',
        LIGHT_YELLOW2 = 'BLIP_MODIFIER_MP_COLOR_28',
        LIGHT_PINK    = 'BLIP_MODIFIER_MP_COLOR_29',
        LIGHT_RED     = 'BLIP_MODIFIER_MP_COLOR_30',
        LIGHT_YELLOW3 = 'BLIP_MODIFIER_MP_COLOR_31',
        WHITE         = 'BLIP_MODIFIER_MP_COLOR_32'
    }
}
