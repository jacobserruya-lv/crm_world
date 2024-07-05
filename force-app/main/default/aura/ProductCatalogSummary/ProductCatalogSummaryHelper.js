({
	
	getProductSettings: function(cmp, helper) {
		var action = cmp.get('c.getProductSettings');
    	action.setCallback(this, function(result) { 
    		var state = result.getState();
            if(state === "SUCCESS"){ 
                var resultSettings = result.getReturnValue();
                cmp.set('v.productSettings', resultSettings);
            }
            else if(state === "ERROR"){
                helper.hanldeError(result);
            } 
            else {
                console.error("Unknown error");
            }
    	});
    	$A.enqueueAction(action);
	},
	
	handleError: function(result) {
		var errors = result.getError();
        if(errors){
            if(errors[0] && errors[0].message){
                console.error('Error Message: ' + errors[0].message);
            }
        }
	},
	
	showSpinner : function(cmp) {
        cmp.set("v.toggleSpinner", true);  
    },
    
    
    hideSpinner : function(cmp) {
        cmp.set("v.toggleSpinner", false);
    },
    
    handleSpinner: function(cmp, helper, show) {
        if(show) {
            helper.showSpinner(cmp);
            cmp.set('v.productVariations ',[]);
        }
        else
        {
            helper.hideSpinner(cmp)
        }
    	//show ? helper.showSpinner(cmp) : helper.hideSpinner(cmp);
        //show ? cmp.set('v.productVariations ',[]) : '';
    },
    
    getVariantStock: function(cmp, event, helper) {
        cmp.set("v.searchVariationStock",true);
        /*var myProductEvent = $A.get('e.c:ProductCatalogVariantionProductEvent');
        myProductEvent.setParams({ 'product' : cmp.get('v.product')});
        myEvent.fire();*/
        var selectedStores = cmp.get("v.selectedStores");
        var productVariations = cmp.get("v.productVariations");
        var productsSku = productVariations.VariantSKU;
        var action = cmp.get('c.getProductsAvailabilitiesByProductId');
        action.setStorable();
        action.setParams({
      		'stores': selectedStores,
            'products': productsSku,
    	});
 
        action.setCallback(this, function(result) { 
        	var state = result.getState();
            //helper.hideSpinner(cmp);
            if(state === 'SUCCESS'){ 
                var pageResult = result.getReturnValue();
                // console.log('pageResult variant' , pageResult);
                if (pageResult == null) {
                    //cmp.set('v.wsError', true);
                    //cmp.set('v.errorCode' ,'unknown'); 
                    //helper.clearProductSummary();
                    //cmp.set('v.selectedProduct', {});
                }
                else if (pageResult['ERROR']) {
                    console.error('myError is ', pageResult['ERROR'][0].errorCode);
                    //cmp.set('v.wsError', true);
                    //cmp.set('v.errorCode' ,pageResult['ERROR'][0].errorCode); 
                    //helper.clearProductSummary();
                    //cmp.set('v.selectedProduct', {});
                }
                else
                {
                    // console.log('setting pageResult');
                    cmp.set('v.productVariationsStock', pageResult);
                    //console.log('productVarStock ' , cmp.get('v.productVariationsStock'));
                    var myEvent = $A.get('e.c:ProductCatalogVariantStockEvent');
                    myEvent.setParams({ 'productVariationsStock' : pageResult});
                    myEvent.fire();
                }
            } 
            else if(state === 'ERROR'){
               helper.hanldeError(result);
            } 
            else {
                console.error('Unknown error');
            }
            //cmp.set('v.isInProccess', false);
            //cmp.set("v.emptyProductStocks", false);
            cmp.set("v.searchVariationStock",false);
    	});
        $A.enqueueAction(action);
        
        
    }
    
})