({
    optionClick: function (cmp, event, helper) {
        // console.group('--ProductCatalogRelatedSkuItemController.optionClick--');
        var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
        var product = cmp.get('v.relatedSku');
        // console.log({Sku: product.Sku});
        myEvent.setParams({'searchKey': product.Sku});
        myEvent.fire();
        // console.groupEnd();
    }
})