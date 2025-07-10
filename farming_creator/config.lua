Config = {}

-- Configuration générale
Config.Locale = 'fr'
Config.UsePermissions = true
Config.RequiredPermission = 'admin'

-- Configuration du Framework
Config.Framework = 'esx' -- 'esx', 'esx_legacy', 'qbcore'

-- Configuration spécifique aux frameworks
Config.FrameworkSettings = {
    esx = {
        resource_name = 'es_extended',
        shared_object = 'esx:getSharedObject',
        inventory_system = 'default', -- 'default', 'ox_inventory', 'qs_inventory'
        notification_type = 'esx' -- 'esx', 'mythic', 'ox_lib'
    },
    esx_legacy = {
        resource_name = 'es_extended',
        shared_object = 'esx:getSharedObject',
        inventory_system = 'default',
        notification_type = 'esx'
    },
    qbcore = {
        resource_name = 'qb-core',
        shared_object = 'QBCore:GetObject',
        inventory_system = 'default', -- 'default', 'ox_inventory', 'qs_inventory', 'lj_inventory'
        notification_type = 'qbcore' -- 'qbcore', 'mythic', 'ox_lib'
    }
}

-- Configuration Discord Logs
Config.Discord = {
    enabled = true,
    webhook = "VOTRE_WEBHOOK_URL_ICI", -- Remplacez par votre webhook Discord
    serverName = "Farming Creator System",
    embedColor = 65280, -- Vert
    footerText = "Farming Creator",
    avatarURL = "https://i.imgur.com/YourImageHere.png" -- Optionnel
}

-- Configuration du système d'items personnalisés
Config.CustomItems = {
    enabled = true,
    allowStaffSuggestions = true, -- Permettre aux staff de suggérer des items
    autoInsertIntoDB = true, -- Insertion automatique en BDD
    logToConsole = true, -- Logs dans la console
    logToDiscord = true, -- Logs sur Discord
    maxItemsPerPlayer = 50, -- Limite d'items par joueur
    
    -- Paramètres par défaut pour les nouveaux items
    defaultValues = {
        weight = 1,
        rare = 0,
        can_remove = 1,
        stackable = true,
        usable = false
    }
}

-- Commandes
Config.Commands = {
    farmingMenu = 'farmingcreator',
    deleteFarm = 'delfarm',
    farmZoneMenu = 'farmzone', -- Nouvelle commande pour créer des zones personnalisées
    createItem = 'createitem', -- Nouvelle commande pour créer des items
    itemMenu = 'itemmenu', -- Menu des items personnalisés
    suggestItem = 'suggestitem' -- Pour les staff - suggérer un item
}

-- Distance d'interaction
Config.InteractionDistance = 2.0
Config.MarkerDistance = 20.0

-- Nouvelles options pour les zones de farm personnalisées
Config.FarmZones = {
    enabled = true, -- Activer/désactiver les zones personnalisées
    defaultRadius = 50.0, -- Rayon par défaut
    maxRadius = 200.0, -- Rayon maximum
    minRadius = 10.0, -- Rayon minimum
    allowCustomLabels = true, -- Permettre les labels personnalisés
    showZoneBlips = true, -- Afficher les blips pour les zones
    zoneColors = { -- Couleurs disponibles pour les zones
        {name = "Vert", color = 2},
        {name = "Bleu", color = 3},
        {name = "Jaune", color = 5},
        {name = "Rouge", color = 6},
        {name = "Orange", color = 17},
        {name = "Violet", color = 27},
        {name = "Rose", color = 7}
    }
}

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
    },
    -- Nouveau type générique pour les zones personnalisées
    ['custom'] = {
        name = 'Zone personnalisée',
        description = 'Zone de farm personnalisable',
        growTime = 240000, -- 4 minutes par défaut
        harvestAmount = {min = 1, max = 3},
        harvestItem = 'farmbox', -- Item générique
        seedItem = 'custom_seed',
        seedPrice = 0,
        sellPrice = 0,
        model = 'prop_rub_boxpile_05',
        blip = {
            sprite = 164,
            color = 2,
            scale = 0.8
        },
        marker = {
            type = 1,
            r = 0, g = 255, b = 0, a = 100,
            scale = {x = 1.0, y = 1.0, z = 1.0}
        }
    }
}

-- Messages
Config.Messages = {
    ['no_permission'] = 'Vous n\'avez pas la permission d\'utiliser cette commande.',
    ['farm_created'] = 'Ferme créée avec succès!',
    ['farm_zone_created'] = 'Zone de farm créée avec succès!',
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
    ['farm_info'] = 'Nom: {name} | Type: {type} | Propriétaire: {owner}',
    ['invalid_radius'] = 'Le rayon doit être entre {min} et {max} mètres.',
    ['zone_too_close'] = 'Une zone existe déjà trop proche de cette position.',
    
    -- Messages pour le système d'items personnalisés
    ['item_created'] = 'Item "{name}" créé avec succès et inséré dans la base de données!',
    ['item_suggestion_sent'] = 'Votre suggestion d\'item a été envoyée!',
    ['item_name_required'] = 'Le nom de l\'item est requis.',
    ['item_label_required'] = 'Le label de l\'item est requis.',
    ['item_already_exists'] = 'Un item avec ce nom existe déjà.',
    ['max_items_reached'] = 'Vous avez atteint la limite d\'items personnalisés ({max}).',
    ['item_created_by'] = 'Item créé par {player}',
    ['item_suggested_by'] = 'Item suggéré par {player}',
    ['discord_log_failed'] = 'Erreur lors de l\'envoi du log Discord.',
    ['item_system_disabled'] = 'Le système d\'items personnalisés est désactivé.'
}

-- Interface NUI
Config.NUI = {
    background = 'rgba(0, 0, 0, 0.8)',
    primaryColor = '#4CAF50',
    secondaryColor = '#2196F3',
    errorColor = '#f44336'
}