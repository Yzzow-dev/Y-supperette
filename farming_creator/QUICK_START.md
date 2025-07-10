# 🚀 Guide de Démarrage Rapide - Système d'Items Personnalisés

## ⚡ Configuration en 3 étapes

### 1. 🔗 Configurez Discord (2 minutes)

1. Créez un webhook Discord dans votre serveur
2. Copiez l'URL du webhook
3. Dans `config.lua`, remplacez `"VOTRE_WEBHOOK_URL_ICI"` par votre URL

```lua
Config.Discord = {
    enabled = true,
    webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE",
    -- ... reste de la config
}
```

### 2. 🎮 Testez le système (1 minute)

1. Connectez-vous à votre serveur FiveM
2. Tapez `/createitem` en jeu
3. Suivez les étapes du menu

### 3. ✅ Vérification

Si tout fonctionne, vous devriez voir :
- ✅ Message dans la console : `[Farming Creator] Item créé et inséré dans la table de données: nom_item par VotreNom`
- ✅ Log Discord avec les détails de l'item
- ✅ Notification en jeu confirmant la création

---

## 🎯 Commandes essentielles

| Commande | Utilisation |
|----------|-------------|
| `/createitem` | Créer un nouvel item (admin uniquement) |
| `/suggestitem` | Suggérer un item (tous les joueurs) |
| `/itemmenu` | Gérer tous les items créés (admin) |

---

## 🔧 Dépannage rapide

### ❌ L'item n'apparaît pas dans la BDD
- Vérifiez que MySQL-async fonctionne
- Vérifiez les permissions admin
- Regardez la console pour les erreurs

### ❌ Pas de logs Discord
- Vérifiez l'URL du webhook
- Assurez-vous que `Config.Discord.enabled = true`
- Vérifiez que le webhook a les bonnes permissions

### ❌ Commandes ne fonctionnent pas
- Vérifiez que vous êtes admin : `Config.RequiredPermission = 'admin'`
- Redémarrez la ressource : `restart farming_creator`

---

## 📝 Exemple de création d'item

**Nom :** `sword_legendary`  
**Label :** `Épée Légendaire`  
**Poids :** `3`  
**Description :** `Une épée forgée par les dieux`

**Résultat attendu :**
- Item ajouté à la table `items` d'ESX
- Log Discord avec tous les détails
- Message console confirmant l'insertion
- Notification pour tous les joueurs connectés

---

## 🎉 C'est tout !

Votre système est maintenant opérationnel. Les staff peuvent créer des items, tout est tracé automatiquement, et vous avez un historique complet de toutes les créations !

**Bon farming ! 🌾**