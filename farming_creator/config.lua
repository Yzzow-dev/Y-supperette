Config = {}

-- Configuration générale
Config.Locale = 'fr'
Config.UsePermissions = true
Config.RequiredPermission = 'admin'

-- Commandes
Config.Commands = {
    farmingMenu = 'farmingcreator',
    deleteFarm = 'delfarm'
}

-- Distance d'interaction
Config.InteractionDistance = 2.0
Config.MarkerDistance = 20.0

-- Types de cultures disponibles
Config.CropTypes = {
    ['orange'] = {
        name = 'Orangers',
        description = 'Plantation d\'orangers',
        growTime = 300000, -- 5 minutes en millisecondes
        harvestAmount = {min = 3, max = 8},
        harvestItem = 'orange',
        seedItem = 'orange_seed',
        seedPrice = 50,
        sellPrice = 15,
        model = 'prop_tree_orange_01',
        blip = {
            sprite = 238,
            color = 25,
            scale = 0.8
        },
        marker = {
            type = 1,
            r = 255, g = 165, b = 0, a = 100,
            scale = {x = 2.0, y = 2.0, z = 1.0}
        }
    },
    ['apple'] = {
        name = 'Pommiers',
        description = 'Plantation de pommiers',
        growTime = 240000, -- 4 minutes
        harvestAmount = {min = 4, max = 10},
        harvestItem = 'apple',
        seedItem = 'apple_seed',
        seedPrice = 45,
        sellPrice = 12,
        model = 'prop_tree_apple_01',
        blip = {
            sprite = 238,
            color = 2,
            scale = 0.8
        },
        marker = {
            type = 1,
            r = 255, g = 0, b = 0, a = 100,
            scale = {x = 2.0, y = 2.0, z = 1.0}
        }
    },
    ['wheat'] = {
        name = 'Blé',
        description = 'Champ de blé',
        growTime = 180000, -- 3 minutes
        harvestAmount = {min = 5, max = 12},
        harvestItem = 'wheat',
        seedItem = 'wheat_seed',
        seedPrice = 25,
        sellPrice = 8,
        model = 'prop_veg_crop_03_cab',
        blip = {
            sprite = 238,
            color = 5,
            scale = 0.8
        },
        marker = {
            type = 1,
            r = 255, g = 255, b = 0, a = 100,
            scale = {x = 1.5, y = 1.5, z = 1.0}
        }
    },
    ['carrot'] = {
        name = 'Carottes',
        description = 'Plantation de carottes',
        growTime = 120000, -- 2 minutes
        harvestAmount = {min = 6, max = 15},
        harvestItem = 'carrot',
        seedItem = 'carrot_seed',
        seedPrice = 20,
        sellPrice = 5,
        model = 'prop_veg_crop_03_pump',
        blip = {
            sprite = 238,
            color = 17,
            scale = 0.8
        },
        marker = {
            type = 1,
            r = 255, g = 69, b = 0, a = 100,
            scale = {x = 1.0, y = 1.0, z = 1.0}
        }
    },
    ['corn'] = {
        name = 'Maïs',
        description = 'Champ de maïs',
        growTime = 360000, -- 6 minutes
        harvestAmount = {min = 2, max = 6},
        harvestItem = 'corn',
        seedItem = 'corn_seed',
        seedPrice = 75,
        sellPrice = 20,
        model = 'prop_veg_crop_04_leaf',
        blip = {
            sprite = 238,
            color = 46,
            scale = 0.8
        },
        marker = {
            type = 1,
            r = 255, g = 255, b = 0, a = 100,
            scale = {x = 1.8, y = 1.8, z = 1.2}
        }
    },
    ['grape'] = {
        name = 'Raisins',
        description = 'Vignoble',
        growTime = 420000, -- 7 minutes
        harvestAmount = {min = 3, max = 9},
        harvestItem = 'grape',
        seedItem = 'grape_seed',
        seedPrice = 100,
        sellPrice = 30,
        model = 'prop_veg_crop_02',
        blip = {
            sprite = 238,
            color = 27,
            scale = 0.8
        },
        marker = {
            type = 1,
            r = 128, g = 0, b = 128, a = 100,
            scale = {x = 1.5, y = 1.5, z = 1.0}
        }
    }
}

-- Messages
Config.Messages = {
    ['no_permission'] = 'Vous n\'avez pas la permission d\'utiliser cette commande.',
    ['farm_created'] = 'Ferme créée avec succès!',
    ['farm_deleted'] = 'Ferme supprimée avec succès!',
    ['farm_not_found'] = 'Aucune ferme trouvée à cette position.',
    ['invalid_crop_type'] = 'Type de culture invalide.',
    ['already_planted'] = 'Cette zone est déjà plantée.',
    ['not_planted'] = 'Cette zone n\'est pas plantée.',
    ['not_ready'] = 'La culture n\'est pas encore prête à être récoltée.',
    ['harvest_success'] = 'Vous avez récolté {amount}x {item}.',
    ['plant_success'] = 'Vous avez planté {crop}.',
    ['no_seeds'] = 'Vous n\'avez pas assez de graines.',
    ['no_space'] = 'Inventaire plein.',
    ['farm_info'] = 'Nom: {name} | Type: {type} | Propriétaire: {owner}'
}

-- Interface NUI
Config.NUI = {
    background = 'rgba(0, 0, 0, 0.8)',
    primaryColor = '#4CAF50',
    secondaryColor = '#2196F3',
    errorColor = '#f44336'
}