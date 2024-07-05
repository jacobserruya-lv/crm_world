({
    doInit: function (component) {
        component.set('v.today', (new Date()).toISOString());
       
    },

    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    saveQuote: function (component) {
        component.set('v.confirmLoading', true);
        var quoteEditForm = component.find('quoteEditForm');
        quoteEditForm.submit();
        
    },
    onSaveQuoteSuccess: function (component) {
        var orderId = component.get('v.record.Id');
        var estimatedProductionTimeValidity = component.find('estimatedProductionTime').get("v.validity");
        var estimatedDistributionTimeValidity  = component.find('estimatedDistributionTime').get("v.validity");
        var productiveHoursValidity  = component.find('productiveHours').get("v.validity");
        var unitRetailPriceValidity  = component.find('unitRetailPrice').get("v.validity");
        var theoricRetailPriceValidity  = component.find('theoricRetailPrice').get("v.validity");
        var spo_CRSValidity  = component.find('spo_CRS').get("v.validity");
        if(estimatedProductionTimeValidity.valid && estimatedDistributionTimeValidity.valid && productiveHoursValidity.valid && unitRetailPriceValidity.valid && theoricRetailPriceValidity.valid &&spo_CRSValidity.valid){
        //var action = component.get('c.getOrder');
        var action = component.get('c.updateQuotationFields');
        //action.setParams({orderId: orderId});
        action.setParams({orderId: orderId,
            estimatedProductionTime:component.find('estimatedProductionTime').get("v.value"),
            estimatedDistributionTime:component.find('estimatedDistributionTime').get("v.value"),
            productiveHours:component.find('productiveHours').get("v.value"),
            unitRetailPrice:component.find('unitRetailPrice').get("v.value"),
            theoricRetailPrice:component.find('theoricRetailPrice').get("v.value"),
            spo_CRS:component.find('spo_CRS').get("v.value")});
        action.setCallback(this, function (response) {
            

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
        }
    
        
        );
        $A.enqueueAction(action);
}
        else{
            
            component.set('v.isNotCompleted',true);
            component.set('v.message',$A.get("$Label.c.Complete_the_required_fields"));
            component.set('v.confirmLoading', false);

        }
        // console.groupEnd();
    },

    handleConfirmMandatory: function (component) {
        // console.group('MIY_SPO_Stage.handleConfirmMandatory');
        var confirmed = component.get('v.depositMandatoryConfirmed');
        component.set('v.depositMandatoryConfirmed', !confirmed);
        // console.groupEnd();
    },

    handleFileUploadFinished: function (component) {
        var fileUploadEvent = $A.get('e.c:MIY_FileUpload');
        fileUploadEvent.setParams({'recordId': component.get('v.record.Id')});
        fileUploadEvent.fire();
    },

    onSaveQuoteError: function (component) {
        component.set('v.confirmLoading', false);
    },

});