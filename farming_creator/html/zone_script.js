let zoneColors = [];
let selectedColor = null;
let isZoneMenuOpen = false;
let itemCategories = [];
let currentTab = 'zone';

// Éléments DOM
const zoneContainer = document.getElementById('zone-container');
const zoneForm = document.getElementById('zoneForm');
const itemForm = document.getElementById('itemForm');
const zoneCloseBtn = document.getElementById('zoneCloseBtn');
const zoneCancelBtn = document.getElementById('zoneCancelBtn');
const itemCancelBtn = document.getElementById('itemCancelBtn');

// Champs du formulaire
const zoneName = document.getElementById('zoneName');
const zoneLabel = document.getElementById('zoneLabel');
const zoneDescription = document.getElementById('zoneDescription');
const zoneRadius = document.getElementById('zoneRadius');
const zoneDensity = document.getElementById('zoneDensity');
const colorGrid = document.getElementById('colorGrid');
const blipSprite = document.getElementById('blipSprite');
const showMarkers = document.getElementById('showMarkers');
const harvestItem = document.getElementById('harvestItem');
const harvestAmount = document.getElementById('harvestAmount');
const growTime = document.getElementById('growTime');
const requireSeeds = document.getElementById('requireSeeds');
const accessType = document.getElementById('accessType');
const allowedJob = document.getElementById('allowedJob');
const allowedGang = document.getElementById('allowedGang');

// Éléments de prévisualisation
const zoneArea = document.getElementById('zoneArea');
const estimatedPoints = document.getElementById('estimatedPoints');
const radiusVisual = document.getElementById('radiusVisual');
const jobSelector = document.getElementById('jobSelector');
const gangSelector = document.getElementById('gangSelector');

// Éléments du formulaire d'items
const itemName = document.getElementById('itemName');
const itemLabel = document.getElementById('itemLabel');
const itemDescription = document.getElementById('itemDescription');
const itemCategory = document.getElementById('itemCategory');
const itemWeight = document.getElementById('itemWeight');
const itemRare = document.getElementById('itemRare');
const itemUsable = document.getElementById('itemUsable');
const itemRemovable = document.getElementById('itemRemovable');
const itemShouldClose = document.getElementById('itemShouldClose');
const itemUsageType = document.getElementById('itemUsageType');

// Éléments de configuration d'usage
const seedConfig = document.getElementById('seedConfig');
const harvestConfig = document.getElementById('harvestConfig');
const seedPrice = document.getElementById('seedPrice');
const seedGrowTime = document.getElementById('seedGrowTime');
const harvestSellPrice = document.getElementById('harvestSellPrice');
const harvestQuantity = document.getElementById('harvestQuantity');

// Éléments de prévisualisation d'item
const previewLabel = document.getElementById('previewLabel');
const previewName = document.getElementById('previewName');
const previewWeight = document.getElementById('previewWeight');
const previewRarity = document.getElementById('previewRarity');
const previewDescription = document.getElementById('previewDescription');

// Initialisation
document.addEventListener('DOMContentLoaded', function() {
    setupZoneEventListeners();
    setupItemEventListeners();
    setupTabSystem();
    updateZonePreview();
    updateItemPreview();
});

// Configuration des event listeners
function setupZoneEventListeners() {
    // Fermeture du menu
    zoneCloseBtn.addEventListener('click', closeZoneMenu);
    zoneCancelBtn.addEventListener('click', closeZoneMenu);
    
    // Soumission du formulaire
    zoneForm.addEventListener('submit', handleZoneFormSubmit);
    
    // Changements de valeurs
    zoneRadius.addEventListener('input', updateZonePreview);
    zoneDensity.addEventListener('change', updateZonePreview);
    accessType.addEventListener('change', updateAccessTypeDisplay);
    
    // Fermeture avec Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && isZoneMenuOpen) {
            closeZoneMenu();
        }
    });
    
    // Empêcher la fermeture du menu en cliquant sur le contenu
    document.querySelector('.zone-menu-container').addEventListener('click', function(e) {
        e.stopPropagation();
    });
    
    // Fermeture en cliquant sur le fond
    zoneContainer.addEventListener('click', closeZoneMenu);
}

