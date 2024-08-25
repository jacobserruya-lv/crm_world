({
	doInit : function(component, event, helper) {
        
        //helper.setFocusedTabLabel(component, event);

        var pageReference = component.get("v.pageReference");
        var state;
        if (!$A.util.isEmpty(pageReference)) {
            state = pageReference.state;
        }
        console.log("pageReference>State", state);

        var recordId = (!$A.util.isEmpty(state) ? state.c__recordId : component.get("v.recordId"));
        var sObject = (!$A.util.isEmpty(state) ? state.c__sObject : component.get("v.sObject"));
        var isNewQualification = (!$A.util.isEmpty(state) ? state.c__isNewQualification : component.get("v.isNewQualification"));
        console.log("recordId", recordId);
        console.log("sObject", sObject);
        console.log("isNewQualification", isNewQualification);

        //var VarLiveChatID = state.c__VarLiveChatID;
        //var VarCaseId = state.c__VarCaseId;

        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        console.log("flow", flow);

        if (!$A.util.isEmpty(sObject)) {
            var inputVariables = [
                { name : "recordId", type : "String", value: recordId },
                { name : "sObject", type : "String", value: sObject },
                { name : "isNewQualification", type : "Boolean", value: isNewQualification }
            ];
            console.log("inputVariables", inputVariables);
            flow.startFlow("ICX_CaseCreation", inputVariables);
        } else {
            flow.startFlow("ICX_CaseCreation");
        }

        //var recordData = component.find("recordData);
        //recordData.reloadRecord(true);

       	//helper.getDocumentList(component, event);
        //helper.consoleSetTabLabel(component);
	},

    handleStatusChange : function (component, event, helper) {
        console.log("handleStatusChange>event.getParam(status)", event.getParam("status"));
        if(event.getParam("status") === "FINISHED") {

            //helper.closeTab(component, event);

            // Success! Prepare a toast UI message
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "message": $A.get("$Label.c.ICX_CaseFromTaskSuccess"),
                "type": "success"
            });
            resultsToast.fire();

            // Get the output variables and iterate over them
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                console.log("outputVar", outputVar);

                // Pass the values to the component's attributes
                if (outputVar.name === "VarNewCaseID" && !$A.util.isEmpty(outputVar.value)) {

                    /*var pageReference = component.get("v.pageReference");
                    var state;
                    if (!$A.util.isEmpty(pageReference)) {
                        state = pageReference.state;
                    }
                    var recordId = (!$A.util.isEmpty(state) ? state.c__recordId : component.get("v.recordId"));
                    console.log("pageReference>State", state);
                    console.log("recordId", recordId);
                    console.log("outputVar.value", outputVar.value);
                    
                    //if (outputVar.value == recordId) {
                        // If the case is just updated (not created), so no need to close the tab but just refresh it
                    //    helper.navigateToRecord(component, recordId);
                    //} else {*/
                    //}

                    //helper.redirectTab(component, outputVar.value);
                    //helper.navigateToRecord(component, outputVar.value);
                    helper.openNewRecordAndCloseExistingTab(component, outputVar.value);

                }/* else {
                    component.set("v.numberOfEmployees", outputVar.value);
                }*/
            }

        }
    },

    /*handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log("eventParams.changeType", eventParams.changeType);
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            //var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            // record is changed, so refresh the component (or other component logic)
            //helper.handleOK(component);
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
            helper.getDocumentList(component, event);
        } else if(eventParams.changeType === "REMOVED") {
            console.log("REMOVED>eventParams", eventParams);
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log("ERROR>eventParams", eventParams);
            // there’s an error while loading, saving or deleting the record
        }
    },*/

    // invoke function for Local Action Flow
	/*invoke : function(component, event, helper) {
    	//var args = event.getParam("arguments");

        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/cmp/c__ICX_CaseCreation?c__recordId=' + component.get("v.recordId") + '&c__sObject=' + component.get("v.sObject") + '&c__isNewQualification=' + component.get("v.isNewQualification"),
            focus: true
        });
    },*/

})