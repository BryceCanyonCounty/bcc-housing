fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author 'BCC Team'

description 'Advanced Housing Script: A comprehensive and customizable system for managing player houses.'

shared_scripts {
    'configs/*.lua',
    'locale.lua',
    'languages/*.lua',
    'shared/init.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    'client/functions.lua',
    'client/MainHousing.lua',
    'client/propertyCheck.lua',
    'client/furnitureSpawning.lua',
    'client/furnitureVendor.lua',
    'client/MenuSetup/adminManagementMenu.lua',
    'client/MenuSetup/buyHouse.lua',
    'client/MenuSetup/createHouseMenu.lua',
    'client/MenuSetup/furnitureMenu.lua',
    'client/MenuSetup/manageHouseMenu.lua',
    'client/MenuSetup/npcAgents.lua',
    'client/MenuSetup/sellHouse.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/helpers/functions.lua',
    'server/helpers/propertyDocuments.lua',
    'server/services/*.lua',
    'server/main.lua'
}
ui_page {
    "ui/index.html"
}

files {
    "ui/index.html",
    "ui/assets/*",
    'stream/Siddin3.ymap',
    'stream/Siddin4.ymap',
}

dependency {
    'vorp_core',
    'vorp_inventory',
    'vorp_character',
    'bcc-utils',
    'bcc-doorlocks',
    'feather-menu',
    'PolyZone'
}

version '2.5.0'
