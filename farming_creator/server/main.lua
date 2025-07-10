local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local farms = {}

-- Initialisation de la base de données
MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS farming_creator (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            crop_type VARCHAR(20) NOT NULL,
            coords_x FLOAT NOT NULL,
            coords_y FLOAT NOT NULL,
            coords_z FLOAT NOT NULL,
            size INT NOT NULL DEFAULT 5,
            spacing FLOAT NOT NULL DEFAULT 2.0,
            owner INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {}, function(result)
        print('[Farming Creator] Table farming_creator créée/vérifiée')
    end)
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS farming_plants (
            id INT AUTO_INCREMENT PRIMARY KEY,
            farm_id INT NOT NULL,
            coords_x FLOAT NOT NULL,
            coords_y FLOAT NOT NULL,
            coords_z FLOAT NOT NULL,
            planted BOOLEAN DEFAULT FALSE,
            harvest_time BIGINT DEFAULT NULL,
            FOREIGN KEY (farm_id) REFERENCES farming_creator(id) ON DELETE CASCADE
        )
    ]], {}, function(result)
        print('[Farming Creator] Table farming_plants créée/vérifiée')
    end)
    
    -- Nouvelle table pour les zones personnalisées
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS farming_zones (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            label VARCHAR(100),
            description TEXT,
            coords_x FLOAT NOT NULL,
            coords_y FLOAT NOT NULL,
            coords_z FLOAT NOT NULL,
            radius FLOAT NOT NULL,
            density VARCHAR(20) DEFAULT 'medium',
            color INT DEFAULT 2,
            blip_sprite INT DEFAULT 164,
            show_markers BOOLEAN DEFAULT TRUE,
            harvest_item VARCHAR(50) DEFAULT 'farmbox',
            harvest_min INT DEFAULT 1,
            harvest_max INT DEFAULT 3,
            grow_time INT DEFAULT 240000,
            require_seeds BOOLEAN DEFAULT FALSE,
            access_type VARCHAR(20) DEFAULT 'public',
            allowed_job VARCHAR(50),
            allowed_gang VARCHAR(50),
            owner VARCHAR(50) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {}, function(result)
        print('[Farming Creator] Table farming_zones créée/vérifiée')
        
        -- Nouvelle table pour les points de récolte des zones
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS farming_zone_points (
                id INT AUTO_INCREMENT PRIMARY KEY,
                zone_id INT NOT NULL,
                coords_x FLOAT NOT NULL,
                coords_y FLOAT NOT NULL,
                coords_z FLOAT NOT NULL,
                planted BOOLEAN DEFAULT FALSE,
                harvest_time BIGINT DEFAULT NULL,
                FOREIGN KEY (zone_id) REFERENCES farming_zones(id) ON DELETE CASCADE
            )
        ]], {}, function(result)
            print('[Farming Creator] Table farming_zone_points créée/vérifiée')
            LoadAllFarms()
        end)
    end)
end)

