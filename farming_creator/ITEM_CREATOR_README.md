# 🎯 Système de Création d'Items Personnalisés

## 📋 Description

Ce système permet de créer des items personnalisés directement en jeu avec :
- ✅ **Insertion automatique en base de données**
- ✅ **Logs Discord en temps réel**
- ✅ **Messages dans la console**
- ✅ **Système de suggestions pour le staff**
- ✅ **Interface graphique intuitive**
- ✅ **Permissions et limitations configurables**

---

## 🚀 Installation & Configuration

### 1. Configuration Discord

Dans le fichier `config.lua`, configurez votre webhook Discord :

```lua
Config.Discord = {
    enabled = true,
    webhook = "https://discord.com/api/webhooks/VOTRE_WEBHOOK_ICI", -- Remplacez par votre webhook
    serverName = "Farming Creator System",
    embedColor = 65280, -- Vert
    footerText = "Farming Creator",
    avatarURL = "https://i.imgur.com/YourImageHere.png" -- Optionnel
}
```

### 2. Configuration du système d'items

```lua
Config.CustomItems = {
    enabled = true,                    -- Activer/désactiver le système
    allowStaffSuggestions = true,      -- Permettre les suggestions
    autoInsertIntoDB = true,           -- Insertion automatique en BDD
    logToConsole = true,               -- Logs dans la console
    logToDiscord = true,               -- Logs sur Discord
    maxItemsPerPlayer = 50,            -- Limite d'items par joueur
}
```

### 3. Base de données

Le système créera automatiquement la table `custom_items_creator` au démarrage.

---

## 🎮 Utilisation

### Commandes disponibles

| Commande | Description | Permission |
|----------|-------------|------------|
| `/createitem` | Ouvre le menu de création d'item | Admin |
| `/itemmenu` | Menu de gestion des items | Admin |
| `/suggestitem` | Suggérer un item (staff) | Tous |

### Création d'un item

1. **Tapez `/createitem` en jeu**
2. **Remplissez les informations :**
   - Nom de l'item (sans espaces ni caractères spéciaux)
   - Label (nom affiché)
   - Poids
   - Description (optionnel)

3. **Le système automatiquement :**
   - Vérifie que l'item n'existe pas déjà
   - Insère l'item dans la table `items` d'ESX
   - Envoie un log Discord
   - Affiche un message dans la console
   - Notifie le joueur

### Exemple de création

```
Nom: potion_magique
Label: Potion Magique
Poids: 2
Description: Une potion mystérieuse aux pouvoirs inconnus
```

**Résultat dans la console :**
```
[Farming Creator] Item créé et inséré dans la table de données: potion_magique par PlayerName
```

**Log Discord automatique :**
- 📦 Nom de l'item: `potion_magique`
- 🏷️ Label: Potion Magique
- ⚖️ Poids: 2
- 👤 Créateur: PlayerName (license:xxxxx)
- 📝 Description: Une potion mystérieuse aux pouvoirs inconnus

---

## 📊 Fonctionnalités

### 🔐 Système de permissions
- Seuls les admins peuvent créer des items réels
- Tout le monde peut suggérer des items
- Limite configurable d'items par joueur

### 🎨 Interface intuitive
- Menus ESX natifs
- Navigation facile
- Validation des données
- Messages d'erreur clairs

### 📈 Statistiques
- Nombre d'items créés
- Poids total
- Items rares/utilisables
- Créateurs uniques

### 🔍 Gestion des suggestions
- Les joueurs peuvent suggérer des items
- Les admins peuvent consulter les suggestions
- Logs Discord séparés pour les suggestions

---

## 🛠️ Structure de la base de données

### Table `custom_items_creator`

```sql
CREATE TABLE custom_items_creator (
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
);
```

### Insertion automatique dans `items`

Chaque item créé est automatiquement inséré dans la table `items` d'ESX :

```sql
INSERT INTO items (name, label, weight, rare, can_remove) 
VALUES (?, ?, ?, ?, ?)
```

---

## 🎯 Exemples d'utilisation

### Créer un item de nourriture

```
Nom: burger_deluxe
Label: Burger Deluxe
Poids: 1
Description: Un burger gastronomique qui redonne 50% de santé
```

### Créer un outil

```
Nom: lockpick_advanced
Label: Crochet Avancé
Poids: 1
Description: Un crochet professionnel pour les serrures complexes
```

### Créer un item rare

```
Nom: diamant_noir
Label: Diamant Noir
Poids: 1
Description: Un diamant extrêmement rare et précieux
```

---

## 🔧 Configuration avancée

### Personnaliser les valeurs par défaut

```lua
Config.CustomItems.defaultValues = {
    weight = 1,           -- Poids par défaut
    rare = 0,            -- Item rare par défaut
    can_remove = 1,      -- Peut être supprimé
    stackable = true,    -- Empilable
    usable = false      -- Utilisable
}
```

### Messages personnalisés

Vous pouvez modifier tous les messages dans `Config.Messages` :

```lua
Config.Messages = {
    ['item_created'] = 'Item "{name}" créé avec succès!',
    ['item_suggestion_sent'] = 'Suggestion envoyée!',
    -- ... autres messages
}
```

---

## 🚨 Sécurité

### Validations automatiques
- ✅ Vérification des permissions
- ✅ Validation des noms d'items
- ✅ Nettoyage des caractères spéciaux
- ✅ Vérification des doublons
- ✅ Limitation du nombre d'items par joueur

### Logs de sécurité
- Tous les items créés sont tracés
- Logs Discord avec informations complètes
- Historique complet en base de données

---

## 🔄 Workflow complet

1. **Un staff a une idée d'item**
2. **Il tape `/createitem`**
3. **Il remplit le formulaire**
4. **Le système valide les données**
5. **L'item est créé et inséré en BDD**
6. **Un message apparaît dans la console**
7. **Un log est envoyé sur Discord**
8. **Tous les joueurs connectés sont notifiés**

---

## 📞 Support

Pour toute question ou problème :
1. Vérifiez la configuration Discord
2. Assurez-vous que MySQL fonctionne
3. Vérifiez les permissions ESX
4. Consultez les logs de la console

---

## 🎉 Conclusion

Ce système vous permet de créer facilement des items personnalisés avec un suivi complet et une intégration Discord professionnelle. Parfait pour les serveurs RP qui veulent un système d'items dynamique et traçable !

**Commandes récapitulatives :**
- `/createitem` - Créer un item (admin)
- `/itemmenu` - Gérer les items (admin)  
- `/suggestitem` - Suggérer un item (tous)

**Bon farming ! 🌾**