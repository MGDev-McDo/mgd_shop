window.onload = function(e) {
  $.getJSON("./config.json", function(CONFIG) {
  window.addEventListener('message', (event) => {
    var data = event.data;
    if (data !== undefined) {
      var userShopData = data.userShopData;
      userShopData.serverID = data.serverID

      if (data.display === true) {
        $('#version').text("v"+ CONFIG.version)
        updateHour();
        setInterval(updateHour, 5000);
        insertData(userShopData);
        buildNavbar();
        buildNewsList();

        document.getElementById("home").classList.add("navbar-item-selected");
        $("#lootbox").hide();
        $("#browse").hide();
        $("#adminCreatorsCodes").hide();
        $("#adminLogsItems").hide();
        $('#adminLogsTransactions').hide();
        $("#navbarAdmin").hide();
        $("#pHistory").hide();
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
            timedNotification(3, 'error', "Ton nombre de coins ne te permet pas de faire cela.")
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
                timedNotification(3, 'success', "L'envoie a bien été effectué.")
              } else {
                timedNotification(4, 'error', cb)
              }
            });
          }
        } else {
          timedNotification(3, 'error', "Le montant est invalide.")
        }
      } else {
        timedNotification(3, 'error', "Le destinaire n'est pas valide.")
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
      if (userShopData.shopTokens >= itemData.price) {
        if(categorie == "rangs" && (GetRankPower(userShopData.shopRank) >= GetRankPower(item))) {
          return timedNotification(3, 'error', "Tu ne peux pas acheter un rang inférieur ou égal au tient.")
        }
        $('#processing').slideDown(750);
        if(categorie === "lootboxs") {
          $('#processing').slideUp(750);
          Lootbox(item)
          return
        }
        $.post('http://mgd_shop/buyItem', JSON.stringify({
          categorie: categorie,
          item: item,
          creatorCode: document.getElementById("creatorCode").textContent
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
            timedNotification(3, 'success', "L'achat a bien été effectué.")
          } else {
            timedNotification(4, 'error', cb)
          }
        });
      } else {
        timedNotification(3, 'error', "Ton solde ne te permet pas d'acheter cela.")
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
      buildCodesCreatorsList();
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
        timedNotification(3, 'error', "Ce code existe déjà.")
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
            buildCodesCreatorsList();
            timedNotification(3, 'success', "Le code a été créé !")
          } else {
            timedNotification(4, 'error', "Erreur pendant l'update server.")
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
          buildCodesCreatorsList()
          $('#adminSelectContainer').hide();
          timedNotification(3, 'success', "Le code a été supprimé !")
        } else {
          timedNotification(3, 'error', "Erreur pendant l'update server.")
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
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="shopID">SHOP ID</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="item">SHOP ITEM</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="date">DATE</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="creatorCode">CODE CREATEUR</option>';
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
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="shopID">SHOP ID</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="date">DATE</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="sender">ENVOYEUR</option>';
      document.getElementById("filterLogsCategorie").innerHTML += '<option value="receiver">DESTINATAIRE</option>';
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
          timedNotification(3, "info", "ATTENTION, le véhicule spawn sur place.")
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

  function Lootbox(boxName) {
    document.getElementById("lootboxModel").style.transform = "rotateX(350deg) rotateY(30deg) rotateZ(0deg)"; document.getElementById("lootboxModel").style.top = "40%";
    document.getElementById("lootboxModel").classList.remove('lb-open');
    document.getElementById("browse").style.opacity = "0"; $("#closeShop").hide();
    $("#lootbox").show();
    $('#lootbox').one("click", function() {
      var selectedReward = SelectReward(boxName);
      $.post('http://mgd_shop/buyItem', JSON.stringify({
        categorie: "lootboxs",
        item: boxName,
        creatorCode: document.getElementById("creatorCode").textContent,
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
                    timedNotification(3, "info", "Tu avais déjà ce rang ou mieux. Tu as donc reçu "+ CONFIG["shopItems"]["rangs"][selectedReward.reward].price +" coins à la place.")
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

  function updateHour() {
    let d = new Date();
    let h = d.getHours();
    let m = d.getMinutes();
    if (h<10) {h = "0" + d.getHours();}
    if (m<10) {m = "0" + d.getMinutes();}
    $("#hour").text(h + "h" + m);
  }
  
  function insertData(data) {
    document.getElementById('title').innerText = (CONFIG.title + " " + CONFIG.serverName).toUpperCase();
    $("#purseAmount").text(data.shopTokens)
    $("#homeLogin").text(data.shopID)
    $("#homeID").text(data.serverID)
    $("#homeRank").text(GetRankLabel(data.shopRank))
    
    if (data.group === CONFIG.adminGroup) {
      $("#adminMenu").show();
    }
  }

  function buildNavbar() {
    $('#navbar').empty();
    document.getElementById('navbar').innerHTML = '<span class="navbar-item" id="home">ACCUEIL</span>';
    Object.keys(CONFIG['shopItems']).forEach(function(value){
      document.getElementById('navbar').innerHTML += '<span class="navbar-item" id='+ value +'>'+ value.toUpperCase() +'</span>';
    });
  }

  function buildNewsList() {
    $('#newsList').empty();
    Object.keys(CONFIG['shopItems']).forEach(function(categorie) {
      Object.keys(CONFIG['shopItems'][categorie]).forEach(function(item) {
        var item = CONFIG['shopItems'][categorie][item];
        if (item.isNew === true) {
          document.getElementById('newsList').innerHTML += '<div class="listItem newsItem"><span class="newItemDisplay"><span class="newStar"><i class="fa-solid fa-star fa-beat-fade"></i></span><span id="newItemCategorie">' + categorie.toUpperCase() + '</span><i class="fa-solid fa-arrow-right arrowIcon"></i><span id="newItemName">' + item.label.toUpperCase() + '</span></span><span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="newItemPrice">' + item.price + '</span></div>'
        }
      })
    });
  }

  function buildCategorieList(categorie) {
    $('#categorieList').empty();
    Object.keys(CONFIG['shopItems'][categorie]).forEach(function(itemIndex) {
      var itemData = CONFIG['shopItems'][categorie][itemIndex];
      document.getElementById('categorieList').innerHTML += '<div class="listItem categorieItem" id='+ itemIndex +'>'+ itemData.label.toUpperCase() +'<span class="itemPrice"><i class="fa-solid fa-coins"></i> <span id="itemPriceValue">'+ itemData.price +'</span></span></div>';
    });
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
        $('#selectContainer').fadeIn(250);
        $('#selectName').text(itemData.label.toUpperCase());
        $('#selectDescription').empty();
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

  function inputValidation(type, value) {
    $('#input-text').fadeOut(250);
    switch(type) {
      case 'idCoins':
        if (value.startsWith("MGD-") || !isNaN(value) && value > 0) {
          if (value !== document.getElementById("homeLogin").textContent && value !== document.getElementById("homeID").textContent) {
            document.getElementById("idToSendCoins").classList.remove("exampleDisplay");
            $('#idToSendCoins').text(value);
          } else {
            timedNotification(3, 'error', "Tu ne peux pas être le destinataire.")
          }
        } else {
          timedNotification(3, 'error', "Le destinaire n'est pas valide.")
        }
        break;
      case 'amountCoins':
        if (!isNaN(value) && value > 0) {
          document.getElementById("displayAmountToSendCoins").classList.remove("exampleDisplay");
          $('#displayAmountToSendCoins').text(value.replace('.', ''))
        } else {
          timedNotification(3, 'error', "Le montant est invalide.")
        }
        break;
      case 'creatorCode':
        if (value.length > 0) {
          value = value.toUpperCase()
          if (data.creatorsCodes[value] !== undefined || value === "-") {
            $('#creatorCode').text(value);
            if (value === "-") {
              timedNotification(3, 'success', "Tu n'utilises plus de code créateur.")
            } else {
              timedNotification(3, 'success', "Tu utilises désormais le code créateur : "+ value +".")
            }
          } else {
            timedNotification(3, 'error', "Ce code créateur n'existe pas.")
          }
        } else {
          $('#creatorCode').text("-");
          timedNotification(3, 'success', "Tu n'utilises plus de code créateur.")
        }
        break;
      case 'editcCode':
        if (value.length > 0) {
          value = value.toUpperCase()
          if (data.creatorsCodes[value] !== undefined) {
            timedNotification(3, 'error', "Ce code créateur existe déjà.")
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
                timedNotification(3, 'success', "Le code a été modifié !")
              } else {
                timedNotification(3, 'error', "Erreur pendant l'update server.")
              }
            });
          }
        }
        else {
          timedNotification(3, 'error', "Aucune valeur renseignée.")
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
              timedNotification(3, 'success', "L'identifier a été modifié !")
            } else {
              timedNotification(3, 'error', "Erreur pendant l'update server.")
            }
          });
        }
        else {
          timedNotification(3, 'error', "Aucune valeur renseignée.")
        }
        break;
      case 'cCCodeCode':
        value = value.toUpperCase();
        if (value.length > 0) {
          if (data.creatorsCodes[value] !== undefined) {
            timedNotification(3, 'error', "Ce code existe déjà.")
          } else {
            document.getElementById("cCCodeCode").classList.remove("exampleDisplay");
            $('#cCCodeCode').text(value);
          }
        } else {
          timedNotification(3, 'error', "Aucune valeur renseignée.")
        }
        break;
      case 'cCCodeIdentifier':
        if (value.length > 0) {
          document.getElementById("cCCodeIdentifier").classList.remove("exampleDisplay");
          $('#cCCodeIdentifier').text(value);
        } else {
          timedNotification(3, 'error', "Aucune valeur renseignée.")
        }
        break;
      case 'filterLogsValue':
        $('#filterLogsValue').text(value);
        break;
      default:
        alert("ERR type inputValidation")
    }
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

  function buildCodesCreatorsList() {
    $('#creatorCodeList').empty();
    Object.keys(data.creatorsCodes).forEach(function(index) {
      document.getElementById('creatorCodeList').innerHTML += '<div class="listItem categorieItem" id='+ index +'>'+ index +'<span>'+ data.creatorsCodes[index] +'</span></div>';
    });

    Object.keys(data.creatorsCodes).forEach(function(index) {
      $('#'+ index).click(function(){
        if (document.getElementsByClassName('selectedItem')[0] !== undefined) { document.getElementsByClassName('selectedItem')[0].classList.remove("selectedItem") }
        document.getElementById(index).classList.add("selectedItem");
        $('#adminSelectContainer').hide();
        $('#adminSelectContainer').fadeIn(250);
        $('#adminSelectName').text(index.toUpperCase());
        $('#acCode').text(index.toUpperCase());
        $('#acIdentifier').text(data.creatorsCodes[index]);
        $.post('http://mgd_shop/creatorCodeMoney', JSON.stringify({
            refCode: index.toUpperCase()
          }), function(money) {
            $('#acMoney').text(money);
          })
      });
    });
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
  })};

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
  };

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
});
})};