-- Chargement de toutes les fermes
function LoadAllFarms()
    MySQL.Async.fetchAll('SELECT * FROM farming_creator', {}, function(farmResults)
        farms = {}
        
        for _, farm in ipairs(farmResults) do
            local farmData = {
                id = farm.id,
                name = farm.name,
                cropType = farm.crop_type,
                coords = {
                    x = farm.coords_x,
                    y = farm.coords_y,
                    z = farm.coords_z
                },
                size = farm.size,
                spacing = farm.spacing,
                owner = farm.owner,
                plants = {}
            }
            
            -- Charger les plantes de cette ferme
            MySQL.Async.fetchAll('SELECT * FROM farming_plants WHERE farm_id = ?', {farm.id}, function(plantResults)
                for _, plant in ipairs(plantResults) do
                    table.insert(farmData.plants, {
                        id = plant.id,
                        coords = {
                            x = plant.coords_x,
                            y = plant.coords_y,
                            z = plant.coords_z
                        },
                        planted = plant.planted == 1,
                        harvestTime = plant.harvest_time
                    })
                end
            end)
            
            table.insert(farms, farmData)
        end
        
        print('[Farming Creator] ' .. #farms .. ' fermes chargées')
    end)
end

-- Events
RegisterServerEvent('farming:loadFarms')
AddEventHandler('farming:loadFarms', function()
    local source = source
    TriggerClientEvent('farming:receiveFarms', source, farms)
end)

RegisterServerEvent('farming:createFarm')
AddEventHandler('farming:createFarm', function(farmData)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Vérifier les permissions si activées
    if Config.UsePermissions then
        if not xPlayer.getGroup() or xPlayer.getGroup() ~= Config.RequiredPermission then
            TriggerClientEvent('esx:showNotification', source, Config.Messages['no_permission'])
            return
        end
    end
    
    -- Insérer la ferme dans la base de données
    MySQL.Async.insert('INSERT INTO farming_creator (name, crop_type, coords_x, coords_y, coords_z, size, spacing, owner) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        farmData.name,
        farmData.cropType,
        farmData.coords.x,
        farmData.coords.y,
        farmData.coords.z,
        farmData.size,
        farmData.spacing,
        xPlayer.identifier
    }, function(farmId)
        if farmId then
            -- Créer les points de plantation
            local plants = GeneratePlantPositions(farmData.coords, farmData.size, farmData.spacing)
            
            for _, plantCoords in ipairs(plants) do
                MySQL.Async.insert('INSERT INTO farming_plants (farm_id, coords_x, coords_y, coords_z) VALUES (?, ?, ?, ?)', {
                    farmId,
                    plantCoords.x,
                    plantCoords.y,
                    plantCoords.z
                }, function(plantId)
                    -- Optionnel: gérer l'ID de la plante
                end)
            end
            
            -- Créer l'objet ferme
            local newFarm = {
                id = farmId,
                name = farmData.name,
                cropType = farmData.cropType,
                coords = farmData.coords,
                size = farmData.size,
                spacing = farmData.spacing,
                owner = xPlayer.identifier,
                plants = {}
            }
            
            -- Ajouter les plantes
            for i, plantCoords in ipairs(plants) do
                table.insert(newFarm.plants, {
                    id = farmId * 1000 + i, -- ID temporaire
                    coords = plantCoords,
                    planted = false,
                    harvestTime = nil
                })
            end
            
            table.insert(farms, newFarm)
            TriggerClientEvent('farming:farmCreated', -1, newFarm)
        end
    end)
end)

