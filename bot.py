import discord
from discord.ext import commands
import os
import base64
import zlib
import lzma
import re
import asyncio
from dotenv import load_dotenv
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import binascii

load_dotenv()

# Configuration du bot
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents)

class FiveMDecrypter:
    """Classe pour décrypter différents types de fichiers FiveM"""
    
    @staticmethod
    def decrypt_base64(encoded_string):
        """Décrypte une chaîne encodée en base64"""
        try:
            decoded = base64.b64decode(encoded_string)
            return decoded.decode('utf-8')
        except Exception as e:
            return f"Erreur lors du décodage base64: {str(e)}"
    
    @staticmethod
    def decrypt_zlib(compressed_data):
        """Décrypte des données compressées avec zlib"""
        try:
            if isinstance(compressed_data, str):
                compressed_data = compressed_data.encode('utf-8')
            decompressed = zlib.decompress(compressed_data)
            return decompressed.decode('utf-8')
        except Exception as e:
            return f"Erreur lors de la décompression zlib: {str(e)}"
    
    @staticmethod
    def decrypt_lzma(compressed_data):
        """Décrypte des données compressées avec LZMA"""
        try:
            if isinstance(compressed_data, str):
                compressed_data = compressed_data.encode('utf-8')
            decompressed = lzma.decompress(compressed_data)
            return decompressed.decode('utf-8')
        except Exception as e:
            return f"Erreur lors de la décompression LZMA: {str(e)}"
    
    @staticmethod
    def decrypt_hex(hex_string):
        """Décrypte une chaîne hexadécimale"""
        try:
            decoded = bytes.fromhex(hex_string)
            return decoded.decode('utf-8')
        except Exception as e:
            return f"Erreur lors du décodage hex: {str(e)}"
    
    @staticmethod
    def decrypt_lua_obfuscated(obfuscated_code):
        """Tente de décrypter du code Lua obfusqué couramment utilisé dans FiveM"""
        try:
            # Supprime les commentaires de confusion
            cleaned = re.sub(r'--.*?\n', '', obfuscated_code)
            
            # Remplace les variables obfusquées communes
            replacements = {
                r'_G\["[^"]*"\]': 'function_name',
                r'local\s+[_a-zA-Z][_a-zA-Z0-9]*\s*=\s*[_a-zA-Z][_a-zA-Z0-9]*': 'local var = value',
                r'string\.char\(([^)]+)\)': lambda m: f'"{chr(int(m.group(1)))}"' if m.group(1).isdigit() else m.group(0)
            }
            
            for pattern, replacement in replacements.items():
                if callable(replacement):
                    cleaned = re.sub(pattern, replacement, cleaned)
                else:
                    cleaned = re.sub(pattern, replacement, cleaned)
            
            return cleaned
        except Exception as e:
            return f"Erreur lors du nettoyage du code Lua: {str(e)}"
    
    @staticmethod
    def auto_decrypt(data):
        """Tente automatiquement différentes méthodes de décryptage"""
        methods = [
            ("Base64", FiveMDecrypter.decrypt_base64),
            ("Hex", FiveMDecrypter.decrypt_hex),
            ("Lua Obfusqué", FiveMDecrypter.decrypt_lua_obfuscated),
        ]
        
        results = []
        for method_name, method in methods:
            try:
                result = method(data)
                if result and not result.startswith("Erreur"):
                    results.append(f"**{method_name}:**\n```\n{result[:500]}{'...' if len(result) > 500 else ''}\n```")
            except:
                continue
        
        return results if results else ["Aucune méthode de décryptage n'a fonctionné"]

@bot.event
async def on_ready():
    print(f'{bot.user} est connecté et prêt!')
    print(f'Bot ID: {bot.user.id}')
    print('=' * 50)

