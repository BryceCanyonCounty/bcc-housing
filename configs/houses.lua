Houses = {
    -----------------------------------------------------
    -- Near Strawberry and Owanjila
    -----------------------------------------------------
    {
        uniqueName = "house0",                            -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-2175.21, -251.55, 192.82), -- Coordinates of the house
        houseRadiusLimit = 20,                            -- Radius limit for the house
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[3978905847,-1896437095,"p_doorsgl02x",-2175.6965332031,-248.17004394531,191.82453918457]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1000,                                 -- Inventory limit for the house
        taxAmount = 380,                                 -- Tax amount for the house
        playerMax = 3,                                   -- Maximum number of players that can own the house
        tpInt = 0,                                       -- TP Interior ID
        tpInstance = 0,                                  -- TP Instance ID
        menuCoords = vector3(-2180.92, -239.25, 191.85), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                                -- Radius for the menu
        price = 3800,                                    -- The price of the house
        sellPrice = 1900,                                -- Amount received when selling the house
        rentalDeposit = 15,                              -- First Rental deposit in gold bars
        rentCharge = 7.5,                                -- Monthly rent in gold bars
        name = "House",                                  -- Name of the house for display
        canSell = true,                                  -- Whether the player can sell the house later
        showmarker = true,                               -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Ranch in the Great Plains
    -----------------------------------------------------
    {
        uniqueName = "house1", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-2568.88, 348.03, 151.45),
        houseRadiusLimit = 30,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1535511805,-542955242,"p_door04x",-2590.8410644531,-248.17004394531,146.01396179199]', locked = true
            },
            {
                doorinfo = '[3443681973,-1899748000,"p_door45x",-2587.4055175781,407.56143188477,148.00889537402]', locked = true
            },
            {
                doorinfo = '[750242038,-1751819926,"p_gate_cattle01b",-2583.8364257813,413.82153320313,147.99279785156]', locked = true
            },
            {
                doorinfo = '[3074780964,-1335979469,"p_door_prong_mans01x",-2570.5344238281,352.88461303711,150.5400390625]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 5000,                               -- Inventory limit for the house
        taxAmount = 2000,                              -- Tax amount for the house
        playerMax = 10,                                -- Maximum number of players that can own the house
        tpInt = 0,                                     -- TP Interior ID
        tpInstance = 0,                                -- TP Instance ID
        menuCoords = vector3(-2555.92, 474.91, 143.5), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                              -- Radius for the menu
        price = 20000,                                 -- The price of the house
        sellPrice = 10000,                             -- Amount received when selling the house
        rentalDeposit = 50,                            -- First Rental deposit in gold bars
        rentCharge = 25,                               -- Monthly rent in gold bars
        name = "Ranch",                                -- Name of the house for display
        canSell = true,                                -- Whether the player can sell the house later
        showmarker = true,                             -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Ranch near Little Creek River
    -----------------------------------------------------
    {
        uniqueName = "house2", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-2173.65, 715.36, 122.62),
        houseRadiusLimit = 30,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
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
                doorinfo = '[2726022400,-559000589,"p_door_wornbarn_l",-2216.4638671875,745.06036376953,122.47724111111]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 4000,                                -- Inventory limit for the house
        taxAmount = 1400,                               -- Tax amount for the house
        playerMax = 8,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-2180.52, 672.45, 119.82), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 14000,                                  -- The price of the house
        sellPrice = 7500,                               -- Amount received when selling the house
        rentalDeposit = 40,                             -- First Rental deposit in gold bars
        rentCharge = 20,                                -- Monthly rent in gold bars
        name = "Ranch",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Hunter's Hut near Little Creek River
    -----------------------------------------------------
    {
        uniqueName = "house3", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-2458.92, 840.13, 146.39),
        houseRadiusLimit = 15,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[524178042,320723614,"p_bigvshk_door",-2460.435546875,839.11047363281,145.35720825195]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 300,                                -- Inventory limit for the house
        taxAmount = 120,                               -- Tax amount for the house
        playerMax = 1,                                 -- Maximum number of players that can own the house
        tpInt = 0,                                     -- TP Interior ID
        tpInstance = 0,                                -- TP Instance ID
        menuCoords = vector3(-2458.29, 833.33, 141.9), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                              -- Radius for the menu
        price = 1200,                                  -- The price of the house
        sellPrice = 600,                               -- Amount received when selling the house
        rentalDeposit = 5,                             -- First Rental deposit in gold bars
        rentCharge = 2.5,                              -- Monthly rent in gold bars
        name = "House",                                -- Name of the house for display
        canSell = true,                                -- Whether the player can sell the house later
        showmarker = true,                             -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Hut near Little Creek
    -----------------------------------------------------
    {
        uniqueName = "house4", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-1818.27, 662.02, 131.87),
        houseRadiusLimit = 25,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1195519038,-1899748000,"p_door45x",-1815.1489257813,654.96380615234,130.88250732422]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1000,                                -- Inventory limit for the house
        taxAmount = 390,                                -- Tax amount for the house
        playerMax = 3,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-1797.65, 641.27, 129.61), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 3900,                                   -- The price of the house
        sellPrice = 1950,                               -- Amount received when selling the house
        rentalDeposit = 15,                             -- First Rental deposit in gold bars
        rentCharge = 7.5,                               -- Monthly rent in gold bars
        name = "House",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Hut near Strawberry
    -----------------------------------------------------
    {
        uniqueName = "house5", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-1675.88, -340.27, 170.79),
        houseRadiusLimit = 25,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[2847752952,-628686073,"p_door_tax_shack01x",-1678.7446289063,-336.68927001953,172.99304199219]', locked = true
            },
            {
                doorinfo = '[1963415953,-628686073,"p_door_tax_shack01x",-1682.8327636719,-340.61013793945,172.98583984375]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1200,                                -- Inventory limit for the house
        taxAmount = 450,                                -- Tax amount for the house
        playerMax = 3,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-1673.04, -332.12, 173.1), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 4500,                                   -- The price of the house
        sellPrice = 2250,                               -- Amount received when selling the house
        rentalDeposit = 15,                             -- First Rental deposit in gold bars
        rentCharge = 7.5,                               -- Monthly rent in gold bars
        name = "House",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Ranch near Diablo Ridge
    -----------------------------------------------------
    {
        uniqueName = "house6", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-613.23, -26.92, 85.98),
        houseRadiusLimit = 35,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
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
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 2000,                             -- Inventory limit for the house
        taxAmount = 800,                             -- Tax amount for the house
        playerMax = 5,                               -- Maximum number of players that can own the house
        tpInt = 0,                                   -- TP Interior ID
        tpInstance = 0,                              -- TP Instance ID
        menuCoords = vector3(-622.36, -33.88, 85.3), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                            -- Radius for the menu
        price = 8000,                                -- The price of the house
        sellPrice = 4000,                            -- Amount received when selling the house
        rentalDeposit = 25,                          -- First Rental deposit in gold bars
        rentCharge = 12.5,                           -- Monthly rent in gold bars
        name = "Ranch",                              -- Name of the house for display
        canSell = true,                              -- Whether the player can sell the house later
        showmarker = true,                           -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Hut near Aurora
    -----------------------------------------------------
    {
        uniqueName = "house9", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-2577.71, -1381.87, 149.25),
        houseRadiusLimit = 15,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '{562830153,-400005393,"p_door_wornbarn_r",-2575.826171875,-1379.3582763672,148.27227783203]', locked = true
            },
            {
                doorinfo = '{663425326,-559000589,"p_door_wornbarn_l",-2578.7858886719,-1385.2464599609,148.26223754883]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 800,                                  -- Inventory limit for the house
        taxAmount = 320,                                 -- Tax amount for the house
        playerMax = 2,                                   -- Maximum number of players that can own the house
        tpInt = 0,                                       -- TP Interior ID
        tpInstance = 0,                                  -- TP Instance ID
        menuCoords = vector3(-2571.8, -1373.45, 149.27), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                                -- Radius for the menu
        price = 3200,                                    -- The price of the house
        sellPrice = 1600,                                -- Amount received when selling the house
        rentalDeposit = 10,                              -- First Rental deposit in gold bars
        rentCharge = 5,                                  -- Monthly rent in gold bars
        name = "House",                                  -- Name of the house for display
        canSell = true,                                  -- Whether the player can sell the house later
        showmarker = true,                               -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Great Ranch of the Great Plains
    -----------------------------------------------------
    {
        uniqueName = "house10", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-1637.48, -1361.72, 84.42),
        houseRadiusLimit = 40,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1606546482,-619255230,"p_door11x_beecher",-1646.2409667969,-1367.1358642578,83.465660095215]', locked = true
            },
            {
                doorinfo = '[2310818050,-619255230,"p_door11x_beecher",-1637.7155761719,-1352.6480712891,83.466453552246]', locked = true
            },
            {
                doorinfo = '[818583340,-619255230,"p_door11x_beecher",-1649.2072753906,-1359.2379150391,83.464546203613]', locked = true
            },
            {
                doorinfo = '[673683647,-1560536379,"p_bee_barn_door_l",-1605.8223876953,-1411.5681152344,81.054786682129]', locked = true
            },
            {
                doorinfo = '[630460389,-1560536379,"p_bee_barn_door_l",-1604.9971923828,-1409.8764648438,81.054786682129]', locked = true
            },
            {
                doorinfo = '[258275690,-1560536379,"p_bee_barn_door_l",-1596.84375,-1413.8291015625,81.054786682129]', locked = true
            },
            {
                doorinfo = '[1796845786,-1560536379,"p_bee_barn_door_l",-1597.6673583984,-1415.5177001953,81.054786682129]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 5000,                                 -- Inventory limit for the house
        taxAmount = 2500,                                -- Tax amount for the house
        playerMax = 10,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                       -- TP Interior ID
        tpInstance = 0,                                  -- TP Instance ID
        menuCoords = vector3(-1660.09, -1499.86, 83.56), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                                -- Radius for the menu
        price = 25000,                                   -- The price of the house
        sellPrice = 12500,                               -- Amount received when selling the house
        rentalDeposit = 50,                              -- First Rental deposit in gold bars
        rentCharge = 25,                                 -- Monthly rent in gold bars
        name = "Ranch",                                  -- Name of the house for display
        canSell = true,                                  -- Whether the player can sell the house later
        showmarker = true,                               -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Unfinished empty house at Wallace Station
    -----------------------------------------------------
    {
        uniqueName = "house20", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-1551.6, 255.4, 114.8),
        houseRadiusLimit = 20,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[3221874820,1288759240,"p_door55x",-1556.2313232422,251.39234924316,113.81051635742]', locked = true
            },
            {
                doorinfo = '[2366407202,1288759240,"p_door55x",-1550.3067626953,249.09503173828,113.80752563477]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1500,                               -- Inventory limit for the house
        taxAmount = 500,                               -- Tax amount for the house
        playerMax = 4,                                 -- Maximum number of players that can own the house
        tpInt = 0,                                     -- TP Interior ID
        tpInstance = 0,                                -- TP Instance ID
        menuCoords = vector3(-1620.8, 234.76, 106.05), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                              -- Radius for the menu
        price = 5000,                                  -- The price of the house
        sellPrice = 2500,                              -- Amount received when selling the house
        rentalDeposit = 20,                            -- First Rental deposit in gold bars
        rentCharge = 10,                               -- Monthly rent in gold bars
        name = "House",                                -- Name of the house for display
        canSell = true,                                -- Whether the player can sell the house later
        showmarker = true,                             -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------
    --- A M B A R I N O ---
    -----------------------

    -----------------------------------------------------
    -- Grizzly West near Dakota River
    -----------------------------------------------------
    {
        uniqueName = "house11", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-690.97, 1045.86, 135.06),
        houseRadiusLimit = 15,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1434140379,-1896437095,"p_doorsgl02x",-692.42681884766,1042.9591674804,134.02406311035]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 700,                                 -- Inventory limit for the house
        taxAmount = 250,                                -- Tax amount for the house
        playerMax = 2,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-704.32, 1045.84, 134.23), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 2500,                                   -- The price of the house
        sellPrice = 1225,                               -- Amount received when selling the house
        rentalDeposit = 10,                             -- First Rental deposit in gold bars
        rentCharge = 5,                                 -- Monthly rent in gold bars
        name = "House",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Brandywine Drop Ranch
    -----------------------------------------------------
    {
        uniqueName = "house12", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-394.48, 1726.56, 216.43),
        houseRadiusLimit = 35,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
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
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 3000,                                -- Inventory limit for the house
        taxAmount = 1200,                               -- Tax amount for the house
        playerMax = 8,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-400.93, 1708.36, 215.64), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 12000,                                  -- The price of the house
        sellPrice = 6000,                               -- Amount received when selling the house
        rentalDeposit = 40,                             -- First Rental deposit in gold bars
        rentCharge = 20,                                -- Monthly rent in gold bars
        name = "Ranch",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- O'Creagh's Run
    -----------------------------------------------------
    {
        uniqueName = "house13", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(1702.5, 1511.68, 147.88),
        houseRadiusLimit = 20,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[868379185,-2080420985,"p_door41x",1697.4683837891,1508.2376708984,146.8824005127]', locked = true
            },
            {
                doorinfo = '[640077562,-2080420985,"p_door41x",1702.7976074219,1514.3333740234,146.87799072266]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1000,                                -- Inventory limit for the house
        taxAmount = 400,                                -- Tax amount for the house
        playerMax = 3,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(1696.92, 1522.87, 146.82), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 4000,                                   -- The price of the house
        sellPrice = 2000,                               -- Amount received when selling the house
        rentalDeposit = 15,                             -- First Rental deposit in gold bars
        rentCharge = 7.5,                               -- Monthly rent in gold bars
        name = "House",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Three Sisters
    -----------------------------------------------------
    {
        uniqueName = "house14", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(1981.05, 1191.35, 171.4),
        houseRadiusLimit = 15,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[784290387,-198436444,"p_door02x",1981.9653320313,1195.0833740234,170.41778564453]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 700,                                 -- Inventory limit for the house
        taxAmount = 320,                                -- Tax amount for the house
        playerMax = 2,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(1976.73, 1200.82, 172.28), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 3200,                                   -- The price of the house
        sellPrice = 1600,                               -- Amount received when selling the house
        rentalDeposit = 10,                             -- First Rental deposit in gold bars
        rentCharge = 5,                                 -- Monthly rent in gold bars
        name = "House",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Tower near Annesburg
    -----------------------------------------------------
    {
        uniqueName = "house15", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(1932.37, 1945.95, 266.1),
        houseRadiusLimit = 30,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1981171235,-1497029950,"p_door37x",1933.5963134766,1949.0305175781,265.11849975586]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1500,                               -- Inventory limit for the house
        taxAmount = 600,                               -- Tax amount for the house
        playerMax = 4,                                 -- Maximum number of players that can own the house
        tpInt = 0,                                     -- TP Interior ID
        tpInstance = 0,                                -- TP Instance ID
        menuCoords = vector3(1946.33, 1967.25, 261.4), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                              -- Radius for the menu
        price = 6000,                                  -- The price of the house
        sellPrice = 3000,                              -- Amount received when selling the house
        rentalDeposit = 20,                            -- First Rental deposit in gold bars
        rentCharge = 10,                               -- Monthly rent in gold bars
        name = "House",                                -- Name of the house for display
        canSell = true,                                -- Whether the player can sell the house later
        showmarker = true,                             -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Hut near Cairn Lake
    -----------------------------------------------------
    {
        uniqueName = "house16", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-943.4, 2168.29, 342.19),
        houseRadiusLimit = 15,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[415985340,-2087217357,"p_doorsgl01x",-950.03857421875,2174.0383300781,341.24365234375]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 500,                                 -- Inventory limit for the house
        taxAmount = 100,                                -- Tax amount for the house
        playerMax = 1,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-957.28, 2174.83, 341.18), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 1000,                                   -- The price of the house
        sellPrice = 500,                                -- Amount received when selling the house
        rentalDeposit = 5,                              -- First Rental deposit in gold bars
        rentCharge = 2.5,                               -- Monthly rent in gold bars
        name = "House",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Ranch north of Colter
    -----------------------------------------------------
    {
        uniqueName = "house17", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-552.62, 2702.75, 320.42),
        houseRadiusLimit = 40,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
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
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 3000,                                -- Inventory limit for the house
        taxAmount = 800,                                -- Tax amount for the house
        playerMax = 6,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-601.41, 2676.31, 323.69), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 8000,                                   -- The price of the house
        sellPrice = 4000,                               -- Amount received when selling the house
        rentalDeposit = 30,                             -- First Rental deposit in gold bars
        rentCharge = 15,                                -- Monthly rent in gold bars
        name = "Ranch",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Hut near Deadboot Creek
    -----------------------------------------------------
    {
        uniqueName = "house18", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-1963.36, 2158.4, 327.6),
        houseRadiusLimit = 15,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[943176298,-58075500,"p_doorsnow01x",-1959.1854248047,2160.2043457031,326.55380249023]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 700,                                 -- Inventory limit for the house
        taxAmount = 180,                                -- Tax amount for the house
        playerMax = 2,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-1952.21, 2161.4, 326.81), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 1800,                                   -- The price of the house
        sellPrice = 900,                                -- Amount received when selling the house
        rentalDeposit = 10,                             -- First Rental deposit in gold bars
        rentCharge = 5,                                 -- Monthly rent in gold bars
        name = "House",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Tower on Mount Hagen
    -----------------------------------------------------
    {
        uniqueName = "house19", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-1488.83, 1248.61, 314.49),
        houseRadiusLimit = 20,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[2971757040,-58075500,"p_doorsnow01x",-1494.4030761719,1246.7662353516,313.5432434082]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1000,                                -- Inventory limit for the house
        taxAmount = 280,                                -- Tax amount for the house
        playerMax = 3,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(-1502.65, 1240.78, 312.8), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 2800,                                   -- The price of the house
        sellPrice = 1400,                               -- Amount received when selling the house
        rentalDeposit = 15,                             -- First Rental deposit in gold bars
        rentCharge = 7.5,                               -- Monthly rent in gold bars
        name = "House",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    ------------------------------
    --- N E W -- H A N O V E R ---
    ------------------------------

    -----------------------------------------------------
    -- Hut near Flatneck Station
    -----------------------------------------------------
    {
        uniqueName = "house21", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-63.72, -392.55, 72.22),
        houseRadiusLimit = 25,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1299456376,1281919024,"ann_jail_main_door_01",-64.242599987305,-393.56112670898,71.248695373535]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 800,                             -- Inventory limit for the house
        taxAmount = 450,                            -- Tax amount for the house
        playerMax = 3,                              -- Maximum number of players that can own the house
        tpInt = 0,                                  -- TP Interior ID
        tpInstance = 0,                             -- TP Instance ID
        menuCoords = vector3(-76.5, -404.42, 71.2), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                           -- Radius for the menu
        price = 4500,                               -- The price of the house
        sellPrice = 2250,                           -- Amount received when selling the house
        rentalDeposit = 15,                         -- First Rental deposit in gold bars
        rentCharge = 7.5,                           -- Monthly rent in gold bars
        name = "House",                             -- Name of the house for display
        canSell = true,                             -- Whether the player can sell the house later
        showmarker = true,                          -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Burrow west of Emerald
    -----------------------------------------------------
    {
        uniqueName = "house22", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(906.42, 261.32, 116.0),
        houseRadiusLimit = 25,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1934463007,-1896437095,"p_doorsgl02x",900.34381103516,265.21841430664,115.04807281494]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1200,                              -- Inventory limit for the house
        taxAmount = 550,                              -- Tax amount for the house
        playerMax = 4,                                -- Maximum number of players that can own the house
        tpInt = 0,                                    -- TP Interior ID
        tpInstance = 0,                               -- TP Instance ID
        menuCoords = vector3(899.49, 282.35, 116.29), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                             -- Radius for the menu
        price = 5500,                                 -- The price of the house
        sellPrice = 2250,                             -- Amount received when selling the house
        rentalDeposit = 20,                           -- First Rental deposit in gold bars
        rentCharge = 10,                              -- Monthly rent in gold bars
        name = "House",                               -- Name of the house for display
        canSell = true,                               -- Whether the player can sell the house later
        showmarker = true,                            -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Ranch near Heartland Overflow
    -----------------------------------------------------
    {
        uniqueName = "house23", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(1120.57, 492.46, 97.28),
        houseRadiusLimit = 50,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1239033969,-164490887,"p_door_val_genstore2",1114.0626220703,493.74633789063,96.290939331055]', locked = true
            },
            {
                doorinfo = '[1597362984,1081626861,"p_door_wglass01x",1116.3991699219,485.99212646484,96.306297302246]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 3000,                             -- Inventory limit for the house
        taxAmount = 1500,                            -- Tax amount for the house
        playerMax = 6,                               -- Maximum number of players that can own the house
        tpInt = 0,                                   -- TP Interior ID
        tpInstance = 0,                              -- TP Instance ID
        menuCoords = vector3(1098.37, 496.9, 95.38), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                            -- Radius for the menu
        price = 15000,                               -- The price of the house
        sellPrice = 7500,                            -- Amount received when selling the house
        rentalDeposit = 30,                          -- First Rental deposit in gold bars
        rentCharge = 15,                             -- Monthly rent in gold bars
        name = "Ranch",                              -- Name of the house for display
        canSell = true,                              -- Whether the player can sell the house later
        showmarker = true,                           -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Between Emerald and Kamassa River
    -----------------------------------------------------
    {
        uniqueName = "house24", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(1887.14, 301.13, 77.07),
        houseRadiusLimit = 15,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[2821676992,-1896437095,"p_doorsgl02x",1888.1700439453,297.95916748047,76.076202392578]', locked = true
            },
            {
                doorinfo = '[1510914117,-1896437095,"p_doorsgl02x",1891.0832519531,302.62200927734,76.091575622559]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 700,                               -- Inventory limit for the house
        taxAmount = 350,                              -- Tax amount for the house
        playerMax = 2,                                -- Maximum number of players that can own the house
        tpInt = 0,                                    -- TP Interior ID
        tpInstance = 0,                               -- TP Instance ID
        menuCoords = vector3(1876.94, 292.55, 76.05), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                             -- Radius for the menu
        price = 3500,                                 -- The price of the house
        sellPrice = 1750,                             -- Amount received when selling the house
        rentalDeposit = 10,                           -- First Rental deposit in gold bars
        rentCharge = 5,                               -- Monthly rent in gold bars
        name = "House",                               -- Name of the house for display
        canSell = true,                               -- Whether the player can sell the house later
        showmarker = true,                            -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Ranch on the banks of Kamassa River
    -----------------------------------------------------
    {
        uniqueName = "house25", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(2233.67, -141.78, 47.62),
        houseRadiusLimit = 40,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1762076266,-2080420985,"p_door41x",2237.1235351563,-141.56480407715,46.626441955566]', locked = true
            },
            {
                doorinfo = '[2689340659,-2080420985,"p_door41x",2235.5598144531,-147.06066894531,46.62866973877]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 3000,                              -- Inventory limit for the house
        taxAmount = 1200,                             -- Tax amount for the house
        playerMax = 6,                                -- Maximum number of players that can own the house
        tpInt = 0,                                    -- TP Interior ID
        tpInstance = 0,                               -- TP Instance ID
        menuCoords = vector3(2224.7, -127.98, 47.63), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                             -- Radius for the menu
        price = 12000,                                -- The price of the house
        sellPrice = 6000,                             -- Amount received when selling the house
        rentalDeposit = 30,                           -- First Rental deposit in gold bars
        rentCharge = 15,                              -- Monthly rent in gold bars
        name = "Ranch",                               -- Name of the house for display
        canSell = true,                               -- Whether the player can sell the house later
        showmarker = true,                            -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- House on the shore near Van Horn
    -----------------------------------------------------
    {
        uniqueName = "house26", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(2820.68, 274.05, 51.08),
        houseRadiusLimit = 20,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1431398235,-1800129672,"p_door36x",2820.5607910156,278.90881347656,50.09118270874]', locked = true
            },
            {
                doorinfo = '[4275653891,-1800129672,"p_door36x",2824.4970703125,270.89910888672,47.120807647705]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 700,                               -- Inventory limit for the house
        taxAmount = 2800,                             -- Tax amount for the house
        playerMax = 3,                                -- Maximum number of players that can own the house
        tpInt = 0,                                    -- TP Interior ID
        tpInstance = 0,                               -- TP Instance ID
        menuCoords = vector3(2810.68, 289.01, 49.74), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                             -- Radius for the menu
        price = 2800,                                 -- The price of the house
        sellPrice = 1400,                             -- Amount received when selling the house
        rentalDeposit = 15,                           -- First Rental deposit in gold bars
        rentCharge = 7.5,                             -- Monthly rent in gold bars
        name = "House",                               -- Name of the house for display
        canSell = true,                               -- Whether the player can sell the house later
        showmarker = true,                            -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- North of Annesburg
    -----------------------------------------------------
    {
        uniqueName = "house27", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(3031.33, 1777.71, 84.13),
        houseRadiusLimit = 35,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[1973911195,1433165496,"p_door60",3024.1213378906,1777.0731201172,83.169136047363]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1200,                              -- Inventory limit for the house
        taxAmount = 400,                              -- Tax amount for the house
        playerMax = 3,                                -- Maximum number of players that can own the house
        tpInt = 0,                                    -- TP Interior ID
        tpInstance = 0,                               -- TP Instance ID
        menuCoords = vector3(3016.23, 1754.19, 83.3), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                             -- Radius for the menu
        price = 4000,                                 -- The price of the house
        sellPrice = 2000,                             -- Amount received when selling the house
        rentalDeposit = 15,                           -- First Rental deposit in gold bars
        rentCharge = 7.5,                             -- Monthly rent in gold bars
        name = "House",                               -- Name of the house for display
        canSell = true,                               -- Whether the player can sell the house later
        showmarker = true,                            -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Ranch above the Oil Fields
    -----------------------------------------------------
    {
        uniqueName = "house29", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(775.81, 844.9, 118.91),
        houseRadiusLimit = 40,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[4123766266,-1480058065,"p_door_rho_doctor",778.96936035156,849.52600097656,117.91557358398]', locked = true
            },
            {
                doorinfo = '[417362979,1045059103,"p_door_val_jail02x",772.65289366641,841.26782226563,117.91557358398]', locked = true
            },
            {
                doorinfo = '[1038094132,-385493140,"p_door_carmodydellbarn_new",773.16864013672,872.33294677734,119.96391296387]', locked = true
            },
            {
                doorinfo = '[883522755,-385493140,"p_door_carmodydellbarn_new",775.56634521484,876.37341308594,119.96391296387]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 5000,                             -- Inventory limit for the house
        taxAmount = 1800,                            -- Tax amount for the house
        playerMax = 8,                               -- Maximum number of players that can own the house
        tpInt = 0,                                   -- TP Interior ID
        tpInstance = 0,                              -- TP Instance ID
        menuCoords = vector3(793.48, 848.22, 117.7), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                            -- Radius for the menu
        price = 18000,                               -- The price of the house
        sellPrice = 9000,                            -- Amount received when selling the house
        rentalDeposit = 40,                          -- First Rental deposit in gold bars
        rentCharge = 20,                             -- Monthly rent in gold bars
        name = "Ranch",                              -- Name of the house for display
        canSell = true,                              -- Whether the player can sell the house later
        showmarker = true,                           -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- House in Cumberland Forest Lower
    -----------------------------------------------------
    {
        uniqueName = "house30", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(218.61, 984.56, 190.9),
        houseRadiusLimit = 75,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
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
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 2000,                            -- Inventory limit for the house
        taxAmount = 700,                            -- Tax amount for the house
        playerMax = 4,                              -- Maximum number of players that can own the house
        tpInt = 0,                                  -- TP Interior ID
        tpInstance = 0,                             -- TP Instance ID
        menuCoords = vector3(202.4, 963.14, 190.4), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                           -- Radius for the menu
        price = 7000,                               -- The price of the house
        sellPrice = 3500,                           -- Amount received when selling the house
        rentalDeposit = 20,                         -- First Rental deposit in gold bars
        rentCharge = 10,                            -- Monthly rent in gold bars
        name = "House",                             -- Name of the house for display
        canSell = true,                             -- Whether the player can sell the house later
        showmarker = true,                          -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- House in Cumberland Forest Upper
    -----------------------------------------------------
    {
        uniqueName = "house31", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-64.9, 1237.65, 170.77),
        houseRadiusLimit = 75,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[202296518,-312814636,"p_door44x",-67.303237915039,1235.8376464844,169.76470947266]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1500,                               -- Inventory limit for the house
        taxAmount = 600,                               -- Tax amount for the house
        playerMax = 4,                                 -- Maximum number of players that can own the house
        tpInt = 0,                                     -- TP Interior ID
        tpInstance = 0,                                -- TP Instance ID
        menuCoords = vector3(-73.79, 1230.05, 169.53), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                              -- Radius for the menu
        price = 6000,                                  -- The price of the house
        sellPrice = 3000,                              -- Amount received when selling the house
        rentalDeposit = 20,                            -- First Rental deposit in gold bars
        rentCharge = 10,                               -- Monthly rent in gold bars
        name = "House",                                -- Name of the house for display
        canSell = true,                                -- Whether the player can sell the house later
        showmarker = true,                             -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Ranch near Keliban's Run
    -----------------------------------------------------
    {
        uniqueName = "house32", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(-820.81, 355.01, 98.08),
        houseRadiusLimit = 100,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
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
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 3500,                             -- Inventory limit for the house
        taxAmount = 1400,                            -- Tax amount for the house
        playerMax = 5,                               -- Maximum number of players that can own the house
        tpInt = 0,                                   -- TP Interior ID
        tpInstance = 0,                              -- TP Instance ID
        menuCoords = vector3(-814.74, 340.2, 96.46), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                            -- Radius for the menu
        price = 14000,                               -- The price of the house
        sellPrice = 7000,                            -- Amount received when selling the house
        rentalDeposit = 25,                          -- First Rental deposit in gold bars
        rentCharge = 12.5,                           -- Monthly rent in gold bars
        name = "Ranch",                              -- Name of the house for display
        canSell = true,                              -- Whether the player can sell the house later
        showmarker = true,                           -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Hut west of Van Horn
    -----------------------------------------------------
    {
        uniqueName = "house33", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(2716.12, 709.84, 79.52),
        houseRadiusLimit = 20,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[843137708,-312814636,"p_door44x",2716.8154296875,708.16693115234,78.605178833008]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 500,                               -- Inventory limit for the house
        taxAmount = 250,                              -- Tax amount for the house
        playerMax = 2,                                -- Maximum number of players that can own the house
        tpInt = 0,                                    -- TP Interior ID
        tpInstance = 0,                               -- TP Instance ID
        menuCoords = vector3(2718.31, 702.96, 78.29), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                             -- Radius for the menu
        price = 2500,                                 -- The price of the house
        sellPrice = 1250,                             -- Amount received when selling the house
        rentalDeposit = 10,                           -- First Rental deposit in gold bars
        rentCharge = 5,                               -- Monthly rent in gold bars
        name = "House",                               -- Name of the house for display
        canSell = true,                               -- Whether the player can sell the house later
        showmarker = true,                            -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Small Ranch near Lumber Mill
    -----------------------------------------------------
    {
        uniqueName = "house34", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(2991.98, 2194.01, 166.76),
        houseRadiusLimit = 50,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[344028824,-542955242,"p_door04x",2989.1081542969,2193.7414550781,165.73979187012]', locked = true
            },
            {
                doorinfo = '[3731688048,-542955242,"p_door04x",2993.4243164063,2188.4375,165.73570251465]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 4000,                                -- Inventory limit for the house
        taxAmount = 1300,                               -- Tax amount for the house
        playerMax = 5,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(2966.77, 2205.69, 166.19), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 13000,                                  -- The price of the house
        sellPrice = 6500,                               -- Amount received when selling the house
        rentalDeposit = 25,                             -- First Rental deposit in gold bars
        rentCharge = 12.5,                              -- Monthly rent in gold bars
        name = "Ranch",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                         -- Show blip for houses for sale
                name = "Ranch",                        -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',                       -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Fisherman's House
    -----------------------------------------------------
    {
        uniqueName = "house35", -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(341.64, -664.92, 42.82),
        houseRadiusLimit = 30,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            {
                doorinfo = '[3238637478,-542955242,"p_door04x",347.24737548828,-666.05346679688,41.822761535645]', locked = true
            },
            {
                doorinfo = '[2933656395,-542955242,"p_door04x",338.25341796875,-669.94842529297,41.821144104004]', locked = true
            },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 1100,                              -- Inventory limit for the house
        taxAmount = 450,                              -- Tax amount for the house
        playerMax = 3,                                -- Maximum number of players that can own the house
        tpInt = 0,                                    -- TP Interior ID
        tpInstance = 0,                               -- TP Instance ID
        menuCoords = vector3(352.73, -656.13, 41.98), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                             -- Radius for the menu
        price = 4500,                                 -- The price of the house
        sellPrice = 2250,                             -- Amount received when selling the house
        rentalDeposit = 15,                           -- First Rental deposit in gold bars
        rentCharge = 7.5,                             -- Monthly rent in gold bars
        name = "House",                               -- Name of the house for display
        canSell = true,                               -- Whether the player can sell the house later
        showmarker = true,                            -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "House",               -- Name of the sale blip on the map
                sprite = 'blip_robbery_home', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your House",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },

    -----------------------------------------------------
    -- Emerald Ranch
    -----------------------------------------------------
    --[[{
        uniqueName = "house36",                            -- Unique identifier for the house. You can use any name but make sure you don't use duplicates
        houseCoords = vector3(1463.52, 313.9, 90.54 - 1),
        houseRadiusLimit = 25,
        doors = {
            -- Make sure you add the exact door from doorhashes.lua (you can find that in bcc-doorlocks in the client folder)
            -- Do not copy the entire line from doorhashes
            -- Example if we have this line
            -- [1610014965] = {1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25},
            -- We need to copy only what's between {...}
            -- 1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25
            -- {
            --     doorinfo = '[344028824,-542955242,"p_door04x",2989.1081542969,2193.7414550781,165.73979187012]', locked = true
            -- },
            -- {
            --     doorinfo = '[3731688048,-542955242,"p_door04x",2993.4243164063,2188.4375,165.73570251465]', locked = true
            -- },
            -- If the house has more than one door, copy the above same as these below
            -- {
            --     doorinfo = '[1610014965,990179346,"p_door_val_bank02",-2371.8505859375,475.1383972168,131.25]', locked = true
            -- },
        },
        invLimit = 5000,                                -- Inventory limit for the house
        taxAmount = 2000,                               -- Tax amount for the house
        playerMax = 8,                                  -- Maximum number of players that can own the house
        tpInt = 0,                                      -- TP Interior ID
        tpInstance = 0,                                 -- TP Instance ID
        menuCoords = vector3(1432.27, 319.2, 88.77 - 1), -- House Info (to buy or rent) / Marker location
        menuRadius = 2.0,                               -- Radius for the menu
        price = 20000,                                  -- The price of the house
        sellPrice = 10000,                               -- Amount received when selling the house
        rentalDeposit = 40,                             -- First Rental deposit in gold bars
        rentCharge = 20,                                -- Monthly rent in gold bars
        name = "Ranch",                                 -- Name of the house for display
        canSell = true,                                 -- Whether the player can sell the house later
        showmarker = true,                              -- Show marker on the ground for house sale info
        blip = {
            sale = {
                active = true,                -- Show blip for houses for sale
                name = "Ranch",               -- Name of the sale blip on the map
                sprite = 'blip_mp_playlist_adversary', -- Set sprite of the sale blip
                color = 'WHITE',              -- Set color of the sale blip (see BlipColors in main.lua config)
            },
            owned = {
                active = true,           -- Show blip for owned houses
                name = "Your Ranch",     -- Name of the owned blip on the map
                sprite = 'blip_mp_base', -- Set sprite of the owned blip
                color = 'WHITE',         -- Set color of the owned blip (see BlipColors in main.lua config)
            }
        }
    },--]]
}
