-- client/animal_spawner.lua
-- Stefano Luciano Corp
-- Spawning animali client-side

local SpawnedAnimals = {}
local SpawnedTamed = {}

-- Funzione per spawnare animale
local function SpawnAnimal(animal)
    if not animal.coords then return end

    local model = GetHashKey('a_c_' .. animal.type) -- es. a_c_deer
    if not IsModelInCdimage(model) then return end

    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return end
        Wait(10)
    end

    local ped = CreatePed(28, model, animal.coords.x, animal.coords.y, animal.coords.z, animal.heading or 0.0, false, false)
    if not ped then return end

    -- Scale non disponibile in FiveM, skip

    -- Freeze se necessario
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    SpawnedAnimals[animal.id] = ped
    SetModelAsNoLongerNeeded(model)
end

-- Spawn tamed
local function SpawnTamed(animal)
    if not animal.coords then return end

    local model = GetHashKey('a_c_' .. animal.type)
    if not IsModelInCdimage(model) then return end

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local ped = CreatePed(28, model, animal.coords.x, animal.coords.y, animal.coords.z, animal.heading or 0.0, false, false)
    if not ped then return end

    -- Scale non disponibile

    -- Tamed possono muoversi
    SetEntityInvincible(ped, false)
    TaskWanderStandard(ped, 10.0, 10)

    SpawnedTamed[animal.id] = ped
    SetModelAsNoLongerNeeded(model)
end

-- Aggiorna spawns
local function UpdateSpawns()
    -- Rimuovi vecchi
    for id, ped in pairs(SpawnedAnimals) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    SpawnedAnimals = {}

    for id, ped in pairs(SpawnedTamed) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    SpawnedTamed = {}

    -- Spawn nuovi
    if Animals then
        for id, animal in pairs(Animals) do
            SpawnAnimal(animal)
        end
    end

    if Tamed then
        for id, animal in pairs(Tamed) do
            if animal.alive then
                SpawnTamed(animal)
            end
        end
    end
end

-- Quando riceve animali
RegisterNetEvent('animal_farm:client:setAnimals', function(animals)
    Animals = animals
    UpdateSpawns()
end)

RegisterNetEvent('animal_farm:client:setTamed', function(tamed)
    Tamed = tamed
    UpdateSpawns()
end)

RegisterNetEvent('animal_farm:client:addTamed', function(animal)
    Tamed[animal.id] = animal
    SpawnTamed(animal)
end)

RegisterNetEvent('animal_farm:client:updateTamed', function(animal)
    Tamed[animal.id] = animal
    -- Update ped if needed
end)

RegisterNetEvent('animal_farm:client:removeTamed', function(id)
    if SpawnedTamed[id] and DoesEntityExist(SpawnedTamed[id]) then
        DeleteEntity(SpawnedTamed[id])
    end
    SpawnedTamed[id] = nil
    Tamed[id] = nil
end)

print('[Animal Farm] Animal spawner loaded')