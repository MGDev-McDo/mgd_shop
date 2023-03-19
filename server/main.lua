ESX = exports["es_extended"]:getSharedObject()

ServerItemsInfos = {}
CreatorCodes = {}

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
        local configFile = LoadResourceFile(GetCurrentResourceName(), "./client/ui/config.json")
        configFile = json.decode(configFile)

        local count = 0
        local countCode = 0
        for k,v in pairs(configFile['shopItems']) do
            ServerItemsInfos[k] = {}
            for k2,v2 in pairs(configFile['shopItems'][k]) do
                ServerItemsInfos[k][k2] = v2
                count = count + 1
            end
        end

        if ServerItemsInfos["rangs"] then
            ServerItemsInfos["rangs"]["user"] = {
                power = 0
            }
        end

        MySQL.query('SELECT * FROM `mgdshop_creatorcode`', {
        }, function(result)
            if result[1] then
                for i = 1, #result, 1 do
                    CreatorCodes[result[i].code] = result[i].identifier
                    countCode = countCode + 1
                end

                print("^4[INFO] " .. countCode .. " creator code(s) found^7")
            else
                print("^4[INFO] No creator code found^7")
            end
        end)

        print("^4[INFO] " .. count .. " shop item(s) found^7")

        SetTimeout(Config.promotTime, PromoteMessage)
    end
end)

function InsertItemsLog(playerIdentifier, playerShopID, creatorCode, categorie, item, price, reward)
    MySQL.insert('INSERT INTO `mgdshop_history_items` (pIdentifier, pShopID, hDate, hHour, hCreatorCodeUsed, hCategorie, hItem, hPrice, hReward) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        playerIdentifier,
        playerShopID,
        os.date('%d', os.time()) .. "/" .. os.date('%m', os.time()) .. "/" .. os.date('%Y', os.time()),
        os.date('%H', os.time()) .. "h" .. os.date('%M', os.time()) .. ":" .. os.date('%S', os.time()),
        creatorCode,
        categorie,
        item,
        price,
        json.encode(reward)
    })
end

function InsertTransactionsLog(senderIdentifier, senderShopID, receiverIdentifier, receiverShopID, amount)
    if receiverShopID == "nc" then
        local result = MySQL.query.await('SELECT shopID FROM `users` WHERE identifier = ?', {receiverIdentifier})
        if result then
            receiverShopID = result[1].shopID
        end
    end

    MySQL.insert('INSERT INTO `mgdshop_history_transactions` (sIdentifier, sShopID, rIdentifier, rShopID, hDate, hHour, tAmount) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        senderIdentifier,
        senderShopID,
        receiverIdentifier,
        receiverShopID,
        os.date('%d', os.time()) .. "/" .. os.date('%m', os.time()) .. "/" .. os.date('%Y', os.time()),
        os.date('%H', os.time()) .. "h" .. os.date('%M', os.time()) .. ":" .. os.date('%S', os.time()),
        amount
    })
end

function PromoteMessage()
    TriggerClientEvent('mgd_shop:shopNotification', -1, "~c~/" .. Config.commandName .. " (" .. Config.openingKey .. ")", Config.promotMessage)
    SetTimeout(Config.promotTime, PromoteMessage)
end

RegisterServerEvent('mgd_shop:forcePromoteMessage')
AddEventHandler('mgd_shop:forcePromoteMessage', function()
	PromoteMessage()
end)

