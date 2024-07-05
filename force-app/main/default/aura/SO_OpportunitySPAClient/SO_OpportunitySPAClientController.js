({
    doInit : function(component, event, helper) {
        // TODO get all stores: get current user to get store id and get all stores in the country
        if ($A.util.isEmpty(component.get("v.store"))) {
            helper.getUser(component);
        } else {
            component.set("v.storeCode", component.get("v.store").RetailStoreId__c);
        }
        helper.getStoreList(component);
        //helper.getAllUsers(component);
    },

    goBack : function(component, event, helper) {        
        // Fire Component (Bubbling) event to ask the OfferLetterSPA LC (Parent) to go back to previous child LC:        
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({"componentAction" : 'AccountSearch_Back'});
        cmpEvent.fire();

        helper.fireOpportunitySPAEvent(component);
    },
    
    goNext : function(component, event, helper) {

        // validate all components called "field"
        /*var allValid = component.find("caCode").reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);*/
        //var CaCodevalidity = helper.isValid(component, "caCode");
        
        // validate fields are filled
        var storeValidity = helper.isValid(component, "storeSelect");

        if (($A.util.isEmpty(component.get("v.account")) || $A.util.isEmpty(component.get("v.account.LastName")) ) && component.get("v.showClient")) {
            // Display toast message to indicate status
            var toastParams = {
                    "type": "error",
                    //"mode": "sticky",
                    "title": "Client required!",
                    "message": "Select a client or display order"
                };
            var toastEvent = $A.get("e.force:showToast");
            // console.log('$A.get("e.force:showToast")', toastEvent);
            if (toastEvent) {
                toastEvent.setParams(toastParams);
                
                toastEvent.fire();
            } else {
                var customToast = $A.get("e.c:SO_CustomToastEvent");
                customToast.setParams(toastParams);
                customToast.fire();
            }

//        } else if ($A.util.isEmpty(component.get("v.opp.FollowUpByClientAdvisorEmail__c"))) {
        } else if ($A.util.isEmpty(component.get("v.opp.OwnerId"))) {
            // Display toast message to indicate status
            var toastParams = {
                    "type": "error",
                    //"mode": "sticky",
                    "title": "Client Advisor Name required!",
                    "message": "Search Client Advisor Name and Select One"
                };
            var toastEvent = $A.get("e.force:showToast");
            // console.log('$A.get("e.force:showToast")', toastEvent);
            if (toastEvent) {
                toastEvent.setParams(toastParams);
                
                toastEvent.fire();
            } else {
                var customToast = $A.get("e.c:SO_CustomToastEvent");
                customToast.setParams(toastParams);
                customToast.fire();
            }

        } else {

//            if (CaCodevalidity && storeValidity) {
            if (storeValidity) {
                // Fire Component (Bubbling) event to ask the SO_OpportunitySPA LC (Parent) to go to the next child LC:
                var cmpEvent = component.getEvent("bubblingEvent");
                cmpEvent.setParams({"componentAction" : 'AccountSearch_Next' });
                cmpEvent.fire();
                
                helper.fireOpportunitySPAEvent(component);
            }
        }
    },

    handleApplicationEvent : function(component, event, helper) {
        var params = event.getParams();
        component.set("v.opp", params.opp);

        //if (params.channel === "Personalization") {
        //    component.set("v.store", params.store);
        //}
    },

    handleClientSelected : function(component, event, helper) {
        // var params = event.getParams();
        //component.set("v.account", params.account);
        //var clientcmp = component.find('clientcmp');
        //$A.util.removeClass(clientcmp,'hideComponent');

        helper.getAccount(component, event);
    },

    changeUser : function(component, event, helper) {
        var opp = component.get("v.opp");
        
        var selectedUser = component.get("v.selecteduser");
        //        if ($A.util.isUndefined(selectedUser) == false || $A.util.isEmpty(selectedUser) == false) {
        if ($A.util.isEmpty(selectedUser) == false) {
            opp.OwnerId = selectedUser.Id;
        } else {
            opp.OwnerId = null;            
        }
    },

    displayOrder : function(component, event, helper) {
        var opp = component.get("v.opp");
        //var isDisplayOrder = opp.SPO_DisplayOrder__c;
        
		// change value
        component.set("v.showClient", opp.SPO_DisplayOrder__c);
        opp.SPO_DisplayOrder__c = !opp.SPO_DisplayOrder__c;
    },

    modalCancel : function (cmp, event, helper) {
        helper.closeModal(cmp);
    },
    
    modalSave : function (cmp, event, helper) {
        //helper.saveAccount(cmp);
        helper.closeModal(cmp);
    },
    
    openModal : function (cmp, event, helper) {
        cmp.set("v.account", {'sobjectType':'Account'});
        helper.openModal(cmp);
    },
    changeStore: function(component, event, helper) {
        helper.findStore(component);     
    }

})