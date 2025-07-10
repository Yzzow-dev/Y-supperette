-- ====================================
-- FARMING CREATOR - ITEMS DATABASE
-- ====================================
-- Ce fichier contient tous les items nécessaires pour le système de farming

-- Graines (Seeds)
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('orange_seed', 'Graines d\'Orange', 1, 0, 1),
('apple_seed', 'Graines de Pomme', 1, 0, 1),
('wheat_seed', 'Graines de Blé', 1, 0, 1),
('carrot_seed', 'Graines de Carotte', 1, 0, 1),
('corn_seed', 'Graines de Maïs', 1, 0, 1),
('grape_seed', 'Graines de Raisin', 1, 0, 1);

-- Produits récoltés (Harvested items)
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('orange', 'Orange', 1, 0, 1),
('apple', 'Pomme', 1, 0, 1),
('wheat', 'Blé', 1, 0, 1),
('carrot', 'Carotte', 1, 0, 1),
('corn', 'Maïs', 1, 0, 1),
('grape', 'Raisin', 1, 0, 1);

-- Produits transformés (optionnel - pour un système de crafting futur)
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('orange_juice', 'Jus d\'Orange', 1, 0, 1),
('apple_juice', 'Jus de Pomme', 1, 0, 1),
('bread', 'Pain', 1, 0, 1),
('carrot_soup', 'Soupe de Carotte', 1, 0, 1),
('corn_flour', 'Farine de Maïs', 1, 0, 1),
('wine', 'Vin', 1, 0, 1);

-- Outils de farming (optionnel)
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('farming_hoe', 'Houe', 3, 0, 1),
('farming_watering_can', 'Arrosoir', 2, 0, 1),
('farming_fertilizer', 'Engrais', 1, 0, 1),
('farming_basket', 'Panier de Récolte', 2, 0, 1);

-- ====================================
-- MISE À JOUR DE LA BASE DE DONNÉES
-- ====================================

-- Si vous avez déjà des items avec ces noms, utilisez UPDATE au lieu d'INSERT
-- Exemple pour mettre à jour un item existant :
-- UPDATE `items` SET `label` = 'Nouvelle Orange', `weight` = 1 WHERE `name` = 'orange';

-- ====================================
-- VÉRIFICATION DES ITEMS
-- ====================================

-- Pour vérifier que tous les items ont été ajoutés :
-- SELECT * FROM `items` WHERE `name` LIKE '%seed' OR `name` IN ('orange', 'apple', 'wheat', 'carrot', 'corn', 'grape');

-- ====================================
-- CONFIGURATION POUR LES SHOPS
-- ====================================

-- Si vous utilisez esx_shops, vous pouvez ajouter les graines dans un magasin :
/*
INSERT INTO `shops` (`name`, `item`, `price`) VALUES
('TwentyFourSeven', 'orange_seed', 50),
('TwentyFourSeven', 'apple_seed', 45),
('TwentyFourSeven', 'wheat_seed', 25),
('TwentyFourSeven', 'carrot_seed', 20),
('TwentyFourSeven', 'corn_seed', 75),
('TwentyFourSeven', 'grape_seed', 100);
*/

-- ====================================
-- JOBS CONFIGURATION (OPTIONNEL)
-- ====================================

-- Si vous voulez créer un job de fermier :
/*
INSERT INTO `jobs` (`name`, `label`) VALUES
('farmer', 'Fermier');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('farmer', 0, 'trainee', 'Apprenti Fermier', 200, '{}', '{}'),
('farmer', 1, 'worker', 'Fermier', 400, '{}', '{}'),
('farmer', 2, 'manager', 'Chef Fermier', 600, '{}', '{}'),
('farmer', 3, 'boss', 'Propriétaire de Ferme', 800, '{}', '{}');
*/