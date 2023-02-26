ALTER TABLE `users` ADD `shopID` VARCHAR(50) NOT NULL DEFAULT 'MGD', ADD `shopTokens` INT NOT NULL DEFAULT '0' AFTER `shopID`, ADD `shopRank` VARCHAR(50) NOT NULL DEFAULT 'user' AFTER `shopTokens`;

CREATE TABLE `mgdshop_creatorcode` (`identifier` varchar(50) NOT NULL, `code` varchar(50) NOT NULL);

ALTER TABLE `mgdshop_creatorcode`
  ADD PRIMARY KEY (`code`);
  
CREATE TABLE `mgdshop_history_items` (`pIdentifier` VARCHAR(100) NOT NULL , `pShopID` VARCHAR(10) NOT NULL , `hDate` VARCHAR(10) NOT NULL , `hHour` VARCHAR(8) NOT NULL , `hCreatorCodeUsed` VARCHAR(50) NOT NULL , `hCategorie` VARCHAR(15) NOT NULL , `hItem` VARCHAR(100) NOT NULL , `hPrice` INT NOT NULL , `hReward` LONGTEXT NOT NULL DEFAULT "" );
ALTER TABLE `mgdshop_history_items` ADD `id` INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `mgdshop_history_items` ADD UNIQUE `noDuplicata` (`pIdentifier`, `pShopID`, `hDate`, `hHour`);

CREATE TABLE `mgdshop_history_transactions` (`sIdentifier` VARCHAR(100) NOT NULL , `sShopID` VARCHAR(10) NOT NULL , `rIdentifier` VARCHAR(100) NOT NULL , `rShopID` VARCHAR(10) NOT NULL , `hDate` VARCHAR(10) NOT NULL , `hHour` VARCHAR(8) NOT NULL , `tAmount` INT NOT NULL );
ALTER TABLE `mgdshop_history_transactions` ADD `id` INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);