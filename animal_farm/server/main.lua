-- Developed 01/2026 by Stefano Luciano Corp. versione 1.0
local Config = Config or {}
local resourceName = GetCurrentResourceName()

local QBCore = nil
if Config.UseQBCore then
    pcall(function()
        QBCore = exports['qb-core'] and exports['qb-core']:GetCoreObject() or nil
    end)
end

local ox_inventory = exports.ox_inventory

---@type table<number, AnimalState>
local Animals = {}
local nextId = 0
local FeedCooldowns = {}
local OnlineOwners = {}
local PlayerCitizenBySrc = {}

-- Compute drop for tamed animals
local function computeDrop(a)
    local def = Config.Animals[a.type]
    if not def or not def.harvestable then return false, 0 end
    local size = (a.stage == 1 and 'small') or (a.stage == 2 and 'medium') or 'large'
    local base = 0.5 -- base success
    local mod = (Config.SizeDropModifiers and Config.SizeDropModifiers[size]) or 1.0
    local successChance = base * mod
    local success = math.random() < successChance
    local qty = success and 1 or 0
    return success, qty
end

---@class TamedAnimal
---@field id string
---@field type string
---@field coords table
---@field heading number
---@field owner string -- citizenid
---@field name string|nil -- nome assegnato
---@field health number -- 0..100
---@field hunger number -- 0..100
---@field stage integer -- 1..3
---@field feeds integer
---@field alive boolean
---@field lastHarvest number?

---@class AnimalState
---@field id number
---@field type string
---@field stage integer -- 1/2/3
---@field feeds integer -- feed accumulati nel current stage
---@field coords vector3
---@field heading number
---@field lastHarvest number? -- os.time()

local function dbg(msg)
    if Config.Debug then
        print(('[animal_farm] %s'):format(msg))
    end
end

local function ensureDataDir()
    local path = ('%s/%s'):format(GetResourcePath(resourceName), 'data')
    if not path or path == '' then return end
    SaveResourceFile(resourceName, 'data/.keep', '', -1)
end

local function saveAnimals()
    ensureDataDir()
    local data = json.encode(Animals)
    SaveResourceFile(resourceName, Config.DataFile, data or '[]', -1)
end

local function saveTamed()
    ensureDataDir()
    local data = json.encode(Tamed)
    SaveResourceFile(resourceName, Config.Tamed.DataFile, data or '{}', -1)
end

local function loadAnimals()
    local data = LoadResourceFile(resourceName, Config.DataFile)
    if data then
        local ok, decoded = pcall(json.decode, data)
        if ok and type(decoded) == 'table' then
            Animals = decoded
            -- ricava nextId
            for k, v in pairs(Animals) do
                if type(k) == 'number' then
                    nextId = math.max(nextId, k)
                elseif type(v) == 'table' and v.id then
                    nextId = math.max(nextId, v.id)
                end
            end
            return
        end
    end
    Animals = {}
end

local function loadTamed()
    local data = LoadResourceFile(resourceName, Config.Tamed.DataFile)
    if data then
        local ok, decoded = pcall(json.decode, data)
        if ok and type(decoded) == 'table' then
            Tamed = decoded
            return
        end
    end
    Tamed = {}
end

local function newId()
    nextId = nextId + 1
    return nextId
end

local function addAnimal(def)
    local id = newId()
    Animals[id] = {
        id = id,
        type = def.type,
        stage = def.stage or 1,
        feeds = def.feeds or 0,
        coords = { x = def.coords.x, y = def.coords.y, z = def.coords.z },
        heading = def.heading or 0.0,
        lastHarvest = def.lastHarvest
    }
    return Animals[id]
end

local function broadcastFullState(src)
    TriggerClientEvent('animal_farm:client:setAnimals', src or -1, Animals)
end

local function spawnFromConfig()
    if Animals and next(Animals) ~= nil then return end
    for _, sp in ipairs(Config.Spawns or {}) do
        addAnimal({ type = sp.type, coords = sp.coords, heading = sp.heading, stage = 1, feeds = 0 })
    end
end

-- Utilità: trova ground Z valido
local function findGroundZ(x, y, zStart)
    local found, z = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, (zStart or 100.0) + 0.0, false)
    if found then return z end
    return 0.0
end

-- Conta per tipo
local function countByType(t)
    local c = 0
    for _, a in pairs(Animals) do
        if a.type == t then c = c + 1 end
    end
    return c
end

-- Distanza minima da altri animali
local function isFarFromOthers(x, y, minDist)
    for _, a in pairs(Animals) do
        local dx = (a.coords.x - x)
        local dy = (a.coords.y - y)
        if (dx*dx + dy*dy) < (minDist*minDist) then
            return false
        end
    end
    return true
end

