({
	getProduct : function(component, page) {
        var recId = component.get("v.recordId");
        
        if (recId) {
            var action = component.get("c.findById");
            action.setParams({
                "productId": recId
            });
            action.setCallback(this, function(a) {
                var result = a.getReturnValue();
                component.set("v.product", result);
                component.set("v.slides", [
                    result.SPO_ImageLink1FrontView__c,
                    result.SPO_ImageLink2SideView__c,
                    result.SPO_ImageLink3OtherView__c,
                    result.SPO_ImageLink4InteriorView__c,
                    result.SPO_ImageLink5OtherView2__c    
                ]);
            });
            $A.enqueueAction(action);
        }
	}
})