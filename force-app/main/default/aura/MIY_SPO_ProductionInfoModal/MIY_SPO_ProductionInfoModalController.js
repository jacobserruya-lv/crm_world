({
    doInit: function (component, event, helper) {
        // console.group(component.getType() + '.doInit');

        component.set('v.today', (new Date()).toISOString());

        // console.groupEnd();
    },

    onFormLoad: function (component) {
        var record = component.get('v.record');
        if (record.SPO_SpecialOrderSKUCodeRef__r != null) {
            component.find('autocomplete').set('v.inputValue', record.SPO_SpecialOrderSKUCodeRef__r.SKUCode__c);
            component.set('v.skuLookupName', record.SPO_SpecialOrderSKUCodeRef__r.Name);
        }
    },
    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    editInfo: function (component) {
        // console.group(component.getType() + '.editInfo');
        component.set('v.editMode', true);
        // console.groupEnd();
    },
    cancelEditInfo: function (component) {
        // console.group(component.getType() + '.cancelEditInfo');
        component.set('v.editMode', false);
        // console.groupEnd();
    },
    saveInfo: function (component) {
        // console.group(component.getType() + '.saveInfo');
        component.set('v.isSaving', true);
        var quoteEditForm = component.find('quoteEditForm');
        quoteEditForm.submit();
        // console.groupEnd();
    },
    onSaveInfoSuccess: function (component) {
        // console.group(component.getType() + '.onSaveInfoSuccess');
        var orderId = component.get('v.record.Id');
        var action = component.get('c.getOrder');
        action.setParams({orderId: orderId});
        action.setCallback(this, function (response) {
            // console.group(component.getType() + '.c.getOrder', orderId);

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
    onSaveInfoError: function (component) {
        component.set('v.confirmLoading', false);
    },

    handleConfirmMandatory: function (component) {
        // console.group(component.getType() + '.handleConfirmMandatory');
        var confirmed = component.get('v.depositMandatoryConfirmed');
        component.set('v.depositMandatoryConfirmed', !confirmed);
        // console.groupEnd();
    },

    handleFileUploadFinished: function (component) {
        var fileUploadEvent = $A.get('e.c:MIY_FileUpload');
        fileUploadEvent.setParams({'recordId': component.get('v.record.Id')});
        fileUploadEvent.fire();
    },

    handleAutocompleteChange: function (component, event, helper) {
        // console.group(component.getType() + '.handleAutocompleteChange');
        var searchSku = event.getParam('value');
        if (searchSku == null) {
            component.set('v.skuLookupId', null);
            component.set('v.skuLookupName', null);
        } else if (searchSku.length > 2) {
            var autocompleteCmp = event.getSource();
            autocompleteCmp.set('v.spinnerActive', true);
            helper.apexActionPromise(component, 'c.findProductBySku', {sku: searchSku})
                .then($A.getCallback(function (result) {
                    component.set('v.skuLookupOptions', result);
                }))
                .finally($A.getCallback(function () {
                    autocompleteCmp.set('v.spinnerActive', false);
                }));
        }
        // console.groupEnd();
    },
    handleAutocompleteSelect: function (component, event) {
        // console.group(component.getType() + '.handleAutocompleteSelect');
        var productReferential = event.getParam('value');
        event.getSource().set('v.inputValue', productReferential.SKUCode__c);
        component.set('v.skuLookupId', productReferential.Id);
        component.set('v.skuLookupName', productReferential.Name);
        // console.groupEnd();
    },
});