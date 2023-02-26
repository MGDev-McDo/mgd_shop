ESX = exports["es_extended"]:getSharedObject()
PlayerDead = false

RegisterCommand(Config.commandName, function()
	if PlayerDead then
		ShopNotification(_('mgd_shop_error'), _("mgd_shop_error_playerdead"))
	else
		TriggerEvent('mgd_shop:openShopUI')
	end
end, false)
RegisterKeyMapping(Config.commandName, _('mgd_command_keyMapping'), 'keyboard', Config.openingKey)

function ShopNotification(object, message)
	RequestStreamedTextureDict('mgd_shop', true)
    while not HasStreamedTextureDictLoaded('mgd_shop') do
        Citizen.Wait(100)
        RequestStreamedTextureDict('mgd_shop', true)
    end
	SetNotificationTextEntry('STRING');
	AddTextComponentString(message);
	SetNotificationMessage('mgd_shop', 'notif', true, 4, _('mgd_shop_title'), object);
	DrawNotification(false, true);
end

function MGD(message)
	RequestStreamedTextureDict('mgd_shop', true)
    while not HasStreamedTextureDictLoaded('mgd_shop') do
        Citizen.Wait(100)
        RequestStreamedTextureDict('mgd_shop', true)
    end
	SetNotificationTextEntry('STRING');
	AddTextComponentString(message);
	SetNotificationMessage('mgd_shop', 'notif', true, 4, _('mgd_dev_title'), _('mgd_dev_error'));
	DrawNotification(false, true);
end

function GenerateShopID()
	local found = false
	local ID
	while not found do
		ID = math.random(0,9) .. math.random(0,9) .. math.random(0,9) .. math.random(0,9)
		ESX.TriggerServerCallback('mgd_shop:isIDTaken', function(isTaken)
			if not isTaken then
				found = true
			end
		end, ID)
		Citizen.Wait(100)
	end

	return ID
end

AddEventHandler('esx:onPlayerDeath', function()
	PlayerDead = true
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

RegisterNetEvent('mgd_shop:shopNotification')
AddEventHandler('mgd_shop:shopNotification', function(object, message)
	ShopNotification(object, message)
end)