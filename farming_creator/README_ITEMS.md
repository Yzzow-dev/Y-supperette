# 🔧 Farming Creator - Création d'Items Personnalisés

Extension du système Farming Creator qui permet aux staff de créer des items personnalisés directement en jeu avec insertion automatique en base de données et logs Discord.

## ✨ Fonctionnalités

### 🎯 Création d'Items Staff
- **Interface intuitive** : Menu complet pour créer des items avec tous les paramètres
- **Validation en temps réel** : Vérification automatique des noms et formats
- **Aperçu instantané** : Visualisation de l'item avant création
- **Insertion automatique** : Ajout direct dans la table `items` de la base de données
- **Logs Discord** : Notifications automatiques avec embed détaillé
- **Logs console** : Affichage complet dans la console serveur

### 🛠️ Paramètres Configurables

#### 📋 Informations de Base
- **Nom de l'item** : ID technique (validation automatique)
- **Label affiché** : Nom visible dans l'inventaire
- **Description** : Description détaillée
- **Catégorie** : Classification (Nourriture, Graines, Outils, etc.)
- **Poids** : Poids de l'item (0-100kg)

#### ⚙️ Propriétés Techniques
- **Rareté** : Commun ou Rare
- **Utilisable** : Si l'item peut être utilisé
- **Supprimable** : Si l'item peut être jeté
- **Fermer inventaire** : Si l'inventaire se ferme après usage

#### 🚜 Usage Farming (Optionnel)
- **Graine** : Prix d'achat et temps de croissance
- **Récolte** : Prix de vente et quantité obtenue
- **Outil** : Outil de farming

## 📋 Commandes

### Nouvelle Commande Principale
```
/farmzone
```
Ouvre l'interface avec l'onglet "Items" pour créer des items personnalisés.

### Commandes de Gestion
```
/giveitem [nom_item] [quantité] [joueur_id]  - Donner un item créé
/giveseed [type] [quantité]                  - Donner des graines de base
```

## 🚀 Utilisation

### 1. Créer un Item Personnalisé

1. **Accès au Menu**
   - Utiliser `/farmzone`
   - Cliquer sur l'onglet "Items" 📦

2. **Informations de Base**
   - **Nom** : `super_carotte` (lettres minuscules, chiffres, underscore)
   - **Label** : `Super Carotte`
   - **Description** : Description personnalisée
   - **Catégorie** : Sélectionner parmi 6 catégories

3. **Configuration des Propriétés**
   - **Poids** : 1.5kg par exemple
   - **Rareté** : Commun ou Rare
   - **Utilisable** : Oui/Non
   - **Supprimable** : Oui/Non

4. **Usage Farming (Optionnel)**
   - **Aucun** : Item normal
   - **Graine** : Configure prix et temps de croissance
   - **Récolte** : Configure prix de vente et quantité
   - **Outil** : Outil de farming

5. **Validation et Création**
   - L'aperçu se met à jour en temps réel
   - Validation automatique du nom
   - Clic sur "Créer l'item"

### 2. Résultat Automatique

✅ **Insertion Base de Données** : Item ajouté dans la table `items`  
✅ **Log Console** : Affichage détaillé dans la console  
✅ **Log Discord** : Message automatique avec embed  
✅ **Notification** : Confirmation au staff  

## 🔧 Configuration

### Fichier `config.lua` - Section Items

```lua
-- Configuration pour la création d'items personnalisés
Config.ItemCreation = {
    enabled = true,                    -- Activer/désactiver la création d'items
    allowStaffCreate = true,           -- Permettre aux staff de créer des items
    autoInsertDatabase = true,         -- Insertion automatique en BDD
    discordLogs = {
        enabled = true,                -- Activer les logs Discord
        webhook = "VOTRE_WEBHOOK_ICI", -- URL du webhook Discord
        botName = "Farming Creator",
        embedColor = 3447003,          -- Couleur bleu
        avatar = "URL_AVATAR"
    },
    defaultItemSettings = {
        weight = 1,
        rare = 0,
        can_remove = 1,
        usable = 0,
        shouldClose = 1
    },
    itemCategories = {                 -- Catégories disponibles
        {name = "Nourriture", value = "food"},
        {name = "Graines", value = "seeds"},
        {name = "Outils", value = "tools"},
        {name = "Matériaux", value = "materials"},
        {name = "Récoltes", value = "harvest"},
        {name = "Autres", value = "other"}
    }
}
```

### Configuration Discord

1. **Créer un Webhook Discord**
   - Aller dans les paramètres de votre salon Discord
   - Intégrations → Webhooks → Nouveau Webhook
   - Copier l'URL du webhook

2. **Configurer dans le Config**
   ```lua
   discordLogs = {
       enabled = true,
       webhook = "https://discord.com/api/webhooks/VOTRE_WEBHOOK_ICI",
       botName = "Farming Creator",
       embedColor = 3447003,
       avatar = "https://your-avatar-url.png"
   }
   ```

