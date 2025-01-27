Config = {
    -- Set your language here
    defaultlang = 'ua_lang',
    -----------------------------------------------------

    -- Set your admin group here
    adminGroup = 'admin',
    -----------------------------------------------------

    DevMode = true,                --False on live server
    DevModeCommand = "HousingDev", --This command need to be sent after restarting the resource
    -----------------------------------------------------

    --Maximum allowed houses per character
    Setup = {
        MaxHousePerChar = 1,
    },
    -----------------------------------------------------
    -----------------------------------------------------
    collectTaxes = false,
    -- Tax Day for checking the ledger and collect
    TaxDay = 26,      --This is the number day of each month that taxes will be collected on
    TaxResetDay = 27, --This MUST be the day after TaxDay set above!!! (do not change either of these dates if the current date is one of the 2 for ex if its the 22 or 23rd day do not change these dates it will break the code)
    -----------------------------------------------------

    -- Discord Webhooks
    WebhookLink = '',               --insert your webhook link here if you want webhooks
    WebhookTitle = 'BCC-Housing',
    WebhookAvatar = 'https://bcc-scripts.com/servericons/provision_jail_keys.png',
    -----------------------------------------------------

    doors = { -- Turn off/on the door buttons in house menu
        createNewDoors = true,
        removeDoors = true
    },

    -----------------------------------------------------

    -- Admin Commands
    AdminManagementMenuCommand = 'HousingManager', --the name of the command for admins to manage all houses
    EnablePrivatePropertyCheck = true,             -- Set to true to enable, false to disable, this is for if you want to see a message that you enterd on a private property
    keys = {
        manage = 'G',                              -- [G] Manage House
        collect = 'G',                             -- [G] Collect money from selling house
        buy = 'G',                                 -- [B] Buy house
    },
    -----------------------------------------------------
    UseImageAtBottomMenu = true,
    HouseImageURL = [[<img style="margin: 0 auto; max-width: 20vw; max-height: 15vh; width: auto; height: auto;" src="]] ..
        "https://bcc-scripts.com/servericons/provision_jail_keys.png" .. [[" />]],
    --<img width="750px" height="108px" style="margin: 0 auto;" src="https://bcc-scripts.com/servericons/ammo_arrow_tracking.png" /> -- Add your desired image URL here

    dontShowNames = true,

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
        {
            name = 'Cтільці',
            titile = 'Cтільці, крісла та табурети', -- Меню заголовок
            desc = "Переглянути асортимент стільців",
            { propModel = "p_chair20x", displayName = "Червоний стілець з розписом", costToBuy = 20, sellFor = 18 },
            { propModel = "p_chair38x", displayName = "Жовтий вишуканий стілець", costToBuy = 20, sellFor = 18 },
            { propModel = "p_chairdining01x", displayName = "Білий вишуканий стілець", costToBuy = 20, sellFor = 18 },
            { propModel = "p_chair06x", displayName = "Лакований стілець", costToBuy = 15, sellFor = 13 },
            { propModel = "p_diningchairs01x", displayName = "Стілець з підлокітниками", costToBuy = 15, sellFor = 13 },
            { propModel = "p_windsorchair03x", displayName = "Коричневий стілець", costToBuy = 15, sellFor = 13 },
            { propModel = "p_chair02x", displayName = "Старий синій стілець", costToBuy = 15, sellFor = 13 },
            { propModel = "s_bfchair04x", displayName = "Дерев'яний стілець", costToBuy = 15, sellFor = 13 },
            { propModel = "p_chair_cs05x", displayName = "Шліфований стілець", costToBuy = 15, sellFor = 13 },
            { propModel = "p_chairfolding02x", displayName = "Розкладний стілець", costToBuy = 5, sellFor = 4 },
            { propModel = "p_chair_crate02x", displayName = "Дерев'яний ящик", costToBuy = 3, sellFor = 2 },
            { propModel = "p_chairdesk02x", displayName = "Червоне шкіряне крісло", costToBuy = 40, sellFor = 38 },
            { propModel = "p_chairwicker02x", displayName = "Плетене крісло", costToBuy = 25, sellFor = 23 },
            { propModel = "p_chairrocking02x", displayName = "Крісло-гойдалка", costToBuy = 18, sellFor = 16 },
            { propModel = "p_stool07x", displayName = "Лакований табурет", costToBuy = 15, sellFor = 13 },
            { propModel = "p_stool01x", displayName = "Дерев'яний табурет", costToBuy = 12, sellFor = 11 },
            { propModel = "p_stool03x", displayName = "Затертий табурет", costToBuy = 5, sellFor = 4 },
        },
        {
            name = 'Лавки та лави',
            titile = 'Лавки та лави',
            desc = "Переглянути асортимент лавок",
            { propModel = "p_bench03x", displayName = "Саморобна лава", costToBuy = 10, sellFor = 8 },
            { propModel = "p_bench09x", displayName = "Дерев'яна лава", costToBuy = 15, sellFor = 13 },
            { propModel = "p_bench08bx", displayName = "Червона лава", costToBuy = 15, sellFor = 13 },
            { propModel = "p_benchannsaloon01x", displayName = "Лава з темного дерева", costToBuy = 25, sellFor = 23 },
            { propModel = "p_benchch01x", displayName = "Дерев'яна лавка", costToBuy = 25, sellFor = 23 },
            { propModel = "p_bench15x", displayName = "Міська лавка", costToBuy = 35, sellFor = 33 },
        },
        {
            name = 'Столи',
            titile = 'Столи',
            desc = "Переглянути асортимент столів",
            { propModel = "p_table04x", displayName = "Кухонний стіл", costToBuy = 15, sellFor = 13 },
            { propModel = "p_table55x", displayName = "Фарбований стіл", costToBuy = 30, sellFor = 28 },
            { propModel = "p_table51x", displayName = "Стіл з білою скатертиною", costToBuy = 30, sellFor = 28 },
            { propModel = "p_table14x", displayName = "Стіл з кольоровю скатертиною", costToBuy = 25, sellFor = 13 },
            { propModel = "p_table48x", displayName = "Дерев'яний стіл", costToBuy = 20, sellFor = 18 },
            { propModel = "p_table47x", displayName = "Малий дерев'яний стіл", costToBuy = 15, sellFor = 13 },
            { propModel = "p_table46x", displayName = "Старий дерев'яний стіл", costToBuy = 15, sellFor = 13 },
            { propModel = "p_table42_cs", displayName = "Старий дерев'яний столик", costToBuy = 10, sellFor = 8 },
            { propModel = "p_tablehob1x", displayName = "Поламаний стіл", costToBuy = 5, sellFor = 4 },
            { propModel = "p_desk14x", displayName = "Лакований стіл для паперів", costToBuy = 50, sellFor = 45 },
            { propModel = "p_desk04x", displayName = "Стіл для паперів", costToBuy = 45, sellFor = 43 },
            { propModel = "p_desk01x", displayName = "Робочій стіл", costToBuy = 25, sellFor = 23 },
            { propModel = "s_desk01x", displayName = "Старий робочій стіл", costToBuy = 15, sellFor = 13 },
        },
        {
            name = 'Ліжка та спальники',
            titile = 'Ліжка та спальники',
            desc = "Переглянути асортимент ліжок",
            { propModel = "p_bedrollopen03x", displayName = "Білий спальник", costToBuy = 10, sellFor = 8 },
            { propModel = "s_bedrollfurlined01x", displayName = "Червоний спальник", costToBuy = 10, sellFor = 8 },
            { propModel = "p_bedindian01x", displayName = "Саморобне ліжко", costToBuy = 10, sellFor = 8 },
            { propModel = "p_bed03x", displayName = "Старе ліжко", costToBuy = 15, sellFor = 13 },
            { propModel = "p_bed14x", displayName = "Брудне ліжко", costToBuy = 15, sellFor = 13 },
            { propModel = "p_bed21x", displayName = "Ліжко з синьою ковдрою", costToBuy = 30, sellFor = 28 },
            { propModel = "p_bed17x", displayName = "Ліжко з коричневою ковдрою", costToBuy = 30, sellFor = 28 },
            { propModel = "p_bed05x", displayName = "Ліжко з ажурною ковдрою", costToBuy = 40, sellFor = 38 },
            { propModel = "p_bed22x", displayName = "Високе ліжко", costToBuy = 50, sellFor = 48 },
            { propModel = "p_bed20madex", displayName = "Двоспальне ліжко", costToBuy = 80, sellFor = 78 },
        },
        {
            name = 'Меблі для зберігання',
            titile = 'Меблі для зберігання',
            desc = "Переглянути асортимент комодів",
            { propModel = "p_cupboard01x", displayName = "Стара навісна шкафчик", costToBuy = 5, sellFor = 4 },
            { propModel = "p_cupboard06x", displayName = "Стара синя тумба", costToBuy = 10, sellFor = 8 },
            { propModel = "p_cupboard03x", displayName = "Стара біла тумба", costToBuy = 10, sellFor = 8 },
            { propModel = "p_bookcase01x", displayName = "Великий буфет", costToBuy = 25, sellFor = 23 },
            { propModel = "p_cupboard02x", displayName = "Малий буфет", costToBuy = 20, sellFor = 18 },
            { propModel = "p_shelfwall02x", displayName = "Дерев'яна полиця", costToBuy = 5, sellFor = 4 },
            { propModel = "p_kitchenhutch01x", displayName = "Кухонний буфет", costToBuy = 30, sellFor = 28 },
            { propModel = "p_shelf06x", displayName = "Буфет з темного дерева", costToBuy = 40, sellFor = 38 },
            { propModel = "p_dresser11x", displayName = "Темний комод", costToBuy = 35, sellFor = 33 },
            { propModel = "p_shelfwall05x", displayName = "Лакована полиця", costToBuy = 10, sellFor = 9 },
            { propModel = "p_armoir08x", displayName = "Мала шафа", costToBuy = 30, sellFor = 28 },
            { propModel = "p_armoir04x", displayName = "Велика шафа", costToBuy = 40, sellFor = 38 },
            { propModel = "p_armoir07x", displayName = "Лакована шафа", costToBuy = 50, sellFor = 48 },
        },
        {
            name = 'Декор',
            titile = 'Декор',
            desc = "Переглянути асортимент всякої всячини",
            { propModel = "p_candlegroup05x", displayName = "Свічка", costToBuy = 1, sellFor = 0 },
            { propModel = "p_candlestand", displayName = "Підсвічник", costToBuy = 3, sellFor = 2 },
            { propModel = "s_interact_lantern01x", displayName = "Ліхтар", costToBuy = 10, sellFor = 9 },
            { propModel = "p_lanternstick09x", displayName = "Ліхтар на палиці", costToBuy = 10, sellFor = 9 },
            { propModel = "p_lamp25x", displayName = "Гасова лампа з накриттям", costToBuy = 10, sellFor = 9 },
            { propModel = "p_oillamp01x", displayName = "Гасова лампа", costToBuy = 8, sellFor = 7 },
            { propModel = "p_dressmirror01x", displayName = "Велике дзеркало", costToBuy = 35, sellFor = 33 },
            { propModel = "p_mirror03x", displayName = "Звичайне дзеркало", costToBuy = 20, sellFor = 18 },
            { propModel = "p_mirror_shave01x", displayName = "Дзеркало для гоління", costToBuy = 10, sellFor = 9 },
            { propModel = "p_hatstand01xng", displayName = "Вішак підлоговий", costToBuy = 15, sellFor = 13 },
            { propModel = "p_coatrack04x", displayName = "Вішак настінний", costToBuy = 10, sellFor = 9 },
            { propModel = "p_alarmclock01x", displayName = "Будильник", costToBuy = 35, sellFor = 33 },
            { propModel = "val_bank_clock", displayName = "Настійнний годдиник", costToBuy = 40, sellFor = 38 },
            { propModel = "p_wallclocklrg01x", displayName = "Великий годинник", costToBuy = 50, sellFor = 48 },
            { propModel = "p_pot_flowerarng01x", displayName = "Букет у горщику", costToBuy = 15, sellFor = 13 },
            { propModel = "p_pot_flowerarng05x", displayName = "Квіти у вазі", costToBuy = 15, sellFor = 13 },
            { propModel = "p_pot_flowerarng07x", displayName = "Рослина у горщику", costToBuy = 15, sellFor = 13 },
            { propModel = "p_pot_flowerarng11x", displayName = "Квіти у стакані", costToBuy = 3, sellFor = 2 },
            { propModel = "p_gunsmithprops20x", displayName = "Рога оленя", costToBuy = 20, sellFor = 18 },
            { propModel = "p_gunsmithprops17x", displayName = "Великі рога оленя", costToBuy = 30, sellFor = 28 },
        },
        {
            name = 'Кухня',
            titile = 'Кухня',
            desc = "Переглянути асортимент для кухні",
            { propModel = "p_sink02x", displayName = "Велика мийка з гідрантом", costToBuy = 90, sellFor = 88 },
            { propModel = "p_stove04x", displayName = "Буржуйка", costToBuy = 100, sellFor = 98 },
            { propModel = "p_stove06x", displayName = "Стара пічка", costToBuy = 120, sellFor = 118 },
            { propModel = "p_stove01x", displayName = "Велика пічка", costToBuy = 150, sellFor = 148 },
            { propModel = "p_cookingtools01x", displayName = "Настінне приладдя", costToBuy = 10, sellFor = 9 },
        },
        {
            name = 'Ванна кімната',
            titile = 'Ванна кімната',
            desc = "Переглянути асортимент для ванної кімнати",
            { propModel = "p_washtub02x", displayName = "Миска для купання", costToBuy = 10, sellFor = 9 },
            { propModel = "p_washbasin01x", displayName = "Старий умивальник", costToBuy = 15, sellFor = 13 },
            { propModel = "p_washbasndoctor01x", displayName = "Умивальник зі дзеркалом", costToBuy = 25, sellFor = 23 },
            { propModel = "p_sink03x", displayName = "Керамічний умивальник", costToBuy = 35, sellFor = 33 },
            { propModel = "p_bath02x", displayName = "Бронзова ванна", costToBuy = 250, sellFor = 248 },
            { propModel = "p_val_hotel_int_tub_01x", displayName = "Ванна обшита деревом", costToBuy = 100, sellFor = 98 },
            { propModel = "p_toiletchair01x", displayName = "Нічний туалет", costToBuy = 15, sellFor = 13 },
        },
        {
            name = "Подвір'я",
            titile = "Подвір'я",
            desc = "Переглянути асортимент для подвір'я",
            { propModel = "p_waterpump01x", displayName = "Залізний гідрант", costToBuy = 80, sellFor = 78 },
            { propModel = "p_wellpumpnbx01x", displayName = "Старий гідрант", costToBuy = 60, sellFor = 58 },
            { propModel = "p_hng_toi", displayName = "Вуличний туалет", costToBuy = 30, sellFor = 28 },
            { propModel = "p_hitchingpost01x", displayName = "Великий конов'яз", costToBuy = 10, sellFor = 9 },
            { propModel = "p_hitchingpost04x", displayName = "Малий конов'яз", costToBuy = 5, sellFor = 4 },
            { propModel = "p_toolbox01x", displayName = "Ящик з інструментами", costToBuy = 10, sellFor = 9 },
            { propModel = "p_group_barrelcor01", displayName = "Бочка з інструментами", costToBuy = 10, sellFor = 9 },
        },
        ------------------------------------------------------------------------------------
        --------------------------------- DEFAULT ------------------------------------------
        ------------------------------------------------------------------------------------
        --[[
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
        --]]
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
    playerMax = 2,
            tpInteriors = {
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
    DefaultSellPrice = 50000,         -- Default sell price for houses
    DefaultSellPricetoPlayer = 50000, -- Default sell price for houses to a player
    DefaultMenuManageRadius = 1.2,
    HousesForSale = {
        --[[{
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
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-2375.032958984375, 476.5924987792969, 131.42164611816406),
            menuRadius = 2.0,
            price = 80000,                       -- The price of the house
            sellPrice = 55000,                   -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "House near Little Creek River", -- Name of the house for display
            blipname = "House",
            forSaleBlips = true,
            saleBlipSprite = 'blip_ambient_quartermaster',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]

        -----
        ---New Houses--
        ----
        ---[[Біля стробері і Ованджили
        {
            uniqueName = "house0", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-2175.21, -251.55, 192.82),
            houseRadiusLimit = 20,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[3978905847,-1896437095,"p_doorsgl02x",-2175.6965332031,-248.17004394531,191.82453918457]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1000,
            taxAmount = 380,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-2180.92, -239.25, 191.85),
            menuRadius = 2.0,
            price = 3800, -- The price of the house
            sellPrice = 1900, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Ранчо у Великих Лугах
        {
            uniqueName = "house1", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-2568.88, 348.03, 151.45),
            houseRadiusLimit = 30,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1535511805,-542955242,"p_door04x",-2590.8410644531,457.83801269531,146.01396179199]', locked = true
                },
                {
                    doorinfo = '[3443681973,-1899748000,"p_door45x",-2587.4055175781,407.56143188477,148.00889587402]', locked = true
                },
                {
                    doorinfo = '[750242038,-1751819926,"p_gate_cattle01b",-2583.8364257813,413.82153320313,147.99279785156]', locked = true
                },
                {
                    doorinfo = '[3074780964,-1335979469,"p_door_prong_mans01x",-2570.5344238281,352.88461303711,150.5400390625]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 5000,
            taxAmount = 2000,
            playerMax = 10,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-2555.92, 474.91, 143.5),
            menuRadius = 2.0,
            price = 20000, -- The price of the house
            sellPrice = 10000, -- Amount received when selling the house
            rentalDeposit = 50, -- First Rental deposit in gold bars
            rentCharge = 25, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Ранчо біля річки Літл Крік
        {
            uniqueName = "house2", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-2173.65, 715.36, 122.62),
            houseRadiusLimit = 30,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[2212914984,-1497029950,"p_door37x",-2182.5109863281,716.46356201172,121.62875366211]', locked = true
                },
                {
                    doorinfo = '[2468163139,233569385,"p_door_barn02",-2211.3740234375,726.83837890625,121.957862854]', locked = true
                },
                {
                    doorinfo = '[2171243230,233569385,"p_door_barn02",-2215.2297363281,724.63256835938,121.957862854]', locked = true
                },
                {
                    doorinfo = '[2726022400,-559000589,"p_door_wornbarn_l",-2216.4638671875,745.06036376953,122.47724151611]', locked = true
                },
                {
                    doorinfo = '[3025858750,-336539838,"p_barn_door_l",-2228.8674316406,737.85589599609,122.49179077148]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 4000,
            taxAmount = 1400,
            playerMax = 8,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-2180.52, 672.45, 119.82),
            menuRadius = 2.0,
            price = 14000, -- The price of the house
            sellPrice = 7500, -- Amount received when selling the house
            rentalDeposit = 40, -- First Rental deposit in gold bars
            rentCharge = 20, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Хатинка мисливця біля річки Літл Крік
        {
            uniqueName = "house3", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-2458.92, 840.13, 146.39),
            houseRadiusLimit = 15,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[524178042,320723614,"p_bigvshk_door",-2460.435546875,839.11047363281,145.35720825195]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 300,
            taxAmount = 120,
            playerMax = 1,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-2458.29, 833.33, 141.9),
            menuRadius = 2.0,
            price = 1200, -- The price of the house
            sellPrice = 600, -- Amount received when selling the house
            rentalDeposit = 5, -- First Rental deposit in gold bars
            rentCharge = 2.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Хатинка біля Літл Крік
        {
            uniqueName = "house4", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-1818.27, 662.02, 131.87),
            houseRadiusLimit = 25,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1195519038,-1899748000,"p_door45x",-1815.1489257813,654.96380615234,130.88250732422]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1000,
            taxAmount = 390,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-1797.65, 641.27, 129.61),
            menuRadius = 2.0,
            price = 3900, -- The price of the house
            sellPrice = 1950, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[ Хатинка біля Строберi
        {
            uniqueName = "house5", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-1675.88, -340.27, 170.79),
            houseRadiusLimit = 25,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[2847752952,-628686073,"p_door_tax_shack01x",-1678.7446289063,-336.68927001953,172.99304199219]', locked = true
                },
                {
                    doorinfo = '[1963415953,-628686073,"p_door_tax_shack01x",-1682.8327636719,-340.61013793945,172.98583984375]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1200,
            taxAmount = 450,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-1673.04, -332.12, 173.1),
            menuRadius = 2.0,
            price = 4500, -- The price of the house
            sellPrice = 2250, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Ранчо біля Діабло Рідж
        {
            uniqueName = "house6", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-1675.88, -340.27, 170.79),
            houseRadiusLimit = 35,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1189146288,-542955242,"p_door04x",-615.93969726563,-27.086599349976,84.997604370117]', locked = true
                },
                {
                    doorinfo = '[906448125,-542955242,"p_door04x",-608.73846435547,-26.612947463989,84.997634887695]', locked = true
                },
                {
                    doorinfo = '[295238741,1354404235,"p_russlingbarnr01x",-630.84625244141,-54.67068862915,81.847953796387]', locked = true
                },
                {
                    doorinfo = '[4291451064,1049886767,"p_russlingbarnl01x",-627.5625,-54.382328033447,81.852699279785]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 2000,
            taxAmount = 800,
            playerMax = 5,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-622.36, -33.88, 85.3),
            menuRadius = 2.0,
            price = 8000, -- The price of the house
            sellPrice = 4000, -- Amount received when selling the house
            rentalDeposit = 25, -- First Rental deposit in gold bars
            rentCharge = 12.5, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Хатинка в Талл Тріс
        {
            uniqueName = "house7", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-2375.76, -1587.81, 154.27),
            houseRadiusLimit = 20,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1171581101,-1497029950,"p_door37x",-2374.3642578125,-1592.6021728516,153.29959106445]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 800,
            taxAmount = 250,
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-2364.74, -1590.5, 153.41),
            menuRadius = 2.0,
            price = 2500, -- The price of the house
            sellPrice = 1250, -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Хатинка на Манзаніта Пост
        {
            uniqueName = "house8", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-1979.21, -1665.52, 118.18),
            houseRadiusLimit = 15,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[3268076220,-1896437095,"p_doorsgl02x",-1976.1311035156,-1665.6566162109,117.19026947021]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 800,
            taxAmount = 350,
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-1975.25, -1658.78, 117.33),
            menuRadius = 2.0,
            price = 3500, -- The price of the house
            sellPrice = 1750, -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Хатинка Біля Аврори
        {
            uniqueName = "house9", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-2577.71, -1381.87, 149.25),
            houseRadiusLimit = 15,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '{562830153,-400005393,"p_door_wornbarn_r",-2575.826171875,-1379.3582763672,148.27227783203}', locked = true
                },
                {
                    doorinfo = '{663425326,-559000589,"p_door_wornbarn_l",-2578.7858886719,-1385.2464599609,148.26223754883}', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 800,
            taxAmount = 320,
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-2571.8, -1373.45, 149.27),
            menuRadius = 2.0,
            price = 3200, -- The price of the house
            sellPrice = 1600, -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Величезне ранчо Велитенські поля
        {
            uniqueName = "house10", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-1637.48, -1361.72, 84.42),
            houseRadiusLimit = 40,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo =
                    '[1606546482,-619255230,"p_door11x_beecher",-1646.2409667969,-1367.1358642578,83.465660095215]',
                    locked = true
                },
                {
                    doorinfo =
                    '[2310818050,-619255230,"p_door11x_beecher",-1637.7155761719,-1352.6480712891,83.466453552246]',
                    locked = true
                },
                {
                    doorinfo =
                    '[818583340,-619255230,"p_door11x_beecher",-1649.2072753906,-1359.2379150391,83.464546203613]',
                    locked = true
                },
                {
                    doorinfo =
                    '[673683647,-1560536379,"p_bee_barn_door_l",-1605.8223876953,-1411.5681152344,81.054786682129]',
                    locked = true
                },
                {
                    doorinfo =
                    '[630460389,-1560536379,"p_bee_barn_door_l",-1604.9971923828,-1409.8764648438,81.054786682129]',
                    locked = true
                },
                {
                    doorinfo = '[258275690,-1560536379,"p_bee_barn_door_l",-1596.84375,-1413.8291015625,81.054786682129]', locked = true
                },
                {
                    doorinfo =
                    '[1796845786,-1560536379,"p_bee_barn_door_l",-1597.6673583984,-1415.5177001953,81.054786682129]',
                    locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 5000,
            taxAmount = 2500,
            playerMax = 10,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-1660.09, -1499.86, 83.56),
            menuRadius = 2.0,
            price = 25000, -- The price of the house
            sellPrice = 12500, -- Amount received when selling the house
            rentalDeposit = 50, -- First Rental deposit in gold bars
            rentCharge = 25, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Недобудований порожній будинок Уолесс Стейшен
        {
            uniqueName = "house20", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-1551.6, 255.4, 114.8),
            houseRadiusLimit = 20,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[3221874820,1288759240,"p_door55x",-1556.2313232422,251.39234924316,113.81051635742]', locked = true
                },
                {
                    doorinfo = '[2366407202,1288759240,"p_door55x",-1550.3067626953,249.09503173828,113.80752563477]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1500,
            taxAmount = 500,
            playerMax = 4,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-1620.8, 234.76, 106.05),
            menuRadius = 2.0,
            price = 5000, -- The price of the house
            sellPrice = 2500, -- Amount received when selling the house
            rentalDeposit = 20, -- First Rental deposit in gold bars
            rentCharge = 10, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]

        -----------------------
        --- A M B A R I N O ---
        -----------------------

        ---[[Грізлі Вест біля річки Дакота
        {
            uniqueName = "house11", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-690.97, 1045.86, 135.06),
            houseRadiusLimit = 15,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1434140379,-1896437095,"p_doorsgl02x",-692.42681884766,1042.9229736328,134.02406311035]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 700,
            taxAmount = 250,
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-704.32, 1045.84, 134.23),
            menuRadius = 2.0,
            price = 2500, -- The price of the house
            sellPrice = 1225, -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Ранчо Бреніс Пас
        {
            uniqueName = "house12", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-394.48, 1726.56, 216.43),
            houseRadiusLimit = 35,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[3444471262,-312814636,"p_door44x",-389.57995605469,1730.2189941406,215.41470336914]', locked = true
                },
                {
                    doorinfo = '[4070066247,-312814636,"p_door44x",-398.64300537109,1722.3649902344,215.42929077148]', locked = true
                },
                {
                    doorinfo = '[3702071668,-2087217357,"p_doorsgl01x",-422.6643371582,1733.5697021484,215.59002685547]', locked = true
                },
                {
                    doorinfo = '[2605981527,-1293373789,"p_eme_barn_door3",-415.45394897461,1747.7584228516,215.28018188477]', locked = true
                },
                {
                    doorinfo = '[2763502110,-1293373789,"p_eme_barn_door3",-413.16644287109,1748.4916992188,215.28018188477]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 3000,
            taxAmount = 1200,
            playerMax = 8,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-400.93, 1708.36, 215.64),
            menuRadius = 2.0,
            price = 12000, -- The price of the house
            sellPrice = 6000, -- Amount received when selling the house
            rentalDeposit = 40, -- First Rental deposit in gold bars
            rentCharge = 20, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Окрігс Ран
        {
            uniqueName = "house13", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(1702.5, 1511.68, 147.88),
            houseRadiusLimit = 20,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[868379185,-2080420985,"p_door41x",1697.4683837891,1508.2376708984,146.8824005127]', locked = true
                },
                {
                    doorinfo = '[640077562,-2080420985,"p_door41x",1702.7976074219,1514.3333740234,146.87799072266]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1000,
            taxAmount = 400,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(1696.92, 1522.87, 146.82),
            menuRadius = 2.0,
            price = 4000, -- The price of the house
            sellPrice = 2000, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Трі Сістерс
        {
            uniqueName = "house14", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(1981.05, 1191.35, 171.4),
            houseRadiusLimit = 15,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[784290387,-198436444,"p_door02x",1981.9653320313,1195.0833740234,170.41778564453]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 700,
            taxAmount = 320,
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(1976.73, 1200.82, 172.28),
            menuRadius = 2.0,
            price = 3200, -- The price of the house
            sellPrice = 1600, -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Вежа біля Аннесубургу
        {
            uniqueName = "house15", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(1932.37, 1945.95, 266.1),
            houseRadiusLimit = 30,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1981171235,-1497029950,"p_door37x",1933.5963134766,1949.0305175781,265.11849975586]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1500,
            taxAmount = 600,
            playerMax = 4,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(1946.33, 1967.25, 261.4),
            menuRadius = 2.0,
            price = 6000, -- The price of the house
            sellPrice = 3000, -- Amount received when selling the house
            rentalDeposit = 20, -- First Rental deposit in gold bars
            rentCharge = 10, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Халупа біля Каірн Лейк
        {
            uniqueName = "house16", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-943.4, 2168.29, 342.19),
            houseRadiusLimit = 15,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[415985340,-2087217357,"p_doorsgl01x",-950.03857421875,2174.0383300781,341.24365234375]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 500,
            taxAmount = 100,
            playerMax = 1,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-957.28, 2174.83, 341.18),
            menuRadius = 2.0,
            price = 1000, -- The price of the house
            sellPrice = 500, -- Amount received when selling the house
            rentalDeposit = 5, -- First Rental deposit in gold bars
            rentCharge = 2.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Ранічо на північ від Колтера
        {
            uniqueName = "house17", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-552.62, 2702.75, 320.42),
            houseRadiusLimit = 40,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1482409867,-853275875,"p_door_emebarn02x",-570.38500976563,2702.14453125,319.67492675781]', locked = true
                },
                {
                    doorinfo = '[2051127971,495953578,"p_door_frghtslide01x",-536.39428710938,2675.3825683594,317.81826782227]', locked = true
                },
                {
                    doorinfo = '[2385374047,-58075500,"p_doorsnow01x",-557.96398925781,2708.9880371094,319.43182373047]', locked = true
                },
                {
                    doorinfo = '[872775928,1636287240,"p_doorsnow01x_c",-556.41680908203,2698.8635253906,319.38018798828]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 3000,
            taxAmount = 800,
            playerMax = 6,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-601.41, 2676.31, 323.69),
            menuRadius = 2.0,
            price = 8000, -- The price of the house
            sellPrice = 4000, -- Amount received when selling the house
            rentalDeposit = 30, -- First Rental deposit in gold bars
            rentCharge = 15, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Хатка Дедбут Крік
        {
            uniqueName = "house18", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-1963.36, 2158.4, 327.6),
            houseRadiusLimit = 15,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[943176298,-58075500,"p_doorsnow01x",-1959.1854248047,2160.2043457031,326.55380249023]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 700,
            taxAmount = 180,
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-1952.21, 2161.4, 326.81),
            menuRadius = 2.0,
            price = 1800, -- The price of the house
            sellPrice = 900, -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Вежа на горі Хаген
        {
            uniqueName = "house19", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-1488.83, 1248.61, 314.49),
            houseRadiusLimit = 20,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[2971757040,-58075500,"p_doorsnow01x",-1494.4030761719,1246.7662353516,313.5432434082]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1000,
            taxAmount = 280,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-1502.65, 1240.78, 312.8),
            menuRadius = 2.0,
            price = 2800, -- The price of the house
            sellPrice = 1400, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]

        ------------------------------
        --- N E W -- H A N O V E R ---
        ------------------------------

        ---[[Хатинка біля Флетнек Стейшен
        {
            uniqueName = "house21", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-63.72, -392.55, 72.22),
            houseRadiusLimit = 25,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo =
                    '[1299456376,1281919024,"ann_jail_main_door_01",-64.242599487305,-393.56112670898,71.248695373535]',
                    locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 800,
            taxAmount = 450,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-76.5, -404.42, 71.2),
            menuRadius = 2.0,
            price = 4500, -- The price of the house
            sellPrice = 2250, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Землянка на захід від Емеральд
        {
            uniqueName = "house22", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(906.42, 261.32, 116.0),
            houseRadiusLimit = 25,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1934463007,-1896437095,"p_doorsgl02x",900.34381103516,265.21841430664,115.04807281494]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1200,
            taxAmount = 550,
            playerMax = 4,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(899.49, 282.35, 116.29),
            menuRadius = 2.0,
            price = 5500, -- The price of the house
            sellPrice = 2250, -- Amount received when selling the house
            rentalDeposit = 20, -- First Rental deposit in gold bars
            rentCharge = 10, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Ранчо поруч з Хертланд Оверфлоу
        {
            uniqueName = "house23", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(1120.57, 492.46, 97.28),
            houseRadiusLimit = 50,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1239033969,-164490887,"p_door_val_genstore2",1114.0626220703,493.74633789063,96.290939331055]', locked = true
                },
                {
                    doorinfo = '[1597362984,1081626861,"p_door_wglass01x",1116.3991699219,485.99212646484,96.306297302246]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 3000,
            taxAmount = 1500,
            playerMax = 6,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(1098.37, 496.9, 95.38),
            menuRadius = 2.0,
            price = 15000, -- The price of the house
            sellPrice = 7500, -- Amount received when selling the house
            rentalDeposit = 30, -- First Rental deposit in gold bars
            rentCharge = 15, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Між Емереаль і Камасска Рівер
        {
            uniqueName = "house24", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(1887.14, 301.13, 77.07),
            houseRadiusLimit = 15,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[2821676992,-1896437095,"p_doorsgl02x",1888.1700439453,297.95916748047,76.076202392578]', locked = true
                },
                {
                    doorinfo = '[1510914117,-1896437095,"p_doorsgl02x",1891.0832519531,302.62200927734,76.091575622559]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 700,
            taxAmount = 350,
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(1876.94, 292.55, 76.05),
            menuRadius = 2.0,
            price = 3500, -- The price of the house
            sellPrice = 1750, -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Ранчо на березі Камасска Рівер
        {
            uniqueName = "house25", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(2233.67, -141.78, 47.62),
            houseRadiusLimit = 40,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1762076266,-2080420985,"p_door41x",2237.1235351563,-141.56480407715,46.626441955566]', locked = true
                },
                {
                    doorinfo = '[2689340659,-2080420985,"p_door41x",2235.5598144531,-147.06066894531,46.62866973877]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 3000,
            taxAmount = 1200,
            playerMax = 6,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(2224.7, -127.98, 47.63),
            menuRadius = 2.0,
            price = 12000, -- The price of the house
            sellPrice = 6000, -- Amount received when selling the house
            rentalDeposit = 30, -- First Rental deposit in gold bars
            rentCharge = 15, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Дім на березі біля Ван Хорну
        {
            uniqueName = "house26", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(2820.68, 274.05, 51.08),
            houseRadiusLimit = 20,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1431398235,-1800129672,"p_door36x",2820.5607910156,278.90881347656,50.09118270874]', locked = true
                },
                {
                    doorinfo = '[4275653891,-1800129672,"p_door36x",2824.4970703125,270.89910888672,47.120807647705]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 700,
            taxAmount = 280,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(2810.68, 289.01, 49.74),
            menuRadius = 2.0,
            price = 2800, -- The price of the house
            sellPrice = 1400, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Північніше Аннесбурга
        {
            uniqueName = "house27", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(3031.33, 1777.71, 84.13),
            houseRadiusLimit = 35,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1973911195,1433165496,"p_door60",3024.1213378906,1777.0731201172,83.169136047363]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1200,
            taxAmount = 400,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(3016.23, 1754.19, 83.3),
            menuRadius = 2.0,
            price = 4000, -- The price of the house
            sellPrice = 2000, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Ранчо над Нафтовиками
        {
            uniqueName = "house29", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(775.81, 844.9, 118.91),
            houseRadiusLimit = 40,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[4123766266,-1480058065,"p_door_rho_doctor",778.96936035156,849.52600097656,117.91557312012]', locked = true
                },
                {
                    doorinfo = '[417362979,1045059103,"p_door_val_jail02x",772.65289306641,841.26782226563,117.91557312012]', locked = true
                },
                {
                    doorinfo = '[1038094132,-385493140,"p_door_carmodydellbarn_new",773.16864013672,872.33294677734,119.96391296387]', locked = true
                },
                {
                    doorinfo = '[883522755,-385493140,"p_door_carmodydellbarn_new",775.0556640625,876.37341308594,119.96391296387]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 5000,
            taxAmount = 1800,
            playerMax = 8,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(793.48, 848.22, 117.7),
            menuRadius = 2.0,
            price = 18000, -- The price of the house
            sellPrice = 9000, -- Amount received when selling the house
            rentalDeposit = 40, -- First Rental deposit in gold bars
            rentCharge = 20, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Дім Камберленд форест низ
        {
            uniqueName = "house30", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(218.61, 984.56, 190.9),
            houseRadiusLimit = 75,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[3167931616,-1293373789,"p_eme_barn_door3",198.80244445801,985.02728271484,189.22232055664]', locked = true
                },
                {
                    doorinfo = '[160425541,-1293373789,"p_eme_barn_door3",198.37966918945,987.38555908203,189.22232055664]', locked = true
                },
                {
                    doorinfo = '[3598523785,-198436444,"p_door02x",215.80004882813,988.06512451172,189.9015045166]', locked = true
                },
                {
                    doorinfo = '[2031215067,-198436444,"p_door02x",222.8265838623,990.53399658203,189.9015045166]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 2000,
            taxAmount = 700,
            playerMax = 4,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(202.4, 963.14, 190.4),
            menuRadius = 2.0,
            price = 7000, -- The price of the house
            sellPrice = 3500, -- Amount received when selling the house
            rentalDeposit = 20, -- First Rental deposit in gold bars
            rentCharge = 10, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Дім Камберленд форест верх
        {
            uniqueName = "house31", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-64.91, 1238.89, 170.77),
            houseRadiusLimit = 75,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[202296518,-312814636,"p_door44x",-67.303237915039,1235.8376464844,169.76470947266]', locked = true
                },

                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1500,
            taxAmount = 600,
            playerMax = 4,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-73.79, 1230.05, 169.53),
            menuRadius = 2.0,
            price = 6000, -- The price of the house
            sellPrice = 3000, -- Amount received when selling the house
            rentalDeposit = 20, -- First Rental deposit in gold bars
            rentCharge = 10, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Ранчо Келібанс Сіт
        {
            uniqueName = "house32", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(-820.81, 355.01, 98.08),
            houseRadiusLimit = 100,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[1915887592,-198436444,"p_door02x",-818.61383056641,351.16165161133,97.108840942383]', locked = true
                },
                {
                    doorinfo = '[3324299212,-198436444,"p_door02x",-819.14367675781,358.73443603516,97.10627746582]', locked = true
                },
                {
                    doorinfo = '[74847256,-559000589,"p_door_wornbarn_l",-866.13610839844,336.54385375977,95.358184814453]', locked = true
                },
                {
                    doorinfo = '[314421415,-400005393,"p_door_wornbarn_r",-866.60192871094,333.91134643555,95.358184814453]', locked = true
                },
                {
                    doorinfo = '[374543565,-400005393,"p_door_wornbarn_r",-856.40496826172,334.82675170898,95.358184814453]', locked = true
                },
                {
                    doorinfo = '[2831333710,-559000589,"p_door_wornbarn_l",-856.88934326172,332.18124389648,95.359802246094]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --  doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 3500,
            taxAmount = 1400,
            playerMax = 5,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(-814.74, 340.2, 96.46),
            menuRadius = 2.0,
            price = 14000, -- The price of the house
            sellPrice = 7000, -- Amount received when selling the house
            rentalDeposit = 25, -- First Rental deposit in gold bars
            rentCharge = 12.5, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Халупа на захід від Ван Хорну
        {
            uniqueName = "house33", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(2716.12, 709.84, 79.52),
            houseRadiusLimit = 20,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[843137708,-312814636,"p_door44x",2716.8154296875,708.16693115234,78.605178833008]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 500,
            taxAmount = 250,
            playerMax = 2,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(2718.31, 702.96, 78.29),
            menuRadius = 2.0,
            price = 2500, -- The price of the house
            sellPrice = 1250, -- Amount received when selling the house
            rentalDeposit = 10, -- First Rental deposit in gold bars
            rentCharge = 5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        --[[Невелике Ранчо біля лісопилки Гановера
        {
            uniqueName = "house34", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(2991.98, 2194.01, 166.76),
            houseRadiusLimit = 50,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[344028824,-542955242,"p_door04x",2989.1081542969,2193.7414550781,165.73979187012]', locked = true
                },
                {
                    doorinfo = '[3731688048,-542955242,"p_door04x",2993.4243164063,2188.4375,165.73570251465]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 4000,
            taxAmount = 1300,
            playerMax = 5,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(2966.77, 2205.69, 166.19),
            menuRadius = 2.0,
            price = 13000, -- The price of the house
            sellPrice = 6500, -- Amount received when selling the house
            rentalDeposit = 25, -- First Rental deposit in gold bars
            rentCharge = 12.5, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Будинок Рибака
        {
            uniqueName = "house35", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(341.64, -664.92, 42.82),
            houseRadiusLimit = 30,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                {
                    doorinfo = '[3238637478,-542955242,"p_door04x",347.24737548828,-666.05346679688,41.822761535645]', locked = true
                },
                {
                    doorinfo = '[2933656395,-542955242,"p_door04x",338.25341796875,-669.94842529297,41.821144104004]', locked = true
                },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 1100,
            taxAmount = 450,
            playerMax = 3,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(352.73, -656.13, 41.98),
            menuRadius = 2.0,
            price = 4500, -- The price of the house
            sellPrice = 2250, -- Amount received when selling the house
            rentalDeposit = 15, -- First Rental deposit in gold bars
            rentCharge = 7.5, -- monthly rent in gold bars
            name = "Будинок", -- Name of the house for display
            blipname = "Будинок",
            forSaleBlips = true,
            saleBlipSprite = 'blip_robbery_home',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
        ---[[Ранчо Емеральд
        {
            uniqueName = "house36", -- Unique identifier for the house you can use any name make sure you dont use duplicates
            houseCoords = vector3(1463.52, 313.9, 90.54 - 1),
            houseRadiusLimit = 25,
            doors = {
                --Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in client folder)
                -- Do not copy the entire line from doorhashes
                -- Example if we have this line
                --[1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
                -- We need to copy only whats between {...}
                -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
                -- {
                --     doorinfo = '[344028824,-542955242,"p_door04x",2989.1081542969,2193.7414550781,165.73979187012]', locked = true
                -- },
                -- {
                --     doorinfo = '[3731688048,-542955242,"p_door04x",2993.4243164063,2188.4375,165.73570251465]', locked = true
                -- },
                --if the house have more than one door copy the above same as these below
                --{
                --doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
                --},
            },
            invLimit = 5000,
            taxAmount = 2000,
            playerMax = 8,
            tpInt = 0,
            tpInstance = 0,
            menuCoords = vector3(1432.27, 319.2, 88.77 - 1),
            menuRadius = 2.0,
            price = 20000, -- The price of the house
            sellPrice = 10000, -- Amount received when selling the house
            rentalDeposit = 40, -- First Rental deposit in gold bars
            rentCharge = 20, -- monthly rent in gold bars
            name = "Ранчо", -- Name of the house for display
            blipname = "Ранчо",
            forSaleBlips = true,
            saleBlipSprite = 'blip_mp_playlist_adversary',
            saleBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            canSell = true, -- Whether the player can sell the house later               -- Whether the player can sell the house later
            showmarker = true,
        },--]]
    },
    houseDealer = {
        --Bw
        {
            houseDealerBlip = true,
            CreateNPC = true,
            NpcCoords = vector3(-797.22, -1193.82, 43.95),
            NpcHeading = 205.37,
            BlipName = "Агент з нерухомості",
            BlipSprite = 'blip_ambient_quartermaster',
        },
        --Valentine
        {
            houseDealerBlip = true,
            CreateNPC = true,
            NpcCoords = vector3(-305.19, 772.39, 118.7 - 1),
            NpcHeading = 277.19,
            BlipName = "Агент з нерухомості",
            BlipSprite = 'blip_ambient_quartermaster',
        },
        --SD
        -- {
        --     houseDealerBlip = true,
        --     CreateNPC = true,
        --     NpcCoords = vector3(2647.08, -1294.95, 52.25 - 1),
        --     NpcHeading = 277.19,
        --     BlipName = "Агент з нерухомості",
        --     BlipSprite = 'blip_ambient_quartermaster',
        -- },

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
