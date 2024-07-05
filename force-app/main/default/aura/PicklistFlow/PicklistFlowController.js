({
    onInit : function(component, event, helper) {
        console.log("onInit > value", component.get("v.selectedValue"));

        helper.validate(component, event);

        //helper.getPicklist(component, helper);
        
        helper.getAllPicklist(component, event, helper);
    },

    handleSelection : function(component, event, helper) {
        var result = event.getParam("value");
        console.log("handleSelection > result", result);
        component.set("v.selectedValue", result);

        helper.goFlowNext(component);
    },

    onPicklistFieldValuesChanged : function(component, event, helper) {
        helper.filterPicklist(component, helper);
    }
})