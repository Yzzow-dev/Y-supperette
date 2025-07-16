# 🔓 Décrypteur FiveM - Bot Discord

Un bot Discord puissant pour décrypter les fichiers et scripts FiveM obfusqués ou chiffrés.

## 🚀 Fonctionnalités

- **Décryptage automatique** : Teste plusieurs méthodes de décryptage automatiquement
- **Méthodes supportées** :
  - Base64
  - Hexadécimal
  - Compression zlib
  - Compression LZMA
  - Code Lua obfusqué
- **Support des fichiers** : Décrypte les fichiers directement via Discord
- **Interface intuitive** : Commandes simples avec des réponses formatées
- **Gestion d'erreurs** : Messages d'erreur clairs et informatifs

## 📋 Prérequis

- Python 3.8 ou plus récent
- Un serveur Discord
- Un bot Discord créé sur le portail développeurs Discord

## 🛠️ Installation

1. **Cloner le projet**
   ```bash
   git clone <url-du-repo>
   cd fivem-discord-decrypter
   ```

2. **Installer les dépendances**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configurer le bot Discord**
   - Allez sur https://discord.com/developers/applications
   - Créez une nouvelle application
   - Dans l'onglet "Bot", créez un bot
   - Copiez le token du bot
   - Renommez `.env.example` en `.env`
   - Remplacez `votre_token_discord_ici` par votre token

4. **Inviter le bot sur votre serveur**
   - Dans l'onglet "OAuth2 > URL Generator"
   - Sélectionnez "bot" dans les scopes
   - Sélectionnez les permissions : "Send Messages", "Read Message History", "Use Slash Commands"
   - Utilisez l'URL générée pour inviter le bot

5. **Lancer le bot**
   ```bash
   python bot.py
   ```

## 📝 Commandes

### `!decrypt [method] [data]`
Décrypte des données avec une méthode spécifique ou automatiquement.

**Méthodes disponibles :**
- `base64` : Décodage Base64
- `hex` : Décodage hexadécimal
- `zlib` : Décompression zlib
- `lzma` : Décompression LZMA
- `lua` : Nettoyage de code Lua obfusqué
- `auto` : Teste toutes les méthodes automatiquement

**Exemples :**
```
!decrypt base64 SGVsbG8gV29ybGQ=
!decrypt hex 48656c6c6f20576f726c64
!decrypt auto [données_cryptées]
```

### `!decrypt_file`
Décrypte un fichier joint au message.

**Utilisation :**
1. Tapez `!decrypt_file`
2. Joignez le fichier à décrypter à votre message
3. Envoyez le message

**Limitations :**
- Taille maximum : 8MB
- Fichiers texte uniquement

### `!help_decrypt`
Affiche l'aide détaillée avec tous les exemples d'utilisation.

## 🔧 Configuration avancée

### Personnaliser le préfixe
Dans `bot.py`, ligne 21, changez `!` par votre préfixe souhaité :
```python
bot = commands.Bot(command_prefix='!', intents=intents)
```

### Ajouter de nouvelles méthodes de décryptage
Créez une nouvelle méthode dans la classe `FiveMDecrypter` :
```python
@staticmethod
def decrypt_custom(data):
    # Votre logique de décryptage ici
    return decrypted_data
```

Ajoutez-la dans la commande `decrypt_command` et dans `auto_decrypt`.

## 🛡️ Sécurité

- Le bot ne stocke aucune donnée décryptée
- Toutes les opérations sont effectuées en mémoire
- Les fichiers temporaires sont automatiquement supprimés
- Le token Discord est stocké de manière sécurisée dans les variables d'environnement

## 📊 Types de fichiers FiveM supportés

- Scripts Lua obfusqués
- Fichiers de configuration chiffrés
- Données sérialisées
- Fichiers compressés
- Données encodées en Base64/Hex

## 🐛 Dépannage

### Le bot ne répond pas
- Vérifiez que le token est correct dans `.env`
- Assurez-vous que le bot a les permissions nécessaires
- Vérifiez que le bot est en ligne dans votre serveur

### Erreurs de décryptage
- Vérifiez que les données sont complètes et correctes
- Essayez la méthode `auto` pour tester plusieurs approches
- Certains fichiers peuvent nécessiter des clés de décryptage spécifiques

### Problèmes de permissions
Le bot a besoin des permissions suivantes :
- Lire les messages
- Envoyer des messages
- Joindre des fichiers
- Utiliser des commandes slash

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Ouvrir une issue pour signaler un bug
- Proposer de nouvelles fonctionnalités
- Soumettre des pull requests

## ⚠️ Avertissement

Ce bot est destiné à des fins éducatives et de débogage. Assurez-vous de respecter les droits d'auteur et les conditions d'utilisation des ressources FiveM que vous décryptez.

---

**Développé pour la communauté FiveM** 🎮