-- Verifica presenza player vicino
local function anyPlayerNear(x, y, radius)
    for _, pid in pairs(GetPlayers()) do
        local ped = GetPlayerPed(pid)
        local p = GetEntityCoords(ped)
        if p.y >= (Config.RandomSpawn.northOfZancudoY or 2500.0) then
            local dx = (p.x - x)
            local dy = (p.y - y)
            if (dx*dx + dy*dy) <= (radius*radius) then
                return true
            end
        end
    end
    return false
end

-- Genera un animale vicino a coordinate random in zona nord
local function trySpawnRandomNear(xCenter, yCenter)
    local types = {}
    for t, cap in pairs(Config.RandomSpawn.perTypeCaps or {}) do
        if countByType(t) < cap then
            types[#types+1] = t
        end
    end
    if #types == 0 then return end

    local t = types[math.random(1, #types)]
    local radius = Config.RandomSpawn.playerActivationRadius or 400.0
    local angle = math.random() * math.pi * 2.0
    local dist = math.random(40, math.floor(radius))
    local x = xCenter + math.cos(angle) * dist
    local y = yCenter + math.sin(angle) * dist
    if y < (Config.RandomSpawn.northOfZancudoY or 2500.0) then
        y = (Config.RandomSpawn.northOfZancudoY or 2500.0) + 10.0
    end
    local z = findGroundZ(x, y, 150.0)

    if not isFarFromOthers(x, y, Config.RandomSpawn.minDistanceBetweenAnimals or 50.0) then
        return
    end

    local heading = math.random(0, 359) + 0.0
    local stage = math.random(2, 3)
    addAnimal({ type = t, coords = vector3(x, y, z), heading = heading, stage = stage, feeds = stage > 2 and (Config.GrowthStages.feedsPerStage or 3) * 2 or (Config.GrowthStages.feedsPerStage or 3) })
end

-- Loop di spawn dinamico: se ci sono player a nord, spawn vicino a loro
CreateThread(function()
    while true do
        Wait(((Config.RandomSpawn and Config.RandomSpawn.checkIntervalSec) or 300) * 1000)
        if not (Config.RandomSpawn and Config.RandomSpawn.enabled) then
            -- goto continue removed
        else
            local players = GetPlayers()
            for _, pid in pairs(players) do
                local ped = GetPlayerPed(pid)
                local p = GetEntityCoords(ped)
                -- spawna animali per tick in tutta la mappa
                for i=1, 5 do
                    trySpawnRandomNear(p.x, p.y)
                end
            end

            saveAnimals()
            broadcastFullState()
        end
    end
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= resourceName then return end
    Wait(100)
    loadAnimals()
    loadTamed()
    spawnFromConfig()
    saveAnimals()
    saveTamed()
    broadcastFullState()
    TriggerClientEvent('animal_farm:client:setTamed', -1, Tamed)
    dbg('Resource started, animals loaded: ' .. tostring(#Animals))
end)

-- Decrementa i cooldown solo quando il proprietario è online
CreateThread(function()
    while true do
        Wait(1000)
        for cid, online in pairs(OnlineOwners) do
            if online and (FeedCooldowns[cid] or 0) > 0 then
                FeedCooldowns[cid] = math.max(0, (FeedCooldowns[cid] or 0) - 1)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= resourceName then return end
    saveAnimals()
    saveTamed()
end)

-- salvataggio periodico
CreateThread(function()
    while true do
        Wait((Config.SaveInterval or 300) * 1000)
        saveAnimals()
        saveTamed()
    end
end)

-- Utilità QBCore
local function getCitizenId(src)
    if not QBCore then return nil end
    local Player = QBCore.Functions.GetPlayer(src)
    return Player and Player.PlayerData and Player.PlayerData.citizenid or nil
end

-- Sincronizza al join
RegisterNetEvent('animal_farm:server:requestSync', function()
    local src = source
    broadcastFullState(src)
    TriggerClientEvent('animal_farm:client:setTamed', src, Tamed)
    -- tracking online
    local cid = getCitizenId(src)
    if cid then OnlineOwners[cid] = true; PlayerCitizenBySrc[src] = cid end
end)

-- Validazioni utili
local function playerCoords(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    return vector3(coords.x, coords.y, coords.z)
end

local function distance(a, b)
    return #(vector3(a.x, a.y, a.z) - vector3(b.x, b.y, b.z))
end

local function getAnimal(id)
    local a = Animals[id]
    if not a then return nil end
    return a
end

-- Raccolta prodotto
RegisterNetEvent('animal_farm:server:harvest', function(id)
    local src = source
    local a = getAnimal(id)
    if not a then return end

    local def = Config.Animals[a.type]
    if not def then return end

    if not def.harvestable then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Questo animale non fornisce raccolto.' })
        return
    end

    if a.stage < 3 then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'L\'animale non è ancora adulto.' })
        return
    end

    -- distanza
    local pcoords = playerCoords(src)
    local dist = distance({x=a.coords.x,y=a.coords.y,z=a.coords.z}, {x=pcoords.x,y=pcoords.y,z=pcoords.z})
    if dist > (Config.InteractDistance or 3.0) + 1.0 then
        return
    end

    local now = os.time()
    local last = a.lastHarvest or 0
    if (now - last) < (Config.Harvest.cooldown or 1800) then
        local remaining = (Config.Harvest.cooldown or 1800) - (now - last)
        local mins = math.ceil(remaining / 60)
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = ('Non è pronto. Riprova tra %d min'):format(mins) })
        return
    end

    -- aggiungi item prodotto
    local added = ox_inventory:AddItem(src, def.productItem, 1)
    if not added then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Inventario pieno.' })
        return
    end

    a.lastHarvest = now
    saveAnimals()
    broadcastFullState()
end)

-- Admin: respawn/reset
QBCore = QBCore or exports['qb-core'] and exports['qb-core']:GetCoreObject() or nil
RegisterCommand('af_respawn', function(source)
    if source ~= 0 then
        if QBCore then
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player or not Player.Functions.HasPermission('admin') then
                TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Permesso negato' })
                return
            end
        end
    end
    Animals = {}
    nextId = 0
    spawnFromConfig()
    saveAnimals()
    broadcastFullState()
end, true)

-- Comando per spawnare animale: /animal <type> <stage>
RegisterCommand('animal', function(source, args, raw)
    if source ~= 0 then
        if QBCore then
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then
                TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Giocatore non trovato' })
                return
            end
        end
    end
    local type = args[1]
    local stage = tonumber(args[2])
    if not type or not stage or stage < 1 or stage > 3 then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Uso: /animal <tipo> <stadio 1-3>' })
        return
    end
    if not Config.Animals[type] then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Tipo animale non valido' })
        return
    end
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local feeds = stage > 1 and (Config.GrowthStages.feedsPerStage or 3) * (stage - 1) or 0
    addAnimal({ type = type, coords = coords, heading = heading, stage = stage, feeds = feeds })
    saveAnimals()
    broadcastFullState()
    TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = ('Animale %s stadio %d spawnato'):format(type, stage) })
end, true)

