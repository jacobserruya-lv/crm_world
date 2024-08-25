({
    onNewRequest : function(component, event, helper) {
        
        //component.set("v.openRequestModal", true);
        //helper.open(component, event);

        
        /*
		// KO: Erorr message "The action you specified isn’t available on the current record page."
        var actionAPI = component.find("quickActionAPI");
        var args = { actionName :"LiveChatTranscript.New_Request" }; // UpdateContact is the action on the contact object
        actionAPI.selectAction(args).then(function(result) {
            // Action selected; show data and set field values
        	console.log("onNewRequest > result = ", result);
        }).catch(function(e) {
            if (e.errors) {
                console.log("onNewRequest > error = ", e.errors);
                // If the specified action isn't found on the page, 
                // show an error message in the my component 
            }
        });*/
        
        console.log("recordId",component.get("v.recordId"));
        helper.openSubtab(component, event);
        /*// Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            {name : "recordId", type : "String", value: component.get("v.recordId")},
            {name : "sObject", type : "String", value: "LiveChatTranscript"}
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("ICX_CaseCreation", inputVariables );*/
    },

    //Flow Status Change
    /*statusChange : function (component, event, helper) {
        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Request created successfully!",
                type: "success"
            });
            toastEvent.fire();

            helper.close(component, event);

            $A.get('e.force:refreshView').fire();
        } else if (event.getParam('status') === "ERROR") {
            //component.set("v.hasError", true);
        }
    },

    closeModal : function (component, event, helper) {
        helper.close(component, event);
    },*/
})