ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ServerItemsInfos = {}
ServerItemsInfos.Ranks = {}
ServerItemsInfos.Vehicles = {}
ServerItemsInfos.Weapons = {}
ServerItemsInfos.Money = {}
ServerItemsInfos.Lootboxs = {}

CreatorCodes = {}

MySQL.ready(function()
    local count = 0
    local countCode = 0
    for k,v in pairs(Config.Ranks) do
        ServerItemsInfos.Ranks[v.label] = v.price
        count = count + 1
    end

    for k,v in pairs(Config.Vehicles) do
        ServerItemsInfos.Vehicles[v.model] = v.price
        count = count + 1
    end

    for k,v in pairs(Config.Weapons) do
        ServerItemsInfos.Weapons[v.name] = v.price
        count = count + 1
    end

    for k,v in pairs(Config.Money) do
        ServerItemsInfos.Money[v.name] = {price = v.price, amount = v.amount}
        count = count + 1
    end

    for k,v in pairs(Config.Lootboxs) do
        ServerItemsInfos.Lootboxs[v.name] = {price = v.price, loots = v.loots}
        count = count + 1
    end

    MySQL.Async.fetchAll('SELECT * FROM `mgdshop_creatorcode`', {
        ['@shopID'] = ID
	}, function(result)
        if result[1] then
		    for i = 1, #result, 1 do
                CreatorCodes[result[i].code] = result[i].identifier
                countCode = countCode + 1
            end

            print("^4[INFO] " .. countCode .. " creator code(s) found")
        end
	end)

    print("^4[INFO] " .. count .. " shop item(s) found")

    SetTimeout(Config.promotTime, PromoteMessage)
end)

function PromoteMessage()
    TriggerClientEvent('mgd_shop:shopNotification', -1, "~c~/" .. Config.commandName .. " (" .. Config.openingKey .. ")", Config.promotMessage)
    SetTimeout(Config.promotTime, PromoteMessage)
end