// Configuration des event listeners pour les items
function setupItemEventListeners() {
    // Fermeture du menu
    itemCancelBtn.addEventListener('click', closeZoneMenu);
    
    // Soumission du formulaire d'item
    itemForm.addEventListener('submit', handleItemFormSubmit);
    
    // Mise à jour de l'aperçu en temps réel
    itemName.addEventListener('input', updateItemPreview);
    itemLabel.addEventListener('input', updateItemPreview);
    itemDescription.addEventListener('input', updateItemPreview);
    itemWeight.addEventListener('input', updateItemPreview);
    itemRare.addEventListener('change', updateItemPreview);
    
    // Gestion du type d'usage farming
    itemUsageType.addEventListener('change', updateUsageConfig);
    
    // Validation du nom de l'item
    itemName.addEventListener('input', validateItemName);
}

// Configuration du système d'onglets
function setupTabSystem() {
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const targetTab = this.dataset.tab;
            
            // Mettre à jour les boutons actifs
            tabBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            // Mettre à jour le contenu actif
            tabContents.forEach(content => {
                content.classList.remove('active');
            });
            
            const targetContent = document.getElementById(`tab-${targetTab}`);
            if (targetContent) {
                targetContent.classList.add('active');
                currentTab = targetTab;
            }
        });
    });
}

// Communication avec FiveM
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openZoneMenu':
            openZoneMenu(data.colors, data.categories);
            break;
        case 'closeZoneMenu':
            closeZoneMenu();
            break;
    }
});

// Ouverture du menu des zones
function openZoneMenu(colors, categories) {
    zoneColors = colors || [
        {name: "Vert", color: 2},
        {name: "Bleu", color: 3},
        {name: "Jaune", color: 5},
        {name: "Rouge", color: 6},
        {name: "Orange", color: 17},
        {name: "Violet", color: 27},
        {name: "Rose", color: 7}
    ];
    
    itemCategories = categories || [
        {name: "Nourriture", value: "food"},
        {name: "Graines", value: "seeds"},
        {name: "Outils", value: "tools"},
        {name: "Matériaux", value: "materials"},
        {name: "Récoltes", value: "harvest"},
        {name: "Autres", value: "other"}
    ];
    
    createColorGrid();
    populateItemCategories();
    updateZonePreview();
    updateItemPreview();
    zoneContainer.classList.remove('hidden');
    isZoneMenuOpen = true;
    
    // Focus sur le premier champ selon l'onglet actif
    setTimeout(() => {
        if (currentTab === 'zone') {
            zoneName.focus();
        } else {
            itemName.focus();
        }
    }, 100);
}

