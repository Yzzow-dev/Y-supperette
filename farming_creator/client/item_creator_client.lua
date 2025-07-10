-- ====================================
-- FARMING CREATOR - ITEM CREATOR CLIENT
-- ====================================
-- Interface client pour la création d'items personnalisés compatible multi-framework

-- Variables locales
local isItemCreatorOpen = false
local customItems = {}

-- Event handlers
RegisterNetEvent('farming:openItemCreator')
AddEventHandler('farming:openItemCreator', function()
    if isItemCreatorOpen then return end
    
    OpenItemCreatorMenu()
end)

RegisterNetEvent('farming:openItemSuggestion')
AddEventHandler('farming:openItemSuggestion', function()
    if isItemCreatorOpen then return end
    
    OpenItemSuggestionMenu()
end)

RegisterNetEvent('farming:openItemMenu')
AddEventHandler('farming:openItemMenu', function()
    if isItemCreatorOpen then return end
    
    OpenItemManagementMenu()
end)

RegisterNetEvent('farming:itemCreated')
AddEventHandler('farming:itemCreated', function(itemData)
    -- Notification pour tous les joueurs qu'un nouvel item a été créé
    Framework.ShowNotification('📦 Nouvel item créé: ' .. itemData.label .. ' par ' .. itemData.creator)
end)

RegisterNetEvent('farming:receiveNotification')
AddEventHandler('farming:receiveNotification', function(message, type, duration)
    Framework.ShowNotification(message, type, duration)
end)

