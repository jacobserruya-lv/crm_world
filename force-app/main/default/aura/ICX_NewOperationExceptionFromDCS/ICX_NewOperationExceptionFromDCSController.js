({
    doInit: function(component, event, helper) {
        var caseRecordTypeId;      
        var action = component.get("c.getCaseRecordTypeID");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                caseRecordTypeId = response.getReturnValue();
                console.log("RecordType Id "+caseRecordTypeId);
                component.set("v.recordTypeId", caseRecordTypeId);
            }
            else { 
                console.log("Failed with state: " + state);
            }
        });
    
        $A.enqueueAction(action);
    },

    cancelDialog : function(component, helper) {
        component.destroy();
    },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        const fields = event.getParam('fields');       
        component.find('recordEditForm').submit(fields);
        var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Saved",
                        "type": "success",
                        "message": "The record was saved. Please refresh Operation Exception section"
                    });
                    component.destroy();                 
                    resultsToast.fire();
    },
       
   
        handleCreateLoad: function (component, event, helper) {
            
        var currentCare;       
        var currentCareId =  component.get('v.parentFieldId');       
      
        // get Care record
        var action = component.get("c.getCareRecord");
        action.setParams({ careId : currentCareId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                currentCare = response.getReturnValue();   
                component.find("countryField").set("v.value", currentCare.Client__r.SPO_Country_code__pc);
                if(currentCare.Assigned_To__c!=null)
                    component.find("ownerField").set("v.value", currentCare.Assigned_To__c);
                    component.find("careField").set("v.value", currentCareId);
                    component.find("clientField").set("v.value", currentCare.Client__c);     
                console.log("recordTypeId : "+ component.get("v.recordTypeId"));
                console.log("countryField : " +  component.find("countryField").get("v.value"));
                console.log("clientField : " +  component.find("clientField").get("v.value"));
                console.log("careField : " +  component.find("careField").get("v.value"));
                console.log("ownerField : " +  component.find("ownerField").get("v.value"));
            }
            else { 
                console.log("Failed with state: " + state);
            }
        });
    
        $A.enqueueAction(action);  

           
           
        }
    
   
})