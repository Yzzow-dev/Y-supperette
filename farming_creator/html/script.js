let cropTypes = {};
let isMenuOpen = false;

// Éléments DOM
const container = document.getElementById('container');
const farmForm = document.getElementById('farmForm');
const cropTypeSelect = document.getElementById('cropType');
const farmNameInput = document.getElementById('farmName');
const farmSizeInput = document.getElementById('farmSize');
const farmSpacingInput = document.getElementById('farmSpacing');
const closeBtn = document.getElementById('closeBtn');
const cancelBtn = document.getElementById('cancelBtn');

// Éléments de prévisualisation
const previewTitle = document.getElementById('previewTitle');
const growTime = document.getElementById('growTime');
const seedPrice = document.getElementById('seedPrice');
const sellPrice = document.getElementById('sellPrice');
const harvestAmount = document.getElementById('harvestAmount');
const previewDescription = document.getElementById('previewDescription');
const totalPlants = document.getElementById('totalPlants');
const totalArea = document.getElementById('totalArea');
const gridPreview = document.getElementById('gridPreview');

// Initialisation
document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    updateSizePreview();
});

// Configuration des event listeners
function setupEventListeners() {
    // Fermeture du menu
    closeBtn.addEventListener('click', closeMenu);
    cancelBtn.addEventListener('click', closeMenu);
    
    // Soumission du formulaire
    farmForm.addEventListener('submit', handleFormSubmit);
    
    // Changement de type de culture
    cropTypeSelect.addEventListener('change', updateCropPreview);
    
    // Changement de taille/espacement
    farmSizeInput.addEventListener('input', updateSizePreview);
    farmSpacingInput.addEventListener('input', updateSizePreview);
    
    // Fermeture avec Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && isMenuOpen) {
            closeMenu();
        }
    });
    
    // Empêcher la fermeture du menu en cliquant sur le contenu
    document.querySelector('.menu-container').addEventListener('click', function(e) {
        e.stopPropagation();
    });
    
    // Fermeture en cliquant sur le fond
    container.addEventListener('click', closeMenu);
}

// Communication avec FiveM
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openMenu':
            openMenu(data.crops);
            break;
        case 'closeMenu':
            closeMenu();
            break;
    }
});

// Ouverture du menu
function openMenu(crops) {
    cropTypes = crops;
    populateCropTypes();
    container.classList.remove('hidden');
    isMenuOpen = true;
    
    // Focus sur le premier champ
    setTimeout(() => {
        farmNameInput.focus();
    }, 100);
}

// Fermeture du menu
function closeMenu() {
    container.classList.add('hidden');
    isMenuOpen = false;
    resetForm();
    
    // Notifier FiveM
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Remplir la liste des types de cultures
function populateCropTypes() {
    cropTypeSelect.innerHTML = '<option value="">Sélectionnez une culture</option>';
    
    for (const [key, crop] of Object.entries(cropTypes)) {
        const option = document.createElement('option');
        option.value = key;
        option.textContent = crop.name;
        cropTypeSelect.appendChild(option);
    }
}

// Mise à jour de l'aperçu de la culture
function updateCropPreview() {
    const selectedType = cropTypeSelect.value;
    
    if (!selectedType || !cropTypes[selectedType]) {
        resetCropPreview();
        return;
    }
    
    const crop = cropTypes[selectedType];
    
    previewTitle.textContent = `Aperçu: ${crop.name}`;
    growTime.textContent = formatTime(crop.growTime);
    seedPrice.textContent = crop.seedPrice;
    sellPrice.textContent = crop.sellPrice;
    harvestAmount.textContent = `${crop.harvestAmount.min}-${crop.harvestAmount.max}`;
    previewDescription.textContent = crop.description;
    
    // Calculer la rentabilité
    const avgHarvest = (crop.harvestAmount.min + crop.harvestAmount.max) / 2;
    const profit = (avgHarvest * crop.sellPrice) - crop.seedPrice;
    const profitColor = profit > 0 ? '#4CAF50' : '#f44336';
    
    const profitInfo = document.createElement('div');
    profitInfo.className = 'stat';
    profitInfo.innerHTML = `
        <i class="fas fa-chart-line"></i>
        <span>Profit moyen: <strong style="color: ${profitColor}">${profit > 0 ? '+' : ''}${profit}$</strong></span>
    `;
    
    // Ajouter l'info de profit si elle n'existe pas déjà
    const existingProfit = document.querySelector('.preview-stats .stat:last-child');
    if (existingProfit && existingProfit.textContent.includes('Profit')) {
        existingProfit.replaceWith(profitInfo);
    } else {
        document.querySelector('.preview-stats').appendChild(profitInfo);
    }
}

// Réinitialiser l'aperçu de la culture
function resetCropPreview() {
    previewTitle.textContent = 'Aperçu de la culture';
    growTime.textContent = '-';
    seedPrice.textContent = '-';
    sellPrice.textContent = '-';
    harvestAmount.textContent = '-';
    previewDescription.textContent = 'Sélectionnez une culture pour voir les détails';
    
    // Supprimer l'info de profit
    const profitStat = document.querySelector('.preview-stats .stat:nth-child(5)');
    if (profitStat) {
        profitStat.remove();
    }
}

// Mise à jour de l'aperçu de la taille
function updateSizePreview() {
    const size = parseInt(farmSizeInput.value) || 5;
    const spacing = parseFloat(farmSpacingInput.value) || 2.0;
    
    const plantsCount = size * size;
    const areaSize = Math.round(((size - 1) * spacing) ** 2);
    
    totalPlants.textContent = plantsCount;
    totalArea.textContent = `${areaSize}m²`;
    
    updateGridPreview(size);
}

// Mise à jour de la grille de prévisualisation
function updateGridPreview(size) {
    gridPreview.innerHTML = '';
    gridPreview.style.gridTemplateColumns = `repeat(${size}, 1fr)`;
    
    for (let i = 0; i < size * size; i++) {
        const cell = document.createElement('div');
        cell.className = 'grid-cell';
        gridPreview.appendChild(cell);
    }
}

// Gestion de la soumission du formulaire
function handleFormSubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(farmForm);
    const name = farmNameInput.value.trim();
    const cropType = cropTypeSelect.value;
    const size = parseInt(farmSizeInput.value);
    const spacing = parseFloat(farmSpacingInput.value);
    
    // Validation
    if (!name) {
        showError('Veuillez entrer un nom pour la ferme');
        return;
    }
    
    if (!cropType) {
        showError('Veuillez sélectionner un type de culture');
        return;
    }
    
    if (size < 3 || size > 15) {
        showError('La taille doit être entre 3 et 15');
        return;
    }
    
    if (spacing < 1 || spacing > 5) {
        showError('L\'espacement doit être entre 1 et 5 mètres');
        return;
    }
    
    // Ajouter l'état de chargement
    const submitBtn = document.querySelector('.btn-primary');
    submitBtn.classList.add('loading');
    submitBtn.textContent = 'Création en cours...';
    
    // Envoyer les données à FiveM
    const farmData = {
        name: name,
        cropType: cropType,
        size: size,
        spacing: spacing
    };
    
    fetch(`https://${GetParentResourceName()}/createFarm`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(farmData)
    }).then(response => {
        if (response.ok) {
            closeMenu();
        } else {
            showError('Erreur lors de la création de la ferme');
        }
    }).catch(error => {
        console.error('Erreur:', error);
        showError('Erreur de communication avec le serveur');
    }).finally(() => {
        // Retirer l'état de chargement
        submitBtn.classList.remove('loading');
        submitBtn.innerHTML = '<i class="fas fa-plus"></i> Créer la ferme';
    });
}

