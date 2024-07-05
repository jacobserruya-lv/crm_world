({

    getAccount : function(cmp, event, helper) {
        
        // change recordId to get Account Id from Case
        var caseService = cmp.find("caseService");
        console.log('recordId', cmp.get("v.recordId"));
        caseService.findAccount(cmp.get("v.recordId"),cmp.get("v.accountApi"),$A.getCallback(function(error, data) {
            console.log('caseService data', data);
            cmp.set("v.recordId", data);
            cmp.set("v.account", data); // //
            cmp.set("v.accountChanged", true);

            console.log('recordId - getAccount', cmp.get("v.recordId"));
            console.log('account - getAccount', cmp.get("v.account"));
            console.log('currentRecordId - getAccount', cmp.get("v.currentRecordId"));

            helper.getContact(cmp,event);
            helper.getKeyInformation(cmp,event);
            //component.find('recordDataAccount').reloadRecord(true);
            //component.set("v.accountId", data);
        }));
	},

    getContact: function(cmp, event){
        console.log('recordId - getContact', cmp.get("v.recordId"));
        console.log('account - getContact', cmp.get("v.account"));
        console.log('currentRecordId - getContact', cmp.get("v.currentRecordId"));
        var action = cmp.get("c.getContact");
        action.setParams({ accountId : cmp.get("v.recordId") });
        // action.setParams({ accountId : cmp.get("v.currentRecordId") });
        
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
})