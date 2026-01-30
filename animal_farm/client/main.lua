-- client/main.lua
-- Stefano Luciano Corp
-- Logica client per Animal Farm: ricevere animali, interazioni

local Animals = {}
local Tamed = {}

-- Ricevi animali dal server
RegisterNetEvent('animal_farm:client:setAnimals', function(animals)
    Animals = animals
    -- Aggiorna blips o markers se necessario
    print('[Animal Farm] Ricevuti ' .. tostring(#Animals) .. ' animali')
end)

RegisterNetEvent('animal_farm:client:setTamed', function(tamed)
    Tamed = tamed
    print('[Animal Farm] Ricevuti animali addomesticati')
end)

RegisterNetEvent('animal_farm:client:addTamed', function(animal)
    Tamed[animal.id] = animal
    print('[Animal Farm] Aggiunto animale addomesticato: ' .. animal.name)
end)

RegisterNetEvent('animal_farm:client:updateTamed', function(animal)
    Tamed[animal.id] = animal
end)

RegisterNetEvent('animal_farm:client:removeTamed', function(id)
    Tamed[id] = nil
end)

-- Richiedi sync al join
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('animal_farm:server:requestSync')
end)

-- Interazione creature gestita in fantasy_peds/feeding_interaction.lua con tasto E

print('[Animal Farm] Client main loaded')