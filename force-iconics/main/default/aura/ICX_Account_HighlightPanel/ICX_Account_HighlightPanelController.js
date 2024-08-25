({
    doInit : function(component, event, helper) {

   
        var rec = component.get("v.recordId");
        var auth = component.get("v.authorizationToEdit");
        component.set("v.currentRecordId", rec);
        console.log('See the format of component',component.get("v.displayFormat"));


        /////////////////////////////////////////////////////////////////////////////////
        console.log('sobj name : ' + component.get("v.sObjectName"));
        if (component.get("v.sObjectName") !== 'Account') {
            helper.getAccount(component, event, helper);
            component.set("v.isAccount", false);
            console.log('sobj name in if statement: ' + component.get("v.sObjectName"));
            console.log("v.isAccount : ", component.get("v.isAccount"));
        }
        /////////////////////////////////////////////////////////////////////////////////
        else {
            helper.getContact(component,event);
            helper.getKeyInformation(component,event);
        }    
    },


    // doInit: function(component, event, helper) {
    //     var rec = component.get("v.recordId");
    //     component.set("v.currentRecordId", rec);
    
    //     console.log('sobj name : ' + component.get("v.sObjectName"));
    
    //     var accountPromise = Promise.resolve();
    //     if (component.get("v.sObjectName") !== 'Account') {
    //         accountPromise = new Promise(function(resolve, reject) {
    //             helper.getAccount(component, event, function() {
    //                 helper.getContact(component, event);
    //                 resolve();
    //             });
    //         });
    //     }
    //     else {
    //         helper.getContact(component, event);
    //     }
    
    //     accountPromise.then(function() {
    //         helper.getKeyInformation(component, event);
    //     });
    // },

    handleEdit:  function(component, event, helper) {
        helper.editAccount(component,event);
    },

    handleSearch:  function(component, event, helper) {
        console.log('handleSearch parent panel');
        helper.searchAccount(component,event);
    },
   
    handleEvent : function(component, event, helper) {
        
        console.log("*** handleEvent", JSON.stringify(event));
        var currentSObject = component.get("v.sObjectName");


            var newAccountId = event.getParam("recordId");           
            var updatedCurrentRecordId = event.getParam("currentRecordId");
            
            var currentAccountId = component.get("v.recordId");
            var currentRecordId = component.get("v.currentRecordId");
            
            console.log("refreshView > newAccountId", newAccountId);
            console.log("refreshView > updatedCurrentRecordId", updatedCurrentRecordId);
            console.log("refreshView > currentRecordId", currentRecordId);
            console.log("refreshView > currentAccountId", currentAccountId);
            
            
            //   var rec = component.get("v.recordId");
            //  component.set("v.currentRecordId", rec);
            
            // refresh highlight panel when the account id became not empty (account created from the Call or Case detail page for example)
            //if (updatedCurrentRecordId == currentRecordId && $A.util.isEmpty(currentAccountId) && !$A.util.isEmpty(newAccountId)) {
                if (updatedCurrentRecordId == currentRecordId && !$A.util.isEmpty(newAccountId)) {
                    component.set("v.recordId", newAccountId);
                    component.set("v.account",null);
                    helper.getContact(component,event);
            helper.getKeyInformation(component,event);
                    // don't refresh the view. For the Screen Flow (ex: Call), the refreshView will close the Flow (with criteria Resolution != null)
            }
            else if ($A.util.isEmpty(newAccountId))
            {
                window.location.reload()
   
            }
            //}
        
    }
})