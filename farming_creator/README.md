# 🌱 Farming Creator - Système de Fermes pour FiveM

Un système complet de création et gestion de fermes personnalisées pour les serveurs FiveM. Permet aux administrateurs de créer facilement des zones de farming avec différents types de cultures.

## ✨ Fonctionnalités

- **Interface moderne** : Menu NUI élégant et intuitif
- **Cultures variées** : Oranges, pommes, blé, carottes, maïs, raisins
- **Création facile** : Placement automatique des zones de culture
- **Système économique** : Prix des graines, récoltes et profits
- **Temps de croissance** : Chaque culture a son propre temps de maturation
- **Visualisation** : Marqueurs et blips pour localiser les fermes
- **Base de données** : Sauvegarde persistante des fermes
- **Permissions** : Système de permissions pour les administrateurs

## 📸 Aperçu

### Types de cultures disponibles :
- 🍊 **Oranges** - 5min de croissance, profit moyen : +70$
- 🍎 **Pommes** - 4min de croissance, profit moyen : +63$  
- 🌾 **Blé** - 3min de croissance, profit moyen : +39$
- 🥕 **Carottes** - 2min de croissance, profit moyen : +32.5$
- 🌽 **Maïs** - 6min de croissance, profit moyen : +5$
- 🍇 **Raisins** - 7min de croissance, profit moyen : +80$

## 🛠️ Installation

### Prérequis
- Serveur FiveM avec ESX Legacy
- Base de données MySQL
- Ressource `mysql-async`

### Étapes d'installation

1. **Télécharger la ressource**
   ```bash
   cd resources
   git clone [URL_DU_REPO] farming_creator
   # ou décompresser le fichier zip dans le dossier resources
   ```

2. **Ajouter à server.cfg**
   ```cfg
   ensure farming_creator
   ```

3. **Configuration de la base de données**
   - Les tables se créent automatiquement au premier démarrage
   - Vérifiez que `mysql-async` est bien configuré

4. **Ajouter les items dans la base de données**
   ```sql
   INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
   ('orange_seed', 'Graines d\'orange', 1, 0, 1),
   ('apple_seed', 'Graines de pomme', 1, 0, 1),
   ('wheat_seed', 'Graines de blé', 1, 0, 1),
   ('carrot_seed', 'Graines de carotte', 1, 0, 1),
   ('corn_seed', 'Graines de maïs', 1, 0, 1),
   ('grape_seed', 'Graines de raisin', 1, 0, 1),
   ('orange', 'Orange', 1, 0, 1),
   ('apple', 'Pomme', 1, 0, 1),
   ('wheat', 'Blé', 1, 0, 1),
   ('carrot', 'Carotte', 1, 0, 1),
   ('corn', 'Maïs', 1, 0, 1),
   ('grape', 'Raisin', 1, 0, 1);
   ```

## ⚙️ Configuration

### Fichier `config.lua`

```lua
-- Permissions
Config.UsePermissions = true
Config.RequiredPermission = 'admin'

-- Commandes
Config.Commands = {
    farmingMenu = 'farmingcreator',
    deleteFarm = 'delfarm'
}

-- Distances
Config.InteractionDistance = 2.0
Config.MarkerDistance = 20.0
```

### Personnalisation des cultures

Vous pouvez modifier les cultures existantes ou en ajouter de nouvelles dans `config.lua` :

```lua
Config.CropTypes['nouvelle_culture'] = {
    name = 'Nom de la culture',
    description = 'Description',
    growTime = 180000, -- 3 minutes en millisecondes
    harvestAmount = {min = 2, max = 5},
    harvestItem = 'item_recolte',
    seedItem = 'item_graine',
    seedPrice = 30,
    sellPrice = 10,
    model = 'prop_model_objet',
    blip = { sprite = 238, color = 2, scale = 0.8 },
    marker = { type = 1, r = 255, g = 0, b = 0, a = 100, scale = {x = 1.0, y = 1.0, z = 1.0} }
}
```

## 🎮 Utilisation

### Pour les administrateurs

1. **Créer une ferme**
   ```
   /farmingcreator
   ```
   - Se placer à l'endroit désiré
   - Choisir le type de culture
   - Définir la taille et l'espacement
   - Valider la création

2. **Supprimer une ferme**
   ```
   /delfarm
   ```
   - Se placer près de la ferme à supprimer
   - Exécuter la commande

3. **Donner des graines**
   ```
   /giveseed [type] [quantité]
   ```
   - Exemple : `/giveseed orange 10`

### Pour les joueurs

1. **Planter**
   - Se rendre sur une ferme
   - Approcher d'un marqueur vide
   - Appuyer sur `E` avec les graines en inventaire

2. **Récolter**
   - Attendre que la culture soit mature
   - Approcher du marqueur vert
   - Appuyer sur `E` pour récolter

## 📁 Structure des fichiers

```
farming_creator/
├── fxmanifest.lua          # Manifest de la ressource
├── config.lua              # Configuration principale
├── client/
│   └── main.lua            # Script client principal
├── server/
│   └── main.lua            # Script serveur principal
├── html/
│   ├── index.html          # Interface utilisateur
│   ├── style.css           # Styles CSS
│   └── script.js           # Logique JavaScript
└── README.md               # Ce fichier
```

## 🛡️ Permissions

### Groupes ESX requis
- `admin` : Peut créer et supprimer des fermes
- `user` : Peut planter et récolter (par défaut)

### Modification des permissions
Dans `config.lua` :
```lua
Config.UsePermissions = false  -- Désactiver les permissions
-- ou
Config.RequiredPermission = 'moderator'  -- Changer le groupe requis
```

## 🔧 Dépannage

### Problèmes courants

1. **Les fermes ne se sauvegardent pas**
   - Vérifiez la connexion MySQL
   - Assurez-vous que `mysql-async` fonctionne

2. **Interface ne s'ouvre pas**
   - Vérifiez les permissions du joueur
   - Regardez la console F8 pour les erreurs

3. **Objets ne s'affichent pas**
   - Vérifiez que les modèles 3D existent
   - Redémarrez la ressource

4. **Marqueurs invisibles**
   - Augmentez `Config.MarkerDistance`
   - Vérifiez les coordonnées des fermes

### Commandes de débogage

```lua
-- Dans la console serveur
refresh
restart farming_creator

-- Pour vérifier la base de données
SELECT * FROM farming_creator;
SELECT * FROM farming_plants;
```

## 🔄 Mises à jour

### Version 1.0.0
- Système de base avec 6 types de cultures
- Interface NUI moderne
- Sauvegarde en base de données
- Système de permissions

### Roadmap
- [ ] Système de fertilisants
- [ ] Météo affectant les cultures
- [ ] Commerce entre joueurs
- [ ] Fermes partagées/coopératives
- [ ] Statistiques de production

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer de nouvelles fonctionnalités
- Améliorer la documentation
- Ajouter des traductions

## 📄 Licence

Ce projet est sous licence MIT. Vous êtes libre de l'utiliser et le modifier selon vos besoins.

## 📞 Support

Pour toute question ou problème :
- Ouvrez une issue sur GitHub
- Rejoignez notre Discord de support
- Consultez la documentation FiveM

---

**Bon farming ! 🌱**