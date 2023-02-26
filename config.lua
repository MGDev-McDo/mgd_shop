function _(str, ...)
	if Messages[_Lang] ~= nil then
		if Messages[_Lang][str] ~= nil then
			return string.format(Messages[_Lang][str], ...)
		else
			return str .. " doesn't have translation"
		end
	end
end

Config = {
    --↓ Promotional message
        --→ Send the message || Options : true / false
        promotStatut = true,
        --→ Time between messages || Exemple : 60 * 60000 = 60 minutes
        promotTime = 60 * 60000,
        --→ Promotional message content
        promotMessage = "N'hésites pas à venir voir le contenu de la boutique !",
    -- --

    --↓ Command
        --→ Admin Group for commands
        commandAdmin = "superadmin",
        --→ Command name
        commandName = "boutique",
        --→ Default opening shop key
        openingKey = "F9",
    -- --

    --↓ Creator code
        --→ Percentage of price for creator reward
        codeReward = 10,
        --→ Notification to creator if is online when his code is used
        codeNotification = true,
    -- --

}

--↓ Language for messages || Options : fr
_Lang = "fr"

Messages = {
    ["fr"] = {
        --[[ ShopNotification(object, message)]]--
        ["mgd_shop_title"] = "Boutique",
        ["mgd_shop_error"] = "~r~Erreur",
        ["mgd_shop_error_playerdead"] = "~r~Tu ne peux pas ouvrir la boutique en étant mort.",
        ["mgd_shop_creator_title"] = "~c~Code créateur",
        ["mgd_shop_creator_used"] = "Ton code créateur a été utilisé.\nRécompense : ~p~%s coins.",
        ["mgd_shop_credits_title"] = "~c~Virement de coins",
        ["mgd_shop_credits_content"] = "Tu as reçu ~g~%s coins~s~ de ~p~%s~s~.",
        ["mgd_shop_admin"] = "~c~Action admin",
        ["mgd_shop_admin_coins_give"] = "Un administrateur t'a donné ~g~%s coins~s~.",
        ["mgd_shop_admin_coins_remove"] = "Un administrateur t'a retiré ~r~%s coins~s~.",
        ["mgd_shop_admin_coins_set"] = "Un administrateur a défini tes coins à ~b~%s coins~s~.",
        ["mgd_shop_admin_rank"] = "Un administrateur a défini ton rang sur ~g~le rang %s~s~.",
        ["mgd_shop_admin_newShopID"] = "Un administrateur a défini ton ID Boutique à ~b~MGD-%s~s~.",

        --[[ MGD(message) ]]--
        ["mgd_dev_title"] = "MGD • Dev Info",
        ["mgd_dev_error"] = "~r~Erreur",
        ["mgd_dev_error_firstOpen"] = "L'update du nouvel ID a rencontré un problème.",
        ["mgd_dev_error_playerData"] = "Aucune informations obtenues sur le joueur.",

        --[[ BANK ]]--
        ["mgd_bank_title"] = "Maze Banque",
        ["mgd_bank_object"] = "~c~Notification",
        ["mgd_bank_content"] = "Vous avez reçu un virement.\n~c~> ~s~SUBVENTION : ~g~+%s$",

        --[[ BACK TO NUI ]]--
        ["mgd_nui_error_processing"] = "Le serveur a rencontré un problème pendant la procédure.",
        ["mgd_nui_error_purse"] = "Tu n'as pas autant de coins.",
        ["mgd_nui_error_playerData"] = "Le serveur n'a pas réussi à récupérer tes données.",
        ["mgd_nui_error_serverID"] = "L'ID spécifié n'est pas connecté.",
        ["mgd_nui_error_shopID"] = "L'ID boutique n'est pas attribué.",

        --[[ COMMANDS ]]--
        ["mgd_command_keyMapping"] = "Ouvrir la boutique",
        ["mgd_command_admin_givecoins"] = "Donner des coins à un joueur",
        ["mgd_command_admin_removecoins"] = "Retirer des coins à un joueur",
        ["mgd_command_admin_setcoins"] = "Définir les coins d'un joueur",
        ["mgd_command_admin_setrank"] = "Définir le rang d'un joueur",
        ["mgd_command_admin_setshopid"] = "Définir l'ID Boutique d'un joueur",
        ["mgd_command_admin_forcepromote"] = "Forcer l'envoie du message pour promouvoir la boutique",
        ["mgd_command_args_playerid"] = "ID Serveur",
        ["mgd_command_args_newShopID"] = "Nouveau ID Boutique (Ex: 1578)",
        ["mgd_command_args_amount"] = "Montant",
        ["mgd_command_args_action"] = "Action (give/remove/set)",
        ["mgd_command_args_rank"] = "Rang",
        ["mgd_command_error_amount"] = "Le montant ne peut pas être inférieur à 0",
        ["mgd_command_error_processing"] = "Erreur lors de la procédure.",
        ["mgd_command_error_rank"] = "Ce rang n'existe pas.",
        ["mgd_command_error_newShopID"] = "Cet ID Boutique est déjà utilisé.",
        ["mgd_command_success"] = "Action effectuée avec succès !",
    }
}