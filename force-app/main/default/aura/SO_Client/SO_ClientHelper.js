({
    getSalutationList : function(cmp) {        
    	this.callServer(cmp, "c.getSalutationJson", "v.salutationList");
    },
    
    /*getClientTypeList : function(cmp) {        
    	this.callServer(cmp, "c.getClientTypeJson", "v.clientTypeList");        
    },

    getNationalityList : function(cmp) {        
    	this.callServer(cmp, "c.getNationalityJson", "v.nationalityList");        
    },*/

    getCountryList : function(cmp) {        
    	this.callServer(cmp, "c.getCountryJson", "v.countryList");        
    },

    /*getPhoneCountryList : function(cmp) {        
    	this.callServer(cmp, "c.getPhoneCountryJson", "v.phoneCountryList");        
    },*/
    
    callServer : function(cmp, method, attribute) {        
        var action = cmp.get(method);
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // TODO use v.options for <ui:inputSelect> and not in page
                cmp.set(attribute, JSON.parse(response.getReturnValue()));                
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
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
        //action.setStorable();
        $A.enqueueAction(action);        
    },

    validateAccountForm: function(component) {
        var validAccount = true;
        
        // Show error messages if required fields are blank
        var allValid = component.find('accountField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        
        if (allValid) {
            // Verify we have an account to attach it to
            var account = component.get("v.account");
            if($A.util.isEmpty(account)) {
                validAccount = false;
                console.log("Quick action context doesn't have a valid account.");
            }
        }  
        return(validAccount);
    }
    
})