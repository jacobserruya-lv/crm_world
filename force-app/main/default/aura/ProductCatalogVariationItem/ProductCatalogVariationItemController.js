({
	variantClick : function(cmp, event, helper) {
    	var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
        var product = cmp.get('v.productVariant');
        myEvent.setParams({ 'searchKey': product.Sku });
        myEvent.fire();
	},
    
    onmouseover : function(cmp) {
        var myEvent = cmp.getEvent("productCatalogVariantHover");
        var product = cmp.get('v.productVariant');

        myEvent.setParams({ 'hoverName': product.ValueName});
        myEvent.fire();
    },
    
    onmouseout : function(cmp) {
        var myEvent = cmp.getEvent("productCatalogVariantHover");

        myEvent.setParams({ 'hoverName': ''});
        myEvent.fire();
    },
    
    getAvailabilities: function(cmp, event, helper) {
    	helper.getAvailabilities(cmp, event, helper);
	},

    updateMyProductNoStock: function(cmp,event,helper) {
        var myProductNoStock = event.getParam('myProductNoStock');
        cmp.set('v.myProductNoStock', myProductNoStock);
        // console.log('no stock', myProductNoStock);
    }
})