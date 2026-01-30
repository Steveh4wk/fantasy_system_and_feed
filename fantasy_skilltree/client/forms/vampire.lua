-- client/forms/vampire.lua
-- Stefano Luciano Corp
-- Spell specifiche Vampire secondo specifiche dettagliate
-- ========================================

local VampireSpells = {
    [6] = function()
        print('[Vampire] Slot 6: Aura')
        local ped = PlayerPedId()
        
        -- Animazione attivazione aura
        TaskPlayAnim(ped, "amb@world_human_yoga@male@base", "base_a", 8.0, -8.0, 2000, 1, 0, 0, 0, 0)
        
        -- Aura rossa attorno al Vampire
        SetEntityAlpha(ped, 150, false)
        SetTimecycleModifier("rply_saturation")
        
        -- Particelle aura rossa intensa
        UseParticleFxAssetNextCall("core")
        local particle1 = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.5, false, false, false)
        local particle2 = StartParticleFxLoopedOnEntity("blood_splash", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)
        
        -- Imposta stato aura attiva
        Entity(ped).state.vampireAura = true
        
        -- Effetto sonoro sottile
        PlayPedAmbientSpeechNative(ped, "GENERIC_CURSE_HIGH", "SPEECH_PARAMS_FORCE")
        
        lib.notify({
            title = 'Vampire',
            description = 'Aura rossa attivata! Ora puoi mordere.',
            type = 'success'
        })
        
        -- L'aura rimane attiva finché non disattivata manualmente
    end,
    [7] = function()
        print('[Vampire] Slot 7: Morso')
        local ped = PlayerPedId()
        
        -- Verifica se aura è attiva
        if not Entity(ped).state.vampireAura then
            lib.notify({
                title = 'Vampire',
                description = 'Aura non attiva! Attivala prima di mordere.',
                type = 'error'
            })
            return
        end
        
        -- Animazione morso RP aggressiva
        TaskPlayAnim(ped, "melee@unarmed@streamed_core", "attack_heavy", 8.0, -8.0, 2000, 48, 0, 0, 0, 0)
        
        -- Trova bersaglio più vicino
        local coords = GetEntityCoords(ped)
        local closestTarget = nil
        local closestDist = 2.0
        
        for _, targetPed in pairs(GetGamePool('CPed')) do
            if DoesEntityExist(targetPed) and targetPed ~= ped then
                local targetCoords = GetEntityCoords(targetPed)
                local dist = #(coords - targetCoords)
                if dist < closestDist then
                    closestTarget = targetPed
                    closestDist = dist
                end
            end
        end
        
        if closestTarget then
            -- Effetti morso sul bersaglio
            SetPedToRagdoll(closestTarget, 60000, 60000, 0, 0, 0, 0) -- 1 minuto ragdoll
            SetEntityHealth(closestTarget, 20) -- Vita a 20 HP
            
            -- Effetto specchio rotto (glitch visivo intenso)
            CreateThread(function()
                for i = 1, 60 do -- 60 glitch in 1 minuto
                    if DoesEntityExist(closestTarget) then
                        -- Effetto glitch visivo specchio rotto
                        SetEntityAlpha(closestTarget, math.random(20, 255), false)
                        SetEntityHeading(closestTarget, GetEntityHeading(closestTarget) + math.random(-90, 90))
                        
                        -- Effetto camera shake per simulare specchio rotto
                        if i % 10 == 0 then
                            ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 500)
                        end
                        
                        Wait(1000)
                    end
                end
                -- Reset finale
                if DoesEntityExist(closestTarget) then
                    SetEntityAlpha(closestTarget, 255, false)
                end
            end)
            
            -- Particelle sangue intense
            UseParticleFxAssetNextCall("core")
            local particle = StartParticleFxLoopedOnEntity("blood_splash", closestTarget, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 2.0, false, false, false)
            
            -- Effetti sul Vampire: refill completo cibo e acqua
            TriggerEvent('fantasy_peds:client:AddHunger', 100)
            TriggerEvent('fantasy_peds:client:AddThirst', 100)
            
            -- Effetto visivo sul Vampire (assorbe energia)
            SetEntityAlpha(ped, 120, false)
            Wait(1000)
            SetEntityAlpha(ped, 150, false) -- Torna ad aura
            
            Wait(1500)
            StopParticleFxLooped(particle, false)
            
            lib.notify({
                title = 'Vampire',
                description = 'MORSO RP eseguito! 1 minuto ragdoll + refill completo',
                type = 'success'
            })
        else
            lib.notify({
                title = 'Vampire',
                description = 'Nessun bersaglio nelle vicinanze!',
                type = 'error'
            })
        end
    end,
    [8] = function()
        print('[Vampire] Slot 8: Nutriti')
        local ped = PlayerPedId()
        
        -- Controlla se ha item sangue nell'inventario
        local hasBlood = false
        -- Qui dovresti integrare con ox_inventory per controllare l'item
        
        if not hasBlood then
            lib.notify({
                title = 'Vampire',
                description = 'Non hai sangue nell\'inventario!',
                type = 'error'
            })
            return
        end
        
        -- Animazione nutrirsi (bere sangue)
        TaskPlayAnim(ped, "amb@world_human_drinking@coffee@male@idle_a", "idle_c", 8.0, -8.0, 3000, 49, 0, 0, 0, 0)
        
        -- Effetti nutrizione
        SetEntityAlpha(ped, 180, false)
        UseParticleFxAssetNextCall("core")
        local particle = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)
        
        -- Rimuovi item sangue (da implementare con ox_inventory)
        -- TriggerServerEvent('ox_inventory:removeItem', 'sangue', 1)
        
        -- Refill completo cibo e acqua
        TriggerEvent('fantasy_peds:client:AddHunger', 100)
        TriggerEvent('fantasy_peds:client:AddThirst', 100)
        
        -- Effetti rigenerazione
        local health = GetEntityHealth(ped)
        SetEntityHealth(ped, math.min(health + 50, 300))
        
        -- Effetto visivo potenza
        SetTimecycleModifier("rply_saturation")
        Wait(2000)
        ClearTimecycleModifier()
        
        Wait(1500)
        SetEntityAlpha(ped, 255, false)
        StopParticleFxLooped(particle, false)
        
        lib.notify({
            title = 'Vampire',
            description = 'Nutrizione completata! Refill cibo/acqua +50 HP',
            type = 'success'
        })
    end,
    [9] = function()
        print('[Vampire] Slot 9: Disattiva Aura')
        local ped = PlayerPedId()
        
        -- Animazione disattivazione
        TaskPlayAnim(ped, "amb@world_human_yoga@male@base", "base_a", 8.0, -8.0, 1500, 1, 0, 0, 0, 0)
        
        -- Rimuovi aura
        SetEntityAlpha(ped, 255, false)
        ClearTimecycleModifier()
        
        -- Disattiva stato aura
        Entity(ped).state.vampireAura = false
        
        lib.notify({
            title = 'Vampire',
            description = 'Aura disattivata.',
            type = 'info'
        })
    end,
    [0] = nil -- Slot vuoto
}

RegisterNetEvent('fantasy_skilltree:client:castSpell', function(form, slot)
    if form ~= 'vampire' then return end
    local spell = VampireSpells[slot]
    if spell then spell() end
end)

exports('GetVampireSpells', function() return VampireSpells end)
