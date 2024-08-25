({
    doInit: function (component, event, helper) {

        var action = component.get("c.getOrderId");
        var orderLineId = component.get("v.recordId");
        action.setParams(
            {
                orderLineId: orderLineId
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderId = response.getReturnValue();
                // console.log("response:", firmOrder);
                component.set("v.recordId", orderId);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({"recordId": orderId, isredirect: true});
                navEvt.fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);

        // console.groupEnd();

    },
})