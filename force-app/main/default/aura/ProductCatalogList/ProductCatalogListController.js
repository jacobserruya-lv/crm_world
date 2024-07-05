({
    doInit: function(cmp, event, helper) {
        helper.getInitData(cmp, event, helper);
    },
    filterChange: function(cmp, event, helper) {
        // console.group('--ProductCatalogListController.filterChange--');
        var searchKey = event.getParam("searchKey") || '';
        var advencedSearch = event.getParam("advencedSearch"); 
        var selectedStores = event.getParam("selectedStores") || [];
        var digitalStore = event.getParam("digitalStore");
        var selectedWarehouses = event.getParam("selectedWarehouses") || [];
        var selectedZone = event.getParam("selectedZone") || [];
        //console.log('selectedZone', selectedZone);
        //console.log('selectedWarehouses in LIst', selectedWarehouses);
    	cmp.set("v.selectedStores", selectedStores);
        cmp.set("v.selectedWarehouses", selectedWarehouses);
        cmp.set("v.selectedZone", selectedZone);
        cmp.set("v.digitalStore", digitalStore);
        cmp.set("v.searchKey", searchKey);
        cmp.set('v.advencedSearch', advencedSearch);
    	cmp.set("v.productsStock",'');
        cmp.set("v.productsPrices",'');
        cmp.set("v.productVariations",[]);
        cmp.set("v.page", 1);
        cmp.set("v.products",[]);
        cmp.set("v.selectedProduct",{});
        cmp.set("v.itemClickedStock",[]);
        if (cmp.get("v.isInProccess")) {
        	cmp.set("v.emptyProductStocks",true);
        }
        if(searchKey != '') {
        	helper.getProducts(cmp, event, helper, 1, searchKey, advencedSearch);
        }
        else {
            var myEvent = $A.get('e.c:ProductCatalogSearchEvent');
            myEvent.setParams({ 'searching': false});
            myEvent.fire();
            var resultsEvent = $A.get('e.c:ProductCatalogGetResultsEvent');
            resultsEvent.fire();
        }
        // console.groupEnd();
	},
	
	updateSelectedStores: function(cmp, event, helper) {
        //console.group('--ProductCatalogListController.updateSelectedStores--');

        var selectedStores = event.getParam('selectedStores');
        var selectedWarehouses = event.getParam('selectedWarehouses');
        var selectedZone = event.getParam('selectedZone');
		cmp.set("v.selectedStores", selectedStores);
        cmp.set("v.selectedWarehouses", selectedWarehouses);
        cmp.set("v.selectedZone", selectedZone);
        cmp.set("v.selectedProduct", "");
        cmp.set("v.productsStock","");
        cmp.set("v.itemClickedStock","");
         if (cmp.get("v.isInProccess")) {
        	cmp.set("v.emptyProductStocks",true);
        }
         //console.groupEnd();
    },

    pageChange: function(cmp, event, helper) {
        // console.group('--ProductCatalogListController.pageChange--');
        var page = cmp.get("v.page") || 1;
        var direction = event.getParam("direction");
        //page = direction === "previous" ? (page - 1) : (page + 1);
        switch(direction) {
            case "previous":
                page = page - 1;
                break;
            case "next":
                page = page + 1;
                break;
            case "first":
                page = 1;
                break;
            case "last":
                page = cmp.get('v.pages');
            default:
            // code block
        }

        cmp.set("v.page", page);
        cmp.set("v.productsStock",'');
        cmp.set("v.itemClickedStock",'');
        cmp.set("v.productVariations",'');
         
        var myEvent = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
        myEvent.setParams({ 
        	'product': null, 
            'productsStock': '',
        });
        myEvent.fire();
        
        helper.getProducts(cmp, event, helper, page, cmp.get('v.searchKey'), cmp.get('v.advencedSearch'));
        // console.groupEnd();
    },
	
	showSpinner : function(cmp, event, helper) {
        helper.showSpinner(cmp);
    },
    
    hideSpinner : function(cmp, event, helper) {
        helper.hideSpinner(cmp);
    },
    
	itemClicked: function(cmp, event, helper) {
        helper.itemClicked(cmp, event, helper);
    },
    
    getStock : function(cmp,event,helper) {
        helper.hideError(cmp);
        //not implemented - since calling 3 ws at once
       // helper.getStock(cmp, event, helper);
    },
    
    closeWsError: function(cmp, event,helper) {
       cmp.set("v.wsError", false); 
    },  
    
    updateVariantStock: function(cmp, event, helper) {
        var productVariationsStock = event.getParam("productVariationsStock"); 
        cmp.set('v.productVariationsStock', productVariationsStock);
    },

    getDigitalStore: function(cmp, event, helper) {
        var digitalStore = event.getParam("digitalStore");
        cmp.set('v.digitalStore', digitalStore);
    },

    /*updateSelectedWarehouses: function(cmp, event, helper) {
        var selectedWarehouses = event.getParam('selectedWarehouses');
        cmp.set('v.selectedWarehouses', selectedWarehouses);
    },*/
    
    updateFavoriteList: function(cmp,event,helper){
        if(event.getParam('src') == 'displayFavorites'){
            event.stopPropagation();
            cmp.set('v.myFavorites',event.getParam('myFavorites'));
        }
    },
})