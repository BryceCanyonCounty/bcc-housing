fx_version "adamant"
games {"rdr3"}
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
lua54 "yes"

shared_scripts {
  "config.lua",
  "locale.lua",
  'languages/*.lua'
}

server_scripts {
  "@oxmysql/lib/MySQL.lua",
  'server/helpers/functions.lua',
  'server/services/dbupdater.lua',
  'server/helpers/*.lua',
  'server/services/*.lua',
  "/server/main.lua"
}

client_scripts {
  "/client/functions.lua",
  "/client/MainHousing.lua",
  "/client/MenuSetup/*.lua",
  '/client/furnitureSpawning.lua'
}

files {
  "stream/Siddin3.ymap",
  "stream/Siddin4.ymap",
}

dependency {
  'vorp_core',
  'vorp_inventory',
  'vorp_utils',
  'vorp_inputs',
  'vorp_character',
  'bcc-utils',
  'bcc-doorlocks'
}

-- u can set doors but if u set one with an id first it will break so u have to set one without an id first then add id doors

version '1.0.4'