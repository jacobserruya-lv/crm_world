({
	getAvailabilities : function(cmp, event, helper) {
		var productVariationsStock = cmp.get('v.productVariationsStock');
        var productSizes = cmp.get('v.productSizes');
        //var myProductData = cmp.get('v.myProductData');
        
		var productAvailabilities;
        if(productVariationsStock) {
            for(var i = 0; i < productSizes.length; i++){
                productAvailabilities = productVariationsStock[productSizes[i].Sku];
                if(productAvailabilities) {
                    productSizes[i].haveAvailabilities = false;
                    for(var j = 0; j < productAvailabilities.length; j++) {
                        if(productAvailabilities[j].inStock > 0  || productAvailabilities[j].csc == true || productAvailabilities[j].online == true) {
                            productSizes[i].haveAvailabilities = true;
                        }
                    }   
            	}
            }
            /*productAvailabilities = productAvailabilities[myProductData.Sku];
            
            if(productAvailabilities != null) {
                myProductData.haveAvailabilities = false;
                for(var j = 0; j < productAvailabilities.length; j++) {
                    if(productAvailabilities[j].inStock > 0  || productAvailabilities[j].csc == true || productAvailabilities[j].online == true) {
                        myProductData.haveAvailabilities = true;
                        break;
                    }
                }  
            }*/
            
        }
        cmp.set('v.productSizes', productSizes);
        //console.log('myProductData ', myProductData.ValueName);
        //cmp.set('v.myProductData', myProductData);
	}
})