({
	getOrderSettings : function(component) {
        var action = component.get("c.getOrderSettings");
        
        //action.setParams({});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            //console.log("orderSettings", result);
            component.set("v.orderSettings", result);
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
            "url": result.MakeItYoursAppUrl__c
            });
            
            urlEvent.fire();

    	});

        console.log(">>>>>>>> " + JSON.stringify(component.get("v.orderSettings")));

    	$A.enqueueAction(action);
    },
})