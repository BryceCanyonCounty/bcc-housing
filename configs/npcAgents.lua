-----------------------------------------------------
-- NPC Real Estate Agents (Collect money after selling a house)
-----------------------------------------------------
Agents = {
    -- Blackwater
    {
        shop = {
            name = 'Blackwater Real Estate',   -- Name of Shop
            prompt = 'Blackwater Real Estate', -- Text Below the Prompt Button
            distance = 2.5,                    -- Distance from NPC to Get Prompt
            jobsEnabled = false,               -- Allow Shop Access to Specified Jobs Only
            jobs = {                           -- Insert Job to limit access - ex. allowedJobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'realtor', grade = 0 },
                { name = 'banker',  grade = 3 },
            },
            hours = {
                active = false, -- Shop uses Open and Closed Hours
                open   = 7,     -- Shop Open Time / 24 Hour Clock
                close  = 21     -- Shop Close Time / 24 Hour Clock
            }
        },
        blip = {
            name = 'Blackwater Real Estate', -- Name of Blip on Map
            sprite = 'blip_ambient_quartermaster',
            show = {
                open   = true, -- Show Blip On Map when Open
                closed = true  -- Show Blip On Map when Closed
            },
            color = {
                open   = 'WHITE',        -- Shop Open - Default: White - Blip Colors Shown in config_main.lua
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown in config_main.lua
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown in config_main.lua
            }
        },
        npc = {
            active   = true,                              -- Turns NPC On / Off
            model    = 'A_M_O_SDUpperClass_01',           -- Model Used for NPC
            coords   = vector3(-792.49, -1354.52, 43.76), -- NPC and Shop Blip Positions
            heading  = 85.88,                             -- NPC Heading
            distance = 100.0                              -- Distance Between Player and Shop for NPC to Spawn
        },
    },
    -----------------------------------------------------

    -- Valentine
    {
        shop = {
            name = 'Valentine Real Estate',   -- Name of Shop
            prompt = 'Valentine Real Estate', -- Text Below the Prompt Button
            distance = 2.5,                   -- Distance from NPC to Get Prompt
            jobsEnabled = false,              -- Allow Shop Access to Specified Jobs Only
            jobs = {                          -- Insert Job to limit access - ex. allowedJobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'realtor', grade = 0 },
                { name = 'banker',  grade = 3 },
            },
            hours = {
                active = false, -- Shop uses Open and Closed Hours
                open   = 7,     -- Shop Open Time / 24 Hour Clock
                close  = 21     -- Shop Close Time / 24 Hour Clock
            }
        },
        blip = {
            name = 'Valentine Real Estate', -- Name of Blip on Map
            sprite = 'blip_ambient_quartermaster',
            show = {
                open   = true, -- Show Blip On Map when Open
                closed = true  -- Show Blip On Map when Closed
            },
            color = {
                open   = 'WHITE',        -- Shop Open - Default: White - Blip Colors Shown in config_main.lua
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown in config_main.lua
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown in config_main.lua
            }
        },
        npc = {
            active   = true,                            -- Turns NPC On / Off
            model    = 'A_M_O_SDUpperClass_01',         -- Model Used for NPC
            coords   = vector3(-305.19, 772.39, 118.7), -- NPC and Shop Blip Positions
            heading  = 277.19,                          -- NPC Heading
            distance = 100.0                            -- Distance Between Player and Shop for NPC to Spawn
        },
    },
    -----------------------------------------------------

    -- Saint Denis
    {
        shop = {
            name = 'Saint Denis Real Estate',   -- Name of Shop
            prompt = 'Saint Denis Real Estate', -- Text Below the Prompt Button
            distance = 2.5,                     -- Distance from NPC to Get Prompt
            jobsEnabled = false,                -- Allow Shop Access to Specified Jobs Only
            jobs = {                            -- Insert Job to limit access - ex. allowedJobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'realtor', grade = 0 },
                { name = 'banker',  grade = 3 },
            },
            hours = {
                active = false, -- Shop uses Open and Closed Hours
                open   = 7,     -- Shop Open Time / 24 Hour Clock
                close  = 21     -- Shop Close Time / 24 Hour Clock
            }
        },
        blip = {
            name = 'Saint Denis Real Estate', -- Name of Blip on Map
            sprite = 'blip_ambient_quartermaster',
            show = {
                open   = true, -- Show Blip On Map when Open
                closed = true  -- Show Blip On Map when Closed
            },
            color = {
                open   = 'WHITE',        -- Shop Open - Default: White - Blip Colors Shown in config_main.lua
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown in config_main.lua
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown in config_main.lua
            }
        },
        npc = {
            active   = true,                              -- Turns NPC On / Off
            model    = 'A_M_O_SDUpperClass_01',           -- Model Used for NPC
            coords   = vector3(2647.08, -1294.95, 52.25), -- NPC and Shop Blip Positions
            heading  = 277.19,                            -- NPC Heading
            distance = 100.0                              -- Distance Between Player and Shop for NPC to Spawn
        },
    },
    -----------------------------------------------------
}
