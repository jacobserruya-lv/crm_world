({
    optionClick: function (cmp, event, helper) {
        var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
        var product = cmp.get('v.product');
        myEvent.setParams({'searchKey': product.sku});
        myEvent.fire();
    },

    removeFromFavorites: function(cmp,event,helper) {
        var myEvent = $A.get('e.c:ProductCatalogFavoriteChangeEvent');
        var product = cmp.get('v.product');
        myEvent.setParams({'productToRemove': product.sku});
        myEvent.fire();
    }
})