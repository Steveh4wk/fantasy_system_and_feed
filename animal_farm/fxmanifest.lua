fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'animal_farm'
author 'Stefano Luciano Corp'
version '1.0.0'
description 'Animal Farm: Spawning, feeding, harvesting, and creature interaction'

dependencies {
    'ox_inventory',
    'ox_target',
    'ox_lib'
}

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/animal_spawner.lua'
}

server_script 'server/main.lua'

print('[Animal Farm] Manifest loaded')