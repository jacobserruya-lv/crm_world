({
	handleSpam: function(component, event){
        var cas = component.get("v.simpleCase");
         if ("Awaiting" == cas.Status && !cas.Spam__c){
             var errorToast = $A.get("e.force:showToast");
             errorToast.setParams({
                 "message": $A.get("$Label.c.CaseSpamButton_AwaitingError"),
                 "type": "error"
             });
             errorToast.fire();
        }
        else if ("Closed" != cas.Status && !cas.Spam__c) {
            component.set("v.simpleCase.Spam__c", true);
            component.set("v.simpleCase.SpamReason__c", "Manual");
            component.find("caseRecordLoader").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log('handleSpam SUCCESS', JSON.stringify(saveResult));
                
                    // Success! Prepare a toast UI message
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "message": $A.get("$Label.c.CaseSpamButton_SuccesfulySpammed"),
                    	"type": "success"
                    });
                    resultsToast.fire();

                    // Update the UI: close panel, show toast, refresh account page
                    $A.get("e.force:closeQuickAction").fire();
                  
                    // Reload the view so components not using force:recordData are updated
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                    	"recordId": component.get("v.recordId")
                    });
                    navEvt.fire();
                    
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving contact, error: ' +
                    JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state +
                    ', error: ' + JSON.stringify(saveResult.error));
                }
            });
        }
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
    }
})