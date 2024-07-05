({
    markRecieved: function (component, event, helper) {
        console.group(component.getType() + '.h.markRecieved');
        console.log('itemData:', Object.assign({},component.get('v.itemData')));

        var action = component.get('c.SPO_updateFirmOrders');
        var orderId = component.get('v.itemData.SPO_BriefName__c');
        action.setParams({orderId: orderId});

        action.setCallback(this, function (response) {
            console.group(component.getType() + '.c.SPO_updateFirmOrders', orderId);

            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('oldData:', component.get('v.order'));
                console.log('response:', response.getReturnValue());

                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                // console.log('updateOrderEvent',updateOrderEvent);
                updateOrderEvent.setParams({
                    'objectId': orderId,
                    'oldData': component.get('v.order'),
                    'newData': response.getReturnValue(),
                });
                updateOrderEvent.fire();
                component.set('v.loading', false);

                component.find('spo-received-modal__overlay-lib').notifyClose();
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                var errorList = [];
                errors.forEach(function(err) {
                    if (err.message) {
                        errorList.push({
                            title:  helper.formatLabel($A.get('$Label.c.MIY_OrderPage_Error'),''),
                            message: errors[0].message,
                        });
                        console.error(helper.formatLabel($A.get('$Label.c.MIY_OrderPage_Error'), errors[0].message));
                    } else if (err.pageErrors) {
                        err.pageErrors.forEach(function (pageError) {
                            errorList.push({title: pageError.statusCode, message: pageError.message});
                            console.error(pageError.statusCode + ': ' + pageError.message);
                        });
                    }
                });
                component.set('v.errors', errorList);
                component.set('v.loading', false);
            }
            console.groupEnd();
        });
        $A.enqueueAction(action);
        console.groupEnd();
    },
})