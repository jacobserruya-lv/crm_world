({
    fireOpportunitySPAEvent : function(component) {
        var store = component.get("v.store");
        console.log("store", store);
        var opp = component.get("v.opp");
        //Pass the values grabbed from this LC Form to the next child LC via Lightning Events:
        var appEvent = $A.get("e.c:SO_OpportunitySPAEvent");
        appEvent.setParams({
            "opp" : opp,
            "account" : (opp.SPO_DisplayOrder__c ? null : component.get("v.account")),
            "store" : store,
            "channel": "Account"
        });
        appEvent.fire();
        console.log("fireOpportunitySPAEvent Client > appEvent", appEvent);
    },

    /*closeModal: function(cmp) {
        // waiting standard Modal component / maybe create a custom component for modal: https://webkul.com/blog/how-to-create-responsive-modal-box-in-lightning-component-salesforce/
        var cmpTarget = cmp.find('Modalbox');
        var cmpBack = cmp.find('MB-Back');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');        
    },
    openModal: function(cmp) {
        // waiting standard Modal component / maybe create a custom component for modal: https://webkul.com/blog/how-to-create-responsive-modal-box-in-lightning-component-salesforce/
        var cmpTarget = cmp.find('Modalbox');
        var cmpBack = cmp.find('MB-Back');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },*/

    isValid : function(component, auraId) {        
        var cmpAuraId = component.find(auraId);
        var validity = cmpAuraId.get("v.validity").valid;
        if (!validity) {
            cmpAuraId.showHelpMessageIfInvalid();
        }
        return validity;
    },

	getAccount : function(component, event) {
        var params = event.getParams();
        //component.set("v.account", params.account);

        console.log("component.get(v.store)", component.get("v.store"));
        var action = component.get("c.getAccountFromRMS");
        action.setParams({
            "storeCode"         :component.get("v.store").RetailStoreId__c,
            "rmsId"             :params.account.RMSId__pc,
            "wwRmsClientCode"   :params.account.WW_RMSId__c
            //"sfdcClient":	params.account//component.get("v.account")
    	});

        action.setCallback(this, function(a) {
            var state = a.getState();

            if (state === "SUCCESS") {
	            var result = a.getReturnValue();
		        result.sobjectType = "Account"; // mandatory otherwise not supported sObjectType when saving record
                
                component.set("v.account", result);
                // this.openModal(component);

            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('error', errors[0].message);
                        // Display toast message to indicate status
                        var toastParams = {
                                "type": "error",
                                "mode": "sticky",
                                "title": "Error!",
                                "message": errors[0].message
                            };
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent) {
                            toastEvent.setParams(toastParams);
                            
                            toastEvent.fire();
                        } else {
                            toastEvent = $A.get("e.c:SO_CustomToastEvent");
                            toastEvent.setParams(toastParams);
                            toastEvent.fire();
                        }
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            var spinner = component.find("spinner"); // replace by events (aura:waiting, aura:doneWaiting)
            $A.util.toggleClass(spinner, "slds-hide");
    	});
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");

        // local store if a new request with same parameters are executed again
        //action.setStorable();// no storable because after saving, records with old values will be kept in cache
    	$A.enqueueAction(action);
	},

    findStore : function(component) {
        console.log("findStore", component.get("v.storeCode"));
        var action = component.get("c.getStore");
        action.setParams({
            "storeCode": component.get("v.storeCode")//.SPO_Store__c
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("storeResponse", storeResponse);
                component.set("v.store", storeResponse);
                
                var opp = component.get("v.opp");
                if (storeResponse != null){
                    opp.SPO_Store__c = storeResponse.Id;
                } else {
                    console.log("storeResponse was null");
                }
            } else if (state === "INCOMPLETE") {
                // do something
                console.log("incomplete");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        // optionally set storable, abortable, background flag here
        action.setStorable();
        $A.enqueueAction(action);
    },

    getStoreList : function(cmp) {
        // TODO get stores in the country of the user
        
        var action = cmp.get("c.getStoreJson");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.storeList", JSON.parse(response.getReturnValue()));

                /*var resultList = JSON.parse(response.getReturnValue());
                var storeCode = cmp.get("v.storeCode");
                var opts = [];
                for (var index in resultList) {
                    var val = resultList[index].value;
                    if (val === storeCode) {
                        opts.push({ value: resultList[index].value, label: resultList[index].label, selected: true });
                    } else {
                        opts.push({ value: resultList[index].value, label: resultList[index].label });
                    }
                }
                cmp.find("storeSelect").set("v.options", opts);*/

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
    	});
        // optionally set storable, abortable, background flag here
        action.setStorable();
        $A.enqueueAction(action);        
    },

    getUser : function(cmp) {
        console.log("getUser");
        // TODO get current user store
        // TODO get stores in the country of the user
        var action = cmp.get("c.getUser");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                cmp.set("v.user",  storeResponse);
                
                /*// set init value for store opportunity
                var opp = cmp.get("v.opp");
                opp.SPO_Store__c = storeResponse.DefaultStore__c;
                console.log('opp.SPO_Store__c', opp.SPO_Store__c);
                
                // need to set opp to display store value
                cmp.set("v.opp", opp);*/
                
                cmp.set("v.storeCode", storeResponse.DefaultStore__c);
                //console.log("getUser > findstore", storeResponse.DefaultStore__c);
                //this.findStore(cmp);

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        // optionally set storable, abortable, background flag here
        //action.storable();
        $A.enqueueAction(action);        
    },

    /*saveAccount : function(component) {
        console.log("save account component.get(v.account)", component.get("v.account"));
        
        var action = component.get("c.saveAccountInRMS");
        action.setParams({
            "sfdcClient":	component.get("v.account"),
            "storeCode":	component.get("v.store").RetailStoreId__c
            //"rmsId": 		params.account.RMSId__pc
            //"sfdcClient":	params.account//component.get("v.account")
    	});

        action.setCallback(this, function(a) {
            var state = a.getState();

            if (state === "SUCCESS") {
	            var result = a.getReturnValue();
                //component.set("v.account", result);
                this.closeModal(component);
                console.log("component.get(account)", component.get("v.account"));

                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        //"type": "error",
                        //"mode": "sticky",
                        "title": "Success",
                        "message": "Client updated with success"
                    });
                    toastEvent.fire();
                }
            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('error', errors[0].message);
                        // Display toast message to indicate status
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent) {
                            toastEvent.setParams({
                                "type": "error",
                                "mode": "sticky",
                                "title": "Error!",
                                "message": errors[0].message
                            });
                            
                            toastEvent.fire();
                        } else {
                            alert(errors[0].message);
                        }
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            var spinner = component.find("spinner"); // replace by events (aura:waiting, aura:doneWaiting)
            $A.util.toggleClass(spinner, "slds-hide");
    	});
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");

        // local store if a new request with same parameters are executed again
        //action.setStorable();
    	$A.enqueueAction(action);
	}*/
    /*getAllUsers : function(component){
        var action = component.get("c.getAllUsersDB");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseReturn = response.getReturnValue();
                component.set("v.users", responseReturn);
                console.log("responseReturn for getAllUsersDB", JSON.stringify(responseReturn));
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        
        $A.enqueueAction(action);   
    }*/
})