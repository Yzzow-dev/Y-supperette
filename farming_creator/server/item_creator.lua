-- ====================================
-- FARMING CREATOR - ITEM CREATOR SYSTEM
-- ====================================
-- Système de création d'items personnalisés avec logs Discord compatible multi-framework

-- Variables locales
local customItems = {}

-- Initialisation de la base de données pour les items personnalisés
MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS custom_items_creator (
            id INT AUTO_INCREMENT PRIMARY KEY,
            item_name VARCHAR(50) NOT NULL UNIQUE,
            item_label VARCHAR(100) NOT NULL,
            weight INT DEFAULT 1,
            rare BOOLEAN DEFAULT FALSE,
            can_remove BOOLEAN DEFAULT TRUE,
            stackable BOOLEAN DEFAULT TRUE,
            usable BOOLEAN DEFAULT FALSE,
            description TEXT,
            creator_identifier VARCHAR(50) NOT NULL,
            creator_name VARCHAR(100) NOT NULL,
            is_suggestion BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {}, function(result)
        print('[Farming Creator] Table custom_items_creator créée/vérifiée')
        LoadCustomItems()
    end)
end)

-- Charger tous les items personnalisés
function LoadCustomItems()
    MySQL.Async.fetchAll('SELECT * FROM custom_items_creator WHERE is_suggestion = 0', {}, function(results)
        customItems = {}
        for _, item in ipairs(results) do
            table.insert(customItems, {
                id = item.id,
                name = item.item_name,
                label = item.item_label,
                weight = item.weight,
                rare = item.rare == 1,
                can_remove = item.can_remove == 1,
                stackable = item.stackable == 1,
                usable = item.usable == 1,
                description = item.description,
                creator = item.creator_name,
                createdAt = item.created_at
            })
        end
        print('[Farming Creator] ' .. #customItems .. ' items personnalisés chargés')
    end)
end

-- Fonction pour envoyer des logs Discord
function SendDiscordLog(title, description, color, fields)
    if not Config.Discord.enabled or not Config.Discord.webhook or Config.Discord.webhook == "VOTRE_WEBHOOK_URL_ICI" then
        return
    end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = color or Config.Discord.embedColor,
            ["fields"] = fields or {},
            ["footer"] = {
                ["text"] = Config.Discord.footerText .. " | " .. os.date("%d/%m/%Y à %H:%M:%S")
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    if Config.Discord.avatarURL then
        embed[1]["thumbnail"] = {
            ["url"] = Config.Discord.avatarURL
        }
    end
    
    local payload = json.encode({
        username = Config.Discord.serverName,
        embeds = embed
    })
    
    PerformHttpRequest(Config.Discord.webhook, function(err, text, headers)
        if err ~= 200 then
            if Config.CustomItems.logToConsole then
                print('[Farming Creator] Erreur Discord Log: ' .. tostring(err))
            end
        else
            if Config.CustomItems.logToConsole then
                print('[Farming Creator] Log Discord envoyé avec succès')
            end
        end
    end, 'POST', payload, {['Content-Type'] = 'application/json'})
end

-- Fonction pour vérifier si un item existe déjà
function ItemExists(itemName)
    -- Vérifier dans les items ESX standards
    local query = 'SELECT name FROM items WHERE name = ? LIMIT 1'
    local result = MySQL.Sync.fetchAll(query, {itemName})
    return #result > 0
end

-- Fonction pour vérifier si un item personnalisé existe
function CustomItemExists(itemName)
    local query = 'SELECT item_name FROM custom_items_creator WHERE item_name = ? LIMIT 1'
    local result = MySQL.Sync.fetchAll(query, {itemName})
    return #result > 0
end

-- Fonction pour compter les items créés par un joueur
function GetPlayerItemCount(identifier)
    local query = 'SELECT COUNT(*) as count FROM custom_items_creator WHERE creator_identifier = ? AND is_suggestion = 0'
    local result = MySQL.Sync.fetchAll(query, {identifier})
    return result[1] and result[1].count or 0
end

-- Event pour créer un item personnalisé
RegisterServerEvent('farming:createCustomItem')
AddEventHandler('farming:createCustomItem', function(itemData)
    local source = source
    local xPlayer = Framework.GetPlayer(source)
    
    if not xPlayer then return end
    
    -- Vérifier si le système est activé
    if not Config.CustomItems.enabled then
        TriggerEvent('farming:sendNotification', source, Config.Messages['item_system_disabled'])
        return
    end
    
    -- Vérifier les permissions
    if Config.UsePermissions then
        if not Framework.HasPermission(xPlayer, Config.RequiredPermission) then
            TriggerEvent('farming:sendNotification', source, Config.Messages['no_permission'])
            return
        end
    end
    
    -- Validation des données
    if not itemData.name or itemData.name == "" then
        TriggerEvent('farming:sendNotification', source, Config.Messages['item_name_required'])
        return
    end
    
    if not itemData.label or itemData.label == "" then
        TriggerEvent('farming:sendNotification', source, Config.Messages['item_label_required'])
        return
    end
    
    -- Nettoyer le nom de l'item (enlever espaces, caractères spéciaux)
    itemData.name = string.lower(itemData.name:gsub("%s+", "_"):gsub("[^%w_]", ""))
    
    -- Vérifier si l'item existe déjà
    if ItemExists(itemData.name) or CustomItemExists(itemData.name) then
        TriggerEvent('farming:sendNotification', source, Config.Messages['item_already_exists'])
        return
    end
    
    -- Vérifier la limite d'items par joueur
    local playerIdentifier = Framework.GetPlayerIdentifier(xPlayer)
    local currentCount = GetPlayerItemCount(playerIdentifier)
    if currentCount >= Config.CustomItems.maxItemsPerPlayer then
        TriggerEvent('farming:sendNotification', source, 
            Config.Messages['max_items_reached']:gsub('{max}', Config.CustomItems.maxItemsPerPlayer))
        return
    end
    
    -- Appliquer les valeurs par défaut si nécessaire
    itemData.weight = itemData.weight or Config.CustomItems.defaultValues.weight
    itemData.rare = itemData.rare or Config.CustomItems.defaultValues.rare
    itemData.can_remove = itemData.can_remove or Config.CustomItems.defaultValues.can_remove
    itemData.stackable = itemData.stackable or Config.CustomItems.defaultValues.stackable
    itemData.usable = itemData.usable or Config.CustomItems.defaultValues.usable
    itemData.description = itemData.description or ""
    
    -- Insérer l'item personnalisé dans la table de tracking
    local playerIdentifier = Framework.GetPlayerIdentifier(xPlayer)
    local playerName = Framework.GetPlayerName(xPlayer)
    
    MySQL.Async.insert([[
        INSERT INTO custom_items_creator 
        (item_name, item_label, weight, rare, can_remove, stackable, usable, description, creator_identifier, creator_name) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        itemData.name,
        itemData.label,
        itemData.weight,
        itemData.rare,
        itemData.can_remove,
        itemData.stackable,
        itemData.usable,
        itemData.description,
        playerIdentifier,
        playerName
    }, function(insertId)
        if insertId then
            -- Si l'insertion automatique est activée, insérer dans la table items d'ESX
            if Config.CustomItems.autoInsertIntoDB then
                MySQL.Async.insert([[
                    INSERT INTO items (name, label, weight, rare, can_remove) 
                    VALUES (?, ?, ?, ?, ?)
                ]], {
                    itemData.name,
                    itemData.label,
                    itemData.weight,
                    itemData.rare and 1 or 0,
                    itemData.can_remove and 1 or 0
                }, function(itemInsertId)
                    if itemInsertId then
                        -- Log dans la console
                        if Config.CustomItems.logToConsole then
                            Framework.Log('Item créé et inséré dans la table de données: ' .. itemData.name .. ' par ' .. playerName)
                        end
                        
                        -- Ajouter à la liste locale
                        table.insert(customItems, {
                            id = insertId,
                            name = itemData.name,
                            label = itemData.label,
                            weight = itemData.weight,
                            rare = itemData.rare,
                            can_remove = itemData.can_remove,
                            stackable = itemData.stackable,
                            usable = itemData.usable,
                            description = itemData.description,
                            creator = playerName,
                            createdAt = os.date("%Y-%m-%d %H:%M:%S")
                        })
                        
                        -- Notification au joueur
                        TriggerEvent('farming:sendNotification', source, 
                            Config.Messages['item_created']:gsub('{name}', itemData.label))
                        
                        -- Log Discord
                        if Config.CustomItems.logToDiscord then
                            local fields = {
                                {
                                    ["name"] = "📦 Nom de l'item",
                                    ["value"] = "`" .. itemData.name .. "`",
                                    ["inline"] = true
                                },
                                {
                                    ["name"] = "🏷️ Label",
                                    ["value"] = itemData.label,
                                    ["inline"] = true
                                },
                                {
                                    ["name"] = "⚖️ Poids",
                                    ["value"] = tostring(itemData.weight),
                                    ["inline"] = true
                                },
                                {
                                    ["name"] = "👤 Créateur",
                                    ["value"] = playerName .. " (" .. playerIdentifier .. ")",
                                    ["inline"] = false
                                }
                            }
                            
                            if itemData.description and itemData.description ~= "" then
                                table.insert(fields, {
                                    ["name"] = "📝 Description",
                                    ["value"] = itemData.description,
                                    ["inline"] = false
                                })
                            end
                            
                            SendDiscordLog(
                                "🎯 Nouvel Item Créé",
                                "Un nouvel item personnalisé a été créé et ajouté à la base de données.",
                                65280, -- Vert
                                fields
                            )
                        end
                        
                        -- Informer tous les joueurs connectés (staff seulement)
                        TriggerClientEvent('farming:itemCreated', -1, {
                            name = itemData.name,
                            label = itemData.label,
                            creator = playerName
                        })
                        
                    else
                        print('[Farming Creator] Erreur lors de l\'insertion de l\'item dans la table items')
                    end
                end)
            end
        else
            print('[Farming Creator] Erreur lors de l\'insertion de l\'item personnalisé')
        end
    end)
end)

-- Event pour suggérer un item (pour les staff)
RegisterServerEvent('farming:suggestCustomItem')
AddEventHandler('farming:suggestCustomItem', function(itemData)
    local source = source
    local xPlayer = Framework.GetPlayer(source)
    
    if not xPlayer then return end
    
    -- Vérifier si le système est activé
    if not Config.CustomItems.enabled or not Config.CustomItems.allowStaffSuggestions then
        TriggerEvent('farming:sendNotification', source, Config.Messages['item_system_disabled'])
        return
    end
    
    -- Validation des données
    if not itemData.name or itemData.name == "" then
        TriggerEvent('farming:sendNotification', source, Config.Messages['item_name_required'])
        return
    end
    
    if not itemData.label or itemData.label == "" then
        TriggerEvent('farming:sendNotification', source, Config.Messages['item_label_required'])
        return
    end
    
    -- Nettoyer le nom de l'item
    itemData.name = string.lower(itemData.name:gsub("%s+", "_"):gsub("[^%w_]", ""))
    
    -- Appliquer les valeurs par défaut
    itemData.weight = itemData.weight or Config.CustomItems.defaultValues.weight
    itemData.rare = itemData.rare or Config.CustomItems.defaultValues.rare
    itemData.can_remove = itemData.can_remove or Config.CustomItems.defaultValues.can_remove
    itemData.stackable = itemData.stackable or Config.CustomItems.defaultValues.stackable
    itemData.usable = itemData.usable or Config.CustomItems.defaultValues.usable
    itemData.description = itemData.description or ""
    
    -- Insérer la suggestion dans la base de données
    MySQL.Async.insert([[
        INSERT INTO custom_items_creator 
        (item_name, item_label, weight, rare, can_remove, stackable, usable, description, creator_identifier, creator_name, is_suggestion) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        itemData.name,
        itemData.label,
        itemData.weight,
        itemData.rare,
        itemData.can_remove,
        itemData.stackable,
        itemData.usable,
        itemData.description,
        Framework.GetPlayerIdentifier(xPlayer),
        Framework.GetPlayerName(xPlayer),
        true
    }, function(insertId)
        if insertId then
            -- Log dans la console
            if Config.CustomItems.logToConsole then
                Framework.Log('Suggestion d\'item reçue: ' .. itemData.name .. ' par ' .. Framework.GetPlayerName(xPlayer))
            end
            
            -- Notification au joueur
            TriggerEvent('farming:sendNotification', source, Config.Messages['item_suggestion_sent'])
            
            -- Log Discord pour les suggestions
            if Config.CustomItems.logToDiscord then
                local fields = {
                    {
                        ["name"] = "📦 Nom de l'item",
                        ["value"] = "`" .. itemData.name .. "`",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🏷️ Label",
                        ["value"] = itemData.label,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "⚖️ Poids",
                        ["value"] = tostring(itemData.weight),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "👤 Suggéré par",
                        ["value"] = Framework.GetPlayerName(xPlayer) .. " (" .. Framework.GetPlayerIdentifier(xPlayer) .. ")",
                        ["inline"] = false
                    }
                }
                
                if itemData.description and itemData.description ~= "" then
                    table.insert(fields, {
                        ["name"] = "📝 Description",
                        ["value"] = itemData.description,
                        ["inline"] = false
                    })
                end
                
                SendDiscordLog(
                    "💡 Suggestion d'Item",
                    "Une nouvelle suggestion d'item a été soumise par un membre du staff.",
                    16776960, -- Jaune
                    fields
                )
            end
        end
    end)
end)

-- Callback pour récupérer les items personnalisés
Framework.RegisterServerCallback('farming:getCustomItems', function(source, cb)
    cb(customItems)
end)

-- Callback pour récupérer les suggestions d'items
Framework.RegisterServerCallback('farming:getItemSuggestions', function(source, cb)
    local xPlayer = Framework.GetPlayer(source)
    if not xPlayer then 
        cb({})
        return 
    end
    
    -- Vérifier les permissions pour voir les suggestions
    if Config.UsePermissions and not Framework.HasPermission(xPlayer, Config.RequiredPermission) then
        cb({})
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM custom_items_creator WHERE is_suggestion = 1 ORDER BY created_at DESC', {}, function(results)
        local suggestions = {}
        for _, item in ipairs(results) do
            table.insert(suggestions, {
                id = item.id,
                name = item.item_name,
                label = item.item_label,
                weight = item.weight,
                rare = item.rare == 1,
                can_remove = item.can_remove == 1,
                stackable = item.stackable == 1,
                usable = item.usable == 1,
                description = item.description,
                creator = item.creator_name,
                createdAt = item.created_at
            })
        end
        cb(suggestions)
    end)
end)

-- Commandes
RegisterCommand(Config.Commands.createItem, function(source, args, rawCommand)
    local xPlayer = Framework.GetPlayer(source)
    if not xPlayer then return end
    
    if Config.UsePermissions and not Framework.HasPermission(xPlayer, Config.RequiredPermission) then
        TriggerEvent('farming:sendNotification', source, Config.Messages['no_permission'])
        return
    end
    
    -- Ouvrir le menu de création d'item
    TriggerClientEvent('farming:openItemCreator', source)
end, false)

RegisterCommand(Config.Commands.suggestItem, function(source, args, rawCommand)
    local xPlayer = Framework.GetPlayer(source)
    if not xPlayer then return end
    
    if not Config.CustomItems.allowStaffSuggestions then
        TriggerEvent('farming:sendNotification', source, Config.Messages['item_system_disabled'])
        return
    end
    
    -- Ouvrir le menu de suggestion d'item
    TriggerClientEvent('farming:openItemSuggestion', source)
end, false)

RegisterCommand(Config.Commands.itemMenu, function(source, args, rawCommand)
    local xPlayer = Framework.GetPlayer(source)
    if not xPlayer then return end
    
    if Config.UsePermissions and not Framework.HasPermission(xPlayer, Config.RequiredPermission) then
        TriggerEvent('farming:sendNotification', source, Config.Messages['no_permission'])
        return
    end
    
    -- Ouvrir le menu de gestion des items
    TriggerClientEvent('farming:openItemMenu', source)
end, false)

-- Event pour gérer les notifications côté serveur vers client
RegisterServerEvent('farming:sendNotification')
AddEventHandler('farming:sendNotification', function(message, type, duration)
    local source = source
    TriggerClientEvent('farming:receiveNotification', source, message, type, duration)
end)

print('[Farming Creator] Système d\'items personnalisés chargé')