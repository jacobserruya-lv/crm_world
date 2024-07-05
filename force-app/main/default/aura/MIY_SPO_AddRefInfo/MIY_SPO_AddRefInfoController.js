({
    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    saveRefInfo: function (component) {
        // console.group('MIY_SPO_AddRefInfo.saveRefInfo');
        component.set('v.confirmLoading', true);
        var addRefInfoForm = component.find('addRefInfoForm');
        // component.find('inputField').forEach(function (cmp) {
        //     cmp.set('v.class', cmp.get('v.class').replace('slds-has-error', '').trim());
        // });
        // console.log(addRefInfoForm, addRefInfoForm.get('v.recordId'), addRefInfoForm.get('v.fields'));
        addRefInfoForm.submit();
        // console.groupEnd();
    },
    onSaveRefInfoSuccess: function (component) {
        // console.group('MIY_SPO_AddRefInfo.onSaveRefInfoSuccess');
        var orderId = component.get('v.record.Id');
        var action = component.get('c.getOrder');
        action.setParams({ orderId: orderId });
        action.setCallback(this, function (response) {
            // console.group('MIY_SPO_CreateQuotationModal.c.getOrder ' + orderId);

            var state = response.getState();
            if (state === 'SUCCESS') {
                // console.log('response:', response.getReturnValue());
                var oldData = component.get('v.record');
                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                updateOrderEvent.setParams({
                    'objectId': oldData.Id,
                    'oldData': oldData,
                    'newData': response.getReturnValue(),
                });
                updateOrderEvent.fire();
                component.set('v.confirmLoading', false);
                component.find('modalOverlayLib').notifyClose();
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error('Error message: ' + errors[0].message);
                    }
                } else {
                    console.error('Unknown error');
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
        // console.groupEnd();
    },
    onSaveRefInfoError: function (component) {
        // console.group('MIY_SPO_AddRefInfo.onSaveRefInfoError');
        component.set('v.confirmLoading', false);
        // component.find('inputField').forEach(function (cmp) {
        //     // console.log(cmp.get('v.fieldName'), cmp.get('v.value'));
        //     var className = cmp.get('v.class');
        //     if (cmp.get('v.value') == null || cmp.get('v.value') == '') {
        //         cmp.set('v.class', className + ' slds-has-error');
        //     }
        // });
        // console.groupEnd();
    },
    handleConfirmClick: function (component, event, helper) {
        component.set('v.confirmLoading', true);
        var orderObj = component.get('v.record');
        var action = component.get('c.updateSPOStage');
        action.setParams({ opp: orderObj });
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.updateSPOStage');
            var state = response.getState();
            component.set('v.confirmLoading', false);
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
                component.find('modalOverlayLib').notifyClose();
            } else if (state === 'ERROR') {
                helper.processErrors(component, helper, response.getError());
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
    },

});