-- Fonction pour ouvrir le menu de création d'item
function OpenItemCreatorMenu()
    local elements = {
        {label = '📦 Créer un nouvel item', value = 'create_item'},
        {label = '📋 Voir mes items créés', value = 'view_my_items'},
        {label = '📊 Statistiques', value = 'view_stats'},
        {label = '❌ Fermer', value = 'close'}
    }
    
    Framework.OpenMenu({
        name = 'item_creator_menu',
        title = 'Créateur d\'Items',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'create_item' then
            menu.close()
            ShowItemCreationForm()
        elseif data.current.value == 'view_my_items' then
            menu.close()
            ShowMyItems()
        elseif data.current.value == 'view_stats' then
            menu.close()
            ShowItemStats()
        elseif data.current.value == 'close' then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Fonction pour ouvrir le menu de suggestion d'item
function OpenItemSuggestionMenu()
    local elements = {
        {label = '💡 Suggérer un item', value = 'suggest_item'},
        {label = '📝 Mes suggestions', value = 'view_suggestions'},
        {label = '❌ Fermer', value = 'close'}
    }
    
    Framework.OpenMenu({
        name = 'item_suggestion_menu',
        title = 'Suggestions d\'Items',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'suggest_item' then
            menu.close()
            ShowItemSuggestionForm()
        elseif data.current.value == 'view_suggestions' then
            menu.close()
            ShowMySuggestions()
        elseif data.current.value == 'close' then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Fonction pour afficher le formulaire de création d'item
function ShowItemCreationForm()
    isItemCreatorOpen = true
    
    Framework.OpenDialog({
        name = 'item_name_input',
        title = 'Nom de l\'item (sans espaces ni caractères spéciaux)'
    }, function(data, menu)
        local itemName = data.value
        if itemName == nil or itemName == '' then
            Framework.ShowNotification('Le nom de l\'item est requis!', 'error')
            isItemCreatorOpen = false
            return
        end
        
        menu.close()
        
        Framework.OpenDialog({
            name = 'item_label_input',
            title = 'Label de l\'item (nom affiché)'
        }, function(data2, menu2)
            local itemLabel = data2.value
            if itemLabel == nil or itemLabel == '' then
                Framework.ShowNotification('Le label de l\'item est requis!', 'error')
                isItemCreatorOpen = false
                return
            end
            
            menu2.close()
            
            Framework.OpenDialog({
                name = 'item_weight_input',
                title = 'Poids de l\'item (nombre)'
            }, function(data3, menu3)
                local itemWeight = tonumber(data3.value) or 1
                
                menu3.close()
                
                Framework.OpenDialog({
                    name = 'item_description_input',
                    title = 'Description de l\'item (optionnel)'
                }, function(data4, menu4)
                    local itemDescription = data4.value or ""
                    
                    menu4.close()
                    
                    -- Créer l'item
                    local itemData = {
                        name = itemName,
                        label = itemLabel,
                        weight = itemWeight,
                        description = itemDescription,
                        rare = false,
                        can_remove = true,
                        stackable = true,
                        usable = false
                    }
                    
                    TriggerServerEvent('farming:createCustomItem', itemData)
                    isItemCreatorOpen = false
                    
                end, function(data4, menu4)
                    menu4.close()
                    isItemCreatorOpen = false
                end)
                
            end, function(data3, menu3)
                menu3.close()
                isItemCreatorOpen = false
            end)
            
        end, function(data2, menu2)
            menu2.close()
            isItemCreatorOpen = false
        end)
        
    end, function(data, menu)
        menu.close()
        isItemCreatorOpen = false
    end)
end

-- Fonction pour afficher le formulaire de suggestion d'item
function ShowItemSuggestionForm()
    isItemCreatorOpen = true
    
    Framework.OpenDialog({
        name = 'suggest_item_name_input',
        title = 'Nom de l\'item suggéré'
    }, function(data, menu)
        local itemName = data.value
        if itemName == nil or itemName == '' then
            Framework.ShowNotification('Le nom de l\'item est requis!', 'error')
            isItemCreatorOpen = false
            return
        end
        
        menu.close()
        
        Framework.OpenDialog({
            name = 'suggest_item_label_input',
            title = 'Label de l\'item suggéré'
        }, function(data2, menu2)
            local itemLabel = data2.value
            if itemLabel == nil or itemLabel == '' then
                Framework.ShowNotification('Le label de l\'item est requis!', 'error')
                isItemCreatorOpen = false
                return
            end
            
            menu2.close()
            
            Framework.OpenDialog({
                name = 'suggest_item_description_input',
                title = 'Description/Justification de la suggestion'
            }, function(data3, menu3)
                local itemDescription = data3.value or ""
                
                menu3.close()
                
                -- Suggérer l'item
                local itemData = {
                    name = itemName,
                    label = itemLabel,
                    description = itemDescription,
                    weight = 1,
                    rare = false,
                    can_remove = true,
                    stackable = true,
                    usable = false
                }
                
                TriggerServerEvent('farming:suggestCustomItem', itemData)
                isItemCreatorOpen = false
                
            end, function(data3, menu3)
                menu3.close()
                isItemCreatorOpen = false
            end)
            
        end, function(data2, menu2)
            menu2.close()
            isItemCreatorOpen = false
        end)
        
    end, function(data, menu)
        menu.close()
        isItemCreatorOpen = false
    end)
end

-- Fonction pour afficher mes items créés
function ShowMyItems()
    Framework.TriggerServerCallback('farming:getCustomItems', function(items)
        local elements = {}
        
        if #items == 0 then
            table.insert(elements, {label = 'Aucun item créé', value = 'none'})
        else
            for _, item in ipairs(items) do
                table.insert(elements, {
                    label = item.label .. ' (' .. item.name .. ') - Poids: ' .. item.weight,
                    value = 'item_' .. item.id,
                    item = item
                })
            end
        end
        
        table.insert(elements, {label = '❌ Retour', value = 'back'})
        
        Framework.OpenMenu({
            name = 'my_items_menu',
            title = 'Mes Items Créés (' .. #items .. ')',
            elements = elements
        }, function(data, menu)
            if data.current.value == 'back' then
                menu.close()
                OpenItemCreatorMenu()
            elseif data.current.value ~= 'none' then
                -- Afficher les détails de l'item
                ShowItemDetails(data.current.item)
            end
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- Fonction pour afficher les détails d'un item
function ShowItemDetails(item)
    local detailsText = string.format(
        'Nom: %s\nLabel: %s\nPoids: %s\nRare: %s\nEmpilable: %s\nUtilisable: %s\nCréateur: %s\nCréé le: %s',
        item.name,
        item.label,
        tostring(item.weight),
        item.rare and 'Oui' or 'Non',
        item.stackable and 'Oui' or 'Non',
        item.usable and 'Oui' or 'Non',
        item.creator,
        item.createdAt
    )
    
    if item.description and item.description ~= '' then
        detailsText = detailsText .. '\nDescription: ' .. item.description
    end
    
    Framework.ShowNotification(detailsText, 'info', 7000)
end

-- Fonction pour afficher les statistiques
function ShowItemStats()
    Framework.TriggerServerCallback('farming:getCustomItems', function(items)
        local totalItems = #items
        local totalWeight = 0
        local rareItems = 0
        local usableItems = 0
        
        for _, item in ipairs(items) do
            totalWeight = totalWeight + item.weight
            if item.rare then rareItems = rareItems + 1 end
            if item.usable then usableItems = usableItems + 1 end
        end
        
        local statsText = string.format(
            'Statistiques des Items:\n\nTotal d\'items créés: %d\nPoids total: %d\nItems rares: %d\nItems utilisables: %d',
            totalItems,
            totalWeight,
            rareItems,
            usableItems
        )
        
        Framework.ShowNotification(statsText, 'info', 7000)
    end)
end

-- Fonction pour afficher mes suggestions
function ShowMySuggestions()
    Framework.TriggerServerCallback('farming:getItemSuggestions', function(suggestions)
        local elements = {}
        
        if #suggestions == 0 then
            table.insert(elements, {label = 'Aucune suggestion', value = 'none'})
        else
            for _, suggestion in ipairs(suggestions) do
                table.insert(elements, {
                    label = suggestion.label .. ' (' .. suggestion.name .. ') - Par: ' .. suggestion.creator,
                    value = 'suggestion_' .. suggestion.id,
                    suggestion = suggestion
                })
            end
        end
        
        table.insert(elements, {label = '❌ Retour', value = 'back'})
        
        Framework.OpenMenu({
            name = 'suggestions_menu',
            title = 'Suggestions d\'Items (' .. #suggestions .. ')',
            elements = elements
        }, function(data, menu)
            if data.current.value == 'back' then
                menu.close()
                OpenItemSuggestionMenu()
            elseif data.current.value ~= 'none' then
                -- Afficher les détails de la suggestion
                ShowItemDetails(data.current.suggestion)
            end
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- Fonction pour ouvrir le menu de gestion des items (admin)
function OpenItemManagementMenu()
    local elements = {
        {label = '📦 Tous les items créés', value = 'all_items'},
        {label = '💡 Suggestions en attente', value = 'pending_suggestions'},
        {label = '📊 Statistiques globales', value = 'global_stats'},
        {label = '❌ Fermer', value = 'close'}
    }
    
    Framework.OpenMenu({
        name = 'item_management_menu',
        title = 'Gestion des Items',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'all_items' then
            menu.close()
            ShowAllItems()
        elseif data.current.value == 'pending_suggestions' then
            menu.close()
            ShowPendingSuggestions()
        elseif data.current.value == 'global_stats' then
            menu.close()
            ShowGlobalStats()
        elseif data.current.value == 'close' then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Fonction pour afficher tous les items
function ShowAllItems()
    Framework.TriggerServerCallback('farming:getCustomItems', function(items)
        local elements = {}
        
        if #items == 0 then
            table.insert(elements, {label = 'Aucun item créé', value = 'none'})
        else
            for _, item in ipairs(items) do
                table.insert(elements, {
                    label = item.label .. ' (' .. item.name .. ') - Par: ' .. item.creator,
                    value = 'item_' .. item.id,
                    item = item
                })
            end
        end
        
        table.insert(elements, {label = '❌ Retour', value = 'back'})
        
        Framework.OpenMenu({
            name = 'all_items_menu',
            title = 'Tous les Items (' .. #items .. ')',
            elements = elements
        }, function(data, menu)
            if data.current.value == 'back' then
                menu.close()
                OpenItemManagementMenu()
            elseif data.current.value ~= 'none' then
                ShowItemDetails(data.current.item)
            end
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- Fonction pour afficher les suggestions en attente
function ShowPendingSuggestions()
    Framework.TriggerServerCallback('farming:getItemSuggestions', function(suggestions)
        local elements = {}
        
        if #suggestions == 0 then
            table.insert(elements, {label = 'Aucune suggestion en attente', value = 'none'})
        else
            for _, suggestion in ipairs(suggestions) do
                table.insert(elements, {
                    label = suggestion.label .. ' (' .. suggestion.name .. ') - Par: ' .. suggestion.creator,
                    value = 'suggestion_' .. suggestion.id,
                    suggestion = suggestion
                })
            end
        end
        
        table.insert(elements, {label = '❌ Retour', value = 'back'})
        
        Framework.OpenMenu({
            name = 'pending_suggestions_menu',
            title = 'Suggestions en Attente (' .. #suggestions .. ')',
            elements = elements
        }, function(data, menu)
            if data.current.value == 'back' then
                menu.close()
                OpenItemManagementMenu()
            elseif data.current.value ~= 'none' then
                ShowItemDetails(data.current.suggestion)
            end
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- Fonction pour afficher les statistiques globales
function ShowGlobalStats()
    Framework.TriggerServerCallback('farming:getCustomItems', function(items)
        Framework.TriggerServerCallback('farming:getItemSuggestions', function(suggestions)
            local totalItems = #items
            local totalSuggestions = #suggestions
            local totalWeight = 0
            local creators = {}
            
            for _, item in ipairs(items) do
                totalWeight = totalWeight + item.weight
                creators[item.creator] = (creators[item.creator] or 0) + 1
            end
            
            local uniqueCreators = 0
            for _ in pairs(creators) do
                uniqueCreators = uniqueCreators + 1
            end
            
            local statsText = string.format(
                'Statistiques Globales:\n\nItems créés: %d\nSuggestions en attente: %d\nPoids total: %d\nCréateurs uniques: %d',
                totalItems,
                totalSuggestions,
                totalWeight,
                uniqueCreators
            )
            
            Framework.ShowNotification(statsText, 'info', 7000)
        end)
    end)
end

print('[Farming Creator] Client Item Creator chargé')