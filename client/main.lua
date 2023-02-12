ESX = nil
if Config.esxLegacy then ESX = exports["es_extended"]:getSharedObject() end
menuOpen = false
PlayerDead = false
Citizen.CreateThread(function()
	if Config.esxLegacy then
		ESX.PlayerData = ESX.GetPlayerData()
	else
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end
		ESX.PlayerData = ESX.GetPlayerData()
	end
end)

function _(str, ...)
	if Messages[_Lang] ~= nil then
		if Messages[_Lang][str] ~= nil then
			return string.format(Messages[_Lang][str], ...)
		else
			return str .. " doesn't have translation"
		end
	end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

AddEventHandler('esx:onPlayerDeath', function()
	PlayerDead = true
	RageUI.CloseAll()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TransitionFromBlurred(0)
		SetNuiFocus(false, false)
	end
end)

AddEventHandler('playerSpawned', function()
	PlayerDead = false
end)

RegisterCommand(Config.commandName, function()
	if PlayerDead then
		ESX.ShowNotification(_("playerdead"))
	else
		if menuOpen then
			menuOpen = false
			RageUI.CloseAll()
		else
			OpenMenu()
		end
	end
end, false)
RegisterKeyMapping(Config.commandName, _('keyMapping_label'), 'keyboard', Config.openingKey)

RegisterNetEvent('mgd_shop:giveVehicle')
AddEventHandler('mgd_shop:giveVehicle', function(model)
	local playerPed = PlayerPedId()
	ESX.Game.SpawnVehicle(model, GetEntityCoords(playerPed), GetEntityHeading(playerPed), function(vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetEntityAsMissionEntity(vehicle, true, true)

		local newPlate = exports['esx_vehicleshop']:GeneratePlate()
		local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
		vehicleProps.plate = newPlate
		SetVehicleNumberPlateText(vehicle, newPlate)

		TriggerServerEvent('esx_vehicleshop:setVehicleOwned', vehicleProps, 'car')
	end)
end)

function GetRankPower(rank)
	if rank == Config.defaultRank then
		return 0
	end

	for k,v in pairs(Config.Ranks) do
		if v.label == rank then
			return k
		end
	end
end

RegisterNetEvent('mgd_shop:shopNotification')
AddEventHandler('mgd_shop:shopNotification', function(object, message)
	ShopNotification(object, message)
end)

RegisterNetEvent('mgd_shop:creatorCodeDelete')
AddEventHandler('mgd_shop:creatorCodeDelete', function(creatorCode)
	if creatorCodeUse == creatorCode then
		creatorCodeUse = "-"
	end
end)

RegisterNetEvent('mgd_shop:creatorCodeEdit')
AddEventHandler('mgd_shop:creatorCodeEdit', function(oldCreatorCode, creatorCode)
	if creatorCodeUse == oldCreatorCode then
		creatorCodeUse = creatorCode
	end
end)

function ShopNotification(object, message)
	SetNotificationTextEntry('STRING');
	AddTextComponentString(message);
	SetNotificationMessage('mgd_shop', 'notif', true, 4, _('menu_title') .. " " .. Config.serverName, object);
	DrawNotification(false, true);
end

function MGD(message)
	SetNotificationTextEntry('STRING');
	AddTextComponentString(message);
	SetNotificationMessage('mgd_shop', 'notif', true, 4, _('mgd_title'), _('mgd_error'));
	DrawNotification(false, true);
end

function GetTypeLabel(typeName)
	if typeName == "rank" then return _('menu_categories_rank') end
	if typeName == "vehicle" then return _('menu_categories_vehicles') end
	if typeName == "money" then return _('menu_categories_money') end
	if typeName == "weapon" then return _('menu_categories_weapons') end
	if typeName == "lootbox" then return _('menu_categories_lootboxs') end
	if typeName == "send" then return _('mgd_typeName_send') end
	if typeName == "receive" then return _('mgd_typeName_receive') end
end

function GetTypeFromArrayIndex(index)
	if index == 1 then return "rank" end
	if index == 2 then return "vehicle" end
	if index == 3 then return "money" end
	if index == 4 then return "weapon" end
	if index == 5 then return "lootbox" end
	if index == 6 then return "send" end
	if index == 7 then return "receive" end
end

function GenerateShopID()
	local ID = math.random(0,9) .. math.random(0,9) .. math.random(0,9) .. math.random(0,9)
	local found = false

	while not found do
		Citizen.Wait(0)
		ESX.TriggerServerCallback('mgd_shop:isIDTaken', function(isTaken)
			if not isTaken then
				found = true
			end
		end, ID)
	end

	return ID
end