// Fermeture du menu des zones
function closeZoneMenu() {
    zoneContainer.classList.add('hidden');
    isZoneMenuOpen = false;
    resetZoneForm();
    
    // Notifier FiveM
    fetch(`https://${GetParentResourceName()}/closeZoneMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(() => {
        // Ignore les erreurs en mode développement
    });
}

// Créer la grille de couleurs
function createColorGrid() {
    colorGrid.innerHTML = '';
    
    const colorMap = {
        2: '#4CAF50',    // Vert
        3: '#2196F3',    // Bleu
        5: '#FFEB3B',    // Jaune
        6: '#F44336',    // Rouge
        17: '#FF9800',   // Orange
        27: '#9C27B0',   // Violet
        7: '#E91E63'     // Rose
    };
    
    zoneColors.forEach((colorData, index) => {
        const colorOption = document.createElement('div');
        colorOption.className = 'color-option';
        colorOption.style.backgroundColor = colorMap[colorData.color] || '#888';
        colorOption.textContent = colorData.name;
        colorOption.dataset.color = colorData.color;
        
        if (index === 0) {
            colorOption.classList.add('selected');
            selectedColor = colorData.color;
        }
        
        colorOption.addEventListener('click', function() {
            document.querySelectorAll('.color-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            this.classList.add('selected');
            selectedColor = parseInt(this.dataset.color);
        });
        
        colorGrid.appendChild(colorOption);
    });
}

// Mise à jour de l'aperçu de la zone
function updateZonePreview() {
    const radius = parseInt(zoneRadius.value) || 50;
    const density = zoneDensity.value;
    
    // Calculer la surface (π × r²)
    const area = Math.round(Math.PI * radius * radius);
    zoneArea.textContent = `${area}m²`;
    
    // Estimer le nombre de points selon la densité
    let pointsMultiplier;
    switch(density) {
        case 'low': pointsMultiplier = 0.5; break;
        case 'medium': pointsMultiplier = 1.0; break;
        case 'high': pointsMultiplier = 1.8; break;
        default: pointsMultiplier = 1.0;
    }
    
    const estimatedPointsCount = Math.round((area / 100) * pointsMultiplier);
    estimatedPoints.textContent = `~${estimatedPointsCount}`;
    
    // Mettre à jour la visualisation du rayon
    updateRadiusVisualization(radius);
}

// Mise à jour de la visualisation du rayon
function updateRadiusVisualization(radius) {
    // Calculer l'échelle pour la visualisation (50m = taille normale)
    const scale = Math.min(1.2, radius / 50);
    const radiusCircle = radiusVisual.querySelector('.radius-circle');
    
    if (radiusCircle) {
        radiusCircle.style.transform = `translate(-50%, -50%) scale(${scale})`;
        
        // Changer la couleur selon la taille
        if (radius > 150) {
            radiusCircle.style.borderColor = '#f44336'; // Rouge pour très grand
        } else if (radius > 100) {
            radiusCircle.style.borderColor = '#ff9800'; // Orange pour grand
        } else if (radius > 50) {
            radiusCircle.style.borderColor = '#ffeb3b'; // Jaune pour moyen
        } else {
            radiusCircle.style.borderColor = '#4CAF50'; // Vert pour petit
        }
    }
}

// Mise à jour de l'affichage du type d'accès
function updateAccessTypeDisplay() {
    const accessValue = accessType.value;
    
    // Cacher tous les sélecteurs conditionnels
    jobSelector.classList.remove('show');
    gangSelector.classList.remove('show');
    
    // Afficher le sélecteur approprié
    setTimeout(() => {
        if (accessValue === 'job') {
            jobSelector.classList.add('show');
        } else if (accessValue === 'gang') {
            gangSelector.classList.add('show');
        }
    }, 50);
}

// Gestion de la soumission du formulaire
function handleZoneFormSubmit(e) {
    e.preventDefault();
    
    // Validation des champs
    const name = zoneName.value.trim();
    const radius = parseInt(zoneRadius.value);
    
    if (!name) {
        showZoneError('Veuillez entrer un nom pour la zone');
        return;
    }
    
    if (radius < 10 || radius > 200) {
        showZoneError('Le rayon doit être entre 10 et 200 mètres');
        return;
    }
    
    if (!selectedColor) {
        showZoneError('Veuillez sélectionner une couleur');
        return;
    }
    
    // Valider la quantité de récolte
    const harvestAmountValue = harvestAmount.value.trim();
    const harvestAmountRegex = /^\d+-\d+$/;
    if (!harvestAmountRegex.test(harvestAmountValue)) {
        showZoneError('Format de quantité invalide. Utilisez le format: min-max (ex: 2-5)');
        return;
    }
    
    // Validation conditionnelle pour les permissions
    if (accessType.value === 'job' && !allowedJob.value.trim()) {
        showZoneError('Veuillez spécifier le métier autorisé');
        return;
    }
    
    if (accessType.value === 'gang' && !allowedGang.value.trim()) {
        showZoneError('Veuillez spécifier le gang autorisé');
        return;
    }
    
    // Préparer les données
    const [minHarvest, maxHarvest] = harvestAmountValue.split('-').map(n => parseInt(n));
    
    const zoneData = {
        name: name,
        label: zoneLabel.value.trim() || name,
        description: zoneDescription.value.trim(),
        radius: radius,
        density: zoneDensity.value,
        color: selectedColor,
        blipSprite: parseInt(blipSprite.value),
        showMarkers: showMarkers.value === 'true',
        harvestItem: harvestItem.value.trim(),
        harvestAmount: {
            min: minHarvest,
            max: maxHarvest
        },
        growTime: parseInt(growTime.value) * 60000, // Convertir en millisecondes
        requireSeeds: requireSeeds.value === 'true',
        accessType: accessType.value,
        allowedJob: allowedJob.value.trim(),
        allowedGang: allowedGang.value.trim()
    };
    
    // Ajouter l'état de chargement
    const submitBtn = document.querySelector('.btn-primary');
    submitBtn.classList.add('loading');
    submitBtn.textContent = 'Création en cours...';
    
    // Envoyer les données à FiveM
    fetch(`https://${GetParentResourceName()}/createZone`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(zoneData)
    }).then(response => {
        if (response.ok) {
            showZoneSuccess('Zone créée avec succès!');
            setTimeout(() => {
                closeZoneMenu();
            }, 1500);
        } else {
            showZoneError('Erreur lors de la création de la zone');
        }
    }).catch(error => {
        console.error('Erreur:', error);
        showZoneError('Erreur de communication avec le serveur');
    }).finally(() => {
        // Retirer l'état de chargement
        submitBtn.classList.remove('loading');
        submitBtn.innerHTML = '<i class="fas fa-plus"></i> Créer la zone';
    });
}

