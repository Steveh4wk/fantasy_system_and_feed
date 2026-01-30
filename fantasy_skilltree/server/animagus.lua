-- server/animagus.lua
-- Stefano Luciano Corp
-- Effetti server-side Animagus (volo, sensi, ultimate)
-- ========================================

local AnimagusServerState = {}

RegisterNetEvent('fantasy_skilltree:server:animagusEffect', function(playerId, effectName)
    AnimagusServerState[playerId] = AnimagusServerState[playerId] or {}
    AnimagusServerState[playerId][effectName] = true
end)

AddEventHandler('playerDropped', function()
    local src = source
    AnimagusServerState[src] = nil
end)

exports('GetAnimagusServerState', function()
    return AnimagusServerState
end)