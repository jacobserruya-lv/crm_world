({        
    createCase: function(component, event){
        // create task if needed
        var action = component.get("c.createCase");
        action.setParams({
            'taskID': component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("storeResponse: " + storeResponse);
                var message = "";
                // In case of error
				if(storeResponse.startsWith('ERROR'))
                {
                    // if there is already a case linked to that task
                    if(storeResponse == 'ERROR_CASE_EXIST')
                    {
                        message = $A.get("$Label.c.ICX_CaseFromTaskError");
                    }
                    // if mandatory fields are empty
                    else if(storeResponse == 'ERROR_MISSING_REQUIRED_FIELDS')
                    {
                        message = $A.get("$Label.c.ICX_CaseFromTaskError1");
                    }
                    component.set("v.message", message);
                    this.showErrorMessage(component, event);
                }
                // if case creation succeeds
                else
                {
                    // retrieve case id and get success message
                    component.set("v.newcaseid", storeResponse);
                    message = $A.get("$Label.c.ICX_CaseFromTaskSuccess");
                    component.set("v.message", message);
                    // redirect to the case page and display success message
                    this.redirectToCase(component, event);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    showErrorMessage: function(component, event)
    {
        this.closeModal(component, event);
        // Display the success in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "message": component.get("v.message"),
            "type" : "error"
        });
        resultsToast.fire(); 
    },
    
    showSuccessMessage: function(component, event)
    {
        // close modal
        this.closeModal(component, event);
        
        // Display the success in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "message": component.get("v.message"),
            "type" : "success"
        });
        resultsToast.fire();
    },
    
    closeModal : function(component, event)
    {
        // close the modal
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire(); 
    },
    
    redirectToCase : function(component, event) {
  
        // Display the success in a "toast" status message
		this.showSuccessMessage(component, event);

        // if a case has been created then redirect to the newly created case detail page
        var caseID = component.get("v.newcaseid");
        if(caseID !== null && caseID !== "")
        {
            this.redirectTab(component, event);
        }
    },
    
    redirectTab : function (component, event) {
        var caseID = component.get("v.newcaseid");

        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(responseConsole) {

            // open sub-tab in the Console app
            if (responseConsole) {
                workspaceAPI.getFocusedTabInfo().then(function(response) {

                    var focusedTabId = response.tabId;
                    if (response.isSubtab) {
                        focusedTabId = response.parentTabId;
                    }

                    workspaceAPI.openSubtab({
                        parentTabId : focusedTabId,
                        recordId : caseID,
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
                    "recordId" : caseID,
                    "isredirect" : "true"
                });
                urlEvent.fire();
            }
            
        })
        .catch(function(error) {
            console.log(error);
        });
    }
    
})