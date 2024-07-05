({
    getProducts: function (component, page) {
        setTimeout(function () {  // MIY-2151
            var action = component.get("c.findAll");
            var pageSize = component.get("v.pageSize");
            console.log(component.get("v.obsolete"));
            action.setParams({
                "searchKey": component.get("v.searchKey"),
                "category": component.get("v.category"),
                "obsolete": component.get("v.obsolete"),
                "pageSize": pageSize,
                "pageNumber": page || 1
            });
            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    var result = a.getReturnValue();
                    component.set("v.products", result.products);
                    component.set("v.page", result.page);
                    component.set("v.total", result.total);
                    component.set("v.pages", Math.ceil(result.total / pageSize));
                    component.set("v.productsStoreAvailabilities", result.productsStoreAvailabilities);
                } else if (state === "INCOMPLETE") {
                    console.log("Action is not complete ");
                } else if (state === "ERROR") {
                    var errors = a.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error Message: " + errors[0].message);
                        }
                    }
                } else {
                    console.log("Unknown error");
                }
            });
            $A.enqueueAction(action);
        }, 600);  // MIY-2151 End 
    },

    getProductSettings: function (component) {
        var action = component.get("c.getProductSettings");

        action.setParams({});
        action.setCallback(this, function (a) {
            var result = a.getReturnValue();
            console.log("productsettings tilelist", result);
            component.set("v.productSettings", result);
        });
        $A.enqueueAction(action);
    }

})