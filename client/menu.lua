local mainMenu = RageUI.CreateMenu(_("menu_title"), _("menu_subtitle"), 10, 0, "mgd_shop", "banner", 0, 0, 0, 0)
local historyMenu = RageUI.CreateSubMenu(mainMenu, _('menu_playerInfo_history'), _("menu_title") .. " → " .. _('menu_playerInfo_history'))
local sendMenu = RageUI.CreateSubMenu(mainMenu, _('menu_categories_send'), _("menu_title") .. " → " .. _('menu_categories_send'))
local rankMenu = RageUI.CreateSubMenu(mainMenu, _('menu_categories_rank'), _("menu_title") .. " → " .. _('menu_categories_rank'))
local vehiclesMenu = RageUI.CreateSubMenu(mainMenu, _('menu_categories_vehicles'), _("menu_title") .. " → " .. _('menu_categories_vehicles'))
local weaponsMenu = RageUI.CreateSubMenu(mainMenu, _('menu_categories_weapons'), _("menu_title") .. " → " .. _('menu_categories_weapons'))
local moneyMenu = RageUI.CreateSubMenu(mainMenu, _('menu_categories_money'), _("menu_title") .. " → " .. _('menu_categories_money'))
local lootboxsMenu =  RageUI.CreateSubMenu(mainMenu, _('menu_categories_lootboxs'), _("menu_title") .. " → " .. _('menu_categories_lootboxs'))
local adminMenu = RageUI.CreateSubMenu(mainMenu, _('menu_admin'), _("menu_title") .. " → " .. _('menu_admin'))
local adminMenu_creatorCode = RageUI.CreateSubMenu(adminMenu, _('menu_admin_creatorCode'), _("menu_title") .. " → " .. _('menu_admin') .. " → " .. _('menu_admin_creatorCode'))
local adminMenu_creatorCode_create = RageUI.CreateSubMenu(adminMenu_creatorCode, _('menu_admin_creatorCode_create'), _("menu_title") .. " → " .. _('menu_admin') .. " → " .. _('menu_admin_creatorCode').. " → " .. _('menu_admin_creatorCode_create'))
local adminMenu_creatorCode_manage = RageUI.CreateSubMenu(adminMenu_creatorCode, _('menu_admin_creatorCode_manage'), _("menu_title") .. " → " .. _('menu_admin') .. " → " .. _('menu_admin_creatorCode').. " → " .. _('menu_admin_creatorCode_manage'))
local adminMenu_history = RageUI.CreateSubMenu(adminMenu, _('menu_admin_history'), _("menu_title") .. " → " .. _('menu_admin') .. " → " .. _('menu_admin_history'))
local adminMenu_history_cat = RageUI.CreateSubMenu(adminMenu_history, _('menu_admin_history_cat'), _("menu_title") .. " → " .. _('menu_admin') .. " → " .. _('menu_admin_history_cat'))
local adminMenu_history_player = RageUI.CreateSubMenu(adminMenu_history, _('menu_admin_history_player'), _("menu_title") .. " → " .. _('menu_admin') .. " → " .. _('menu_admin_history_player'))
local adminMenu_player = RageUI.CreateSubMenu(adminMenu, _('menu_admin_player'), _("menu_title") .. " → " .. _('menu_admin') .. " → " .. _('menu_admin_player'))

creatorCodeUse = "-"
local adminCreatorCode_Label = ""
local adminCreatorCode_Identifier = ""
local adminCreatorCode_Selected = {}
local sendMenu_ShopID = ""
local sendMenu_Quantity = 0
local historyCat_arrayIndex = 1
local historyPlayer = ""
local playerID = ""

