-- client/forms/lycan.lua
-- Stefano Luciano Corp
-- Spell specifiche Lycan secondo specifiche dettagliate
-- ========================================

local LycanSpells = {
    [6] = function()
        print('[Lycan] Slot 6: Trasformazione')
        local ped = PlayerPedId()
        
        -- Animazione trasformazione lycan potente
        TaskPlayAnim(ped, "missheistdocks2preig_1@context_ext_ig_0", "handsup_base", 8.0, -8.0, 4000, 48, 0, 0, 0, 0)
        
        -- Effetti trasformazione intensi
        SetEntityHealth(ped, 400)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 3.0)
        
        -- Particelle trasformazione esplosive
        UseParticleFxAssetNextCall("core")
        local particle1 = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 3.0, false, false, false)
        local particle2 = StartParticleFxLoopedOnEntity("exp_grd_grenade_smoke", ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false)
        
        -- Effetto aura lycan potente
        SetEntityAlpha(ped, 140, false)
        SetTimecycleModifier("tunnel_lights")
        
        -- Terremoto trasformazione
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 2000)
        
        -- Effetto sonoro
        PlayPedAmbientSpeechNative(ped, "GENERIC_CURSE_HIGH", "SPEECH_PARAMS_FORCE")
        
        Wait(3500)
        SetEntityAlpha(ped, 180, false)
        ClearTimecycleModifier()
        StopParticleFxLooped(particle1, false)
        StopParticleFxLooped(particle2, false)
        
        lib.notify({
            title = 'Lycan',
            description = 'TRASFORMAZIONE COMPLETATA! Potere lupino attivato!',
            type = 'success'
        })
    end,
    [7] = function()
        print('[Lycan] Slot 7: Corsa')
        local ped = PlayerPedId()
        
        -- Animazione corsa lycan selvaggia
        TaskPlayAnim(ped, "move_jump", "dive_start_run", 8.0, -8.0, 1500, 48, 0, 0, 0, 0)
        
        -- Boost velocità +40%
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.4)
        
        -- Stamina infinita e forza potenziata
        SetPlayerSprint(PlayerId(), true)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 2.5)
        
        -- Effetto scia blu elettrica
        SetEntityAlpha(ped, 170, false)
        
        -- Particelle scia velocità
        UseParticleFxAssetNextCall("core")
        local particle = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, 1.5, false, false, false)
        
        -- Effetto sonoro ruggito
        PlayPedAmbientSpeechNative(ped, "GENERIC_CURSE_MED", "SPEECH_PARAMS_FORCE")
        
        -- Durata illimitata finché in forma lycan
        lib.notify({
            title = 'Lycan',
            description = 'CORSA SELVAGGIA! +40% velocità, stamina infinita!',
            type = 'success'
        })
    end,
    [8] = function()
        print('[Lycan] Slot 8: Graffio')
        local ped = PlayerPedId()
        
        -- Animazione graffio area feroce
        TaskPlayAnim(ped, "melee@unarmed@streamed_core", "attack_heavy", 8.0, -8.0, 1500, 48, 0, 0, 0, 0)
        
        -- Danno area 6 metri aumentato
        local coords = GetEntityCoords(ped)
        local players = GetGamePool('CPed')
        
        -- Effetto shockwave visivo
        UseParticleFxAssetNextCall("core")
        local shockwave = StartParticleFxLoopedAtCoord("exp_grd_grenade_smoke", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 3.0, false, false, false)
        
        for _, targetPed in pairs(players) do
            if DoesEntityExist(targetPed) and targetPed ~= ped then
                local targetCoords = GetEntityCoords(targetPed)
                if #(coords - targetCoords) < 6.0 then
                    -- Applica 30 HP di danno aumentato
                    local targetHealth = GetEntityHealth(targetPed)
                    SetEntityHealth(targetPed, math.max(0, targetHealth - 30))
                    
                    -- Effetto graffio intenso
                    UseParticleFxAssetNextCall("core")
                    StartParticleFxLoopedOnEntity("blood_splash", targetPed, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 2.0, false, false, false)
                    
                    -- Ragdoll potente
                    SetPedToRagdoll(targetPed, 1000, 1000, 0, 0, 0, 0)
                    
                    -- Effetto screen shake per bersaglio
                    ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 300)
                end
            end
        end
        
        -- Effetti visivi graffio su lycan
        SetEntityAlpha(ped, 150, false)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 3.5)
        
        Wait(1200)
        SetEntityAlpha(ped, 255, false)
        StopParticleFxLooped(shockwave, false)
        
        lib.notify({
            title = 'Lycan',
            description = 'GRAFFIO FEROCE! 6 metri, 30 HP danno!',
            type = 'success'
        })
    end,
    [9] = function()
        print('[Lycan] Slot 9: Morso')
        local ped = PlayerPedId()
        
        -- Animazione morso RP brutale
        TaskPlayAnim(ped, "melee@unarmed@streamed_core", "attack_heavy", 8.0, -8.0, 2500, 48, 0, 0, 0, 0)
        
        -- Trova bersaglio più vicino
        local coords = GetEntityCoords(ped)
        local closestTarget = nil
        local closestDist = 2.5
        
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
            -- Effetti morso brutale sul bersaglio
            SetPedToRagdoll(closestTarget, 60000, 60000, 0, 0, 0, 0) -- 1 minuto ragdoll
            SetEntityHealth(closestTarget, 10) -- Vita a 10 HP
            
            -- Effetto black screen intermittente potenziato
            CreateThread(function()
                for i = 1, 24 do -- 24 volte in 1 minuto
                    if DoesEntityExist(closestTarget) then
                        -- Black screen effect simulato
                        SetEntityAlpha(closestTarget, math.random(10, 40), false)
                        
                        -- Effetto camera shake violento
                        if i % 8 == 0 then
                            ShakeGameplayCam("JOLT_SHAKE", 500)
                        end
                        
                        Wait(2500)
                    end
                end
                -- Reset finale
                if DoesEntityExist(closestTarget) then
                    SetEntityAlpha(closestTarget, 255, false)
                end
            end)
            
            -- Particelle sangue violente
            UseParticleFxAssetNextCall("core")
            local particle1 = StartParticleFxLoopedOnEntity("blood_splash", closestTarget, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 3.0, false, false, false)
            local particle2 = StartParticleFxLoopedOnEntity("exp_grd_grenade_smoke", closestTarget, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, false, false, false)
            
            -- Effetto ruggito lycan
            PlayPedAmbientSpeechNative(ped, "GENERIC_FREAKED_OUT", "SPEECH_PARAMS_FORCE")
            
            Wait(2000)
            StopParticleFxLooped(particle1, false)
            StopParticleFxLooped(particle2, false)
            
            lib.notify({
                title = 'Lycan',
                description = 'MORSO BRUTALE! 1 minuto ragdoll + black screen totale!',
                type = 'success'
            })
        else
            lib.notify({
                title = 'Lycan',
                description = 'Nessun bersaglio nelle vicinanze!',
                type = 'error'
            })
        end
    end,
    [0] = function()
        print('[Lycan] Slot 0: Pozione Antilupo')
        local ped = PlayerPedId()
        
        -- Animazione bere pozione disperata
        TaskPlayAnim(ped, "amb@world_human_drinking@coffee@male@idle_a", "idle_c", 8.0, -8.0, 2500, 49, 0, 0, 0, 0)
        
        -- Effetto pozione potente
        SetEntityAlpha(ped, 100, false)
        UseParticleFxAssetNextCall("core")
        local particle1 = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 2.5, false, false, false)
        local particle2 = StartParticleFxLoopedOnEntity("exp_grd_grenade_smoke", ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false)
        
        -- Effetto purificazione violenta
        ShakeGameplayCam("JOLT_SHAKE", 1500)
        
        Wait(2000)
        
        -- Interrompe trasformazione con effetti
        TriggerEvent('fantasy_peds:client:RestoreHuman')
        
        StopParticleFxLooped(particle1, false)
        StopParticleFxLooped(particle2, false)
        
        lib.notify({
            title = 'Lycan',
            description = 'POZIONE ANTIUPOO! Trasformazione interrotta violentemente!',
            type = 'success'
        })
    end
}

RegisterNetEvent('fantasy_skilltree:client:castSpell', function(form, slot)
    if form ~= 'lycan' then return end
    local spell = LycanSpells[slot]
    if spell then spell() end
end)

exports('GetLycanSpells', function() return LycanSpells end)