@bot.command(name='decrypt')
async def decrypt_command(ctx, method=None, *, data=None):
    """
    Décrypte des données avec une méthode spécifique ou automatiquement
    Usage: !decrypt [method] [data]
    Méthodes disponibles: base64, hex, zlib, lzma, lua, auto
    """
    if not data:
        embed = discord.Embed(
            title="❌ Erreur",
            description="Veuillez fournir des données à décrypter.",
            color=discord.Color.red()
        )
        embed.add_field(
            name="Usage",
            value="!decrypt [method] [data]\n\nMéthodes: base64, hex, zlib, lzma, lua, auto",
            inline=False
        )
        await ctx.send(embed=embed)
        return
    
    decrypter = FiveMDecrypter()
    
    if method == "base64":
        result = decrypter.decrypt_base64(data)
    elif method == "hex":
        result = decrypter.decrypt_hex(data)
    elif method == "zlib":
        result = decrypter.decrypt_zlib(data)
    elif method == "lzma":
        result = decrypter.decrypt_lzma(data)
    elif method == "lua":
        result = decrypter.decrypt_lua_obfuscated(data)
    elif method == "auto" or method is None:
        if method is None:
            data = method + " " + data if method else data
        results = decrypter.auto_decrypt(data)
        
        embed = discord.Embed(
            title="🔓 Décryptage Automatique",
            description="Tentative de décryptage avec plusieurs méthodes:",
            color=discord.Color.green()
        )
        
        for i, result in enumerate(results[:3]):  # Limite à 3 résultats
            embed.add_field(
                name=f"Résultat {i+1}",
                value=result,
                inline=False
            )
        
        await ctx.send(embed=embed)
        return
    else:
        embed = discord.Embed(
            title="❌ Méthode inconnue",
            description=f"La méthode '{method}' n'est pas supportée.",
            color=discord.Color.red()
        )
        embed.add_field(
            name="Méthodes disponibles",
            value="base64, hex, zlib, lzma, lua, auto",
            inline=False
        )
        await ctx.send(embed=embed)
        return
    
    # Affichage du résultat
    if result.startswith("Erreur"):
        embed = discord.Embed(
            title="❌ Erreur de décryptage",
            description=result,
            color=discord.Color.red()
        )
    else:
        embed = discord.Embed(
            title="🔓 Décryptage réussi",
            description=f"Méthode utilisée: **{method}**",
            color=discord.Color.green()
        )
        
        # Limite la longueur du résultat pour Discord
        if len(result) > 1000:
            embed.add_field(
                name="Résultat (tronqué)",
                value=f"```\n{result[:1000]}...\n```",
                inline=False
            )
            embed.add_field(
                name="Note",
                value="Le résultat a été tronqué. Utilisez un fichier pour voir le contenu complet.",
                inline=False
            )
        else:
            embed.add_field(
                name="Résultat",
                value=f"```\n{result}\n```",
                inline=False
            )
    
    await ctx.send(embed=embed)

@bot.command(name='decrypt_file')
async def decrypt_file_command(ctx):
    """
    Décrypte un fichier joint au message
    Usage: !decrypt_file (avec un fichier joint)
    """
    if not ctx.message.attachments:
        embed = discord.Embed(
            title="❌ Erreur",
            description="Veuillez joindre un fichier à décrypter.",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    attachment = ctx.message.attachments[0]
    
    if attachment.size > 8 * 1024 * 1024:  # 8MB limite
        embed = discord.Embed(
            title="❌ Fichier trop volumineux",
            description="Le fichier ne peut pas dépasser 8MB.",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    try:
        file_content = await attachment.read()
        file_content = file_content.decode('utf-8')
        
        decrypter = FiveMDecrypter()
        results = decrypter.auto_decrypt(file_content)
        
        embed = discord.Embed(
            title="🔓 Décryptage de fichier",
            description=f"Fichier: **{attachment.filename}**",
            color=discord.Color.green()
        )
        
        for i, result in enumerate(results[:2]):  # Limite à 2 résultats
            embed.add_field(
                name=f"Méthode {i+1}",
                value=result,
                inline=False
            )
        
        await ctx.send(embed=embed)
        
    except Exception as e:
        embed = discord.Embed(
            title="❌ Erreur de lecture",
            description=f"Impossible de lire le fichier: {str(e)}",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)

@bot.command(name='help_decrypt')
async def help_decrypt_command(ctx):
    """Affiche l'aide pour les commandes de décryptage"""
    embed = discord.Embed(
        title="🔓 Aide - Décrypteur FiveM",
        description="Bot Discord pour décrypter des fichiers et scripts FiveM",
        color=discord.Color.blue()
    )
    
    embed.add_field(
        name="!decrypt [method] [data]",
        value="Décrypte des données avec une méthode spécifique\n"
              "Méthodes: base64, hex, zlib, lzma, lua, auto",
        inline=False
    )
    
    embed.add_field(
        name="!decrypt_file",
        value="Décrypte un fichier joint au message\n"
              "Joignez simplement un fichier à votre message",
        inline=False
    )
    
    embed.add_field(
        name="!help_decrypt",
        value="Affiche cette aide",
        inline=False
    )
    
    embed.add_field(
        name="Exemples d'utilisation",
        value="• !decrypt base64 SGVsbG8gV29ybGQ=\n"
              "• !decrypt auto [données]\n"
              "• !decrypt_file (avec fichier joint)",
        inline=False
    )
    
    embed.set_footer(text="Développé pour la communauté FiveM")
    
    await ctx.send(embed=embed)

if __name__ == "__main__":
    token = os.getenv('DISCORD_TOKEN')
    if not token:
        print("❌ Token Discord manquant!")
        print("Veuillez créer un fichier .env avec votre token:")
        print("DISCORD_TOKEN=votre_token_ici")
    else:
        bot.run(token)