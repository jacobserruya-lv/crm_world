({
    doInit : function(cmp, event, helper) {
        console.log("LiveChatURL");       
        var Id = cmp.get("v.recordId");
        var action = cmp.get("c.getData");
        action.setParams({ recordId : Id });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.url", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.log("Error message: Incomplete request");
            }
            else if (state === "ERROR") {
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
        $A.enqueueAction(action);
     }
})