RegisterServerEvent('mgd_shop:forcePromoteMessage')
AddEventHandler('mgd_shop:forcePromoteMessage', function()
	PromoteMessage()
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

function HistoryAdd(identifier, purchaseData)
    MySQL.Async.execute('INSERT INTO `mgdshop_history` SET `identifier` = @identifier, `time` = @time, `categ` = @categ, `data` = @data', {
        ['@identifier'] = identifier,
        ['@time'] = os.date('%d', os.time()) .. "/" .. os.date('%m', os.time()) .. "/" .. os.date('%Y', os.time()) .. " - " .. os.date('%H', os.time()) .. "h" .. os.date('%M', os.time()) .. ":" .. os.date('%S', os.time()),
        ['@categ'] = purchaseData.type,
        ['@data'] = json.encode(purchaseData)
    }, function(rowsChange)
        if not rowsChange then     
            print("^1[ERROR] No INSERT " .. identifier .. " → " .. json.encode(purchaseData))       
        end
    end)
end

function CreatorCodeUse(code, creditUsed)
    local xPlayer = ESX.GetPlayerFromIdentifier(CreatorCodes[code])
    local reward = creditUsed * (Config.codeReward / 100)

    MySQL.Async.fetchAll('SELECT `shopTokens` FROM `users` WHERE `identifier` = @identifier', {
        ['@identifier'] = CreatorCodes[code]
	}, function(result)
        if result[1] then
		    MySQL.Async.execute('UPDATE `users` SET `shopTokens` = @shopTokens WHERE `identifier` = @identifier', {
                ['@identifier'] = CreatorCodes[code],
                ['@shopTokens'] = result[1].shopTokens + reward
            }, function(rowsChange)
                if rowsChange then
                    if xPlayer and Config.codeNotification then
                        TriggerClientEvent("mgd_shop:shopNotification", xPlayer.source, _('creatorCode_title'), _('creatorCode_used', ESX.Math.Round(reward), Config.creditName .. "(s)"))
                    end
                else
                    print("^1[ERROR] Can't add codeReward for " .. xPlayer.identifier .. " | Reward : " .. reward)
                end
            end)
        else
            print("^1[ERROR] Can't found info for creator " .. xPlayer.identifier)
        end
	end)
end

function ManageReward(xPlayer, reward)
    if reward.type == "rank" then
        MySQL.Async.fetchAll('SELECT `shopRank` FROM `users` WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            if result[1] then
                local rewardPower = GetRankPower(reward.label)
                local actualPower = GetRankPower(result[1].shopRank)

                if rewardPower > actualPower then
                    MySQL.Async.execute('UPDATE `users` SET `shopRank` = @shopRank WHERE `identifier` = @identifier', {
                        ['@identifier'] = xPlayer.identifier,
                        ['@shopRank'] = reward.label
                    }, function(rowsChange)
                        if not rowsChange then
                            print("^1[ERROR] " .. xPlayer.identifier .. " didn't updated shopRank when reward " .. reward.label)
                        end
                    end)
                else
                    MySQL.Async.execute('UPDATE `users` SET `shopTokens` = `shopTokens` + @shopTokens WHERE `identifier` = @identifier', {
                        ['@identifier'] = xPlayer.identifier,
                        ['@shopTokens'] = ServerItemsInfos.Ranks[reward.label]
                    }, function(rowsChange)
                        if rowsChange then
                            TriggerClientEvent('mgd_shop:shopNotification', xPlayer.source, _('mgd_infos'), _('mgd_reward_alreadyRank', ServerItemsInfos.Ranks[reward.label]))
                        else
                            print("^1[ERROR] " .. xPlayer.identifier .. " didn't updated shopRank when reward " .. reward.label)
                        end
                    end)
                end
            else
                print("^1[ERROR] No result in reward rank for " .. xPlayer.identifier)
            end
        end)
    end

    if reward.type == "vehicle" then
        TriggerClientEvent('mgd_shop:giveVehicle', xPlayer.source, reward.model)
    end

    if reward.type == "weapon" then
        xPlayer.addWeapon(reward.name, Config.ammoWeapon)
    end

    if reward.type == "money" then
        xPlayer.addAccountMoney('bank', reward.amount)
        TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _('bank_title'), _('bank_subtitle'), _('bank_content', ESX.Math.GroupDigits(reward.amount)), "CHAR_BANK_MAZE", 9)
    end

    if reward.type == "credit" then
        MySQL.Async.execute('UPDATE `users` SET `shopTokens` = `shopTokens` + @shopTokens WHERE `identifier` = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@shopTokens'] = reward.amount
        }, function(rowsChange)
            if not rowsChange then
                print("^1[ERROR] " .. xPlayer.identifier .. " didn't updated shopTokens when reward " .. reward.amount)
            end
        end)
    end
end

ESX.RegisterServerCallback('mgd_shop:removeCredits', function(source, cb, target, quantity)
    if tonumber(target) ~= nil then
        if GetPlayerName(tonumber(target)) then
            target = ESX.GetPlayerFromId(tonumber(target))
            MySQL.Async.execute('UPDATE `users` SET `shopTokens` = `shopTokens` - @shopTokens WHERE `identifier` = @identifier', {
                ['@identifier'] = target.identifier,
                ['@shopTokens'] = quantity
            }, function(rowsChange)
                if rowsChange then
                    TriggerClientEvent('mgd_shop:shopNotification', target.source, _('mgd_infos'), _('mgd_admin_receiveRemoveCredits', quantity))
                    cb(true, "S")
                else
                    print("^1[ERROR] Can't update removeCredits for " .. target.identifier)
                    cb(false, _('mgd_error_playerProcess')) 
                end
            end)
        else
            cb(false, _('mgd_error_playerIdnotonline'))
        end
    else
        MySQL.Async.execute('UPDATE `users` SET `shopTokens` = `shopTokens` - @shopTokens WHERE `shopID` = @shopID', {
            ['@shopID'] = target,
            ['@shopTokens'] = quantity
        }, function(rowsChange)
            if rowsChange then
                MySQL.Async.fetchAll('SELECT `identifier` FROM `users` WHERE `shopID` = @shopID', {
                    ['@shopID'] = target
                }, function(result)
                    if result[1] then
                        local xPlayer = ESX.GetPlayerFromIdentifier(result[1].identifier)
                        if xPlayer then
                            TriggerClientEvent('mgd_shop:shopNotification', xPlayer.source, _('mgd_infos'), _('mgd_admin_receiveRemoveCredits', quantity))
                        end
                    else
                        print("^1[ERROR] Can't found info for " .. target)
                    end
                end)

                cb(true, "S")
            else
                print("^1[ERROR] Can't update removeCredits for " .. target)
                cb(false, _('mgd_error_playerProcess')) 
            end
        end)
    end
end)

