({
	getProduct : function(component, page) {
        var action = component.get("c.findBySObjectId");//findById");

        action.setParams({
      		"productId": component.get("v.recordId")
    	});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.product", result);
            if (result) {
                component.set("v.slides", [
                    result.SPO_ImageLink1FrontView__c,
                    result.SPO_ImageLink2SideView__c,
                    result.SPO_ImageLink3OtherView__c,
                    result.SPO_ImageLink4InteriorView__c,
                    result.SPO_ImageLink5OtherView2__c    
                ]);
            }
        });
    	$A.enqueueAction(action);
	},

    getProductSettings : function(component) {
        var action = component.get("c.getProductSettings");

        action.setParams({});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            //console.log("productsettings", result);
            component.set("v.productSettings", result);
    	});
        action.setStorable();
    	$A.enqueueAction(action);
    }
    /*
    getProductFromOpportunity : function(component, page) {
        var action = component.get("c.findByOpportunityId");

        action.setParams({
      		"oppId": component.get("v.oppId")
    	});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.product", result);
    	});
    	$A.enqueueAction(action);
	}
*/
})