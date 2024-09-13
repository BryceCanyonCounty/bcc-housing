Config = {
    -- Set your language here
    defaultlang = 'en_lang',
    -----------------------------------------------------

    -- Set your admin group here
    adminGroup = 'admin',
    -----------------------------------------------------

    DevMode = false, --False on live server
    -----------------------------------------------------

    --Maximum allowed houses per character
    Setup = {
        MaxHousePerChar = 2,
    },
    -----------------------------------------------------

    -- Tax Day for checking the ledger and collect
    TaxDay = 23,      --This is the number day of each month that taxes will be collected on
    TaxResetDay = 24, --This MUST be the day after TaxDay set above!!! (do not change either of these dates if the current date is one of the 2 for ex if its the 22 or 23rd day do not change these dates it will break the code)
    -----------------------------------------------------

    -- Discord Webhooks
    WebhookLink = '',              --insert your webhook link here if you want webhooks
    WebhookTitle = 'BCC-Housing',
    WebhookAvatar = '',
    -----------------------------------------------------

    -- Admin Commands
    AdminManagementMenuCommand = 'HousingManager', --the name of the command for admins to manage all houses
    EnablePrivatePropertyCheck = true,             -- Set to true to enable, false to disable, this is for if you want to see a message that you enterd on a private property
    keys = {
        manage = 0x760A9C6F,                        -- [G] Manage House
        collect = 0x760A9C6F,                       -- [G] Collect money from selling house 
        buy = 0x4CC0E2FE,                           -- [B] Buy house
    },
    -----------------------------------------------------

    -- Hotels
    Hotels = {
        {
            hotelId = 1,                                        --Make sure this is a unique number for each hotel (once set do not change it will break!)
            location = { x = -322.12, y = 767.12, z = 121.63 }, --location of where you will buy and enter the hotel room
            cost = 40,                                          --cost to buy the hotel room
            invSpace = 100,                                     --Amount of inventory room the hotel will have
        },
        {
            hotelId = 2,                                         --Make sure this is a unique number for each hotel (once set do not change it will break!)
            location = { x = 1343.59, y = -1302.07, z = 77.42 }, --location of where you will buy and enter the hotel room
            cost = 40,                                           --cost to buy the hotel room
            invSpace = 100,                                      --Amount of inventory room the hotel will have
        },
        {
            hotelId = 3,                                        --Make sure this is a unique number for each hotel (once set do not change it will break!)
            location = { x = 2671.97, y = -1219.82, z = 53.3 }, --location of where you will buy and enter the hotel room
            cost = 40,                                          --cost to buy the hotel room
            invSpace = 100,                                     --Amount of inventory room the hotel will have
        },
        {
            hotelId = 4,                                        --Make sure this is a unique number for each hotel (once set do not change it will break!)
            location = { x = 2769.85, y = -1337.6, z = 46.46 }, --location of where you will buy and enter the hotel room
            cost = 40,                                          --cost to buy the hotel room
            invSpace = 100,                                     --Amount of inventory room the hotel will have
        },
        {
            hotelId = 5,                                          --Make sure this is a unique number for each hotel (once set do not change it will break!)
            location = { x = -1778.39, y = -375.34, z = 159.91 }, --location of where you will buy and enter the hotel room
            cost = 40,                                            --cost to buy the hotel room
            invSpace = 100,                                       --Amount of inventory room the hotel will have
        },
        {
            hotelId = 6,                                         --Make sure this is a unique number for each hotel (once set do not change it will break!)
            location = { x = -790.34, y = -1264.38, z = 43.63 }, --location of where you will buy and enter the hotel room
            cost = 40,                                           --cost to buy the hotel room
            invSpace = 100,                                      --Amount of inventory room the hotel will have
        },
        {
            hotelId = 7,                                       --Make sure this is a unique number for each hotel (once set do not change it will break!)
            location = { x = 2958.83, y = 483.01, z = 47.77 }, --location of where you will buy and enter the hotel room
            cost = 40,                                         --cost to buy the hotel room
            invSpace = 100,                                    --Amount of inventory room the hotel will have
        },
    },
    -----------------------------------------------------

    -- Furnitures
    Furniture = {
        chairs = {
            { propModel = 'p_chair14x',  displayName = 'Gardenchair',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair11x',  displayName = 'Chair',               costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair04x',  displayName = 'Woodchair',           costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair05x',  displayName = 'Woodchair 1',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair06x',  displayName = 'Woodchair 2',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair15x',  displayName = 'Woodchair 3',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair16x',  displayName = 'Woodchair 4',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair20x',  displayName = 'Woodchair 5',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair24x',  displayName = 'Woodchair 6',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair26x',  displayName = 'Woodchair 7',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair09x',  displayName = 'Braidchair',          costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair17x',  displayName = 'Braidchair 2',        costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair18x',  displayName = 'Braidchair 3',        costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair19x',  displayName = 'Braidchair 4',        costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair21x',  displayName = 'Braidchair 5',        costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair25x',  displayName = 'Braidchair 6',        costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair31x',  displayName = 'Braidchair 7',        costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair37x',  displayName = 'Braidchair 8',        costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair12bx', displayName = 'upholstered Chair',   costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair12x',  displayName = 'upholstered Chair 2', costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair38x',  displayName = 'upholstered Chair 3', costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair13x',  displayName = 'noble Chair',         costToBuy = 50, sellFor = 30 },
            { propModel = 'p_chair30x',  displayName = 'noble Chair 2',       costToBuy = 50, sellFor = 30 },
        },
        seat = {
            { propModel = 'p_chaircomfy07x',         displayName = 'Braidchair',             costToBuy = 70, sellFor = 50 },
            { propModel = 'p_woodendeskchair01x',    displayName = 'Woodseat',               costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy09x',         displayName = 'Seat',                   costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy23x',         displayName = 'Seat 2',                 costToBuy = 70, sellFor = 50 },
            { propModel = 'p_stoolcomfy02x',         displayName = 'Stool',                  costToBuy = 70, sellFor = 50 },
            { propModel = 'p_stoolcomfy01x',         displayName = 'Stool 2',                costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy03x',         displayName = 'upholstered Armchair',   costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy04x',         displayName = 'upholstered Armchair 2', costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy06x',         displayName = 'upholstered Armchair 3', costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy08x',         displayName = 'upholstered Armchair 4', costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy10x',         displayName = 'upholstered Armchair 5', costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy17x',         displayName = 'upholstered Armchair 6', costToBuy = 70, sellFor = 50 },
            { propModel = 'mp007_p_mp_chairdesk01x', displayName = 'upholstered Armchair 7', costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chairdesk02x',          displayName = 'upholstered Armchair 8', costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy05x',         displayName = 'noble Seat',             costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy11x',         displayName = 'noble Seat 2',           costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy12x',         displayName = 'noble Seat 3',           costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfy22x',         displayName = 'noble Seat 4',           costToBuy = 70, sellFor = 50 },
            { propModel = 'p_chaircomfycombo01x',    displayName = 'noble Seat 5',           costToBuy = 70, sellFor = 50 },
        },
        benches = {
            { propModel = 'p_bench03x',        displayName = 'Woodbench',           costToBuy = 40, sellFor = 20 },
            { propModel = 'p_bench06x',        displayName = 'Woodbench 2',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_bench09x',        displayName = 'Woodbench 3',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_bench11x',        displayName = 'Woodbench 4',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_bench18x',        displayName = 'Woodbench 5',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_benchlong05x',    displayName = 'Woodbench 6',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_benchch01x',      displayName = 'Woodbench 7',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_windsorbench01x', displayName = 'Woodbench 8',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_bench15x',        displayName = 'Parkbench',           costToBuy = 40, sellFor = 20 },
            { propModel = 'p_benchironnbx01x', displayName = 'Parkbench 2',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_benchironnbx02x', displayName = 'Parkbench 3',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_benchnbx03x',     displayName = 'Parkbench 4',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_bench16x',        displayName = 'noble Bench',         costToBuy = 40, sellFor = 20 },
            { propModel = 'p_bench17x',        displayName = 'noble Bench 2',       costToBuy = 40, sellFor = 20 },
            { propModel = 'p_benchnbx02x',     displayName = 'noble Bench 3',       costToBuy = 40, sellFor = 20 },
            { propModel = 'p_hallbench01x',    displayName = 'upholstered Bench',   costToBuy = 40, sellFor = 20 },
            { propModel = 'p_seatbench01x',    displayName = 'upholstered Bench 2', costToBuy = 40, sellFor = 20 },
        },
        tables = {
            { propModel = 'p_writingdesk01x',   displayName = 'small Woodtable',   costToBuy = 60, sellFor = 40 },
            { propModel = 'p_desk04x',          displayName = 'wooden Desk',       costToBuy = 60, sellFor = 40 },
            { propModel = 'p_desk07x',          displayName = 'wooden Desk 2',     costToBuy = 60, sellFor = 40 },
            { propModel = 'p_desk13x',          displayName = 'wooden Desk 3',     costToBuy = 60, sellFor = 40 },
            { propModel = 'p_desk14x',          displayName = 'wooden Desk 4',     costToBuy = 60, sellFor = 40 },
            { propModel = 'p_desk17x',          displayName = 'wooden Desk 5',     costToBuy = 60, sellFor = 40 },
            { propModel = 's_desk01x',          displayName = 'wooden Desk 6',     costToBuy = 60, sellFor = 40 },
            { propModel = 'p_workbenchdesk01x', displayName = 'wooden Desk 7',     costToBuy = 60, sellFor = 40 },
            { propModel = 'p_desk10x',          displayName = 'white wooden Desk', costToBuy = 60, sellFor = 40 },
            { propModel = 'p_desk09x',          displayName = 'noble Desk',        costToBuy = 60, sellFor = 40 },
            { propModel = 'p_desk09bx',         displayName = 'noble Desk 2',      costToBuy = 60, sellFor = 40 },
        },
        couch = {
            { propModel = 'p_couchwicker01x',   displayName = 'Gardensofa',         costToBuy = 80, sellFor = 60 },
            { propModel = 'p_couch08x',         displayName = 'upholstered sofa',   costToBuy = 80, sellFor = 60 },
            { propModel = 'p_sofa01x',          displayName = 'upholstered sofa 2', costToBuy = 80, sellFor = 60 },
            { propModel = 'p_sofa02x',          displayName = 'upholstered sofa 3', costToBuy = 80, sellFor = 60 },
            { propModel = 'p_couch02x',         displayName = 'noble Sofa',         costToBuy = 80, sellFor = 60 },
            { propModel = 'p_couch01x',         displayName = 'noble Sofa 2',       costToBuy = 80, sellFor = 60 },
            { propModel = 'p_couch06x',         displayName = 'noble Sofa 3',       costToBuy = 80, sellFor = 60 },
            { propModel = 'p_couch09x',         displayName = 'noble Sofa 4',       costToBuy = 80, sellFor = 60 },
            { propModel = 'p_couch10x',         displayName = 'noble Sofa 5',       costToBuy = 80, sellFor = 60 },
            { propModel = 'p_victoriansofa01x', displayName = 'noble Sofa 6',       costToBuy = 80, sellFor = 60 },
            { propModel = 'p_couch05x',         displayName = 'Leathersofa',        costToBuy = 80, sellFor = 60 },
        },
        beds = {
            { propModel = 'p_bed04x',     displayName = 'wooden bed',         costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bed05x',     displayName = 'wooden bed 2',       costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bed17x',     displayName = 'wooden bed 3',       costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bed21x',     displayName = 'wooden bed 4',       costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bed13x',     displayName = 'noble bed',          costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bed14x',     displayName = 'metal bed',          costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bed20x',     displayName = 'sized wooden bed',   costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bed20madex', displayName = 'sized wooden bed 2', costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bed12x',     displayName = 'sized noble bed',    costToBuy = 80, sellFor = 60 },
            { propModel = 'p_bedking02x', displayName = 'sized noble bed 2',  costToBuy = 80, sellFor = 60 },
        },
        post = {
            { propModel = 'p_hitchingpost01x_dmg', displayName = 'damaged wooden post',  costToBuy = 30, sellFor = 15 },
            { propModel = 'p_hitchingpost04x',     displayName = 'wooden post',          costToBuy = 30, sellFor = 15 },
            { propModel = 's_hitchpo02x',          displayName = 'wooden post 2',        costToBuy = 30, sellFor = 15 },
            { propModel = 'p_hitchingpost01x',     displayName = 'double wooden post',   costToBuy = 30, sellFor = 15 },
            { propModel = 'p_hitchingpost05x',     displayName = 'double wooden post 2', costToBuy = 30, sellFor = 15 },
            { propModel = 'p_hitchpostbla01x',     displayName = 'metal post',           costToBuy = 30, sellFor = 15 },
            { propModel = 'p_horsehitchnbd01x',    displayName = 'metal post 2',         costToBuy = 30, sellFor = 15 },
        },
        shelf = {
            { propModel = 'p_shelf06x',       displayName = 'wooden cabinet',     costToBuy = 70, sellFor = 50 },
            { propModel = 'p_shelf09x',       displayName = 'simple shelf',       costToBuy = 70, sellFor = 50 },
            { propModel = 'p_shelf10x',       displayName = 'wooden shelf',       costToBuy = 70, sellFor = 50 },
            { propModel = 'p_shelflrg01x',    displayName = 'noble wooden shelf', costToBuy = 70, sellFor = 50 },
            { propModel = 'p_shelfpostal01x', displayName = 'telegram shelf',     costToBuy = 70, sellFor = 50 },
            { propModel = 'p_shelfmail01x',   displayName = 'letter cabinet',     costToBuy = 70, sellFor = 50 },
            { propModel = 'p_shelfwine01x',   displayName = 'letter cabinet 2',   costToBuy = 70, sellFor = 50 },
        },
        lights = {
            { propModel = 'p_lightpolenbx04x', displayName = 'Lightpole',   costToBuy = 20, sellFor = 10 },
            { propModel = 'p_lightpolenbx01x', displayName = 'Lightpole 2', costToBuy = 20, sellFor = 10 },
            { propModel = 'p_lightpolenbx02x', displayName = 'Lightpole 3', costToBuy = 20, sellFor = 10 },
            { propModel = 'p_lightpolenbx03x', displayName = 'Lightpole 4', costToBuy = 20, sellFor = 10 },
            { propModel = 'p_lightpost01x',    displayName = 'Lightpole 5', costToBuy = 20, sellFor = 10 },
            { propModel = 'p_lightpostnbx01x', displayName = 'Lightpole 6', costToBuy = 20, sellFor = 10 },
        }
    },
    -----------------------------------------------------

    -- These are jobs that will be able to make houses just like the admins can above useful for real estate jobs
    ALlowedJobs = {
        {
            jobname = '' --the job name
        },               --to add more just copy this table paste and change job name
    },
    -----------------------------------------------------
    -- TP Houses
    -- Here you need to add coordinates for interiors which doors cannot be open, you need to enter in the house with Noclip and get the coords
    -- Make sure you add the cordinates before create the TP House
    TpInteriors = {
        Interior1 = {
            exitCoords = { x = -1103.15, y = -2252.92, z = 50.65 },
            furnRadius = 10
        },
        Interior2 = {
            exitCoords = { x = -63.74, y = 14.05, z = 76.6 },
            furnRadius = 10
        },
        Interior3 = {
            exitCoords = { x = -60.36, y = 1238.86, z = 170.79 },
            furnRadius = 10
        }
    },
    DefaultSellPrice = 50000, -- Default sell price for houses
    DefaultSellPricetoPlayer = 50000, -- Default sell price for houses to a player
    HousesForSale = {
        {
            uniqueName = "cabin_braitwaite",       -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-2370.77587890625, 471.5861511230469, 132.2300262451172),
            houseRadiusLimit = 50,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line 
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                    --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},

            },
            invLimit = 1000,
            taxAmount = 1000,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-2375.032958984375, 476.5924987792969, 131.42164611816406),
            price = 80000,                       -- The price of the house
            sellPrice = 55000,                   -- Amount received when selling the house
            name = "House near Little Creek River", -- Name of the house for display
            forSaleBlips = true,
            saleBlipSprite = 'blip_ambient_quartermaster',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_20',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },
    },
    houseDealer = {
        {
            houseDealerBlip = true,
            CreateNPC = true,
            NpcCoords = vector3(-800.7, -1203.84, 44.19),
            NpcHeading = 192.57,
            BlipName = "House Dealer",
            BlipSprite = 'blip_mp_cash_checkpoint',
        },
    },
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
