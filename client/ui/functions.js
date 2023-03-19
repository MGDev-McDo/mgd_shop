let CONFIG
$.getJSON("./config.json", function(CONFIGData) { CONFIG = CONFIGData });

function BuildShop() {
    // VERSION
    document.getElementById("version").innerHTML = "v"+ CONFIG.version

    // PURSE
    document.getElementById("purse").innerHTML = '<i class="fa-solid fa-coins"></i><span id="purseAmount">%d</span> '+ CONFIG.moneyName

    // SHOP SUB
    document.getElementById("shop-sub").innerHTML = '<span id="hour">0h00</span>'
    if(CONFIG.features.creatorCode) {
      document.getElementById("shop-sub").innerHTML += '<span>'+ _('shopSub_creatorCode') +' : <span id="creatorCode">-</span></span>'
    }  

    // HOUR
    UpdateHour();
    setInterval(UpdateHour, 5000);

    // NAVBAR
    document.getElementById('navbar').innerHTML = '<span class="navbar-item" id="home">'+ _U("home") +'</span>';
    Object.keys(CONFIG['shopItems']).forEach(function(value){
        document.getElementById('navbar').innerHTML += '<span class="navbar-item" id='+ value +'>'+ value.toUpperCase() +'</span>';
    });
    document.getElementById("home").classList.add("navbar-item-selected");

    // ADMIN NAVBAR
    document.getElementById("navbarAdmin").innerHTML = '\
        <span class="navbar-item" id="adminNav_logsItems">'+ _U("adminNavbar_logsItems") +'</span>\
        <span class="navbar-item" id="adminNav_logsTransactions">'+ _U("adminNavbar_logsTransactions") +'</span>'
    if(CONFIG.features.creatorCode) {
      document.getElementById("navbarAdmin").innerHTML += '<span class="navbar-item" id="adminNav_creatorsCodes">'+ _U("adminNavbar_creatorCodes") +'</span>'
    }    

    // HOME
    document.getElementById("homeMain").innerHTML = '\
        <div class="main-head firstHead">'+ _U('home') +'</div>\
        <div class="main-head secondHead">'+ _U('news') +'</div>\
        <div class="homeArea" id="homeArea"></div>\
        <div class="listMain" id="newsList"></div>'

    // HOME AREA
    document.getElementById("homeArea").innerHTML = '\
        <div class="homeContainer">\
            <div class="homeInfo"><i class="fa-solid fa-user-tag"></i>'+ _("homeInfo_shopID") +'<i class="fa-solid fa-arrow-right arrowIcon"></i><span id="homeLogin">MGD-0000</span></div>\
            <div class="homeInfo"><i class="fa-solid fa-user"></i>'+ _("homeInfo_serverID") +'<i class="fa-solid fa-arrow-right arrowIcon"></i><span id="homeID">0</span></div>\
            <div class="homeInfo"><i class="fa-solid fa-ranking-star"></i>'+ _("homeInfo_rank") +'<i class="fa-solid fa-arrow-right arrowIcon"></i><span id="homeRank">RANK</span></div>\
        </div>'
    if(CONFIG.features.sendCoins) {
      document.getElementById("homeArea").innerHTML += '<div class="homeButton" id="sendCoins"><span><i class="fa-solid fa-share"></i>'+ _("homeButton_sendCoins") + CONFIG.moneyName +'</span></div>'
    }
    document.getElementById("homeArea").innerHTML +='\
        <div class="homeButton" id="playerHistory"><span><i class="fa-solid fa-bookmark"></i>'+ _("homeButton_history") +'</span></div>\
        <div class="homeButton" id="adminMenu"><span><i class="fa-solid fa-toolbox"></i>'+ _("homeButton_admin") +'</span></div>'
    
    // NEWS IN HOME
    $('#newsList').empty();
    Object.keys(CONFIG['shopItems']).forEach(function(categorie) {
      Object.keys(CONFIG['shopItems'][categorie]).forEach(function(item) {
        var item = CONFIG['shopItems'][categorie][item];
        if (item.isNew === true) {
          document.getElementById('newsList').innerHTML += '\
            <div class="listItem newsItem">\
                <span class="newItemDisplay">\
                    <span class="newStar"><i class="fa-solid fa-star fa-beat-fade"></i></span>\
                    <span id="newItemCategorie">' + categorie.toUpperCase() + '</span><i class="fa-solid fa-arrow-right arrowIcon"></i><span id="newItemName">' + item.label.toUpperCase() + '</span>\
                </span>\
                <span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="newItemPrice">' + item.price + '</span>\
            </div>'
        }
      })
    });

    // PLAYER HISTORY
    document.getElementById("pHistory").innerHTML = '\
        <div class="main-head firstHead">'+ _U("pHistory_items") +'</div>\
        <div class="main-head secondHead">'+ _U("pHistory_transactions") +'</div>\
        <div class="listMain" id="historyItems"></div>\
        <div class="listMain" id="historyTransactions"></div>'

    // COINS FORM
    document.getElementById("coinsForm").innerHTML = '\
        <div id="closeCoinsForm"><i class="fa-solid fa-circle-arrow-left"></i></div>\
        <div class="coinsFormTitle">'+ _U("coinsForm_title") +'</div>\
        <div class="coinsFormItem"><span><i class="fa-solid fa-circle-user"></i> '+ _U("coinsForm_receiver") +' <i id="moreInfoReceiver" class="fa-regular fa-circle-question"></i></span><span class="exampleDisplay displayFormCoins" id="idToSendCoins">MGD-OOOO</span></div>\
        <div id="moreInfoReceiverExplain"><i class="fa-regular fa-circle-question fa-flip" style="--fa-animation-duration: 2s;"></i><span>'+ _("coinsForm_explain") +'</span></div>\
        <div class="coinsFormItem"><span><i class="fa-solid fa-circle-dollar-to-slot"></i> '+ _U("coinsForm_amount") +'</span><span class="displayFormCoins amountCoins" id="amountToSendCoins"><i class="fa-solid fa-coins"></i><span class="exampleDisplay" id="displayAmountToSendCoins">0</span></span></div>\
        <div id="submitCoinsForm"><i class="fa-solid fa-share-from-square"></i> '+ _U("coinsForm_send") +'</div>'
    
    // CREATE CREATOR CODE FORM
    document.getElementById("createCCodeForm").innerHTML = '\
        <div id="closeCCCodeForm"><i class="fa-solid fa-circle-arrow-left"></i></div>\
        <div class="cCCodeFormTitle">'+ _U('cCCForm_title') +'</div>\
        <div class="cCCodeFormItem"><span><i class="fa-solid fa-tag"></i> '+ _U('cCCForm_code') +'</span><span class="exampleDisplay displayFormAdmin" id="cCCodeCode">MGDEV</span></div>\
        <div class="cCCodeFormItem"><span><i class="fa-solid fa-circle-user"></i> '+ _U('cCCForm_identifier') +'</span><span class="exampleDisplay displayFormAdmin" id="cCCodeIdentifier">steam:000000000000000</span></div>\
        <div id="submitCCCodeForm"><i class="fa-solid fa-circle-plus"></i> '+ _U('cCCForm_create') +'</div>'

    // LOGS FILTER
    document.getElementById("filterLogsForm").innerHTML = '\
        <div id="closeFilterLogsForm"><i class="fa-solid fa-circle-arrow-left"></i></div>\
        <div class="filterLogsFormTitle">'+ _U("filterLogs_title") +'</div>\
        <div class="filterLogsFormItem"><span><i class="fa-solid fa-bars"></i> '+ _U("filterLogs_filter") +'</span>\
          <select class="displayFormAdmin displayFormAdminSelect" id="filterLogsCategorie"></select>\
        </div>\
        <div class="filterLogsFormItem"><span><i class="fa-solid fa-magnifying-glass"></i> '+ _U("filterLogs_value") +'</span><span class="displayFormAdmin" id="filterLogsValue"></span></div>\
        <div id="submitFilterLogsForm"><i class="fa-solid fa-filter"></i> '+ _U("filterLogs_submit") +'</div>'

    // LOOTBOX REWARD
    document.getElementById("lootboxReward").innerHTML = '\
        <div id="lbr-title"><i class="fa-solid fa-gift"></i>'+ _U("lootboxR_title") +'</div>\
        <div class="line notif-line lbr-line"></div>\
        <div id="lbr-content">'+ _U("lootboxR_message") +' <span id="lbr-reward">%s</span> !</div>'

    // BROWSE CATEGORIE
    document.getElementById("browse").innerHTML = '\
        <div class="main-head firstHead">'+ _U("selectTitle") +'</div>\
        <div class="main-head secondHead" id="categorieName">CATEGORIENAME</div>\
        <div class="selectionArea"><div id="selectContainer">\
            <div id="selectHead" class="selectHead"><span id="selectName"></span><span id="buyButton"><i class="fa-solid fa-cart-shopping"></i>Acheter</span></div>\
            <div id="selectDescription"></div>\
        </div></div>\
        <div class="listMain" id="categorieList">\
        </div>'

    // CREATORS CODES
    document.getElementById("adminCreatorsCodes").innerHTML = '\
        <div class="main-head firstHead">'+ _U("selectTitle") +'</div>\
        <div class="main-head secondHead">'+ _U("aCC_title") +'<span id="newCreatorCode"><i class="fa-solid fa-circle-plus fa-beat-fade" style="--fa-beat-fade-scale: 1.075;"></i></span></div>\
        <div class="selectionArea">\
          <div id="adminSelectContainer">\
            <div class="selectHead"><span id="adminSelectName"></span><span id="deleteButton"><i class="fa-solid fa-trash "></i>'+ _('deleteButton') +'</span></div>\
            <div id="adminSelectDescription">\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('cCCForm_code') +' : </span><span id="acCode"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('cCCForm_identifier') +' : </span><span id="acIdentifier"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('aCC_reward') +' : </span><span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="acMoney">N/A</span></span></div>\
            </div>\
          </div>\
        </div>\
        <div class="listMain" id="creatorCodeList"></div>'

    // LOGS ITEMS
    document.getElementById("adminLogsItems").innerHTML = '\
        <div class="main-head firstHead">'+ _U("selectTitle") +'</div>\
        <div class="main-head secondHead">'+ _U("logs_title") +'<span id="filterItemsLogs"><i class="fa-solid fa-filter"></i>'+ _U("filter") +'</span></div>\
        <div class="selectionArea">\
          <div id="adminSelectLogItemContainer">\
            <div class="selectHead"><span id="adminSelectLogItemName"></span></div>\
            <div id="adminSelectLogItemDescription">\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('date') +' : </span><span id="aSLIDate"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _("player") +' : </span><span id="aSLIPlayer"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _("creatorCodeUsed") +' : </span><span id="aSLICreatorCode"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('categorie') +' : </span><span id="aSLICategorie"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('item') +' : </span><span id="aSLIItem"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('price') +' : </span><span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="aSLIPrice">N/A</span></span></div>\
              <div class="adminDisplayDescription" id="adminLogItemLootboxReward"><span class="aDDspan">'+ _('reward') +' : </span><span id="aSLIReward"></span></div>\
            </div>\
          </div>\
        </div>\
        <div class="listMain" id="logsItemsList"></div>'
    
    // LOGS TRANSACTIONS
    document.getElementById("adminLogsTransactions").innerHTML = '\
        <div class="main-head firstHead">'+ _U("selectTitle") +'</div>\
        <div class="main-head secondHead">'+ _U("logs_title") +'<span id="filterTransactionsLogs"><i class="fa-solid fa-filter"></i>'+ _U("filter") +'</span></div>\
        <div class="selectionArea">\
          <div id="adminSelectLogTransactionContainer">\
            <div class="selectHead"><span id="adminSelectLogTransactionName"></span></div>\
            <div id="adminSelectLogTransactionDescription">\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('date') +' : </span><span id="aSLTDate"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('sender') +' : </span><span id="aSLTSender"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('receiver') +' : </span><span id="aSLTReceiver"></span></div>\
              <div class="adminDisplayDescription"><span class="aDDspan">'+ _('amount') +' : </span><span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="aSLTAmount">N/A</span></span></div>\
            </div>\
          </div>\
        </div>\
        <div class="listMain" id="logsTransactionsList"></div>'

    // NOTIFICATIONS
    document.getElementById("processing").innerHTML = '<div class="notif-icon"><i class="fa-solid fa-circle-notch fa-spin"></i></div><div class="notif-text">'+ _U('processing') +'</div>'
    document.getElementById("success-notif").innerHTML = '<div id="success-icon" class="notif-icon"><i class="fa-regular fa-circle-check"></i></div><div id="success-text" class="notif-text">'+ _U('success') +'<div class="line notif-line"></div><div class="subtext" id="success-subtext"><i class="fa-solid fa-coins"></i></div></div>'
    document.getElementById("error-notif").innerHTML = '<div id="error-icon" class="notif-icon"><i class="fa-regular fa-circle-xmark"></i></div><div id="error-text" class="notif-text">'+ _U('error') +'<div class="line notif-line"></div><div class="subtext" id="error-subtext"><i class="fa-solid fa-coins"></i></div></div>'
    document.getElementById("info-notif").innerHTML = '<div id="info-icon" class="notif-icon"><i class="fa-solid fa-circle-info"></i></div><div id="info-text" class="notif-text">'+ _U('info') +'<div class="line notif-line"></div><div class="subtext" id="info-subtext"><i class="fa-solid fa-coins"></i></div></div>'
    document.getElementById("welcome-notif").innerHTML = '<div id="welcome-icon" class="notif-icon"><i class="fa-solid fa-hands-clapping fa-shake"></i></div><div id="welcome-text" class="notif-text">'+ _U('welcome_title') +'<div class="line notif-line"></div><div class="subtext" id="welcome-subtext">'+ _('welcome_content') +'<span id="welcomeLogin">MGD-0000</span></div></div>'
}

