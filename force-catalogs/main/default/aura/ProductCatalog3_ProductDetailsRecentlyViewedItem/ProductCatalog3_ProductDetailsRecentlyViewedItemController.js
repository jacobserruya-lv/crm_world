({
    openRecentlyViewed: function(cmp,event,helper) {
		var product = cmp.get('v.product');
		var myEvent = $A.get('e.c:ProductCatalog3_productClickEvent');
        myEvent.setParams({ 'product': product, 'fromWhere': 'recentlyViewed'});
        myEvent.fire();
	}
})