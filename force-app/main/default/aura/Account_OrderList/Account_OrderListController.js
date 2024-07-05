({
    doInit: function(component, event, helper) {
        helper.getOrders(component);
    },
    openRelatedList: function(component, _event){ 
        /*var relatedListEvent = $A.get("e.force:navigateToRelatedList"); 
        relatedListEvent.setParams({ 
            "relatedListId": "Order__r", 
            "parentRecordId": component.get("v.recordId") 
       }); 
        relatedListEvent.fire();*/
    },
    onPreviousPage: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        var direction = event.getParam("direction");
        page = page - 1;
        helper.getOrders(component, page);
	},

	onNextPage: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        var direction = event.getParam("direction");
        page = page + 1;
        helper.getOrders(component, page);
	},

})