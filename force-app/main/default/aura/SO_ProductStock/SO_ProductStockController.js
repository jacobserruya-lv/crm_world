({
    recordChangeHandler : function(component, event, helper) {
        var id = event.getParam("recordId");
        component.set("v.recordId", id);

        helper.getStockAvailability(component);
	}
})