({
	getAvailabilities : function(cmp, event, helper) {
		var productVariationsStock = cmp.get('v.productVariationsStock');
        var productVariant = cmp.get('v.productVariant');
        var haveAvailabilities = false;
        var productAvailabilities;

       	if(productVariationsStock) {
            var sku = productVariant.Sku;
            productAvailabilities = productVariationsStock[sku];

            if(productAvailabilities) {
                for(var i = 0; i < productAvailabilities.length; i++) {
                    if(productAvailabilities[i].inStock > 0  || productAvailabilities[i].csc == true || productAvailabilities[i].online == true) {
                        haveAvailabilities = true;
                        break;
                    }
                }	
            }
        }
        cmp.set('v.haveAvailabilities', haveAvailabilities);
	}
})