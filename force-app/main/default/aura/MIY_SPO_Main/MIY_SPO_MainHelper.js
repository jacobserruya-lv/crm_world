({
    getStatuses: function (component, event, helper) {
        // console.group('MIY_SPO_Main.h.getStatuses');
        var status = component.get('v.record.StageName');
        var action = component.get('c.getOrderStageOptions');
        var isUserInPermissionSetGroup = component.get('v.isUserInPermissionSetGroup'); // MIY-2224
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.getOrderStageOptions');

            var state = response.getState();
            if (state === 'SUCCESS') {
                // console.log('response:', response.getReturnValue());
                var statusOptions = response.getReturnValue();
                var userProfile = component.get('v.userProfile');
                var userCanModifyMfgDate = (
                    userProfile == 'SPO_Other' || 
                    userProfile == 'MIY_Admin' || 
                    userProfile =='SPO_NomadeMgnt' ||
                    userProfile == 'System Administrator' ||
                    isUserInPermissionSetGroup // MIY-2224
                );
                var storeMode = component.get('v.storeMode');
                var sentToRef = component.get('v.record.SPO_TechMailToreferential__c');
                var items = [
                    {
                        key: 'brief-in-progress',
                        value: 'Brief in progress',
                        label: statusOptions['Brief in progress'],
                        dateField: 'CreatedDate',
                        dateLabel: 'Created at: ',
                        workshopResponsible: false,
                        c2aTitle: (storeMode ? 'Check and Request' : 'Waiting for Brief'),
                        c2aBtnLabel: (storeMode ? $A.get('$Label.c.LV_SO_Request_quotation') : null),
                        c2aActionType: (storeMode ? 'prompt' : null),
                        c2aActionData: (storeMode ? 'MIY_SPO_QuoteSentPrompt' : null),
                        altActionLabel: (storeMode ? 'View Brief' : 'Ask for Updates'),
                        altActionType: (storeMode ? 'action' : 'post'),
                        stageIcon: 'shopping-basket',
                        iconId:'1575297751000',
                        stageProgress: 0.1,
                        pastTitle: 'Brief Created',
                        pastSubtitle: 'at the date',
                        pastValueType: 'date',
                        pastValue: component.get('v.record.CreatedDate'),
                        pastActionLabel: (storeMode ? null : 'View Brief'),
                        pastActionType: (storeMode ? null : 'action'),
                        stageDuration: component.get('v.miySettings.stageDuration_briefInProgress.Value__c'),
                    },
                    {
                        key: 'quotation-in-progress',
                        value: 'Quotation in progress',
                        label: statusOptions['Quotation in progress'],
                        dateField: 'SPO_Date_Quotation_in_progress__c',
                        dateLabel: 'Sent at: ',
                        workshopResponsible: true,
                        c2aTitle: (storeMode ? 'Waiting for Quotation' : 'Create Quotation'),
                        c2aBtnLabel: (storeMode ? null : 'Create Quotation'),
                        c2aActionType: (storeMode ? null : 'modal-med'),
                        c2aActionData: (storeMode ? null : 'MIY_SPO_CreateQuotationModal'),
                        altActionLabel: (storeMode ? 'Ask for Updates' : null),
                        altActionType: (storeMode ? 'post' : null),
                        stageIcon: 'file',
                        iconId: '1575297751000',
                        stageProgress: 0.177,
                        pastTitle:  (storeMode
                            ? 'You got an answer from '+component.get('v.workshopName')+'!'
                            : 'Quotation Sent to Store'),
                        pastSubtitle: 'The price is',
                        pastValueType: 'currency',
                        pastValue: component.get('v.record.Amount'),
                        stageDuration: component.get('v.miySettings.stageDuration_quotationInProgress.Value__c'),
                    },
                    {
                        key: 'quotation-submitted',
                        value: 'Quotation submitted',
                        label: statusOptions['Quotation submitted'],
                        dateField: 'SPO_Date_Quotation_submitted__c',
                        dateLabel: 'Received at: ',
                        workshopResponsible: false,
                        c2aTitle: (storeMode ? 'Confirm Quotation' : 'Waiting for Quotation'),
                        c2aActionType: (storeMode ? 'modal' : 'post'),
                        c2aActionData: (storeMode ? 'MIY_SPO_AddDepositModal' : null),
                        c2aBtnLabel: (storeMode ? 'Confirm' : null),
                        altActionLabel: (storeMode ? null : 'Ask for Updates'),
                        altActionType: (storeMode ? null : 'post'),
                        stageIcon: 'target',
                        iconId:'1575297751000',
                        stageProgress: 0.25,
                        // pastTitle: (storeMode ? 'Check quotation with Client' : 'Waiting for Confirmation'),
                        // pastSubtitle: 'The Quotation is accepted by the client',
                        // pastValueType: 'statictext',
                        // pastValue: 'Confirmed',
                        pastTitle: 'Deposit added',
                        pastSubtitle: ((component.get('v.record.SPO_DepositAmount__c') / component.get('v.record.Amount')) * 100) + '% of the total',
                        pastValueType: 'currency',
                        pastValue: component.get('v.record.SPO_DepositAmount__c'),
                        stageDuration: component.get('v.miySettings.stageDuration_quotationSubmitted.Value__c'),
                    },

                    /*{
                        key: 'quotation-accepted',
                        value: 'Quotation accepted',
                        label: statusOptions['Quotation accepted'],
                        dateField: 'SPO_Date_Quotation_accepted__c',
                        dateLabel: 'At: ',
                        workshopResponsible: false,
                        c2aTitle: (storeMode ? 'Add Deposit' : 'Waiting for Deposit'),
                        c2aText: 'Click on Add Deposit and complete all fields',
                        c2aBtnLabel:  (storeMode ? 'Add Deposit' : 'Ask for Updates'),
                        c2aActionType: (storeMode ? 'modal' : 'post'),
                        c2aActionData: (storeMode ? 'MIY_SPO_AddDepositModal' : null),
                        altActionType: (storeMode ? 'link' : null),
                        altActionLabel: (storeMode ? 'Quotation PDF' : null),
                        altActionData: (storeMode ? '/apex/PDFPage?id=' + component.get('v.record.Id') : null),
                        altActionOnClick: '',
                        stageIcon: 'deposit',
                        stageProgress: 0.25,
                        pastTitle: 'Deposit added',
                        pastSubtitle: ((component.get('v.record.SPO_DepositAmount__c') / component.get('v.record.Amount')) * 100) + '% of the total',
                        pastValueType: 'currency',
                        pastValue: component.get('v.record.SPO_DepositAmount__c'),
                    },*/

                    {
                        key: 'creation-in-progress',
                        value: 'Creation in progress',
                        label: statusOptions['Creation in progress'],
                        dateField: 'SPO_Date_Creation_in_progress__c',
                        dateLabel: 'Sent: ',
                        workshopResponsible: true,
                        c2aTitle: (storeMode
                            ? 'Info about Production'
                            : (sentToRef ? 'Referential Info' : 'Deposit Added')),
                        c2aBtnLabel: (storeMode
                            ? null
                            : (sentToRef ? 'Add manufacturing' : 'Add Referential Info')),
                        c2aActionType: (storeMode ? null : 'modal-med'),
                        c2aActionData: (storeMode
                            ? null
                            : (sentToRef ? 'MIY_SPO_AddManufacturing' : 'MIY_SPO_AddRefInfo')),
                        // c2aBtnDisabled: (sentToRef && !rcvdByRef),                        
                        altActionLabel: (storeMode ? 'Ask for Updates' : null),
                        altActionType: (storeMode ? 'post': null),
                        stageIcon: 'production-old',
                        iconId:'1575297751000',
                        stageProgress: 0.5,
                        stageDuration: component.get('v.miySettings.stageDuration_creationInProgress.Value__c'),
                    },
                    {
                        key: 'in-progress',
                        value: 'In progress',
                        label: statusOptions['In progress'],
                        dateField: 'SPO_Date_In_progress__c',
                        dateLabel: 'Received at: ',
                        workshopResponsible: true,
                        c2aTitle: 'Info about Production',
                        c2aBtnLabel:  (storeMode 
                            ? (userCanModifyMfgDate ? 'Adjust Mfg. Date' : null) 
                            : 'Sent to Distribution'
                        ),
                        c2aActionType: (storeMode 
                            ? (userCanModifyMfgDate ? 'modal' : null)  
                            : 'prompt'
                        ),
                        c2aActionData: (storeMode 
                            ? (userCanModifyMfgDate ? 'MIY_SPO_AdjustMfgDateModal' : null)
                            : 'MIY_SPO_SentToDistPrompt'
                        ),
                        altActionLabel: (storeMode ? 'Ask for Updates': null),
                        altActionType: (storeMode ? 'post' : null),
                        stageIcon: 'production',
                        iconId: '1602685985000',
                        stageProgress: (storeMode ? 0.5 : 0.666667),
                        pastTitle: 'Product sent for delivery',
                        pastSubtitle: 'on the date',
                        pastValueType: 'date',
                        pastValue: component.get('v.record.SPO_Date_Distribution_in_Progress__c'),
                        stageDuration: (storeMode
                            ? (component.get('v.miySettings.stageDuration_creationInProgress.Value__c')
                                + component.get('v.record.SPO_EstimatedProductionTimeMonths__c'))
                            : null),
                    },
                    {
                        key: 'distribution-in-progress',
                        value: 'Distribution in Progress',
                        label: statusOptions['Distribution in Progress'],
                        dateField: 'SPO_Date_Distribution_in_Progress__c',
                        dateLabel: 'Sent at: ',
                        workshopResponsible: false,
                        c2aTitle: (component.get('v.record.SpeOrder_Order_Following__r[0].DistributionStatus__c') != null
                            ? component.get('v.record.SpeOrder_Order_Following__r[0].DistributionStatus__c')
                            : 'Info about Delivery'
                        ),
                        c2aBtnLabel:  (storeMode ? 'Received in Store' : null),
                        c2aActionType: (storeMode ? 'received' : null),
                        altActionLabel: (storeMode ? null : 'Ask for Updates'),
                        altActionType: (storeMode ? null : 'post'),
                        stageIcon: 'trolley',
                        iconId: '1575297751000',
                        stageProgress: 0.75,
                        pastTitle: 'Product arrival in Store',
                        pastSubtitle: 'on the date',
                        pastValueType: 'date',
                        pastValue: component.get('v.record.SpeOrder_Order_Following__r[0].SPO_ReceivedInStoreDate__c'),
                        stageDuration: component.get('v.record.SPO_EstimatedDistributionTime__c'),
                    },
                    {
                        key: 'received-in-store',
                        value: 'Received in store',
                        label: statusOptions['Received in store'],
                        dateField: 'Received_in_Store_Date__c',
                        dateLabel: 'Received at: ',
                        workshopResponsible: false,
                        c2aTitle: (storeMode ? 'Client Pickup' : 'Arrival in Store'),
                        c2aBtnLabel:  (storeMode ? 'Deliver to client' : null),
                        c2aActionType: (storeMode ? 'delivered' : null),
                        stageIcon: 'serve',
                        iconId:'1575297751000',
                        stageProgress: 0.875,
                        stageDuration: component.get('v.miySettings.stageDuration_receivedInStore.Value__c'),
                    },
                    {
                        key: 'delivered',
                        value: 'Delivered',
                        label: statusOptions['Closed Won'],
                        stageProgress: 1,
                        orderClosed: true,
                    },
                    {
                        key: 'cancelled-store',
                        value: 'Cancelled by store',
                        label: statusOptions['Cancelled by store'],
                        orderClosed: true,
                    },
                    {
                        key: 'cancelled-production',
                        value: 'Cancelled by Production',
                        label: statusOptions['Cancelled by Production'],
                        orderClosed: true,
                    },
                    {
                        key: 'cancelled-migrated-to-xstore',
                        value: 'Cancelled - Migrated to XStore',
                        label: statusOptions['Cancelled - Migrated to XStore'],
                        orderClosed: true,
                    }
                ];
                var isDelivered = ((status === 'Closed Won') && (component.get('v.record.SPO_Date_Closed_Won__c') != null));
                // console.log('status:',status);
                // console.log('storeMode:',storeMode);
                // console.log('items:',items);
                if (storeMode && (status === 'Creation in progress')) {status = 'In progress';}
                if (status === 'Quotation accepted') {status = 'Quotation submitted';}
                var statuses = [];
                var statusIdx = 0;
                items.forEach(function (obj, i) {
                    // console.log(i, statusIdx, obj.key, obj.value, obj.label);
                    if (!storeMode || (storeMode && obj.key !== 'creation-in-progress')) {
                        // console.log('if true');
                        obj.idx = statusIdx;
                        statusIdx++;
                        if ((obj.value == status) || (obj.label == status) || (isDelivered && obj.key === 'delivered')) {
                            component.set('v.currentStatus',obj);
                        }
                        statuses.push(obj);
                    }
                });
                // console.log('statuses:',statuses);
                component.set('v.statuses', statuses);
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
    getProductSettings: function(component) {
        var action = component.get('c.getProductSettings');
        action.setCallback(this, function(result) {component.set('v.productSettings', result.getReturnValue());});
        action.setStorable();
        $A.enqueueAction(action);
    },
    getMiySettings: function(component) {
        var action = component.get('c.getMiySettings');
        action.setCallback(this, function(result) {component.set('v.miySettings', result.getReturnValue());});
        action.setStorable();
        $A.enqueueAction(action);
    },

    scrollStages: function (component, stageIdx) {
        // console.group('MIY_SPO_Main.scrollStages', stageIdx);
        var scrollerWrapper = component.find('scrollerWrapper');
        if (stageIdx < 2) {
            scrollerWrapper.scrollTo('left');
        } else {
            scrollerWrapper.scrollTo('custom', (((stageIdx - 1) * 376) - 50), (((stageIdx - 1) * 388) - 50));
        }
        // console.groupEnd();
    },
    getProductProfile: function (component) {
        var action = component.get('c.getUserProfileName');
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.h.getUserProfileName');

            var state = response.getState();
            if (state === 'SUCCESS') {
                var profileName = response.getReturnValue();
                // console.log(profileName);
                if (profileName === 'SPO_Product') {
                    component.set('v.productProfile', true);
                }
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error($A.get('$Label.c.MIY_OrderPage_Error').replace('{0}', errors[0].message));
                    }
                } else {
                    console.error($A.get('$Label.c.MIY_OrderPage_Unknown_Error'));
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
    },
});