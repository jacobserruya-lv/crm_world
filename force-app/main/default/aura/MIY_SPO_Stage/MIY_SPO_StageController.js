({
    doInit: function (component, event, helper) {
        // console.group('MIY_SPO_Stage.doInit');
        var dateField = component.get('v.status.dateField');
        var stageDate = component.get('v.record.' + dateField);
        component.set('v.stageDate', stageDate);

        // console.log(component.get('v.status'), component.get('v.status.pastValue'));
        var pastValueType = component.get('v.status.pastValueType');
        var pastValue = component.get('v.status.pastValue');

        var callback = function(newCmp, status, errorMessage) {
            if (status === 'SUCCESS') {
                var content = component.get('v.pastValueContent');
                content.push(newCmp);
                component.set('v.pastValueContent', content);
            }
            else if (status === 'INCOMPLETE') {
                console.error('No response from server or client is offline.');
                // Show offline error
            }
            else if (status === 'ERROR') {
                console.error('Error: ' + errorMessage);
                // Show error message
            }
        };
        switch (pastValueType) {
            case 'date':
                $A.createComponent('ui:outputDate', {value: pastValue}, callback);
                break;
            case 'currency':
                $A.createComponent('lightning:formattedNumber',
                    {
                        style: 'currency',
                        value: pastValue,
                        currencyCode: component.get('v.record.SPO_Store__r.Currency__c'),
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 0,
                    },
                    callback
                );
                break;
            default:
                $A.createComponent('lightning:formattedText', {value: pastValue}, callback);
                break;
        }

        component.set('v.dateCreated', new Date(component.get('v.record.CreatedDate')));
        var dateQuotationInProgress = new Date(component.get('v.record.SPO_Date_Quotation_in_progress__c'));
        var now = new Date();
        dateQuotationInProgress.setHours(now.getHours(),now.getMinutes(),now.getSeconds());
        component.set('v.dateQuotationInProgress', dateQuotationInProgress);
        // console.groupEnd();
        helper.warningMsg(component,helper);
        
    },
    handleC2AAction: function (component, event, helper) {
        // console.group('MIY_SPO_Stage.onCallToActionClick');
        var actionType = component.get('v.status.c2aActionType');
        var actionData = component.get('v.status.c2aActionData');

        helper.selectAction(component, helper, actionType, actionData);
        // console.groupEnd();
    },
    handleAltAction: function (component, event, helper) {
        // console.group('MIY_SPO_Stage.onCallToActionClick');
        var actionType = component.get('v.status.altActionType');
        var actionData = component.get('v.status.altActionData');

        helper.selectAction(component, helper, actionType, actionData);
        // console.groupEnd();
    },
    handleUpdateEvent: function (component, event) {
        component.set('v.record', event.getParam('newData'));
    },
    handleCancelClick: function (component, event, helper) {
        helper.selectAction(component, helper, 'modal', 'MIY_SPO_CancelModal');
    },
});