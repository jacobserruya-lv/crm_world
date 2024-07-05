({
    doInit: function (component, event, helper) {
        // console.group('MIY_FirmOrderRedirect.doInit');

        var action = component.get("c.getFirmOrder");
        var firmOrderId = component.get("v.recordId");
        action.setParams({firmOrderId: firmOrderId});
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed('MIY_FirmOrderRedirect.c.getFirmOrder ' + firmOrderId);

            var state = response.getState();
            if (state === "SUCCESS") {
                var firmOrder = response.getReturnValue();
                // console.log("response:", firmOrder);
                component.set("v.recordId", firmOrder.SPO_BriefName__c);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({"recordId": firmOrder.SPO_BriefName__c, isredirect: true});
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