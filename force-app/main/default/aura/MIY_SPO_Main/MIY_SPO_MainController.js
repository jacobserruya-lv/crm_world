({
    doInit: function (component, event, helper) {
        // console.group(component.getType() + '.doInit');
        helper.getMiySettings(component);
        helper.getStatuses(component, event, helper);
        helper.getProductSettings(component);

        var workshop = '' + component.get('v.record.Workshop__c');
        component.set('v.workshopName', workshop.substring(workshop.search(/[^\d\s-]/)));
        // console.groupEnd();
        var recordId = component.get("v.recordId");
        var action = component.get("c.getLastStageChangeDate");
        action.setParams({
            opportunityId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lastStageChangeDate", response.getReturnValue());
            } else {
                console.log('Error: ' + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    handleUpdateEvent: function (component, event, helper) {
        component.set('v.record', event.getParam('newData'));
        helper.getStatuses(component, event, helper);
    },
    goToOrders: function () {
        var homeEvent = $A.get('e.force:navigateToObjectHome');
        homeEvent.setParams({'scope': 'Opportunity'});
        homeEvent.fire();
    },
    openProductDetailsModal: function (component) {
        // console.group(component.getType() + '.openProductDetailsModal');
        // console.log(component);
        $A.createComponent('c:MIY_SPO_ProductionInfoModal', {record: component.get('v.record')},
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: modalCmp.get('v.header'),
                        body: modalCmp,
                        showCloseButton: true,
                        cssClass: ['cMIY_FancyModal', modalCmp.getName(), 'slds-modal_large'].join(' '),
                    });
                }
            }
        );
        // console.groupEnd();
    },
    getActions: function (component) {
        // console.group(component.getType() + '.getActions');
        component.find('quickActionAPI').selectAction({actionName: 'FeedItem.TextPost'});
        // console.groupEnd();
    },

    onRender: function (component, event, helper) {
        helper.scrollStages(component, component.get('v.currentStatus.idx'));
    },

    handleStoreModeUpdate: function(component, event, helper) {
        helper.getStatuses(component, event, helper);
    },
});