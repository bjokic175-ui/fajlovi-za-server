fx_version 'cerulean'
game 'gta5'

author 'Gang System'
description 'ESX Legacy Gang System sa pljačkom banke'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'mysql-async'
}