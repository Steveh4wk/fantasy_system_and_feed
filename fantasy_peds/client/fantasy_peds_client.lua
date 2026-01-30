-- fantasy_peds_client.lua
-- Gestione trasformazioni, ped, menu e spell casting (tasti 0-6)
-- Integrazione completa con fantasy_skilltree

local FantasyPeds = {
    vampire = { model = "Vampire" },
    lycan = { model = "icewolf" },
    animagus = { model = "random" } -- verrà scelto randomicamente
}

-- 6 animali nativi GTA per trasformazione Animagus
local AnimagusAnimals = {
    "a_c_deer",        -- Cervo
    "a_c_coyote",      -- Coyote
    "a_c_mtlion",      -- Leone di montagna
    "a_c_boar",        -- Cinghiale
    "a_c_rabbit_01",   -- Coniglio
    "a_c_chimp"        -- Scimpanzé
}

local SpellSlots = {0,1,2,3,4,5,6} -- tasti per spell casting
local CurrentForm = nil -- forma corrente del giocatore

-- ==============================
-- UTILITY MODELLO SICURO
-- ==============================
local function LoadModelSafe(modelName)
    local hash = GetHashKey(modelName)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        print("[FANTASY_PEDS] Modello non valido:", modelName)
        return nil
    end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then
            print("[FANTASY_PEDS] Timeout caricamento modello:", modelName)
            return nil
        end
        Wait(10)
    end
    return hash
end

-- ==============================
-- APPLICA CREATURE
-- ==============================
local function ApplyCreature(form)
    local data = FantasyPeds[form]
    if not data then return end
    
    local model = nil
    
    if form == 'animagus' then
        -- Scegli un animale random dalla lista
        local randomIndex = math.random(1, #AnimagusAnimals)
        local randomAnimal = AnimagusAnimals[randomIndex]
        print("[FANTASY_PEDS] Animagus scelto:", randomAnimal)
        model = LoadModelSafe(randomAnimal)
    else
        model = LoadModelSafe(data.model)
    end
    
    if not model then return end

    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())
    Wait(100)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), form == "vampire" and 1.2 or form == "lycan" and 1.3 or 1.0)

    LocalPlayer.state:set('fantasyForm', form, true)
    CurrentForm = form

    TriggerEvent('fantasy_skilltree:client:ShowCreatureAbilities', form)
    
    -- Attiva automaticamente NUI skilltree
    TriggerEvent('fantasy_skilltree:client:ShowSkillBar', form)

    local ped = PlayerPedId()
    Entity(ped).state.isVampire = (form == "vampire")
    Entity(ped).state.isLycan = (form == "lycan")
    Entity(ped).state.isAnimagus = (form == "animagus")
    print("[FANTASY_PEDS] Trasformato in:", form)
end

-- ==============================
-- RIPRISTINA PED UMANO
-- ==============================
local function RestoreOriginalPed()
    local ped = PlayerPedId()
    LocalPlayer.state:set('fantasyForm', nil, true)
    CurrentForm = nil

    Entity(ped).state.isVampire = false
    Entity(ped).state.isLycan = false
    Entity(ped).state.isAnimagus = false

    -- Controlla il genere del player e imposta il modello appropriato
    local isMale = true -- default maschio
    
    -- Prova a ottenere dati da QBCore, se disponibile
    if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.charinfo then
            isMale = playerData.charinfo.gender == 0 -- 0 = maschio, 1 = femmina
        end
    else
        -- Fallback: controlla il modello corrente per determinare il genere
        local currentModel = GetEntityModel(ped)
        if currentModel == GetHashKey("mp_f_freemode_01") then
            isMale = false
        end
        print("[FANTASY_PEDS] QBCore non disponibile, uso fallback per genere")
    end
    
    local humanModel = isMale and "mp_m_freedom_01" or "mp_f_freedom_01"
    local hash = LoadModelSafe(humanModel)
    if not hash then return end
    
    SetPlayerModel(PlayerId(), hash)
    SetPedDefaultComponentVariation(ped)
    LocalPlayer.state:set('invHotkeys', true, true)
    
    -- Chiudi skillbar e NUI
    TriggerEvent('fantasy_skilltree:client:HideCreatureAbilities')
    
    print("[FANTASY_PEDS] Ripristinato ped umano:", humanModel)
