({
	variantClick : function(cmp, event, helper) {
        var product = cmp.get('v.productVariant');
        var myEvent = $A.get('e.c:ProductCatalog3_VariationClickEvent');
        myEvent.setParams({ 'product': product});
        myEvent.fire();

        //for new relic
        /*var myEventnewRelic = $A.get('e.c:AnalyticsServiceEvent');
        myEventnewRelic.setParams({
            'application': 'Catalogue',
            'parameters': '{"sku":"'+product.sku+'"}',
            'action': 'variations'
        });
        myEventnewRelic.fire();*/
	},
    
    onmouseover : function(cmp) {
        var myEvent = cmp.getEvent("productCatalogVariantHover");
        var product = cmp.get('v.productVariant');
        //console.log('product', product);

        myEvent.setParams({ 'hoverName': product.materialTypeName +' - ' + product.MarketingColorName});
        
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