RegisterNetEvent('animal_farm:server:updateCoords', function(id, coords)
    local src = source
    local a = getAnimal(id)
    if not a then return end
    -- opzionale: validazioni
    a.coords = { x = coords.x, y = coords.y, z = coords.z }
end)

RegisterNetEvent('animal_farm:server:updateTamedCoords', function(id, coords)
    local src = source
    local a = Tamed[id]
    if not a then return end
    a.coords = { x = coords.x, y = coords.y, z = coords.z }
    saveTamed()
end)

-- tracking online/offline
AddEventHandler('playerDropped', function()
    local src = source
    local cid = PlayerCitizenBySrc[src]
    if cid then
        OnlineOwners[cid] = false
        PlayerCitizenBySrc[src] = nil
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local cid = getCitizenId(src)
    if cid then
        OnlineOwners[cid] = true
        PlayerCitizenBySrc[src] = cid
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local src = source
    local cid = PlayerCitizenBySrc[src]
    if cid then
        OnlineOwners[cid] = false
        PlayerCitizenBySrc[src] = nil
    end
end)

-- Comando /farminfo: riepilogo animali vivi
RegisterCommand('farminfo', function(source)
    if source <= 0 then return end
    local src = source
    local citizen = getCitizenId(src)
    if not citizen then return end

    local total = 0
    for _, a in pairs(Tamed) do
        if a.alive then total = total + 1 end
    end

    -- raccogli i propri
    local list = {}
    for _, a in pairs(Tamed) do
        if a.alive and a.owner == citizen then
            local def = Config.Animals[a.type]
            local typ = def and def.label or a.type
            local nm = a.name or (typ)
            list[#list+1] = string.format('%s - %s (Salute %d/100, Stadio %d/3)', typ, nm, math.floor(a.health or 0), a.stage or 1)
        end
    end
    table.sort(list)

    TriggerClientEvent('chat:addMessage', src, { args = { '^2Animal Farm', ('Totale animali vivi: %d'):format(total) } })
    if #list == 0 then
        TriggerClientEvent('chat:addMessage', src, { args = { '^2Animal Farm', 'Non possiedi animali vivi.' } })
    else
        for _, line in ipairs(list) do
            TriggerClientEvent('chat:addMessage', src, { args = { '^2Animal', line } })
        end
    end
end)

-- Feed cooldown: restituisce i secondi residui per l'owner dell'animale
RegisterNetEvent('animal_farm:server:getFeedCooldown', function(requestId, animalId)
    local src = source
    local a = Tamed[animalId]
    local remaining = 0
    if a and a.owner then
        remaining = FeedCooldowns[a.owner] or 0
    end
    TriggerClientEvent('animal_farm:client:setFeedCooldown', src, requestId, remaining)
end)

print('[Animal Farm] Server main loaded')