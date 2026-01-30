-- ==========================================================
-- Fantasy Skill Tree - Dynamic Creature Power System
-- Autore: Stefano Luciano Corp
-- SISTEMA POWER DINAMICO: Stamina/Rage/Sangue
-- ==========================================================

-- =========================
-- CONFIGURAZIONE POWER DINAMICO
-- =========================

local PowerConfig = {
    -- =========================
    -- VAMPIRO - SANGUE
    -- =========================
    vampire = {
        maxPower = 100,
        powerType = 'blood',
        decayRate = 0.5,      -- Per secondi
        abilityCost = {
            bloodlust = 15,
            mist_form = 25,
            vampire_bite = 10,
            bat_swarm = 30
        },
        regenRate = 2.0,      -- Quando si nutre
        regenDuration = 5000, -- 5 secondi
        color = '#8B0000'     -- Dark red
    },
    
    -- =========================
    -- LYCAN - RAGE
    -- =========================
    lycan = {
        maxPower = 100,
        powerType = 'rage',
        decayRate = 0.8,      -- Per secondi
        abilityCost = {
            rage = 20,
            claw_swipe = 12,
            wolf_howl = 8,
            enhanced_senses = 15
        },
        regenRate = 3.0,      -- Quando si nutre
        regenDuration = 4000, -- 4 secondi
        color = '#FF4500'      -- Orange red
    },
    
    -- =========================
    -- ANIMAGUS - STAMINA
    -- =========================
    animagus = {
        maxPower = 100,
        powerType = 'stamina',
        decayRate = 0.3,      -- Per secondi
        abilityCost = {
            swift = 10,
            stealth = 15,
            enhanced_senses = 8,
            flight = 25
        },
        regenRate = 1.5,      -- Passivo
        regenDuration = 3000, -- 3 secondi
        color = '#228B22'     -- Forest green
    }
}

-- =========================
-- STATE MANAGEMENT
-- =========================

local currentPower = 100
local isRegenerating = false
local lastDecayTime = GetGameTimer()
local lastNotifiedPower = 100 -- ✅ Aggiunto per evitare notifiche ripetute

-- =========================
-- POWER FUNCTIONS
-- =========================

-- Ottieni configurazione power per forma
local function GetPowerConfig(form)
    return PowerConfig[form]
end

-- Calcola decay rate basato su attività
local function GetDecayRate(form)
    local config = GetPowerConfig(form)
    if not config then return 0 end
    
    local baseRate = config.decayRate
    
    -- Aumenta decay se si sta usando abilità o correndo
    local ped = PlayerPedId()
    if IsPedSprinting(ped) then
        baseRate = baseRate * 1.5
    end
    
    if IsPedInMeleeCombat(ped) then
        baseRate = baseRate * 2.0
    end
    
    return baseRate
end

-- Aggiorna power dinamico
local function UpdatePower()
    local form = LocalPlayer.state.fantasyForm
    if not form then
        currentPower = 100
        return
    end
    
    local config = GetPowerConfig(form)
    if not config then return end
    
    local currentTime = GetGameTimer()
    local deltaTime = (currentTime - lastDecayTime) / 1000.0
    lastDecayTime = currentTime
    
    -- Applica decay
    if not isRegenerating then
        local decayRate = GetDecayRate(form)
        currentPower = math.max(0, currentPower - (decayRate * deltaTime))
    end
    
    -- Limita al massimo
    currentPower = math.min(config.maxPower, currentPower)
    
    -- Aggiorna state bag
    LocalPlayer.state:set('fantasyPower', currentPower, false)
    
    -- Notifica se power basso (solo una volta)
    if currentPower <= 20 and currentPower > 19 and lastNotifiedPower > 20 then
        TriggerEvent('ox_lib:notify', {
            title = 'Power Basso',
            description = string.format('%s: %.0f%%', config.powerType, currentPower),
            type = 'warning'
        })
        lastNotifiedPower = currentPower
    end
    
    -- Notifica se power esaurito (solo una volta)
    if currentPower <= 0 and lastNotifiedPower > 0 then
        TriggerEvent('ox_lib:notify', {
            title = 'Power Esaurito',
            description = string.format('Non puoi usare abilità %s', config.powerType),
            type = 'error'
        })
        lastNotifiedPower = currentPower
    end
    
    -- Resetta notifica se il power torna sopra 0
    if currentPower > 0 and lastNotifiedPower <= 0 then
        lastNotifiedPower = currentPower
    end
end

-- Controlla se si può usare abilità
local function CanUseAbility(abilityId)
    local form = LocalPlayer.state.fantasyForm
    if not form then return false end
    
    local config = GetPowerConfig(form)
    if not config then return false end
    
    local cost = config.abilityCost[abilityId]
    if not cost then return true end
    
    return currentPower >= cost
end

