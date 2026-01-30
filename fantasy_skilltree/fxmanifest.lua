fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

name 'fantasy_skilltree'
author 'Steveh4wk'
version '1.0.0'
description 'Skill tree and spell casting system for fantasy forms'

-- ==========================================================
-- Dependencies
-- ==========================================================
dependencies {
    'ox_lib'
}

-- ==========================================================
-- Shared Scripts
-- ==========================================================
shared_script '@ox_lib/init.lua'
shared_scripts {
    'shared/animagus.lua',   -- solo dati condivisi per animagus (può contenere enum o configurazioni)
}

-- ==========================================================
-- Client Scripts
-- ==========================================================
client_scripts {
    'client/fantasy_skilltree_client.lua',   -- logica principale spell casting e menu
    'client/dynamic_power.lua',             -- effetti/variabili runtime spell
    'client/forms/vampire.lua',             -- effetti e spell specifiche vampire
    'client/forms/lycan.lua',               -- effetti e spell specifiche lycan
    'client/forms/animagus.lua',            -- effetti e spell specifiche animagus
}

-- ==========================================================
-- Server Scripts
-- ==========================================================
server_scripts {
    'server/integration.lua',               -- integrazione eventuale con altri sistemi
    'server/animagus.lua'                  -- solo se gli effetti server-side sono necessari
}

-- ==========================================================
-- NUI (opzionale, se spell tree ha interfaccia)
-- ==========================================================
ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}