function UpdateHour() {
    let d = new Date();
    let h = d.getHours();
    let m = d.getMinutes();
    if (h<10) {h = "0" + d.getHours();}
    if (m<10) {m = "0" + d.getMinutes();}
    $("#hour").text(h + "h" + m);
}

function InsertData(data) {
    document.getElementById('title').innerText = (CONFIG.title + " " + CONFIG.serverName).toUpperCase();
    $("#purseAmount").text(data.shopTokens)
    $("#homeLogin").text(data.shopID)
    $("#homeID").text(data.serverID)
    $("#homeRank").text(GetRankLabel(data.shopRank))

    if (data.group === CONFIG.adminGroup) {
        $("#adminMenu").show();
    }
}

function SelectReward(boxName) {
    let totalChance = 0;
    for (const reward of CONFIG["shopItems"]["lootboxs"][boxName].reward) {
      totalChance += reward.luck;
    }

    let roll = Math.floor(Math.random() * totalChance);
    let cumulativeChance = 0;
    for (const reward of CONFIG["shopItems"]["lootboxs"][boxName].reward) {
        cumulativeChance += reward.luck;
        if (cumulativeChance > roll) {
        return reward;
        }
    }
}

function GetRankLabel(rank) {
    if (rank === "user") {
        return "Joueur"
    } else {
        return CONFIG['shopItems']['rangs'][rank].label;
    }
}