function OpenMenu(specificMenu)
    ESX.TriggerServerCallback('mgd_shop:getShopData', function(playerShopData, historyData)
        ESX.TriggerServerCallback('mgd_shop:getCreatorcode', function(data)
            ESX.TriggerServerCallback('mgd_shop:getHistory', function(adminHistoryData)
                if playerShopData ~= nil then
                    if playerShopData.shopID == "MGD" then
                        local newID = GenerateShopID()
                        playerShopData.shopID = "MGD-".. newID
                        ESX.TriggerServerCallback('mgd_shop:firstOpen', function(success)
                            if success then
                                ShopNotification(_('mgd_first_open'), _('mgd_first_openContent', playerShopData.shopID))
                            else
                                MGD(_('mgd_error_firstOpen'))
                                return
                            end
                        end, playerShopData.shopID)
                    end

                    if playerShopData.group == Config.accessAdmin then
                        HistoryCateg = {}
                        HistoryCateg["rank"] = {}
                        HistoryCateg["vehicle"] = {}
                        HistoryCateg["money"] = {}
                        HistoryCateg["weapon"] = {}
                        HistoryCateg["lootbox"] = {}
                        HistoryCateg["send"] = {}
                        HistoryCateg["receive"] = {}

                        if adminHistoryData ~= nil then
                            for i=1, #adminHistoryData, 1 do
                                table.insert(HistoryCateg[adminHistoryData[i].categ], {identifier = adminHistoryData[i].identifier, time = adminHistoryData[i].time, data = adminHistoryData[i].data})
                            end
                        end
                    end

                    local historyActive = false
                    if historyData ~= nil then
                        historyActive = true
                    end
                    menuOpen = true

                    if specificMenu then
                        RageUI.Visible(specificMenu, not RageUI.Visible(specificMenu))
                    else
                        RageUI.Visible(mainMenu, not RageUI.Visible(mainMenu))
                    end

                    playerShopData.shopRankPower = GetRankPower(playerShopData.shopRank)
                    Citizen.CreateThread(function()
                        while menuOpen do
                            Wait(0)
                            
                            RageUI.IsVisible(mainMenu, true, false, false, function()
                                RenderMainMenu(playerShopData, historyActive)
                            end, function() end, 1)

                            RageUI.IsVisible(historyMenu, true, false, false, function()
                                RenderHistoryMenu(historyData)
                            end, function() end, 1)

                            RageUI.IsVisible(sendMenu, true, false, false, function()
                                RenderSendMenu(playerShopData)
                            end, function() end, 1)
                            
                            RageUI.IsVisible(adminMenu, true, false, false, function()
                                RenderAdminMenu()
                            end, function() end, 1)

                            RageUI.IsVisible(adminMenu_creatorCode, true, false, false, function()
                                RenderAdminMenu_CreatorCode(data)
                            end, function() end, 1)

                            RageUI.IsVisible(adminMenu_creatorCode_create, true, false, false, function()
                                RenderAdminMenu_CreatorCodeCreate()
                            end, function() end, 1)

                            RageUI.IsVisible(adminMenu_creatorCode_manage, true, false, false, function()
                                RenderAdminMenu_CreatorCodeManage()
                            end, function() end, 1)

                            RageUI.IsVisible(adminMenu_history, true, false, false, function()
                                RenderAdminMenu_History()
                            end, function() end, 1)

                            RageUI.IsVisible(adminMenu_history_cat, true, false, false, function()
                                RenderAdminMenu_HistoryCat(HistoryCateg)
                            end, function() end, 1)

                            RageUI.IsVisible(adminMenu_history_player, true, false, false, function()
                                RenderAdminMenu_HistoryPlayer(adminHistoryData)
                            end, function() end, 1)

                            RageUI.IsVisible(adminMenu_player, true, false, false, function()
                                RenderAdminMenu_Player()
                            end, function() end, 1)

                            RageUI.IsVisible(rankMenu, true, false, false, function()
                                RenderRankMenu(playerShopData)
                            end, function() end, 1)

                            RageUI.IsVisible(vehiclesMenu, true, false, false, function()
                                RenderVehiclesMenu(playerShopData)
                            end, function() end, 1)

                            RageUI.IsVisible(weaponsMenu, true, false, false, function()
                                RenderWeaponsMenu(playerShopData)
                            end, function() end, 1)

                            RageUI.IsVisible(moneyMenu, true, false, false, function()
                                RenderMoneyMenu(playerShopData)
                            end, function() end, 1)

                            RageUI.IsVisible(lootboxsMenu, true, false, false, function()
                                RenderLootboxsMenu(playerShopData)
                            end, function() end, 1)
                        end
                    end)
                else
                    MGD(_('mgd_error_playerData'))
                end
            end)
        end)
    end)
end

