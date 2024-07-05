({
    searchSku : function(component) {
        /*var sku = component.get("v.sku");

        var briefSPA = component.find("briefSPA");
        console.log("breiefSPA", briefSPA);
        briefSPA.search(sku);*/
        // TODO find product and registerEvent
        this.getProduct(component);
    },
    
    fireOpportunitySPAEvent : function(component) {
        //Pass the values grabbed from this LC Form to the next child LC via Lightning Events:
        var appEvent = $A.get("e.c:SO_OpportunitySPAEvent");
        appEvent.setParams({
            "product" : component.get("v.product"),
            "channel": "Init"
        });
        appEvent.fire();
    },
    
    getProduct: function(cmp) {
        if ($A.util.isEmpty(cmp.get("v.sku")) === false) {
            var action = cmp.get("c.getProductBySku");
            action.setParams({
                "sku": cmp.get("v.sku")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var prod =  response.getReturnValue();
                    cmp.set("v.product", prod);
                    
                    this.fireOpportunitySPAEvent(cmp);
                    
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
            //action.setStorable();
            $A.enqueueAction(action);        
        }
    },

    closeToast: function(cmp){        
        console.log("closing toast");
        cmp.set("v.showToast", false);
    },

    getOrderSettings : function(component) {
        var action = component.get("c.getOrderSettings");

        action.setParams({});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            //console.log("orderSettings", result);
            component.set("v.orderSettings", result);
    	});
    	$A.enqueueAction(action);
    }
})