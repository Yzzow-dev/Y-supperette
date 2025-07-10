# 🗺️ Farming Creator - Zones Personnalisées

Extension du système Farming Creator qui permet aux staff de créer des zones de farm personnalisées avec des paramètres avancés.

## ✨ Nouvelles Fonctionnalités

### 🎯 Zones de Farm Personnalisées
- **Interface avancée** : Menu complet pour créer des zones avec tous les paramètres
- **Zones circulaires** : Création de zones avec un rayon défini (10-200m)
- **Labels personnalisés** : Noms et descriptions personnalisables
- **Densité variable** : Faible, moyenne ou élevée selon les besoins
- **Couleurs configurables** : 7 couleurs disponibles pour différencier les zones
- **Système de permissions** : Contrôle d'accès par métier, gang ou liste blanche

### 🛠️ Paramètres Configurables

#### 🎨 Apparence
- **Couleurs** : Vert, Bleu, Jaune, Rouge, Orange, Violet, Rose
- **Icônes** : 5 types d'icônes sur la carte (Ferme, Plante, Propriété, etc.)
- **Marqueurs** : Possibilité d'afficher ou masquer les marqueurs visuels

#### 🌱 Configuration des Récoltes
- **Item personnalisé** : Définir quel item est donné lors de la récolte
- **Quantité variable** : Format min-max (ex: 2-5)
- **Temps de croissance** : 1-60 minutes configurable
- **Graines optionnelles** : Récolte gratuite ou avec graines requises

#### 🔐 Système de Permissions
- **Public** : Accessible à tous les joueurs
- **Métier** : Réservé à un métier spécifique
- **Gang** : Réservé à un gang spécifique
- **Liste blanche** : Pour des utilisateurs spécifiques (future extension)

## 📋 Commandes Staff

### Nouvelle Commande Principale
```
/farmzone
```
Ouvre l'interface avancée de création de zones personnalisées.

### Commandes Existantes
```
/farmingcreator  - Menu de création de fermes traditionnelles
/delfarm        - Supprimer une ferme/zone proche
```

## 🚀 Utilisation

### 1. Créer une Zone Personnalisée

1. **Positionnement**
   - Placez-vous au centre de la zone souhaitée
   - Utilisez `/farmzone` pour ouvrir le menu

2. **Configuration de Base**
   - **Nom** : Nom affiché sur la carte
   - **Label** : Texte affiché aux joueurs (optionnel)
   - **Description** : Description détaillée

3. **Configuration Spatiale**
   - **Rayon** : 10-200 mètres (surface calculée automatiquement)
   - **Densité** : 
     - Faible = espacement large, moins de points
     - Moyenne = équilibré
     - Élevée = dense, plus de points

4. **Personnalisation**
   - **Couleur** : Sélectionner parmi 7 couleurs
   - **Icône** : Choisir l'icône sur la carte
   - **Marqueurs** : Afficher ou masquer

5. **Récoltes**
   - **Item** : Par défaut `farmbox` (modifiable)
   - **Quantité** : Format "min-max" (ex: 1-3)
   - **Temps** : Minutes avant récolte possible
   - **Graines** : Requis ou gratuit

6. **Accès**
   - **Type** : Public, Métier, Gang, ou Liste blanche
   - **Restrictions** : Spécifier le métier/gang si applicable

### 2. Aperçu en Temps Réel

Le menu affiche automatiquement :
- **Surface totale** : Calculée selon le rayon (π × r²)
- **Points estimés** : Nombre approximatif de points de récolte
- **Visualisation** : Cercle qui change de couleur selon la taille

### 3. Validation et Sécurité

- **Proximité** : Vérification automatique des chevauchements
- **Limites** : Rayon entre 10 et 200 mètres
- **Permissions** : Vérification des droits staff
- **Format** : Validation du format des quantités

## ⚙️ Configuration Avancée

### Fichier `config.lua` - Section Zones

```lua
-- Nouvelles options pour les zones de farm personnalisées
Config.FarmZones = {
    enabled = true,              -- Activer/désactiver les zones personnalisées
    defaultRadius = 50.0,        -- Rayon par défaut
    maxRadius = 200.0,          -- Rayon maximum
    minRadius = 10.0,           -- Rayon minimum
    allowCustomLabels = true,    -- Permettre les labels personnalisés
    showZoneBlips = true,       -- Afficher les blips pour les zones
    zoneColors = {              -- Couleurs disponibles
        {name = "Vert", color = 2},
        {name = "Bleu", color = 3},
        -- ... autres couleurs
    }
}
```

### Nouvelle Commande

