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
        LoadAllFarms()
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