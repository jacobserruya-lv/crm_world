({
    loadPurchasedProduct : function (component, page) {

        var pageSize = component.get("v.pageSize");

        var action = component.get("c.getPurchasedProductList");
        action.setStorable();
        action.setParams({
            "accountId" : component.get("v.recordId"),
            "pageSize": pageSize,
            "pageNumber": page || 1
        });
        action.setCallback(this, function (response) {
            /*var result = response.getReturnValue();
            console.log('result ppr', result);
            component.set("v.items", result);*/
			var result = response.getReturnValue();
            component.set("v.items", result.purchasedProductList);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total/pageSize));
        });
        $A.enqueueAction(action);
    }
})