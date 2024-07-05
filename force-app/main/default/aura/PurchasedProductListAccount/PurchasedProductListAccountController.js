({
    doInit: function(component, event, helper) {
        helper.loadPurchasedProduct(component);
    },

	onMouseMove: function(component, event, helper) {
        console.log('onmousemove', event.target);
        if (event.target === event.currentTarget) return;
        var el = event.target;
        while (el && (!el.dataset || !el.dataset.id)) {
            el = el.parentElement;
        }
        console.log('el', el);
        if (el) {
			var items = component.get("v.items");
            component.find("popup").showPopup(items[el.dataset.id]);
        }
    },

    onMouseLeave: function(component, event, helper) {
        //if (event.target === component.find("list").getElement()) {
	        component.find("popup").hidePopup();    
        //}
    },

    goToRelatedList : function(component) {
        var navEvt = $A.get("e.force:navigateToRelatedList");
        navEvt.setParams({
            "relatedListId": "Purchased_Products__r",
            "parentRecordId" : component.get("v.recordId")
        });
        navEvt.fire();
    },

    onPreviousPage: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        var direction = event.getParam("direction");
        page = page - 1;
        helper.loadPurchasedProduct(component, page);
	},

	onNextPage: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        var direction = event.getParam("direction");
        page = page + 1;
        helper.loadPurchasedProduct(component, page);
	},

})