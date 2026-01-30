-- shared/animagus.lua
-- Stefano Luciano Corp
-- Configurazioni condivise per Animagus (enum, cooldown, valori base)
-- ========================================

AnimagusConfig = {
    SlotCount = 7, -- slot 0-6
    DefaultCooldown = 5000, -- 5 secondi
    DefaultHealth = 200,
    DefaultSpeed = 1.0,
    Spells = {
        [0] = { name = "FlightBoost", description = "Aumenta velocità in volo" },
        [1] = { name = "EnhancedSenses", description = "Migliora percezione animali e nemici" },
        [2] = { name = "BeastStrike", description = "Attacco speciale Animagus" },
        [3] = { name = "Camouflage", description = "Diventa meno visibile" },
        [4] = { name = "HealingAura", description = "Rigenera salute gradualmente" },
        [5] = { name = "Roar", description = "Spaventa nemici vicini" },
        [6] = { name = "UltimateForm", description = "Trasformazione massima Animagus" }
    }
}

exports('GetAnimagusConfig', function()
    return AnimagusConfig
end)