-- ====================================
-- FARMING CREATOR - ITEM CREATOR CLIENT
-- ====================================
-- Interface client pour la création d'items personnalisés compatible multi-framework avec NUI moderne

-- Variables locales
local isItemCreatorOpen = false
local customItems = {}

-- Event handlers
RegisterNetEvent('farming:openItemCreator')
AddEventHandler('farming:openItemCreator', function()
    if isItemCreatorOpen then return end
    
    OpenItemCreatorNUI()
end)

RegisterNetEvent('farming:openItemSuggestion')
AddEventHandler('farming:openItemSuggestion', function()
    if isItemCreatorOpen then return end
    
    OpenItemCreatorNUI('suggest')
end)

RegisterNetEvent('farming:openItemMenu')
AddEventHandler('farming:openItemMenu', function()
    if isItemCreatorOpen then return end
    
    OpenItemCreatorNUI('manage')
end)

RegisterNetEvent('farming:receiveNotification')
AddEventHandler('farming:receiveNotification', function(message, type, duration)
    Framework.ShowNotification(message, type, duration)
end)

-- Fonction pour ouvrir l'interface NUI moderne
function OpenItemCreatorNUI(defaultTab)
    isItemCreatorOpen = true
    
    -- Ouvrir l'interface NUI
    SetNuiFocus(true, true)
    
    -- Envoyer le message d'ouverture
    SendNUIMessage({
        type = 'openItemCreator',
        defaultTab = defaultTab or 'create'
    })
    
    -- Charger les données initiales
    LoadItemsForNUI()
    LoadSuggestionsForNUI()
    LoadStatsForNUI()
end

-- Fonction pour fermer l'interface NUI
function CloseItemCreatorNUI()
    if not isItemCreatorOpen then return end
    
    isItemCreatorOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = 'closeItemCreator'
    })
end

-- Callbacks NUI
RegisterNUICallback('closeUI', function(data, cb)
    CloseItemCreatorNUI()
    cb('ok')
end)

RegisterNUICallback('createItem', function(data, cb)
    TriggerServerEvent('farming:createCustomItem', data)
    cb('ok')
end)

RegisterNUICallback('suggestItem', function(data, cb)
    TriggerServerEvent('farming:suggestCustomItem', data)
    cb('ok')
end)

RegisterNUICallback('loadItems', function(data, cb)
    LoadItemsForNUI()
    cb('ok')
end)

RegisterNUICallback('loadSuggestions', function(data, cb)
    LoadSuggestionsForNUI()
    cb('ok')
end)

RegisterNUICallback('loadStats', function(data, cb)
    LoadStatsForNUI()
    cb('ok')
end)

-- Fonctions pour charger les données
function LoadItemsForNUI()
    Framework.TriggerServerCallback('farming:getCustomItems', function(items)
        SendNUIMessage({
            type = 'updateItems',
            items = items
        })
    end)
end

function LoadSuggestionsForNUI()
    Framework.TriggerServerCallback('farming:getItemSuggestions', function(suggestions)
        SendNUIMessage({
            type = 'updateSuggestions',
            suggestions = suggestions
        })
    end)
end

function LoadStatsForNUI()
    -- Calculer les statistiques côté client
    Framework.TriggerServerCallback('farming:getCustomItems', function(items)
        Framework.TriggerServerCallback('farming:getItemSuggestions', function(suggestions)
            local stats = CalculateStats(items, suggestions)
            SendNUIMessage({
                type = 'updateStats',
                stats = stats
            })
        end)
    end)
end

function CalculateStats(items, suggestions)
    local stats = {
        totalItems = #items,
        totalSuggestions = #suggestions,
        totalWeight = 0,
        totalCreators = 0,
        normalItems = 0,
        rareItems = 0,
        epicItems = 0
    }
    
    local creators = {}
    
    for _, item in ipairs(items) do
        stats.totalWeight = stats.totalWeight + (item.weight or 1)
        
        if item.rare then
            stats.rareItems = stats.rareItems + 1
        else
            stats.normalItems = stats.normalItems + 1
        end
        
        if item.creator and not creators[item.creator] then
            creators[item.creator] = true
            stats.totalCreators = stats.totalCreators + 1
        end
    end
    
    return stats
end

-- Fonction pour afficher une notification dans l'interface NUI
function ShowNUINotification(message, type, duration)
    SendNUIMessage({
        type = 'showNotification',
        message = message,
        notificationType = type or 'info',
        duration = duration or 5000
    })
end

-- Gestion des événements de création d'item réussie
RegisterNetEvent('farming:itemCreated')
AddEventHandler('farming:itemCreated', function(itemData)
    -- Notification pour tous les joueurs qu'un nouvel item a été créé
    Framework.ShowNotification('📦 Nouvel item créé: ' .. itemData.label .. ' par ' .. itemData.creator)
    
    -- Mettre à jour l'interface NUI si elle est ouverte
    if isItemCreatorOpen then
        LoadItemsForNUI()
        LoadStatsForNUI()
        ShowNUINotification('Item créé avec succès!', 'success')
    end
end)

-- Gestion de la fermeture avec ESC
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isItemCreatorOpen then
            if IsControlJustPressed(0, 322) then -- ESC
                CloseItemCreatorNUI()
            end
        end
    end
end)

print('[Farming Creator] Client Item Creator avec interface NUI moderne chargé')