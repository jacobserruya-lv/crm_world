({
    manageAccount : function (component, event, helper) {
		console.log("handleFlowFooterEvent", JSON.stringify(event));
        console.log("recordId", event.getParam("recordId"));
        console.log("component recordId", component.get("v.recordId"));
        //if (component.get("v.recordId") === event.getParam("recordId")) {

        var acc = component.get("v.account");
        console.log("acc", JSON.stringify(acc));
        //if (!$A.util.isEmpty(acc) && $A.util.isEmpty(acc.Id)) {
        var promise = this.insertAccount(component);
        promise.then($A.getCallback(function(result) {
            console.log("promise 1", result);                    
            return helper.linkRecordToNewAccount(component);
        }))
        /*.then($A.getCallback(function(result) {
            console.log("Promise 2", result);
            // inform that a new Account is created
            //component.set("v.newProspectCreated", true);
            
            // Refresh the highlight panel to get the new account
            return helper.fireHighlightEvent(component);
        }))
        .then($A.getCallback(function() {
            console.log("Promise 3");
            // on account creation, go to the next screen
            var navigate = component.get('v.navigateFlow');
            console.log("navigate promise", navigate);
            if (!$A.util.isEmpty(navigate)) {
                var footerAction = event.getParam("action");
                console.log("handleFlowFooterEvent>action", footerAction);
                
                if (!$A.util.isEmpty(footerAction)) {
                    navigate(footerAction);
                } else {
                    navigate("NEXT");
                }
            }
        }))*/
        .then($A.getCallback(function(result) {
            console.log("Promise 2", result);
            // inform that a new Account is created
            //component.set("v.newProspectCreated", true);
            
            // Refresh the highlight panel to get the new account
            helper.fireHighlightEvent(component);

            console.log("Promise 3");
            // on account creation, go to the next screen
            var navigate = component.get('v.navigateFlow');
            console.log("navigate promise", navigate);
            if (!$A.util.isEmpty(navigate)) {
                var footerAction = event.getParam("action");
                console.log("handleFlowFooterEvent>action", footerAction);
                
                if (!$A.util.isEmpty(footerAction)) {
                    navigate(footerAction);
                } else {
                    navigate("NEXT");
                }
            } else if (component.get("v.isModal") == true) {
                helper.handleOK(component, null);
            }
        }))
        .catch($A.getCallback(function(err) {
            console.log('catch: ' + err);
            if (component.get("v.isModal") == true) {
                helper.handleError(component, err, null);
            }
        }))
       // }
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
                // TODO ask EAI team why WW_RMSId__c or Dream id is empty in production? Mapping error?
                component.set("v.accountRmsId", (!$A.util.isEmpty(params.account.RMSId__pc) ? params.account.RMSId__pc : result.DREAMID__c));
                component.set("v.accountId", result.Id);
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
                        } /*else {
                            toastEvent = $A.get("e.c:SO_CustomToastEvent");
                            toastEvent.setParams(toastParams);
                            toastEvent.fire();
                        }*/
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
                
                //var opp = component.get("v.opp");
                if (storeResponse != null){
                   // opp.SPO_Store__c = storeResponse.Id;
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
       // action.setStorable();
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
        //action.setStorable();
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
                cmp.set("v.storeCode", storeResponse.DefaultStore__c);
                // TODO : no need to display the Store picklist if the user store is known 
                // if ($A.util.isEmpty(storeResponse.DefaultStore__c)) {
                // this.getStoreList(cmp);
                // }

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

    getAccountId : function(component) {
        console.log("getAccountId recordId", component.get("v.recordId"));
        var accountId = component.get("v.accountId");

        if ($A.util.isEmpty(accountId)) {
            var action = component.get("c.getAccountId");
            action.setParams({
                "recordId": component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var accountIdResult = response.getReturnValue();
                    console.log("accountIdResult", accountIdResult);
                    component.set("v.accountId", accountIdResult);
                    
                    // load client search part if empty
                    if ($A.util.isEmpty(accountIdResult)) {
                        component.set("v.accountNotVerified", true);
                    }
                    component.find("recordDataAccount").reloadRecord(true);
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
            $A.enqueueAction(action);
        }
    },

    /*getAccountFromRecord : function(component, event) {
        var action = component.get("c.getAccountFromRecord");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var account = response.getReturnValue();
                console.log("accountFromRecord", account);
                component.set("v.accountFromRecord", account);
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
        $A.enqueueAction(action);
    },*/

    // Insert the account if new or skip it
    // TO CHECK: If the Highlight panel is displayed in the page with the flow, maybe 2 records will be created with the New button
    insertAccount : function(component) {
        return new Promise(function (resolve, reject) {
            var accountId = component.get("v.accountId");
            var acc = component.get("v.account");
            
            console.log("insertAccount accountId", accountId);
            console.log("insertAccount acc", JSON.stringify(acc));

            // if the account id is empty and one account is selected
            if ($A.util.isEmpty(accountId) && !$A.util.isEmpty(acc)) {
                var action = component.get("c.insertAccount");
                action.setParams({
                    "account": component.get("v.account")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("success NEXT");
                        var accountCreated = response.getReturnValue();
                        console.log("accountCreated", accountCreated);
                        if (!$A.util.isEmpty(accountCreated)) {
                            // Keep data for output parameters
                            component.set("v.accountId", accountCreated.Id);
                            component.set("v.account", accountCreated);
                            
                            // inform that a new Account is created
                            component.set("v.newProspectCreated", true);

                            resolve(accountCreated);
                        } else {
                            reject();
                        }
                    } else {
                        console.log("Unknown error", state);
                        reject();
                    }
                });
                $A.enqueueAction(action);
            } else {
                console.log("insert save skipped");
                // continue the transaction for this Promise
                resolve();
            }
        });
    },

    editAccount : function(component, event, accountId) {
		if (component.get("v.editModalOpened")) return;
		component.set("v.editModalOpened", true);
		var modalBody, modalFooter;
		$A.createComponents([
			["c:ICX_Account_Highlight_Edit2",{
                recordId : accountId,
                taskRecordId : component.get("v.recordId"),
                simpleAccount : (!$A.util.isEmpty(component.get("v.accountFromSearch")) ? component.get("v.accountFromSearch") : null)
            }],
			["c:ICX_Account_Highlight_Edit_Buttons",{}]
			],
			function(components, status){
				if(status==="SUCCESS"){
					modalBody = components[0];
					modalFooter = components[1];
					modalFooter.set("v.parent", modalBody);
					component.find("overlayLib").showCustomModal({
						header: "Edit Account",
						body : modalBody,
						footer: modalFooter,
						cssClass: "slds-modal_large",
						showCloseButton: true,
						closeCallback: function() {
                            component.set("v.editModalOpened", false);
					   }
					})
				}
			}
		)
	},

    fireHighlightEvent: function(component) {
        console.log("fireHighlightEvent");
        
        var accId = component.get("v.accountId");
        if (!$A.util.isEmpty(accId)) {
            var myEvent = $A.get("e.c:ICX_Account_Highlight_Event"); // component.getEvent("cmpEvent"); 
            myEvent.setParams({
                "recordId": accId,
                "currentRecordId": component.get("v.recordId")
            });
            myEvent.fire();
        }
    },

    linkRecordToNewAccount : function (component){//, helper) {
        var newAccountId = component.get("v.accountId");
        var callRecordId = component.get("v.recordId");
        
        console.log("linkRecordToNewAccount > newAccountId", newAccountId);
        console.log("linkRecordToNewAccount > callRecordId", callRecordId);

        if (!$A.util.isEmpty(newAccountId)) {
            // update object with account
            var caseService = component.find("caseService");
            console.log("caseService", caseService);
            caseService.updateObject(
                newAccountId,
                callRecordId,
                $A.getCallback(function(error, data) {
                    console.log("callback error", error);                   
                    if(error){                      
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "warning",
                            "title": "Warning!",
                            "message": "The Client is already added to the Alias"
                        });
                        toastEvent.fire();
                    }
                    console.log("callback data", data);
                })
            );
        }
        /*return new Promise(function (resolve, reject) {
            if (!$A.util.isEmpty(newAccountId)) {
                // update object with account
                var caseService = component.find("caseService");
                console.log("caseService", caseService);
                caseService.updateObject(
                    newAccountId,
                    callRecordId,
                    $A.getCallback(function(error, data) {
                        if (!$A.util.isEmpty(error)) {
                            reject();
                        } else {
                            resolve();
                        }
                        console.log("callback error", error);
                        console.log("callback data", data);
                    })
                );
            } else {
                resolve();
            }
        });*/
    },

	validate : function(component, event) {
        // Set the validate attribute to a function that includes validation logic
        component.set('v.validate', function() {
            if (component.get("v.required")) {
                if (!$A.util.isEmpty(component.get("v.accountId"))) {
                    // If the component is valid...
                    return { isValid: true };
                }
                // If the component is invalid...
                var error = $A.get("$Label.c.ICX_Flow_Account_Error_Required");
                return { isValid: false, errorMessage: error};
            }
        })
    },

	// Display notification in modal mode (Chang button in the Highlight panel)
    handleOK: function(component, notifLib) {
        var resultsToast = $A.get("e.force:showToast");
        
        resultsToast.setParams({
            "title": "Saved",
            "message": "The record was updated.",
            "type": "success"
        });
        resultsToast.fire();

        var overlay = component.find("overlayLib");
        console.log("handle Ok > notifLib", notifLib);
        //var notif = (!$A.util.isUndefined(notifLib) ? notifLib : component.find('notifLib'));
        var notif = (!$A.util.isUndefined(overlay) ? overlay : notifLib);
        console.log("handle Ok > notif", notif);

        notif.notifyClose();
        //component.find("overlayLib").notifyClose();
	},

	handleError : function(component, error, notifLib) {
        console.log("handle ko > notifLib", notifLib);
        var notifLib2 = component.find('notifLib');
        var notif = (!$A.util.isUndefined(notifLib2) ? notifLib2 : notifLib);
        console.log("handle ko > notif", notif);
		notif.showNotice({
        //component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Error",
            "message": error
        });
	},
})