function CreatorCodeUse(code, creditUsed)
    if CreatorCodes[code] ~= nil then
        local xPlayer = ESX.GetPlayerFromIdentifier(CreatorCodes[code])
        local reward = creditUsed * (Config.codeReward / 100)

        MySQL.query('SELECT `shopTokens` FROM `users` WHERE `identifier` = ?', {
            CreatorCodes[code]
        }, function(result)
            if result[1] then
                MySQL.update('UPDATE `users` SET `shopTokens` = ? WHERE `identifier` = ?', {
                    result[1].shopTokens + reward,
                    CreatorCodes[code]
                }, function(rowsChange)
                    if rowsChange then
                        if xPlayer and Config.codeNotification then
                            TriggerClientEvent("mgd_shop:shopNotification", xPlayer.source, _('mgd_shop_creator_title'), _('mgd_shop_creator_used', ESX.Math.Round(reward)))
                        end
                    else
                        print("^1[ERROR] Can't add codeReward for " .. xPlayer.identifier .. " | Reward : " .. reward)
                    end
                end)
            else
                print("^1[ERROR] Can't found info for creator " .. xPlayer.identifier)
            end
        end)
    else
        print("^1[ERROR] Can't found info for code " .. code)
    end
end

RegisterServerEvent('mgd_shop:adminCoins')
AddEventHandler('mgd_shop:adminCoins', function(sender, target, action, amount)
    if action == "give" then
        MySQL.update('UPDATE `users` SET `shopTokens` = `shopTokens` + ? WHERE `identifier` = ?', {
            amount,
            target.identifier
        }, function(rowsChange)
            if rowsChange then
                sender.showNotification(_('mgd_command_success'))
                TriggerClientEvent("mgd_shop:shopNotification", target.source, _('mgd_shop_admin'), _('mgd_shop_admin_coins_give', ESX.Math.Round(amount)))       
            else
                sender.showNotification(_('mgd_command_error_processing'))
            end
        end)
    end
    if action == "remove" then
        MySQL.update('UPDATE `users` SET `shopTokens` = `shopTokens` - ? WHERE `identifier` = ?', {
            amount,
            target.identifier
        }, function(rowsChange)
            if rowsChange then
                sender.showNotification(_('mgd_command_success'))
                TriggerClientEvent("mgd_shop:shopNotification", target.source, _('mgd_shop_admin'), _('mgd_shop_admin_coins_remove', ESX.Math.Round(amount)))       
            else
                sender.showNotification(_('mgd_command_error_processing'))
            end
        end)
    end
    if action == "set" then
        MySQL.update('UPDATE `users` SET `shopTokens` = ? WHERE `identifier` = ?', {
            amount,
            target.identifier
        }, function(rowsChange)
            if rowsChange then
                sender.showNotification(_('mgd_command_success'))
                TriggerClientEvent("mgd_shop:shopNotification", target.source, _('mgd_shop_admin'), _('mgd_shop_admin_coins_set', ESX.Math.Round(amount)))       
            else
                sender.showNotification(_('mgd_command_error_processing'))
            end
        end)
    end
end)

RegisterServerEvent('mgd_shop:adminSetRank')
AddEventHandler('mgd_shop:adminSetRank', function(sender, target, rank)
    local rankData = ServerItemsInfos["rangs"][rank]

    if rank == "user" then
        rankData = {}
        rankData.label = "Joueur"
    end

    if rankData ~= nil then
        MySQL.update('UPDATE `users` SET `shopRank` = ? WHERE `identifier` = ?', {
            rank,
            target.identifier
        }, function(rowsChange)
            if rowsChange then
                sender.showNotification(_('mgd_command_success'))
                TriggerClientEvent("mgd_shop:shopNotification", target.source, _('mgd_shop_admin'), _('mgd_shop_admin_rank', rankData.label))       
            else
                sender.showNotification(_('mgd_command_error_processing'))
            end
        end)
    else
        sender.showNotification(_('mgd_command_error_rank'))
    end
end)

