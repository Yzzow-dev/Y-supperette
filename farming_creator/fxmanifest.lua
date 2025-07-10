fx_version 'cerulean'
game 'gta5'

author 'Farming Creator System'
description 'Système de création de fermes personnalisées pour FiveM'
version '1.0.0'

client_scripts {
    'client/main.lua',
    'client/item_creator_client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
    'server/item_creator.lua'
}

shared_scripts {
    'config.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/zone_creator.html',
    'html/zone_style.css',
    'html/zone_script.js'
}

ui_page 'html/index.html'