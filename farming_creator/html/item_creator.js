// ====================================
// FARMING CREATOR - ITEM CREATOR UI
// ====================================
// JavaScript pour l'interface moderne de création d'items

class ItemCreatorUI {
    constructor() {
        this.isVisible = false;
        this.currentTab = 'create';
        this.items = [];
        this.suggestions = [];
        this.stats = {};
        
        this.init();
    }
    
    init() {
        this.bindEvents();
        this.setupNUICallbacks();
        this.loadInitialData();
    }
    
    bindEvents() {
        // Fermeture de l'interface
        document.getElementById('closeBtn').addEventListener('click', () => {
            this.close();
        });
        
        // Navigation entre onglets
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.addEventListener('click', (e) => {
                const tabName = e.currentTarget.dataset.tab;
                this.switchTab(tabName);
            });
        });
        
        // Formulaire de création d'item
        document.getElementById('createItemForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.createItem();
        });
        
        // Bouton aperçu
        document.getElementById('previewBtn').addEventListener('click', () => {
            this.showPreview();
        });
        
        // Formulaire de suggestion
        document.getElementById('suggestItemForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.suggestItem();
        });
        
        // Recherche et filtres
        document.getElementById('searchItems').addEventListener('input', (e) => {
            this.filterItems(e.target.value);
        });
        
        document.getElementById('filterType').addEventListener('change', (e) => {
            this.filterItemsByType(e.target.value);
        });
        
        // Modal de prévisualisation
        document.querySelectorAll('.modal-close').forEach(btn => {
            btn.addEventListener('click', () => {
                this.closeModal();
            });
        });
        
        document.getElementById('confirmCreate').addEventListener('click', () => {
            this.confirmCreateItem();
        });
        
        // Fermeture modal avec ESC
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                if (!document.getElementById('previewModal').classList.contains('hidden')) {
                    this.closeModal();
                } else if (this.isVisible) {
                    this.close();
                }
            }
        });
        
        // Auto-nettoyage du nom d'item
        document.getElementById('itemName').addEventListener('input', (e) => {
            e.target.value = e.target.value.toLowerCase().replace(/[^a-z0-9_]/g, '');
        });
    }
    
    setupNUICallbacks() {
        // Écouter les messages NUI
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            switch (data.type) {
                case 'openItemCreator':
                    this.open();
                    break;
                case 'closeItemCreator':
                    this.close();
                    break;
                case 'updateItems':
                    this.updateItems(data.items);
                    break;
                case 'updateSuggestions':
                    this.updateSuggestions(data.suggestions);
                    break;
                case 'updateStats':
                    this.updateStats(data.stats);
                    break;
                case 'showNotification':
                    this.showNotification(data.message, data.type, data.duration);
                    break;
            }
        });
    }
    
    loadInitialData() {
        // Charger les données initiales
        this.sendNUIMessage('loadItems');
        this.sendNUIMessage('loadSuggestions');
        this.sendNUIMessage('loadStats');
    }
    
    open() {
        this.isVisible = true;
        document.getElementById('itemCreatorUI').classList.remove('hidden');
        document.body.style.overflow = 'hidden';
        
        // Recharger les données
        this.loadInitialData();
        
        // Focus sur le premier champ
        setTimeout(() => {
            document.getElementById('itemName').focus();
        }, 300);
    }
    
    close() {
        this.isVisible = false;
        document.getElementById('itemCreatorUI').classList.add('hidden');
        document.body.style.overflow = 'auto';
        
        // Réinitialiser les formulaires
        document.getElementById('createItemForm').reset();
        document.getElementById('suggestItemForm').reset();
        
        // Notifier le jeu
        this.sendNUIMessage('closeUI');
    }
    
    switchTab(tabName) {
        // Désactiver tous les onglets
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });
        
        // Activer l'onglet sélectionné
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
        document.getElementById(`${tabName}Tab`).classList.add('active');
        
        this.currentTab = tabName;
        
        // Charger les données spécifiques à l'onglet
        switch (tabName) {
            case 'manage':
                this.loadItems();
                break;
            case 'suggest':
                this.loadSuggestions();
                break;
            case 'stats':
                this.loadStats();
                break;
        }
    }
    
    createItem() {
        const formData = this.getFormData('createItemForm');
        
        if (!this.validateItemForm(formData)) {
            return;
        }
        
        // Préparer les données
        const itemData = {
            name: formData.itemName,
            label: formData.itemLabel,
            weight: parseInt(formData.itemWeight) || 1,
            description: formData.itemDescription,
            rare: formData.itemType !== 'normal',
            stackable: formData.itemStackable,
            usable: formData.itemUsable,
            can_remove: formData.itemRemovable
        };
        
        // Envoyer au serveur
        this.sendNUIMessage('createItem', itemData);
        
        // Afficher animation de chargement
        this.showLoadingState('createItemForm');
    }
    
    confirmCreateItem() {
        const formData = this.getFormData('createItemForm');
        
        const itemData = {
            name: formData.itemName,
            label: formData.itemLabel,
            weight: parseInt(formData.itemWeight) || 1,
            description: formData.itemDescription,
            rare: formData.itemType !== 'normal',
            stackable: formData.itemStackable,
            usable: formData.itemUsable,
            can_remove: formData.itemRemovable
        };
        
        this.sendNUIMessage('createItem', itemData);
        this.closeModal();
        
        // Réinitialiser le formulaire
        document.getElementById('createItemForm').reset();
    }
    
    suggestItem() {
        const formData = this.getFormData('suggestItemForm');
        
        if (!this.validateSuggestionForm(formData)) {
            return;
        }
        
        const suggestionData = {
            name: formData.suggestName,
            label: formData.suggestLabel,
            description: formData.suggestReason,
            weight: 1,
            rare: false,
            stackable: true,
            usable: false,
            can_remove: true
        };
        
        this.sendNUIMessage('suggestItem', suggestionData);
        
        // Réinitialiser le formulaire
        document.getElementById('suggestItemForm').reset();
    }
    
    showPreview() {
        const formData = this.getFormData('createItemForm');
        
        if (!formData.itemName || !formData.itemLabel) {
            this.showNotification('Veuillez remplir au moins le nom et le label de l\'item', 'warning');
            return;
        }
        
        // Remplir l'aperçu
        document.getElementById('previewName').textContent = formData.itemName;
        document.getElementById('previewLabel').textContent = formData.itemLabel;
        document.getElementById('previewWeight').textContent = formData.itemWeight || 1;
        document.getElementById('previewType').textContent = this.getTypeLabel(formData.itemType);
        
        const description = formData.itemDescription || 'Aucune description fournie';
        document.getElementById('previewDescription').textContent = description;
        
        // Options
        const optionsContainer = document.getElementById('previewOptions');
        optionsContainer.innerHTML = '';
        
        if (formData.itemStackable) {
            optionsContainer.innerHTML += '<div class="option-tag"><i class="fas fa-layer-group"></i> Empilable</div>';
        }
        
        if (formData.itemUsable) {
            optionsContainer.innerHTML += '<div class="option-tag"><i class="fas fa-hand-pointer"></i> Utilisable</div>';
        }
        
        if (formData.itemRemovable) {
            optionsContainer.innerHTML += '<div class="option-tag"><i class="fas fa-trash"></i> Supprimable</div>';
        }
        
        // Afficher la modal
        document.getElementById('previewModal').classList.remove('hidden');
    }
    
    closeModal() {
        document.getElementById('previewModal').classList.add('hidden');
    }
    
    getFormData(formId) {
        const form = document.getElementById(formId);
        const formData = new FormData(form);
        const data = {};
        
        // Récupérer tous les champs
        const inputs = form.querySelectorAll('input, select, textarea');
        inputs.forEach(input => {
            if (input.type === 'checkbox') {
                data[input.id] = input.checked;
            } else {
                data[input.id] = input.value;
            }
        });
        
        return data;
    }
    
    validateItemForm(data) {
        if (!data.itemName) {
            this.showNotification('Le nom de l\'item est requis', 'error');
            return false;
        }
        
        if (!data.itemLabel) {
            this.showNotification('Le label de l\'item est requis', 'error');
            return false;
        }
        
        if (data.itemName.length < 3) {
            this.showNotification('Le nom de l\'item doit faire au moins 3 caractères', 'error');
            return false;
        }
        
        return true;
    }
    
    validateSuggestionForm(data) {
        if (!data.suggestName) {
            this.showNotification('Le nom suggéré est requis', 'error');
            return false;
        }
        
        if (!data.suggestLabel) {
            this.showNotification('Le label suggéré est requis', 'error');
            return false;
        }
        
        if (!data.suggestReason) {
            this.showNotification('Une justification est requise', 'error');
            return false;
        }
        
        return true;
    }
    
    getTypeLabel(type) {
        const types = {
            normal: 'Normal',
            rare: 'Rare',
            epic: 'Épique',
            legendary: 'Légendaire'
        };
        return types[type] || 'Normal';
    }
    
    getTypeColor(type) {
        const colors = {
            normal: '#8B949E',
            rare: '#1F6FEB',
            epic: '#D29922',
            legendary: '#DA3633'
        };
        return colors[type] || '#8B949E';
    }
    
    updateItems(items) {
        this.items = items;
        this.renderItems();
    }
    
    updateSuggestions(suggestions) {
        this.suggestions = suggestions;
        this.renderSuggestions();
    }
    
    updateStats(stats) {
        this.stats = stats;
        this.renderStats();
    }
    
    renderItems() {
        const container = document.getElementById('itemsList');
        
        if (this.items.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-cube"></i>
                    <h3>Aucun item créé</h3>
                    <p>Commencez par créer votre premier item personnalisé</p>
                </div>
            `;
            return;
        }
        
        container.innerHTML = this.items.map(item => `
            <div class="item-card" onclick="itemCreatorUI.showItemDetails('${item.id}')">
                <div class="item-header">
                    <div class="item-icon">
                        <i class="fas fa-cube"></i>
                    </div>
                    <div>
                        <div class="item-name">${item.label}</div>
                        <div class="item-label">${item.name}</div>
                    </div>
                </div>
                
                <div class="item-properties">
                    <div class="item-property">
                        <i class="fas fa-weight-hanging"></i>
                        ${item.weight}
                    </div>
                    <div class="item-property" style="color: ${this.getTypeColor(item.rare ? 'rare' : 'normal')}">
                        <i class="fas fa-star"></i>
                        ${item.rare ? 'Rare' : 'Normal'}
                    </div>
                    ${item.stackable ? '<div class="item-property"><i class="fas fa-layer-group"></i> Empilable</div>' : ''}
                    ${item.usable ? '<div class="item-property"><i class="fas fa-hand-pointer"></i> Utilisable</div>' : ''}
                </div>
                
                ${item.description ? `<div class="item-description">${item.description}</div>` : ''}
                
                <div class="item-footer">
                    <small style="color: var(--text-muted)">
                        Par: ${item.creator} • ${this.formatDate(item.createdAt)}
                    </small>
                </div>
            </div>
        `).join('');
    }
    
    renderSuggestions() {
        const container = document.getElementById('mySuggestions');
        
        if (this.suggestions.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-lightbulb"></i>
                    <h3>Aucune suggestion</h3>
                    <p>Vos suggestions d'items apparaîtront ici</p>
                </div>
            `;
            return;
        }
        
        container.innerHTML = this.suggestions.map(suggestion => `
            <div class="suggestion-card">
                <div class="suggestion-header">
                    <strong>${suggestion.label}</strong>
                    <small style="color: var(--text-muted); font-family: monospace;">${suggestion.name}</small>
                </div>
                <div class="suggestion-description" style="margin: 8px 0; font-size: 14px; color: var(--text-secondary);">
                    ${suggestion.description}
                </div>
                <div class="suggestion-footer" style="font-size: 12px; color: var(--text-muted);">
                    Suggéré le ${this.formatDate(suggestion.createdAt)}
                </div>
            </div>
        `).join('');
    }
    
    renderStats() {
        // Mettre à jour les cartes de statistiques
        document.getElementById('totalItems').textContent = this.stats.totalItems || 0;
        document.getElementById('totalSuggestions').textContent = this.stats.totalSuggestions || 0;
        document.getElementById('totalWeight').textContent = this.stats.totalWeight || 0;
        document.getElementById('totalCreators').textContent = this.stats.totalCreators || 0;
        
        // Ici on pourrait ajouter des graphiques avec Chart.js ou similaire
        this.updateCharts();
    }
    
    updateCharts() {
        // Placeholder pour les graphiques
        const typeChart = document.getElementById('typeChart');
        const timeChart = document.getElementById('timeChart');
        
        // Simulation de données pour les graphiques
        typeChart.innerHTML = `
            <div class="chart-info">
                <div style="display: flex; justify-content: space-around; align-items: center; height: 100%;">
                    <div style="text-align: center;">
                        <div style="font-size: 24px; font-weight: bold; color: var(--accent-primary);">${this.stats.normalItems || 0}</div>
                        <div style="font-size: 12px; color: var(--text-muted);">Normal</div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 24px; font-weight: bold; color: var(--accent-secondary);">${this.stats.rareItems || 0}</div>
                        <div style="font-size: 12px; color: var(--text-muted);">Rare</div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 24px; font-weight: bold; color: var(--accent-warning);">${this.stats.epicItems || 0}</div>
                        <div style="font-size: 12px; color: var(--text-muted);">Épique</div>
                    </div>
                </div>
            </div>
        `;
        
        timeChart.innerHTML = `
            <div class="chart-info">
                <div style="display: flex; align-items: center; justify-content: center; height: 100%; flex-direction: column;">
                    <i class="fas fa-chart-line" style="font-size: 48px; color: var(--accent-primary); margin-bottom: 16px; opacity: 0.5;"></i>
                    <div style="color: var(--text-muted); text-align: center;">
                        Graphique d'évolution temporelle<br>
                        <small>Disponible prochainement</small>
                    </div>
                </div>
            </div>
        `;
    }
    
    filterItems(searchTerm) {
        const filteredItems = this.items.filter(item => 
            item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.label.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.description.toLowerCase().includes(searchTerm.toLowerCase())
        );
        
        this.renderFilteredItems(filteredItems);
    }
    
    filterItemsByType(type) {
        if (type === 'all') {
            this.renderItems();
            return;
        }
        
        const filteredItems = this.items.filter(item => {
            if (type === 'rare') return item.rare;
            if (type === 'normal') return !item.rare;
            return true;
        });
        
        this.renderFilteredItems(filteredItems);
    }
    
    renderFilteredItems(items) {
        const container = document.getElementById('itemsList');
        
        if (items.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-search"></i>
                    <h3>Aucun résultat</h3>
                    <p>Aucun item ne correspond à vos critères de recherche</p>
                </div>
            `;
            return;
        }
        
        // Utiliser la même logique de rendu que renderItems mais avec les items filtrés
        const originalItems = this.items;
        this.items = items;
        this.renderItems();
        this.items = originalItems;
    }
    
    showItemDetails(itemId) {
        const item = this.items.find(i => i.id == itemId);
        if (!item) return;
        
        // Créer une modal pour les détails
        const detailsHTML = `
            <div class="modal" id="itemDetailsModal">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3><i class="fas fa-info-circle"></i> Détails de l'item</h3>
                        <button class="modal-close" onclick="document.getElementById('itemDetailsModal').remove()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="item-preview">
                            <div class="item-preview-icon">
                                <i class="fas fa-cube"></i>
                            </div>
                            <div class="item-preview-details">
                                <div class="item-preview-name">${item.name}</div>
                                <div class="item-preview-label">${item.label}</div>
                                <div class="item-preview-properties">
                                    <div class="property">
                                        <i class="fas fa-weight-hanging"></i>
                                        <span>Poids: ${item.weight}</span>
                                    </div>
                                    <div class="property">
                                        <i class="fas fa-star"></i>
                                        <span>Type: ${item.rare ? 'Rare' : 'Normal'}</span>
                                    </div>
                                    <div class="property">
                                        <i class="fas fa-user"></i>
                                        <span>Créateur: ${item.creator}</span>
                                    </div>
                                    <div class="property">
                                        <i class="fas fa-calendar"></i>
                                        <span>Créé le: ${this.formatDate(item.createdAt)}</span>
                                    </div>
                                </div>
                                ${item.description ? `
                                    <div class="item-preview-description">${item.description}</div>
                                ` : ''}
                                <div class="item-preview-options">
                                    ${item.stackable ? '<div class="option-tag"><i class="fas fa-layer-group"></i> Empilable</div>' : ''}
                                    ${item.usable ? '<div class="option-tag"><i class="fas fa-hand-pointer"></i> Utilisable</div>' : ''}
                                    ${item.can_remove ? '<div class="option-tag"><i class="fas fa-trash"></i> Supprimable</div>' : ''}
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" onclick="document.getElementById('itemDetailsModal').remove()">Fermer</button>
                    </div>
                </div>
            </div>
        `;
        
        document.body.insertAdjacentHTML('beforeend', detailsHTML);
    }
    
    loadItems() {
        this.sendNUIMessage('loadItems');
    }
    
    loadSuggestions() {
        this.sendNUIMessage('loadSuggestions');
    }
    
    loadStats() {
        this.sendNUIMessage('loadStats');
    }
    
    showLoadingState(formId) {
        const form = document.getElementById(formId);
        const submitBtn = form.querySelector('button[type="submit"]');
        
        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Création en cours...';
            
            setTimeout(() => {
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="fas fa-plus"></i> Créer l\'item';
            }, 2000);
        }
    }
    
    showNotification(message, type = 'info', duration = 5000) {
        const container = document.getElementById('notifications');
        
        const notificationId = 'notification_' + Date.now();
        const icons = {
            success: 'fas fa-check-circle',
            error: 'fas fa-exclamation-circle',
            warning: 'fas fa-exclamation-triangle',
            info: 'fas fa-info-circle'
        };
        
        const notificationHTML = `
            <div class="notification ${type}" id="${notificationId}">
                <div class="notification-icon">
                    <i class="${icons[type] || icons.info}"></i>
                </div>
                <div class="notification-content">
                    <div class="notification-title">${this.getNotificationTitle(type)}</div>
                    <div class="notification-message">${message}</div>
                </div>
                <button class="notification-close" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `;
        
        container.insertAdjacentHTML('beforeend', notificationHTML);
        
        // Auto-suppression
        setTimeout(() => {
            const notification = document.getElementById(notificationId);
            if (notification) {
                notification.style.animation = 'notificationSlide 0.3s ease reverse';
                setTimeout(() => notification.remove(), 300);
            }
        }, duration);
    }
    
    getNotificationTitle(type) {
        const titles = {
            success: 'Succès',
            error: 'Erreur',
            warning: 'Attention',
            info: 'Information'
        };
        return titles[type] || 'Information';
    }
    
    formatDate(dateString) {
        if (!dateString) return 'Date inconnue';
        
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString('fr-FR', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        } catch (e) {
            return 'Date invalide';
        }
    }
    
    sendNUIMessage(type, data = {}) {
        // Envoyer un message au client FiveM/NUI
        if (window.invokeNative) {
            // FiveM environment
            fetch(`https://${GetParentResourceName()}/${type}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify(data)
            });
        } else {
            // Development environment
            console.log('NUI Message:', type, data);
        }
    }
}

