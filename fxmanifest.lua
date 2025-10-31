fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author 'BCC Team'

description 'Advanced Housing Script: A comprehensive and customizable system for managing player houses.'

shared_scripts {
    'configs/*.lua',
    'locale.lua',
    'languages/*.lua'
}

client_scripts {
    'client/functions.lua',
    'client/MainHousing.lua',
    'client/propertyCheck.lua',
    'client/furnitureSpawning.lua',
    'client/furnitureVendor.lua',
    'client/MenuSetup/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/helpers/functions.lua',
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
    'feather-menu'
}

version '2.1.0'
