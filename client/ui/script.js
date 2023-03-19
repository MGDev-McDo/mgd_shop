window.onload = function(e) {
  $.getJSON("./config.json", function(CONFIG) {
  window.addEventListener('message', (event) => {
    var data = event.data;
    if (data !== undefined) {
      userShopData = data.userShopData;
      userShopData.serverID = data.serverID

      if (data.display === true) {
        // BUILD SHOP HTML
        BuildShop();

        // INSERT DATA IN HTML
        InsertData(userShopData);

        $("#lootbox").hide(); $("#browse").hide(); $("#adminCreatorsCodes").hide(); $("#adminLogsItems").hide(); $('#adminLogsTransactions').hide();
        $("#navbarAdmin").hide(); $("#pHistory").hide();
        $("#homeMain").show();
        $("#shop-main").fadeIn(250);

        if (data.firstOpen === true) {
          $("#welcomeLogin").text(userShopData.shopID)
          timedNotification(5, 'welcome')
        }
      } else {
        $("#shop-main").fadeOut(250);
      }
    }

    /** INPUT **/
    document.addEventListener('keydown', function(event) {
      if (document.getElementById('inputText').offsetWidth > 0) {
        if (event.code == 'Enter') {
          inputValidation(document.getElementById('inputText').name, document.getElementById('inputText').value)
        } else if (event.code == 'Escape') {
          $('#input-text').fadeOut(250);
        }
      }
    });

    $('#submitInput').click(function(){
      inputValidation(document.getElementById('inputText').name, document.getElementById('inputText').value)
    });

    $('#cancelInput').click(function(){
      $('#input-text').fadeOut(250);
    });
    
    function inputValidation(type, value) {
      $('#input-text').fadeOut(250);
      switch(type) {
        case 'idCoins':
          if (value.startsWith("MGD-") || !isNaN(value) && value > 0) {
            if (value !== document.getElementById("homeLogin").textContent && value !== document.getElementById("homeID").textContent) {
              document.getElementById("idToSendCoins").classList.remove("exampleDisplay");
              $('#idToSendCoins').text(value);
            } else {
              timedNotification(3, 'error', _('error_u_receiver'))
            }
          } else {
            timedNotification(3, 'error', _('error_receiver'))
          }
          break;
        case 'amountCoins':
          if (!isNaN(value) && value > 0) {
            document.getElementById("displayAmountToSendCoins").classList.remove("exampleDisplay");
            $('#displayAmountToSendCoins').text(value.replace('.', ''))
          } else {
            timedNotification(3, 'error', _('error_amount'))
          }
          break;
        case 'creatorCode':
          if (value.length > 0) {
            value = value.toUpperCase()
            if (data.creatorsCodes[value] !== undefined || value === "-") {
              $('#creatorCode').text(value);
              if (value === "-") {
                timedNotification(3, 'info', _('info_no_code'))
              } else {
                timedNotification(3, 'success', _('success_code') + value)
              }
            } else {
              timedNotification(3, 'error', _('error_codeNoExist'))
            }
          } else {
            $('#creatorCode').text("-");
            timedNotification(3, 'info', _('info_no_code'))
          }
          break;
        case 'editcCode':
          if (value.length > 0) {
            value = value.toUpperCase()
            if (data.creatorsCodes[value] !== undefined) {
              timedNotification(3, 'error', _('error_codeAlreadyExist'))
            } else {
              var oldCode = document.getElementById("acCode").textContent
              $.post('http://mgd_shop/creatorCodeUpdate', JSON.stringify({
                updateType: "code",
                oldValue: oldCode,
                newValue: value,
                refCode: ""
              }), function(success) {
                if (success === true) {
                  data.creatorsCodes[value] = data.creatorsCodes[oldCode];
                  delete data.creatorsCodes[oldCode];
                  buildCodesCreatorsList()
                  $('#adminSelectName').text(value);
                  $('#acCode').text(value);
                  timedNotification(3, 'success', _('success_edit_code'))
                } else {
                  timedNotification(3, 'error', _('error_server'))
                }
              });
            }
          }
          else {
            timedNotification(3, 'error', _('error_noData'))
          }
          break;
        case 'editcIdentifier':
          if (value.length > 0) {
            var refCode = document.getElementById("acCode").textContent
            $.post('http://mgd_shop/creatorCodeUpdate', JSON.stringify({
              updateType: "identifier",
              oldValue: "",
              newValue: value,
              refCode: refCode
            }), function(success) {
              if (success === true) {
                data.creatorsCodes[refCode] = value;
                buildCodesCreatorsList()
                $('#acIdentifier').text(value);
                timedNotification(3, 'success', _('success_edit_identifier'))
              } else {
                timedNotification(3, 'error', _('error_server'))
              }
            });
          }
          else {
            timedNotification(3, 'error', _('error_noData'))
          }
          break;
        case 'cCCodeCode':
          value = value.toUpperCase();
          if (value.length > 0) {
            if (data.creatorsCodes[value] !== undefined) {
              timedNotification(3, 'error', _('error_codeAlreadyExist'))
            } else {
              document.getElementById("cCCodeCode").classList.remove("exampleDisplay");
              $('#cCCodeCode').text(value);
            }
          } else {
            timedNotification(3, 'error', _('error_noData'))
          }
          break;
        case 'cCCodeIdentifier':
          if (value.length > 0) {
            document.getElementById("cCCodeIdentifier").classList.remove("exampleDisplay");
            $('#cCCodeIdentifier').text(value);
          } else {
            timedNotification(3, 'error', _('error_noData'))
          }
          break;
        case 'filterLogsValue':
          $('#filterLogsValue').text(value);
          break;
        default:
          alert("ERR type inputValidation")
      }
    }

    /** COINS FORM **/
    $("#idToSendCoins").click(function(){
      $("#input-text").hide();
      document.getElementById('inputText').value = "";
      document.getElementById('inputText').name = 'idCoins';
      document.getElementById('inputText').placeholder = 'MGD-0001 / 1';
      $("#input-text").fadeIn(250);
    });

    $("#amountToSendCoins").click(function(){
      $("#input-text").hide();
      document.getElementById('inputText').value = "";
      document.getElementById('inputText').name = 'amountCoins';
      document.getElementById('inputText').placeholder = '1';
      $("#input-text").fadeIn(250);
    });

    $("#sendCoins").click(function(){
      $("#input-text").hide();
      $('#idToSendCoins').text("MGD-OOOO");
      $('#displayAmountToSendCoins').text("0");
      document.getElementById("idToSendCoins").classList.add("exampleDisplay");
      document.getElementById("displayAmountToSendCoins").classList.add("exampleDisplay");
      $("#coinsForm").fadeIn(250);
    });
    
    $("#closeCoinsForm").click(function(){
      $("#input-text").hide();
      $("#coinsForm").fadeOut(250);
    });

    $("#moreInfoReceiver").hover(
      function(){
        $("#moreInfoReceiverExplain").fadeIn(150);
      },
      function(){
        $("#moreInfoReceiverExplain").fadeOut(150);
      }
    );

    $('#submitCoinsForm').click(function(){
      var receiver = document.getElementById("idToSendCoins").textContent;
      var amount = document.getElementById("displayAmountToSendCoins").textContent;
      if (receiver !== "MGD-OOOO") {
        if (amount > 0) {
          if (amount > userShopData.shopTokens) {
            timedNotification(3, 'error', _('error_coinsForm'))
          } else {
            var type = "serverID"
            if (receiver.startsWith("MGD-")) { type = "shopID" }
            $("#coinsForm").fadeOut(250);
            $('#processing').slideDown(250);
            $.post('http://mgd_shop/submitCoinsForm', JSON.stringify({
              type: type,
              sender: userShopData.shopID,
              receiver: receiver,
              amount: amount
            }), function(cb) {
              $('#processing').slideUp(250);
              if (cb === true) {
                var purse = document.getElementById("purseAmount").textContent;
                $('#purseAmount').text(purse - amount)
                userShopData.shopTokens = userShopData.shopTokens - amount
                timedNotification(3, 'success', _('success_coinsForm'))
              } else {
                timedNotification(4, 'error', cb)
              }
            });
          }
        } else {
          timedNotification(3, 'error', _('error_amount'))
        }
      } else {
        timedNotification(3, 'error', _('error_receiver'))
      }
    });

    /** CREATOR CODE **/
    $('#creatorCode').click(function(){
      $("#input-text").hide();
      document.getElementById('inputText').value = "";
      document.getElementById('inputText').name = 'creatorCode';
      document.getElementById('inputText').placeholder = 'MGDEV';
      $("#input-text").fadeIn(250);
    });

    /** BUY BUTTON **/
    $('#buyButton').click(function(){
      var itemData = document.getElementById('selectName').itemData;
      var categorie = document.getElementById('selectName').categorie;
      var item = document.getElementById('selectName').item;
      var purse = document.getElementById("purseAmount").textContent;
      if (purse >= itemData.price) {
        if(categorie == "rangs" && (GetRankPower(userShopData.shopRank) >= GetRankPower(item))) {
          return timedNotification(3, 'error', _('error_bigRank'))
        }
        $('#processing').slideDown(750);
        if(categorie === "lootboxs") {
          $('#processing').slideUp(750);
          Lootbox(item)
          return
        }
        var creatorCode = "-"
        if (document.getElementById("creatorCode")) {
          creatorCode = document.getElementById("creatorCode").textContent
        }
        $.post('http://mgd_shop/buyItem', JSON.stringify({
          categorie: categorie,
          item: item,
          creatorCode: creatorCode
        }), function(cb) {
          $('#processing').slideUp(750);
          if (cb === true) {
            if(categorie === "rangs") {
              $("#homeRank").text(GetRankLabel(item))
              userShopData.shopRank = item
            }
            if(categorie === "vehicules") {
              $("#shop-main").fadeOut(250);
              $.post('http://mgd_shop/closeShopUI', JSON.stringify({}));
            }
            var purse = document.getElementById("purseAmount").textContent;
            $('#purseAmount').text(purse - itemData.price)
            userShopData.shopTokens = userShopData.shopTokens - itemData.price
            timedNotification(3, 'success', _('success_buy'))
          } else {
            timedNotification(4, 'error', cb)
          }
        });
      } else {
        timedNotification(3, 'error', _('error_notEnoughCoins'))
      }  
    });

    /** CLOSE SHOP **/
    $('#closeShop').click(function() {
      $("#shop-main").fadeOut(250);
      $.post('http://mgd_shop/closeShopUI', JSON.stringify({}));
    });

    /** HISTORY PLAYER **/
    $('#playerHistory').click(function() {
      if (document.getElementsByClassName('navbar-item-selected')[0] !== undefined) { document.getElementsByClassName('navbar-item-selected')[0].classList.remove("navbar-item-selected") }
      $('#browse').hide();
      $('#homeMain').hide();
      buildHistoryList();
      $('#pHistory').fadeIn(250);
    });

    /** ADMIN **/
    $('#adminMenu').click(function() {
      if (document.getElementsByClassName('navbar-item-selected')[0] !== undefined) { document.getElementsByClassName('navbar-item-selected')[0].classList.remove("navbar-item-selected") }
      $('#browse').hide();
      $('#homeMain').hide();
      $('#navbarAdmin').fadeIn(250);
    });

    $('#adminNav_creatorsCodes').click(function() {
      if (document.getElementsByClassName('navbar-item-selected')[0] !== undefined) { document.getElementsByClassName('navbar-item-selected')[0].classList.remove("navbar-item-selected") }
      document.getElementById("adminNav_creatorsCodes").classList.add("navbar-item-selected");
      $('#adminSelectContainer').hide();
      $('#adminSelectLogItemContainer').hide();
      $('#adminLogsItems').hide();
      $('#adminLogsTransactions').hide();
      buildCodesCreatorsList(data.creatorsCodes);
      $("#adminCreatorsCodes").fadeIn(250);
    });

    $("#closeCCCodeForm").click(function(){
      $("#input-text").hide();
      $("#createCCodeForm").fadeOut(250);
    });

    $('#newCreatorCode').click(function() {
      $("#input-text").hide();
      $('#cCCodeCode').text("MGDEV");
      $('#cCCodeIdentifier').text("steam:000000000000000");
      document.getElementById("cCCodeCode").classList.add("exampleDisplay");
      document.getElementById("cCCodeIdentifier").classList.add("exampleDisplay");
      $('#createCCodeForm').fadeIn(250);
    });

    $("#cCCodeCode").click(function(){
      $("#input-text").hide();
      document.getElementById('inputText').value = "";
      document.getElementById('inputText').name = 'cCCodeCode';
      document.getElementById('inputText').placeholder = 'MGDEV';
      if (document.getElementById('cCCodeCode').textContent !== 'MGDEV') {
        document.getElementById('inputText').value = document.getElementById('cCCodeCode').textContent;
      }
      $("#input-text").fadeIn(250);
    });

    $("#cCCodeIdentifier").click(function(){
      $("#input-text").hide();
      document.getElementById('inputText').value = "";
      document.getElementById('inputText').name = 'cCCodeIdentifier';
      document.getElementById('inputText').placeholder = 'steam:000000000000000';
      if (document.getElementById('cCCodeIdentifier').textContent !== 'steam:000000000000000') {
        document.getElementById('inputText').value = document.getElementById('cCCodeIdentifier').textContent;
      }
      $("#input-text").fadeIn(250);
    });

    $('#submitCCCodeForm').click(function(){
      var code = document.getElementById("cCCodeCode").textContent;
      var identifier = document.getElementById("cCCodeIdentifier").textContent;
      if (data.creatorsCodes[code] !== undefined) {
        timedNotification(3, 'error', _('error_codeExist'))
      } else {
        $("#createCCodeForm").fadeOut(250);
        $('#processing').slideDown(250);
        $.post('http://mgd_shop/creatorCodeCreate', JSON.stringify({
          code: code,
          identifier: identifier
        }), function(cb) {
          $('#processing').slideUp(250);
          if (cb === true) {
            data.creatorsCodes[code] = identifier;
            buildCodesCreatorsList(data.creatorsCodes);
            timedNotification(3, 'success', _('success_create_code'))
          } else {
            timedNotification(4, 'error', _('error_server'))
          }
        });
      }
    });

    $('#deleteButton').click(function() {
      var refCode = document.getElementById("acCode").textContent
      $.post('http://mgd_shop/creatorCodeDelete', JSON.stringify({
        refCode: refCode
      }), function(success) {
        if (success === true) {
          delete data.creatorsCodes[refCode];
          buildCodesCreatorsList(data.creatorsCodes)
          $('#adminSelectContainer').hide();
          timedNotification(3, 'success', _('success_delete_code'))
        } else {
          timedNotification(3, 'error', _('error_server'))
        }
      })
    });
     
    $('#acCode').click(function() {
      $("#input-text").hide();
      document.getElementById('inputText').value = "";
      document.getElementById('inputText').name = 'editcCode';
      document.getElementById('inputText').placeholder = document.getElementById("acCode").textContent;
      $("#input-text").fadeIn(250);
    });

    $('#acIdentifier').click(function() {
      $("#input-text").hide();
      document.getElementById('inputText').value = "";
      document.getElementById('inputText').name = 'editcIdentifier';
      document.getElementById('inputText').placeholder = document.getElementById("acIdentifier").textContent;
      $("#input-text").fadeIn(250);
    });

    $('#adminNav_logsItems').click(function() {
      $('#filterLogsCategorie').empty();
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="none"></option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="shopID">'+ _U('filter_shopID') +'</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="item">'+ _U('filter_shopItem') +'</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="date">'+ _U('date') +'</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="creatorCode">'+ _U('shopSub_creatorCode') +'</option>';
      Object.keys(CONFIG['shopItems']).forEach(function(categorie) {
        document.getElementById("filterLogsCategorie").innerHTML += '<option custom="categorie" value='+ categorie +'>CATEGORIE : '+ categorie.toUpperCase() +'</option>'
      });
      if (document.getElementsByClassName('navbar-item-selected')[0] !== undefined) { document.getElementsByClassName('navbar-item-selected')[0].classList.remove("navbar-item-selected") }
      document.getElementById("adminNav_logsItems").classList.add("navbar-item-selected");
      $('#adminSelectContainer').hide();
      $('#adminSelectLogItemContainer').hide();
      $('#adminLogsTransactions').hide();
      $('#adminCreatorsCodes').hide();
      buildLogsItemsList()
      $('#adminLogsItems').fadeIn(250);
    });

    $('#filterItemsLogs').click(function() {
      $("#input-text").hide();
      document.getElementById('filterLogsForm').type = "items";
      $('#filterLogsForm').fadeIn(250);
    });

    $('#filterTransactionsLogs').click(function() {
      $("#input-text").hide();
      document.getElementById('filterLogsForm').type = "transactions";
      $('#filterLogsForm').fadeIn(250);
    });

    $("#closeFilterLogsForm").click(function(){
      $("#input-text").hide();
      $("#filterLogsForm").fadeOut(250);
    });

    $('#filterLogsValue').click(function() {
      $("#input-text").hide();
      document.getElementById('inputText').value = "";
      document.getElementById('inputText').name = 'filterLogsValue';
      document.getElementById('inputText').placeholder = filterPlaceholderDisplay();
      $("#input-text").fadeIn(250);
    });
    
    $('#submitFilterLogsForm').click(function(){
      $('#adminSelectLogItemContainer').hide();
      $('#adminSelectLogTransactionContainer').hide();
      $("#filterLogsForm").fadeOut(250);
      if (document.getElementById('filterLogsForm').type === "items") { buildLogsItemsList() }
      if (document.getElementById('filterLogsForm').type === "transactions") { buildLogsTransactionsList() }
    });

    $('#adminNav_logsTransactions').click(function() {
      $('#filterLogsCategorie').empty();
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="none"></option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="shopID">'+ _U('filter_shopID') +'</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="date">'+ _U('date') +'</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="sender">'+ _U('sender') +'</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="receiver">'+ _U('receiver') +'</option>';
      if (document.getElementsByClassName('navbar-item-selected')[0] !== undefined) { document.getElementsByClassName('navbar-item-selected')[0].classList.remove("navbar-item-selected") }
      document.getElementById("adminNav_logsTransactions").classList.add("navbar-item-selected");
      $('#adminSelectContainer').hide();
      $('#adminSelectLogItemContainer').hide();
      $('#adminSelectLogTransactionContainer').hide();
      $('#adminCreatorsCodes').hide();
      $("#adminLogsItems").hide();
      buildLogsTransactionsList()
      $('#adminLogsTransactions').fadeIn(250);
    });
    
    /** CLICK - CATEGORIES **/
    Object.keys(CONFIG['shopItems']).forEach(function(categorie) {
      $('#'+ categorie).click(function(){
        if (document.getElementsByClassName('navbar-item-selected')[0] !== undefined) { document.getElementsByClassName('navbar-item-selected')[0].classList.remove("navbar-item-selected") }
        $('#selectContainer').hide();
        $('#homeMain').hide();
        $('#browse').hide();
        $("#pHistory").hide();
        $("#adminCreatorsCodes").hide();
        $("#adminLogsItems").hide();
        $('#adminLogsTransactions').hide();
        $("#navbarAdmin").hide();
        $('#browse').fadeIn(250);
        document.getElementById(categorie).classList.add("navbar-item-selected");
        $('#categorieName').text(categorie.toUpperCase());
        if (categorie === "vehicules") {
          timedNotification(1.15, "info", _('info_categ_veh'))
        }
        buildCategorieList(categorie);
        clickableCategorieItem(categorie);
      });
    });

    $('#home').click(function() {
      if (document.getElementsByClassName('navbar-item-selected')[0] !== undefined) { document.getElementsByClassName('navbar-item-selected')[0].classList.remove("navbar-item-selected") }
      $('#browse').hide();
      $("#pHistory").hide();
      $("#adminCreatorsCodes").hide();
      $("#adminLogsItems").hide();
      $('#adminLogsTransactions').hide();
      $("#navbarAdmin").hide();
      $('#homeMain').fadeIn(250);
      document.getElementById("home").classList.add("navbar-item-selected");
    });
})})};