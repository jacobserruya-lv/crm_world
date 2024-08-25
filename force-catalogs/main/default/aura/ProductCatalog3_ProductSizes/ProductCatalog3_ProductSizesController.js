({
    changeSize : function(cmp, event, helper) {
        var productSku = cmp.find("selectOtherProductSize").get("v.value");
        var product = {};
        var myproduct = {};
        var productSizes = cmp.get('v.productSizes');
        for(var i=0; i < productSizes.length; i++){
            myproduct = productSizes[i];
            if(myproduct.sku == productSku){
                product = myproduct;
                break;
            }
        }
        if(!product){
            product = cmp.get('v.product');
        }
        var myEvent = $A.get('e.c:ProductCatalog3_VariationClickEvent');
        myEvent.setParams({ 'product': product});
        myEvent.fire();
    },
})