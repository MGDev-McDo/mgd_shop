author 'McDo - MGDev'
version '1.0.0'
description 'InGame Shop with tokens'

fx_version 'adamant'
game 'gta5'

client_scripts {    
    'src/RMenu.lua',
    'src/menu/RageUI.lua',
    'src/menu/Menu.lua',
    'src/menu/MenuController.lua',
    'src/components/*.lua',
    'src/menu/elements/*.lua',
    'src/menu/items/*.lua',
    'src/menu/panels/*.lua',
    'src/menu/windows/*.lua',
    'config.lua',
    
    'client/main.lua',
    'client/menu.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',

    'server/main.lua',
}