-- ====================================
-- FARMING CREATOR - CUSTOM ITEMS EXAMPLES
-- ====================================
-- Exemples d'items personnalisés pour tester le système

-- IMPORTANT: Ces items sont des exemples pour tester le système
-- En production, utilisez les commandes in-game pour créer vos items

-- ====================================
-- EXEMPLES D'ITEMS PERSONNALISÉS
-- ====================================

-- Items de test pour vérifier que le système fonctionne
INSERT INTO `custom_items_creator` 
(`item_name`, `item_label`, `weight`, `rare`, `can_remove`, `stackable`, `usable`, `description`, `creator_identifier`, `creator_name`, `is_suggestion`) 
VALUES
-- Item de nourriture
('pizza_deluxe', 'Pizza Deluxe', 2, 0, 1, 1, 1, 'Une pizza gastronomique qui redonne 75% de santé', 'system', 'Système', 0),

-- Item d'outil
('multitool_advanced', 'Multi-outil Avancé', 3, 1, 1, 0, 1, 'Un outil polyvalent pour diverses réparations', 'system', 'Système', 0),

-- Item de matériau
('metal_rare', 'Métal Rare', 5, 1, 1, 1, 0, 'Un alliage métallique extrêmement rare et précieux', 'system', 'Système', 0),

-- Item de drogue (exemple RP)
('weed_premium', 'Cannabis Premium', 1, 1, 1, 1, 1, 'Cannabis de haute qualité cultivé avec soin', 'system', 'Système', 0),

-- Item d'accessoire
('montre_luxe', 'Montre de Luxe', 1, 1, 1, 0, 0, 'Une montre suisse haut de gamme', 'system', 'Système', 0);

-- ====================================
-- EXEMPLES DE SUGGESTIONS
-- ====================================

-- Suggestions d'items (is_suggestion = 1)
INSERT INTO `custom_items_creator` 
(`item_name`, `item_label`, `weight`, `rare`, `can_remove`, `stackable`, `usable`, `description`, `creator_identifier`, `creator_name`, `is_suggestion`) 
VALUES
-- Suggestion d'item de véhicule
('nitro_boost', 'Kit Nitro', 2, 1, 1, 0, 1, 'Kit de nitro pour véhicules de course', 'license:xxxxx', 'PlayerTest', 1),

-- Suggestion d'item médical
('medkit_military', 'Trousse Militaire', 3, 1, 1, 1, 1, 'Trousse médicale militaire complète', 'license:yyyyy', 'StaffMember', 1),

-- Suggestion d'item électronique
('smartphone_encrypted', 'Téléphone Crypté', 1, 1, 1, 0, 1, 'Smartphone avec chiffrement avancé pour communications sécurisées', 'license:zzzzz', 'TechStaff', 1);

-- ====================================
-- INSERTION DANS LA TABLE ITEMS ESX
-- ====================================

-- Ces items doivent aussi être ajoutés à la table items d'ESX
-- (Normalement fait automatiquement par le système)

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('pizza_deluxe', 'Pizza Deluxe', 2, 0, 1),
('multitool_advanced', 'Multi-outil Avancé', 3, 1, 1),
('metal_rare', 'Métal Rare', 5, 1, 1),
('weed_premium', 'Cannabis Premium', 1, 1, 1),
('montre_luxe', 'Montre de Luxe', 1, 1, 1);

-- ====================================
-- COMMANDES DE TEST
-- ====================================

-- Pour tester le système, connectez-vous au serveur et utilisez:
-- /createitem - Pour créer un nouvel item
-- /itemmenu - Pour gérer les items créés
-- /suggestitem - Pour suggérer un item

-- ====================================
-- REQUÊTES DE VÉRIFICATION
-- ====================================

-- Vérifier tous les items personnalisés créés
-- SELECT * FROM custom_items_creator WHERE is_suggestion = 0;

-- Vérifier toutes les suggestions
-- SELECT * FROM custom_items_creator WHERE is_suggestion = 1;

-- Vérifier qu'un item existe dans la table ESX
-- SELECT * FROM items WHERE name = 'pizza_deluxe';

-- Statistiques des items par créateur
-- SELECT creator_name, COUNT(*) as items_created 
-- FROM custom_items_creator 
-- WHERE is_suggestion = 0 
-- GROUP BY creator_name;

-- ====================================
-- NETTOYAGE (SI NÉCESSAIRE)
-- ====================================

-- Pour supprimer tous les items de test:
-- DELETE FROM custom_items_creator WHERE creator_name = 'Système';
-- DELETE FROM items WHERE name IN ('pizza_deluxe', 'multitool_advanced', 'metal_rare', 'weed_premium', 'montre_luxe');