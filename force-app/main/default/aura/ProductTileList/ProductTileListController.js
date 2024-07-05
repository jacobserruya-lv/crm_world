({
    doInit: function(component, event, helper) {
        helper.getProductSettings(component);
        helper.getProducts(component);
    },

    filterChange: function(component, event, helper) {
        component.set("v.searchKey", event.getParam("searchKey"));
        component.set("v.category", event.getParam("category"));
        component.set("v.obsolete", event.getParam("obsolete"));
        helper.getProducts(component);
	},

    pageChange: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        var direction = event.getParam("direction");
        page = direction === "previous" ? (page - 1) : (page + 1);
        helper.getProducts(component, page);
	},

    onProductSelected: function(component, event, helper) {

        var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.index; // Get its value i.e. the index

        var product = component.get("v.products")[index];
        console.log('product', product);

        // use for CSS (product selected style)
        component.set("v.product", product);

        var cmpEvent = component.getEvent("productEvent");                
        cmpEvent.setParams({
            "product": product
        });
        cmpEvent.fire();
    }
})