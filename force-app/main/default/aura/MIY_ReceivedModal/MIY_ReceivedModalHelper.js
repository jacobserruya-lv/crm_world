({
    markRecieved: function (component, event, helper) {
        var action = component.get('c.updateFirmOrder');
        var itemId = component.get('v.itemData.Id');
        action.setParams({firmOrderId: itemId});

        action.setCallback(this, function (response) {
            // console.group(component.getType() + '.c.updateFirmOrder', itemId);

            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('oldData:', component.get('v.itemData'));
                console.log('response:', response.getReturnValue());

                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                console.log('updateOrderEvent',updateOrderEvent);
                
                updateOrderEvent.setParams({
                    'objectId': itemId,
                    'oldData': component.get('v.itemData'),
                    'newData': response.getReturnValue(),
                });
                updateOrderEvent.fire();
                component.set('v.loading', false);

                component.find('overlayLib').notifyClose();
                console.log('overlayLib',component.find('overlayLib'));
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
            // console.groupEnd();
        });
        $A.enqueueAction(action);

    },
    formatLabel: function(string) {
        var outerArguments = arguments;
        return string.replace(/{(\d+)}/g, function() {
            return outerArguments[parseInt(arguments[1]) + 1];
        });
    },

});