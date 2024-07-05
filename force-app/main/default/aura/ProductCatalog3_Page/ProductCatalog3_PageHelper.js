({
  initData: function (cmp, event, helper) {
    var action = cmp.get("c.getInitData");

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var initData = response.getReturnValue();
        // cmp.set("v.digitalStoresForAtgPrice", initData["digitalStoreCodesAtgPrice"]);
        cmp.set("v.myFavorites", initData["MyFavorites"]);
      } else if (state === "ERROR") {
        helper.handleError(response);
      }
    });

    $A.enqueueAction(action);
  },

  handleError: function (reponse) {
    var errors = reponse.getError();
    if (errors && errors[0] && errors[0].message) {
      console.error("Error Message: " + errors[0].message);
    }
  },

  getStoreHierarchy: function (cmp, helper, callback) {
    /*var action = cmp.get('c.getUserLocationPickListValues');
        action.setParams({
        'fieldNames': ['MANAGEMENT_ZONE_LEVEL__c', 'MGMT_ZONE_SUB_LEVEL1__c', 'MGMT_ZONE_SUB_LEVEL2__c', 'MGMT_ZONE_SUB_LEVEL3__c', 'DefaultStore__c']
        });*/

    var action = cmp.get("c.getUserStoreHierarchy");

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log('physical in page RESPONSE : ', response.getReturnValue())
        cmp.set("v.ManagementZoneLevelMap", response.getReturnValue());
        var defaultUserCountry = cmp.get("v.ManagementZoneLevelMap").userStores.countries;
        cmp.set("v.selectedCountries", defaultUserCountry);
        cmp.set("v.selectedPhysicalStores", cmp.get("v.ManagementZoneLevelMap").userStores.stores[0]);
        console.log('physical in page', cmp.get("v.selectedPhysicalStores"));
        callback();
      } else if (state === "ERROR") {
        helper.handleError(response);
      }
    });
    $A.enqueueAction(action);
  },

  getPersonalizeButtonPermission: function (component, event, helper) {
    var action = component.get("c.hasCustomPermission");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.isPersonalizeButtonPermission", response.getReturnValue());
      } else if (state === "ERROR") {
        helper.handleError(response);
      }
    });
    $A.enqueueAction(action);
  },

  getCurrentUser: function (cmp, event, helper) {
    var action = cmp.get("c.getUser");

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        cmp.set("v.currentUserData", response.getReturnValue());
      } else if (state === "ERROR") {
        helper.handleError(response);
      }
    });

    $A.enqueueAction(action);
  }
});