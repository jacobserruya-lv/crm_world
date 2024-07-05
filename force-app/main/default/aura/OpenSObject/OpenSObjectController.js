/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
 ({

	invoke : function(component, event, helper) {
    	//var args = event.getParam("arguments");
        
        var destObject = component.get("v.SObject");
        console.log("destObject", destObject);
        /*var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": destObject,
          "slideDevName": "related"
        });
        navEvt.fire();*/

        // Salesforce recommends using lightning:navigation component instead: https://developer.salesforce.com/docs/component-library/bundle/force:navigateToSObject/documentation */
        var pageReference = {
            type: "standard__recordPage",
            attributes: {
                "recordId": destObject,
                "objectApiName": "Case",
                "actionName": "view"
            }
        };
        console.log("pageReference", pageReference);
        var navService = component.find("navService");
        console.log("navService", navService);
        navService.navigate(pageReference, false);

        /*var workspaceAPI = component.find("workspace");
        console.log("workspaceAPI", workspaceAPI);
        workspaceAPI.isConsoleNavigation().then(function(responseConsole) {
			 console.log("responseConsole", responseConsole);
            // open sub-tab in the Console app
            if (responseConsole) {
                workspaceAPI.getFocusedTabInfo().then(function(response) {

                    var focusedTabId = response.tabId;
                    if (response.isSubtab) {
                        focusedTabId = response.parentTabId;
                    }

                    console.log("focusedTabId/destObject", focusedTabId, destObject);
                    workspaceAPI.openSubtab({
                        parentTabId : focusedTabId,
                        recordId : destObject,
                        //url : '/lightning/r/Case/' + caseID + '/view',
                        focus: true                    
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            } else {
                // if not in a Console app
                var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                    "recordId" : destObject,
                    "isredirect" : "true"
                });
                urlEvent.fire();
            }
            
        })
        .catch(function(error) {
            console.log(error);
        });*/
    }
     
 })