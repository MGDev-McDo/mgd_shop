Config = {
    --↓ Promotional message
        --→ Send the message || Options : true / false
        promotStatut = true,
        --→ Time between messages || Exemple : 60 * 60000 = 60 minutes
        promotTime = 60 * 60000,
        --→ Promotional message content
        promotMessage = "N'hésites pas à venir voir le contenu de la boutique !",

    --↓ Creator code
        --→ Enable the create code system || Options : true / false
        codeStatut = true,
        --→ Percentage of price for reward
        codeReward = 10,
        --→ Notification to creator if is online when code is used
        codeNotification = true,

    --↓ Categories in the shop || Options : true / false
        --→ Enable ranks categorie
        catRanks = true,
        --→ Enable vehicles categorie
        catVehicles = true,
        --→ Enable weapons categorie
        catWeapons = true,
        --→ Amount of ammo when buying a weapon
        ammoWeapon = 100,
        --→ Enable money categorie
        catMoney = true,
        --→ Enable lootboxs categorie
        catLootboxs = true,
    
    --↓ Other configurations
        --→ Enable player to send credits to another player || Options : true / false
        sendCredits = true,
        --→ Label for credits
        creditName = "Jeton",
        --→ Server name
        serverName = "The Roleplay",
        --→ Group that can access to admin space
        accessAdmin = "superadmin",
        --→ Default rank (/!\ Care the value must be the same as the default value in users table in db /!\)
        defaultRank = "Joueur",
        --→ Command name opening menu
        commandName = "boutique",
        --→ Default opening menu key
        openingKey = "F9",
}

Config.HistoryCategories = {
    "rank", "vehicle", "money", "weapon", "lootbox", "send", "receive"
}

Config.Ranks = {
    { label = "Argentum", price = 150 },
    { label = "Aurum", price = 250 },
    { label = "Platinum", price = 500 },
}

Config.Vehicles = {
    { label = "XA-21", model = "xa21", price = 100 },
    { label = "DR1", model = "openwheel2", price = 500 },
    { label = "Toros", model = "toros", price = 250 },
}

Config.Weapons = {
    { label = "Pistol Mk II", name = "weapon_pistol_mk2", price = 200 },
    { label = "SNS Pistol Mk II", name = "weapon_snspistol_mk2", price = 200 },
    { label = "Heavy Revolver Mk II", name = "weapon_revolver_mk2", price = 500 },
    { label = "SMG Mk II", name = "weapon_smg_mk2", price = 1000 },
    { label = "Pump Shotgun Mk II", name = "weapon_pumpshotgun_mk2", price = 2500 },
    { label = "Combat Shotgun", name = "weapon_combatshotgun", price = 2500 },
    { label = "Assault Rifle Mk II", name = "weapon_assaultrifle_mk2", price = 5000 },
}

Config.Money = {
    { amount = 10000, name = "moneypack_10000", price = 100 },
    { amount = 100000, name = "moneypack_100000", price = 1000 },
    { amount = 500000, name = "moneypack_500000", price = 5000 },
}

Config.Lootboxs = {
    { 
        label = "Caisse Fer", name = "caisse1", price = 1000,
        loots = {
            { type = "rank", label = "Argentum" },
            { type = "vehicle", model = "openwheel2", label = "DR1" },
            { type = "weapon", name = "weapon_combatshotgun", label = "Combat Shotgun" },
            { type = "money", amount = 200000, label = "200 000$" },
            { type = "credit", amount = 500, label = "500 " .. Config.creditName .. "(s)" }
        }
    },
    {
        label = "Caisse Or", name = "caisse2", price = 2000,
        loots = {
            { type = "rank", name = "Argentum", label = "Argentum" },
            { type = "vehicle", model = "openwheel2", label = "DR1" },
            { type = "weapon", name = "weapon_combatshotgun", label = "Combat Shotgun" },
            { type = "money", amount = 300000, label = "300 000$" },
            { type = "credit", amount = 600, label = "600 " .. Config.creditName .. "(s)" }
        }
    },
    { 
        label = "Caisse Diamant", name = "caisse3", price = 3000,
        loots = {
            { type = "rank", name = "Argentum", label = "Argentum" },
            { type = "rank", name = "Aurum", label = "Aurum" },
            { type = "rank", name = "Platinum", label = "Platinum" },
            { type = "vehicle", model = "openwheel2", label = "DR1" },
            { type = "weapon", name = "weapon_combatshotgun", label = "Combat Shotgun" },
            { type = "money", amount = 400000, label = "400 000$" },
            { type = "credit", amount = 1000, label = "1000 " .. Config.creditName .. "(s)" }
        }
    },
}

