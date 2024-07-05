({

    titleClickHandler: function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.item").Order__c
        });
        navEvt.fire();
    },

    handleMouseEnter : function(component, event, helper) {
        var popover = component.find("popup");
        console.log('handleMouseEnter',popover);
        $A.util.removeClass(popover,'slds-hide');
    },

    //make a mouse leave handler here
    handleMouseLeave : function(component, event, helper) {
        var popover = component.find("popup");
        console.log('handleMouseLeave',popover);
        $A.util.addClass(popover,'slds-hide');
    },

    handleClickLWC: function(component, event, helper) {
        var navService = component.find("navService");
        var compDefinition = {
            componentDef: "c:icx_accountOrderDetails"//My Lwc Component
            
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
    
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": component.get("v.item").Order__c,
                "objectApiName": "Order__c",
                "actionName": "view"
            }
        }
    
        //navService.navigate(pageReference);
        
        var workspaceAPI = component.find("workspace");
        navService.generateUrl(pageReference).then(function(cmpURL) {
            workspaceAPI.getEnclosingTabId().then(function(tabId) {
                return workspaceAPI.openSubtab({
                    parentTabId: tabId,
                    url: cmpURL,
                    focus: true
                });
            })
            .then(function(subTabId) {
            // the subtab has been created, use the Id to set the label
                workspaceAPI.setTabLabel({
                    tabId: subTabId,
                    label: "Order"
                });
                workspaceAPI.setTabIcon({
                    tabId: subTabId,
                    icon: "standard:orders",
                    iconAlt: "Order Line"
                });
            });
        });
    },

    // handleClick: function(component, event, helper) {
    //     console.log(component.get("v.item"));
    //     var pageReference = {
    //         type: 'standard__component',
    //         attributes: {
    //             componentName: 'c__Account_OrderDetails',
    //         },
    //         state: {
    //             "c__orderNumber": component.get("v.item").Order__r.OrderNumber__c
    //         }
    //     };
    //     const navService = component.find('navService');
    //     //event.preventDefault();
    //    // navService.navigate(pageReference);
    
    //    // handles checking for console and standard navigation and then navigating to the component appropriately
    //     var workspaceAPI = component.find("workspace");
    //     workspaceAPI.isConsoleNavigation().then(function(isConsole) {
    //     if (isConsole) {
    //         //  // in a console app - generate a URL and then open a subtab of the currently focused parent tab
    //         navService.generateUrl(pageReference).then(function(cmpURL) {
    //         workspaceAPI.getEnclosingTabId().then(function(tabId) {
    //             return workspaceAPI.openSubtab({
    //                 parentTabId: tabId,
    //                 url: cmpURL,
    //                 focus: true
    //             });
    //         })
    //         .then(function(subTabId) {
    //         // the subtab has been created, use the Id to set the label
    //             workspaceAPI.setTabLabel({
    //                 tabId: subTabId,
    //                 label: "Order"
    //             });
    //             workspaceAPI.setTabIcon({
    //                 tabId: subTabId,
    //                 icon: "standard:orders",
    //                 iconAlt: "Order Line"
    //             });
    //         });
    //         });
    //     } else {
    //         // this is standard navigation, use the navigate method to open the component
    //         navService.navigate(pageReference, false);
    //     }
    //     })
    //     .catch(function(error) {
    //     console.log(error);
    //     });
    // }

})