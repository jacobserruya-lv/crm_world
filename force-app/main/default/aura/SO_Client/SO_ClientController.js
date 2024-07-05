({
    doInit: function(component, event, helper) {
        helper.getSalutationList(component);
        //helper.getClientTypeList(component);
   //     helper.getNationalityList(component);
        helper.getCountryList(component);
        //helper.getPhoneCountryList(component);

        // need Summer '17
        /*component.find("accountRecordLoader").getNewRecord(
            "Account",
            null,
            null,
            false,
            $A.getCallback(function() {
                var rec = component.get("v.account");
                var error = component.get("v.newAccountError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.sobjectType);
                }
            })
        );*/
        
    },
    /*
    onSelectMobilePhoneCountryChange : function(component, event, helper) {
        var client = component.get("v.account");
        console.log("client.MobilePhoneCountryCode__pc", client.MobilePhoneCountryCode__pc);
        if ($A.util.isEmpty(client.MobilePhoneCountryCode__pc)) {
	        client.LocalMobilePhone__pc = "";
            component.set("v.account", client);
        }
    },*/
    
    handleSaveAccount: function(component, event, helper) {
        if(helper.validateAccountForm(component)) {
            // need Summer '17
            //component.set("v.account.AccountId", component.get("v.recordId"));
            /*component.find("accountRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    
                    // Success! Prepare a toast UI message
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Client Saved",
                        "message": "The new client was created."
                    });
                    
                    // Update the UI: close panel, show toast, refresh account page
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                    
                    // Reload the view so components not using force:recordData
                    // are updated
                    $A.get("e.force:refreshView").fire();
                }
                else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                }
                    else if (saveResult.state === "ERROR") {
                        console.log('Problem saving contact, error: ' +
                                    JSON.stringify(saveResult.error));
                    } else {
                        console.log('Unknown problem, state: ' + saveResult.state +
                                    ', error: ' + JSON.stringify(saveResult.error));
                    }
            });*/
        }
    },

    /*handleCancel: function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    },*/
    
    editAccount : function(component, event, helper){
        if(component.get("v.editModalOpened")) return;
        component.set("v.editModalOpened", true);
        var modalBody, modalFooter;

        console.log("SO client account", JSON.stringify(component.get("v.account")));
        $A.createComponents([
            ["c:ICX_Account_Highlight_Edit2",{
                recordId : (!$A.util.isEmpty(component.get("v.account")) ? component.get("v.account").Id : null)
                //taskRecordId : component.get("v.relatedRecordId")
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
})