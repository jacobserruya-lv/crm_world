({
	fireProductFilterChangeEvent : function(component) {
        var myEvent = $A.get("e.c:ProductFilterChange");
        myEvent.setParams({
            "searchKey" : component.get("v.searchKey"),
            "category"  : component.get("v.category"),
            "obsolete"  : component.get("v.obsolete")
        });
        console.log("Obsolete params on ProductFilterChange event " + myEvent.getParam("obsolete"));
        myEvent.fire();
    },

    getProductCategoryList : function(cmp) {        
    	this.callServer(cmp, "c.getProductCategoryJson", "v.productCategoryList");        
    },
    callServer : function(cmp, method, attribute) {        
        var action = cmp.get(method);
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // TODO use v.options for <ui:inputSelect> and not in page
                cmp.set(attribute, JSON.parse(response.getReturnValue()));
                
                /*var result = response.getReturnValue();
                var typeOpts = new Array();
                // Set the result on the ui:inputSelect component
                for (var i = 0; i < result.length; i++) {
                    typeOpts.push({label: result[i], value: result[i]});//, selected: result[i] === type});
                }
                cmp.find("unitField").set("v.options", typeOpts);*/

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
        action.setStorable();
        $A.enqueueAction(action);        
    },

    initMTOEnabled : function(component){
        var action = component.get("c.isMTOEnabled");
        
        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS"){
                var isMTOEnabled = response.getReturnValue();
                component.set("v.isMTOEnabled", isMTOEnabled);
            } else {
                console.log("could not load isMTOEnabled");
            }
        });

        $A.enqueueAction(action);
    }
})