RegisterServerEvent('mgd_shop:adminSetShopID')
AddEventHandler('mgd_shop:adminSetShopID', function(sender, target, newShopID)
    MySQL.query('SELECT `shopID` FROM `users` WHERE `shopID` = ?', {
        "MGD-" .. newShopID
	}, function(result)
        if result[1] then
		    sender.showNotification(_('mgd_command_error_newShopID'))
        else
            MySQL.update('UPDATE `users` SET `shopID` = ? WHERE `identifier` = ?', {
                "MGD-" ..newShopID,
                target.identifier
            }, function(rowsChange)
                if rowsChange then
                    sender.showNotification(_('mgd_command_success'))
                    TriggerClientEvent("mgd_shop:shopNotification", target.source, _('mgd_shop_admin'), _('mgd_shop_admin_newShopID', newShopID))       
                else
                    sender.showNotification(_('mgd_command_error_processing'))
                end
            end)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:creatorCodeUpdate', function(source, cb, updateType, oldValue, newValue, refCode)
    if updateType == "code" then
        MySQL.update('UPDATE `mgdshop_creatorcode` SET `code` = ? WHERE `code` = ?', {
            newValue,
            oldValue
        }, function(rowsChange)
            if rowsChange then
                CreatorCodes[newValue] = CreatorCodes[oldValue]
                CreatorCodes[oldValue] = nil
                cb(true)
            else
                cb(false)
            end
        end)
    end

    if updateType == "identifier" then
        MySQL.update('UPDATE `mgdshop_creatorcode` SET `identifier` = ? WHERE `code` = ?', {
            newValue,
            refCode
        }, function(rowsChange)
            if rowsChange then
                CreatorCodes[refCode] = newValue
                cb(true)
            else
                cb(false)
            end
        end)
    end
end)

ESX.RegisterServerCallback('mgd_shop:creatorCodeDelete', function(source, cb, refCode)
    MySQL.update('DELETE FROM `mgdshop_creatorcode` WHERE `code` = ?', {
        refCode
    }, function(rowsChange)
        if rowsChange then
            CreatorCodes[refCode] = nil
            cb(true)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('mgd_shop:creatorCodeMoney', function(source, cb, refCode)
    MySQL.query('SELECT `hPrice` FROM `mgdshop_history_items` WHERE `hCreatorCodeUsed` = ?', {
        refCode
	}, function(result)
        local money = 0
        if result[1] then
		    for i=1, #result, 1 do
                money = money + result[i].hPrice
            end
        end
        money = money * (Config.codeReward / 100)
        cb(money)
	end)
end)

ESX.RegisterServerCallback('mgd_shop:creatorCodeCreate', function(source, cb, code, identifier)
    MySQL.insert('INSERT INTO `mgdshop_creatorcode`(identifier, code) VALUES (?, ?)', {
        identifier,
        code
	}, function(rowsChange)
        if rowsChange then
            CreatorCodes[code] = identifier
            cb(true)
        else
            cb(false)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:getAdminLogsItems', function(source, cb, filter)
    MySQL.query('SELECT * FROM `mgdshop_history_items` '.. filter ..' ORDER BY `hDate` DESC, `hHour` DESC', {
    }, function(result)
        if result[1] then
            cb(result)
        else
            cb({})
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:getAdminLogsTransactions', function(source, cb, filter)
    MySQL.query('SELECT * FROM `mgdshop_history_transactions` '.. filter ..' ORDER BY `hDate` DESC, `hHour` DESC', {
    }, function(result)
        if result[1] then
            cb(result)
        else
            cb({})
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:lootboxReward', function(source, cb, rewardData)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
	if rewardData.type == "rank" then
        MySQL.query('SELECT `shopRank` FROM `users` WHERE identifier = ?', {
            xPlayer.identifier
        }, function(result)
            if result[1] then
                local actualPower = ServerItemsInfos["rangs"][result[1].shopRank].power
                local rewardPower = ServerItemsInfos["rangs"][rewardData.reward].power

                if rewardPower > actualPower then
                    MySQL.update('UPDATE `users` SET `shopRank` = ? WHERE `identifier` = ?', {
                        rewardData.reward,
                        xPlayer.identifier
                    }, function(rowsChange)
                        if rowsChange then
                            cb(true)
                        else
                            cb(false, "Error : LR#2.1-".. rewardData.type)
                            print("^1[ERROR] MySQL failed to UPDATE " .. xPlayer.identifier .. " shopRank reward " .. rewardData.reward)
                        end
                    end)
                else
                    MySQL.update('UPDATE `users` SET `shopTokens` = `shopTokens` + ? WHERE `identifier` = ?', {
                        ServerItemsInfos["rangs"][rewardData.reward].price,
                        xPlayer.identifier
                    }, function(rowsChange)
                        if rowsChange then
                            cb(true)
                        else
                            cb(false, "Error : LR#2.2-".. rewardData.type)
                            print("^1[ERROR] MySQL failed to UPDATE " .. xPlayer.identifier .. " shopRank price reward " .. rewardData.reward)
                        end
                    end)
                end
            else
                cb(false, "Error : LR#1-".. rewardData.type)
                print("^1[ERROR] No result in reward rank for " .. xPlayer.identifier)
            end
        end)
    end

    if rewardData.type == "vehicle" then
        TriggerClientEvent('mgd_shop:giveVehicle', xPlayer.source, rewardData.reward)
        cb(true)
    end

    if rewardData.type == "weapon" then
        xPlayer.addWeapon(rewardData.reward, 50)
        cb(true)
    end

    if rewardData.type == "money" then
        xPlayer.addAccountMoney('bank', tonumber(rewardData.reward))
        TriggerClientEvent("esx:showAdvancedNotification", xPlayer.source, _('mgd_bank_title'), _('mgd_bank_object'), _('mgd_bank_content', rewardData.reward), "CHAR_BANK_MAZE", 9)
        cb(true)
    end

    if rewardData.type == "coins" then
        MySQL.update('UPDATE `users` SET `shopTokens` = `shopTokens` + ? WHERE `identifier` = ?', {
            rewardData.reward,
            xPlayer.identifier
        }, function(rowsChange)
            if rowsChange then
                cb(true)
            else
                cb(false, "Error : LR-".. rewardData.type)
                print("^1[ERROR] MySQL failed to UPDATE " .. xPlayer.identifier .. " shopTokens reward " .. rewardData.reward)
            end
        end)
    end
end)

ESX.RegisterServerCallback('mgd_shop:getCreatorcode', function(source, cb)
    cb(CreatorCodes)
end)

ESX.RegisterServerCallback('mgd_shop:sendCredits', function(source, cb, sendType, senderShopID, receiver, quantity)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    
    if sendType == 'serverID' then
        local xPlayerTarget = ESX.GetPlayerFromId(receiver)

        if xPlayerTarget ~= nil then
            MySQL.query('SELECT `shopTokens` FROM `users` WHERE `identifier` = ?', {
                xPlayer.identifier
            }, function(senderTokens)
                if senderTokens[1] then
                    if senderTokens[1].shopTokens >= quantity then
                        MySQL.update('UPDATE `users` SET `shopTokens` = `shopTokens` - ? WHERE `identifier` = ?', {
                            quantity,
                            xPlayer.identifier
                        }, function(rowsChange)
                            if rowsChange then
                                MySQL.update('UPDATE `users` SET `shopTokens` = `shopTokens` + ? WHERE `identifier` = ?', {
                                    quantity,
                                    xPlayerTarget.identifier
                                }, function(rowsChange2)
                                    if rowsChange2 then
                                        InsertTransactionsLog(xPlayer.identifier, senderShopID, xPlayerTarget.identifier, "nc", quantity)
                                        TriggerClientEvent("mgd_shop:shopNotification", xPlayerTarget.source, _('mgd_shop_credits_title'), _('mgd_shop_credits_content', ESX.Math.Round(quantity), senderShopID))       
                                        cb(true, "")
                                    else
                                        print("^1[ERROR] Can't update shopTokens for " .. xPlayerTarget.identifier .. " in sendCredits")
                                        cb(false, _('mgd_nui_error_processing'))  
                                    end
                                end)
                            else
                                print("^1[ERROR] Can't update shopTokens for " .. xPlayer.identifier .. " in sendCredits")
                                cb(false, _('mgd_nui_error_processing'))
                            end
                        end)
                    else
                        cb(false, _('mgd_nui_error_purse'))
                    end
                else
                    cb(false, _('mgd_nui_error_playerData'))
                end
            end)
        else
            cb(false, _('mgd_nui_error_serverID'))
        end
    end

    if sendType == 'shopID' then
        MySQL.query('SELECT `identifier`, `shopID` FROM `users` WHERE `shopID` = ?', {
            receiver
        }, function(result)
            if result[1] then
                local xPlayerTarget = ESX.GetPlayerFromIdentifier(result[1].identifier)
                MySQL.query('SELECT `shopTokens` FROM `users` WHERE `identifier` = ?', {
                    xPlayer.identifier
                }, function(result2)
                    if result2[1] then
                        if result2[1].shopTokens >= quantity then
                            MySQL.update('UPDATE `users` SET `shopTokens` = `shopTokens` - ? WHERE `identifier` = ?', {
                                quantity,
                                xPlayer.identifier
                            }, function(rowsChange)
                                if rowsChange then
                                    MySQL.update('UPDATE `users` SET `shopTokens` = `shopTokens` + ? WHERE `shopID` = ?', {
                                        quantity,
                                        receiver
                                    }, function(rowsChange2)
                                        if rowsChange2 then
                                            if xPlayerTarget then
                                                TriggerClientEvent("mgd_shop:shopNotification", xPlayerTarget.source, _('mgd_shop_credits_title'), _('mgd_shop_credits_content', ESX.Math.Round(quantity), senderShopID))
                                            end
                                            InsertTransactionsLog(xPlayer.identifier, senderShopID, result[1].identifier, receiver, quantity)
                                            cb(true, "")
                                        else
                                            print("^1[ERROR] Can't update shopTokens for " .. receiver .. " in sendCredits")
                                            cb(false, _('mgd_nui_error_processing'))  
                                        end
                                    end)
                                else
                                    print("^1[ERROR] Can't update shopTokens for " .. xPlayer.identifier .. " in sendCredits")
                                    cb(false, _('mgd_nui_error_processing'))
                                end
                            end)
                        else
                            cb(false, _('mgd_nui_error_purse'))
                        end
                    else
                        cb(false, _('mgd_nui_error_playerData'))
                    end
                end)
            else
                cb(false, _('mgd_nui_error_shopID'))
            end
        end)
    end
end)

ESX.RegisterServerCallback('mgd_shop:isIDTaken', function(source, cb, ID)
    MySQL.query('SELECT `shopID` FROM `users` WHERE `shopID` = ?', {
        ID
	}, function(result)
        if result[1] then
		    cb(true)
        else
            cb(false)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:firstOpen', function(source, cb, newID)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.update('UPDATE `users` SET `shopID` = ? WHERE `identifier` = ?', {
        newID,
        xPlayer.identifier
    }, function(rowsChange)
        if rowsChange then
            cb(true)
        else
            print("^1[ERROR] Can't update shopID for " .. xPlayer.identifier .. " | NewID : " .. newID)
            cb(false)  
        end
    end)
end)

ESX.RegisterServerCallback('mgd_shop:getShopData', function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.query('SELECT `group`, `shopID`, `shopTokens`, `shopRank` FROM `users` WHERE identifier = ?', {
        xPlayer.identifier
	}, function(result)
        if result[1] then
            cb(result[1])
        else
            print("^1[ERROR] No result in getShopData for " .. xPlayer.identifier)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:buyItem', function(source, cb, categorie, item, creatorCode, lootboxsInfos)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if ServerItemsInfos[categorie][item] ~= nil then
        MySQL.query('SELECT `shopTokens`, `shopID` FROM `users` WHERE identifier = ?', {
            xPlayer.identifier
        }, function(result)
            if result[1] then
                local shopTokens = result[1].shopTokens
                if shopTokens >= ServerItemsInfos[categorie][item].price then
                    MySQL.update('UPDATE `users` SET `shopTokens` = ? WHERE `identifier` = ?', {
                        shopTokens - ServerItemsInfos[categorie][item].price,
                        xPlayer.identifier
                    }, function(rowsChange)
                        if rowsChange then
                            if categorie == "lootboxs" then
                                InsertItemsLog(xPlayer.identifier, result[1].shopID, creatorCode, categorie, item, ServerItemsInfos[categorie][item].price, lootboxsInfos)
                            else
                                InsertItemsLog(xPlayer.identifier, result[1].shopID, creatorCode, categorie, item, ServerItemsInfos[categorie][item].price, "")
                            end

                            if creatorCode ~= "-" then CreatorCodeUse(creatorCode, ServerItemsInfos[categorie][item].price) end
                            if categorie == "rangs" then
                                MySQL.update('UPDATE `users` SET `shopRank` = ? WHERE `identifier` = ?', {
                                    item,
                                    xPlayer.identifier
                                }, function(rowsChange)
                                    if rowsChange then
                                        cb(true, "")
                                    else
                                        cb(false, "Error : BI#4-".. item)
                                        print("^1[ERROR] MySQL failed to UPDATE " .. xPlayer.identifier .. " rank to " .. item)
                                    end
                                end)
                            end
                            if categorie == "vehicules" then
                                TriggerClientEvent("mgd_shop:giveVehicle", xPlayer.source, item)
                                cb(true, "")
                            end
                            if categorie == "armes" then
                                xPlayer.addWeapon(item, ServerItemsInfos[categorie][item].ammo)
                                cb(true, "")
                            end
                            if categorie == "argent" then
                                xPlayer.addAccountMoney('bank', tonumber(ServerItemsInfos[categorie][item].amount))
                                TriggerClientEvent("esx:showAdvancedNotification", xPlayer.source, _('mgd_bank_title'), _('mgd_bank_object'), _('mgd_bank_content', ServerItemsInfos[categorie][item].amount), "CHAR_BANK_MAZE", 9)
                                cb(true, "")
                            end
                            if categorie == "lootboxs" then
                                cb(true, "")
                            end
                        else
                            cb(false, "Error : BI#3-".. categorie)
                            print("^1[ERROR] MySQL failed to UPDATE " .. xPlayer.identifier .. " when buy " .. item .. " for " .. ServerItemsInfos[categorie][item].price)
                        end
                    end)
                else
                    cb(false, "Error : BI#2")
                    print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. item .. " with " .. shopTokens .. " except that it cost " .. ServerItemsInfos[categorie][item].price)
                end
            else
                print("^1[ERROR] No result shopTokens for " .. xPlayer.identifier)
            end
        end)
    else
        cb(false, "Error : BI#1")
        print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. item .. " in " .. categorie .. " but doesn't exist.")
    end
end)

ESX.RegisterServerCallback('mgd_shop:getPlayerHistory', function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local history = { items = {}, transactions = {} }
    MySQL.query('SELECT * FROM `mgdshop_history_items` WHERE `pIdentifier` = ? ORDER BY `hDate` DESC, `hHour` DESC', {
        xPlayer.identifier
	}, function(resultItems)
        if resultItems[1] then
            history.items = resultItems
        end

        MySQL.query('SELECT * FROM `mgdshop_history_transactions` WHERE `sIdentifier` = ? OR `rIdentifier` = ? ORDER BY `hDate` DESC, `hHour` DESC', {
            xPlayer.identifier,
            xPlayer.identifier
        }, function(resultTransactions)
            if resultTransactions[1] then
                history.transactions = resultTransactions
            end

            cb(history)
        end)
    end)
end)