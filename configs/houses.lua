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
        currencyType = 0,                                -- 0 = cash, 1 = gold, 2 = Rol Tokens (character.rol)
        allowRental = true,                             -- Set to false to disable renting for this house
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
        },
        -- Optional PolyZone boundary:
        -- Add at least 3 points in order around the property boundary.
        -- polyMinZ and polyMaxZ control the bottom and top of the zone.
        -- Remove or comment out polyPoints, polyMinZ, and polyMaxZ to use houseRadiusLimit instead.
        -- Use the configured HousingPolyZoneCommand to capture and export PolyZone coordinates.
        polyPoints = {
            { x = -2175.94, y = -234.60, z = 191.31 },
            { x = -2169.94, y = -235.42, z = 192.83 },
            { x = -2161.71, y = -243.30, z = 194.27 },
            { x = -2159.17, y = -249.45, z = 193.96 },
            { x = -2160.12, y = -256.20, z = 191.92 },
            { x = -2162.19, y = -264.18, z = 191.05 },
            { x = -2167.02, y = -270.02, z = 190.14 },
            { x = -2174.21, y = -271.32, z = 188.90 },
            { x = -2180.89, y = -270.70, z = 188.12 },
            { x = -2184.00, y = -269.29, z = 188.60 },
            { x = -2191.97, y = -258.97, z = 189.90 },
            { x = -2192.24, y = -257.30, z = 190.01 },
            { x = -2191.86, y = -255.24, z = 190.17 }
        },
        polyMinZ = 188.12, -- Bottom of the PolyZone
        polyMaxZ = 199.27  -- Top of the PolyZone
    },

    -----------------------------------------------------
    -- Ranch in the Great Plains
    -----------------------------------------------------
    {
        uniqueName = "house1",
        houseCoords = vector3(-2568.88, 348.03, 151.45),
        houseRadiusLimit = 30,
        doors = {
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
        },
        invLimit = 5000,
        taxAmount = 2000,
        playerMax = 10,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-2555.92, 474.91, 143.5),
        menuRadius = 2.0,
        price = 20000,
        sellPrice = 10000,
        rentalDeposit = 50,
        rentCharge = 25,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -2609.73, y = 386.04, z = 146.37 },
            { x = -2610.45, y = 364.47, z = 146.44 },
            { x = -2610.17, y = 351.37, z = 146.60 },
            { x = -2606.06, y = 337.63, z = 147.23 },
            { x = -2602.04, y = 329.47, z = 147.11 },
            { x = -2594.91, y = 320.03, z = 147.77 },
            { x = -2588.36, y = 315.23, z = 147.71 },
            { x = -2581.17, y = 312.63, z = 147.57 },
            { x = -2573.98, y = 312.58, z = 147.72 },
            { x = -2564.11, y = 314.54, z = 148.67 },
            { x = -2554.13, y = 316.71, z = 149.58 },
            { x = -2544.90, y = 317.87, z = 150.42 },
            { x = -2536.15, y = 318.65, z = 151.63 },
            { x = -2527.43, y = 319.37, z = 152.48 },
            { x = -2519.98, y = 321.41, z = 153.10 },
            { x = -2514.59, y = 325.16, z = 153.29 },
            { x = -2511.57, y = 329.56, z = 153.23 },
            { x = -2509.92, y = 337.22, z = 153.10 },
            { x = -2508.41, y = 345.78, z = 153.05 },
            { x = -2507.13, y = 358.07, z = 152.60 },
            { x = -2502.85, y = 403.15, z = 148.33 },
            { x = -2500.45, y = 430.40, z = 146.81 },
            { x = -2499.35, y = 446.76, z = 145.80 },
            { x = -2498.89, y = 460.19, z = 144.75 },
            { x = -2500.29, y = 474.71, z = 143.67 },
            { x = -2502.37, y = 481.04, z = 143.08 },
            { x = -2506.89, y = 489.81, z = 142.15 },
            { x = -2512.63, y = 496.11, z = 141.69 },
            { x = -2519.91, y = 499.54, z = 141.47 },
            { x = -2530.71, y = 502.69, z = 141.39 },
            { x = -2552.31, y = 503.99, z = 141.32 },
            { x = -2555.59, y = 501.56, z = 141.38 },
            { x = -2567.79, y = 495.83, z = 141.91 },
            { x = -2575.35, y = 491.08, z = 142.52 },
            { x = -2586.05, y = 483.00, z = 143.73 },
            { x = -2597.46, y = 476.50, z = 144.79 },
            { x = -2608.22, y = 473.24, z = 144.93 },
            { x = -2617.58, y = 465.15, z = 144.76 },
            { x = -2618.32, y = 458.67, z = 144.85 },
            { x = -2612.40, y = 427.23, z = 145.39 },
            { x = -2607.92, y = 411.50, z = 146.61 }
        },
        polyMinZ = 141.32,
        polyMaxZ = 158.29,
    },

    -----------------------------------------------------
    -- Ranch near Little Creek River
    -----------------------------------------------------
    {
        uniqueName = "house2",
        houseCoords = vector3(-2173.65, 715.36, 122.62),
        houseRadiusLimit = 30,
        doors = {
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
        },
        invLimit = 4000,
        taxAmount = 1400,
        playerMax = 8,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-2180.52, 672.45, 119.82),
        menuRadius = 2.0,
        price = 14000,
        sellPrice = 7500,
        rentalDeposit = 40,
        rentCharge = 20,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -2183.24, y = 673.87 },
            { x = -2229.12, y = 659.03 },
            { x = -2249.96, y = 676.48 },
            { x = -2263.69, y = 684.15 },
            { x = -2275.99, y = 689.06 },
            { x = -2279.35, y = 693.59 },
            { x = -2276.42, y = 701.03 },
            { x = -2271.67, y = 710.77 },
            { x = -2267.79, y = 716.99 },
            { x = -2261.65, y = 727.61 },
            { x = -2253.82, y = 731.97 },
            { x = -2245.33, y = 736.38 },
            { x = -2233.54, y = 742.93 },
            { x = -2224.87, y = 747.78 },
            { x = -2204.49, y = 759.28 },
            { x = -2199.50, y = 762.20 },
            { x = -2149.29, y = 705.04 },
            { x = -2146.20, y = 701.39 },
            { x = -2150.54, y = 692.87 },
            { x = -2156.27, y = 688.00 },
            { x = -2172.89, y = 677.10 },
        },
        polyMinZ = 119.16,
        polyMaxZ = 123.16,
    },

    -----------------------------------------------------
    -- Hunter's Hut near Little Creek River
    -----------------------------------------------------
    {
        uniqueName = "house3",
        houseCoords = vector3(-2458.92, 840.13, 146.39),
        houseRadiusLimit = 15,
        doors = {
            {
                doorinfo = '[524178042,320723614,"p_bigvshk_door",-2460.435546875,839.11047363281,145.35720825195]', locked = true
            },
        },
        invLimit = 300,
        taxAmount = 120,
        playerMax = 1,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-2458.29, 833.33, 141.9),
        menuRadius = 2.0,
        price = 1200,
        sellPrice = 600,
        rentalDeposit = 5,
        rentCharge = 2.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -2466.28, y = 829.83, z = 140.87 },
            { x = -2454.36, y = 831.22, z = 140.39 },
            { x = -2442.57, y = 834.53, z = 139.92 },
            { x = -2442.91, y = 838.11, z = 140.45 },
            { x = -2446.77, y = 845.33, z = 141.81 },
            { x = -2450.05, y = 852.72, z = 143.10 },
            { x = -2454.46, y = 857.98, z = 144.73 },
            { x = -2464.20, y = 851.69, z = 144.11 },
            { x = -2470.97, y = 845.93, z = 143.23 },
            { x = -2475.12, y = 842.58, z = 142.60 },
        },
        polyMinZ = 139.92,
        polyMaxZ = 149.73,
    },

    -----------------------------------------------------
    -- Hut near Little Creek
    -----------------------------------------------------
    {
        uniqueName = "house4",
        houseCoords = vector3(-1818.27, 662.02, 131.87),
        houseRadiusLimit = 25,
        doors = {
            {
                doorinfo = '[1195519038,-1899748000,"p_door45x",-1815.1489257813,654.96380615234,130.88250732422]', locked = true
            },
        },
        invLimit = 1000,
        taxAmount = 390,
        playerMax = 3,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-1797.65, 641.27, 129.61),
        menuRadius = 2.0,
        price = 3900,
        sellPrice = 1950,
        rentalDeposit = 15,
        rentCharge = 7.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -1794.59, y = 644.46, z = 128.25 },
            { x = -1789.41, y = 657.46, z = 128.61 },
            { x = -1795.78, y = 671.13, z = 129.94 },
            { x = -1806.56, y = 684.05, z = 133.19 },
            { x = -1817.73, y = 680.02, z = 136.77 },
            { x = -1835.45, y = 665.99, z = 135.14 },
            { x = -1840.50, y = 661.04, z = 133.41 },
            { x = -1837.28, y = 644.89, z = 129.88 },
            { x = -1832.37, y = 630.50, z = 128.88 },
            { x = -1831.28, y = 628.72, z = 128.59 },
            { x = -1818.09, y = 628.08, z = 128.49 },
            { x = -1801.06, y = 637.90, z = 129.24 },
            { x = -1798.94, y = 637.94, z = 128.93 },
        },
        polyMinZ = 128.25,
        polyMaxZ = 141.77,
    },

    -----------------------------------------------------
    -- Hut near Strawberry
    -----------------------------------------------------
    {
        uniqueName = "house5",
        houseCoords = vector3(-1675.88, -340.27, 170.79),
        houseRadiusLimit = 25,
        doors = {
            {
                doorinfo = '[2847752952,-628686073,"p_door_tax_shack01x",-1678.7446289063,-336.68927001953,172.99304199219]', locked = true
            },
            {
                doorinfo = '[1963415953,-628686073,"p_door_tax_shack01x",-1682.8327636719,-340.61013793945,172.98583984375]', locked = true
            },
        },
        invLimit = 1200,
        taxAmount = 450,
        playerMax = 3,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-1673.04, -332.12, 173.1),
        menuRadius = 2.0,
        price = 4500,
        sellPrice = 2250,
        rentalDeposit = 15,
        rentCharge = 7.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -1671.63, y = -335.84, z = 172.77 },
            { x = -1670.48, y = -343.52, z = 172.72 },
            { x = -1672.10, y = -349.34, z = 172.99 },
            { x = -1677.49, y = -354.67, z = 173.38 },
            { x = -1684.24, y = -357.56, z = 173.50 },
            { x = -1689.39, y = -357.79, z = 173.68 },
            { x = -1697.14, y = -354.89, z = 174.54 },
            { x = -1702.67, y = -350.10, z = 175.48 },
            { x = -1705.82, y = -341.47, z = 176.33 },
            { x = -1706.15, y = -336.08, z = 176.12 },
            { x = -1703.85, y = -327.39, z = 175.51 },
            { x = -1698.29, y = -321.76, z = 175.07 },
            { x = -1693.70, y = -320.06, z = 174.46 },
            { x = -1685.76, y = -323.67, z = 172.86 },
            { x = -1675.85, y = -330.80, z = 172.19 },
        },
        polyMinZ = 172.19,
        polyMaxZ = 181.33,
    },

    -----------------------------------------------------
    -- Ranch near Diablo Ridge
    -----------------------------------------------------
    {
        uniqueName = "house6",
        houseCoords = vector3(-613.23, -26.92, 85.98),
        houseRadiusLimit = 35,
        doors = {
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
        },
        invLimit = 2000,
        taxAmount = 800,
        playerMax = 5,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-622.36, -33.88, 85.3),
        menuRadius = 2.0,
        price = 8000,
        sellPrice = 4000,
        rentalDeposit = 25,
        rentCharge = 12.5,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -654.68, y = -11.70, z = 84.19 },
            { x = -645.94, y = -3.37,  z = 84.14 },
            { x = -638.85, y = 2.73,   z = 84.90 },
            { x = -631.07, y = 8.34,   z = 85.64 },
            { x = -622.59, y = 14.12,  z = 86.09 },
            { x = -613.21, y = 19.47,  z = 85.63 },
            { x = -605.63, y = 24.27,  z = 86.66 },
            { x = -598.83, y = 30.25,  z = 86.98 },
            { x = -592.39, y = 31.43,  z = 87.04 },
            { x = -584.56, y = 28.83,  z = 87.11 },
            { x = -575.71, y = 26.15,  z = 87.23 },
            { x = -568.63, y = 22.10,  z = 87.19 },
            { x = -561.17, y = 16.69,  z = 87.24 },
            { x = -556.81, y = 12.17,  z = 87.23 },
            { x = -556.42, y = 4.50,   z = 86.67 },
            { x = -556.54, y = -6.05,  z = 85.34 },
            { x = -557.27, y = -15.29, z = 84.35 },
            { x = -560.58, y = -26.74, z = 83.13 },
            { x = -564.39, y = -34.21, z = 81.00 },
            { x = -566.25, y = -39.20, z = 79.89 },
            { x = -569.58, y = -47.07, z = 81.93 },
            { x = -578.25, y = -57.83, z = 81.82 },
            { x = -585.96, y = -64.72, z = 81.29 },
            { x = -595.37, y = -70.45, z = 81.40 },
            { x = -604.34, y = -77.30, z = 81.29 },
            { x = -615.70, y = -82.74, z = 81.18 },
            { x = -627.41, y = -87.19, z = 80.63 },
            { x = -637.47, y = -88.20, z = 79.59 },
            { x = -649.27, y = -85.56, z = 79.42 },
            { x = -658.68, y = -78.82, z = 80.10 },
            { x = -667.47, y = -67.61, z = 81.06 },
            { x = -670.38, y = -53.98, z = 81.63 },
            { x = -671.64, y = -37.40, z = 82.42 },
            { x = -670.32, y = -23.97, z = 83.32 },
            { x = -659.44, y = -9.62,  z = 83.94 },
        },
        polyMinZ = 79.42,
        polyMaxZ = 92.24,
    },

    -----------------------------------------------------
    -- Hut near Aurora
    -----------------------------------------------------
    {
        uniqueName = "house9",
        houseCoords = vector3(-2577.71, -1381.87, 149.25),
        houseRadiusLimit = 15,
        doors = {
            {
                doorinfo = '{562830153,-400005393,"p_door_wornbarn_r",-2575.826171875,-1379.3582763672,148.27227783203]', locked = true
            },
            {
                doorinfo = '{663425326,-559000589,"p_door_wornbarn_l",-2578.7858886719,-1385.2464599609,148.26223754883]', locked = true
            },
        },
        invLimit = 800,
        taxAmount = 320,
        playerMax = 2,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-2571.8, -1373.45, 149.27),
        menuRadius = 2.0,
        price = 3200,
        sellPrice = 1600,
        rentalDeposit = 10,
        rentCharge = 5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Great Ranch of the Great Plains
    -----------------------------------------------------
    {
        uniqueName = "house10",
        houseCoords = vector3(-1637.48, -1361.72, 84.42),
        houseRadiusLimit = 40,
        doors = {
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
        },
        invLimit = 5000,
        taxAmount = 2500,
        playerMax = 10,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-1660.09, -1499.86, 83.56),
        menuRadius = 2.0,
        price = 25000,
        sellPrice = 12500,
        rentalDeposit = 50,
        rentCharge = 25,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Unfinished empty house at Wallace Station
    -----------------------------------------------------
    {
        uniqueName = "house20",
        houseCoords = vector3(-1551.6, 255.4, 114.8),
        houseRadiusLimit = 20,
        doors = {
            {
                doorinfo = '[3221874820,1288759240,"p_door55x",-1556.2313232422,251.39234924316,113.81051635742]', locked = true
            },
            {
                doorinfo = '[2366407202,1288759240,"p_door55x",-1550.3067626953,249.09503173828,113.80752563477]', locked = true
            },
        },
        invLimit = 1500,
        taxAmount = 500,
        playerMax = 4,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-1620.8, 234.76, 106.05),
        menuRadius = 2.0,
        price = 5000,
        sellPrice = 2500,
        rentalDeposit = 20,
        rentCharge = 10,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
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
        uniqueName = "house11",
        houseCoords = vector3(-690.97, 1045.86, 135.06),
        houseRadiusLimit = 15,
        doors = {
            {
                doorinfo = '[1434140379,-1896437095,"p_doorsgl02x",-692.42681884766,1042.9591674804,134.02406311035]', locked = true
            },
        },
        invLimit = 700,
        taxAmount = 250,
        playerMax = 2,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-704.32, 1045.84, 134.23),
        menuRadius = 2.0,
        price = 2500,
        sellPrice = 1225,
        rentalDeposit = 10,
        rentCharge = 5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Brandywine Drop Ranch
    -----------------------------------------------------
    {
        uniqueName = "house12",
        houseCoords = vector3(-394.48, 1726.56, 216.43),
        houseRadiusLimit = 35,
        doors = {
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
        },
        invLimit = 3000,
        taxAmount = 1200,
        playerMax = 8,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-400.93, 1708.36, 215.64),
        menuRadius = 2.0,
        price = 12000,
        sellPrice = 6000,
        rentalDeposit = 40,
        rentCharge = 20,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -406.17, y = 1707.61 },
            { x = -420.82, y = 1708.25 },
            { x = -426.76, y = 1722.18 },
            { x = -432.98, y = 1734.21 },
            { x = -440.78, y = 1753.88 },
            { x = -421.18, y = 1767.03 },
            { x = -406.73, y = 1770.59 },
            { x = -396.51, y = 1768.31 },
            { x = -386.32, y = 1761.50 },
            { x = -380.85, y = 1752.95 },
            { x = -379.12, y = 1742.87 },
            { x = -378.55, y = 1732.16 },
            { x = -378.19, y = 1723.08 },
            { x = -403.86, y = 1707.48 },
        },
        polyMinZ = 214.67,
        polyMaxZ = 218.67,
    },

    -----------------------------------------------------
    -- O'Creagh's Run
    -----------------------------------------------------
    {
        uniqueName = "house13",
        houseCoords = vector3(1702.5, 1511.68, 147.88),
        houseRadiusLimit = 20,
        doors = {
            {
                doorinfo = '[868379185,-2080420985,"p_door41x",1697.4683837891,1508.2376708984,146.8824005127]', locked = true
            },
            {
                doorinfo = '[640077562,-2080420985,"p_door41x",1702.7976074219,1514.3333740234,146.87799072266]', locked = true
            },
        },
        invLimit = 1000,
        taxAmount = 400,
        playerMax = 3,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(1696.92, 1522.87, 146.82),
        menuRadius = 2.0,
        price = 4000,
        sellPrice = 2000,
        rentalDeposit = 15,
        rentCharge = 7.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 1704.45, y = 1534.60, z = 146.64 },
            { x = 1713.56, y = 1522.87, z = 146.88 },
            { x = 1721.00, y = 1511.79, z = 147.56 },
            { x = 1731.51, y = 1494.31, z = 148.46 },
            { x = 1735.59, y = 1486.04, z = 148.90 },
            { x = 1710.34, y = 1475.20, z = 145.39 },
            { x = 1693.28, y = 1472.02, z = 145.41 },
            { x = 1688.49, y = 1505.02, z = 144.97 },
            { x = 1693.18, y = 1535.58, z = 145.40 },
            { x = 1694.79, y = 1542.67, z = 146.06 }
        },
        polyMinZ = 144.97,
        polyMaxZ = 153.90,
    },

    -----------------------------------------------------
    -- Three Sisters
    -----------------------------------------------------
    {
        uniqueName = "house14",
        houseCoords = vector3(1981.05, 1191.35, 171.4),
        houseRadiusLimit = 15,
        doors = {
            {
                doorinfo = '[784290387,-198436444,"p_door02x",1981.9653320313,1195.0833740234,170.41778564453]', locked = true
            },
        },
        invLimit = 700,
        taxAmount = 320,
        playerMax = 2,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(1976.73, 1200.82, 172.28),
        menuRadius = 2.0,
        price = 3200,
        sellPrice = 1600,
        rentalDeposit = 10,
        rentCharge = 5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 1943.13, y = 1223.24, z = 178.48 },
            { x = 1944.31, y = 1204.50, z = 176.37 },
            { x = 1945.98, y = 1191.94, z = 174.72 },
            { x = 1958.59, y = 1187.52, z = 172.87 },
            { x = 1981.85, y = 1177.96, z = 170.15 },
            { x = 2007.89, y = 1169.74, z = 169.07 },
            { x = 2014.84, y = 1180.67, z = 167.66 },
            { x = 2014.82, y = 1191.36, z = 168.24 },
            { x = 2011.46, y = 1211.50, z = 167.82 },
            { x = 2007.83, y = 1219.55, z = 169.50 }
        },
        polyMinZ = 167.66,
        polyMaxZ = 183.48,
    },

    -----------------------------------------------------
    -- Tower near Annesburg
    -----------------------------------------------------
    {
        uniqueName = "house15",
        houseCoords = vector3(1932.37, 1945.95, 266.1),
        houseRadiusLimit = 30,
        doors = {
            {
                doorinfo = '[1981171235,-1497029950,"p_door37x",1933.5963134766,1949.0305175781,265.11849975586]', locked = true
            },
        },
        invLimit = 1500,
        taxAmount = 600,
        playerMax = 4,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(1946.33, 1967.25, 261.4),
        menuRadius = 2.0,
        price = 6000,
        sellPrice = 3000,
        rentalDeposit = 20,
        rentCharge = 10,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 1953.49, y = 1974.08, z = 259.90 },
            { x = 1937.69, y = 1973.88, z = 263.60 },
            { x = 1925.05, y = 1977.30, z = 263.06 },
            { x = 1915.77, y = 1974.92, z = 262.41 },
            { x = 1907.44, y = 1969.15, z = 258.15 },
            { x = 1904.24, y = 1963.81, z = 257.58 },
            { x = 1914.67, y = 1954.19, z = 263.74 },
            { x = 1921.60, y = 1936.86, z = 263.04 },
            { x = 1928.44, y = 1930.97, z = 263.80 },
            { x = 1943.29, y = 1933.51, z = 263.55 },
            { x = 1948.91, y = 1937.59, z = 263.03 }
        },
        polyMinZ = 257.58,
        polyMaxZ = 268.80,
    },

    -----------------------------------------------------
    -- Hut near Cairn Lake
    -----------------------------------------------------
    {
        uniqueName = "house16",
        houseCoords = vector3(-943.4, 2168.29, 342.19),
        houseRadiusLimit = 15,
        doors = {
            {
                doorinfo = '[415985340,-2087217357,"p_doorsgl01x",-950.03857421875,2174.0383300781,341.24365234375]', locked = true
            },
        },
        invLimit = 500,
        taxAmount = 100,
        playerMax = 1,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-957.28, 2174.83, 341.18),
        menuRadius = 2.0,
        price = 1000,
        sellPrice = 500,
        rentalDeposit = 5,
        rentCharge = 2.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Ranch north of Colter
    -----------------------------------------------------
    {
        uniqueName = "house17",
        houseCoords = vector3(-552.62, 2702.75, 320.42),
        houseRadiusLimit = 40,
        doors = {
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
        },
        invLimit = 3000,
        taxAmount = 800,
        playerMax = 6,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-601.41, 2676.31, 323.69),
        menuRadius = 2.0,
        price = 8000,
        sellPrice = 4000,
        rentalDeposit = 30,
        rentCharge = 15,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -600.16, y = 2673.68, z = 323.52 },
            { x = -596.69, y = 2661.58, z = 323.75 },
            { x = -590.41, y = 2658.17, z = 322.71 },
            { x = -564.89, y = 2651.23, z = 320.38 },
            { x = -547.15, y = 2644.28, z = 322.72 },
            { x = -531.89, y = 2639.25, z = 325.98 },
            { x = -526.87, y = 2637.93, z = 326.36 },
            { x = -512.32, y = 2643.98, z = 324.55 },
            { x = -510.64, y = 2651.62, z = 321.43 },
            { x = -509.97, y = 2663.08, z = 319.25 },
            { x = -509.80, y = 2673.99, z = 318.41 },
            { x = -515.48, y = 2694.50, z = 318.31 },
            { x = -531.78, y = 2713.50, z = 319.13 },
            { x = -543.37, y = 2720.54, z = 319.43 },
            { x = -554.47, y = 2724.39, z = 319.99 },
            { x = -572.82, y = 2725.81, z = 320.89 },
            { x = -586.98, y = 2726.37, z = 322.25 },
            { x = -593.70, y = 2717.39, z = 323.06 },
            { x = -602.55, y = 2704.42, z = 323.18 },
            { x = -607.06, y = 2695.39, z = 323.70 },
        },
        polyMinZ = 318.31,
        polyMaxZ = 331.36,
    },

    -----------------------------------------------------
    -- Hut near Deadboot Creek
    -----------------------------------------------------
    {
        uniqueName = "house18",
        houseCoords = vector3(-1963.36, 2158.4, 327.6),
        houseRadiusLimit = 15,
        doors = {
            {
                doorinfo = '[943176298,-58075500,"p_doorsnow01x",-1959.1854248047,2160.2043457031,326.55380249023]', locked = true
            },
        },
        invLimit = 700,
        taxAmount = 180,
        playerMax = 2,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-1952.21, 2161.4, 326.81),
        menuRadius = 2.0,
        price = 1800,
        sellPrice = 900,
        rentalDeposit = 10,
        rentCharge = 5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Tower on Mount Hagen
    -----------------------------------------------------
    {
        uniqueName = "house19",
        houseCoords = vector3(-1488.83, 1248.61, 314.49),
        houseRadiusLimit = 20,
        doors = {
            {
                doorinfo = '[2971757040,-58075500,"p_doorsnow01x",-1494.4030761719,1246.7662353516,313.5432434082]', locked = true
            },
        },
        invLimit = 1000,
        taxAmount = 280,
        playerMax = 3,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-1502.65, 1240.78, 312.8),
        menuRadius = 2.0,
        price = 2800,
        sellPrice = 1400,
        rentalDeposit = 15,
        rentCharge = 7.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -1520.93, y = 1229.00, z = 312.48 },
            { x = -1506.21, y = 1233.78, z = 309.81 },
            { x = -1494.69, y = 1238.56, z = 312.40 },
            { x = -1485.47, y = 1245.74, z = 312.88 },
            { x = -1486.93, y = 1250.77, z = 313.50 },
            { x = -1490.49, y = 1256.96, z = 313.21 },
            { x = -1499.90, y = 1257.97, z = 312.78 },
            { x = -1509.47, y = 1256.56, z = 313.79 },
            { x = -1516.76, y = 1253.52, z = 312.58 },
            { x = -1520.43, y = 1249.01, z = 312.64 },
            { x = -1522.57, y = 1242.70, z = 315.33 },
        },
        polyMinZ = 309.81,
        polyMaxZ = 320.33,
    },

    ------------------------------
    --- N E W -- H A N O V E R ---
    ------------------------------

    -----------------------------------------------------
    -- Hut near Flatneck Station
    -----------------------------------------------------
    {
        uniqueName = "house21",
        houseCoords = vector3(-63.72, -392.55, 72.22),
        houseRadiusLimit = 25,
        doors = {
            {
                doorinfo = '[1299456376,1281919024,"ann_jail_main_door_01",-64.242599987305,-393.56112670898,71.248695373535]', locked = true
            },
        },
        invLimit = 800,
        taxAmount = 450,
        playerMax = 3,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-76.5, -404.42, 71.2),
        menuRadius = 2.0,
        price = 4500,
        sellPrice = 2250,
        rentalDeposit = 15,
        rentCharge = 7.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -81.60,  y = -409.57 },
            { x = -72.29,  y = -425.40 },
            { x = -34.00,  y = -396.74 },
            { x = -52.83,  y = -377.55 },
            { x = -74.62,  y = -362.31 },
            { x = -106.08, y = -362.83 },
            { x = -113.34, y = -387.73 },
            { x = -102.29, y = -399.84 },
        },
        polyMinZ = 69.20,
        polyMaxZ = 73.20,
    },

    -----------------------------------------------------
    -- Burrow west of Emerald
    -----------------------------------------------------
    {
        uniqueName = "house22",
        houseCoords = vector3(906.42, 261.32, 116.0),
        houseRadiusLimit = 25,
        doors = {
            {
                doorinfo = '[1934463007,-1896437095,"p_doorsgl02x",900.34381103516,265.21841430664,115.04807281494]', locked = true
            },
        },
        invLimit = 1200,
        taxAmount = 550,
        playerMax = 4,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(899.49, 282.35, 116.29),
        menuRadius = 2.0,
        price = 5500,
        sellPrice = 2250,
        rentalDeposit = 20,
        rentCharge = 10,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 921.24, y = 284.43, z = 116.42 },
            { x = 911.12, y = 284.05, z = 115.23 },
            { x = 898.05, y = 284.33, z = 115.16 },
            { x = 884.93, y = 284.20, z = 114.52 },
            { x = 880.47, y = 283.90, z = 114.50 },
            { x = 879.81, y = 270.39, z = 115.29 },
            { x = 879.49, y = 259.57, z = 115.96 },
            { x = 880.12, y = 249.54, z = 116.45 },
            { x = 880.49, y = 244.56, z = 116.73 },
            { x = 881.78, y = 240.15, z = 116.66 },
            { x = 892.68, y = 245.34, z = 117.07 },
            { x = 902.21, y = 249.82, z = 118.44 },
            { x = 910.33, y = 254.40, z = 118.44 },
            { x = 920.99, y = 260.54, z = 117.22 },
            { x = 932.13, y = 268.12, z = 117.61 },
        },
        polyMinZ = 114.50,
        polyMaxZ = 123.44,
    },

    -----------------------------------------------------
    -- Ranch near Heartland Overflow
    -----------------------------------------------------
    {
        uniqueName = "house23",
        houseCoords = vector3(1120.57, 492.46, 97.28),
        houseRadiusLimit = 50,
        doors = {
            {
                doorinfo = '[1239033969,-164490887,"p_door_val_genstore2",1114.0626220703,493.74633789063,96.290939331055]', locked = true
            },
            {
                doorinfo = '[1597362984,1081626861,"p_door_wglass01x",1116.3991699219,485.99212646484,96.306297302246]', locked = true
            },
        },
        invLimit = 3000,
        taxAmount = 1500,
        playerMax = 6,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(1098.37, 496.9, 95.38),
        menuRadius = 2.0,
        price = 15000,
        sellPrice = 7500,
        rentalDeposit = 30,
        rentCharge = 15,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Between Emerald and Kamassa River
    -----------------------------------------------------
    {
        uniqueName = "house24",
        houseCoords = vector3(1887.14, 301.13, 77.07),
        houseRadiusLimit = 15,
        doors = {
            {
                doorinfo = '[2821676992,-1896437095,"p_doorsgl02x",1888.1700439453,297.95916748047,76.076202392578]', locked = true
            },
            {
                doorinfo = '[1510914117,-1896437095,"p_doorsgl02x",1891.0832519531,302.62200927734,76.091575622559]', locked = true
            },
        },
        invLimit = 700,
        taxAmount = 350,
        playerMax = 2,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(1876.94, 292.55, 76.05),
        menuRadius = 2.0,
        price = 3500,
        sellPrice = 1750,
        rentalDeposit = 10,
        rentCharge = 5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Ranch on the banks of Kamassa River
    -----------------------------------------------------
    {
        uniqueName = "house25",
        houseCoords = vector3(2233.67, -141.78, 47.62),
        houseRadiusLimit = 40,
        doors = {
            {
                doorinfo = '[1762076266,-2080420985,"p_door41x",2237.1235351563,-141.56480407715,46.626441955566]', locked = true
            },
            {
                doorinfo = '[2689340659,-2080420985,"p_door41x",2235.5598144531,-147.06066894531,46.62866973877]', locked = true
            },
        },
        invLimit = 3000,
        taxAmount = 1200,
        playerMax = 6,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(2224.7, -127.98, 47.63),
        menuRadius = 2.0,
        price = 12000,
        sellPrice = 6000,
        rentalDeposit = 30,
        rentCharge = 15,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 2209.76, y = -112.96, z = 48.93 },
            { x = 2222.03, y = -102.85, z = 47.16 },
            { x = 2233.99, y = -93.19,  z = 45.59 },
            { x = 2243.69, y = -93.35,  z = 44.75 },
            { x = 2258.73, y = -94.80,  z = 44.45 },
            { x = 2293.31, y = -101.43, z = 43.53 },
            { x = 2283.10, y = -132.88, z = 43.09 },
            { x = 2269.37, y = -159.01, z = 41.85 },
            { x = 2263.61, y = -173.96, z = 42.01 },
            { x = 2257.43, y = -188.56, z = 42.89 },
            { x = 2238.43, y = -177.63, z = 45.28 },
            { x = 2218.16, y = -161.93, z = 46.69 },
            { x = 2200.35, y = -147.54, z = 47.34 },
            { x = 2186.38, y = -134.02, z = 49.74 },
        },
        polyMinZ = 41.85,
        polyMaxZ = 54.74,
    },

    -----------------------------------------------------
    -- House on the shore near Van Horn
    -----------------------------------------------------
    {
        uniqueName = "house26",
        houseCoords = vector3(2820.68, 274.05, 51.08),
        houseRadiusLimit = 20,
        doors = {
            {
                doorinfo = '[1431398235,-1800129672,"p_door36x",2820.5607910156,278.90881347656,50.09118270874]', locked = true
            },
            {
                doorinfo = '[4275653891,-1800129672,"p_door36x",2824.4970703125,270.89910888672,47.120807647705]', locked = true
            },
        },
        invLimit = 700,
        taxAmount = 2800,
        playerMax = 3,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(2810.68, 289.01, 49.74),
        menuRadius = 2.0,
        price = 2800,
        sellPrice = 1400,
        rentalDeposit = 15,
        rentCharge = 7.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 2796.76, y = 268.97, z = 46.59 },
            { x = 2804.97, y = 260.45, z = 46.53 },
            { x = 2816.23, y = 251.59, z = 46.07 },
            { x = 2819.63, y = 250.92, z = 46.01 },
            { x = 2830.50, y = 251.33, z = 45.20 },
            { x = 2836.72, y = 254.71, z = 45.70 },
            { x = 2840.83, y = 266.33, z = 46.41 },
            { x = 2844.08, y = 276.50, z = 46.14 },
            { x = 2847.61, y = 287.64, z = 46.50 },
            { x = 2839.46, y = 295.69, z = 46.37 },
            { x = 2827.24, y = 304.38, z = 47.10 },
            { x = 2818.38, y = 311.66, z = 47.25 },
            { x = 2806.12, y = 304.66, z = 47.48 },
        },
        polyMinZ = 45.20,
        polyMaxZ = 52.48,
    },

    -----------------------------------------------------
    -- North of Annesburg
    -----------------------------------------------------
    {
        uniqueName = "house27",
        houseCoords = vector3(3031.33, 1777.71, 84.13),
        houseRadiusLimit = 35,
        doors = {
            {
                doorinfo = '[1973911195,1433165496,"p_door60",3024.1213378906,1777.0731201172,83.169136047363]', locked = true
            },
        },
        invLimit = 1200,
        taxAmount = 400,
        playerMax = 3,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(3016.23, 1754.19, 83.3),
        menuRadius = 2.0,
        price = 4000,
        sellPrice = 2000,
        rentalDeposit = 15,
        rentCharge = 7.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 3018.01, y = 1754.66, z = 82.46 },
            { x = 3028.23, y = 1751.66, z = 83.14 },
            { x = 3037.70, y = 1754.23, z = 82.59 },
            { x = 3044.87, y = 1764.60, z = 82.18 },
            { x = 3046.17, y = 1774.15, z = 81.96 },
            { x = 3046.26, y = 1785.67, z = 83.23 },
            { x = 3040.87, y = 1790.88, z = 82.43 },
            { x = 3028.50, y = 1792.55, z = 81.62 },
            { x = 3018.43, y = 1793.11, z = 82.18 },
            { x = 3007.92, y = 1791.21, z = 82.50 },
            { x = 3001.45, y = 1788.94, z = 83.36 },
            { x = 3000.57, y = 1787.31, z = 83.41 },
            { x = 3001.94, y = 1777.52, z = 83.45 },
            { x = 3002.42, y = 1767.28, z = 83.29 },
            { x = 3004.74, y = 1759.82, z = 83.20 },
            { x = 3006.40, y = 1757.02, z = 83.15 },
        },
        polyMinZ = 81.62,
        polyMaxZ = 88.45,
    },

    -----------------------------------------------------
    -- Ranch above the Oil Fields
    -----------------------------------------------------
    {
        uniqueName = "house29",
        houseCoords = vector3(775.81, 844.9, 118.91),
        houseRadiusLimit = 40,
        doors = {
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
        },
        invLimit = 5000,
        taxAmount = 1800,
        playerMax = 8,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(793.48, 848.22, 117.7),
        menuRadius = 2.0,
        price = 18000,
        sellPrice = 9000,
        rentalDeposit = 40,
        rentCharge = 20,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- House in Cumberland Forest Lower
    -----------------------------------------------------
    {
        uniqueName = "house30",
        houseCoords = vector3(218.61, 984.56, 190.9),
        houseRadiusLimit = 75,
        doors = {
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
        },
        invLimit = 2000,
        taxAmount = 700,
        playerMax = 4,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(202.4, 963.14, 190.4),
        menuRadius = 2.0,
        price = 7000,
        sellPrice = 3500,
        rentalDeposit = 20,
        rentCharge = 10,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 200.27, y = 961.83,  z = 189.38 },
            { x = 211.92, y = 959.81,  z = 191.04 },
            { x = 221.02, y = 960.60,  z = 193.48 },
            { x = 228.88, y = 973.49,  z = 189.95 },
            { x = 233.83, y = 985.89,  z = 188.48 },
            { x = 239.94, y = 986.58,  z = 188.38 },
            { x = 239.51, y = 995.29,  z = 188.29 },
            { x = 238.06, y = 1003.41, z = 188.37 },
            { x = 236.79, y = 1008.20, z = 188.18 },
            { x = 223.46, y = 1012.57, z = 187.63 },
            { x = 213.09, y = 1014.71, z = 187.54 },
            { x = 202.64, y = 1016.31, z = 187.54 },
            { x = 192.34, y = 1014.67, z = 188.21 },
            { x = 187.61, y = 1010.26, z = 188.96 },
            { x = 186.06, y = 1002.02, z = 189.31 },
            { x = 185.98, y = 992.60,  z = 189.43 },
            { x = 187.23, y = 982.12,  z = 189.76 },
            { x = 190.79, y = 966.27,  z = 190.99 },
        },
        polyMinZ = 187.54,
        polyMaxZ = 198.48,
    },

    -----------------------------------------------------
    -- House in Cumberland Forest Upper
    -----------------------------------------------------
    {
        uniqueName = "house31",
        houseCoords = vector3(-64.9, 1237.65, 170.77),
        houseRadiusLimit = 75,
        doors = {
            {
                doorinfo = '[202296518,-312814636,"p_door44x",-67.303237915039,1235.8376464844,169.76470947266]', locked = true
            },
        },
        invLimit = 1500,
        taxAmount = 600,
        playerMax = 4,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-73.79, 1230.05, 169.53),
        menuRadius = 2.0,
        price = 6000,
        sellPrice = 3000,
        rentalDeposit = 20,
        rentCharge = 10,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Ranch near Keliban's Run
    -----------------------------------------------------
    {
        uniqueName = "house32",
        houseCoords = vector3(-820.81, 355.01, 98.08),
        houseRadiusLimit = 100,
        doors = {
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
        },
        invLimit = 3500,
        taxAmount = 1400,
        playerMax = 5,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(-814.74, 340.2, 96.46),
        menuRadius = 2.0,
        price = 14000,
        sellPrice = 7000,
        rentalDeposit = 25,
        rentCharge = 12.5,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = -806.51, y = 286.83, z = 93.95 },
            { x = -763.44, y = 306.06, z = 93.33 },
            { x = -745.74, y = 318.47, z = 92.46 },
            { x = -755.88, y = 347.14, z = 93.97 },
            { x = -768.37, y = 373.46, z = 95.38 },
            { x = -780.49, y = 391.77, z = 95.52 },
            { x = -798.83, y = 381.38, z = 95.09 },
            { x = -838.65, y = 375.47, z = 95.52 },
            { x = -867.87, y = 370.99, z = 95.44 },
            { x = -873.65, y = 368.69, z = 95.35 },
            { x = -883.43, y = 350.12, z = 95.09 },
            { x = -890.85, y = 330.69, z = 95.32 },
            { x = -892.57, y = 322.29, z = 95.28 },
            { x = -898.19, y = 304.22, z = 94.36 },
            { x = -898.39, y = 292.39, z = 94.78 },
        },
        polyMinZ = 92.46,
        polyMaxZ = 100.52,
    },

    -----------------------------------------------------
    -- Hut west of Van Horn
    -----------------------------------------------------
    {
        uniqueName = "house33",
        houseCoords = vector3(2716.12, 709.84, 79.52),
        houseRadiusLimit = 20,
        doors = {
            {
                doorinfo = '[843137708,-312814636,"p_door44x",2716.8154296875,708.16693115234,78.605178833008]', locked = true
            },
        },
        invLimit = 500,
        taxAmount = 250,
        playerMax = 2,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(2718.31, 702.96, 78.29),
        menuRadius = 2.0,
        price = 2500,
        sellPrice = 1250,
        rentalDeposit = 10,
        rentCharge = 5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 2732.90, y = 723.06, z = 77.59 },
            { x = 2715.90, y = 724.38, z = 77.01 },
            { x = 2701.39, y = 724.94, z = 75.79 },
            { x = 2698.13, y = 726.82, z = 75.26 },
            { x = 2695.41, y = 722.10, z = 75.63 },
            { x = 2685.17, y = 708.71, z = 75.01 },
            { x = 2682.07, y = 701.54, z = 75.01 },
            { x = 2685.10, y = 696.06, z = 74.74 },
            { x = 2689.82, y = 688.51, z = 74.88 },
            { x = 2691.18, y = 686.08, z = 74.86 },
            { x = 2706.24, y = 692.54, z = 75.36 },
            { x = 2721.35, y = 698.36, z = 76.33 },
            { x = 2732.71, y = 702.27, z = 76.17 },
        },
        polyMinZ = 74.74,
        polyMaxZ = 82.59,
    },

    -----------------------------------------------------
    -- Small Ranch near Lumber Mill
    -----------------------------------------------------
    {
        uniqueName = "house34",
        houseCoords = vector3(2991.98, 2194.01, 166.76),
        houseRadiusLimit = 50,
        doors = {
            {
                doorinfo = '[344028824,-542955242,"p_door04x",2989.1081542969,2193.7414550781,165.73979187012]', locked = true
            },
            {
                doorinfo = '[3731688048,-542955242,"p_door04x",2993.4243164063,2188.4375,165.73570251465]', locked = true
            },
        },
        invLimit = 4000,
        taxAmount = 1300,
        playerMax = 5,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(2966.77, 2205.69, 166.19),
        menuRadius = 2.0,
        price = 13000,
        sellPrice = 6500,
        rentalDeposit = 25,
        rentCharge = 12.5,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 2960.88, y = 2199.48, z = 165.12 },
            { x = 2957.50, y = 2191.90, z = 168.90 },
            { x = 2953.91, y = 2184.36, z = 169.29 },
            { x = 2954.53, y = 2177.56, z = 170.69 },
            { x = 2961.53, y = 2175.44, z = 169.66 },
            { x = 2977.66, y = 2169.85, z = 167.76 },
            { x = 2988.34, y = 2167.48, z = 170.36 },
            { x = 2999.15, y = 2166.18, z = 170.17 },
            { x = 3007.77, y = 2166.42, z = 170.06 },
            { x = 3014.77, y = 2166.44, z = 170.13 },
            { x = 3024.39, y = 2169.64, z = 167.98 },
            { x = 3036.68, y = 2180.03, z = 166.12 },
            { x = 3043.94, y = 2187.49, z = 164.46 },
            { x = 3038.81, y = 2196.56, z = 164.67 },
            { x = 3033.32, y = 2206.50, z = 166.06 },
            { x = 3023.47, y = 2213.92, z = 165.39 },
            { x = 3015.30, y = 2218.63, z = 166.04 },
            { x = 3003.66, y = 2222.99, z = 167.04 },
            { x = 2992.90, y = 2225.15, z = 166.61 },
            { x = 2980.67, y = 2227.54, z = 166.20 },
        },
        polyMinZ = 164.46,
        polyMaxZ = 175.69,
    },

    -----------------------------------------------------
    -- Fisherman's House
    -----------------------------------------------------
    {
        uniqueName = "house35",
        houseCoords = vector3(341.64, -664.92, 42.82),
        houseRadiusLimit = 30,
        doors = {
            {
                doorinfo = '[3238637478,-542955242,"p_door04x",347.24737548828,-666.05346679688,41.822761535645]', locked = true
            },
            {
                doorinfo = '[2933656395,-542955242,"p_door04x",338.25341796875,-669.94842529297,41.821144104004]', locked = true
            },
        },
        invLimit = 1100,
        taxAmount = 450,
        playerMax = 3,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(352.73, -656.13, 41.98),
        menuRadius = 2.0,
        price = 4500,
        sellPrice = 2250,
        rentalDeposit = 15,
        rentCharge = 7.5,
        currencyType = 0,
        allowRental = true,
        name = "House",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "House",
                sprite = 'blip_robbery_home',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your House",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        }
    },

    -----------------------------------------------------
    -- Emerald Ranch
    -----------------------------------------------------
    --[[{
        uniqueName = "house36",
        houseCoords = vector3(1463.52, 313.9, 90.54 - 1),
        houseRadiusLimit = 25,
        doors = {
            --     doorinfo = '[344028824,-542955242,"p_door04x",2989.1081542969,2193.7414550781,165.73979187012]', locked = true
            --     doorinfo = '[3731688048,-542955242,"p_door04x",2993.4243164063,2188.4375,165.73570251465]', locked = true
        },
        invLimit = 5000,
        taxAmount = 2000,
        playerMax = 8,
        tpInt = 0,
        tpInstance = 0,
        menuCoords = vector3(1432.27, 319.2, 88.77 - 1),
        menuRadius = 2.0,
        price = 20000,
        sellPrice = 10000,
        rentalDeposit = 40,
        rentCharge = 20,
        currencyType = 0,
        allowRental = true,
        name = "Ranch",
        canSell = true,
        showmarker = true,
        blip = {
            sale = {
                active = true,
                name = "Ranch",
                sprite = 'blip_mp_playlist_adversary',
                color = 'WHITE',
            },
            owned = {
                active = true,
                name = "Your Ranch",
                sprite = 'blip_mp_base',
                color = 'WHITE',
            }
        },
        polyPoints = {
            { x = 1429.55, y = 316.47, z = 87.65 },
            { x = 1429.30, y = 284.99, z = 88.44 },
            { x = 1429.76, y = 246.95, z = 89.81 },
            { x = 1446.31, y = 242.90, z = 90.90 },
            { x = 1470.96, y = 290.08, z = 90.64 },
            { x = 1489.64, y = 323.06, z = 90.24 },
            { x = 1512.27, y = 354.13, z = 91.48 },
            { x = 1520.59, y = 385.09, z = 90.65 },
            { x = 1456.13, y = 393.02, z = 90.75 },
            { x = 1438.86, y = 387.33, z = 88.64 },
            { x = 1432.44, y = 379.42, z = 88.21 },
            { x = 1429.82, y = 368.37, z = 87.97 },
        },
        polyMinZ = 87.65,
        polyMaxZ = 96.48,
    },--]]
}