// Initialiser l'interface
const itemCreatorUI = new ItemCreatorUI();

// Fonctions globales pour les événements onclick
window.itemCreatorUI = itemCreatorUI;

// Debugging helpers pour le développement
if (!window.invokeNative) {
    // Mode développement - simuler des données
    setTimeout(() => {
        itemCreatorUI.updateItems([
            {
                id: 1,
                name: 'potion_magique',
                label: 'Potion Magique',
                weight: 2,
                rare: true,
                stackable: true,
                usable: true,
                can_remove: true,
                description: 'Une potion mystérieuse aux pouvoirs inconnus',
                creator: 'TestPlayer',
                createdAt: new Date().toISOString()
            },
            {
                id: 2,
                name: 'epic_sword',
                label: 'Épée Légendaire',
                weight: 5,
                rare: true,
                stackable: false,
                usable: true,
                can_remove: true,
                description: 'Une épée forgée par les dieux',
                creator: 'AdminTest',
                createdAt: new Date(Date.now() - 86400000).toISOString()
            }
        ]);
        
        itemCreatorUI.updateStats({
            totalItems: 15,
            totalSuggestions: 3,
            totalWeight: 45,
            totalCreators: 5,
            normalItems: 12,
            rareItems: 3,
            epicItems: 0
        });
    }, 1000);
}