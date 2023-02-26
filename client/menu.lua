RegisterNetEvent('mgd_shop:openShopUI')
AddEventHandler('mgd_shop:openShopUI', function()
    ESX.TriggerServerCallback('mgd_shop:getShopData', function(playerShopData)
        ESX.TriggerServerCallback('mgd_shop:getCreatorcode', function(dataCreatorCode)
            if playerShopData ~= nil then
                local firstOpen = false
                if playerShopData.shopID == "MGD" then
                    local newID = GenerateShopID()
                    playerShopData.shopID = "MGD-".. newID
                    ESX.TriggerServerCallback('mgd_shop:firstOpen', function(success)
                        if success then
                            SendNUIMessage({
                                display = true,
                                serverID = GetPlayerServerId(PlayerId()),
                                userShopData = playerShopData,
                                creatorsCodes = dataCreatorCode,
                                firstOpen = true
                            })
                    
                            SetNuiFocus(true, true)
                            TransitionToBlurred(2000)
                        else
                            MGD(_('mgd_dev_error_firstOpen'))
                            return
                        end
                    end, playerShopData.shopID)
                else
                    SendNUIMessage({
                        display = true,
                        serverID = GetPlayerServerId(PlayerId()),
                        userShopData = playerShopData,
                        creatorsCodes = dataCreatorCode,
                        firstOpen = false
                    })
            
                    SetNuiFocus(true, true)
                    TransitionToBlurred(2000)
                end        
            else
                MGD(_('mgd_dev_error_playerData'))
            end
        end)
    end)
end)

RegisterNUICallback('closeShopUI', function(data, cb)
    SetNuiFocus(false, false)
    TransitionFromBlurred(2000)
end)

RegisterNUICallback('submitCoinsForm', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:sendCredits', function(success, errorText)
        if success then
            cb(true)
        else
            cb(errorText)
        end
    end, data.type, data.sender, data.receiver, tonumber(data.amount))
end)

RegisterNUICallback('buyItem', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:buyItem', function(success, errorText)
        if success then
            cb(true)
        else
            cb(errorText)
        end
    end, data.categorie, data.item, data.creatorCode, data.lootboxsInfos)
end)

RegisterNUICallback('lootboxReward', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:lootboxReward', function(success, errorText)
        if success then
            cb(true)
        else
            cb(errorText)
        end
    end, data.reward)
end)

RegisterNUICallback('getPlayerHistory', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:getPlayerHistory', function(history)
        cb(history)
    end)
end)

RegisterNUICallback('creatorCodeMoney', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:creatorCodeMoney', function(money)
        cb(money)
    end, data.refCode)
end)

RegisterNUICallback('creatorCodeCreate', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:creatorCodeCreate', function(success)
        cb(success)
    end, data.code, data.identifier)
end)

RegisterNUICallback('creatorCodeUpdate', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:creatorCodeUpdate', function(success)
        cb(success)
    end, data.updateType, data.oldValue, data.newValue, data.refCode)
end)

RegisterNUICallback('creatorCodeDelete', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:creatorCodeDelete', function(success)
        cb(success)
    end, data.refCode)
end)

RegisterNUICallback('getAdminLogsItems', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:getAdminLogsItems', function(success)
        cb(success)
    end, data.filter)
end)

RegisterNUICallback('getAdminLogsTransactions', function(data, cb)
    ESX.TriggerServerCallback('mgd_shop:getAdminLogsTransactions', function(success)
        cb(success)
    end, data.filter)
end)