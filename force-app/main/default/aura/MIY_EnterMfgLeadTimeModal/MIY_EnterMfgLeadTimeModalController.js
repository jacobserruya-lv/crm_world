({
    handleConfirmClick: function (component, event, helper) {
        // console.group(component.getType() + '.handleConfirmClick');
        component.set('v.confirmLoading', true);
        var firmOrder = component.get('v.record');
        helper.apexActionPromise(component, 'c.setFirmOrderProductMfgLeadTime',
            {
                firmOrder: firmOrder,
                newLeadTime: component.get('v.LeadTimeManufacturing__c'),
            }, false, true)
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
                    $A.get('e.force:refreshView').fire();
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