function GetRankPower(rank) {
    if (rank === "user") {
        return '0'
    } else {
        return CONFIG['shopItems']['rangs'][rank].power;
    }
}

function timedNotification(time, notifType, message) {
    $('#'+ notifType +'-notif').hide();
    $('#'+ notifType +'-subtext').text(message)
    $('#'+ notifType +'-notif').slideDown(750);
    setTimeout(function(){
      $('#'+ notifType +'-notif').slideUp(750);
    }, time * 1000);
}

function logItemsFilterToSQL(filter, value) {
    switch(filter) {
      case 'none':
        return '';
      case 'shopID':
        return 'WHERE `pShopID` = "'+ value +'"';
      case 'item':
        return 'WHERE `hItem` = "'+ value +'"';
      case 'date':
        return 'WHERE `hDate` = "'+ value +'"';
      case 'creatorCode':
        return 'WHERE `hCreatorCodeUsed` = "'+ value +'"';
      default:
        return 'WHERE `hCategorie` = "'+ filter +'"';
    }
}

function logTransactionsFilterToSQL(filter, value) {
    switch(filter) {
        case 'none':
        return '';
        case 'shopID':
        return 'WHERE `sShopID` = "'+ value +'" OR `rShopID` = "'+ value +'"';
        case 'date':
        return 'WHERE `hDate` = "'+ value +'"';
        case 'sender':
        return 'WHERE `sShopID` = "'+ value +'"';
        case 'receiver':
        return 'WHERE `rShopID` = "'+ value +'"';
        default:
        return '';
    }
}

