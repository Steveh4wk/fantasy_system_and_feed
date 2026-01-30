-- client/forms/animagus.lua
-- Stefano Luciano Corp
-- Spell specifiche Animagus
-- ========================================

local AnimagusSpells = {
    [0] = function() print('[Animagus] Slot 0: Flight Boost') end,
    [1] = function() print('[Animagus] Slot 1: Enhanced Senses') end,
    [2] = function() print('[Animagus] Slot 2: Beast Strike') end,
    [3] = function() print('[Animagus] Slot 3: Camouflage') end,
    [4] = function() print('[Animagus] Slot 4: Healing Aura') end,
    [5] = function() print('[Animagus] Slot 5: Roar') end,
    [6] = function() print('[Animagus] Slot 6: Ultimate Form') end
}

RegisterNetEvent('fantasy_skilltree:client:castSpell', function(form, slot)
    if form ~= 'animagus' then return end
    local spell = AnimagusSpells[slot]
    if spell then spell() end
end)

exports('GetAnimagusSpells', function() return AnimagusSpells end)
