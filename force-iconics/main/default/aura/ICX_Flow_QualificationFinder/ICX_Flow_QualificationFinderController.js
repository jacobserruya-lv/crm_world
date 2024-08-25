({
    doInit : function(component, event, helper) {
        console.log("doInit > picklistFieldValues", component.get("v.picklistFieldValues"));
		var label = component.get("v.label");
        if (!$A.util.isEmpty(label)) {
            component.set("v.translatedLabel", $A.getReference("$Label.c." + label));
        }
	},

    handleChangeClick : function(component, event, helper) {
		console.log("handleChangeClick", component.get("v.field"));
        component.set("v.showList", true);
        component.set("v.showButton", false);
        
        const searchEvent = component.getEvent('onQualificationSelected');
        searchEvent.setParams({
            "value": component.get("v.selection"),
            "field" : component.get("v.field"),
            "level" : component.get("v.level"),
            "action" : "Change"
        });
        searchEvent.fire();
	},

	/*selectionChanged : function(component, event, helper) {
        console.log("selectionChanged", component.get("v.field"));
        component.set("v.showList", false);
        component.set("v.showButton", true);
        
        helper.fireEvent(component, event);
	},*/

	handleSelection : function(component, event, helper) {
        component.set("v.showList", false);
        component.set("v.showButton", true);

        var resultValue = event.getParam("value");
        console.log("handleSelection > resultValue", resultValue);
        console.log("handleSelection > field", component.get("v.field"));
        //var field = component.get("v.field");
        
        const searchEvent = component.getEvent('onQualificationSelected');
        searchEvent.setParams({
            "value": resultValue,
            "field" : component.get("v.field"),
            "level" : component.get("v.level"),
            "action" : "Select"
        });
        searchEvent.fire();
	},

})