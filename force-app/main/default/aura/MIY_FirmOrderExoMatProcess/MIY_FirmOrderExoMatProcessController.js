({
    doInit: function (component, event, helper) {
        // console.group(component.getType() + '.doInit');
        helper.apexActionPromise(component, 'c.isDebugMode')
            .then($A.getCallback(function (result) {
                component.set('v.isDebugMode', result);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
        // console.groupEnd();
    },

    selectExoMatClick: function (component, event, helper) {
        // console.group(component.getType() + '.selectExoMatClick');
        component.set('v.isLoading', true);
        $A.createComponent('c:MIY_ExoMaterialModal', {record: component.get('v.itemData')},
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: ['cMIY_FancyModal', modalCmp.getName()].join(' ').trim(),
                        closeCallback: function() {
                            helper.apexActionPromise(component, 'c.getFirmOrder', {firmOrderId: component.get('v.itemData.Id')})
                                .then($A.getCallback(function (result) {
                                    component.set('v.itemData', result);
                                    component.set('v.creationStatus', result.Creation_Status__c);
                                }))
                                .catch($A.getCallback(function (e) {
                                    console.error(e);
                                }))
                                .finally($A.getCallback(function () {
                                    component.set('v.isLoading', false);
                                }))
                            ;
                        },
                    });
                }
            }
        );
        // console.groupEnd();
    },
    progressExoMatProcess: function (component, event, helper) {
        component.set('v.isLoading', true);
        helper.apexActionPromise(component, 'c.progressExoMatWorkflow', {firmOrder: component.get('v.itemData')})
        //helper.apexActionPromise(component, 'c.progressHardsidedWorkflow', {firmOrder: component.get('v.itemData')})
            .then($A.getCallback(function (result) {
                component.set('v.itemData', result);
                component.set('v.creationStatus', result.Creation_Status__c);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }))
            .finally($A.getCallback(function () {
                component.set('v.isLoading', false);
            }))
        ;
    },
    openConfirmModal: function (component, event, helper) {
        // console.group(component.getType() + '.openConfirmModal');
        component.set('v.isLoading', true);

        $A.createComponent('c:MIY_ExoFlowConfirmModal',
            {
                firmOrder: component.get('v.itemData'),
                stageLabel: event.getSource().get('v.label'),
            },
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        footer: modalCmp.get('v.footer'),
                        showCloseButton: true,
                        cssClass: ['cMIY_FancyModal', modalCmp.getName()].join(' ').trim(),
                        closeCallback: function() {
                        //     helper.apexActionPromise(component, 'c.getFirmOrder', {firmOrderId: component.get('v.itemData.Id')})
                        //         .then($A.getCallback(function (result) {
                        //             component.set('v.itemData', result);
                        //             component.set('v.creationStatus', result.Creation_Status__c);
                        //         }))
                        //         .catch($A.getCallback(function (e) {
                        //             console.error(e);
                        //         }))
                        //         .finally($A.getCallback(function () {
                                    component.set('v.isLoading', false);
                        //         }))
                        //     ;
                        },
                    });
                }
            }
        );
        // console.groupEnd();
    },
});