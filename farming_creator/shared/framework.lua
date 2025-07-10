-- ====================================
-- FARMING CREATOR - FRAMEWORK COMPATIBILITY
-- ====================================
-- Système de compatibilité multi-framework

Framework = {}
Framework.Object = nil
Framework.PlayerData = {}

-- Initialisation du framework
function Framework.Init()
    local frameworkConfig = Config.FrameworkSettings[Config.Framework]
    
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        Framework.InitESX()
    elseif Config.Framework == 'qbcore' then
        Framework.InitQBCore()
    else
        print('[Farming Creator] Framework non supporté: ' .. Config.Framework)
    end
end

-- Initialisation ESX/ESX Legacy
function Framework.InitESX()
    if IsDuplicityVersion() then
        -- Côté serveur
        TriggerEvent('esx:getSharedObject', function(obj) Framework.Object = obj end)
        
        -- Attendre que ESX soit prêt
        while Framework.Object == nil do
            Citizen.Wait(10)
        end
    else
        -- Côté client
        Citizen.CreateThread(function()
            while Framework.Object == nil do
                TriggerEvent('esx:getSharedObject', function(obj) Framework.Object = obj end)
                Citizen.Wait(10)
            end
            
            while Framework.Object.GetPlayerData().job == nil do
                Citizen.Wait(10)
            end
            
            Framework.PlayerData = Framework.Object.GetPlayerData()
        end)
    end
end

-- Initialisation QBCore
function Framework.InitQBCore()
    if IsDuplicityVersion() then
        -- Côté serveur
        Framework.Object = exports['qb-core']:GetCoreObject()
    else
        -- Côté client
        Framework.Object = exports['qb-core']:GetCoreObject()
        Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
    end
end

-- Fonctions universelles pour obtenir un joueur (serveur)
function Framework.GetPlayer(source)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return Framework.Object.GetPlayerFromId(source)
    elseif Config.Framework == 'qbcore' then
        return Framework.Object.Functions.GetPlayer(source)
    end
    return nil
end

-- Fonctions universelles pour l'identifiant du joueur
function Framework.GetPlayerIdentifier(xPlayer)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return xPlayer.identifier
    elseif Config.Framework == 'qbcore' then
        return xPlayer.PlayerData.license or xPlayer.PlayerData.citizenid
    end
    return nil
end

-- Fonctions universelles pour le nom du joueur
function Framework.GetPlayerName(xPlayer)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return xPlayer.getName()
    elseif Config.Framework == 'qbcore' then
        return xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
    end
    return "Unknown"
end

-- Fonctions universelles pour le groupe/job du joueur
function Framework.GetPlayerGroup(xPlayer)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return xPlayer.getGroup()
    elseif Config.Framework == 'qbcore' then
        return xPlayer.PlayerData.job.name
    end
    return nil
end

-- Fonctions universelles pour les items (serveur)
function Framework.GetPlayerItem(xPlayer, itemName)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return xPlayer.getInventoryItem(itemName)
    elseif Config.Framework == 'qbcore' then
        return xPlayer.Functions.GetItemByName(itemName)
    end
    return nil
end

function Framework.AddPlayerItem(xPlayer, itemName, amount)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return xPlayer.addInventoryItem(itemName, amount)
    elseif Config.Framework == 'qbcore' then
        return xPlayer.Functions.AddItem(itemName, amount)
    end
    return false
end

function Framework.RemovePlayerItem(xPlayer, itemName, amount)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return xPlayer.removeInventoryItem(itemName, amount)
    elseif Config.Framework == 'qbcore' then
        return xPlayer.Functions.RemoveItem(itemName, amount)
    end
    return false
end

function Framework.CanCarryItem(xPlayer, itemName, amount)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return xPlayer.canCarryItem(itemName, amount)
    elseif Config.Framework == 'qbcore' then
        -- QBCore n'a pas de fonction canCarryItem native, on peut l'ajouter
        local item = Framework.GetPlayerItem(xPlayer, itemName)
        return true -- Simplified pour l'instant
    end
    return false
end

-- Fonctions universelles pour les notifications (client)
function Framework.ShowNotification(message, type, duration)
    if not IsDuplicityVersion() then
        local notifType = Config.FrameworkSettings[Config.Framework].notification_type
        
        if notifType == 'esx' then
            if Framework.Object and Framework.Object.ShowNotification then
                Framework.Object.ShowNotification(message, type, duration)
            else
                -- Fallback pour ESX Legacy
                TriggerEvent('esx:showNotification', message)
            end
        elseif notifType == 'qbcore' then
            if Framework.Object and Framework.Object.Functions and Framework.Object.Functions.Notify then
                Framework.Object.Functions.Notify(message, type or 'primary', duration or 5000)
            end
        elseif notifType == 'mythic' then
            exports['mythic_notify']:DoHudText(type or 'inform', message)
        elseif notifType == 'ox_lib' then
            exports['ox_lib']:notify({
                title = 'Farming Creator',
                description = message,
                type = type or 'inform',
                duration = duration or 5000
            })
        end
    end
