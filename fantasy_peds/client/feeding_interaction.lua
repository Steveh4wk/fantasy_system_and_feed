-- feeding_interaction.lua
-- Gestione interazione vicinanza / tasto per feeding creature (solo animali)

local feedingDistance = 3.0
local lastFeedTime = 0
local feedCooldown = 2000 -- 2 secondi

-- Funzione per trovare animali vicini
local function FindNearbyAnimal()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestAnimal = nil
    local closestDistance = feedingDistance
    
    -- Controlla tutti i ped nel gioco
    for _, ped in pairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and IsPedHuman(ped) == false then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestAnimal = ped
            end
        end
    end
    
    return closestAnimal, closestDistance
end

-- Funzione per controllare se il giocatore è una creatura
local function IsCreature()
    local form = LocalPlayer.state.fantasyForm
    return form == 'vampire' or form == 'lycan'
end

-- Funzione per eseguire il feeding su animali
local function ExecuteFeed(animal)
    if not animal or not DoesEntityExist(animal) then return end
    
    local form = LocalPlayer.state.fantasyForm
    if not form then return end
    
    -- Check cooldown
    if GetGameTimer() - lastFeedTime < feedCooldown then
        if lib then
            lib.notify({title='Attesa', description='Aspetta prima di nutrirti di nuovo!', type='warning'})
        end
        return
    end
    
    lastFeedTime = GetGameTimer()
    
    if form == 'vampire' then
        -- ✅ ANIMAZIONE MORSO VAMPIRO
        local ped = PlayerPedId()
        local dict = 'melee@unarmed@streamed_core'
        local anim = 'heavy_punch_a'

        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10) end

        -- Inizia animazione morso
        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 1500, 48, 0, false, false, false)

        -- Aspetta fine animazione player
        Wait(1500)

        -- Ora uccidi l'animale con animazione morte
        SetEntityHealth(animal, 0)
        SetPedToRagdoll(animal, 1000, 1000, 0, 0, 0, 0)

        -- Applica effetti
        SetEntityHealth(ped, GetEntityHealth(ped) + 10)
        AddHunger(50)
        AddThirst(50)

        RemoveAnimDict(dict)
        ClearPedTasksImmediately(ped)

        if lib then
            lib.notify({title='Vampiro', description='Hai morso e ucciso l\'animale per nutrirti!', type='success'})
        end

    elseif form == 'lycan' then
        -- ✅ ANIMAZIONE TUFFO LYCAN
        local ped = PlayerPedId()
        local dict = 'creatures@dog@amb@world_dog_biting@idle_a'
        local anim = 'idle_b'

        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10) end

        -- Inizia animazione tuffo/pounce
        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 1500, 48, 0, false, false, false)

        -- Aspetta fine animazione player
        Wait(1500)

        -- Ora uccidi l'animale con animazione morte
        SetEntityHealth(animal, 0)
        SetPedToRagdoll(animal, 1000, 1000, 0, 0, 0, 0)

        -- Applica effetti
        SetEntityHealth(ped, GetEntityHealth(ped) + 15)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.3)
        AddHunger(50)
        AddThirst(50)

        RemoveAnimDict(dict)
        ClearPedTasksImmediately(ped)

        if lib then
            lib.notify({title='Lycan', description='Hai fatto un tuffo e sbranato l\'animale!', type='success'})
        end
    end
    
    Wait(1500) -- Aspetta che l'animazione completi
    ClearPedTasksImmediately(PlayerPedId())
end

-- Thread principale per controllare vicinanza e input (solo animali)
CreateThread(function()
    while true do
        Wait(500)
        
        if IsCreature() then
            local nearbyAnimal, distance = FindNearbyAnimal()
            
            if nearbyAnimal and distance <= feedingDistance then
                -- Mostra testo UI per nutrirsi
                local form = LocalPlayer.state.fantasyForm
                local text = (form == 'vampire' and '[E] Bevi Sangue') or (form == 'lycan' and '[E] Mangia Animale') or '[E] Interagisci'
                if lib then
                    lib.showTextUI(text)
                end

                -- Controlla input tasto E
                if IsControlJustReleased(0, 38) then -- Tasto E
                    ExecuteFeed(nearbyAnimal)
                    if lib then
                        lib.hideTextUI()
                    end
                end
            else
                -- Nascondi testo se non ci sono animali vicini
                if lib then
                    lib.hideTextUI()
                end
            end
        else
            -- Nascondi testo se non sei una creatura
            if lib then
                lib.hideTextUI()
            end
        end
    end
end)

-- Reset al disconnect
AddEventHandler('playerSpawned', function()
    lastFeedTime = 0
    if lib then
        lib.hideTextUI()
    end
end)

print('[FANTASY_PEDS] Feeding interaction caricato! (solo animali)')
