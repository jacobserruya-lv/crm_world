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
            var field = event.getSource().getLocalId();
            var newInputDate = moment(event.getParam('value'));
            
            if(field == 'mfg_date'){                
                var baseMfgDate = moment(component.get('v.baseMfgDate'));
                var baseDeliveryDate = moment(component.get('v.baseDeliveryDate'));
                var deliveryDate = moment(baseDeliveryDate).add(newInputDate.diff(baseMfgDate, 'days'), 'days');                
                component.set('v.mfgDate', newInputDate.format('YYYY-MM-DD'));
                component.set('v.deliveryDate', deliveryDate.format('YYYY-MM-DD'));
            }
            if(field == 'dlv_date'){
                component.set('v.deliveryDate', newInputDate.format('YYYY-MM-DD'));
            }
            
        }
        // console.groupEnd();
    },
    scriptsLoaded: function (component, event, helper) {
        // console.group(component.getType() + '.scriptsLoaded');
        component.set('v.scriptsLoaded', true);
        // console.groupEnd();
    },
    onSaveInfoSuccess: function (component, event, helper) {
        var oldOrder = component.get('v.record.SPO_BriefName__r');

        helper.apexActionPromise(component, 'c.getOrder', {orderId: component.get('v.record.SPO_BriefName__c')})
            .then($A.getCallback(function (result) {
                var updateOrderEvent = $A.get('e.c:MIY_OrderUpdate');
                updateOrderEvent.setParams({'oldData': oldOrder,'newData': result});
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