end

-- Fonctions universelles pour les callbacks (serveur)
function Framework.RegisterServerCallback(name, callback)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        Framework.Object.RegisterServerCallback(name, callback)
    elseif Config.Framework == 'qbcore' then
        Framework.Object.Functions.CreateCallback(name, callback)
    end
end

-- Fonctions universelles pour déclencher les callbacks (client)
function Framework.TriggerServerCallback(name, callback, ...)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        Framework.Object.TriggerServerCallback(name, callback, ...)
    elseif Config.Framework == 'qbcore' then
        Framework.Object.Functions.TriggerCallback(name, callback, ...)
    end
end

-- Fonctions universelles pour les menus (client)
function Framework.OpenMenu(menuData, onSelect, onClose)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        Framework.Object.UI.Menu.Open('default', GetCurrentResourceName(), menuData.name, {
            title = menuData.title,
            align = menuData.align or 'top-left',
            elements = menuData.elements
        }, onSelect, onClose)
    elseif Config.Framework == 'qbcore' then
        -- QBCore utilise généralement qb-menu ou ox_lib pour les menus
        if GetResourceState('qb-menu') == 'started' then
            exports['qb-menu']:openMenu(menuData.elements)
        elseif GetResourceState('ox_lib') == 'started' then
            local options = {}
            for _, element in ipairs(menuData.elements) do
                table.insert(options, {
                    title = element.label,
                    description = element.description,
                    onSelect = function()
                        onSelect({current = element}, {close = function() end})
                    end
                })
            end
            exports['ox_lib']:registerContext({
                id = menuData.name,
                title = menuData.title,
                options = options
            })
            exports['ox_lib']:showContext(menuData.name)
        end
    end
end

function Framework.CloseMenu()
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        Framework.Object.UI.Menu.CloseAll()
    elseif Config.Framework == 'qbcore' then
        if GetResourceState('qb-menu') == 'started' then
            exports['qb-menu']:closeMenu()
        elseif GetResourceState('ox_lib') == 'started' then
            exports['ox_lib']:hideContext()
        end
    end
end

-- Fonctions universelles pour les dialogues (client)
function Framework.OpenDialog(data, onSubmit, onCancel)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        Framework.Object.UI.Menu.Open('dialog', GetCurrentResourceName(), data.name, {
            title = data.title
        }, onSubmit, onCancel)
    elseif Config.Framework == 'qbcore' then
        if GetResourceState('ox_lib') == 'started' then
            local input = exports['ox_lib']:inputDialog(data.title, {
                {type = 'input', label = data.title, placeholder = data.placeholder or '', required = true}
            })
            if input and input[1] then
                onSubmit({value = input[1]}, {close = function() end})
            else
                if onCancel then onCancel({}, {close = function() end}) end
            end
        elseif GetResourceState('qb-input') == 'started' then
            local dialog = exports['qb-input']:ShowInput({
                header = data.title,
                submitText = "Confirmer",
                inputs = {
                    {
                        text = data.title,
                        name = "input",
                        type = "text",
                        isRequired = true
                    }
                }
            })
            if dialog and dialog.input then
                onSubmit({value = dialog.input}, {close = function() end})
            else
                if onCancel then onCancel({}, {close = function() end}) end
            end
        end
    end
end

-- Vérification des permissions
function Framework.HasPermission(xPlayer, permission)
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        if permission == 'admin' then
            return Framework.GetPlayerGroup(xPlayer) == 'admin'
        end
        return Framework.GetPlayerGroup(xPlayer) == permission
    elseif Config.Framework == 'qbcore' then
        if permission == 'admin' then
            return Framework.Object.Functions.HasPermission(Framework.GetPlayerIdentifier(xPlayer), 'admin') or 
                   xPlayer.PlayerData.job.name == 'police' and xPlayer.PlayerData.job.grade.level >= 4
        end
        return Framework.Object.Functions.HasPermission(Framework.GetPlayerIdentifier(xPlayer), permission)
    end
    return false
end

-- Fonction pour obtenir la table des items selon le framework
function Framework.GetItemsTable()
    if Config.Framework == 'esx' or Config.Framework == 'esx_legacy' then
        return 'items'
    elseif Config.Framework == 'qbcore' then
        return 'items' -- QBCore utilise aussi 'items' par défaut
    end
    return 'items'
end

-- Debug/Logs
function Framework.Log(message)
    print('[Farming Creator] [' .. string.upper(Config.Framework) .. '] ' .. message)
end

-- Initialisation automatique
if Config.Framework then
    Framework.Init()
    Framework.Log('Framework initialisé: ' .. Config.Framework)
else
    print('[Farming Creator] ERREUR: Aucun framework configuré!')
end