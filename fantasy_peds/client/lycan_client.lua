-- lycan_client.lua
-- Funzioni specifiche Lycan

RegisterNetEvent('fantasy_peds:client:LycanSpecial', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 350)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.3)
    print("[FANTASY_PEDS] Lycan: effetti speciali applicati")
end)
