({
    changeSize : function(cmp, event, helper) {
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

})