({
    onclick : function (component, event, helper) {
        console.log(component.get("v.Case.OwnerId"));

        if (!component.get("v.Case.OwnerId").startsWith("00G")) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.Case.OwnerId"),
                "slideDevName": "related"
            });
            navEvt.fire();
        }
    }
})