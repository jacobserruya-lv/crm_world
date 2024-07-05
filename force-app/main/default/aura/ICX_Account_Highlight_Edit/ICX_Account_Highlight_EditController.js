({
    handleLoad: function(cmp, event, helper) {
        console.log('handleLoad');
        //cmp.set('v.showSpinner', true);//false);
    },

    handleSubmit: function(cmp, event, helper) {
        console.log('handleSubmit');
        cmp.set('v.disabled', true);
        //cmp.set('v.showSpinner', true);
    },

    handleError: function(cmp, event, helper) {
        console.log('handleError');
        // errors are handled by lightning:inputField and lightning:nessages
        // so this just hides the spinnet
        //cmp.set('v.showSpinner', false);
    },

    handleSuccess: function(cmp, event, helper) {
        console.log('handleSuccess');
        //cmp.set('v.showSpinner', false);
        //cmp.set('v.saved', true);
    },

   /* fireEvent : function(component, event) {
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "mode" : "READ"
        });
        cmpEvent.fire();
    }*/
})