// Afficher une erreur
function showZoneError(message) {
    removeExistingMessages();
    
    const errorElement = document.createElement('div');
    errorElement.className = 'error-message';
    errorElement.innerHTML = `<i class="fas fa-exclamation-triangle"></i><span>${message}</span>`;
    
    zoneForm.insertBefore(errorElement, zoneForm.firstChild);
    
    // Faire disparaître l'erreur après 5 secondes
    setTimeout(() => {
        if (errorElement.parentNode) {
            errorElement.remove();
        }
    }, 5000);
}

// Afficher un message de succès
function showZoneSuccess(message) {
    removeExistingMessages();
    
    const successElement = document.createElement('div');
    successElement.className = 'success-message';
    successElement.innerHTML = `<i class="fas fa-check-circle"></i><span>${message}</span>`;
    
    zoneForm.insertBefore(successElement, zoneForm.firstChild);
    
    // Faire disparaître le succès après 3 secondes
    setTimeout(() => {
        if (successElement.parentNode) {
            successElement.remove();
        }
    }, 3000);
}

// Supprimer les messages existants
function removeExistingMessages() {
    const existingMessages = zoneForm.querySelectorAll('.error-message, .success-message');
    existingMessages.forEach(msg => msg.remove());
}

// Réinitialiser le formulaire
function resetZoneForm() {
    zoneForm.reset();
    zoneRadius.value = 50;
    zoneDensity.value = 'medium';
    harvestItem.value = 'farmbox';
    harvestAmount.value = '1-3';
    growTime.value = 4;
    requireSeeds.value = 'false';
    accessType.value = 'public';
    showMarkers.value = 'true';
    blipSprite.value = '164';
    
    // Réinitialiser les sélecteurs conditionnels
    jobSelector.classList.remove('show');
    gangSelector.classList.remove('show');
    
    // Réinitialiser la sélection de couleur
    selectedColor = null;
    
    // Supprimer les messages
    removeExistingMessages();
    
    // Mettre à jour l'aperçu
    updateZonePreview();
}

// Obtenir le nom de la ressource parent
function GetParentResourceName() {
    return window.location.hostname === '' ? 'farming_creator' : window.location.hostname;
}

// Mode développement
if (window.location.hostname === '' || window.location.hostname === 'localhost') {
    console.log('Mode développement activé pour Zone Creator');
    
    // Simuler l'ouverture du menu avec des données de test
    setTimeout(() => {
        openZoneMenu();
    }, 1000);
}

// Animation d'entrée pour les sections
function animateZoneSections() {
    const sections = document.querySelectorAll('.form-section');
    sections.forEach((section, index) => {
        section.style.opacity = '0';
        section.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            section.style.transition = 'all 0.4s ease';
            section.style.opacity = '1';
            section.style.transform = 'translateY(0)';
        }, index * 150);
    });
}

// Appeler l'animation quand le menu s'ouvre
const originalOpenZoneMenu = openZoneMenu;
openZoneMenu = function(...args) {
    originalOpenZoneMenu.apply(this, args);
    setTimeout(animateZoneSections, 100);
};

