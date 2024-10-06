({

    getAccount : function(cmp, event, helper) {
        
        // change recordId to get Account Id from Case
        var caseService = cmp.find("caseService");
        console.log('recordId', cmp.get("v.recordId"));
        caseService.findAccount(cmp.get("v.recordId"),cmp.get("v.accountApi"),$A.getCallback(function(error, data) {
            console.log('caseService data', data);
            cmp.set("v.recordId", data);
            cmp.set("v.account", data); // //

            console.log('recordId - getAccount', cmp.get("v.recordId"));
            console.log('account - getAccount', cmp.get("v.account"));
            console.log('currentRecordId - getAccount', cmp.get("v.currentRecordId"));

            helper.getContact(cmp, event);
            helper.getKeyInformation(cmp, event);
            helper.getMultiMatch(cmp, event);
        }));
	},

    getContact: function(cmp, event){
        console.log('recordId - getContact', cmp.get("v.recordId"));
        console.log('account - getContact', cmp.get("v.account"));
        console.log('currentRecordId - getContact', cmp.get("v.currentRecordId"));
        var action = cmp.get("c.getContact");
        action.setParams({ accountId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.account",response.getReturnValue());
                console.log(' aura get account response', response.getReturnValue());
                if( response.getReturnValue().Can_Be_Contacted_By_Phone)
                {
                    console.log(' aura get account response right here', response.getReturnValue().Can_Be_Contacted_By_Phone);
                    cmp.set("v.accessible",response.getReturnValue().Can_Be_Contacted_By_Phone)
                }
                console.log(' aura get account ',  cmp.get("v.account"));

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error")
                }            
            }

     });
     $A.enqueueAction(action);
    },

    getMultiMatch: function(cmp, event){
        var accountId = cmp.get("v.recordId");
        console.log('account - getMultiMatch', accountId);
        if(accountId != null){
            console.log('getMultiMatch: Account is already assigned -  exit: ', accountId);
            return;
        }
        console.log('currentRecordId - getMultiMatch', cmp.get("v.currentRecordId"));
        var action = cmp.get("c.getMultiMatch");
        action.setParams({ recordId : cmp.get("v.currentRecordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(' aura get multiMatch response', response.getReturnValue());
                if( response.getReturnValue())
                {
                    console.log(' aura get multiMatch response right here', response.getReturnValue());
                    var records = response.getReturnValue();
                    records.forEach(function(record){
                        record.linkName = '/'+record.Id;
                    })
                    cmp.set("v.isMultiMatch", records.length > 1);
                    cmp.set("v.accountList", records);
                    
                    console.log('accountList - getMultiMatch', cmp.get("v.accountList"));
                    //console.log('isMultiMatch - getMultiMatch', cmp.get("v.isMultiMatch"));
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(" Get MultiMatch Error message : " +  errors[0].message);
                    }
                } else {
                    console.log(" Get MultiMatch Unknown error")
                }            
            }

     });
     $A.enqueueAction(action);
    },

    getKeyInformation:function(cmp,event){
        var action = cmp.get("c.getKeyInformation");
        action.setParams({ accountId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.clientKeyInfo",response.getReturnValue().item);
                console.log(' aura get clientKeyInfo response', response.getReturnValue());
                console.log(' aura get clientKeyInfo ',  cmp.get("v.clientKeyInfo"));

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(" Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error")
                }            
            }

     });
     $A.enqueueAction(action);
    },
    
    editAccount: function(component, event){

		if(component.get("v.editModalOpened")) return;
		component.set("v.editModalOpened", true);
      
        var myHelper = this;
		var modalBody, modalFooter;
		$A.createComponents([
			["c:ICX_Account_Highlight_Edit2",{
                recordId : component.get("v.recordId"),
                taskRecordId : component.get("v.relatedRecordId")
            }],
			["c:ICX_Account_Highlight_Edit_Buttons",{}]
        ],
        //callback
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
                    closeCallback: function(event) {
                        component.set("v.editModalOpened", false);
                    }
                })
				}
			}
		)
	},

    searchAccount: function(component, event){
        console.log('recordId - searchAccount 0', component.get("v.recordId"));
        console.log('currentRecordId - searchAccount 0', component.get("v.currentRecordId"));

		if(component.get("v.editModalOpened")) return;
		component.set("v.editModalOpened", true);
		var modalBody, modalFooter;
        console.log('recordId - searchAccount 1', component.get("v.recordId"));
        console.log('account - searchAccount 1', component.get("v.account"));
		$A.createComponents([
			["c:ICX_Flow_Account",{
                recordId : component.get("v.currentRecordId"),
                accountNotVerified : true,
                isModal : true
            }],
			["c:ICX_Account_Highlight_Edit_Buttons",{}]
			],
            //callback
			function(components, status){
				if(status==="SUCCESS"){
					modalBody = components[0];
					modalFooter = components[1];
					modalFooter.set("v.parent", modalBody);
					component.find("overlayLib").showCustomModal({
						header: "Search Account",
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
        console.log('recordId - searchAccount 2', component.get("v.recordId"));
        console.log('account - searchAccount 2', component.get("v.account"));
	},

    updateRecordClient: function(cmp, event, helper){
        var accountId = event.getParam("accountId");
        var contactId = event.getParam("contactId");
        var recordId = cmp.get("v.currentRecordId");
        var objectName = cmp.get("v.sObjectName");

        console.log('@@ params: ', {accountId, contactId, recordId, objectName});

        var action = cmp.get("c.updateClient");
        action.setParams({accountId, contactId, recordId, objectName});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(' Update Record Client response', response.getReturnValue());
                if(response.getReturnValue()){
                    cmp.set("v.recordId", accountId);
                    cmp.set("v.account", null);
                    helper.getContact(cmp, null );
                    helper.getKeyInformation(cmp, null);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(" Update Record Client Error message : " +  errors[0].message);
                    }
                } else {
                    console.log(" Update Record Client Unknown error")
                }            
            }
        });
        $A.enqueueAction(action);
    },
    
    refreshData : function(component, event, helper) {
        console.log("*** handleEvent", JSON.stringify(event));
        // var currentSObject = component.get("v.sObjectName");
        var newAccountId = event.getParam("recordId");           
        var updatedCurrentRecordId = event.getParam("currentRecordId");
        
        var currentAccountId = component.get("v.recordId");
        var currentRecordId = component.get("v.currentRecordId");
        
        console.log("refreshView > newAccountId", newAccountId);
        console.log("refreshView > updatedCurrentRecordId", updatedCurrentRecordId);
        console.log("refreshView > currentRecordId", currentRecordId);
        console.log("refreshView > currentAccountId", currentAccountId);
                
        //   var rec = component.get("v.recordId");
        //  component.set("v.currentRecordId", rec);
        
        // refresh highlight panel when the account id became not empty (account created from the Call or Case detail page for example)
        //if (updatedCurrentRecordId == currentRecordId && $A.util.isEmpty(currentAccountId) && !$A.util.isEmpty(newAccountId)) {
        if (updatedCurrentRecordId == currentRecordId && !$A.util.isEmpty(newAccountId)) {
                component.set("v.recordId", newAccountId);
                component.set("v.account",null);
                helper.getContact(component,event);
                helper.getKeyInformation(component,event);
                // don't refresh the view. For the Screen Flow (ex: Call), the refreshView will close the Flow (with criteria Resolution != null)
        }
        else if ($A.util.isEmpty(newAccountId))
        {
            window.location.reload()
        }
        //}  
        //*/
    }, 
})