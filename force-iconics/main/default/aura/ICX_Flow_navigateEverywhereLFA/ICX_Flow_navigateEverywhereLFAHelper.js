({
    openSubtab: function(component, event, pageReference) {
        const regex = /&amp;/gi;

        //destinationUrl = encodeURI(destinationUrl);//.replace(regex,"&");
        //console.log("destinationUrl", destinationUrl);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            var focusedTabId = enclosingTabId.tabId;
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                //url: component.get("v.destinationUrl")
                pageReference: pageReference
                /*pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__greetings"
                    },
                    "state": {
                        "uid": "1",
                        "c__name": component.get("v.myName")
                    }
                }*/
            }).then(function(subtabId) {
                console.log("The new subtab ID is:" + subtabId);
                /*console.log("closeTab>focusedTabId", focusedTabId);
                if (!$A.util.isEmpty(focusedTabId)) {
                    console.log("close tab");
                    workspaceAPI.closeTab({tabId: focusedTabId});
                }*/
            }).catch(function(error) {
                console.log("error");
            });
        });
    },

/*
    redirectToRecordAndCloseExistingTab : function (component, recordId) {
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
                            console.log("close tab");
                            workspaceAPI.closeTab({
                                tabId: response.tabId
                            }).then(function(response) {
                                // redirect to record
                                workspaceAPI.openTab({
                                    recordId : recordId,
                                    focus: true
                                })
                            });

                        } else {
                            console.log("openTab", focusedTabId);
                            workspaceAPI.openTab({
                                //parentTabId : focusedTabId,
                                pageReference : recordId,
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
    },*/
})