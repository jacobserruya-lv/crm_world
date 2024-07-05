({
    getOrders : function (component, page) {
        console.log("getOrders");
        var pageSize = component.get("v.pageSize");

        var action = component.get("c.getOrderLineList");
        action.setParams({
            "accountId" : component.get("v.recordId"),
            "pageSize": pageSize,
            "pageNumber": page || 1
        });
        action.setCallback(this, function (response) {
			var result = response.getReturnValue();
            component.set("v.lines", result.orderLineList);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total/pageSize));
            console.log("result", result);
        });
        $A.enqueueAction(action);
    }

})