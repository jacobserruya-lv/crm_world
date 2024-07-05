({
    doInit: function (component, event, helper) {
        // console.group(component.getType() + '.doInit');
        var action = component.get('c.getCancelReasonOptions');
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.getCancelReasonOptions');

            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.reasonOptions', response.getReturnValue());
            }
            else if (state === 'ERROR') {
                helper.processErrors(component, helper, response.getError());
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
        // console.groupEnd();
    },

    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },

    handleConfirmClick: function (component, event, helper) {
        component.set('v.confirmLoading', true);
        var action = component.get('c.cancelOrder');
        var opp = component.get('v.record');
        action.setParams({
            opp: opp,
            reason: component.get('v.reasonValue'),
            comment: component.get('v.commentValue'),
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.cancelOrder');
            var state = response.getState();
            // console.log('state:', state);
            if (state === 'SUCCESS') {
                console.log(response.getReturnValue());
                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                updateOrderEvent.setParams({
                    'objectId': opp.Id,
                    'oldData': opp,
                    'newData': response.getReturnValue(),
                });
                updateOrderEvent.fire();
                component.find('modalOverlayLib').notifyClose();
            } else if (state === 'ERROR') {
                helper.processErrors(component, helper, response.getError());
                component.set('v.confirmLoading', false);
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
    },

});