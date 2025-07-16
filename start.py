#!/usr/bin/env python3
"""
Script de démarrage pour le bot décrypteur FiveM
"""

import os
import sys
import subprocess
import pkg_resources
from pathlib import Path

def check_python_version():
    """Vérifie la version de Python"""
    if sys.version_info < (3, 8):
        print("❌ Python 3.8 ou plus récent est requis")
        print(f"Version actuelle: {sys.version}")
        return False
    print(f"✅ Python {sys.version_info.major}.{sys.version_info.minor} détecté")
    return True

def check_dependencies():
    """Vérifie et installe les dépendances"""
    print("🔍 Vérification des dépendances...")
    
    requirements_file = Path("requirements.txt")
    if not requirements_file.exists():
        print("❌ Fichier requirements.txt manquant")
        return False
    
    try:
        # Lit les dépendances
        with open(requirements_file, 'r') as f:
            requirements = [line.strip() for line in f if line.strip() and not line.startswith('#')]
        
        # Vérifie chaque dépendance
        missing = []
        for req in requirements:
            try:
                pkg_resources.require(req)
                print(f"✅ {req}")
            except pkg_resources.DistributionNotFound:
                missing.append(req)
                print(f"❌ {req} (manquant)")
            except pkg_resources.VersionConflict as e:
                print(f"⚠️  {req} (conflit de version: {e})")
        
        # Installe les dépendances manquantes
        if missing:
            print(f"\n📦 Installation de {len(missing)} dépendances manquantes...")
            for req in missing:
                try:
                    subprocess.check_call([sys.executable, "-m", "pip", "install", req])
                    print(f"✅ {req} installé")
                except subprocess.CalledProcessError as e:
                    print(f"❌ Erreur lors de l'installation de {req}: {e}")
                    return False
        
        print("✅ Toutes les dépendances sont installées")
        return True
        
    except Exception as e:
        print(f"❌ Erreur lors de la vérification des dépendances: {e}")
        return False

def check_env_file():
    """Vérifie la configuration du fichier .env"""
    print("🔍 Vérification de la configuration...")
    
    env_file = Path(".env")
    env_example = Path(".env.example")
    
    if not env_file.exists():
        if env_example.exists():
            print("⚠️  Fichier .env manquant")
            print("📝 Veuillez copier .env.example vers .env et configurer votre token Discord")
            
            # Demande si on doit créer automatiquement
            response = input("Voulez-vous créer le fichier .env maintenant ? (y/n): ").lower().strip()
            if response in ['y', 'yes', 'oui', 'o']:
                try:
                    # Copie le fichier exemple
                    with open(env_example, 'r') as src, open(env_file, 'w') as dst:
                        dst.write(src.read())
                    
                    print("✅ Fichier .env créé")
                    print("🔑 Veuillez maintenant éditer le fichier .env et ajouter votre token Discord")
                    print("💡 Instructions: https://discord.com/developers/applications")
                    
                    return False  # Arrête ici pour permettre la configuration
                except Exception as e:
                    print(f"❌ Erreur lors de la création du fichier .env: {e}")
                    return False
            else:
                return False
        else:
            print("❌ Fichiers .env et .env.example manquants")
            return False
    
    # Vérifie le contenu du fichier .env
    try:
        with open(env_file, 'r') as f:
            content = f.read()
        
        if 'DISCORD_TOKEN=votre_token_discord_ici' in content:
            print("⚠️  Token Discord non configuré dans le fichier .env")
            print("🔑 Veuillez remplacer 'votre_token_discord_ici' par votre vrai token Discord")
            return False
        
        if 'DISCORD_TOKEN=' in content:
            print("✅ Configuration .env détectée")
            return True
        else:
            print("❌ DISCORD_TOKEN manquant dans le fichier .env")
            return False
            
    except Exception as e:
        print(f"❌ Erreur lors de la lecture du fichier .env: {e}")
        return False

def start_bot():
    """Démarre le bot"""
    print("🚀 Démarrage du bot décrypteur FiveM...")
    print("=" * 50)
    
    try:
        # Importe et lance le bot
        os.system("python bot.py")
    except KeyboardInterrupt:
        print("\n👋 Bot arrêté par l'utilisateur")
    except Exception as e:
        print(f"❌ Erreur lors du démarrage du bot: {e}")
        return False
    
    return True

def main():
    """Fonction principale"""
    print("🔓 Décrypteur FiveM - Bot Discord")
    print("=" * 40)
    
    # Vérifications préliminaires
    if not check_python_version():
        sys.exit(1)
    
    if not check_dependencies():
        sys.exit(1)
    
    if not check_env_file():
        print("\n💡 Configuration requise avant de continuer")
        sys.exit(1)
    
    # Démarre le bot
    print("\n🎯 Tous les prérequis sont satisfaits!")
    input("Appuyez sur Entrée pour démarrer le bot...")
    
    start_bot()

if __name__ == "__main__":
    main()