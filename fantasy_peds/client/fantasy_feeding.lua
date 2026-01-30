-- ==========================================================
-- FANTASY FEEDING SYSTEM: VAMPIRO & LYCAN
-- Autore: Stefano Luciano Corp
-- Gestione feeding animali, acqua e tracking

local AnimalFeedStats = {}
local hunger = 100
local thirst = 100

-- Evento feeding animali
RegisterNetEvent('fantasy_peds:client:FeedAnimal', function(model)
    local playerId = GetPlayerServerId(PlayerId())
    if not AnimalFeedStats[playerId] then
        AnimalFeedStats[playerId] = { total = 0, animals = {} }
    end
    AnimalFeedStats[playerId].total = AnimalFeedStats[playerId].total + 1
    AnimalFeedStats[playerId].animals[model] = (AnimalFeedStats[playerId].animals[model] or 0) + 1
    print("[FANTASY_PEDS] Animale nutrito:", model, "Totale:", AnimalFeedStats[playerId].total)
end)

-- ✅ Eventi per esportazioni centralizzate
RegisterNetEvent('fantasy_peds:client:AddHunger', function(amount)
    AddHunger(amount)
end)

RegisterNetEvent('fantasy_peds:client:AddThirst', function(amount)
    AddThirst(amount)
end)

-- Funzioni per gestione hunger/thirst
function AddHunger(amount)
    hunger = math.min(100, hunger + (amount or 10))
    local ped = PlayerPedId()
    Entity(ped).state.hunger = hunger
    print("[FANTASY_PEDS] Hunger increased:", hunger)
end

function AddThirst(amount)
    thirst = math.min(100, thirst + (amount or 10))
    local ped = PlayerPedId()
    Entity(ped).state.thirst = thirst
    print("[FANTASY_PEDS] Thirst increased:", thirst)
end

function GetHunger()
    return hunger
end

function GetThirst()
    return thirst
end

-- Funzione per uccidere animali correttamente
function KillAnimalProperly(animalPed)
    if DoesEntityExist(animalPed) and not IsPedAPlayer(animalPed) then
        SetEntityHealth(animalPed, 0)
        Wait(500)
        
        -- Applica ragdoll per morte realistica
        SetPedToRagdoll(animalPed, 1000, 1000, 0, 0, 0, 0)
        
        print("[FANTASY_PEDS] Animal killed properly")
        return true
    end
    return false
end

-- Thread per decay hunger/thirst
CreateThread(function()
    while true do
        Wait(30000) -- Ogni 30 secondi
        
        local form = LocalPlayer.state.fantasyForm
        if form then
            -- Decay solo quando trasformato
            hunger = math.max(0, hunger - 2)
            thirst = math.max(0, thirst - 1)
            
            local ped = PlayerPedId()
            Entity(ped).state.hunger = hunger
            Entity(ped).state.thirst = thirst
            
            -- Notifiche basse
            if hunger <= 20 and lib then
                lib.notify({title='Fame', description='Hai fame!', type='warning'})
            end
            
            if thirst <= 20 and lib then
                lib.notify({title='Sete', description='Hai sete!', type='warning'})
            end
        end
    end
end)

-- Reset stats al respawn
AddEventHandler('playerSpawned', function()
    hunger = 100
    thirst = 100
    local ped = PlayerPedId()
    Entity(ped).state.hunger = hunger
    Entity(ped).state.thirst = thirst
end)

-- ESPORTAZIONI
exports('GetAnimalFeedStats', function()
    local playerId = GetPlayerServerId(PlayerId())
    return AnimalFeedStats[playerId] or { total=0, animals={} }
end)

exports('AddHunger', AddHunger)
exports('AddThirst', AddThirst)
exports('GetHunger', GetHunger)
exports('GetThirst', GetThirst)
exports('KillAnimalProperly', KillAnimalProperly)

-- ✅ Esportazione per ox_inventory - uso item sangue
exports('UseBloodItem', function(itemData, slot)
    local form = LocalPlayer.state.fantasyForm
    
    -- Solo vampiri possono usare
    if form ~= 'vampire' then
        if lib then
            lib.notify({
                title = 'Errore',
                description = 'Solo i vampiri possono usare il sangue!',
                type = 'error'
            })
        end
        return false
    end
    
    -- Applica effetti vampiro
    AddHunger(30)
    AddThirst(20)
    
    -- Effetti speciali aggiuntivi
    local ped = PlayerPedId()
    SetEntityHealth(ped, math.min(200, GetEntityHealth(ped) + 15))
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.2)
    
    -- Animazione speciale
    TaskPlayAnim(ped, 'mp_player_intdrink', 'loop_bottle', 8.0, -8.0, 2500, 49, 0, false, false, false)
    
    -- Notifica
    if lib then
        lib.notify({
            title = 'Sangue',
            description = 'Il sangue ti ha dato forza!',
            type = 'success'
        })
    end
    
    print('[FANTASY_PEDS] Blood item used by vampire')
    return true
end)

print('[FANTASY_PEDS] Feeding system caricato!')
