({
    getHistories: function (component, firmOrderIds) {
        // console.group('MIY_FirmOrderList.h.getHistories');
        var action = component.get('c.getFirmOrdersHistory');
        action.setParam('firmOrderIds', firmOrderIds);
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.getFirmOrdersHistory');

            var state = response.getState();
            if (state === 'SUCCESS') {
                var historyMap = response.getReturnValue();
                component.set('v.historyMap', historyMap);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error($A.get('$Label.c.MIY_OrderPage_Error') + errors[0].message);
                    }
                } else {
                    console.error($A.get('$Label.c.MIY_OrderPage_Unknown_Error'));
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
        // console.groupEnd();
    },
});