```lua
Config.Commands = {
    farmingMenu = 'farmingcreator',
    deleteFarm = 'delfarm',
    farmZoneMenu = 'farmzone'    -- Nouvelle commande
}
```

## 🗄️ Base de Données

### Nouvelles Tables

#### Table `farming_zones`
```sql
CREATE TABLE farming_zones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    label VARCHAR(100),
    description TEXT,
    coords_x FLOAT NOT NULL,
    coords_y FLOAT NOT NULL,
    coords_z FLOAT NOT NULL,
    radius FLOAT NOT NULL,
    density VARCHAR(20) DEFAULT 'medium',
    color INT DEFAULT 2,
    blip_sprite INT DEFAULT 164,
    show_markers BOOLEAN DEFAULT TRUE,
    harvest_item VARCHAR(50) DEFAULT 'farmbox',
    harvest_min INT DEFAULT 1,
    harvest_max INT DEFAULT 3,
    grow_time INT DEFAULT 240000,
    require_seeds BOOLEAN DEFAULT FALSE,
    access_type VARCHAR(20) DEFAULT 'public',
    allowed_job VARCHAR(50),
    allowed_gang VARCHAR(50),
    owner VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Table `farming_zone_points`
```sql
CREATE TABLE farming_zone_points (
    id INT AUTO_INCREMENT PRIMARY KEY,
    zone_id INT NOT NULL,
    coords_x FLOAT NOT NULL,
    coords_y FLOAT NOT NULL,
    coords_z FLOAT NOT NULL,
    planted BOOLEAN DEFAULT FALSE,
    harvest_time BIGINT DEFAULT NULL,
    FOREIGN KEY (zone_id) REFERENCES farming_zones(id) ON DELETE CASCADE
);
```

### Nouveaux Items

```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('farmbox', 'Caisse de Récolte', 2, 0, 1),
('custom_seed', 'Graines Universelles', 1, 0, 1);
```

## 📊 Algorithme de Génération des Points

### Distribution Circulaire
- **Méthode** : Génération en spirale à partir du centre
- **Espacement dynamique** : Selon la densité choisie
  - Faible : 8m entre les points
  - Moyenne : 5m entre les points
  - Élevée : 3m entre les points

### Calcul des Points
```lua
-- Exemple pour rayon 50m, densité moyenne
local spacing = 5.0
for r = spacing, radius, spacing do
    local circumference = 2 * math.pi * r
    local pointsOnCircle = math.floor(circumference / spacing)
    -- Génération des points sur le cercle...
end
```

## 🎯 Cas d'Usage

### 1. Zone Publique de Débutants
- **Rayon** : 30m
- **Densité** : Élevée
- **Récolte** : Gratuite, 1-2 items
- **Temps** : 2 minutes
- **Accès** : Public

### 2. Zone VIP Réservée
- **Rayon** : 100m
- **Densité** : Moyenne
- **Récolte** : Items rares, 3-5 items
- **Temps** : 5 minutes
- **Accès** : Métier "vip"

### 3. Zone de Gang
- **Rayon** : 75m
- **Densité** : Élevée
- **Récolte** : Items spéciaux, 2-4 items
- **Temps** : 3 minutes
- **Accès** : Gang "ballas"

## 🔧 Maintenance

### Commandes de Gestion
```lua
-- Lister toutes les zones
SELECT * FROM farming_zones;

-- Supprimer une zone spécifique
DELETE FROM farming_zones WHERE id = [zone_id];

-- Modifier une zone existante
UPDATE farming_zones SET radius = 75 WHERE id = [zone_id];
```

### Performance
- **Optimisation** : Les zones avec densité élevée peuvent impacter les performances
- **Recommandation** : Limiter le nombre de zones avec densité élevée
- **Monitoring** : Surveiller le nombre total de points actifs

## 🛡️ Sécurité

### Validations
- **Rayon** : Strictement entre min et max configurés
- **Proximité** : Buffer automatique de 50m entre zones
- **Permissions** : Vérification côté serveur
- **Format** : Validation des quantités (regex)

### Anti-Exploit
- **Cooldown** : Temps de croissance respecté
- **Vérification** : Items requis vérifiés avant plantation
- **Distance** : Interaction limitée par la distance

## 📈 Extensions Futures

### Fonctionnalités Prévues
- **Zones temporaires** : Expiration automatique
- **Événements** : Zones spéciales pour événements
- **Statistiques** : Tracking des récoltes par zone
- **Économie** : Prix dynamiques selon l'activité
- **Météo** : Impact des conditions météo

---

**🎮 Bon farming avec les zones personnalisées !**