## 📊 Logs et Monitoring

### 🖥️ Logs Console

Quand un item est créé, la console affiche :
```
[FARMING CREATOR] Item créé et inséré dans la base de données:
  ├─ Nom: super_carotte
  ├─ Label: Super Carotte
  ├─ Catégorie: food
  ├─ Poids: 1.5kg
  ├─ Rareté: Commun
  ├─ Créé par: PlayerName (steam:110000xxxxxx)
  └─ ID BDD: 245
[FARMING CREATOR] ✅ Item inséré avec succès dans la table items
[FARMING CREATOR] ✅ Log Discord envoyé avec succès
```

### 📱 Logs Discord

L'embed Discord contient :
- **Informations de l'item** : Nom, label, catégorie, poids, rareté
- **Propriétés** : Utilisable, supprimable, ferme inventaire
- **Créateur** : Nom, ID serveur, identifier
- **Usage Farming** : Si configuré (graine, récolte, outil)
- **Description** : Si renseignée
- **Footer** : ID de base de données

## 🗄️ Base de Données

### Table `items` (Existante)

L'item est automatiquement inséré avec :
```sql
INSERT INTO items 
(name, label, weight, rare, can_remove, usable, shouldClose, combinable, description) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
```

### Vérification d'Existence

Le système vérifie automatiquement si un item avec le même nom existe déjà pour éviter les doublons.

## 🎯 Exemples d'Usage

### 1. Créer une Nourriture Spéciale

```
Nom: burger_deluxe
Label: Burger Deluxe
Catégorie: Nourriture
Poids: 0.8kg
Rareté: Rare
Utilisable: Oui
Description: Un burger exceptionnel qui restaure beaucoup de vie
```

### 2. Créer une Nouvelle Graine

```
Nom: magic_seed
Label: Graine Magique
Catégorie: Graines
Usage: Graine
Prix d'achat: 150$
Temps croissance: 10 minutes
Description: Graine rare qui produit des fruits magiques
```

### 3. Créer un Outil Spécialisé

```
Nom: super_hoe
Label: Houe Magique
Catégorie: Outils
Poids: 2.5kg
Rareté: Rare
Usage: Outil de farming
Description: Houe enchantée qui accélère la plantation
```

## 🔒 Sécurité et Validation

### Validations Automatiques
- **Nom unique** : Vérification en base de données
- **Format nom** : Lettres minuscules, chiffres, underscore uniquement
- **Longueur minimum** : 3 caractères minimum
- **Poids valide** : Entre 0 et 100kg
- **Permissions** : Vérification des droits staff

### Prévention d'Exploits
- **Validation côté serveur** : Double vérification de tous les paramètres
- **Logs complets** : Traçabilité de toutes les créations
- **Permissions strictes** : Seuls les staff autorisés

## 🚨 Dépannage

### Problèmes Courants

1. **Discord logs ne marchent pas**
   - Vérifiez l'URL du webhook
   - Assurez-vous que `enabled = true`
   - Regardez les logs console pour les erreurs

2. **Item pas inséré en BDD**
   - Vérifiez `autoInsertDatabase = true`
   - Consultez les logs pour les erreurs SQL
   - Vérifiez la connexion MySQL

3. **Permissions refusées**
   - Vérifiez que le joueur a le bon groupe
   - Contrôlez `Config.RequiredPermission`

### Commandes de Vérification

```sql
-- Voir les derniers items créés
SELECT * FROM items ORDER BY id DESC LIMIT 10;

-- Chercher un item spécifique
SELECT * FROM items WHERE name = 'super_carotte';

-- Compter les items par catégorie
SELECT 
    CASE 
        WHEN name LIKE '%seed%' THEN 'Graines'
        WHEN name LIKE '%tool%' THEN 'Outils'
        ELSE 'Autres'
    END as category,
    COUNT(*) as count
FROM items 
GROUP BY category;
```

## 📈 Fonctionnalités Avancées

### Ajout Dynamique au Farming

Si vous créez une graine avec le système, elle est automatiquement ajoutée au système de farming (temporaire, redémarre avec le serveur).

### Types d'Usage Spéciaux

- **Graine** : Crée automatiquement une nouvelle culture
- **Récolte** : Configure les prix de vente
- **Outil** : Marqué comme outil de farming

### Aperçu Temps Réel

L'interface met à jour automatiquement l'aperçu quand vous modifiez :
- Le nom et label
- La description
- Le poids et la rareté

## 🔮 Extensions Futures

- **Items utilisables** : Scripts personnalisés pour les items
- **Crafting** : Système de fabrication avec les items créés
- **Commerce** : Intégration avec les shops
- **Import/Export** : Sauvegarde et partage de configs d'items

---

**🎮 Créez vos items personnalisés facilement !**