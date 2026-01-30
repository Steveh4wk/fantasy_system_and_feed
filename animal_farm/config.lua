-- config.lua
-- Stefano Luciano Corp
-- Configurazione per Animal Farm

Config = {
    -- Usa QBCore
    UseQBCore = true,

    -- Debug
    Debug = true,

    -- File dati
    DataFile = 'animals.json',
    Tamed = {
        DataFile = 'tamed.json',
        MaxPerPlayer = 5,
        FeedHealthIncrease = 10,
        FeedCooldown = 3600, -- secondi
        BaseCollectSuccess = 0.5,
        HealthLossOnCollect = 20
    },

    -- Salvataggio
    SaveInterval = 300, -- secondi

    -- Distanza interazione
    InteractDistance = 3.0,

    -- Crescita animali
    GrowthStages = {
        feedsPerStage = 3,
        scales = {0.5, 0.75, 1.0} -- scale per stage 1,2,3
    },

    -- Raccolta
    Harvest = {
        cooldown = 1800 -- secondi
    },

    -- Spawn casuali
    RandomSpawn = {
        enabled = true,
        checkIntervalSec = 300,
        playerActivationRadius = 400.0,
        minDistanceBetweenAnimals = 50.0,
        northOfZancudoY = 2500.0,
        perTypeCaps = {
            deer = 10,
            boar = 5,
            cow = 3
        }
    },

    -- Animali
    Animals = {
        deer = {
            label = 'Cervo',
            feedItem = 'hay',
            productItem = 'meat',
            harvestable = true
        },
        boar = {
            label = 'Cinghiale',
            feedItem = 'corn',
            productItem = 'meat',
            harvestable = true
        },
        cow = {
            label = 'Mucca',
            feedItem = 'hay',
            productItem = 'milk',
            harvestable = true
        }
    },

    -- Modelli animali permessi
    AllowedModels = {
        [GetHashKey('a_c_deer')] = 'deer',
        [GetHashKey('a_c_boar')] = 'boar',
        [GetHashKey('a_c_cow')] = 'cow'
    },

    -- Size modifiers
    SizeDropModifiers = {
        small = 0.8,
        medium = 1.0,
        large = 1.2
    },

    -- Spawns iniziali
    Spawns = {
        { type = 'deer', coords = vector3(100.0, 100.0, 100.0), heading = 0.0, stage = 1, feeds = 0 },
        { type = 'boar', coords = vector3(200.0, 200.0, 200.0), heading = 0.0, stage = 1, feeds = 0 }
    }
}

print('[Animal Farm] Config loaded')