({

    removeSelectedItem : function(component, removedItemId) {
        //const selection = component.get('v.selection');
        //const updatedSelection = selection.filter(item => item.id !== removedItemId);
        //component.set('v.selection', updatedSelection);

        // Avoid double-click
        //let removeButton = component.find("removeButton");
        //removeButton.set("v.disabled", true);

        console.log("removeSelectedItem", JSON.stringify(component.get("v.item")));
        var item = component.get("v.item");
        const searchEvent = component.getEvent("onSearchAction");
        searchEvent.setParams({
            "action": "REMOVE",
            "recordId": item.qualification.Id//removedItemId
        });
        console.log("searchEvent", JSON.stringify(searchEvent.getParams()));
        searchEvent.fire();
   },
    
    /*getPicklistValue: function(component){
		var action= component.get("c.getPicklistOptions");
		action.setParams({qualification: component.get("v.item").qualification});
		action.setCallback(this, function(result){
			if(result.getState() === "SUCCESS"){
				var options = result.getReturnValue();
                component.set("v.currencyList",options.ProductCurrency__c);
			}
		});
		$A.enqueueAction(action);
	},*/
})