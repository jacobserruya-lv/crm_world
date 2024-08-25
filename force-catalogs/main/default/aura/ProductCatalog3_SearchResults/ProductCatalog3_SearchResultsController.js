({

    // filterChange: function (cmp, event, helper) {
    //     helper.filterChange(cmp, event, helper);
    // },

    // updatePerPageAction: function (cmp, event, helper) {
    //     // console.group(cmp.getType() + '.updatePerPageAction');
    //     var newPageNumber = 1;
    //     cmp.set('v.currentPage', newPageNumber);
    //     var listSkus = component.get("v.productsSkusSearch");

    //     // helper.getProducts(cmp, event, helper, newPageNumber, cmp.get('v.searchTerm'));
    //     helper.getProductsCatalog(component, event, helper, newPageNumber, listSkus);

    //     // console.groupEnd();
    // },

    // updatePageNumber: function (cmp, event, helper) {
    //     var pageNumber = event.getParam('pageNumber');
    //     //console.log('pageNumber', pageNumber);
    //     cmp.set('v.currentPage', pageNumber);
    //     var listSkus = component.get("v.productsSkusSearch");
    //     // helper.getProducts(cmp, event, helper, pageNumber, cmp.get('v.searchTerm'));
    //     helper.getProductsCatalog(component, event, helper, pageNumber, listSkus);

    // },
    updateSelectedStores: function (cmp, event, helper) {
        var selectedStores = event.getParam('selectedStores');
        var selectedWarehouses = event.getParam('selectedWarehouses');
        var selectedZone = event.getParam('selectedZone');
        cmp.set("v.selectedStores", selectedStores);
        cmp.set("v.selectedWarehouses", selectedWarehouses);
        cmp.set("v.selectedZone", selectedZone);
        cmp.set("v.selectedProduct", "");
    },

    onDataReady: function (component, event, helper) {
        const listSkus = component.get('v.productsSkusSearch');
        console.log({ listSkus })
        helper.getProductsCatalog(component, event, helper, listSkus);
    }


})