"""
Utilitaires spécialisés pour le décryptage de fichiers FiveM
"""

import re
import base64
import binascii
import json
import gzip
import io

class FiveMAdvancedDecrypter:
    """Décrypteur avancé pour les formats spécifiques à FiveM"""
    
    @staticmethod
    def decrypt_escrow_protection(data):
        """
        Tente de décrypter les scripts avec protection escrow courante
        """
        try:
            # Supprime les patterns d'obfuscation courants
            patterns = [
                r'local\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*\{[^}]*\}',
                r'local\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*function\([^)]*\).*?end',
                r'--\[\[.*?\]\]',
                r'--.*?$',
            ]
            
            cleaned = data
            for pattern in patterns:
                cleaned = re.sub(pattern, '', cleaned, flags=re.MULTILINE | re.DOTALL)
            
            # Remplace les appels de fonction obfusqués
            cleaned = re.sub(r'([a-zA-Z_][a-zA-Z0-9_]*)\[(["\'])(.*?)\2\]', r'\1.\3', cleaned)
            
            return cleaned.strip()
        except Exception as e:
            return f"Erreur lors du décryptage escrow: {str(e)}"
    
    @staticmethod
    def decrypt_string_encryption(data):
        """
        Décrypte les chaînes chiffrées couramment utilisées dans FiveM
        """
        try:
            # Recherche des patterns de string.char()
            def replace_string_char(match):
                try:
                    numbers = match.group(1).split(',')
                    chars = [chr(int(n.strip())) for n in numbers if n.strip().isdigit()]
                    return '"' + ''.join(chars) + '"'
                except:
                    return match.group(0)
            
            # Remplace string.char(num1, num2, ...)
            result = re.sub(r'string\.char\(([^)]+)\)', replace_string_char, data)
            
            # Remplace les séquences d'échappement
            result = result.replace('\\n', '\n').replace('\\t', '\t').replace('\\r', '\r')
            
            return result
        except Exception as e:
            return f"Erreur lors du décryptage des chaînes: {str(e)}"
    
    @staticmethod
    def decrypt_table_obfuscation(data):
        """
        Décrypte les tables Lua obfusquées
        """
        try:
            # Remplace les accès de table obfusqués
            patterns = [
                (r'_G\[(["\'])(.*?)\1\]', r'\2'),
                (r'getfenv\(\)\[(["\'])(.*?)\1\]', r'\2'),
                (r'rawget\(_G,\s*(["\'])(.*?)\1\)', r'\2'),
            ]
            
            result = data
            for pattern, replacement in patterns:
                result = re.sub(pattern, replacement, result)
            
            return result
        except Exception as e:
            return f"Erreur lors du décryptage des tables: {str(e)}"
    
    @staticmethod
    def decrypt_cfx_resource(data):
        """
        Décrypte les ressources CFX obfusquées
        """
        try:
            # Patterns spécifiques aux ressources CFX
            cfx_patterns = [
                (r'Citizen\.CreateThread\([^)]+\)', 'CreateThread'),
                (r'Citizen\.Wait\(([^)]+)\)', r'Wait(\1)'),
                (r'RegisterNetEvent\(([^)]+)\)', r'RegisterNetEvent(\1)'),
                (r'TriggerEvent\(([^)]+)\)', r'TriggerEvent(\1)'),
                (r'AddEventHandler\(([^)]+)\)', r'AddEventHandler(\1)'),
            ]
            
            result = data
            for pattern, replacement in cfx_patterns:
                result = re.sub(pattern, replacement, result)
            
            return result
        except Exception as e:
            return f"Erreur lors du décryptage CFX: {str(e)}"
    
    @staticmethod
    def decrypt_json_config(data):
        """
        Décrypte les configurations JSON obfusquées
        """
        try:
            # Tente de parser comme JSON
            try:
                parsed = json.loads(data)
                return json.dumps(parsed, indent=2, ensure_ascii=False)
            except json.JSONDecodeError:
                pass
            
            # Nettoie les chaînes JSON malformées
            cleaned = data.replace("'", '"')
            cleaned = re.sub(r'(\w+):', r'"\1":', cleaned)
            cleaned = re.sub(r',\s*}', '}', cleaned)
            cleaned = re.sub(r',\s*]', ']', cleaned)
            
            try:
                parsed = json.loads(cleaned)
                return json.dumps(parsed, indent=2, ensure_ascii=False)
            except json.JSONDecodeError:
                return "Impossible de parser le JSON"
                
        except Exception as e:
            return f"Erreur lors du décryptage JSON: {str(e)}"
    
    @staticmethod
    def decrypt_binary_data(data):
        """
        Décrypte les données binaires encodées
        """
        try:
            # Tente différents décodages
            decoders = [
                ("Base64", lambda x: base64.b64decode(x).decode('utf-8')),
                ("Hex", lambda x: bytes.fromhex(x).decode('utf-8')),
                ("URL", lambda x: x.replace('%20', ' ').replace('%22', '"')),
            ]
            
            results = []
            for name, decoder in decoders:
                try:
                    result = decoder(data)
                    if result and len(result) > 10:  # Résultat significatif
                        results.append(f"{name}: {result[:200]}...")
                except:
                    continue
            
            return '\n'.join(results) if results else "Aucun décodage réussi"
            
        except Exception as e:
            return f"Erreur lors du décryptage binaire: {str(e)}"
    
    @staticmethod
    def decrypt_gzip_data(data):
        """
        Décrypte les données compressées avec gzip
        """
        try:
            # Tente de décoder en base64 puis décompresser
            try:
                decoded = base64.b64decode(data)
                decompressed = gzip.decompress(decoded)
                return decompressed.decode('utf-8')
            except:
                pass
            
            # Tente de décompresser directement
            try:
                if isinstance(data, str):
                    data = data.encode('utf-8')
                decompressed = gzip.decompress(data)
                return decompressed.decode('utf-8')
            except:
                pass
            
            return "Impossible de décompresser les données gzip"
            
        except Exception as e:
            return f"Erreur lors du décryptage gzip: {str(e)}"
    
    @staticmethod
    def auto_decrypt_advanced(data):
        """
        Décryptage automatique avec toutes les méthodes avancées
        """
        methods = [
            ("Protection Escrow", FiveMAdvancedDecrypter.decrypt_escrow_protection),
            ("Chiffrement de chaînes", FiveMAdvancedDecrypter.decrypt_string_encryption),
            ("Obfuscation de tables", FiveMAdvancedDecrypter.decrypt_table_obfuscation),
            ("Ressource CFX", FiveMAdvancedDecrypter.decrypt_cfx_resource),
            ("Configuration JSON", FiveMAdvancedDecrypter.decrypt_json_config),
            ("Données binaires", FiveMAdvancedDecrypter.decrypt_binary_data),
            ("Compression gzip", FiveMAdvancedDecrypter.decrypt_gzip_data),
        ]
        
        results = []
        for method_name, method in methods:
            try:
                result = method(data)
                if result and not result.startswith("Erreur") and not result.startswith("Impossible"):
                    # Vérifie si le résultat est significatif
                    if len(result) > 20 and result != data:
                        results.append({
                            "method": method_name,
                            "result": result[:500] + ("..." if len(result) > 500 else ""),
                            "full_length": len(result)
                        })
            except Exception as e:
                continue
        
        return results