function filterPlaceholderDisplay() {
    var categorie = document.getElementById('filterLogsCategorie').value;
    switch(categorie) {
      case 'shopID':
        return 'MGD-0000';
      case 'item':
        return 'iron';
      case 'date':
        return 'DD/MM/YYYY';
      case 'creatorCode':
        return 'MGDEV';
      default:
        return 'Valeur non nécessaire';
    }
}

function buildCategorieList(categorie) {
    $('#categorieList').empty();
    Object.keys(CONFIG['shopItems'][categorie]).forEach(function(itemIndex) {
      var itemData = CONFIG['shopItems'][categorie][itemIndex];
      document.getElementById('categorieList').innerHTML += '<div class="listItem categorieItem" id='+ itemIndex +'>'+ itemData.label.toUpperCase() +'<span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="itemPriceValue">'+ itemData.price +'</span></span></div>';
    });
}

function buildHistoryList() {
    $('#historyItems').empty();
    $('#historyTransactions').empty();
    $.post('http://mgd_shop/getPlayerHistory', JSON.stringify({}), function(resultHistory) {
      var hI = resultHistory.items;
      var hT = resultHistory.transactions;
      Object.keys(hI).forEach(function(index) {
        var data = hI[index];
        document.getElementById('historyItems').innerHTML += '<div class="listItem">'+ data.hDate +' - '+ data.hHour +'<span id="historyContent"><span id="newItemCategorie">'+ data.hCategorie.toUpperCase() +'</span><i class="fa-solid fa-arrow-right arrowIcon"></i>'+ CONFIG["shopItems"][data.hCategorie][data.hItem].label.toUpperCase() +'</span><span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="historyPrice">'+ data.hPrice +'</span></span></div>';
      });

      Object.keys(hT).forEach(function(index) {
        var data = hT[index];
        if (data.sShopID === userShopData.shopID) {
          document.getElementById('historyTransactions').innerHTML += '<div class="listItem hTransactionsItem">'+ data.hDate +' - '+ data.hHour +'<span id="historyShopID"><i class="fa-solid fa-arrow-trend-down" style="color:#ef5350d6"></i> '+ data.rShopID +'</span><span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="itemPriceValue">'+ data.tAmount +'</span></span></div>';
        } else {
          document.getElementById('historyTransactions').innerHTML += '<div class="listItem hTransactionsItem">'+ data.hDate +' - '+ data.hHour +'<span id="historyShopID"><i class="fa-solid fa-arrow-trend-up" style="color:#4caf50d6"></i> '+ data.sShopID +'</span><span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="itemPriceValue">'+ data.tAmount +'</span></span></div>';
        }
      });
    });
}

