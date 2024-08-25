({
	callSaveFunction : function(component, event, helper) {
        var accountcomp = component.find("FlowAccount");
        if(!$A.util.isEmpty(accountcomp) && !$A.util.isEmpty(component.get("v.account"))){
         accountcomp.save();    
        }  
    },
    refresh : function() {       
        $A.get('e.force:refreshView').fire();
    },
    close : function() {
        $A.get("e.force:closeQuickAction").fire();
       
    }
})