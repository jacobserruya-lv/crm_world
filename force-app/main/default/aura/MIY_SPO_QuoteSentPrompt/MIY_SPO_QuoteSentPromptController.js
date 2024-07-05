({
    doInit: function (component) {
        // console.group('MIY_SPO_QuoteSentPrompt.doInit');
        // console.log(component.get('v.workshopName'));
        // console.groupEnd();
    },

    handleContinueClick: function (component) {
        // console.group('MIY_SPO_QuoteSentPrompt.handleContinueClick');
        component.set('v.isLoading',true);
        var action = component.get('c.updateSPOStage');
        action.setParams({opp: component.get('v.record')});
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.group('MIY_OrderPageController.updateSPOStage');
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
                var errors = response.getError();
                // console.log(errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error($A.get('$Label.c.MIY_OrderPage_Error') + errors[0].message);
                    }
                } else {
                    console.error($A.get('$Label.c.MIY_OrderPage_Unknown_Error'));
                }
                component.set('v.isLoading', false);
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
        // console.groupEnd();
    },
});