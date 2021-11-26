fx_version 'cerulean'
game 'gta5'

name 'ESX Vehicle Location'
description 'Allow vehicle rental to the new player. Example: at the airport.'
website 'https://github.com/ESX-FRANCE/esx_vehicle_location'
version '1.0.0'
author 'keketiger'

server_script 'server/main.lua'

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/fr.lua',
    'config.lua',
    'client/main.lua'
}

dependency 'es_extended'
