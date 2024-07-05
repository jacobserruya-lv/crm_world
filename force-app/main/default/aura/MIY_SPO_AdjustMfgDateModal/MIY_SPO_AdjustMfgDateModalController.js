({
    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    handleConfirmClick: function(component, event, helper) {
        component.set('v.confirmLoading', true);
        component.find('form').submit();
    },
    handleDateChange: function (component, event, helper) {
        // console.group(component.getType() + '.handleDateChange');
        if(component.get('v.scriptsLoaded')) {
            var baseMfgDate = moment(component.get('v.baseMfgDate'));
            var baseDeliveryDate = moment(component.get('v.baseDeliveryDate'));
            var newMfgDate = moment(event.getParam('value'));
            var deliveryDate = moment(baseDeliveryDate).add(newMfgDate.diff(baseMfgDate, 'days'), 'days');

            component.set('v.mfgDate', newMfgDate.format('YYYY-MM-DD'));
            component.set('v.deliveryDate', deliveryDate.format('YYYY-MM-DD'));
        }
        // console.groupEnd();
    },
    scriptsLoaded: function (component, event, helper) {
        // console.group(component.getType() + '.scriptsLoaded');
        component.set('v.scriptsLoaded', true);
        // console.groupEnd();
    },
    onSaveInfoSuccess: function (component, event, helper) {
        var oldData = component.get('v.record');
        helper.apexActionPromise(component, 'c.getOrder', {orderId: component.get('v.record.Id')})
            .then($A.getCallback(function (result) {
                component.set('v.record', result);
                var updateOrderEvent = $A.get('e.c:MIY_FirmOrderUpdate');
                updateOrderEvent.setParams({
                    'objectId': result.Id,
                    'oldData': oldData,
                    'newData': result,
                });
                updateOrderEvent.fire();
                component.find('modalOverlayLib').notifyClose();
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }))
            .finally($A.getCallback(function () {
                component.set('v.confirmLoading', false);
            }))
        ;

    },
    onSaveInfoError: function (component) {
        component.set('v.confirmLoading', false);
    },
})