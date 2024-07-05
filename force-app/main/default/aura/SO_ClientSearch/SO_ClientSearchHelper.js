({
    fireClientSearchChangeEvent : function(component) {
        console.log("fireClient,component.get(v.isRmsSearch)", component.get("v.isRmsSearch"));
        var myEvent = $A.get("e.c:SO_ClientFilterChange");
        myEvent.setParams({
            "lastname": component.get("v.lastname"),
            "firstname": component.get("v.firstname"),
            "email": component.get("v.email"),
            "phone": component.get("v.phone"),
            "passport": component.get("v.passport"),
            "country": component.get("v.country"),
            "postalcode": component.get("v.postalcode"),
            "storeCode": component.get("v.storeCode"),
            "isRmsSearch" : component.get("v.isRmsSearch"),
            "isCustomerServiceView" : component.get("v.isCustomerServiceView"),
            "dreamId" : component.get("v.dreamId")
        });
        myEvent.fire();
    },

    getCountryList : function(component) {
        var action = component.get("c.getCountryMap");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var countries = [];
                var conts = response.getReturnValue();

                for (var key in conts) {
                    countries.push({key:conts[key], value:key});
                }
                component.set("v.countryList", countries);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        //action.setStorable();
        $A.enqueueAction(action);
    },

    toggleDiv : function(component) {
        var bodyCard = component.find("bodyCard");
        $A.util.toggleClass(bodyCard, "slds-hide");        
    }
})