function RenderMainMenu(playerShopData, historyActive)
    RageUI.Separator(_("menu_playerInfo"))
    RageUI.Separator(_("menu_playerInfo_shopID", playerShopData.shopID))
    if Config.codeStatut then RageUI.Separator(_("menu_playerInfo_creatorcode", creatorCodeUse)) end
    RageUI.Separator(_("menu_playerInfo_shopCredits", playerShopData.shopTokens))
    RageUI.Separator(_("menu_playerInfo_rank", playerShopData.shopRank))
    RageUI.Line()
    RageUI.ButtonWithStyle(_("menu_playerInfo_history"), nil, {RightLabel = "→"}, historyActive, function(h,a,s) end, historyMenu)
    if Config.codeStatut then RageUI.ButtonWithStyle(_("menu_active_creatorCode"), nil, {RightLabel = "→"}, true, function(h,a,s)
        if s then
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                creaCode = GetOnscreenKeyboardResult()
            end

            if creaCode ~= nil and creaCode ~= "" and creaCode ~= " " then
                ESX.TriggerServerCallback('mgd_shop:creatorCodeValid', function(isValid)
                    if isValid then
                        creatorCodeUse = string.upper(creaCode)
                        ShopNotification(_('mgd_success'), _('mgd_success_creaCode', string.upper(creaCode)))
                    else
                        ShopNotification(_('mgd_error'), _('mgd_error_invalidcreaCode'))
                    end
                end, creaCode)
            else
                creatorCodeUse = "-"
                ShopNotification(_('mgd_error'), _('mgd_error_emptycreaCode'))
            end
        end
    end) end
    if Config.sendCredits then RageUI.ButtonWithStyle(_("menu_categories_send"), nil, {RightLabel = "→"}, true, function(h,a,s) end, sendMenu) end
    if playerShopData.group == Config.accessAdmin then RageUI.ButtonWithStyle(_("menu_admin"), nil, {RightLabel = "→"}, true, function(h,a,s) end, adminMenu) end
    RageUI.Line()
    RageUI.Separator(_("menu_categories"))
    if Config.catRanks then RageUI.ButtonWithStyle(_("menu_categories_rank"), nil, {RightLabel = "→"}, true, function(h,a,s) end, rankMenu) end
    if Config.catVehicles then RageUI.ButtonWithStyle(_("menu_categories_vehicles"), _('menu_categories_vehicles_alert'), {RightLabel = "→"}, true, function(h,a,s) end, vehiclesMenu) end
    if Config.catWeapons then RageUI.ButtonWithStyle(_("menu_categories_weapons"), nil, {RightLabel = "→"}, true, function(h,a,s) end, weaponsMenu) end
    if Config.catMoney then RageUI.ButtonWithStyle(_("menu_categories_money"), nil, {RightLabel = "→"}, true, function(h,a,s) end, moneyMenu) end
    if Config.catLootboxs then RageUI.ButtonWithStyle(_("menu_categories_lootboxs"), nil, {RightLabel = "→"}, true, function(h,a,s) end, lootboxsMenu) end
end

function RenderHistoryMenu(data)
    for i = 1, #data, 1 do
        infos = json.decode(data[i].data)
        if infos.masterType == "send" then
            RageUI.ButtonWithStyle(data[i].time, nil, {RightLabel = _('history_label_send', GetTypeLabel(infos.type))}, true, function(h,a,s)
                if a then
                    RageUI.Info(_('history_title_send', data[i].time), {_('history_transac', infos.amount), _('history_toFrom', infos.toFrom), "", ""}, {"", "", "", ""})
                end
            end)
        end

        if infos.masterType == "buy" then
            RageUI.ButtonWithStyle(data[i].time, nil, {RightLabel = _('history_label_buy', GetTypeLabel(infos.type))}, true, function(h,a,s)
                if a then
                    RageUI.Info(_('history_title_buy', data[i].time), {_('history_type', infos.name), _('history_price', infos.price), "", _('history_code', infos.creatorCode)}, {"", "", "", ""})
                end
            end)
        end
    end
end

function RenderSendMenu(playerShopData)
    RageUI.ButtonWithStyle(_("mgd_sendMenu_boutiqueID"), nil, {RightLabel = "~p~" .. sendMenu_ShopID}, true, function(h,a,s)
        if s then
            local inputText
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                inputText = GetOnscreenKeyboardResult()
            end

            if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                sendMenu_ShopID = string.upper(inputText)
            else
                ShopNotification(_('mgd_error'), _('mgd_sendMenu_emptyShopID'))
            end
        end
    end)
    RageUI.ButtonWithStyle(_("mgd_sendMenu_quantity"), nil, {RightLabel = "~p~" .. sendMenu_Quantity}, true, function(h,a,s)
        if s then
            local inputText
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                inputText = GetOnscreenKeyboardResult()
            end

            inputText = tonumber(inputText)

            if inputText ~= nil and inputText ~= "" and inputText ~= " " and inputText > 0 then
                if inputText > playerShopData.shopTokens then
                    ShopNotification(_('mgd_error'), _('mgd_sendMenu_notEnoughQuantity'))
                else
                    sendMenu_Quantity = inputText
                end
            else
                ShopNotification(_('mgd_error'), _('mgd_sendMenu_emptyQuantity'))
            end
        end
    end)
    RageUI.ButtonWithStyle(_("mgd_sendMenu_confirm"), nil, {RightLabel = "→"}, true, function(h,a,s)
        if s then
            if sendMenu_ShopID ~= nil and sendMenu_ShopID ~= "" and sendMenu_ShopID ~= " " then
                if sendMenu_Quantity ~= nil and sendMenu_Quantity ~= "" and sendMenu_Quantity ~= " " and sendMenu_Quantity > 0 then
                    ESX.TriggerServerCallback('mgd_shop:sendCredits', function(success, cbError)
                        if success then
                            ShopNotification(_('mgd_success'), _('mgd_success_sendMenu', sendMenu_Quantity, sendMenu_ShopID))
                            sendMenu_ShopID = ""
                            sendMenu_Quantity = 0
                        else
                            ShopNotification(_('mgd_error'), cbError)
                        end
                    end, playerShopData.shopID, sendMenu_ShopID, sendMenu_Quantity)
                else
                    ShopNotification(_('mgd_error'), _('mgd_sendMenu_emptyQuantity'))
                end
            else
                ShopNotification(_('mgd_error'), _('mgd_sendMenu_emptyShopID'))
            end
        end
    end)
