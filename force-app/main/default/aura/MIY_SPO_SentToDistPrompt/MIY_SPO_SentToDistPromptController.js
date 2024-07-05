({
    doInit: function (component) {
        // console.group(component.getType() + '.doInit');
        // console.log(component.get('v.workshopName'));
        // console.groupEnd();
    },

    handleContinueClick: function (component, event, helper) {
        // console.group(component.getType() + '.handleContinueClick');
        component.set('v.isLoading', true);
        var action = component.get('c.updateSPOStage');
        action.setParams({opp: component.get('v.record')});
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + 'c.updateSPOStage');
            var state = response.getState();
            // console.log('state:', state);
            if (state === 'SUCCESS') {
                // console.log(response.getReturnValue());
                var oldData = component.get('v.record');
                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                updateOrderEvent.setParams({
                    'objectId': oldData.Id,
                    'oldData': oldData,
                    'newData': response.getReturnValue(),
                });
                updateOrderEvent.fire();

                component.find('modalOverlayLib').notifyClose();
            } else if (state === 'ERROR') {
                helper.processErrors(component, helper, response.getError());
            }
            component.set('v.isLoading', false);
            // console.groupEnd();
        });
        $A.enqueueAction(action);
        // console.groupEnd();
    },
});