-- Usa power per abilità
local function UseAbilityPower(abilityId)
    local form = LocalPlayer.state.fantasyForm
    if not form then return false end
    
    local config = GetPowerConfig(form)
    if not config then return false end
    
    local cost = config.abilityCost[abilityId]
    if not cost then return true end
    
    if currentPower >= cost then
        currentPower = currentPower - cost
        LocalPlayer.state:set('fantasyPower', currentPower, false)
        
        TriggerEvent('ox_lib:notify', {
            title = 'Power Usato',
            description = string.format('-%.0f %s', cost, config.powerType),
            type = 'info'
        })
        
        return true
    else
        TriggerEvent('ox_lib:notify', {
            title = 'Power Insufficiente',
            description = string.format('Servono %.0f %s', cost, config.powerType),
            type = 'error'
        })
        
        return false
    end
end

-- Rigenera power (feeding, riposo, etc.)
local function RegeneratePower(amount, duration)
    local form = LocalPlayer.state.fantasyForm
    if not form then return end
    
    local config = GetPowerConfig(form)
    if not config then return end
    
    if isRegenerating then return end
    
    isRegenerating = true
    
    CreateThread(function()
        local startTime = GetGameTimer()
        local endTime = startTime + duration
        
        while GetGameTimer() < endTime do
            local progress = (GetGameTimer() - startTime) / duration
            currentPower = math.min(config.maxPower, currentPower + (amount * progress))
            LocalPlayer.state:set('fantasyPower', currentPower, false)
            
            Wait(100)
        end
        
        isRegenerating = false
        
        TriggerEvent('ox_lib:notify', {
            title = 'Power Rigenerato',
            description = string.format('+%.0f %s', amount, config.powerType),
            type = 'success'
        })
    end)
end

-- =========================
-- MAIN UPDATE LOOP
-- =========================

CreateThread(function()
    while true do
        Wait(1000) -- Update ogni secondo
        
        UpdatePower()
    end
end)

-- =========================
-- INTEGRAZIONE FEEDING
-- =========================

-- Quando il giocatore si nutre, rigenera power
RegisterNetEvent('fantasy_skilltree:client:feedingComplete', function(feedType)
    local form = LocalPlayer.state.fantasyForm
    if not form then return end
    
    local config = GetPowerConfig(form)
    if not config then return end
    
    -- Rigenera power basato sul tipo di nutrimento
    local regenAmount = 30
    
    if form == 'vampire' and feedType == 'blood' then
        regenAmount = 50 -- Bonus per sangue
    elseif form == 'lycan' and feedType == 'meat' then
        regenAmount = 40 -- Bonus per carne
    end
    
    RegeneratePower(regenAmount, config.regenDuration)
end)

-- =========================
-- ESPORTAZIONI
-- =========================

exports('GetCurrentPower', function() return currentPower end)
exports('GetMaxPower', function() 
    local form = LocalPlayer.state.fantasyForm
    local config = GetPowerConfig(form)
    return config and config.maxPower or 100
end)
exports('GetPowerType', function()
    local form = LocalPlayer.state.fantasyForm
    local config = GetPowerConfig(form)
    return config and config.powerType or 'none'
end)
exports('CanUseAbility', CanUseAbility)
exports('UseAbilityPower', UseAbilityPower)
exports('RegeneratePower', RegeneratePower)
exports('GetPowerConfig', GetPowerConfig)

-- =========================
-- DEBUG COMMANDS
-- =========================

RegisterCommand('power_debug', function()
    local form = LocalPlayer.state.fantasyForm
    local config = GetPowerConfig(form)
    
    print(string.format('=== POWER DEBUG ==='))
    print(string.format('Form: %s', form or 'human'))
    print(string.format('Current Power: %.1f', currentPower))
    print(string.format('Power Type: %s', config and config.powerType or 'none'))
    print(string.format('Max Power: %d', config and config.maxPower or 100))
    print(string.format('Decay Rate: %.2f/s', GetDecayRate(form)))
    print(string.format('Is Regenerating: %s', tostring(isRegenerating)))
end)

RegisterCommand('power_fill', function()
    local form = LocalPlayer.state.fantasyForm
    local config = GetPowerConfig(form)
    if config then
        currentPower = config.maxPower
        LocalPlayer.state:set('fantasyPower', currentPower, false)
        TriggerEvent('ox_lib:notify', {
            title = 'Power',
            description = 'Power riempito al massimo',
            type = 'success'
        })
    end
end)

RegisterCommand('power_empty', function()
    currentPower = 0
    LocalPlayer.state:set('fantasyPower', currentPower, false)
    TriggerEvent('ox_lib:notify', {
        title = 'Power',
        description = 'Power svuotato',
        type = 'info'
    })
end)

print('[INFO] Dynamic Creature Power System caricato!')