--↓ Language for messages || Options : fr
_Lang = "fr"

Messages = {
    ["fr"] = {
        ["keyMapping_label"] = "Ouvrir la boutique",
        ["playerdead"] = "~r~Tu ne peux pas ouvrir la boutique en étant mort.",
        ["menu_title"] = "Boutique",
        ["menu_subtitle"] = "Bienvenue sur la boutique",
        
        ["menu_playerInfo"] = "~c~↓ A propos de toi ↓",
        ["menu_playerInfo_shopID"] = "Identifiant boutique : ~p~%s",
        ["menu_playerInfo_creatorcode"] = "Code créateur actif : ~p~%s",
        ["menu_playerInfo_shopCredits"] = "Balance : ~p~%s " .. Config.creditName .. "(s)",
        ["menu_playerInfo_rank"] = "Grade : ~p~%s",
        ["menu_playerInfo_history"] = "Historique",
        ["menu_active_creatorCode"] = "Activer un code créateur",
        ["menu_admin"] = "~r~Administration~s~",
        ["menu_admin_creatorCode"] = "Codes créateurs",
        ["menu_admin_history"] = "Historique",
        ["menu_admin_history_cat"] = "Catégories",
        ["menu_admin_history_player"] = "Joueur",
        ["menu_admin_player"] = "Actions Joueur",
        ["menu_admin_creatorCode_create"] = "Créer un nouveau code",
        ["menu_admin_creatorCode_manage"] = "Gestion d'un code",

        ["menu_categories"] = "~c~↓ Catégories d'achats ↓",
        ["menu_categories_rank"] = "Grades",
        ["menu_categories_vehicles"] = "Véhicules",
        ["menu_categories_vehicles_alert"] = "~r~/!\\ Le véhicule spawn sur place /!\\",
        ["menu_categories_weapons"] = "Armes",
        ["menu_categories_money"] = "Argent",
        ["menu_categories_lootboxs"] = "Caisses",
        ["menu_categories_send"] = "Envoyer des " .. Config.creditName .. "(s)",

        ------------------------------------------------------------------

        ["bank_title"] = "Maze Banque",
        ["bank_subtitle"] = "~c~Notification",
        ["bank_content"] = "Vous avez reçu un virement.\n~c~> ~s~SUBVENTION : ~g~+%s$",

        ["creatorCode_title"] = "~c~CODE CREATEUR",
        ["creatorCode_used"] = "Ton code créateur a été utilisé.\nRécompense : ~p~%s %s.",

        ["history_title_buy"] = "~p~Achat du %s",
        ["history_title_send"] = "~p~Transaction du %s",
        ["history_type"] = "Acheté : %s",
        ["history_price"] = "Prix : %s " .. Config.creditName .. "(s)",
        ["history_code"] = "Code créateur : %s",
        ["history_label_buy"] = "Cat. %s",
        ["history_label_send"] = "%s",
        ["history_transac"] = "Transaction : %s " .. Config.creditName .. "(s)",
        ["history_toFrom"] = "Envoyé/Reçu de : %s",

        ------------------------------------------------------------------

        ["mgd_title"] = "MGD • Dev Info",
        ["mgd_success"] = "~g~Succès",
        ["mgd_error"] = "~r~Erreur",
        ["mgd_infos"] = "~b~Information",
        ["mgd_first_open"] = "~c~PREMIERE OUVERTURE",
        ["mgd_first_openContent"] = "Bienvenue sur la boutique, c'est la première fois.\nVoici ton ID boutique : ~p~%s~s~.",
        ["mgd_notEnoughTokens"] = "Il te manque ~r~%s " .. Config.creditName .. "(s) ~s~pour acheter cela.",
        ["mgd_error_firstOpen"] = "L'update du nouvel ID a rencontré un problème.",
        ["mgd_error_playerData"] = "Le callback n'a renvoyé aucune information sur le joueur.",
        ["mgd_error_menuData"] = "La catégorie %s n'a aucune donnée.",
        ["mgd_error_buyResponse"] = "L'achat de ~p~%s ~s~a rencontré un problème.\n%s → %s → %s\n~r~%s",
        ["mgd_error_alreadyBought"] = "Tu possèdes déjà ~r~%s~s~.",
        ["mgd_error_emptycreaCode"] = "Tu n'as pas spécifié de code créateur.\nCelui-ci a donc été réinitialisé.",
        ["mgd_error_invalidcreaCode"] = "Ce code créateur n'existe pas.",
        ["mgd_admin_creatorCode_createCode"] = "Code créateur",
        ["mgd_admin_creatorCode_createIdentifier"] = "Identifier",
        ["mgd_admin_creatorCode_confirm"] = "~g~Créer",
        ["mgd_admin_error_emptycreaCodeLabel"] = "Aucun code renseigné.",
        ["mgd_admin_error_emptycreaCodeIdentifier"] = "Aucun identifier renseigné",
        ["mgd_admin_success_creaCode"] = "Le code créateur ~p~%s ~s~viens d'être créé.",
        ["mgd_success_creaCode"] = "Tu utilises désormais le code ~p~%s ~s~pour tes achats.",
        ["mgd_buy_rank"] = "Tu viens d'acheter le grade ~p~%s~s~ pour %s %s(s).\nIl te reste ~g~%s %s(s)~s~.",
        ["mgd_buy_money"] = "Tu viens d'acheter un pack de ~p~%s$~s~ pour %s %s(s).\nIl te reste ~g~%s %s(s)~s~.",
        ["mgd_buy_weapon"] = "Tu viens d'acheter un(e) ~p~%s~s~ pour %s %s(s).\nIl te reste ~g~%s %s(s)~s~.",
        ["mgd_buy_vehicle"] = "Tu viens d'acheter un(e) ~p~%s~s~ pour %s %s(s).\nIl te reste ~g~%s %s(s)~s~.",
        ["mgd_buy_lootbox"] = "Tu viens d'acheter un(e) ~p~%s~s~ pour %s %s(s).\nIl te reste ~g~%s %s(s)~s~.",
        ["mgd_lootbox_title"] = "~p~Loots disponibles :~s~",
        ["mgd_lootbox_reward"] = "Tu as gagné un(e) ~p~%s~s~.\n~g~Bravo !",
        ["mgd_reward_alreadyRank"] = "Tu avais déjà ce rang ou mieux.\nTu as donc reçu ~p~%s " .. Config.creditName .. "(s) ~s~à la place.",
        ["mgd_admin_success_createCreaCode"] = "Tu as créé le code créateur ~p~%s ~s~associé à l'identifier ~p~%s~s~.",
        ["mgd_admin_error_createCreaCode"] = "La création du code créateur a rencontré un problème.",
        ["menu_admin_creatorCode_list"] = "~c~↓ Codes existants ↓",
        ["menu_admin_creatorCode_manage_changeCode"] = "Modifier le code créateur",
        ["menu_admin_creatorCode_manage_changeIdentifier"] = "Modifier l'identifier lié",
        ["menu_admin_creatorCode_manage_delete"] = "~r~Supprimer le code",
        ["menu_admin_creatorCode_manage_actions"] = "~c~↓ Actions ↓",
        ["menu_admin_creatorCode_manage_titleIdentifier"] = "Identifier : ~p~%s",
        ["menu_admin_creatorCode_manage_titleCode"] = "Code créateur : ~p~%s",
        ["menu_admin_forcePromoteMessage"] = "Forcer le message promotionnel",
        ["mgd_sendMenu_boutiqueID"] = "ID Boutique",
        ["mgd_sendMenu_quantity"] = "Quantité",
        ["mgd_sendMenu_emptyShopID"] = "Tu n'as pas précisé d'ID boutique.",
        ["mgd_sendMenu_emptyQuantity"] = "Tu n'as pas précisé de quantité ou elle est inférieur à 0.",
        ["mgd_sendMenu_notEnoughQuantity"] = "Tu n'as pas autant de " .. Config.creditName .. "(s).",
        ["mgd_sendMenu_confirm"] = "~g~Envoyer",
        ["mgd_sendMenu_success"] = "Tu as envoyé ~p~%s " .. Config.creditName .. "(s) ~s~à l'ID ~p~%s~s~.",
        ["mgd_sendCredits_error_unknowShopID"] = "Cet ID boutique n'est pas attribué.",
        ["mgd_sendCredits_error_noData"] = "Le serveur n'a pas réussi à récupérer tes données.",
        ["mgd_sendCredits_error_processing"] = "Le serveur a rencontré un problème pendant la procédure.",
        ["sendCredits_title"] = "~c~Virement de " .. Config.creditName .. "(s)",
        ["sendCredits_content"] = "Tu as reçu ~g~%s " .. Config.creditName .. "(s)~s~ de ~p~%s~s~.",
        ["mgd_success_sendMenu"] = "Tu as envoyé ~r~%s " .. Config.creditName .. "(s)~s~ à ~p~%s~s~.",
        ["mgd_typeName_send"] = "Envoie",
        ["mgd_typeName_receive"] = "Réception",
        ["mgd_success_deleteCreatorCode"] = "Tu as supprimé le code créateur ~p~%s~s~.",
        ["mgd_error_deleteCreatorCode"] = "Le serveur a rencontré un problème pendant la procédure.",
        ["mgd_error_editCreatorCode"] = "Le serveur a rencontré un problème pendant la procédure.",
        ["mgd_success_editCreatorCode_code"] = "Tu as modifié le code créateur.\nNouveau code : ~p~%s~s~.",
        ["mgd_success_editCreatorCode_identifier"] = "Tu as modifié l'identifier lié au code créateur.\nNouvel identifier : ~p~%s~s~.",
        ["mgd_admin_error_emptyIdentifier"] = "Tu n'as pas précisé de filtre.",
        ["mgd_admin_historyPlayer_filter"] = "Filtre",
        ["mgd_admin_historyPlayer_filterInfo"] = "Identifier ou ID Boutique",
        ["mgd_admin_player_filter"] = "Filtre",
        ["mgd_admin_player_filterInfo"] = "ID ig ou ID Boutique\nSi ID Boutique, l'action est possible même si le joueur n'est pas connecté.",
        ["mgd_admin_player_addCredits"] = "Donner des " .. Config.creditName .. "s",
        ["mgd_admin_player_removeCredits"] = "Retirer des " .. Config.creditName .. "s",
        ["mgd_admin_error_emptyQuantity"] = "Tu n'as pas précisé de quantité ou elle est inférieur à 0.",
        ["mgd_error_playerIdnotonline"] = "L'ID renseigné n'est associé à aucun joueur in game.",
        ["mgd_admin_error_emptyFilter"] = "Tu n'as pas précisé de filtre ou celui-ci est invalide.",
        ["mgd_error_playerProcess"] = "Le serveur a rencontré un problème pendant la procédure.",
        ["mgd_admin_receiveAddCredits"] = "Un administrateur viens de te donner ~g~%s ".. Config.creditName .. "(s)~s~.",
        ["mgd_admin_receiveRemoveCredits"] = "Un administrateur viens de te retirer ~r~%s ".. Config.creditName .. "(s)~s~.",
        ["mgd_success_addCredits"] = "Tu as donné ~g~%s ".. Config.creditName .. "(s)~s~ à l'id ~p~%s~s~.",
        ["mgd_success_removeCredits"] = "Tu as retiré ~r~%s ".. Config.creditName .. "(s)~s~ à l'id ~p~%s~s~.",
    }
}