end

function RenderAdminMenu()
    if Config.codeStatut then RageUI.ButtonWithStyle(_("menu_admin_creatorCode"), nil, {RightLabel = "→"}, true, function(h,a,s) end, adminMenu_creatorCode) end
    RageUI.ButtonWithStyle(_("menu_admin_history"), nil, {RightLabel = "→"}, true, function(h,a,s) end, adminMenu_history)
    RageUI.ButtonWithStyle(_("menu_admin_player"), nil, {RightLabel = "→"}, true, function(h,a,s) end, adminMenu_player)
    RageUI.ButtonWithStyle(_("menu_admin_forcePromoteMessage"), nil, {RightLabel = "→"}, true, function(h,a,s)
        if s then
            TriggerServerEvent('mgd_shop:forcePromoteMessage')
        end
    end)
end

function RenderAdminMenu_CreatorCode(data)
    RageUI.ButtonWithStyle(_("menu_admin_creatorCode_create"), nil, {RightLabel = "→"}, true, function(h,a,s) end, adminMenu_creatorCode_create)
    RageUI.Separator(_("menu_admin_creatorCode_list"))
    for i=1, #data, 1 do
        RageUI.ButtonWithStyle(data[i].code, nil, {RightLabel = "→"}, true, function(h,a,s)
            if s then
                adminCreatorCode_Selected.code = data[i].code
                adminCreatorCode_Selected.identifier = data[i].identifier
            end
        end, adminMenu_creatorCode_manage)
    end
end

function RenderAdminMenu_CreatorCodeCreate()
    RageUI.ButtonWithStyle(_("mgd_admin_creatorCode_createCode"), nil, {RightLabel = "~p~" .. adminCreatorCode_Label}, true, function(h,a,s)
        if s then
            local inputText
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                inputText = GetOnscreenKeyboardResult()
            end

            if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                adminCreatorCode_Label = string.upper(inputText)
            else
                ShopNotification(_('mgd_error'), _('mgd_admin_error_emptycreaCodeLabel'))
            end
        end
    end)
    RageUI.ButtonWithStyle(_("mgd_admin_creatorCode_createIdentifier"), nil, {RightLabel = "~p~" .. adminCreatorCode_Identifier}, true, function(h,a,s)
        if s then
            local inputText
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                inputText = GetOnscreenKeyboardResult()
            end

            if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                adminCreatorCode_Identifier = inputText
            else
                ShopNotification(_('mgd_error'), _('mgd_admin_error_emptycreaCodeIdentifier'))
            end
        end
    end)
    RageUI.ButtonWithStyle(_("mgd_admin_creatorCode_confirm"), nil, {RightLabel = "→"}, true, function(h,a,s)
        if s then
            if adminCreatorCode_Label ~= nil and adminCreatorCode_Label ~= "" and adminCreatorCode_Label ~= " " then
                if adminCreatorCode_Identifier ~= nil and adminCreatorCode_Identifier ~= "" and adminCreatorCode_Identifier ~= " " then
                    ESX.TriggerServerCallback('mgd_shop:createCreatorcode', function(success, code)
                        if success then
                            ShopNotification(_('mgd_success'), _('mgd_admin_success_createCreaCode', adminCreatorCode_Label, adminCreatorCode_Identifier))
                            adminCreatorCode_Label = ""
                            adminCreatorCode_Identifier = ""
                            RageUI.CloseAll()
                            OpenMenu(adminMenu_creatorCode)
                        else
                            ShopNotification(_('mgd_error'), _('mgd_admin_error_createCreaCode'))
                        end
                    end, adminCreatorCode_Label, adminCreatorCode_Identifier)
                else
                    ShopNotification(_('mgd_error'), _('mgd_admin_error_emptycreaCodeIdentifier'))
                end
            else
                ShopNotification(_('mgd_error'), _('mgd_admin_error_emptycreaCodeLabel'))
            end
        end
    end)
