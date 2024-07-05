({
    doInit : function(component, event, helper) {
        var orderline = component.get("v.OrderLine");
        if(orderline!=null){
            var ordershippingId = orderline.requestId;
            var shipment = component.get("v.shipments");
            if(shipment!=null) {
                //var fil = shipment.filter(el => el[0].request_id === ordershippingId.split('-')[0]);
                //if(fil.length > 0 && fil[0].length >0 ){
                //    component.set("v.tracking_number", fil[0][0].tracking_number);
                //    component.set("v.tracking_link", fil[0][0].tracking_link);
                //    component.set("v.carrier_name", fil[0][0].carrier_name);
                //    component.set("v.carrier_service", fil[0][0].carrier_service);
                //    component.set("v.delivery_status", fil[0][0].delivery_status);
                //    component.set("v.delivery_status_date", fil[0][0].delivery_status_date);
                var fil = shipment.filter(el => el.request_id === ordershippingId.split('-')[0]);
                if(fil.length > 0 && fil[0] != null ){
                    component.set("v.tracking_number", fil[0].tracking_number);
                    component.set("v.tracking_link", fil[0].tracking_link);
                    component.set("v.carrier_name", fil[0].carrier_name);
                    component.set("v.carrier_service", fil[0].carrier_service);
                    component.set("v.delivery_status", fil[0].delivery_status);
                    component.set("v.delivery_status_date", fil[0].delivery_status_date);
                }
            }
        }  
    },
    init : function(component, event, helper){
        var orderline = component.get("v.OrderLine");
        if(orderline!=null){
            var ordershippingId = orderline.requestId;
            var shipment = component.get("v.shipments");
            if(shipment!=null){
                // var fil = shipment.filter(el => el[0].request_id === ordershippingId.split('-')[0]);
                // if(fil.length > 0 && fil[0].length >0 ){
                //     component.set("v.tracking_number", fil[0][0].tracking_number);
                //     component.set("v.tracking_link", fil[0][0].tracking_link);
                //     component.set("v.carrier_name", fil[0][0].carrier_name);
                //     component.set("v.carrier_service", fil[0][0].carrier_service);
                //     component.set("v.delivery_status", fil[0][0].delivery_status);
                //     component.set("v.delivery_status_date", fil[0][0].delivery_status_date);
                // }


                //naomi fix 05/2023 --> the shipments we receive from the api is an list of item, not a list of list
                var fil = shipment.filter(el => el.request_id === ordershippingId.split('-')[0]);
                if(fil.length > 0 && fil[0]!=null ){
                    component.set("v.tracking_number", fil[0].tracking_number);
                    component.set("v.tracking_link", fil[0].tracking_link);
                    component.set("v.carrier_name", fil[0].carrier_name);
                    component.set("v.carrier_service", fil[0].carrier_service);
                    component.set("v.delivery_status", fil[0].delivery_status);
                    component.set("v.delivery_status_date", fil[0].delivery_status_date);
                }
            }
        }  
        
        var navService = component.find("navService");
        // Sets the route to /lightning/o/Account/home

        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
            }
        };
        component.set("v.pageReference", pageReference);

        var action = component.get("c.getCaseRecordTypeID");
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            pageReference.state.recordTypeId = response.getReturnValue();
        }
        else {
            console.log("Failed with state: " + state);
        }
        });
        $A.enqueueAction(action);


        // action = component.get("c.getProductMap");
        // action.setParams({
        //     'SKUList' : component.get("v.OrderLine.SKU"),
        // });
        // action.setCallback(this, function(response) {
        // var state = response.getState();
        // if (state === "SUCCESS") {
        //     //DO SOMETHING
        //     component.set("v.productSKU", response.getReturnValue());
        // }
        // else {
        //     console.log("Failed with state: " + state);
        // }
        // });
        // $A.enqueueAction(action);
       
    },
    refreshFocusedTab : function(component, event, helper) {

        var e = event.getParam('result');
        var myEvent = $A.get("e.c:ICX_RefreshOrderDetailsEvent");
        myEvent.setParams({
            "OrderNumber": component.get("v.OrderNumber"),
            "OrderDetails":e,

        });
        myEvent.fire();

    },
    openNewCaseHandler: function(component, event, helper){
        var navService = component.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = component.get("v.pageReference");
        var defaultFieldValues = {
            Shipping_group__c: component.get("v.OrderLine.requestId"),
            Product_Sku__c: component.get("v.skuProductMap")[component.get("v.OrderLine.SKU")],
            AccountId:component.get("v.accountId"),
            Country__c: component.get("v.storeCountry"),
            Transaction_Id__c:  component.get("v.OrderNumber"),
            //Origin_of_order__c: component.get("v.OrderNumber").substr(0,3) == 'nvo' ? 'Digital' : 'Retail',// "Retail",
            Origin_of_order__c: component.get("v.storeType") == 'Store' ?'Retail' :'Digital',
            Tracking_Number__c: component.get("v.tracking_number"),
            Status:'Back Office New'
         };
        pageReference.state.defaultFieldValues = component.find("pageRefUtils").encodeDefaultFieldValues(defaultFieldValues);
 
        event.preventDefault();
        navService.navigate(pageReference);
    }
})