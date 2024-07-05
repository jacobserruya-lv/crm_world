({
    updateSPOStage: function(component, helper, orderObj, successCallback, errorCallback) {
        var action = component.get('c.updateSPOStage');
        action.setParams({opp: orderObj});
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.updateSPOStage');
            var state = response.getState();
            // console.log('state:', state);
            if (state === 'SUCCESS') {
                // console.log(response.getReturnValue());
                var oldData = orderObj;
                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                updateOrderEvent.setParams({
                    'objectId': oldData.Id,
                    'oldData': oldData,
                    'newData': response.getReturnValue(),
                });
                updateOrderEvent.fire();
                successCallback();
            } else if (state === 'ERROR') {
                helper.processErrors(component, helper, response.getError());
                errorCallback();
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
    },
})