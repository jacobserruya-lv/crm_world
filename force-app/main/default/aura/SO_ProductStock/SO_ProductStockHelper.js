({
	getStockAvailability : function(component) {
        var action = component.get("c.getStock");

        action.setParams({
      		"productId": component.get("v.recordId"),
            "storeName" : ""
    	});
    	action.setCallback(this, function(a) {
            var state = a.getState();

            if (state === "SUCCESS") {
	            var result = a.getReturnValue();
            	component.set("v.stockList", JSON.parse(result));
                component.set("v.errorMessage", "");
                //component.set("v.product", result);
            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
            			component.set("v.errorMessage", errors[0].message);
                        // Display toast message to indicate status
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "	Technical error on stock availability!",
                            "message": errors[0].message
                        });
                        console.log("Error message: " + errors[0].message);
			            toastEvent.fire();
//                        alert(errors[0].message);*/
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
    	$A.enqueueAction(action);
	}

})