({
    doInit: function (component, event, helper) {
        // console.group(component.getType() + '.doInit');

        component.set('v.today', (new Date()).toISOString());
        helper.apexActionPromise(component, 'c.getOrder', {orderId: component.get('v.record.Id')})
            .then(
                $A.getCallback(function(result) {
                    component.set('v.record', result);
                    if (result.SPO_SpecialOrderSKUCodeRef__r != null) {
                        component.find('autocomplete').set('v.inputValue', result.SPO_SpecialOrderSKUCodeRef__r.SKUCode__c);
                        component.set('v.skuLookupName', result.SPO_SpecialOrderSKUCodeRef__r.Name);
                    }
                })
            )
            .catch($A.getCallback(function() {}));
        // console.groupEnd();
    },

    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    saveInfo: function (component, event, helper) {
        // console.group(component.getType() + '.saveInfo');
        // Start MIY-1583 By Neta
        if (!component.get('v.erpCheck')) {
            helper.showError(component, $A.get("$Label.c.MIY_OrderPage_Send_To_ERP_Required"));
            return;
        }
        component.set('v.confirmLoading', true);
        var addInfoForm = component.find('addInfoForm');
        addInfoForm.submit();
        // console.groupEnd();
    },
    onSaveInfoSuccess: function (component) {
        // console.group(component.getType() + '.onSaveInfoSuccess');
        var orderId = component.get('v.record.Id');
       // var action = component.get('c.getOrder');
       //MIY - 1626 by Avigail
        var action = component.get('c.updateStageToInProgress');
        action.setParams({orderId: orderId});
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.getOrder', orderId);

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

    // MIY-1583 By Neta
    handleSendToErpChange: function (component, event, helper) {
        var erpCheck = event.getParam('checked');

        component.set('v.erpCheck', erpCheck);
        if (erpCheck) {
            helper.hideError(component);
        }
    },

});