end

function RenderAdminMenu_CreatorCodeManage()
    RageUI.Separator(_('menu_admin_creatorCode_manage_titleIdentifier', adminCreatorCode_Selected.identifier))
    RageUI.Separator(_('menu_admin_creatorCode_manage_titleCode', adminCreatorCode_Selected.code))
    RageUI.Separator(_('menu_admin_creatorCode_manage_actions'))
    RageUI.ButtonWithStyle(_("menu_admin_creatorCode_manage_changeCode"), nil, {RightLabel = "→"}, true, function(h,a,s)
        if s then
            local inputText
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                inputText = GetOnscreenKeyboardResult()
            end

            if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                inputText = string.upper(inputText)
                ESX.TriggerServerCallback('mgd_shop:editCreatorcode_code', function(success)
                    if success then
                        ShopNotification(_('mgd_success'), _('mgd_success_editCreatorCode_code', inputText))
                        adminCreatorCode_Selected.code = inputText
                        menuOpen = false
                        RageUI.CloseAll()
                        OpenMenu(adminMenu_creatorCode_manage)
                    else
                        ShopNotification(_('mgd_error'), _('mgd_error_editCreatorCode'))
                    end
                end, adminCreatorCode_Selected.identifier, adminCreatorCode_Selected.code, inputText)
            else
                ShopNotification(_('mgd_error'), _('mgd_admin_error_emptycreaCodeLabel'))
            end
        end
    end)
    RageUI.ButtonWithStyle(_("menu_admin_creatorCode_manage_changeIdentifier"), nil, {RightLabel = "→"}, true, function(h,a,s)
        if s then
            local inputText
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                inputText = GetOnscreenKeyboardResult()
            end

            if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                ESX.TriggerServerCallback('mgd_shop:editCreatorcode_identifier', function(success)
                    if success then
                        ShopNotification(_('mgd_success'), _('mgd_success_editCreatorCode_identifier', inputText))
                        adminCreatorCode_Selected.identifier = inputText
                        menuOpen = false
                        RageUI.CloseAll()
                        OpenMenu(adminMenu_creatorCode_manage)
                    else
                        ShopNotification(_('mgd_error'), _('mgd_error_editCreatorCode'))
                    end
                end, adminCreatorCode_Selected.code, adminCreatorCode_Selected.identifier, inputText)
            else
                ShopNotification(_('mgd_error'), _('mgd_admin_error_emptycreaCodeIdentifier'))
            end
        end
    end)
    RageUI.ButtonWithStyle(_("menu_admin_creatorCode_manage_delete"), nil, {RightLabel = "→"}, true, function(h,a,s)
        if s then
            ESX.TriggerServerCallback('mgd_shop:deleteCreatorcode', function(success)
                if success then
                    ShopNotification(_('mgd_success'), _('mgd_success_deleteCreatorCode', adminCreatorCode_Selected.code))
                    adminCreatorCode_Selected.identifier = ""
                    adminCreatorCode_Selected.code = ""
                    menuOpen = false
                    RageUI.CloseAll()
                    OpenMenu(adminMenu_creatorCode)
                else
                    ShopNotification(_('mgd_error'), _('mgd_error_deleteCreatorCode'))
                end
            end, adminCreatorCode_Selected.code)
        end
    end)
end

function RenderAdminMenu_History()
    RageUI.ButtonWithStyle(_("menu_admin_history_cat"), nil, {RightLabel = "→"}, true, function(h,a,s) end, adminMenu_history_cat)
    RageUI.ButtonWithStyle(_("menu_admin_history_player"), nil, {RightLabel = "→"}, true, function(h,a,s) end, adminMenu_history_player)
end