-- Nouvel event pour créer des items personnalisés
RegisterServerEvent('farming:createCustomItem')
AddEventHandler('farming:createCustomItem', function(itemData)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Vérifier les permissions
    if Config.UsePermissions then
        if not xPlayer.getGroup() or xPlayer.getGroup() ~= Config.RequiredPermission then
            TriggerClientEvent('esx:showNotification', source, Config.Messages['no_permission'])
            return
        end
    end
    
    -- Vérifier que la création d'items est activée
    if not Config.ItemCreation.enabled or not Config.ItemCreation.allowStaffCreate then
        TriggerClientEvent('esx:showNotification', source, 'La création d\'items est désactivée')
        return
    end
    
    -- Vérifier que l'item n'existe pas déjà
    MySQL.Async.fetchAll('SELECT name FROM items WHERE name = ?', {itemData.name}, function(result)
        if #result > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Un item avec ce nom existe déjà!')
            return
        end
        
        -- Insérer l'item dans la base de données
        if Config.ItemCreation.autoInsertDatabase then
            MySQL.Async.insert([[
                INSERT INTO items 
                (name, label, weight, rare, can_remove, usable, shouldClose, combinable, description) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                itemData.name,
                itemData.label,
                itemData.weight,
                itemData.rare,
                itemData.can_remove,
                itemData.usable,
                itemData.shouldClose,
                nil, -- combinable
                itemData.description
            }, function(insertId)
                if insertId then
                    -- Log console
                    print('^2[FARMING CREATOR]^7 Item créé et inséré dans la base de données:')
                    print('  ├─ Nom: ' .. itemData.name)
                    print('  ├─ Label: ' .. itemData.label)
                    print('  ├─ Catégorie: ' .. itemData.category)
                    print('  ├─ Créé par: ' .. xPlayer.getName() .. ' (' .. xPlayer.identifier .. ')')
                    print('  └─ ID BDD: ' .. insertId)
                    
                    -- Envoyer vers Discord si activé
                    if Config.ItemCreation.discordLogs.enabled then
                        SendItemToDiscord(itemData, xPlayer)
                    end
                    
                    -- Si c'est un item de farming, l'ajouter au config dynamiquement
                    if itemData.usageType and itemData.usageType ~= 'none' and itemData.farmingData then
                        AddItemToFarmingConfig(itemData)
                    end
                    
                    TriggerClientEvent('esx:showNotification', source, 'Item ^2' .. itemData.label .. '^7 créé avec succès!')
                else
                    TriggerClientEvent('esx:showNotification', source, 'Erreur lors de l\'insertion en base de données')
                end
            end)
        else
            -- Juste loguer sans insérer
            print('^3[FARMING CREATOR]^7 Item créé (insertion BDD désactivée):')
            print('  ├─ Nom: ' .. itemData.name)
            print('  ├─ Label: ' .. itemData.label)
            print('  └─ Créé par: ' .. xPlayer.getName())
            
            TriggerClientEvent('esx:showNotification', source, 'Item créé (vérifiez les logs)')
        end
    end)
end)

-- Nouvel event pour créer des zones personnalisées
RegisterServerEvent('farming:createCustomZone')
AddEventHandler('farming:createCustomZone', function(zoneData)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Vérifier les permissions
    if Config.UsePermissions then
        if not xPlayer.getGroup() or xPlayer.getGroup() ~= Config.RequiredPermission then
            TriggerClientEvent('esx:showNotification', source, Config.Messages['no_permission'])
            return
        end
    end
    
    -- Vérifier que les zones personnalisées sont activées
    if not Config.FarmZones.enabled then
        TriggerClientEvent('esx:showNotification', source, 'Les zones personnalisées sont désactivées')
        return
    end
    
    -- Vérifier la proximité avec d'autres zones (éviter les chevauchements)
    local tooClose = false
    for _, farm in ipairs(farms) do
        local distance = #(vector3(zoneData.coords.x, zoneData.coords.y, zoneData.coords.z) - 
                         vector3(farm.coords.x, farm.coords.y, farm.coords.z))
        if distance < (zoneData.radius + 50) then -- Buffer de 50m
            tooClose = true
            break
        end
    end
    
    if tooClose then
        TriggerClientEvent('esx:showNotification', source, Config.Messages['zone_too_close'])
        return
    end
    
    -- Insérer la zone dans la base de données
    MySQL.Async.insert([[
        INSERT INTO farming_zones 
        (name, label, description, coords_x, coords_y, coords_z, radius, density, color, 
         blip_sprite, show_markers, harvest_item, harvest_min, harvest_max, grow_time, 
         require_seeds, access_type, allowed_job, allowed_gang, owner) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        zoneData.name,
        zoneData.label,
        zoneData.description,
        zoneData.coords.x,
        zoneData.coords.y,
        zoneData.coords.z,
        zoneData.radius,
        zoneData.density,
        zoneData.color,
        zoneData.blipSprite,
        zoneData.showMarkers,
        zoneData.harvestItem,
        zoneData.harvestAmount.min,
        zoneData.harvestAmount.max,
        zoneData.growTime,
        zoneData.requireSeeds,
        zoneData.accessType,
        zoneData.allowedJob,
        zoneData.allowedGang,
        xPlayer.identifier
    }, function(zoneId)
        if zoneId then
            -- Générer les points de récolte dans la zone
            local points = GenerateZonePoints(zoneData.coords, zoneData.radius, zoneData.density)
            
            for _, pointCoords in ipairs(points) do
                MySQL.Async.insert('INSERT INTO farming_zone_points (zone_id, coords_x, coords_y, coords_z) VALUES (?, ?, ?, ?)', {
                    zoneId,
                    pointCoords.x,
                    pointCoords.y,
                    pointCoords.z
                })
            end
            
            -- Créer l'objet zone
            local newZone = {
                id = zoneId,
                name = zoneData.name,
                label = zoneData.label,
                description = zoneData.description,
                coords = zoneData.coords,
                radius = zoneData.radius,
                density = zoneData.density,
                color = zoneData.color,
                blipSprite = zoneData.blipSprite,
                showMarkers = zoneData.showMarkers,
                harvestItem = zoneData.harvestItem,
                harvestAmount = zoneData.harvestAmount,
                growTime = zoneData.growTime,
                requireSeeds = zoneData.requireSeeds,
                accessType = zoneData.accessType,
                allowedJob = zoneData.allowedJob,
                allowedGang = zoneData.allowedGang,
                owner = xPlayer.identifier,
                isZone = true, -- Marquer comme zone personnalisée
                plants = {}
            }
            
            -- Ajouter les points
            for i, pointCoords in ipairs(points) do
                table.insert(newZone.plants, {
                    id = zoneId * 10000 + i, -- ID temporaire différent des fermes
                    coords = pointCoords,
                    planted = false,
                    harvestTime = nil
                })
            end
            
            table.insert(farms, newZone)
            TriggerClientEvent('farming:farmCreated', -1, newZone)
            TriggerClientEvent('esx:showNotification', source, Config.Messages['farm_zone_created'])
        end
    end)
end)

-- Nouvel event pour créer des items personnalisés
RegisterServerEvent('farming:createCustomItem')
AddEventHandler('farming:createCustomItem', function(itemData)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Vérifier les permissions
    if Config.UsePermissions then
        if not xPlayer.getGroup() or xPlayer.getGroup() ~= Config.RequiredPermission then
            TriggerClientEvent('esx:showNotification', source, Config.Messages['no_permission'])
            return
        end
    end
    
    -- Vérifier que la création d'items est activée
    if not Config.ItemCreation.enabled or not Config.ItemCreation.allowStaffCreate then
        TriggerClientEvent('esx:showNotification', source, 'La création d\'items est désactivée')
        return
    end
    
    -- Vérifier que l'item n'existe pas déjà
    MySQL.Async.fetchAll('SELECT name FROM items WHERE name = ?', {itemData.name}, function(result)
        if #result > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Un item avec ce nom existe déjà!')
            return
        end
        
        -- Insérer l'item dans la base de données
        if Config.ItemCreation.autoInsertDatabase then
            MySQL.Async.insert([[
                INSERT INTO items 
                (name, label, weight, rare, can_remove, usable, shouldClose, combinable, description) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                itemData.name,
                itemData.label,
                itemData.weight,
                itemData.rare,
                itemData.can_remove,
                itemData.usable,
                itemData.shouldClose,
                nil, -- combinable
                itemData.description
            }, function(insertId)
                if insertId then
                    -- Log console
                    print('^2[FARMING CREATOR]^7 Item créé et inséré dans la base de données:')
                    print('  ├─ Nom: ' .. itemData.name)
                    print('  ├─ Label: ' .. itemData.label)
                    print('  ├─ Catégorie: ' .. itemData.category)
                    print('  ├─ Poids: ' .. itemData.weight .. 'kg')
                    print('  ├─ Rareté: ' .. (itemData.rare == 1 and 'Rare' or 'Commun'))
                    print('  ├─ Créé par: ' .. xPlayer.getName() .. ' (' .. xPlayer.identifier .. ')')
                    print('  └─ ID BDD: ' .. insertId)
                    
                    -- Envoyer vers Discord si activé
                    if Config.ItemCreation.discordLogs.enabled then
                        SendItemToDiscord(itemData, xPlayer, insertId)
                    end
                    
                    -- Si c'est un item de farming, l'ajouter au config dynamiquement
                    if itemData.usageType and itemData.usageType ~= 'none' and itemData.farmingData then
                        AddItemToFarmingConfig(itemData)
                    end
                    
                    TriggerClientEvent('esx:showNotification', source, 'Item ^2' .. itemData.label .. '^7 créé avec succès!')
                    print('^2[FARMING CREATOR]^7 ✅ Item inséré avec succès dans la table items')
                else
                    print('^1[FARMING CREATOR]^7 ❌ Erreur lors de l\'insertion en base de données')
                    TriggerClientEvent('esx:showNotification', source, 'Erreur lors de l\'insertion en base de données')
                end
            end)
        else
            -- Juste loguer sans insérer
            print('^3[FARMING CREATOR]^7 Item créé (insertion BDD désactivée):')
            print('  ├─ Nom: ' .. itemData.name)
            print('  ├─ Label: ' .. itemData.label)
            print('  └─ Créé par: ' .. xPlayer.getName())
            
            TriggerClientEvent('esx:showNotification', source, 'Item créé (vérifiez les logs)')
        end
    end)
end)

RegisterServerEvent('farming:deleteFarm')
AddEventHandler('farming:deleteFarm', function(farmId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Vérifier les permissions
    if Config.UsePermissions then
        if not xPlayer.getGroup() or xPlayer.getGroup() ~= Config.RequiredPermission then
            TriggerClientEvent('esx:showNotification', source, Config.Messages['no_permission'])
            return
        end
    end
    
    -- Supprimer de la base de données
    MySQL.Async.execute('DELETE FROM farming_creator WHERE id = ?', {farmId}, function(affectedRows)
        if affectedRows > 0 then
            -- Supprimer de la liste locale
            for i, farm in ipairs(farms) do
                if farm.id == farmId then
                    table.remove(farms, i)
                    break
                end
            end
            
            TriggerClientEvent('farming:farmDeleted', -1, farmId)
        end
    end)
end)

RegisterServerEvent('farming:plantCrop')
AddEventHandler('farming:plantCrop', function(farmId, plantIndex)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local farm = GetFarmById(farmId)
    if not farm or not farm.plants[plantIndex] then return end
    
    local plant = farm.plants[plantIndex]
    if plant.planted then
        TriggerClientEvent('esx:showNotification', source, Config.Messages['already_planted'])
        return
    end
    
    local cropConfig = Config.CropTypes[farm.cropType]
    if not cropConfig then return end
    
    -- Vérifier si le joueur a les graines
    local item = xPlayer.getInventoryItem(cropConfig.seedItem)
    if not item or item.count < 1 then
        TriggerClientEvent('esx:showNotification', source, Config.Messages['no_seeds'])
        return
    end
    
    -- Retirer les graines
    xPlayer.removeInventoryItem(cropConfig.seedItem, 1)
    
    -- Planter la culture
    local harvestTime = os.time() * 1000 + cropConfig.growTime
    plant.planted = true
    plant.harvestTime = harvestTime
    
    -- Mettre à jour la base de données
    MySQL.Async.execute('UPDATE farming_plants SET planted = ?, harvest_time = ? WHERE id = ?', {
        true, harvestTime, plant.id
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('farming:cropPlanted', -1, farmId, {
                id = plant.id,
                harvestTime = harvestTime
            })
            TriggerClientEvent('esx:showNotification', source, Config.Messages['plant_success']:gsub('{crop}', cropConfig.name))
        end
    end)
end)

RegisterServerEvent('farming:harvestCrop')
AddEventHandler('farming:harvestCrop', function(farmId, plantIndex)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local farm = GetFarmById(farmId)
    if not farm or not farm.plants[plantIndex] then return end
    
    local plant = farm.plants[plantIndex]
    if not plant.planted then
        TriggerClientEvent('esx:showNotification', source, Config.Messages['not_planted'])
        return
    end
    
    if plant.harvestTime and os.time() * 1000 < plant.harvestTime then
        TriggerClientEvent('esx:showNotification', source, Config.Messages['not_ready'])
        return
    end
    
    local cropConfig = Config.CropTypes[farm.cropType]
    if not cropConfig then return end
    
    -- Calculer la quantité récoltée
    local harvestAmount = math.random(cropConfig.harvestAmount.min, cropConfig.harvestAmount.max)
    
    -- Vérifier l'espace dans l'inventaire
    local item = xPlayer.getInventoryItem(cropConfig.harvestItem)
    if xPlayer.canCarryItem(cropConfig.harvestItem, harvestAmount) then
        -- Ajouter les objets récoltés
        xPlayer.addInventoryItem(cropConfig.harvestItem, harvestAmount)
        
        -- Réinitialiser la plante
        plant.planted = false
        plant.harvestTime = nil
        
        -- Mettre à jour la base de données
        MySQL.Async.execute('UPDATE farming_plants SET planted = ?, harvest_time = ? WHERE id = ?', {
            false, nil, plant.id
        }, function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent('farming:cropHarvested', -1, farmId, plant.id)
                TriggerClientEvent('esx:showNotification', source, 
                    Config.Messages['harvest_success']:gsub('{amount}', harvestAmount):gsub('{item}', cropConfig.harvestItem))
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', source, Config.Messages['no_space'])
    end
end)

-- Callbacks
ESX.RegisterServerCallback('farming:hasPermission', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        cb(false)
        return 
    end
    
    if Config.UsePermissions then
        cb(xPlayer.getGroup() == Config.RequiredPermission)
    else
        cb(true)
    end
end)

ESX.RegisterServerCallback('farming:hasItem', function(source, cb, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        cb(false)
        return 
    end
    
    local item = xPlayer.getInventoryItem(itemName)
    cb(item and item.count > 0)
end)

-- Fonctions utilitaires
function GetFarmById(farmId)
    for _, farm in ipairs(farms) do
        if farm.id == farmId then
            return farm
        end
    end
    return nil
end

function GeneratePlantPositions(centerCoords, size, spacing)
    local positions = {}
    local halfSize = math.floor(size / 2)
    
    for x = -halfSize, halfSize do
        for y = -halfSize, halfSize do
            local plantCoords = {
                x = centerCoords.x + (x * spacing),
                y = centerCoords.y + (y * spacing),
                z = centerCoords.z
            }
            table.insert(positions, plantCoords)
        end
    end
    
    return positions
end

-- Nouvelle fonction pour générer des points dans une zone circulaire
function GenerateZonePoints(centerCoords, radius, density)
    local positions = {}
    local spacing
    
    -- Définir l'espacement selon la densité
    if density == 'low' then
        spacing = 8.0
    elseif density == 'medium' then
        spacing = 5.0
    elseif density == 'high' then
        spacing = 3.0
    else
        spacing = 5.0 -- par défaut
    end
    
    -- Calculer le nombre de points sur le rayon
    local steps = math.floor(radius / spacing)
    
    -- Générer des points en spirale dans le cercle
    for r = spacing, radius, spacing do
        local circumference = 2 * math.pi * r
        local pointsOnCircle = math.max(1, math.floor(circumference / spacing))
        
        for i = 0, pointsOnCircle - 1 do
            local angle = (i / pointsOnCircle) * 2 * math.pi
            local x = centerCoords.x + math.cos(angle) * r
            local y = centerCoords.y + math.sin(angle) * r
            
            -- Ajouter une petite variation aléatoire pour éviter l'alignement parfait
            local randomOffset = spacing * 0.3
            x = x + (math.random() - 0.5) * randomOffset
            y = y + (math.random() - 0.5) * randomOffset
            
            table.insert(positions, {
                x = x,
                y = y,
                z = centerCoords.z
            })
        end
    end
    
    -- Ajouter un point au centre
    table.insert(positions, {
        x = centerCoords.x,
        y = centerCoords.y,
        z = centerCoords.z
    })
    
    return positions
end

-- Fonctions utilitaires pour les items personnalisés

-- Fonction pour envoyer les logs vers Discord
function SendItemToDiscord(itemData, xPlayer, insertId)
    local webhook = Config.ItemCreation.discordLogs.webhook
    
    if not webhook or webhook == "VOTRE_WEBHOOK_DISCORD_ICI" then
        print('^3[FARMING CREATOR]^7 ⚠️ Webhook Discord non configuré')
        return
    end
    
    local embed = {
        {
            ["title"] = "🆕 Nouvel Item Créé",
            ["color"] = Config.ItemCreation.discordLogs.embedColor,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["thumbnail"] = {
                ["url"] = "https://cdn.discordapp.com/emojis/📦.png"
            },
            ["fields"] = {
                {
                    ["name"] = "📝 Informations de l'item",
                    ["value"] = "**Nom:** `" .. itemData.name .. "`\n" ..
                               "**Label:** " .. itemData.label .. "\n" ..
                               "**Catégorie:** " .. itemData.category .. "\n" ..
                               "**Poids:** " .. itemData.weight .. "kg\n" ..
                               "**Rareté:** " .. (itemData.rare == 1 and "Rare 💎" or "Commun ⚪"),
                    ["inline"] = true
                },
                {
                    ["name"] = "⚙️ Propriétés",
                    ["value"] = "**Utilisable:** " .. (itemData.usable == 1 and "Oui ✅" or "Non ❌") .. "\n" ..
                               "**Supprimable:** " .. (itemData.can_remove == 1 and "Oui ✅" or "Non ❌") .. "\n" ..
                               "**Ferme inventaire:** " .. (itemData.shouldClose == 1 and "Oui ✅" or "Non ❌"),
                    ["inline"] = true
                },
                {
                    ["name"] = "👨‍💼 Créateur",
                    ["value"] = "**Nom:** " .. xPlayer.getName() .. "\n" ..
                               "**ID:** " .. xPlayer.source .. "\n" ..
                               "**Identifier:** `" .. xPlayer.identifier .. "`",
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Farming Creator • ID BDD: " .. (insertId or "N/A"),
                ["icon_url"] = Config.ItemCreation.discordLogs.avatar
            }
        }
    }
    
    -- Ajouter les informations de farming si disponibles
    if itemData.usageType and itemData.usageType ~= 'none' and itemData.farmingData then
        local farmingInfo = ""
        if itemData.usageType == 'seed' then
            farmingInfo = "**Type:** Graine 🌱\n" ..
                         "**Prix:** " .. itemData.farmingData.price .. "$\n" ..
                         "**Temps croissance:** " .. (itemData.farmingData.growTime / 60000) .. " min"
        elseif itemData.usageType == 'harvest' then
            farmingInfo = "**Type:** Récolte 🌾\n" ..
                         "**Prix vente:** " .. itemData.farmingData.sellPrice .. "$\n" ..
                         "**Quantité:** " .. itemData.farmingData.harvestAmount.min .. "-" .. itemData.farmingData.harvestAmount.max
        elseif itemData.usageType == 'tool' then
            farmingInfo = "**Type:** Outil 🔧"
        end
        
        table.insert(embed[1].fields, {
            ["name"] = "🚜 Usage Farming",
            ["value"] = farmingInfo,
            ["inline"] = false
        })
    end
    
    -- Ajouter la description si elle existe
    if itemData.description and itemData.description ~= "" then
        table.insert(embed[1].fields, {
            ["name"] = "📄 Description",
            ["value"] = "```" .. itemData.description .. "```",
            ["inline"] = false
        })
    end
    
    local data = {
        ["username"] = Config.ItemCreation.discordLogs.botName,
        ["avatar_url"] = Config.ItemCreation.discordLogs.avatar,
        ["embeds"] = embed
    }
    
    -- Envoyer vers Discord
    PerformHttpRequest(webhook, function(err, text, headers)
        if err == 200 then
            print('^2[FARMING CREATOR]^7 ✅ Log Discord envoyé avec succès')
        else
            print('^1[FARMING CREATOR]^7 ❌ Erreur envoi Discord (Code: ' .. err .. ')')
        end
    end, 'POST', json.encode(data), {['Content-Type'] = 'application/json'})
end

-- Fonction pour ajouter un item au système de farming (dynamique)
function AddItemToFarmingConfig(itemData)
    if itemData.usageType == 'seed' and itemData.farmingData then
        print('^3[FARMING CREATOR]^7 🌱 Ajout de la graine "' .. itemData.name .. '" au système de farming')
        
        -- Créer une nouvelle culture dynamique
        local newCropType = {
            name = itemData.label,
            description = itemData.description or 'Culture personnalisée',
            growTime = itemData.farmingData.growTime,
            harvestAmount = itemData.farmingData.harvestAmount or {min = 1, max = 3},
            harvestItem = itemData.name:gsub('_seed', ''), -- Enlever _seed pour l'item de récolte
            seedItem = itemData.name,
            seedPrice = itemData.farmingData.price,
            sellPrice = itemData.farmingData.sellPrice or 5,
            model = 'prop_veg_crop_03_cab', -- Modèle par défaut
            blip = {
                sprite = 238,
                color = 2,
                scale = 0.8
            },
            marker = {
                type = 1,
                r = 0, g = 255, b = 0, a = 100,
                scale = {x = 1.0, y = 1.0, z = 1.0}
            }
        }
        
        -- Ajouter au config (temporaire, redémarre avec le serveur)
        local cropKey = itemData.name:gsub('_seed', '')
        Config.CropTypes[cropKey] = newCropType
        
        print('^2[FARMING CREATOR]^7 ✅ Culture "' .. cropKey .. '" ajoutée dynamiquement')
    end
end

-- Commandes administrateur
RegisterCommand('giveseed', function(source, args, rawCommand)
    if source == 0 then return end -- Console uniquement
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if Config.UsePermissions and xPlayer.getGroup() ~= Config.RequiredPermission then
        TriggerClientEvent('esx:showNotification', source, Config.Messages['no_permission'])
        return
    end
    
    if #args < 2 then
        TriggerClientEvent('esx:showNotification', source, 'Usage: /giveseed [type] [quantité]')
        return
    end
    
    local cropType = args[1]
    local amount = tonumber(args[2]) or 1
    
    if not Config.CropTypes[cropType] then
        TriggerClientEvent('esx:showNotification', source, 'Type de culture invalide')
        return
    end
    
    local seedItem = Config.CropTypes[cropType].seedItem
    xPlayer.addInventoryItem(seedItem, amount)
    TriggerClientEvent('esx:showNotification', source, 'Vous avez reçu ' .. amount .. 'x ' .. seedItem)
end, false)

-- Nouvelle commande pour donner des items personnalisés
RegisterCommand('giveitem', function(source, args, rawCommand)
    if source == 0 then return end -- Console uniquement
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if Config.UsePermissions and xPlayer.getGroup() ~= Config.RequiredPermission then
        TriggerClientEvent('esx:showNotification', source, Config.Messages['no_permission'])
        return
    end
    
    if #args < 2 then
        TriggerClientEvent('esx:showNotification', source, 'Usage: /giveitem [nom_item] [quantité] [joueur_id (optionnel)]')
        return
    end
    
    local itemName = args[1]
    local amount = tonumber(args[2]) or 1
    local targetId = args[3] and tonumber(args[3]) or source
    
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent('esx:showNotification', source, 'Joueur introuvable')
        return
    end
    
    -- Vérifier que l'item existe
    MySQL.Async.fetchAll('SELECT * FROM items WHERE name = ?', {itemName}, function(result)
        if #result == 0 then
            TriggerClientEvent('esx:showNotification', source, 'Item "' .. itemName .. '" introuvable')
            return
        end
        
        local item = result[1]
        targetPlayer.addInventoryItem(itemName, amount)
        
        if targetId == source then
            TriggerClientEvent('esx:showNotification', source, 'Vous avez reçu ' .. amount .. 'x ' .. item.label)
        else
            TriggerClientEvent('esx:showNotification', source, 'Vous avez donné ' .. amount .. 'x ' .. item.label .. ' à ' .. targetPlayer.getName())
            TriggerClientEvent('esx:showNotification', targetId, 'Vous avez reçu ' .. amount .. 'x ' .. item.label)
        end
        
        print('^2[FARMING CREATOR]^7 Item donné: ' .. amount .. 'x ' .. item.label .. ' à ' .. targetPlayer.getName())
    end)
end, false)

-- Auto-save toutes les 5 minutes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- 5 minutes
        
        for _, farm in ipairs(farms) do
            for _, plant in ipairs(farm.plants) do
                if plant.planted then
                    MySQL.Async.execute('UPDATE farming_plants SET planted = ?, harvest_time = ? WHERE id = ?', {
                        plant.planted, plant.harvestTime, plant.id
                    })
                end
            end
        end
        
        print('[Farming Creator] Sauvegarde automatique effectuée')
    end
end)