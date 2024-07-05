({
	doInit : function(component, event, helper) {
       
     },
    handleClick: function(component, event, helper) {
        helper.close();
        helper.callSaveFunction(component, event, helper);       
        window.setTimeout(
            $A.getCallback(function() {
               helper.refresh();
            }), 2000
		);
    },
    handleClientSelected: function(component, event, helper) {
        var params = event.getParams();
        component.set("v.account", params.account);
        component.set("v.selectedAccount", params.account.Id);
       
    },
    
    
})