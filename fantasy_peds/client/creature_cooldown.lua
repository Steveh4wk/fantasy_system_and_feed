-- Stefano Luciano Corp
-- Sistema Client Cooldown e Trasformazioni Server-Authoritative

local isTransforming = false
local currentCreature = nil

-- ==============================
-- EVENTI SERVER COOLDOWN
-- ==============================
RegisterNetEvent('fantasy_creatures:client:transformDenied', function(timeLeft)
    if lib and lib.notify then
        lib.notify({
            title = 'Creature',
            description = ('Devi attendere %d secondi prima di trasformarti'):format(timeLeft),
            type = 'error'
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Creature", ("Devi attendere %d secondi prima di trasformarti"):format(timeLeft)}
        })
    end
end)

RegisterNetEvent('fantasy_creatures:client:transformApproved', function(creature)
    if creature == 'vampire' then
        TriggerEvent('fantasy_peds:client:becomeVampire')
    elseif creature == 'demogorgon' then
        TriggerEvent('fantasy_peds:client:becomeDemogorgon')
    end
    
    currentCreature = creature
    isTransforming = false
end)

-- ==============================
-- FUNZIONE RICHIESTA TRASFORMAZIONE
-- ==============================
local function RequestTransformation(creature)
    if isTransforming then
        if lib and lib.notify then
            lib.notify({title = 'Creature', description = 'Trasformazione già in corso...', type = 'error'})
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Creature", "Trasformazione già in corso..."}
            })
        end
        return
    end
    
    if currentCreature then
        if lib and lib.notify then
            lib.notify({title = 'Creature', description = 'Sei già una creatura! Torna umano prima.', type = 'error'})
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Creature", "Sei già una creatura! Torna umano prima."}
            })
        end
        return
    end
    
    isTransforming = true
    TriggerServerEvent('fantasy_creatures:server:requestTransform', creature)
end

-- ==============================
-- FUNZIONE RESET STATO
-- ==============================
local function ClearCreatureState()
    if currentCreature then
        TriggerServerEvent('fantasy_creatures:server:clearState')
        currentCreature = nil
    end
end

-- ==============================
-- ESPORTAZIONI
-- ==============================
exports('RequestTransformation', RequestTransformation)
exports('ClearCreatureState', ClearCreatureState)
exports('GetCurrentCreature', function() return currentCreature end)
exports('IsTransforming', function() return isTransforming end)
