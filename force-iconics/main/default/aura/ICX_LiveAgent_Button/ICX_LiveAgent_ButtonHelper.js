({
    /*close : function (component, event) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },


    open : function (component, event) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },*/

    openSubtab: function(component, event) {
        console.log(component.get("v.sObjectName"));
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__ICX_CaseCreation"
                    },
                    "state": {
                        "c__recordId" : component.get("v.recordId"),
                        "c__sObject" :  component.get("v.sObjectName")
                    }
                }
            }).then(function(subtabId) {
                
               workspaceAPI.setTabLabel({
                    tabId: subTabId,
                    label: "New Request"
                });
                workspaceAPI.setTabIcon({
                    tabId: subTabId,
                    icon: "standard:case",
                    iconAlt: "Request"
                });
                console.log("The new subtab ID is:" + subtabId);
            }).catch(function(error) {
                console.log("error");
            });
        });
    }
})