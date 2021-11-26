Config = {
    Locale = 'fr',

    DrawDistance = 10.0,
    MarkerType   = 36,
    MarkerSize   = { x = 1.0, y = 1.0, z = 1.0 },
    MarkerColor  = { r = 255, g = 255, b = 255 },

    Blip = {
        Sprite  = 171,
        Display = 4,
        Scale   = 1.0,
        Color   = 5
    },

    Locations = {
        {
            Spawner = vector3(-1035.2, -2732.8, 20.1),
            SpawnPoints = {
                { coords = vector3(-1033.6, -2730.7, 19.5), heading = 239.24, radius = 3.0 },
                { coords = vector3(-1027.4, -2734.5, 19.5), heading = 238.72, radius = 3.0 },
                { coords = vector3(-1038.7, -2727.7, 19.5), heading = 238.92, radius = 3.0 }
            },
            Models = {
                { model = 'kalahari', label = 'Canis Kalahari', price = 100 },
                { model = 'Faggio2', label = 'Scooter', price = 50 }
            }
        }
    }
}