function buildCodesCreatorsList(data) {
    $('#creatorCodeList').empty();
    Object.keys(data).forEach(function(index) {
      document.getElementById('creatorCodeList').innerHTML += '<div class="listItem categorieItem" id='+ index +'>'+ index +'<span>'+ data[index] +'</span></div>';
    });

    Object.keys(data).forEach(function(index) {
      $('#'+ index).click(function(){
        if (document.getElementsByClassName('selectedItem')[0] !== undefined) { document.getElementsByClassName('selectedItem')[0].classList.remove("selectedItem") }
        document.getElementById(index).classList.add("selectedItem");
        $('#adminSelectContainer').hide();
        $('#adminSelectContainer').fadeIn(250);
        $('#adminSelectName').text(index.toUpperCase());
        $('#acCode').text(index.toUpperCase());
        $('#acIdentifier').text(data[index]);
        $.post('http://mgd_shop/creatorCodeMoney', JSON.stringify({
            refCode: index.toUpperCase()
          }), function(money) {
            $('#acMoney').text(money);
          })
      });
    });
}

function buildLogsItemsList() {
    $('#adminSelectLogItemContainer').hide();
    var filter = document.getElementById("filterLogsCategorie").options[document.getElementById("filterLogsCategorie").selectedIndex].value
    var value = document.getElementById('filterLogsValue').textContent;
    $('#logsItemsList').empty();
    $.post('http://mgd_shop/getAdminLogsItems', JSON.stringify({
      filter: logItemsFilterToSQL(filter, value)
    }), function(result) {
      Object.keys(result).forEach(function(index) {
        var data = result[index];
        document.getElementById('logsItemsList').innerHTML += '<div id=item-'+ data.id +' class="listItem categorieItem">'+ data.hDate +' - '+ data.hHour +'<span><span id="newItemCategorie">'+ data.hCategorie.toUpperCase() +'</span><i class="fa-solid fa-arrow-right arrowIcon"></i>'+ CONFIG["shopItems"][data.hCategorie][data.hItem].label.toUpperCase() +'</span><span>'+ data.pShopID +'</span></div>';
      });

      Object.keys(result).forEach(function(index) {
        var data = result[index];
        var idBox = "item-"+data.id
        $('#'+ idBox).click(function(){
          if (document.getElementsByClassName('selectedItem')[0] !== undefined) { document.getElementsByClassName('selectedItem')[0].classList.remove("selectedItem") }
          document.getElementById(idBox).classList.add("selectedItem");
          $('#adminSelectLogItemContainer').hide();
          $('#adminSelectLogItemContainer').fadeIn(250);
          $('#adminSelectLogItemName').text("LOG " + idBox)
          $('#aSLIDate').text(data.hDate +' - '+ data.hHour)
          $('#aSLIPlayer').text(data.pShopID + ' (' + data.pIdentifier + ')')
          $('#aSLICreatorCode').text(data.hCreatorCodeUsed)
          $('#aSLICategorie').text(data.hCategorie.toUpperCase())
          $('#aSLIItem').text(data.hItem)
          $('#aSLIPrice').text(data.hPrice)
          $('#adminLogItemLootboxReward').hide();
          if (data.hCategorie === "lootboxs") {
            $('#adminLogItemLootboxReward').show();
            if (data.hReward.rewardLabel !== undefined) {
              $('#aSLIReward').text(data.hReward.rewardLabel)
            } else {
              data.hReward = JSON.parse(data.hReward)
              $('#aSLIReward').text(data.hReward.rewardLabel)
            }
          }
      });
    });
  })
}

