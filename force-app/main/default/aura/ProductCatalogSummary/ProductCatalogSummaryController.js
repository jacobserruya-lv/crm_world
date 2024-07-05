({
    
	getProductCatalog: function(cmp, event, helper) { 
        var productClicked = event.getParam('productClicked');
		//var product = productClicked ? event.getParam('product') : cmp.get('v.product');
		var product = event.getParam('product');

        var productVariations = event.getParam('productVariations');
        if(product) {
            cmp.set('v.product', product);
            cmp.set('v.productVariations', productVariations);
            cmp.set('v.productVariationsStock', null);
        	helper.hideSpinner(cmp);
        }
        else {
        	cmp.set('v.product', null);
        }    
	},
	
	showSpinner: function(cmp, event, helper) {
        helper.showSpinner(cmp);
    },
    
    hideSpinner: function(cmp, event, helper) {
        helper.hideSpinner(cmp);
    },
    
    handleSpinner: function(cmp, event, helper) {
		var show = event.getParam('show');
		helper.handleSpinner(cmp, helper, show);
    },
    
    /*updatePrice: function(cmp, event, helper) {
        if(cmp.get('v.product')) {
    		var product = cmp.get('v.product');
	    	product.price = event.getParam('price');
	    	product.currency = event.getParam('currency');
            product.inCm = event.getParam('inCm');
            
            console.log(event.getParam('inCm'));
	    	cmp.set('v.product', product);
    	}
    	helper.hideSpinner(cmp);
    }*/
    
    updateSelectedStores: function(cmp, event, helper) {
		var selectedStores = event.getParam('selectedStores');
		cmp.set("v.selectedStores", selectedStores);
        cmp.set("v.productVariationsStock","");
         /*if (cmp.get("v.isInProccess")) {
        	cmp.set("v.emptyProductStocks",true);
        }*/
	},
    
    getVariantStock: function(cmp, event, helper) {
        helper.getVariantStock(cmp,event, helper);      
    },



})