end

-- ==============================
-- SPELL CASTING DA 0 A 6
-- ==============================
local function CastSpell(slot)
    if not CurrentForm then
        print("[FANTASY_PEDS] Non sei trasformato, impossibile lanciare spell")
        return
    end
    -- Trigger fantasy_skilltree con forma corrente e slot
    print("[FANTASY_PEDS] Casting spell slot:", slot, "form:", CurrentForm)
    TriggerEvent('fantasy_skilltree:client:cast', slot, CurrentForm)
end

-- Crea comandi per tasti 0-6
for _, slot in ipairs(SpellSlots) do
    RegisterCommand('spell'..slot, function()
        CastSpell(slot)
    end)
    RegisterKeyMapping('spell'..slot, 'Fantasy Spell Slot '..slot, 'keyboard', tostring(slot))
end

-- Comando diretto per tornare umano
RegisterCommand('tornaumano', function()
    print("[FANTASY_PEDS] Comando tornaumano eseguito")
    RestoreOriginalPed()
end)
RegisterKeyMapping('tornaumano', 'Torna Umano', 'keyboard', 'X')

-- Comando test per verificare funzioni
RegisterCommand('testrestore', function()
    print("[FANTASY_PEDS] Test RestoreOriginalPed...")
    if RestoreOriginalPed then
        print("[FANTASY_PEDS] RestoreOriginalPed disponibile, eseguo...")
        RestoreOriginalPed()
    else
        print("[FANTASY_PEDS] ERRORE: RestoreOriginalPed non disponibile!")
    end
end)

-- Menu ox_lib
RegisterCommand('creatures', function()
    print("[FANTASY_PEDS] Menu creatures richiesto")
    
    local menu = {
        { title="Vampiro", description="Trasformati in Vampiro", icon="skull", onSelect=function() 
            print("[FANTASY_PEDS] Scelto Vampiro")
            ApplyCreature('vampire') 
        end },
        { title="Lycan", description="Trasformati in Licantropo", icon="paw", onSelect=function() 
            print("[FANTASY_PEDS] Scelto Lycan")
            ApplyCreature('lycan') 
        end },
        { title="Animagus", description="Trasformati in Animagus", icon="feather", onSelect=function() 
            print("[FANTASY_PEDS] Scelto Animagus")
            ApplyCreature('animagus') 
        end },
        { title="Torna Umano", description="Ripristina forma umana", icon="user", onSelect=function() 
            print("[FANTASY_PEDS] Scelto Torna Umano")
            RestoreOriginalPed() 
        end }
    }
    
    if lib and lib.registerContext then
        print("[FANTASY_PEDS] Mostro menu ox_lib")
        lib.registerContext({id='creature_menu', title='🌙 Menu Creature', options=menu})
        lib.showContext('creature_menu')
    else
        print("[FANTASY_PEDS] ox_lib non trovato, uso fallback comandi diretti")
        lib.notify({
            title = 'Menu Creature',
            description = 'Usa /tornaumano per tornare umano',
            type = 'info'
        })
    end
end)
RegisterKeyMapping('creatures','Menu Creature','keyboard','F7')

-- ==============================
-- EXPORTS
-- ==============================
exports('ApplyCreature', ApplyCreature)
exports('RestoreOriginalPed', RestoreOriginalPed)

-- Pulisci tutto al relog
AddEventHandler('playerSpawned', function()
    print('[FANTASY_PEDS] Player spawned - reset stato trasformazione')
    CurrentForm = nil
    LocalPlayer.state:set('fantasyForm', nil, true)
    
    -- Resetta stato creature
    local ped = PlayerPedId()
    Entity(ped).state.isVampire = false
    Entity(ped).state.isLycan = false
    Entity(ped).state.isAnimagus = false
    
    -- Chiudi skillbar se aperta
    TriggerEvent('fantasy_skilltree:client:HideCreatureAbilities')
end)
