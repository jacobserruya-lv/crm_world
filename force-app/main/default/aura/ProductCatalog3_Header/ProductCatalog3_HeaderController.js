({

  getCurrentUser: function (cmp, event, helper) {
    var action = cmp.get("c.getUser");

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        helper.setupUserData(cmp, event, helper, response);
      } else if (state === "ERROR") {
        helper.handleError(response);
      }
    });

    $A.enqueueAction(action);
  },

  setupUserData: function (cmp, event, helper, response) {
    var currentUser = response.getReturnValue();
    var managementZoneLevelMap = cmp.get("v.ManagementZoneLevelMap");
    //var userStoreCode = currentUser['DefaultStore__c'];
    var userStoreCode = currentUser["My_Stores_Lists__c"];
    var selectedStores = [];
    cmp.set("v.Warehouse_List", managementZoneLevelMap["Warehouse"]);
    cmp.set("v.MANAGEMENT_ZONE_LEVEL__c_List", Object.keys(managementZoneLevelMap["zone"]).sort());
    cmp.set("v.selectedZoneLevel", managementZoneLevelMap["userStores"]["mgmtZones"] || "");

    var storesWarehouses = managementZoneLevelMap["Warehouse"];
    var warehousesName = Object.keys(managementZoneLevelMap["Warehouse"]);
    var selectedWarehouses = [];

    var selectedZones = managementZoneLevelMap["userStores"]["mgmtZones"];
    var countriesList = [];
    if (selectedZones) {
      for (var i = 0; i < selectedZones.length; i++) {
        var zoneCountries = managementZoneLevelMap["zone"][selectedZones[i]];
        countriesList = countriesList.concat(zoneCountries);
      }
    }

    cmp.set("v.MGMT_ZONE_SUB_LEVEL3__c_List", countriesList.sort() || []);
    cmp.set("v.selectedZoneLevel3", managementZoneLevelMap["userStores"]["countries"] || "");
    cmp.set("v.defaultStore", managementZoneLevelMap["userStores"]["stores"] || "");

    var digitalStores = managementZoneLevelMap["DigitalStores"]["DigitalStores"];
    cmp.set("v.digitalStores", digitalStores);

    var currentStores = [];
    var stores;
    var countries = managementZoneLevelMap["userStores"]["countries"];
    for (var j = 0; j < countries.length; j++) {
      stores = managementZoneLevelMap["countries"][countries[j]];
      currentStores = currentStores.concat(stores);
    }

    cmp.set("v.physicalStores", currentStores);
    var userStores = JSON.parse(Object.keys(managementZoneLevelMap.userStores)[0]);
    cmp.set("v.selectedDigitalStore", userStores.lastDigitalStore);
    cmp.set("v.userStores", userStores);

    var userStoresCode = [];
    if (userStoreCode) {
      userStoresCode = userStoreCode.split(";");
    }
    for (var k = 0; k < userStoresCode.length; k++) {
      for (var y = 0; y < warehousesName.length; y++) {
        if (
          storesWarehouses[warehousesName[y]].includes(userStoresCode[k]) &&
          storesWarehouses[warehousesName[y]] != null &&
          !selectedWarehouses.includes(warehousesName[y])
        ) {
          selectedWarehouses.push(warehousesName[y]);
          break;
        }
      }
    }
    cmp.set("v.selectedPhysicalStores", userStoresCode);
    cmp.set("v.mySelectedList", userStoresCode);
    cmp.set("v.selectedWarehouses", selectedWarehouses);

  },

  toggleStoreFilterExpanded: function (cmp, event, helper) {
    helper.toggleStoreFilterExpanded(cmp, event, helper);
  },

  handleRecordChange: function (cmp, event, helper) {
    var product = cmp.get("v.product");
    if (product.sku != undefined) {
      cmp.set("v.isStoreFilterExpanded", false);
      cmp.set("v.isStoreFilterExpanding", false);
    }
  },

  goToProductLibrary: function (cmp, event, helper) {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: $A.get("$Label.c.Product_Library_Link")
    });
    urlEvent.fire();
  },

  handleMessage: function (component, event, helper) {
    const messageReceived = event.getParams();

    const { searchTerm,
      resultsList,
      totalCount,
      isModalOpen } = messageReceived.payload;

    const isModalOpened = component.get('v.isModalOpen');

    if (isModalOpen !== isModalOpened) {
      component.set("v.isModalOpen", isModalOpen);
      const myElement = document.querySelector("#searchBar");
      if (isModalOpen) myElement.className = 'pc3-header__container--open';
      else myElement.className = 'pc3-header__container';
    }

    component.set("v.searchTerm", searchTerm);
    const listSkusResults = resultsList.map(result => result.resultFields.skuId);
    console.log('listSkusResults', listSkusResults);
    helper.sendData(component, listSkusResults);


  },

  handelPersonalizedProdNavigation: function (com, event, helper) {

    try {
      var eventFire = com.getEvent("triggerCustomProducts");
      eventFire.fire();
    }
    catch (error) {
      console.error('The event didnt fire', error);
    }
    com.set('v.isDisplaySearchBar', !com.get("v.isDisplaySearchBar"));
  },


});