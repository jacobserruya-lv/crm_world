({
    getAccount : function(component, event, helper) {

        var params = event.getParam("arguments");
        //this.callApex(component, "c.getAccountId", {"caseId": params.caseId}, this.getAccountSuccess);
        
        var action 	= component.get("c.getAccountIdByField");
        action.setParams({
            "recordId" : params.recordId,
            "accountField" : params.accountField
        });
        
        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                params.callback(null, response.getReturnValue());
            } else {
                params.callback(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getOpenCases : function(component, event, helper) {
        var params = event.getParam("arguments");
        console.log("getOpenCases > params", JSON.stringify(params));
        var action = component.get("c.getOpenCaseList");
        action.setParams({
            "recordId"	: params.recordId
        });
        
        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                params.callback(null, response.getReturnValue());
            } else {
                params.callback(response.getError());
            }
        });
        //action.setStorable();
        $A.enqueueAction(action);
    },
        
    getComplaints : function(component, event, helper) {
        var params = event.getParam("arguments");

        console.log("getComplaints", params.recordId);
        var action = component.get("c.getComplaintIndicator");
        action.setParams({
            "recordId"	: params.recordId
        });
        
        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('result', JSON.parse(response.getReturnValue()));
                params.callback(null, JSON.parse(response.getReturnValue()));
            } else {
                params.callback(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getIndicators : function(component, event, helper) {
        var params = event.getParam("arguments");
        console.log("getIndicators > params", JSON.stringify(params));
        var action = component.get("c.getIndicatorList");
        action.setParams({
            "recordId"	: params.recordId
        });
        
        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                params.callback(null, response.getReturnValue());
            } else {
                params.callback(response.getError());
            }
        });
        //action.setStorable();
        $A.enqueueAction(action);
    },

    updateObject : function(component, event, helper) {
        var params = event.getParam("arguments");
                
        var action = component.get("c.updateRecord");
        action.setParams({
            "recordId" : 	params.recordId,
            "accountId"	:	params.accountId
        });
        
        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('result', JSON.parse(response.getReturnValue()));
                params.callback(null, JSON.parse(response.getReturnValue()));
            } else {
                console.log('error', response.getError());
                params.callback(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    /*getAccountSuccess: function(component, returnValue) {
        //process result in some way
        component.set("v.contactList", returnValue);
    }

    callApex: function(component, controllerMethod, actionParameters, successCallback) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get(controllerMethod);
        action.setParams(actionParameters);
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //->HERE WE CALL THE CALLBACK RATHER PROCESS THE RESPONSE
                successCallback(component, response.getReturnValue())
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        // optionally set storable, abortable, background flag here
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    }*/
    
})