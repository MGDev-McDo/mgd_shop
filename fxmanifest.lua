author 'McDo - MGDev'
version '2.1'
description 'InGame Shop'

fx_version 'adamant'
game 'gta5'

client_scripts {    
    'config.lua',
    
    'client/main.lua',
    'client/menu.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',

    'server/main.lua',
    'server/commands.lua'
}

ui_page 'client/ui/index.html'

files {
    'client/ui/index.html',
    'client/ui/css/style.css',
    'client/ui/script.js',
    'client/ui/functions.js',
    'client/ui/config.json',
    'client/ui/img/*.png'
}