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
  "/server/server.lua",
  '/server/adminManagment.lua'
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

version '1.0.3'