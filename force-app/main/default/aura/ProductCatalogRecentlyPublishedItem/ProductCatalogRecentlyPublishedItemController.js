({
    optionClick: function (cmp, event, helper) {
        var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
        var product = cmp.get('v.product');
        console.log('product',product);
        myEvent.setParams({'searchKey': product.sku});
        myEvent.fire();
    }
})