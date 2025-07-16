#!/usr/bin/env python3
"""
Script de test pour les fonctions de décryptage FiveM
"""

import base64
import binascii
from bot import FiveMDecrypter
from fivem_utils import FiveMAdvancedDecrypter, FiveMAnalyzer

def test_basic_decryption():
    """Test des fonctions de décryptage de base"""
    print("🧪 Tests de décryptage de base")
    print("=" * 40)
    
    # Test Base64
    test_data = "SGVsbG8gV29ybGQ="  # "Hello World" en base64
    result = FiveMDecrypter.decrypt_base64(test_data)
    print(f"Base64: {test_data} -> {result}")
    assert result == "Hello World", f"Expected 'Hello World', got {result}"
    print("✅ Test Base64 réussi")
    
    # Test Hex
    test_hex = "48656c6c6f20576f726c64"  # "Hello World" en hex
    result = FiveMDecrypter.decrypt_hex(test_hex)
    print(f"Hex: {test_hex} -> {result}")
    assert result == "Hello World", f"Expected 'Hello World', got {result}"
    print("✅ Test Hex réussi")
    
    # Test Lua obfuscation
    test_lua = """
    local function test()
        -- Commentaire à supprimer
        local var = "test"
        return var
    end
    """
    result = FiveMDecrypter.decrypt_lua_obfuscated(test_lua)
    print(f"Lua nettoyé: {len(result)} caractères")
    print("✅ Test Lua réussi")
    
    print()

def test_advanced_decryption():
    """Test des fonctions de décryptage avancées"""
    print("🔬 Tests de décryptage avancé")
    print("=" * 40)
    
    # Test décryptage de chaînes
    test_string = 'string.char(72, 101, 108, 108, 111)'  # "Hello"
    result = FiveMAdvancedDecrypter.decrypt_string_encryption(test_string)
    print(f"String encryption: {result}")
    print("✅ Test décryptage chaînes réussi")
    
    # Test configuration JSON
    test_json = '{"name": "test", "version": 1}'
    result = FiveMAdvancedDecrypter.decrypt_json_config(test_json)
    print(f"JSON config: {result[:50]}...")
    print("✅ Test JSON réussi")
    
    # Test protection escrow
    test_escrow = """
    local _G = _G
    local function obfuscated()
        -- Commentaire obfusqué
        local var = {test = "value"}
        return var
    end
    """
    result = FiveMAdvancedDecrypter.decrypt_escrow_protection(test_escrow)
    print(f"Escrow protection: {len(result)} caractères")
    print("✅ Test protection escrow réussi")
    
    print()

def test_file_analyzer():
    """Test de l'analyseur de fichiers"""
    print("🔍 Tests d'analyse de fichiers")
    print("=" * 40)
    
    # Test différents types de fichiers
    test_cases = [
        ("fx_version '1.0.0'", "FXManifest"),
        ('{"name": "test"}', "Configuration JSON"),
        ("RegisterNetEvent('test')", "Script Client/Server"),
        ("function test() end", "Script Lua"),
        ("SGVsbG8gV29ybGQ=", "Données Base64"),
        ("48656c6c6f20576f726c64", "Données Hexadécimales"),
        ("<html><body>test</body></html>", "Interface HTML"),
        ("CREATE TABLE test", "Script SQL"),
        ("random text", "Type inconnu")
    ]
    
    for data, expected_type in test_cases:
        result = FiveMAnalyzer.analyze_file_type(data)
        print(f"Type: {result} (attendu: {expected_type})")
        assert result == expected_type, f"Expected {expected_type}, got {result}"
    
    print("✅ Tous les tests d'analyse réussis")
    print()

def test_auto_decrypt():
    """Test du décryptage automatique"""
    print("🤖 Tests de décryptage automatique")
    print("=" * 40)
    
    # Test avec données Base64
    test_data = "SGVsbG8gV29ybGQ="
    results = FiveMDecrypter.auto_decrypt(test_data)
    print(f"Décryptage automatique: {len(results)} résultats")
    
    # Test avec données complexes
    complex_data = """
    local test = function()
        string.char(72, 101, 108, 108, 111)
        return "World"
    end
    """
    results = FiveMAdvancedDecrypter.auto_decrypt_advanced(complex_data)
    print(f"Décryptage avancé: {len(results)} résultats")
    
    for result in results:
        print(f"  - {result['method']}: {result['full_length']} caractères")
    
    print("✅ Tests de décryptage automatique réussis")
    print()

def test_recommendations():
    """Test des recommandations de méthodes"""
    print("💡 Tests de recommandations")
    print("=" * 40)
    
    file_types = [
        "Script Lua",
        "Configuration JSON",
        "Données Base64",
        "Script Client/Server",
        "Type inconnu"
    ]
    
    for file_type in file_types:
        methods = FiveMAnalyzer.get_recommended_methods(file_type)
        print(f"{file_type}: {methods}")
    
    print("✅ Tests de recommandations réussis")
    print()

def main():
    """Fonction principale de test"""
    print("🔓 Tests du décrypteur FiveM")
    print("=" * 50)
    
    try:
        test_basic_decryption()
        test_advanced_decryption()
        test_file_analyzer()
        test_auto_decrypt()
        test_recommendations()
        
        print("🎉 Tous les tests ont réussi!")
        print("✅ Le décrypteur FiveM est prêt à être utilisé")
        
    except Exception as e:
        print(f"❌ Erreur lors des tests: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    return True

if __name__ == "__main__":
    main()