// Validation en temps réel
function setupRealTimeValidation() {
    zoneRadius.addEventListener('input', function() {
        const value = parseInt(this.value);
        if (value < 10 || value > 200) {
            this.style.borderColor = '#f44336';
        } else {
            this.style.borderColor = '#4CAF50';
        }
    });
    
    harvestAmount.addEventListener('input', function() {
        const regex = /^\d+-\d+$/;
        if (!regex.test(this.value)) {
            this.style.borderColor = '#f44336';
        } else {
            this.style.borderColor = '#4CAF50';
        }
    });
}

// Appliquer la validation en temps réel
document.addEventListener('DOMContentLoaded', setupRealTimeValidation);

// ================================
// FONCTIONS POUR LA GESTION DES ITEMS
// ================================

// Remplir la liste des catégories d'items
function populateItemCategories() {
    itemCategory.innerHTML = '<option value="">Sélectionnez une catégorie</option>';
    
    itemCategories.forEach(category => {
        const option = document.createElement('option');
        option.value = category.value;
        option.textContent = category.name;
        itemCategory.appendChild(option);
    });
}

// Mise à jour de l'aperçu de l'item
function updateItemPreview() {
    const name = itemName.value.trim() || 'item_name';
    const label = itemLabel.value.trim() || 'Nom de l\'item';
    const description = itemDescription.value.trim() || 'Description de l\'item...';
    const weight = parseFloat(itemWeight.value) || 1;
    const rare = parseInt(itemRare.value) || 0;
    
    previewName.textContent = name;
    previewLabel.textContent = label;
    previewDescription.textContent = description;
    previewWeight.textContent = weight;
    previewRarity.textContent = rare === 1 ? 'Rare' : 'Commun';
}

// Validation du nom de l'item
function validateItemName() {
    const name = itemName.value.trim();
    let validation = itemName.parentNode.querySelector('.item-name-validation');
    
    if (!validation) {
        validation = document.createElement('div');
        validation.className = 'item-name-validation';
        itemName.parentNode.appendChild(validation);
    }
    
    if (name === '') {
        validation.style.display = 'none';
        return;
    }
    
    // Regex pour nom d'item valide (lettres, chiffres, underscore)
    const validRegex = /^[a-z0-9_]+$/;
    
    if (validRegex.test(name) && name.length >= 3) {
        validation.innerHTML = '<i class="fas fa-check"></i> Nom d\'item valide';
        validation.className = 'item-name-validation valid';
        itemName.style.borderColor = '#4CAF50';
    } else {
        validation.innerHTML = '<i class="fas fa-times"></i> Nom invalide (lettres minuscules, chiffres, underscore uniquement)';
        validation.className = 'item-name-validation invalid';
        itemName.style.borderColor = '#f44336';
    }
    
    validation.style.display = 'flex';
}

// Mise à jour de la configuration d'usage
function updateUsageConfig() {
    const usageType = itemUsageType.value;
    
    // Cacher toutes les configurations
    seedConfig.style.display = 'none';
    harvestConfig.style.display = 'none';
    
    // Afficher la configuration appropriée
    if (usageType === 'seed') {
        seedConfig.style.display = 'block';
    } else if (usageType === 'harvest') {
        harvestConfig.style.display = 'block';
    }
}

