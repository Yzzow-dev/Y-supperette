local ESX = nil
local farms = {}
local creatingFarm = false
local selectedCropType = nil
local nearbyFarms = {}
local playerCoords = nil

-- Initialisation ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    
    PlayerData = ESX.GetPlayerData()
    
    -- Charger les fermes existantes
    TriggerServerEvent('farming:loadFarms')
end)

-- Events
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    TriggerServerEvent('farming:loadFarms')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('farming:receiveFarms')
AddEventHandler('farming:receiveFarms', function(serverFarms)
    farms = serverFarms
    CreateFarmBlips()
end)

RegisterNetEvent('farming:farmCreated')
AddEventHandler('farming:farmCreated', function(farm)
    farms[#farms + 1] = farm
    CreateFarmBlips()
    ESX.ShowNotification(Config.Messages['farm_created'])
end)

RegisterNetEvent('farming:farmDeleted')
AddEventHandler('farming:farmDeleted', function(farmId)
    for i, farm in ipairs(farms) do
        if farm.id == farmId then
            RemoveBlip(farm.blip)
            table.remove(farms, i)
            break
        end
    end
    ESX.ShowNotification(Config.Messages['farm_deleted'])
end)

RegisterNetEvent('farming:cropHarvested')
AddEventHandler('farming:cropHarvested', function(farmId, plantId)
    for _, farm in ipairs(farms) do
        if farm.id == farmId then
            for _, plant in ipairs(farm.plants) do
                if plant.id == plantId then
                    plant.harvestTime = nil
                    plant.planted = false
                    if plant.object then
                        DeleteObject(plant.object)
                        plant.object = nil
                    end
                    break
                end
            end
            break
        end
    end
end)

RegisterNetEvent('farming:cropPlanted')
AddEventHandler('farming:cropPlanted', function(farmId, plantData)
    for _, farm in ipairs(farms) do
        if farm.id == farmId then
            for _, plant in ipairs(farm.plants) do
                if plant.id == plantData.id then
                    plant.planted = true
                    plant.harvestTime = plantData.harvestTime
                    CreateCropObject(farm, plant)
                    break
                end
            end
            break
        end
    end
end)

-- Commandes
RegisterCommand(Config.Commands.farmingMenu, function(source, args, rawCommand)
    if Config.UsePermissions then
        ESX.TriggerServerCallback('farming:hasPermission', function(hasPermission)
            if hasPermission then
                OpenFarmingMenu()
            else
                ESX.ShowNotification(Config.Messages['no_permission'])
            end
        end)
    else
        OpenFarmingMenu()
    end
end, false)

RegisterCommand(Config.Commands.deleteFarm, function(source, args, rawCommand)
    if Config.UsePermissions then
        ESX.TriggerServerCallback('farming:hasPermission', function(hasPermission)
            if hasPermission then
                DeleteNearestFarm()
            else
                ESX.ShowNotification(Config.Messages['no_permission'])
            end
        end)
    else
        DeleteNearestFarm()
    end
end, false)

-- Fonctions principales
function OpenFarmingMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openMenu',
        crops = Config.CropTypes
    })
end

function CreateFarm(name, cropType, size, spacing)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    if not Config.CropTypes[cropType] then
        ESX.ShowNotification(Config.Messages['invalid_crop_type'])
        return
    end
    
    local farmData = {
        name = name,
        cropType = cropType,
        coords = coords,
        size = size,
        spacing = spacing,
        owner = GetPlayerServerId(PlayerId())
    }
    
    TriggerServerEvent('farming:createFarm', farmData)
end

function DeleteNearestFarm()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestFarm = nil
    local closestDistance = math.huge
    
    for _, farm in ipairs(farms) do
        local distance = #(coords - vector3(farm.coords.x, farm.coords.y, farm.coords.z))
        if distance < closestDistance and distance < 10.0 then
            closestDistance = distance
            closestFarm = farm
        end
    end
    
    if closestFarm then
        TriggerServerEvent('farming:deleteFarm', closestFarm.id)
    else
        ESX.ShowNotification(Config.Messages['farm_not_found'])
    end
end