// Afficher une erreur
function showError(message) {
    // Créer ou mettre à jour un élément d'erreur
    let errorElement = document.querySelector('.error-message');
    
    if (!errorElement) {
        errorElement = document.createElement('div');
        errorElement.className = 'error-message';
        errorElement.style.cssText = `
            background: rgba(244, 67, 54, 0.1);
            border: 1px solid rgba(244, 67, 54, 0.3);
            color: #f44336;
            padding: 10px 15px;
            border-radius: 8px;
            margin: 10px 0;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        `;
        
        const icon = document.createElement('i');
        icon.className = 'fas fa-exclamation-triangle';
        errorElement.appendChild(icon);
        
        const text = document.createElement('span');
        errorElement.appendChild(text);
        
        farmForm.insertBefore(errorElement, farmForm.firstChild);
    }
    
    errorElement.querySelector('span').textContent = message;
    errorElement.style.display = 'flex';
    
    // Faire disparaître l'erreur après 5 secondes
    setTimeout(() => {
        if (errorElement) {
            errorElement.style.display = 'none';
        }
    }, 5000);
}

// Réinitialiser le formulaire
function resetForm() {
    farmForm.reset();
    farmSizeInput.value = 5;
    farmSpacingInput.value = 2;
    resetCropPreview();
    updateSizePreview();
    
    // Cacher les messages d'erreur
    const errorElement = document.querySelector('.error-message');
    if (errorElement) {
        errorElement.style.display = 'none';
    }
}

// Formater le temps en minutes et secondes
function formatTime(milliseconds) {
    const totalSeconds = Math.floor(milliseconds / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    
    if (minutes > 0) {
        return `${minutes}m ${seconds}s`;
    } else {
        return `${seconds}s`;
    }
}

// Obtenir le nom de la ressource parent
function GetParentResourceName() {
    return window.location.hostname === '' ? 'farming_creator' : window.location.hostname;
}

// Fonctions d'aide pour le développement
if (window.location.hostname === '' || window.location.hostname === 'localhost') {
    // Mode développement - simuler des données de test
    console.log('Mode développement activé');
    
    // Simuler l'ouverture du menu avec des données de test
    setTimeout(() => {
        const testCrops = {
            orange: {
                name: 'Orangers',
                description: 'Plantation d\'orangers',
                growTime: 300000,
                harvestAmount: {min: 3, max: 8},
                seedPrice: 50,
                sellPrice: 15
            },
            apple: {
                name: 'Pommiers',
                description: 'Plantation de pommiers',
                growTime: 240000,
                harvestAmount: {min: 4, max: 10},
                seedPrice: 45,
                sellPrice: 12
            }
        };
        
        openMenu(testCrops);
    }, 1000);
}

// Animation d'entrée pour les éléments
function animateIn(element) {
    element.style.opacity = '0';
    element.style.transform = 'translateY(20px)';
    
    setTimeout(() => {
        element.style.transition = 'all 0.3s ease';
        element.style.opacity = '1';
        element.style.transform = 'translateY(0)';
    }, 10);
}

// Ajouter des effets visuels pour améliorer l'UX
document.addEventListener('DOMContentLoaded', function() {
    // Animer les éléments du formulaire
    const formElements = document.querySelectorAll('.form-group, .crop-preview, .size-preview');
    formElements.forEach((element, index) => {
        setTimeout(() => {
            animateIn(element);
        }, index * 100);
    });
});