class FiveMAnalyzer:
    """Analyseur pour identifier le type de fichier FiveM"""
    
    @staticmethod
    def analyze_file_type(data):
        """
        Analyse le type de fichier FiveM
        """
        if not data:
            return "Fichier vide"
        
        # Vérifie les indicateurs de type
        if data.strip().startswith('fx_version'):
            return "FXManifest"
        elif 'RegisterNetEvent' in data or 'AddEventHandler' in data:
            return "Script Client/Server"
        elif data.strip().startswith('{') and data.strip().endswith('}'):
            return "Configuration JSON"
        elif 'CREATE TABLE' in data.upper():
            return "Script SQL"
        elif '<html' in data.lower():
            return "Interface HTML"
        elif ('function(' in data and 'end' in data) or ('function ' in data and 'end' in data):
            return "Script Lua"
        elif re.search(r'^[0-9a-fA-F]+$', data.strip()) and len(data.strip()) % 2 == 0:
            return "Données Hexadécimales"
        elif re.search(r'^[A-Za-z0-9+/]+=*$', data.strip()):
            return "Données Base64"
        else:
            return "Type inconnu"
    
    @staticmethod
    def get_recommended_methods(file_type):
        """
        Recommande les méthodes de décryptage selon le type de fichier
        """
        recommendations = {
            "Script Lua": ["lua", "escrow", "string_encryption"],
            "Configuration JSON": ["json", "base64"],
            "Données Base64": ["base64", "gzip"],
            "Données Hexadécimales": ["hex", "binary"],
            "Script Client/Server": ["cfx", "lua", "escrow"],
            "Type inconnu": ["auto"]
        }
        
        return recommendations.get(file_type, ["auto"])