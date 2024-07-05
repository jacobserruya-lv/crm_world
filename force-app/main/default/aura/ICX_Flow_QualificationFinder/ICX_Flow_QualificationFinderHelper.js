({
	fireEvent : function(component, event) {
		const searchEvent = component.getEvent('onQualificationSelected');
        searchEvent.setParams({
            "value": resultValue,
            "field" : component.get("v.field")
        });
        searchEvent.fire();
	},
})