// Gestion de la soumission du formulaire d'item
function handleItemFormSubmit(e) {
    e.preventDefault();
    
    // Validation des champs
    const name = itemName.value.trim();
    const label = itemLabel.value.trim();
    
    if (!name) {
        showZoneError('Veuillez entrer un nom pour l\'item');
        return;
    }
    
    if (!label) {
        showZoneError('Veuillez entrer un label pour l\'item');
        return;
    }
    
    // Validation du nom d'item
    const validRegex = /^[a-z0-9_]+$/;
    if (!validRegex.test(name) || name.length < 3) {
        showZoneError('Le nom de l\'item doit contenir au moins 3 caractères (lettres minuscules, chiffres, underscore)');
        return;
    }
    
    if (!itemCategory.value) {
        showZoneError('Veuillez sélectionner une catégorie');
        return;
    }
    
    // Validation conditionnelle pour les quantités de récolte
    if (itemUsageType.value === 'harvest') {
        const quantityRegex = /^\d+-\d+$/;
        if (!quantityRegex.test(harvestQuantity.value)) {
            showZoneError('Format de quantité invalide. Utilisez le format: min-max (ex: 2-5)');
            return;
        }
    }
    
    // Préparer les données de l'item
    const itemData = {
        name: name,
        label: label,
        description: itemDescription.value.trim(),
        category: itemCategory.value,
        weight: parseFloat(itemWeight.value) || 1,
        rare: parseInt(itemRare.value) || 0,
        usable: parseInt(itemUsable.value) || 0,
        can_remove: parseInt(itemRemovable.value) || 1,
        shouldClose: parseInt(itemShouldClose.value) || 1,
        usageType: itemUsageType.value
    };
    
    // Ajouter les données spécifiques selon le type d'usage
    if (itemUsageType.value === 'seed') {
        itemData.farmingData = {
            type: 'seed',
            price: parseInt(seedPrice.value) || 25,
            growTime: parseInt(seedGrowTime.value) * 60000 // Convertir en millisecondes
        };
    } else if (itemUsageType.value === 'harvest') {
        const [minHarvest, maxHarvest] = harvestQuantity.value.split('-').map(n => parseInt(n));
        itemData.farmingData = {
            type: 'harvest',
            sellPrice: parseInt(harvestSellPrice.value) || 10,
            harvestAmount: {
                min: minHarvest,
                max: maxHarvest
            }
        };
    }
    
    // Ajouter l'état de chargement
    const submitBtn = itemForm.querySelector('.btn-primary');
    submitBtn.classList.add('loading');
    submitBtn.textContent = 'Création en cours...';
    
    // Envoyer les données à FiveM
    fetch(`https://${GetParentResourceName()}/createItem`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(itemData)
    }).then(response => {
        if (response.ok) {
            showZoneSuccess('Item créé avec succès!');
            showDiscordIndicator('Item envoyé vers Discord', 'success');
            
            // Animation de succès
            const previewCard = document.querySelector('.preview-card');
            previewCard.classList.add('item-created-animation');
            
            setTimeout(() => {
                previewCard.classList.remove('item-created-animation');
                resetItemForm();
            }, 1500);
        } else {
            showZoneError('Erreur lors de la création de l\'item');
        }
    }).catch(error => {
        console.error('Erreur:', error);
        showZoneError('Erreur de communication avec le serveur');
    }).finally(() => {
        // Retirer l'état de chargement
        submitBtn.classList.remove('loading');
        submitBtn.innerHTML = '<i class="fas fa-plus"></i> Créer l\'item';
    });
}

// Afficher l'indicateur Discord
function showDiscordIndicator(message, type = 'info') {
    // Supprimer l'indicateur existant s'il y en a un
    const existingIndicator = document.querySelector('.discord-indicator');
    if (existingIndicator) {
        existingIndicator.remove();
    }
    
    const indicator = document.createElement('div');
    indicator.className = `discord-indicator ${type}`;
    indicator.innerHTML = `<i class="fab fa-discord"></i><span>${message}</span>`;
    
    document.body.appendChild(indicator);
    
    // Afficher l'indicateur
    setTimeout(() => {
        indicator.classList.add('show');
    }, 100);
    
    // Masquer après 3 secondes
    setTimeout(() => {
        indicator.classList.remove('show');
        setTimeout(() => {
            indicator.remove();
        }, 300);
    }, 3000);
}

// Réinitialiser le formulaire d'item
function resetItemForm() {
    itemForm.reset();
    itemWeight.value = 1;
    itemRare.value = 0;
    itemUsable.value = 0;
    itemRemovable.value = 1;
    itemShouldClose.value = 1;
    itemUsageType.value = 'none';
    seedPrice.value = 25;
    seedGrowTime.value = 5;
    harvestSellPrice.value = 10;
    harvestQuantity.value = '1-3';
    
    // Cacher les configurations d'usage
    seedConfig.style.display = 'none';
    harvestConfig.style.display = 'none';
    
    // Supprimer la validation du nom
    const validation = itemName.parentNode.querySelector('.item-name-validation');
    if (validation) {
        validation.remove();
    }
    
    // Réinitialiser les styles
    itemName.style.borderColor = '';
    
    // Mettre à jour l'aperçu
    updateItemPreview();
}