function RenderAdminMenu_HistoryCat(data)
    RageUI.List(_('menu_admin_history_cat'), Config.HistoryCategories, historyCat_arrayIndex, nil, {}, true, function(h, a, s, i)
        historyCat_arrayIndex = i
        historyCat_arrayIndexToLabel = GetTypeFromArrayIndex(historyCat_arrayIndex)
    end)

    for j=1, #data[historyCat_arrayIndexToLabel], 1 do
        local globalInfos = data[historyCat_arrayIndexToLabel][j]
        local infos = json.decode(data[historyCat_arrayIndexToLabel][j].data)

        RageUI.ButtonWithStyle(globalInfos.time, nil, {RightLabel = ""}, true, function(h,a,s)
            if a then
                if historyCat_arrayIndexToLabel == "send" or historyCat_arrayIndexToLabel == "receive" then
                    RageUI.Info(globalInfos.time, {globalInfos.identifier, _('history_transac', infos.amount), _('history_toFrom', infos.toFrom), "", ""}, {"", "", "", ""})
                else
                    RageUI.Info(globalInfos.time, {globalInfos.identifier, _('history_type', infos.name), _('history_price', infos.price), _('history_code', infos.creatorCode)}, {"", "", "", ""})
                end
            end
        end)
    end
end

function RenderAdminMenu_HistoryPlayer(historyData)
    RageUI.ButtonWithStyle(_("mgd_admin_historyPlayer_filter"), _('mgd_admin_historyPlayer_filterInfo'), {RightLabel = "~p~" .. historyPlayer}, true, function(h,a,s)
        if s then
            local inputText
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                inputText = GetOnscreenKeyboardResult()
            end

            if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                historyPlayer = inputText
            else
                ShopNotification(_('mgd_error'), _('mgd_admin_error_emptyFilter'))
            end
        end
    end)

    if historyData ~= nil then
        for j=1, #historyData, 1 do
            if historyData[j].identifier == historyPlayer or historyData[j].shopID == historyPlayer then
                infos = json.decode(historyData[j].data)
                if infos.masterType == "send" then
                    RageUI.ButtonWithStyle(historyData[j].time, nil, {RightLabel = _('history_label_send', GetTypeLabel(infos.type))}, true, function(h,a,s)
                        if a then
                            RageUI.Info(_('history_title_send', historyData[j].time), {_('history_transac', infos.amount), _('history_toFrom', infos.toFrom), "", ""}, {"", "", "", ""})
                        end
                    end)
                end

                if infos.masterType == "buy" then
                    RageUI.ButtonWithStyle(historyData[j].time, nil, {RightLabel = _('history_label_buy', GetTypeLabel(infos.type))}, true, function(h,a,s)
                        if a then
                            RageUI.Info(_('history_title_buy', historyData[j].time), {_('history_type', infos.name), _('history_price', infos.price), "", _('history_code', infos.creatorCode)}, {"", "", "", ""})
                        end
                    end)
                end
            end
        end
    end
end

function RenderAdminMenu_Player()
    RageUI.ButtonWithStyle(_("mgd_admin_player_filter"), _('mgd_admin_player_filterInfo'), {RightLabel = "~p~" .. playerID}, true, function(h,a,s)
        if s then
            local inputText
            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
            while UpdateOnscreenKeyboard() == 0 do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                inputText = GetOnscreenKeyboardResult()
            end

            if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                if tonumber(inputText) ~= nil then
                    if tonumber(inputText) > 0 then
                        playerID = inputText
                    else
                        ShopNotification(_('mgd_error'), _('mgd_admin_error_emptyFilter'))
                    end
                else
                    playerID = inputText
                end
            else
                ShopNotification(_('mgd_error'), _('mgd_admin_error_emptyFilter'))
            end
        end
    end)
    if playerID ~= nil and playerID ~= "" and playerID ~= " " then
        RageUI.ButtonWithStyle(_("mgd_admin_player_addCredits"), nil, {RightLabel = "→"}, true, function(h,a,s)
            if s then
                local inputText
                DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
                while UpdateOnscreenKeyboard() == 0 do
                    DisableAllControlActions(0)
                    Wait(0)
                end
                if GetOnscreenKeyboardResult() then
                    inputText = GetOnscreenKeyboardResult()
                end

                inputText = tonumber(inputText)

                if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                    ESX.TriggerServerCallback('mgd_shop:addCredits', function(success, cbError)
                        if success then
                            ShopNotification(_('mgd_success'), _('mgd_success_addCredits', inputText, playerID))
                        else
                            ShopNotification(_('mgd_error'), cbError)
                        end
                    end, playerID, inputText)
                else
                    ShopNotification(_('mgd_error'), _('mgd_admin_error_emptyQuantity'))
                end
            end
        end)
        RageUI.ButtonWithStyle(_("mgd_admin_player_removeCredits"), nil, {RightLabel = "→"}, true, function(h,a,s)
            if s then
                local inputText
                DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 50)
                while UpdateOnscreenKeyboard() == 0 do
                    DisableAllControlActions(0)
                    Wait(0)
                end
                if GetOnscreenKeyboardResult() then
                    inputText = GetOnscreenKeyboardResult()
                end

                inputText = tonumber(inputText)

                if inputText ~= nil and inputText ~= "" and inputText ~= " " then
                    ESX.TriggerServerCallback('mgd_shop:removeCredits', function(success, cbError)
                        if success then
                            ShopNotification(_('mgd_success'), _('mgd_success_removeCredits', inputText, playerID))
                        else
                            ShopNotification(_('mgd_error'), cbError)
                        end
                    end, playerID, inputText)
                else
                    ShopNotification(_('mgd_error'), _('mgd_admin_error_emptyQuantity'))
                end
            end
        end)
    end
