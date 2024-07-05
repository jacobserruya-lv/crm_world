({
    onRender: function (component) {
        // console.group(component.getType() + '.onRender');
        var userProfile = component.get('v.userProfile');
        var record = component.get('v.record');
        var isUserInPermissionSetGroup = component.get("v.isUserInPermissionSetGroup"); // MIY-2224
        // console.log(record);
        component.set('v.showAddDepositBtn', (
            record.StageName == 'Creation in progress'
            && ((userProfile == 'System Administrator' || userProfile == 'MIY_Admin' || userProfile =='SPO_NomadeMgnt' || isUserInPermissionSetGroup) 
                || (userProfile != null && userProfile.startsWith('ICON_')))
            && (record.SPO_DepositAmount__c == null || record.SPO_DepositAmount__c == 0)
            && record.TECH_Nb_FO_ETL_Status_is_V__c > 0
        ));

        // console.groupEnd();
    },
    chatterAction: function (component, event, helper) {
        // console.group('MIY_OrderPageHeader.chatterAction');

        $A.createComponents([
                ['forceChatter:publisher', {
                    'context': 'RECORD',
                    'recordId': component.get('v.recordId'),
                }],
                ['forceChatter:feed', {
                    'type': 'Record',
                    'subjectId': component.get('v.recordId'),
                    'feedDesign': 'DEFAULT',
                }],
            ],
            function (newCmps, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        body: newCmps,
                        showCloseButton: true,
                        cssClass: 'slds-modal_large',
                        closeCallback: function() {

                        },
                    });
                }
            }
        );

        // console.groupEnd();
    },
    filesAction: function (component, event, helper) {
        // console.group('MIY_OrderPageHeader.filesAction');

        $A.createComponent('c:MIY_Files',
            {
                'recordId': component.get('v.recordId'),
            },
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        body: modalCmp,
                        showCloseButton: true,
                        closeCallback: function() {

                        },
                    });
                }
            }
        );

        // console.groupEnd();
    },
    handleEditClick: function (component, event, helper) {
        var editRecordEvent = $A.get('e.force:editRecord');
        editRecordEvent.setParams({
            'recordId': component.get('v.recordId'),
        });
        editRecordEvent.fire();
    },
    handleAccountNameClick: function (component) {
        var navEvt = $A.get('e.force:navigateToSObject');
        navEvt.setParams({
            'recordId': component.get('v.record.Account.Id'),
        });
        navEvt.fire();
    },
    handleCloneClick: function (component) {
        $A.createComponent(('c:MIY_ConfirmCloneModal'), {record: component.get('v.record')},
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: ('cMIY_FancyModal cMIY_ConfirmCloneModal'),
                    });
                }
            }
        );

    },
    handleCancelClick: function (component) {
        var isUserInPermissionSetGroup = component.get('v.isUserInPermissionSetGroup'); // MIY-2224
        $A.createComponent(('c:MIY_SPO_CancelModal'),
            {
                record: component.get('v.record'),
                'isUserInPermissionSetGroup': isUserInPermissionSetGroup // MIY-2224
            },
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: ['cMIY_FancyModal', modalCmp.getName()].join(' '),
                    });
                }
            }
        );
    },
    handleAddDepositClick: function (component) {
        $A.createComponent(('c:MIY_AddPersoDepositModal'), {record: component.get('v.record')},
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: ['cMIY_FancyModal', modalCmp.getName()].join(' ').trim(),
                    });
                }
            }
        );
    },
    handleUpdateEvent: function (component, event) {
        // console.group(component.getType() + '.handleUpdateEvent');
        // var evtOldData = event.getParam('oldData');
        var evtNewData = event.getParam('newData');
        component.set('v.record', evtNewData);
        // console.groupEnd();
    },

});