ESX.RegisterServerCallback('mgd_shop:addCredits', function(source, cb, target, quantity)
    if tonumber(target) ~= nil then
        if GetPlayerName(tonumber(target)) then
            target = ESX.GetPlayerFromId(tonumber(target))
            MySQL.Async.execute('UPDATE `users` SET `shopTokens` = `shopTokens` + @shopTokens WHERE `identifier` = @identifier', {
                ['@identifier'] = target.identifier,
                ['@shopTokens'] = quantity
            }, function(rowsChange)
                if rowsChange then
                    TriggerClientEvent('mgd_shop:shopNotification', target.source, _('mgd_infos'), _('mgd_admin_receiveAddCredits', quantity))
                    cb(true, "S")
                else
                    print("^1[ERROR] Can't update addCredits for " .. target.identifier)
                    cb(false, _('mgd_error_playerProcess')) 
                end
            end)
        else
            cb(false, _('mgd_error_playerIdnotonline'))
        end
    else
        MySQL.Async.execute('UPDATE `users` SET `shopTokens` = `shopTokens` + @shopTokens WHERE `shopID` = @shopID', {
            ['@shopID'] = target,
            ['@shopTokens'] = quantity
        }, function(rowsChange)
            if rowsChange then
                MySQL.Async.fetchAll('SELECT `identifier` FROM `users` WHERE `shopID` = @shopID', {
                    ['@shopID'] = target
                }, function(result)
                    if result[1] then
                        local xPlayer = ESX.GetPlayerFromIdentifier(result[1].identifier)
                        if xPlayer then
                            TriggerClientEvent('mgd_shop:shopNotification', xPlayer.source, _('mgd_infos'), _('mgd_admin_receiveAddCredits', quantity))
                        end
                    else
                        print("^1[ERROR] Can't found info for " .. target)
                    end
                end)

                cb(true, "S")
            else
                print("^1[ERROR] Can't update addCredits for " .. target)
                cb(false, _('mgd_error_playerProcess')) 
            end
        end)
    end
end)

