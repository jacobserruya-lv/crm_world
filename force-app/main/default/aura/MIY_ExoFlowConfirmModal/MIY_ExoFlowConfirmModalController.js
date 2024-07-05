({
    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    handleConfirmClick: function (component, event, helper) {
        // console.group(component.getType() + '.handleConfirmClick');
        component.set('v.confirmLoading', true);
        var oldData = component.get('v.firmOrder');
         if(oldData.ProductCatalogue__r.ReportingCategory__c!= null && oldData.ProductCatalogue__r.ReportingCategory__r.Exotic_Workflow__c == true){
        helper.apexActionPromise(component, 'c.progressExoMatWorkflow', {firmOrder: oldData})
        //helper.apexActionPromise(component, 'c.progressHardsidedWorkflow', {firmOrder: oldData})
            .then($A.getCallback(function (result) {
                component.set('v.firmOrder', result);
                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                updateOrderEvent.setParams({
                    'objectId': result.Id,
                    'oldData': oldData,
                    'newData': result,
                });
                updateOrderEvent.fire();
                component.find('modalOverlayLib').notifyClose();
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }))
            .finally($A.getCallback(function () {
                component.set('v.confirmLoading', false);
            }))
        }
        else{
            //handleConfirmClickHardsided(component, event, helper);
            component.set('v.confirmLoading', true);
            var oldData = component.get('v.firmOrder');
            if(oldData.TECH_Product_Hard_Workflow__c == true){
            
            helper.apexActionPromise(component, 'c.progressHardsidedWorkflow', {firmOrder: oldData})
                .then($A.getCallback(function (result) {
                    component.set('v.firmOrder', result);
                    var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                    updateOrderEvent.setParams({
                        'objectId': result.Id,
                        'oldData': oldData,
                        'newData': result,
                    });
                    updateOrderEvent.fire();
                    component.find('modalOverlayLib').notifyClose();
                }))
                .catch($A.getCallback(function (e) {
                    console.error(e);
                }))
                .finally($A.getCallback(function () {
                    component.set('v.confirmLoading', false);
                }))
    
        }

        }
        
        ;
    },
    handleConfirmClickHardsided: function (component, event, helper) {
        component.set('v.confirmLoading', true);
        var oldData = component.get('v.firmOrder');
        if(oldData.ProductCatalogue__r.Workflow__c == true){
        
        helper.apexActionPromise(component, 'c.progressHardsidedWorkflow', {firmOrder: oldData})
            .then($A.getCallback(function (result) {
                component.set('v.firmOrder', result);
                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                updateOrderEvent.setParams({
                    'objectId': result.Id,
                    'oldData': oldData,
                    'newData': result,
                });
                updateOrderEvent.fire();
                component.find('modalOverlayLib').notifyClose();
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }))
            .finally($A.getCallback(function () {
                component.set('v.confirmLoading', false);
            }))

    }}
});