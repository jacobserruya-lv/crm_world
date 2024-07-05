({
    doInit: function(component, event, helper) {
        var variationRecordTypeId;      
        var action = component.get("c.getPhysicalEventRecordTypeID");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                variationRecordTypeId = response.getReturnValue();
                console.log("RecordType Id "+variationRecordTypeId);
                component.set("v.recordTypeId", variationRecordTypeId);
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
                        "message": "The record was saved."
                    });
                   // component.destroy();                 
                    resultsToast.fire();
          
           

    },

    handleSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        // ID of updated or created record
        console.log("new record id: " + record.id);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": record.id,
          "slideDevName": "Detail"
        });
        navEvt.fire();
        component.destroy();     
    },
       
   
        handleCreateLoad: function (component, event, helper) {
            
        var currentExperience;       
        var currentExperienceId =  component.get('v.parentFieldId');       
      
        // get Parent record
        var action = component.get("c.getExperienceRecord");
        action.setParams({ experienceId : currentExperienceId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                currentExperience = response.getReturnValue();   
                component.find("startDateTimeField").set("v.value", currentExperience.Experience_StartDate__c);
                component.find("endDateTimeField").set("v.value", currentExperience.Experience_EndDate__c);               
                component.find("experienceField").set("v.value", currentExperienceId);
                component.find("experienceNameField").set("v.value", currentExperience.Name);
                  
                console.log("recordTypeId : "+ component.get("v.recordTypeId"));
          
                console.log("experienceField : " +  component.find("experienceField").get("v.value"));
              
            }
            else { 
                console.log("Failed with state: " + state);
            }
        });
    
        $A.enqueueAction(action);  

           
           
        }
    
   
})