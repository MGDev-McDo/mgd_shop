ALTER TABLE `users` ADD `shopID` VARCHAR(50) NOT NULL DEFAULT 'MGD', ADD `shopTokens` INT NOT NULL DEFAULT '0' AFTER `shopID`, ADD `shopRank` VARCHAR(50) NOT NULL DEFAULT 'Joueur' AFTER `shopTokens`;

CREATE TABLE `mgdshop_history` (
  `identifier` varchar(50) NOT NULL,
  `time` varchar(24) NOT NULL,
  `categ` varchar(50) NOT NULL,
  `data` longtext NOT NULL
);

CREATE TABLE `mgdshop_creatorcode` (
  `identifier` varchar(50) NOT NULL,
  `code` varchar(50) NOT NULL
);

ALTER TABLE `mgdshop_creatorcode`
  ADD PRIMARY KEY (`code`);

ALTER TABLE `mgdshop_history` CHANGE `identifier` `identifier` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, CHANGE `time` `time` VARCHAR(24) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, CHANGE `categ` `categ` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, CHANGE `data` `data` LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;