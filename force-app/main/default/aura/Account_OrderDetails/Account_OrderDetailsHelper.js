({
    getOrderLineDetails : function(component, event, helper) {

        
        var orderNumber="";
        var isRecordId = false;

        if(!$A.util.isEmpty(component.get("v.recordId"))){
            orderNumber = component.get("v.recordId");
            isRecordId = true;
        }
        else if(!$A.util.isEmpty(component.get("v.pageReference"))){
            var myPageRef = component.get("v.pageReference");
           orderNumber = myPageRef.state.c__orderNumber;
        }
        
        component.set('v.orderNumber', orderNumber);

        var action = component.get("c.getOrderDetails");
        action.setParams({
            'orderId' : component.get("v.orderNumber"),
            'isRecordId' : isRecordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // check if it not null
                var skuList = [];
                if(result.StatusCode == '200'){
                    result.orderLines.forEach(element =>{ element.statusHistory.reverse();
                                                            skuList.push(element.SKU);
                                                        });
                    component.set("v.details", result);  
                    helper.getOrderDetails(component ,result);
                    helper.skuProductMap(component, skuList);
                    helper.getStoreType(component, result.store.Id);
                }else {
                    component.set("v.message",result.StatusCode);  
                }
            }else if (state === "ERROR"){
                component.set("v.message","500");  
            }

        });
        $A.enqueueAction(action);
        
    },
    getOrderDetails : function(component,orderDetails) {
        //console.log("orderDetails", orderDetails);
        var order ={
            OrderId: orderDetails.OrderId,
            store: orderDetails.store,
            date: orderDetails.date,
            account:orderDetails.account
        };

        component.set("v.orderDetail", order);  


    },
    skuProductMap : function(component, skuList){
        var action = component.get("c.getProductMap");
        action.setParams({
            'SKUList' : skuList,
        });

        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            //DO SOMETHING
            component.set("v.productSKU", response.getReturnValue());
        }
        else {
            console.log("Failed with state: " + state);
        }
        });
        $A.enqueueAction(action);
    },
    getStoreType: function(component, storeId){
        var action = component.get("c.getStoreType");
        action.setParams({
            'storeId' : storeId,
        });

        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            //DO SOMETHING
            component.set("v.storeType", response.getReturnValue());
        }
        else {
            console.log("Failed with state: " + state);
        }
        });
        $A.enqueueAction(action);
    },
    isBackOfficeUser: function(component, event, helper){

        var action = component.get("c.backOfficeUser");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.backOffice", result);  
            }
        });
        $A.enqueueAction(action);
    },

    getPicklistShipping: function(component, event, helper){

        var action = component.get("c.reasonPicklist");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.picklistShipping",  result);  
            }
        });
        $A.enqueueAction(action);
    },
    getActionPicklist: function(component, event, helper){

        helper.callServer(component, "c.actionPicklist",
            function(response){
                if(response){
                    var action = [];
                    for(let key in response){ 
                        if(response.hasOwnProperty(key)){
                                action.push({'value':key , 'label':response[key]});
                        }
                    } 
                    component.set("v.picklistAction", action);
                }
        }) 
    },

    callServer : function(component, method, callback, params) {
        var action = component.get(method);
        
        //Set params if any
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {

                    if (errors[0] && errors[0].message) {
                       console.error("Error" + errors[0].message);
                    }
                } else {
                    console.error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    }
    

})