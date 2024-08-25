({
	showSpinner: function(component) {
		var spinnerMain =  component.find("Spinner");
		$A.util.removeClass(spinnerMain, "slds-hide");
	},

	hideSpinner : function(component) {
		var spinnerMain =  component.find("Spinner");
		$A.util.addClass(spinnerMain, "slds-hide");
	},


    /*navigateToRecord : function(cmp, recordId) {
        console.log("navigateToRecord", recordId);
        var navService = cmp.find("navService");
        var pageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId":  recordId,
                "objectApiName": "Account",
                "actionName": "view"
            },
            "state": {}
        };        
        navService.navigate(pageReference);    
    },*/

    openNewRecordAndCloseExistingTab : function (component, recordId) {
        var workspaceAPI = component.find("workspace");
        if (!$A.util.isUndefined(workspaceAPI)) {
            workspaceAPI.isConsoleNavigation().then(function(responseConsole) {
                
                // open sub-tab in the Console app
                if (responseConsole) {
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        
                        var focusedTabId = response.tabId;
                        if (response.isSubtab) {
                            console.log("subtab", focusedTabId);
                            focusedTabId = response.parentTabId;
                            
                            console.log("openSubTab", focusedTabId);
                            workspaceAPI.openSubtab({
                                parentTabId : focusedTabId,
                                recordId : recordId,
                                //url : '/lightning/r/Case/' + caseID + '/view',
                                focus: true
                            }).then(function(response) {
                                console.log("close tab");
                                workspaceAPI.closeTab({tabId: response.tabId});
                            });
                        } else {
                            console.log("openTab", focusedTabId);
                            workspaceAPI.openTab({
                                //parentTabId : focusedTabId,
                                recordId : recordId,
                                //url : '/lightning/r/Case/' + caseID + '/view',
                                focus: true
                            }).then(function(response) {
                                console.log("closeTab>focusedTabId", focusedTabId);
                                if (!$A.util.isEmpty(focusedTabId)) {
                                    console.log("close tab");
                                    workspaceAPI.closeTab({tabId: focusedTabId});
                                }
                            });

                        }

                        
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                } else {
                    // if not in a Console app
                    var urlEvent = $A.get("e.force:navigateToSObject");
                    urlEvent.setParams({
                        "recordId" : recordId,
                        "isredirect" : "true"
                    });
                    urlEvent.fire();
                }
                
            })
            .catch(function(error) {
                console.log(error);
            });
            
        }
    },

    closeTab : function(component, event) {

        var workspaceAPI = component.find("workspace");
        console.log("handleStatusChange>workspaceAPI", workspaceAPI);
        if (!$A.util.isUndefined(workspaceAPI)) {
            workspaceAPI.isConsoleNavigation().then(function(responseConsole) {
                if (responseConsole) {
                    // Console
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        if (response.isSubtab) {
                                //focusedTabId = response.parentTabId;
                        }
                        console.log("closeTab>focusedTabId", focusedTabId);
                        workspaceAPI.closeTab({tabId: focusedTabId});
                	})
                } else {
                    // Standard app
                    window.history.back();
                }
            });

        }
    },

})