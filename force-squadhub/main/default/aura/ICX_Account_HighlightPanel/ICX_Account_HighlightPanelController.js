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
        helper.refreshData(component, event, helper);
    }, 

    handleClientSelected: function(component, event, helper) {
        // alert(event.getParams());
        console.log('handle client selected event: ', JSON.stringify(event.getParams()));
        helper.updateRecordClient(component, event, helper);
    },
})