function CreateFarmBlips()
    -- Supprimer les anciens blips
    for _, farm in ipairs(farms) do
        if farm.blip then
            RemoveBlip(farm.blip)
        end
    end
    
    -- Créer les nouveaux blips
    for _, farm in ipairs(farms) do
        local cropConfig = Config.CropTypes[farm.cropType]
        if cropConfig then
            local blip = AddBlipForCoord(farm.coords.x, farm.coords.y, farm.coords.z)
            SetBlipSprite(blip, cropConfig.blip.sprite)
            SetBlipColour(blip, cropConfig.blip.color)
            SetBlipScale(blip, cropConfig.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(farm.name .. " (" .. cropConfig.name .. ")")
            EndTextCommandSetBlipName(blip)
            farm.blip = blip
        end
        
        -- Créer les objets de culture
        if farm.plants then
            for _, plant in ipairs(farm.plants) do
                if plant.planted and plant.harvestTime then
                    CreateCropObject(farm, plant)
                end
            end
        end
    end
end

function CreateCropObject(farm, plant)
    local cropConfig = Config.CropTypes[farm.cropType]
    if cropConfig and cropConfig.model then
        local hash = GetHashKey(cropConfig.model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end
        
        local object = CreateObject(hash, plant.coords.x, plant.coords.y, plant.coords.z, false, false, false)
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        plant.object = object
    end
end

function PlantCrop(farm, plantIndex)
    local cropConfig = Config.CropTypes[farm.cropType]
    if not cropConfig then return end
    
    ESX.TriggerServerCallback('farming:hasItem', function(hasSeeds)
        if hasSeeds then
            TriggerServerEvent('farming:plantCrop', farm.id, plantIndex)
        else
            ESX.ShowNotification(Config.Messages['no_seeds'])
        end
    end, cropConfig.seedItem)
end

function HarvestCrop(farm, plantIndex)
    local plant = farm.plants[plantIndex]
    if not plant or not plant.planted then
        ESX.ShowNotification(Config.Messages['not_planted'])
        return
    end
    
    if plant.harvestTime and GetGameTimer() < plant.harvestTime then
        local timeLeft = math.ceil((plant.harvestTime - GetGameTimer()) / 1000)
        ESX.ShowNotification('Récolte dans ' .. timeLeft .. ' secondes')
        return
    end
    
    TriggerServerEvent('farming:harvestCrop', farm.id, plantIndex)
end

-- Thread principal pour les interactions
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
        nearbyFarms = {}
        
        for _, farm in ipairs(farms) do
            local distance = #(playerCoords - vector3(farm.coords.x, farm.coords.y, farm.coords.z))
            if distance < Config.MarkerDistance then
                table.insert(nearbyFarms, farm)
                sleep = 0
            end
        end
        
        Citizen.Wait(sleep)
    end
end)

-- Thread pour afficher les marqueurs et gérer les interactions
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        
        if #nearbyFarms > 0 then
            sleep = 0
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            
            for _, farm in ipairs(nearbyFarms) do
                local cropConfig = Config.CropTypes[farm.cropType]
                if cropConfig and farm.plants then
                    for i, plant in ipairs(farm.plants) do
                        local distance = #(coords - vector3(plant.coords.x, plant.coords.y, plant.coords.z))
                        
                        if distance < 5.0 then
                            local marker = cropConfig.marker
                            DrawMarker(
                                marker.type,
                                plant.coords.x, plant.coords.y, plant.coords.z - 1.0,
                                0, 0, 0, 0, 0, 0,
                                marker.scale.x, marker.scale.y, marker.scale.z,
                                marker.r, marker.g, marker.b, marker.a,
                                false, true, 2, false, nil, nil, false
                            )
                            
                            if distance < Config.InteractionDistance then
                                if plant.planted then
                                    if plant.harvestTime and GetGameTimer() >= plant.harvestTime then
                                        ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour récolter')
                                        if IsControlJustReleased(0, 51) then -- E
                                            HarvestCrop(farm, i)
                                        end
                                    else
                                        local timeLeft = plant.harvestTime and math.ceil((plant.harvestTime - GetGameTimer()) / 1000) or 0
                                        ESX.ShowHelpNotification('Culture en croissance (' .. timeLeft .. 's)')
                                    end
                                else
                                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour planter')
                                    if IsControlJustReleased(0, 51) then -- E
                                        PlantCrop(farm, i)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)

-- NUI Callbacks
RegisterNUICallback('createFarm', function(data, cb)
    CreateFarm(data.name, data.cropType, data.size, data.spacing)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Cleanup au déchargement de la ressource
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, farm in ipairs(farms) do
            if farm.blip then
                RemoveBlip(farm.blip)
            end
            if farm.plants then
                for _, plant in ipairs(farm.plants) do
                    if plant.object then
                        DeleteObject(plant.object)
                    end
                end
            end
        end
    end
end)