fx_version 'adamant'
game 'gta5'

name 'ESX Vehicle Location'
description 'This script allows you to rent vehicles to the newcomer for example at the airport of your city.'
website 'https://github.com/ESX-FRANCE/esx_vehicle_location'
version '0.0.2'
author 'keketiger'

server_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/fr.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/fr.lua',
    'config.lua',
    'client/main.lua'
}

dependencies {
    'es_extended'
}