end

function RenderRankMenu(playerShopData)
    for k,v in pairs(Config.Ranks) do
        local color = "~r~"
        local canBuy = false
        local statut = true
        if playerShopData.shopTokens >= v.price then color = "~g~" canBuy = true end
        if playerShopData.shopRank ~= Config.defaultRank then if playerShopData.shopRankPower >= k then statut = false end end
        RageUI.ButtonWithStyle(v.label, nil, {RightLabel = color .. ESX.Math.GroupDigits(v.price) .. " " .. Config.creditName .. "(s)"}, statut, function(h,a,s)
            if s then
                local missTokens = v.price - playerShopData.shopTokens
                if canBuy then
                    ESX.TriggerServerCallback('mgd_shop:buyRank', function(success, code)
                        if success then
                            playerShopData.shopTokens = tonumber(playerShopData.shopTokens - v.price)
                            playerShopData.shopRank = tostring(v.label)
                            playerShopData.shopRankPower = tonumber(GetRankPower(playerShopData.shopRank))
                            ShopNotification(_('mgd_success'), _('mgd_buy_rank', playerShopData.shopRank, ESX.Math.GroupDigits(v.price), Config.creditName, ESX.Math.GroupDigits(playerShopData.shopTokens), Config.creditName))
                        else
                            MGD(_('mgd_error_buyResponse', v.label, ESX.Math.GroupDigits(playerShopData.shopTokens), ESX.Math.GroupDigits(v.price), ESX.Math.GroupDigits(missTokens), code))
                        end
                    end, creatorCodeUse, v.label, v.price)
                else
                    ShopNotification(_('mgd_error'), _('mgd_notEnoughTokens', ESX.Math.GroupDigits(missTokens)))
                end
            end
        end)
    end
end

function RenderVehiclesMenu(playerShopData)
    for k,v in pairs(Config.Vehicles) do
        local color = "~r~"
        local canBuy = false
        if playerShopData.shopTokens >= v.price then color = "~g~" canBuy = true end
        RageUI.ButtonWithStyle(v.label, nil, {RightLabel = color .. ESX.Math.GroupDigits(v.price) .. " " .. Config.creditName .. "(s)"}, true, function(h,a,s)
            if s then
                local missTokens = v.price - playerShopData.shopTokens
                if canBuy then
                    ESX.TriggerServerCallback('mgd_shop:buyVehicle', function(success, code)
                        if success then
                            playerShopData.shopTokens = tonumber(playerShopData.shopTokens - v.price)
                            TriggerEvent('mgd_shop:giveVehicle', v.model)
                            ShopNotification(_('mgd_success'), _('mgd_buy_vehicle', v.label, ESX.Math.GroupDigits(v.price), Config.creditName, ESX.Math.GroupDigits(playerShopData.shopTokens), Config.creditName))
                        else
                            MGD(_('mgd_error_buyResponse', v.label, ESX.Math.GroupDigits(playerShopData.shopTokens), ESX.Math.GroupDigits(v.price), ESX.Math.GroupDigits(missTokens), code))
                        end
                    end, creatorCodeUse, v.model, v.price)
                else
                    ShopNotification(_('mgd_error'), _('mgd_notEnoughTokens', ESX.Math.GroupDigits(missTokens)))
                end
            end
        end)
    end
end