ESX.RegisterServerCallback('mgd_shop:getHistory', function(source, cb)
    MySQL.Async.fetchAll('SELECT `mgdshop_history`.`identifier`, `time`, `categ`, `data`, `shopID`  FROM `mgdshop_history` LEFT JOIN `users` ON `mgdshop_history`.`identifier` = `users`.`identifier` ORDER BY `time` DESC', {
	}, function(result)
        if result[1] then
		    cb(result)
        else
            cb(nil)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:editCreatorcode_identifier', function(source, cb, creatorCode, identifier, editIdentifier)
    MySQL.Async.execute('UPDATE `mgdshop_creatorcode` SET `identifier` = @newIdentifier WHERE `identifier` = @identifier', {
        ['@identifier'] = identifier,
        ['@newIdentifier'] = editIdentifier
    }, function(rowsChange)
        if rowsChange then
            CreatorCodes[creatorCode] = editIdentifier
            cb(true)
        else
            print("^1[ERROR] Can't update creatorCode for " .. identifier)
            cb(false) 
        end
    end)
end)

ESX.RegisterServerCallback('mgd_shop:editCreatorcode_code', function(source, cb, identifier, creatorCode, editCreatorCode)
    MySQL.Async.execute('UPDATE `mgdshop_creatorcode` SET `code` = @newCode WHERE `code` = @code', {
        ['@code'] = creatorCode,
        ['@newCode'] = editCreatorCode
    }, function(rowsChange)
        if rowsChange then
            CreatorCodes[creatorCode] = nil
            CreatorCodes[editCreatorCode] = identifier
            TriggerClientEvent('mgd_shop:creatorCodeEdit', -1, creatorCode, editCreatorCode)
            cb(true)
        else
            print("^1[ERROR] Can't update creatorCode for " .. creatorCode)
            cb(false) 
        end
    end)
end)

ESX.RegisterServerCallback('mgd_shop:deleteCreatorcode', function(source, cb, creatorCode)
    MySQL.Async.execute('DELETE FROM `mgdshop_creatorcode` WHERE `code` = @code', {
        ['@code'] = creatorCode
    }, function(rowsChange)
        if rowsChange then
            CreatorCodes[creatorCode] = nil
            TriggerClientEvent('mgd_shop:creatorCodeDelete', -1, creatorCode)
            cb(true)
        else
            print("^1[ERROR] Can't delete creatorCode for " .. creatorCode)
            cb(false) 
        end
    end)
end)

ESX.RegisterServerCallback('mgd_shop:createCreatorcode', function(source, cb, creatorCode, identifier)
    MySQL.Async.execute('INSERT INTO `mgdshop_creatorcode`(`identifier`, `code`) VALUES (@identifier, @code)', {
        ['@identifier'] = identifier,
        ['@code'] = creatorCode
    }, function(rowsChange)
        if rowsChange then
            CreatorCodes[creatorCode] = identifier
            cb(true)
        else
            print("^1[ERROR] Can't create creatorCode for " .. identifier .. " | Code : " .. creatorCode)
            cb(false)  
        end
    end)
end)

ESX.RegisterServerCallback('mgd_shop:getCreatorcode', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM `mgdshop_creatorcode`', {
        ['@shopID'] = ID
	}, function(result)
        if result[1] then
		    cb(result)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:sendCredits', function(source, cb, senderShopID, shopID, quantity)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT `identifier`, `shopID` FROM `users` WHERE `shopID` = @shopID', {
        ['@shopID'] = shopID
	}, function(result)
        if result[1] then
            local xPlayerTarget = ESX.GetPlayerFromIdentifier(result[1].identifier)
            MySQL.Async.fetchAll('SELECT `shopTokens` FROM `users` WHERE `identifier` = @identifier', {
                ['@identifier'] = xPlayer.identifier
            }, function(result2)
                if result2[1] then
                    if result2[1].shopTokens > quantity then
                        MySQL.Async.execute('UPDATE `users` SET `shopTokens` = `shopTokens` - @shopTokens WHERE `identifier` = @identifier', {
                            ['@shopTokens'] = quantity,
                            ['@identifier'] = xPlayer.identifier
                        }, function(rowsChange)
                            if rowsChange then
                                MySQL.Async.execute('UPDATE `users` SET `shopTokens` = `shopTokens` + @shopTokens WHERE `shopID` = @shopID', {
                                    ['@shopTokens'] = quantity,
                                    ['@shopID'] = shopID
                                }, function(rowsChange2)
                                    if rowsChange2 then
                                        if xPlayerTarget then
                                            TriggerClientEvent("mgd_shop:shopNotification", xPlayerTarget.source, _('sendCredits_title'), _('sendCredits_content', ESX.Math.Round(quantity), senderShopID))
                                        end
                                        HistoryAdd(xPlayer.identifier, {masterType = "send", type = "send", amount = "~r~-~s~" .. quantity, toFrom = shopID})
                                        HistoryAdd(xPlayerTarget.identifier, {masterType = "send", type = "receive", amount = "~g~+~s~" .. quantity, toFrom = senderShopID})
                                        cb(true, "S")
                                    else
                                        print("^1[ERROR] Can't update shopTokens for " .. shopID .. " in sendCredits")
                                        cb(false, _('mgd_sendCredits_error_processing'))  
                                    end
                                end)
                            else
                                print("^1[ERROR] Can't update shopTokens for " .. xPlayer.identifier .. " in sendCredits")
                                cb(false, _('mgd_sendCredits_error_processing'))
                            end
                        end)
                    else
                        cb(false, _('mgd_sendMenu_notEnoughQuantity'))
                    end
                else
                    cb(false, _('mgd_sendCredits_error_noData'))
                end
            end)
		else
            cb(false, _('mgd_sendCredits_error_unknowShopID'))
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:isIDTaken', function(source, cb, ID)
    MySQL.Async.fetchAll('SELECT `shopID` FROM `users` WHERE `shopID` = @shopID', {
        ['@shopID'] = ID
	}, function(result)
        if result[1] then
		    cb(true)
        else
            cb(false)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:creatorCodeValid', function(source, cb, creatorCode)
    MySQL.Async.fetchAll('SELECT `code` FROM `mgdshop_creatorcode` WHERE `code` = @creatorCode', {
        ['@creatorCode'] = creatorCode
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
    MySQL.Async.execute('UPDATE `users` SET `shopID` = @shopID WHERE `identifier` = @identifier', {
        ['@identifier'] = xPlayer.identifier,
        ['@shopID'] = newID
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
    MySQL.Async.fetchAll('SELECT `group`, `shopID`, `shopTokens`, `shopRank` FROM `users` WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
	}, function(result)
        if result[1] then
            MySQL.Async.fetchAll('SELECT * FROM `mgdshop_history` WHERE `identifier` = @identifier ORDER BY `time` DESC LIMIT 20', {
                ['@identifier'] = xPlayer.identifier
            }, function(result2)
                if result2[1] then
                    cb(result[1], result2)
                else
                    cb(result[1], nil)
                end
            end)
        else
            print("^1[ERROR] No result in getShopData for " .. xPlayer.identifier)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:buyRank', function(source, cb, creatorCode, purchaseRank, price)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT `shopTokens`, `shopRank` FROM `users` WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
	}, function(result)
        if result[1] then
            local sqlData = result[1]
            if sqlData.shopRank ~= purchaseRank then
                if ServerItemsInfos.Ranks[purchaseRank] ~= nil then
                    if ServerItemsInfos.Ranks[purchaseRank] == price then
                        if sqlData.shopTokens >= price then
                            MySQL.Async.execute('UPDATE `users` SET `shopRank` = @shopRank, `shopTokens` = @shopTokens WHERE `identifier` = @identifier', {
                                ['@identifier'] = xPlayer.identifier,
                                ['@shopRank'] = purchaseRank,
                                ['@shopTokens'] = sqlData.shopTokens - price
                            }, function(rowsChange)
                                if rowsChange then
                                    HistoryAdd(xPlayer.identifier, {masterType = "buy", type = "rank", name = "Rang - " .. purchaseRank, price = price, creatorCode = creatorCode})
                                    if creatorCode ~= "-" then
                                        CreatorCodeUse(creatorCode, price)
                                    end
                                    cb(true, "S")
                                else
                                    cb(false, "E#5")
                                    print("^1[ERROR] " .. xPlayer.identifier .. " didn't updated when buying " .. purchaseRank)
                                end
                            end)
                        else
                            cb(false, "E#4")
                            print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseRank .. " with " .. sqlData.shopTokens .. " except that it cost " .. ServerItemsInfos.Ranks[purchaseRank])
                        end
                    else
                        cb(false, "E#3")
                        print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseRank .. " at the price of " .. price .. " except that it cost " .. ServerItemsInfos.Ranks[purchaseRank])
                    end
                else
                    cb(false, "E#2")
                    print("^1[ERROR] " .. xPlayer.identifier .. " try to buy unknown rank (" .. purchaseRank .. ")")
                end
            else
                cb(false, "E#1")
            end
		else
            print("^1[ERROR] No result in buyRank for " .. xPlayer.identifier)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:buyMoney', function(source, cb, creatorCode, purchaseName, purchaseAmount, price)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT `shopTokens`, `shopRank` FROM `users` WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
	}, function(result)
        if result[1] then
            local sqlData = result[1]
            if ServerItemsInfos.Money[purchaseName] ~= nil then
                if ServerItemsInfos.Money[purchaseName].price == price then
                    if ServerItemsInfos.Money[purchaseName].amount == purchaseAmount then
                        if sqlData.shopTokens >= price then
                            MySQL.Async.execute('UPDATE `users` SET `shopTokens` = @shopTokens WHERE `identifier` = @identifier', {
                                ['@identifier'] = xPlayer.identifier,
                                ['@shopTokens'] = sqlData.shopTokens - price
                            }, function(rowsChange)
                                if rowsChange then
                                    xPlayer.addAccountMoney('bank', purchaseAmount)
                                    HistoryAdd(xPlayer.identifier, {masterType = "buy", type = "money", name = "Argent - " .. purchaseAmount .. "$", price = price, creatorCode = creatorCode})
                                    if creatorCode ~= "-" then
                                        CreatorCodeUse(creatorCode, price)
                                    end
                                    cb(true, "S")
                                else
                                    cb(false, "E#5")
                                    print("^1[ERROR] " .. xPlayer.identifier .. " didn't updated when buying " .. purchaseName)
                                end
                            end)
                        else
                            cb(false, "E#4")
                            print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseRank .. " with " .. sqlData.shopTokens .. " except that it cost " .. ServerItemsInfos.Ranks[purchaseRank])
                        end
                    else
                        cb(false, "E#3")
                        print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseName .. " with " .. purchaseAmount .. "$ except that it contains ".. ServerItemsInfos.Money[purchaseName].amount .."$.")
                    end
                else
                    cb(false, "E#2")
                    print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseName .. " at the price of " .. price .. " except that it cost " .. ServerItemsInfos.Money[purchaseName].price)
                end
            else
                cb(false, "E#1")
                print("^1[ERROR] " .. xPlayer.identifier .. " try to buy unknown money pack (" .. purchaseName .. ")")
            end
		else
            print("^1[ERROR] No result in buyMoney for " .. xPlayer.identifier)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:buyWeapon', function(source, cb, creatorCode, purchaseWeapon, price)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT `shopTokens`, `shopRank` FROM `users` WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
	}, function(result)
        if result[1] then
            local sqlData = result[1]
            if ServerItemsInfos.Weapons[purchaseWeapon] ~= nil then
                if ServerItemsInfos.Weapons[purchaseWeapon] == price then
                    if sqlData.shopTokens >= price then
                        MySQL.Async.execute('UPDATE `users` SET `shopTokens` = @shopTokens WHERE `identifier` = @identifier', {
                            ['@identifier'] = xPlayer.identifier,
                            ['@shopTokens'] = sqlData.shopTokens - price
                        }, function(rowsChange)
                            if rowsChange then
                                xPlayer.addWeapon(purchaseWeapon, Config.ammoWeapon)
                                HistoryAdd(xPlayer.identifier, {masterType = "buy", type = "weapon", name = "Arme - " .. purchaseWeapon, price = price, creatorCode = creatorCode})
                                if creatorCode ~= "-" then
                                    CreatorCodeUse(creatorCode, price)
                                end
                                cb(true, "S")
                            else
                                cb(false, "E#4")
                                print("^1[ERROR] " .. xPlayer.identifier .. " didn't updated when buying " .. purchaseWeapon)
                            end
                        end)
                    else
                        cb(false, "E#3")
                        print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseWeapon .. " with " .. sqlData.shopTokens .. " except that it cost " .. ServerItemsInfos.Weapons[purchaseWeapon])
                    end
                else
                    cb(false, "E#2")
                    print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseWeapon .. " at the price of " .. price .. " except that it cost " .. ServerItemsInfos.Weapons[purchaseWeapon])
                end
            else
                cb(false, "E#1")
                print("^1[ERROR] " .. xPlayer.identifier .. " try to buy unknown weapon (" .. purchaseWeapon .. ")")
            end
		else
            print("^1[ERROR] No result in buyWeapon for " .. xPlayer.identifier)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:buyVehicle', function(source, cb, creatorCode, purchaseModel, price)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT `shopTokens`, `shopRank` FROM `users` WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
	}, function(result)
        if result[1] then
            local sqlData = result[1]
            if ServerItemsInfos.Vehicles[purchaseModel] ~= nil then
                if ServerItemsInfos.Vehicles[purchaseModel] == price then
                    if sqlData.shopTokens >= price then
                        MySQL.Async.execute('UPDATE `users` SET `shopTokens` = @shopTokens WHERE `identifier` = @identifier', {
                            ['@identifier'] = xPlayer.identifier,
                            ['@shopTokens'] = sqlData.shopTokens - price
                        }, function(rowsChange)
                            if rowsChange then
                                HistoryAdd(xPlayer.identifier, {masterType = "buy", type = "vehicle", name = "Véhicule - " .. purchaseModel, price = price, creatorCode = creatorCode})
                                if creatorCode ~= "-" then
                                    CreatorCodeUse(creatorCode, price)
                                end
                                cb(true, "S")
                            else
                                cb(false, "E#4")
                                print("^1[ERROR] " .. xPlayer.identifier .. " didn't updated when buying " .. purchaseModel)
                            end
                        end)
                    else
                        cb(false, "E#3")
                        print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseModel .. " with " .. sqlData.shopTokens .. " except that it cost " .. ServerItemsInfos.Vehicles[purchaseModel])
                    end
                else
                    cb(false, "E#2")
                    print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseModel .. " at the price of " .. price .. " except that it cost " .. ServerItemsInfos.Vehicles[purchaseModel])
                end
            else
                cb(false, "E#1")
                print("^1[ERROR] " .. xPlayer.identifier .. " try to buy unknown vehicle (" .. purchaseModel .. ")")
            end
		else
            print("^1[ERROR] No result in buyVehicle for " .. xPlayer.identifier)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_shop:buyLootbox', function(source, cb, creatorCode, purchaseCase, price)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT `shopTokens`, `shopRank` FROM `users` WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
	}, function(result)
        if result[1] then
            local sqlData = result[1]
            if ServerItemsInfos.Lootboxs[purchaseCase] ~= nil then
                if ServerItemsInfos.Lootboxs[purchaseCase].price == price then
                    if sqlData.shopTokens >= price then
                        MySQL.Async.execute('UPDATE `users` SET `shopTokens` = @shopTokens WHERE `identifier` = @identifier', {
                            ['@identifier'] = xPlayer.identifier,
                            ['@shopTokens'] = sqlData.shopTokens - price
                        }, function(rowsChange)
                            if rowsChange then
                                local purchasedCase = ServerItemsInfos.Lootboxs[purchaseCase]
                                local rewardIndex = math.random(#purchasedCase.loots)
                                local reward = purchasedCase.loots[rewardIndex]
                                ManageReward(xPlayer, reward)
                                HistoryAdd(xPlayer.identifier, {masterType = "buy", type = "lootbox", name = "Caisse - " .. purchaseCase .. " | Récompense : " .. reward.label, price = price, creatorCode = creatorCode})
                                if creatorCode ~= "-" then
                                    CreatorCodeUse(creatorCode, price)
                                end
                                cb(true, "S", reward.label)
                            else
                                cb(false, "E#4")
                                print("^1[ERROR] " .. xPlayer.identifier .. " didn't updated when buying " .. purchaseCase)
                            end
                        end)
                    else
                        cb(false, "E#3")
                        print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseCase .. " with " .. sqlData.shopTokens .. " except that it cost " .. ServerItemsInfos.Lootboxs[purchaseCase].price)
                    end
                else
                    cb(false, "E#2")
                    print("^1[ERROR] " .. xPlayer.identifier .. " try to buy " .. purchaseCase .. " at the price of " .. price .. " except that it cost " .. ServerItemsInfos.Lootboxs[purchaseCase].price)
                end
            else
                cb(false, "E#1")
                print("^1[ERROR] " .. xPlayer.identifier .. " try to buy unknown weapon (" .. purchaseWeapon .. ")")
            end
		else
            print("^1[ERROR] No result in buyLootbox for " .. xPlayer.identifier)
        end
	end)
end)