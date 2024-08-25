({
    doInit : function(component, event, helper) {

        helper.validate(component, event);

        //helper.getAccountFromRecord(component, event);
        if (!$A.util.isEmpty(component.get("v.accountId"))) {
            console.log("accountId", component.get("v.accountId"));
          //  component.find("recordDataAccount").reloadRecord(true);
            //component.set("v.accountNotVerified", true);
        } else {
            helper.getAccountId(component);
        }

        // get all stores: get current user to get store id and get all stores in the country
        if ($A.util.isEmpty(component.get("v.store"))) {
            helper.getUser(component);
        } else {
            component.set("v.storeCode", component.get("v.store").RetailStoreId__c);
        }
        
        if ($A.util.isEmpty(component.get("v.storeCode"))) {
            helper.getStoreList(component);
        }
        //helper.getAllUsers(component);
    },

    /*goBack : function(component, event, helper) {        
        // Fire Component (Bubbling) event to ask the OfferLetterSPA LC (Parent) to go back to previous child LC:        
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({"componentAction" : 'AccountSearch_Back'});
        cmpEvent.fire();

        helper.fireOpportunitySPAEvent(component);
    },
    
    goNext : function(component, event, helper) {

        // validate all components called "field"
        //var allValid = component.find("caCode").reduce(function (validSoFar, inputCmp) {
       //     inputCmp.showHelpMessageIfInvalid();
        //    return validSoFar && inputCmp.get('v.validity').valid;
        //}, true);
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
    },*/

    handleClientSelected : function(component, event, helper) {
        var params = event.getParams();
        component.set("v.account", params.account);
        component.set("v.accountId", params.account.Id);
        //var clientcmp = component.find('clientcmp');
        //$A.util.removeClass(clientcmp,'hideComponent');

        //helper.getAccount(component, event);
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
    },

    onRadioClientChanged : function(component, event, helper) {
        var newValue = event.getParam("value");
        //console.log("clientRadio", clientRadio);
        //var oldValue = event.getParam("oldValue");
        //if (newValue !== oldValue) {
        if (newValue === 'false') {
            var clientSearchLayout = component.find("clientSearchLayout");
            $A.util.removeClass(clientSearchLayout,'slds-hide');
            component.set("v.accountNotVerified", true);
            
            //$A.util.toggleClass(clientSearchLayout, 'slds-hide')
            //$A.util.removeClass(clientSearchLayout,'disabledClient');
            var contactabilityValidationDiv = component.find("contactabilityValidationDiv");
            $A.util.addClass(contactabilityValidationDiv, 'slds-hide');
        } else {
            component.set("v.accountRmsId", component.get("v.accountFromRecord").DREAMID__c);
            
            if (component.get("v.showContactabilityValidation") == true) {
                var contactabilityValidationDiv2 = component.find("contactabilityValidationDiv");
                $A.util.removeClass(contactabilityValidationDiv2, 'slds-hide');
            } else {
                console.log("navigate onRadioClientChanged", navigate);
                // auto-next screen
                var navigate = component.get('v.navigateFlow');
                if (!$A.util.isUndefined(navigate)) {
                    navigate("NEXT");
                }
            }            
        }
    },

	handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log("eventParams.changeType", eventParams.changeType);
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            // record is changed, so refresh the component (or other component logic)
       //     helper.handleOK(component);
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
            console.log("handleRecordUpdated > LOADED");
            
            /*if (!$A.util.isEmpty(component.get("v.accountFromRecord")) && $A.util.isEmpty(component.get("v.accountId"))) {
                console.log("LOADED AND READY TO CREATE ACCOUNT");
                component.find("recordDataAccount").saveRecord($A.getCallback(function(saveResult) {
                    // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        // handle component related logic in event handler
                        console.log("success recordID + TODO: Next button", saveResult.recordId);
                        component.set("v.accountId", saveResult.recordId);
                    } else if (saveResult.state === "INCOMPLETE") {
                        console.log("User is offline, device doesn't support drafts.");
                    } else if (saveResult.state === "ERROR") {
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        //helper.handleError(component, saveResult.error[0].message);
                    } else {
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    }
                }));
            }*/
            /*var p = helper.findCallDetail2(component);
            p.then(function (response) {
                console.log("createPhone success", response);
                helper.createPhone(component);
            }).catch(function (err) {
                console.log("err", err);
            })*/
            //console.log(JSON.stringify(component.find("recordDataAccount").targetFields));
        } else if(eventParams.changeType === "REMOVED") {
            console.log("REMOVED>eventParams", eventParams);
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log("ERROR>eventParams", JSON.stringify(eventParams));
            // there’s an error while loading, saving or deleting the record
        }
    },

    editAccount : function(component, event, helper) {
        // edit the existing account
		helper.editAccount(component, event, component.get("v.accountId"));
	},

	handleFlowFooterEvent : function (component, event, helper) {
        // if the account is selection from RMS search (no account id) OR Salesforce Search (account id)
        // The New button is managed by the Highlight event

        if (component.get("v.recordId") === event.getParam("recordId")) {
            helper.manageAccount(component, event, helper);
        }
    },

    // Save account from modal 
    saveFromModal : function (component, event, helper) {        
        helper.manageAccount(component, event, helper);       
    },

    filterChange: function(component, event, helper) {
        // used to have predefined values in the highlight panel if the user selects the "New" button
        var accountSearch = {
            "sobjectType": "Account",
            "LastName": event.getParam("lastname"),
            "FirstName": event.getParam("firstname"),
            "PersonEmail": event.getParam("email"),
            "PersonMobilePhone": event.getParam("phone"),
            "SPO_Country_code__pc": event.getParam("country"),
            "PrimaryZipCode__pc": event.getParam("postalcode")
        };
        component.set("v.accountFromSearch", accountSearch);

        // Display New button after a search (force the user to search before creating)
        var newProspectButton = component.find("newProspectButton");
        $A.util.removeClass(newProspectButton, 'slds-hide');
	},

	onNewProspect : function(component, event, helper) {
        // edit the new prospect
        helper.editAccount(component, event, null);
	},

	handleHighlightEvent : function(component, event, helper) {
        console.log("handleHighlightEvent");
        var accountId = event.getParam("recordId");
        var currentRecordId = event.getParam("currentRecordId");
        console.log("AccountId/currentRecordId", accountId, currentRecordId);
        console.log("recordId",component.get("v.recordId"));

        // just manage the Highlight event from this record
        if (currentRecordId === component.get("v.recordId")) {
            
            // if New button then Save, manage the account
            var actualAccountId = component.get("v.accountId");
            console.log("AccountId/actualAccountId", accountId, actualAccountId);
            if (!$A.util.isEmpty(accountId) && accountId !== actualAccountId) {
                // set the new account id for the record
                component.set("v.accountId", accountId);
                // manage the new account
                helper.manageAccount(component, event, helper, accountId);
            }

            /*// is new prospect
            //if ($A.util.isEmpty(component.get("v.accountId"))) {
            component.set("v.accountId", accountId);

            // after creation of the New prospect, change to the next screen
            console.log("newProspectCreated", component.get("v.newProspectCreated"));
            if (component.get("v.newProspectCreated")) {
                console.log("auto next");
                var navigate = component.get("v.navigateFlow");
                if (!$A.util.isEmpty(navigate)) {
                    navigate("NEXT");
                }
            }*/
            //component.set("v.accountId", accountId);
        }
	},
})