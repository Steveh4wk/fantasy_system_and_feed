-- vampire_client.lua
-- Funzioni specifiche Vampiro

RegisterNetEvent('fantasy_peds:client:VampireSpecial', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 300)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.2)
    print("[FANTASY_PEDS] Vampiro: effetti speciali applicati")
end)
