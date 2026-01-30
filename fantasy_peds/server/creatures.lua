-- ==========================================================
-- Fantasy Peds Server
-- Autore: Stefano Luciano Corp
-- Sistema Server per Creature - Cooldown condiviso e sincronizzazione
-- VERSIONE COMPLETA - SISTEMA PERMESSI RAZZA

local CreatureCooldowns = {}
local PlayerRaces = {} -- Salva le razze dei player
local AnimalFeedStats = {} -- ✅ AGGIUNTO: Fix errore nil
local COOLDOWN_TIME = 5 -- 5 secondi per test

-- ==============================
-- SISTEMA PERMESSI RAZZA
-- ==============================
RegisterNetEvent('fantasy_creatures:server:checkRacePermission', function(race)
    local src = source
    local playerId = GetPlayerIdentifier(src)

    print(string.format("[FANTASY_PEDS SERVER] 📥 Ricevuta richiesta trasformazione: %s da player %s", race, playerId))

    -- Per ora permette a tutti (da configurare con whitelist/database)
    -- TODO: Integrare con database player per salvare razze permanenti

    if not PlayerRaces[playerId] then
        PlayerRaces[playerId] = {}
    end

    -- Check se il player ha questa razza sbloccata
    if not PlayerRaces[playerId][race] then
        -- Per ora auto-sblocca la prima volta (da cambiare con sistema progressione)
        PlayerRaces[playerId][race] = true
        
        print(string.format("[FANTASY_PEDS SERVER] ✅ Razza %s sbloccata per player %s", race, playerId))
        
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            TriggerClientEvent('QBCore:Notify', src, 'Hai sbloccato la razza ' .. race .. '!', 'success')
        else
            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Fantasy Creatures", "Hai sbloccato la razza " .. race .. "!"}
            })
        end
    end
    
    -- Procedi con il check cooldown
    local now = os.time()
    
    -- Check cooldown
    if CreatureCooldowns[src] and CreatureCooldowns[src] > now then
        local remaining = CreatureCooldowns[src] - now
        local minutes = math.ceil(remaining / 60)
        
        print(string.format("[FANTASY_PEDS SERVER] ❌ Cooldown attivo per player %s: %d minuti", playerId, minutes))
        
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            TriggerClientEvent('QBCore:Notify', src, 'Cooldown attivo! Attendi ' .. minutes .. ' minuti', 'error')
        else
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Fantasy Creatures", "Cooldown attivo! Attendi " .. minutes .. " minuti"}
            })
        end
        return
    end

    -- Imposta cooldown
    CreatureCooldowns[src] = now + COOLDOWN_TIME

    print(string.format("[FANTASY_PEDS SERVER] 🚀 Autorizzo trasformazione %s per player %s", race, playerId))

    -- Autorizza trasformazione
    TriggerClientEvent('fantasy_peds:client:transformAuthorized', src, race)
end)

-- ==============================
-- TRASFORMAZIONE DIRETTA (ADMIN)
-- ==============================
RegisterNetEvent('fantasy_creatures:server:transformTo', function(creature)
    local src = source
    
    -- Check cooldown
    local now = os.time()
    
    if CreatureCooldowns[src] and CreatureCooldowns[src] > now then
        local remaining = CreatureCooldowns[src] - now
        local minutes = math.ceil(remaining / 60)
        
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            TriggerClientEvent('QBCore:Notify', src, 'Cooldown attivo! Attendi ' .. minutes .. ' minuti', 'error')
        else
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Fantasy Creatures", "Cooldown attivo! Attendi " .. minutes .. " minuti"}
            })
        end
        return
    end

    -- Imposta cooldown
    CreatureCooldowns[src] = now + COOLDOWN_TIME

    -- Autorizza trasformazione
    TriggerClientEvent('fantasy_peds:client:transformAuthorized', src, creature)
end)

-- ==============================
-- PULIZIA AL DISCONNECT
-- ==============================
AddEventHandler('playerDropped', function()
    local src = source
    CreatureCooldowns[src] = nil
    
    -- Pulisci statistiche feeding
    local playerId = GetPlayerIdentifier(src)
    AnimalFeedStats[playerId] = nil
end)

-- ==============================
-- COMANDI ADMIN PER DEBUG
-- ==============================
RegisterCommand('creature_reset', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        local target = tonumber(args[1])
        if target then
            CreatureCooldowns[target] = nil
            print(string.format("Reset creature cooldown per player %s", target))
        end
    end
end, false)

RegisterCommand('creature_force', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        local target = tonumber(args[1])
        local creature = args[2]
        if target and creature then
            TriggerClientEvent('fantasy_peds:client:transformAuthorized', target, creature)
            print(string.format("Forzata autorizzazione trasformazione in %s per player %s", creature, GetPlayerName(target)))
        else
            print("Uso: /creature_force [player_id] [vampire|lycan]")
        end
    end
end, false)

print('[INFO] Fantasy Peds Server caricato!')
