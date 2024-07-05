({
	/*selectRecord : function(component, event, helper) {
		//Get the selected record from the list
		var selectedRecord = component.get("v.oRecord");
		//Get the event
		var evt = component.getEvent("sObjectSelectedEvent");
		evt.setParams({
			"sObjectType":selectedRecord
		});
		evt.fire();
	}*/
	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
	},
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
	},
	handleInputFocus: function(component) {
		component.set('v.isOpen', true);
	},
	handleInputBlur: function(component) {
		component.set('v.isOpen', false);
	},
})