({
    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    handleConfirmClick: function (component, event, helper) {
        // console.group(component.getType() + '.handleConfirmClick');
        component.set('v.confirmLoading', true);
        helper.updateSPOStage(component, helper, component.get('v.record'), function () {
            component.set('v.confirmLoading', false);
            component.find('modalOverlayLib').notifyClose();
        }, function () {
            component.set('v.confirmLoading', false);
        });
        // console.groupEnd();
    },
    handleConfirmMandatory: function (component) {
        // console.group(component.getType() + '.handleConfirmMandatory');
        var confirmed = component.get('v.depositMandatoryConfirmed');
        component.set('v.depositMandatoryConfirmed', !confirmed);
        // console.groupEnd();
    },

});