function RenderWeaponsMenu(playerShopData)
    for k,v in pairs(Config.Weapons) do
        local color = "~r~"
        local canBuy = false
        if playerShopData.shopTokens >= v.price then color = "~g~" canBuy = true end
        RageUI.ButtonWithStyle(v.label, nil, {RightLabel = color .. ESX.Math.GroupDigits(v.price) .. " " .. Config.creditName .. "(s)"}, true, function(h,a,s)
            if s then
                local missTokens = v.price - playerShopData.shopTokens
                if canBuy then
                    ESX.TriggerServerCallback('mgd_shop:buyWeapon', function(success, code)
                        if success then
                            playerShopData.shopTokens = tonumber(playerShopData.shopTokens - v.price)
                            ShopNotification(_('mgd_success'), _('mgd_buy_weapon', v.label, ESX.Math.GroupDigits(v.price), Config.creditName, ESX.Math.GroupDigits(playerShopData.shopTokens), Config.creditName))
                        else
                            MGD(_('mgd_error_buyResponse', v.label, ESX.Math.GroupDigits(playerShopData.shopTokens), ESX.Math.GroupDigits(v.price), ESX.Math.GroupDigits(missTokens), code))
                        end
                    end, creatorCodeUse, v.name, v.price)
                else
                    ShopNotification(_('mgd_error'), _('mgd_notEnoughTokens', ESX.Math.GroupDigits(missTokens)))
                end
            end
        end)
    end
end

function RenderMoneyMenu(playerShopData)
    for k,v in pairs(Config.Money) do
        local color = "~r~"
        local canBuy = false
        if playerShopData.shopTokens >= v.price then color = "~g~" canBuy = true end
        RageUI.ButtonWithStyle(ESX.Math.GroupDigits(v.amount) .. "$", nil, {RightLabel = color .. ESX.Math.GroupDigits(v.price) .. " " .. Config.creditName .. "(s)"}, true, function(h,a,s)
            if s then
                local missTokens = v.price - playerShopData.shopTokens
                if canBuy then
                    ESX.TriggerServerCallback('mgd_shop:buyMoney', function(success, code)
                        if success then
                            playerShopData.shopTokens = tonumber(playerShopData.shopTokens - v.price)
                            ShopNotification(_('mgd_success'), _('mgd_buy_money', ESX.Math.GroupDigits(v.amount), ESX.Math.GroupDigits(v.price), Config.creditName, ESX.Math.GroupDigits(playerShopData.shopTokens), Config.creditName))
                            ESX.ShowAdvancedNotification(_('bank_title'), _('bank_subtitle'), _('bank_content', ESX.Math.GroupDigits(v.amount)), "CHAR_BANK_MAZE", 9)
                        else
                            MGD(_('mgd_error_buyResponse', ESX.Math.GroupDigits(v.amount).. "$", ESX.Math.GroupDigits(playerShopData.shopTokens), ESX.Math.GroupDigits(v.price), ESX.Math.GroupDigits(missTokens), code))
                        end
                    end, creatorCodeUse, v.name, v.amount, v.price)
                else
                    ShopNotification(_('mgd_error'), _('mgd_notEnoughTokens', ESX.Math.GroupDigits(missTokens)))
                end
            end
        end)
    end
end

function RenderLootboxsMenu(playerShopData)
    for k,v in pairs(Config.Lootboxs) do
        local color = "~r~"
        local canBuy = false
        if playerShopData.shopTokens >= v.price then color = "~g~" canBuy = true end
        local rewardAvaible = _('mgd_lootbox_title')
        for i=1, #v.loots, 1 do
            rewardAvaible = rewardAvaible .. " \n- "..  v.loots[i].label
        end
        RageUI.ButtonWithStyle(v.label, rewardAvaible, {RightLabel = color .. ESX.Math.GroupDigits(v.price) .. " " .. Config.creditName .. "(s)"}, true, function(h,a,s)
            if s then
                local missTokens = v.price - playerShopData.shopTokens
                if canBuy then
                    ESX.TriggerServerCallback('mgd_shop:buyLootbox', function(success, code, reward)
                        if success then
                            playerShopData.shopTokens = tonumber(playerShopData.shopTokens - v.price)
                            ShopNotification(_('mgd_success'), _('mgd_buy_lootbox', v.label, ESX.Math.GroupDigits(v.price), Config.creditName, ESX.Math.GroupDigits(playerShopData.shopTokens), Config.creditName))
                            ESX.ShowNotification(_('mgd_lootbox_reward', reward))
                        else
                            MGD(_('mgd_error_buyResponse', v.label, ESX.Math.GroupDigits(playerShopData.shopTokens), ESX.Math.GroupDigits(v.price), ESX.Math.GroupDigits(missTokens), code))
                        end
                    end, creatorCodeUse, v.name, v.price)
                else
                    ShopNotification(_('mgd_error'), _('mgd_notEnoughTokens', ESX.Math.GroupDigits(missTokens)))
                end
            end
        end)
    end
end