function buildLogsTransactionsList() {
    $('#adminSelectLogItemContainer').hide();
    var filter = document.getElementById("filterLogsCategorie").options[document.getElementById("filterLogsCategorie").selectedIndex].value
    var value = document.getElementById('filterLogsValue').textContent;
    $('#logsTransactionsList').empty();
    $.post('http://mgd_shop/getAdminLogsTransactions', JSON.stringify({
      filter: logTransactionsFilterToSQL(filter, value)
    }), function(result) {
      Object.keys(result).forEach(function(index) {
        var data = result[index];
        document.getElementById('logsTransactionsList').innerHTML += '<div id=transaction-'+ data.id +' class="listItem categorieItem">'+ data.hDate +' - '+ data.hHour +'<span>'+ data.sShopID +'<i class="fa-solid fa-arrow-right arrowIcon"></i>'+ data.rShopID +'</span><span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="newItemPrice">' + data.tAmount + '</span></div>';
      });

      Object.keys(result).forEach(function(index) {
        var data = result[index];
        var idBox = "transaction-"+data.id
        $('#'+ idBox).click(function(){
          if (document.getElementsByClassName('selectedItem')[0] !== undefined) { document.getElementsByClassName('selectedItem')[0].classList.remove("selectedItem") }
          document.getElementById(idBox).classList.add("selectedItem");
          $('#adminSelectLogTransactionContainer').hide();
          $('#adminSelectLogTransactionContainer').fadeIn(250);
          $('#adminSelectLogTransactionName').text("LOG ID " + idBox)
          $('#aSLTDate').text(data.hDate +' - '+ data.hHour)
          $('#aSLTSender').text(data.sShopID +" ("+ data.sIdentifier +")")
          $('#aSLTReceiver').text(data.rShopID +" ("+ data.rIdentifier +")")
          $('#aSLTAmount').text(data.tAmount)
      });
    });
    })
}

