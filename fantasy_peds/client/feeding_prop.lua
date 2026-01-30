-- feeding_prop.lua
-- Stefano Luciano Corp
-- Prop per il feed dei fantasy ped, simile a animal_farm
-- ========================================

local propModel = 'prop_cs_bowl_01' -- Modello del prop (ciotola)
local propCoords = vector3(0.0, 0.0, 0.0) -- Coordinate dove spawnare il prop (modifica con le tue coordinate)
local propHeading = 0.0 -- Rotazione del prop

local spawnedProp = nil

-- Funzione per spawnare il prop
local function SpawnFeedingProp()
    if not IsModelInCdimage(propModel) then
        print('[Fantasy Feeding Prop] Modello non valido:', propModel)
        return
    end

    RequestModel(propModel)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(propModel) do
        if GetGameTimer() > timeout then
            print('[Fantasy Feeding Prop] Timeout caricamento modello:', propModel)
            return
        end
        Wait(10)
    end

    spawnedProp = CreateObject(propModel, propCoords.x, propCoords.y, propCoords.z, false, false, false)
    SetEntityHeading(spawnedProp, propHeading)
    FreezeEntityPosition(spawnedProp, true)
    SetModelAsNoLongerNeeded(propModel)

    print('[Fantasy Feeding Prop] Prop spawnato')
end

-- Funzione per rimuovere il prop
local function RemoveFeedingProp()
    if spawnedProp and DoesEntityExist(spawnedProp) then
        DeleteEntity(spawnedProp)
        spawnedProp = nil
        print('[Fantasy Feeding Prop] Prop rimosso')
    end
end

-- Interazione con ox_target
if exports.ox_target then
    exports.ox_target:addLocalEntity(spawnedProp, {
        {
            name = 'feed_fantasy_ped',
            label = 'Nutri Creatura Fantasy',
            icon = 'fas fa-utensils',
            distance = 2.0,
            onSelect = function()
                local form = LocalPlayer.state.fantasyForm
                if not form then
                    if lib then
                        lib.notify({
                            title = 'Feed',
                            description = 'Non sei trasformato in una creatura!',
                            type = 'error'
                        })
                    end
                    return
                end

                -- Aggiungi hunger e thirst
                TriggerEvent('fantasy_peds:client:AddHunger', 20) -- +20 hunger
                TriggerEvent('fantasy_peds:client:AddThirst', 20) -- +20 thirst

                if lib then
                    lib.notify({
                        title = 'Feed',
                        description = 'Hai nutrito la tua creatura!',
                        type = 'success'
                    })
                end
            end
        }
    })
end

-- Spawn al caricamento
CreateThread(function()
    Wait(1000) -- Aspetta che il client sia pronto
    SpawnFeedingProp()
end)

-- Comando per respawnare il prop (admin)
RegisterCommand('respawn_feeding_prop', function()
    RemoveFeedingProp()
    SpawnFeedingProp()
end, true)

-- Cleanup al logout
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RemoveFeedingProp()
    end
end)