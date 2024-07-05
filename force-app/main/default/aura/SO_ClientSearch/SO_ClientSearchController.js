({
    doInit: function(component, event, helper) {
        //console.log('start init');
        // CSC users should search in Salesforce first.
        // Special Order (Creation) app is always is RMS search
        if (component.get("v.isCustomerServiceView")) {
            component.set("v.isRmsSearch", false);
        }
        helper.getCountryList(component);
        //console.log('end init');
    },

    clientSearchChange: function(component, event, helper) {
        helper.fireClientSearchChangeEvent(component);
        //helper.toggleDiv(component);        
    },
    
    clientSearchChangeAndHide: function(component, event, helper) {
        helper.fireClientSearchChangeEvent(component);
        helper.toggleDiv(component);        
    },
    
    togglePanel: function(component, helper) {
        //helper.toggleDiv(component);        
        var bodyCard = component.find("bodyCard");
        $A.util.toggleClass(bodyCard, "slds-hide");        
    },

    reset: function(component) {
        //component.set("v.clientData", new SO_Util.SearchClientData());
        component.set("v.lastname", "");
        component.set("v.firstname", "");
        component.set("v.email", "");
        component.set("v.phone", "");
        component.set("v.passport", "");
        component.set("v.country", "");
        component.set("v.postalcode", "");
        component.set("v.dreamId", "");
        //component.set("v.displayorder", "false");
        //helper.fireClientSearchChangeEvent(component);
    }
})