function clickableCategorieItem(categorie) {
    Object.keys(CONFIG['shopItems'][categorie]).forEach(function(item) {
      $('#'+ item).click(function(){
        var itemData = CONFIG['shopItems'][categorie][item]
        if (document.getElementsByClassName('selectedItem')[0] !== undefined) { document.getElementsByClassName('selectedItem')[0].classList.remove("selectedItem") }
        document.getElementById(item).classList.add("selectedItem");
        document.getElementById('selectName').itemData = itemData;
        document.getElementById('selectName').categorie = categorie;
        document.getElementById('selectName').item = item;
        $('#selectContainer').hide();
        $('#selectDescription').empty();
        $('#selectContainer').fadeIn(250);
        $('#selectName').text(itemData.label.toUpperCase());
        if (itemData.image === true) {
          document.getElementById('selectDescription').innerHTML += '<div class="descriptionImg"><img src="./img/'+ item +'.png"/></div>';
        }
        document.getElementById('selectDescription').innerHTML += itemData.description;
        if (categorie == "lootboxs") {
          Object.keys(CONFIG['shopItems'][categorie][item]["reward"]).forEach(function(i) {
            var data = CONFIG['shopItems'][categorie][item]["reward"][i]
            document.getElementById('selectDescription').innerHTML += "- " + data.rewardLabel + " ("+ data.luck +"%)<br>";
          });
        }
      });
  });
}

function Lootbox(boxName) {
    document.getElementById("lootboxModel").style.transform = "rotateX(350deg) rotateY(30deg) rotateZ(0deg)"; document.getElementById("lootboxModel").style.top = "40%";
    document.getElementById("lootboxModel").classList.remove('lb-open');
    document.getElementById("browse").style.opacity = "0"; $("#closeShop").hide();
    $("#lootbox").show();
    $('#lootbox').one("click", function() {
      var selectedReward = SelectReward(boxName);
      var creatorCode = "-"
      if (document.getElementById("creatorCode")) {
        creatorCode = document.getElementById("creatorCode").textContent
      }
      $.post('http://mgd_shop/buyItem', JSON.stringify({
        categorie: "lootboxs",
        item: boxName,
        creatorCode: creatorCode,
        lootboxsInfos: selectedReward
        }), function(cb) {
          if (cb === true) {
            var purse = document.getElementById("purseAmount").textContent;
            $('#purseAmount').text(purse - CONFIG["shopItems"]["lootboxs"][boxName].price)
            userShopData.shopTokens = userShopData.shopTokens - CONFIG["shopItems"]["lootboxs"][boxName].price
            document.getElementById("lootboxModel").style.transform = "rotateX(350deg) rotateY(570deg) rotateZ(0deg)"; document.getElementById("lootboxModel").style.top = "55%";
            document.getElementById("lootboxModel").classList.add('lb-open');
            setTimeout(function(){
              $("#lootboxReward").show();
              document.getElementById("lbr-reward").innerHTML = selectedReward.rewardLabel.toUpperCase();

              if (selectedReward.type === "coins") {
                userShopData.shopTokens = userShopData.shopTokens + selectedReward.reward
                document.getElementById("purseAmount").innerHTML = userShopData.shopTokens;
              }

              if (selectedReward.type === "rank") {
                if (GetRankPower(userShopData.shopRank) >= GetRankPower(selectedReward.reward)) {
                  userShopData.shopTokens = userShopData.shopTokens + CONFIG["shopItems"]["rangs"][selectedReward.reward].price
                  document.getElementById("purseAmount").innerHTML = userShopData.shopTokens;
                  setTimeout(function(){
                    timedNotification(3, "info", _('alreadyHaveRank') + CONFIG.moneyName)
                  }, 3 * 1000);
                } else {
                  userShopData.shopRank = selectedReward.reward
                }
              }
              
              $.post('http://mgd_shop/lootboxReward', JSON.stringify({
                reward: selectedReward
              }), function(cb) {
                if (cb === true) {
                  setTimeout(function(){
                    document.getElementById("lootboxModel").style.transform = "rotateX(350deg) rotateY(30deg) rotateZ(0deg)"; document.getElementById("lootboxModel").style.top = "40%";
                    document.getElementById("lootboxModel").classList.remove('lb-open');
                    setTimeout(function(){
                      $("#lootboxReward").fadeOut(250);
                      $("#lootbox").fadeOut(250);
                      document.getElementById("browse").style.opacity = "1"; $("#closeShop").show()
                    }, 1.25 * 1000);
                  }, 4 * 1000);
                } else {
                  $("#lootbox").fadeOut(250);
                  timedNotification(4, 'error', cb)
                }
              });
            }, 1.5 * 1000);
          } else {
            $("#lootbox").fadeOut(250);
            timedNotification(4, 'error', cb)
          }
      });
    })
}

function _(msg) {
    return CONFIG.LANG[CONFIG.lang][msg]
}

function _U(msg) {
    return CONFIG.LANG[CONFIG.lang][msg].toUpperCase()
}