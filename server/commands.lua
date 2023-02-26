ESX.RegisterCommand('shop:coins', Config.commandAdmin, function(xPlayer, args, showError)
	local target = args.playerId
	local action = args.action
	local amount = args.amount
	if amount >= 0 then
		TriggerEvent("mgd_shop:adminCoins", xPlayer, target, action, amount)
	else
		xPlayer.showNotification(_("mgd_command_error_amount"))
	end
end, true, {help = _('mgd_command_admin_givecoins'), validate = true, arguments = {
	{name = 'playerId', help = _('mgd_command_args_playerid'), type = 'player'},
	{name = 'action', help = _('mgd_command_args_action'), type = 'string'},
	{name = 'amount', help = _('mgd_command_args_amount'), type = 'number'}
}})

ESX.RegisterCommand('shop:setrank', Config.commandAdmin, function(xPlayer, args, showError)
	local target = args.playerId
	local rank = args.rank
	TriggerEvent("mgd_shop:adminSetRank", xPlayer, target, rank)
end, true, {help = _('mgd_command_admin_setrank'), validate = true, arguments = {
	{name = 'playerId', help = _('mgd_command_args_playerid'), type = 'player'},
	{name = 'rank', help = _('mgd_command_args_rank'), type = 'string'}
}})

ESX.RegisterCommand('shop:setshopid', Config.commandAdmin, function(xPlayer, args, showError)
	local target = args.playerId
	local newShopID = args.newShopID
	TriggerEvent("mgd_shop:adminSetShopID", xPlayer, target, newShopID)
end, true, {help = _('mgd_command_admin_setshopid'), validate = true, arguments = {
	{name = 'playerId', help = _('mgd_command_args_playerid'), type = 'player'},
	{name = 'newShopID', help = _('mgd_command_args_newShopID'), type = 'number'}
}})

ESX.RegisterCommand('shop:forcepromote', Config.commandAdmin, function(xPlayer, args, showError)
	TriggerEvent("mgd_shop:forcePromoteMessage")
end, true, {help = _('mgd_command_admin_forcepromote'), validate = true, arguments = {}})