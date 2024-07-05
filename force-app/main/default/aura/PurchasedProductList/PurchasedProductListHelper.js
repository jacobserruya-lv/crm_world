({
	doInit : function(component) {
        //var stateRecordId = component.get("v.pageReference").state.c__recordId;
        //console.log("stateRecordId", stateRecordId);
        var recordId = (!$A.util.isEmpty(component.get("v.recordId")) ? component.get("v.recordId") : component.get("v.pageReference").state.c__recordId);
        console.log("recordId", recordId);
        component.set("v.recordId", recordId);

		// call Apex controller
		var action 		= component.get("c.findPurchasedProductDB");
		//var recordId 	= component.find("idFromSearch").get("v.value");
		//var recordId	= component.get("v.recordId");
		//var idAttr		= component.set("v.id",recordId);
		action.setParams({
			//"Id" : component.get("v.recordId")
			"Id"	: recordId
		});

		action.setCallback (this, function(response){
			var state = response.getState();
			if(component.isValid() && state === 'SUCCESS'){
				component.set("v.purchasedProducts", response.getReturnValue());
			}
		});

		$A.enqueueAction(action);
        
        this.consoleSetTabLabel(component);
	},

	addProductToEventFromIndex : function(component, event, index){
		console.log('adding');

		var recordId	= component.get("v.recordId");
		var pp			= component.get("v.purchasedProducts");

		// Call Apex controller method
		var action = component.get("c.updatePurchasedProductOnEvent");
		action.setParams({
			"eventId" 	: recordId,
			"ppId"		: pp[index].pps[0].Id
		});

        action.setCallback (this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                this.consoleCloseTab(component, event);
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();

                component.find('notifLib').showToast({
                    "variant" : "success",
                    "message": "Record linked to " + pp[index].transactionid + " transaction"
                });

            }
        });

		$A.enqueueAction(action);
	},

    consoleCloseTab : function(component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response == true) {
                var focusedTabId = component.get("v.focusedTabId");
           // workspaceAPI.getFocusedTabInfo().then(function(response) {
           //     var focusedTabId = response.tabId;
                console.log("focusedTabId", focusedTabId);
                workspaceAPI.closeTab({tabId: focusedTabId});
            /*})
            .catch(function(error) {
                console.log("getFocusedTabInfo", error);
            });*/
            } else {
                // standard app, go back to the record page
                var pageReference = {
                    type: "standard__recordPage",
                    attributes: {
                        "recordId": component.get("v.recordId"),
                        "actionName": "view"
                    }
                };
                var navService = component.find("navService");
                navService.navigate(pageReference, false);
            }
        })
        .catch(function(error) {
            console.log("error", error);
        });
    }, 
    
    consoleSetTabLabel : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response == true) {
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    component.set("v.focusedTabId", focusedTabId);
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Link to Purchase"
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            }            
        })
        .catch(function(error) {
            console.log(error);
        });
    }

})