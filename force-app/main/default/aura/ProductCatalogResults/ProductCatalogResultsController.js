({
	getResults : function(cmp, event, helper) {
        var total = event.getParam('total');
        var searchKey = event.getParam('searchKey');
        var selectedProduct = event.getParam('selectedProduct') ? event.getParam('selectedProduct'): [];
        cmp.set('v.total',total);
        cmp.set('v.searchKey', searchKey);
        cmp.set('v.selectedProduct', selectedProduct);
        
	},
    
    itemClicked: function(cmp, event,helper) {
    	var selectedProduct = event.getParam('product');
        cmp.set('v.selectedProduct' , selectedProduct);
    	
    }
})