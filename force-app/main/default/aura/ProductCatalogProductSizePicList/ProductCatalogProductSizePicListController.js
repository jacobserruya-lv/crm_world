({
	changeSize : function(cmp, event, helper) {
        var productSku = cmp.find("selectProductSize").get("v.value");
        var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
        myEvent.setParams({ 'searchKey': productSku});
        myEvent.fire();
	},
    
     getAvailabilities: function(cmp, event, helper) {
    	helper.getAvailabilities(cmp, event, helper);
	},

    updateMyProductNoStock: function(cmp,event,helper) {
        var myProductNoStock = event.getParam('myProductNoStock');
        cmp.set('v.myProductNoStock', myProductNoStock);
    }

})