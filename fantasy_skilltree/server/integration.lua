-- server/integration.lua
-- Stefano Luciano Corp
-- Gestione server-side spell tracking e cooldown
-- ========================================

local SpellCooldowns = {}

RegisterNetEvent('fantasy_skilltree:server:castSpell', function(slot)
    local src = source
    local now = os.time()

    if SpellCooldowns[src] and SpellCooldowns[src][slot] and SpellCooldowns[src][slot] > now then
        TriggerClientEvent('QBCore:Notify', src, 'Spell in cooldown', 'error')
        return
    end

    SpellCooldowns[src] = SpellCooldowns[src] or {}
    SpellCooldowns[src][slot] = now + 5 -- 5 secondi cooldown

    -- Trigger client
    TriggerClientEvent('fantasy_skilltree:client:castSpell', src, LocalPlayer.state.fantasyForm, slot)
end)

AddEventHandler('playerDropped', function()
    local src = source
    SpellCooldowns[src] = nil
end)