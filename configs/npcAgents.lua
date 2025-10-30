-----------------------------------------------------
-- NPC Real Estate Agents (Collect money after selling a house)
-----------------------------------------------------
Agents = {
    -- Blackwater
    {
        shop = {
            name = 'VANZARI PROPIETATI',   -- Name of Shop
            prompt = 'VANZARI PROPIETATI', -- Text Below the Prompt Button
            distance = 2.5,              -- Distance from NPC to Get Prompt
            jobsEnabled = false,         -- Allow Shop Access to Specified Jobs Only
            jobs = {                     -- Insert Job to limit access - ex. allowedJobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'realtor',      grade = 0 },
                { name = 'Comandant', grade = 2 },
            },
            hours = {
                active = false, -- Shop uses Open and Closed Hours
                open   = 7,     -- Shop Open Time / 24 Hour Clock
                close  = 21     -- Shop Close Time / 24 Hour Clock
            }
        },
        blip = {
            name = 'Blackwater Real Estate', -- Name of Blip on Map
            sprite = 'blip_for_sale',
            show = {
                open   = false, -- Show Blip On Map when Open
                closed = true  -- Show Blip On Map when Closed
            },
            color = {
                open   = 'BRIGHT_BLUE',  -- Shop Open - Default: White - Blip Colors Shown in config_main.lua
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown in config_main.lua
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown in config_main.lua
            }
        },
        npc = {
            active   = true,                              -- Turns NPC On / Off
            model    = 'A_M_O_SDUpperClass_01',           -- Model Used for NPC
            coords   = vector3(-797.57, -1191.7, 44.05), -- NPC and Shop Blip Positions
            heading  = 311.15,                             -- NPC Heading
            distance = 100.0                              -- Distance Between Player and Shop for NPC to Spawn
        },
    },
    -----------------------------------------------------

    -- Valentine
    {
        shop = {
            name = 'VANZARI PROPIETATI',   -- Name of Shop
            prompt = 'VANZARI PROPIETATI', -- Text Below the Prompt Button
            distance = 2.5,              -- Distance from NPC to Get Prompt
            jobsEnabled = false,         -- Allow Shop Access to Specified Jobs Only
            jobs = {                     -- Insert Job to limit access - ex. allowedJobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
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
            name = 'VANZARI PROPIETATI', -- Name of Blip on Map
            sprite = 'blip_for_sale',
            show = {
                open   = false, -- Show Blip On Map when Open
                closed = true  -- Show Blip On Map when Closed
            },
            color = {
                open   = 'BRIGHT_BLUE',  -- Shop Open - Default: White - Blip Colors Shown in config_main.lua
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown in config_main.lua
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown in config_main.lua
            }
        },
        npc = {
            active   = true,                            -- Turns NPC On / Off
            model    = 'A_M_O_SDUpperClass_01',         -- Model Used for NPC
            coords   = vector3(-291.72, 774.02, 119.37), -- NPC and Shop Blip Positions
            heading  = 7.36,                          -- NPC Heading
            distance = 100.0                            -- Distance Between Player and Shop for NPC to Spawn
        },
    },
    -----------------------------------------------------

    -- Saint Denis
    {
        shop = {
            name = 'VANZARI PROPIETATI',   -- Name of Shop
            prompt = 'VANZARI PROPIETATI', -- Text Below the Prompt Button
            distance = 2.5,              -- Distance from NPC to Get Prompt
            jobsEnabled = false,         -- Allow Shop Access to Specified Jobs Only
            jobs = {                     -- Insert Job to limit access - ex. allowedJobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
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
            name = 'VANZARI PROPIETATI', -- Name of Blip on Map
            sprite = 'blip_for_sale',
            show = {
                open   = false, -- Show Blip On Map when Open
                closed = true  -- Show Blip On Map when Closed
            },
            color = {
                open   = 'BRIGHT_BLUE',  -- Shop Open - Default: White - Blip Colors Shown in config_main.lua
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
