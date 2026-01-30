fx_version 'cerulean'
game 'gta5'

author 'Stefano Luciano Corp'
description 'Fantasy Peds: Vampiri, Lycans, Animagus, Feeding e Trasformazioni'
version '1.0.0'

-- ==========================================================
-- Dependencies
-- ==========================================================
dependencies {
    'ox_inventory',
    'ox_target'
}

-- ==========================================================
-- Server Scripts
-- ==========================================================
server_scripts {
    'server/creatures.lua' -- gestione cooldown, permessi, autorizzazioni
}

-- ==========================================================
-- Client Scripts
-- ==========================================================
client_scripts {
    '@ox_lib/init.lua',               -- librerie comuni
    'client/fantasy_peds_client.lua', -- gestione trasformazioni, ped, menu
    'client/fantasy_feeding.lua',     -- gestione feeding animali, target, acqua
    'client/vampire_client.lua',      -- specifiche Vampiro
    'client/lycan_client.lua',        -- specifiche Lycan
    'client/feeding_interaction.lua', -- interazione pulsante feeding prossimità
    'client/feeding_prop.lua'         -- prop per il feed dei fantasy ped
}

-- ==========================================================
-- Data Files / Streaming
-- ==========================================================
-- Vampire
data_file 'PED_METADATA_FILE' 'stream/Vampire/peds.meta'

files {
    'stream/Vampire/Vampire.ydd',
    'stream/Vampire/Vampire.yft',
    'stream/Vampire/Vampire.ymt',
    'stream/Vampire/Vampire.ytd',
    'stream/Vampire/peds.meta',
}

-- Lycan / Icewolf
data_file 'PED_METADATA_FILE' 'stream/Lycan/peds.meta'

files {
    'stream/Lycan/icewolf.ydd',
    'stream/Lycan/icewolf.yft',
    'stream/Lycan/icewolf.ymt',
    'stream/Lycan/icewolf.ytd',
    'stream/Lycan/peds.meta',
}

-- ==========================================================
-- Exports (per altri script come fantasy_creatures)
-- ==========================================================
exports {
    'IsVampire',
    'IsLycan',
    'SetPlayerState',
    'AddHunger',
    'AddThirst',
    'KillAnimalProperly',
    'RestoreOriginalPed',    -- ripristino ped umano
    'ApplyCreature'          -- trasformazione globale
}

print('[FANTASY_PEDS] Manifest caricato correttamente')
