({
    doInit: function (component, event, helper) {
        // console.group(component.getType() + '.doInit');
        helper.apexActionPromise(component, 'c.isDebugMode')
            .then($A.getCallback(function (result) {
                component.set('v.isDebugMode', result);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));

        helper.apexActionPromise(component, 'c.getExoLeatherOptions',
            {genericSku: component.get('v.record.ProductCatalogue__r.Generic_SKU__c')})
            .then(
                $A.getCallback(function(result) {
                    // console.group(component.getType() + '.c.getExoLeatherOptions.then', result);
                    component.set('v.exoLeatherOptions', result);
                    // console.groupEnd();
                })
            )
            .catch($A.getCallback(function(e) {
                console.error(e);
            }));
        // console.groupEnd();
    },
    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },

    handleConfirmClick: function (component, event, helper) {
        // console.group(component.getType() + '.handleConfirmClick');
        component.set('v.confirmLoading', true);
        var firmOrder = component.get('v.record');
        helper.apexActionPromise(component, 'c.setFirmOrderExoLeatherProduct',
            {
                productId: component.get('v.exoLeatherSelected'),
                firmOrder: firmOrder,
                fluidRecipeId: component.get('v.fluidRecipeId'),
            })
            .then(
                $A.getCallback(function(result) {
                    component.set('v.record', result);
                    var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                    updateOrderEvent.setParams({
                        'objectId': firmOrder.Id,
                        'oldData': firmOrder,
                        'newData': result,
                    });
                    updateOrderEvent.fire();
                    component.find('modalOverlayLib').notifyClose();
                })
            )
            .catch($A.getCallback(function(e) {
                console.error(e);
            }))
            .finally($A.getCallback(function() {
                component.set('v.confirmLoading', false);
            }));
        // console.groupEnd();
    },
});