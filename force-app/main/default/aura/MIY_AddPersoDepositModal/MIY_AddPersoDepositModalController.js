({
    doInit: function (component) {
        var defaultDeposit = (component.get('v.record.Amount') / 2);
        component.set('v.depositAmount', defaultDeposit);

        helper.apexActionPromise(component, 'c.getUserInfo')
            .then($A.getCallback(function (result) {
                var userLookupObj = {
                    "val": result.Email,
                    "text": result.Name,
                    "objName": "User",
                    "obj": result
                }
                component.set('v.selectedUser', result);
                component.set('v.selectedUserItem', userLookupObj);
                component.set('v.caEmail', result.Email);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
    },
    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    handleConfirmClick: function (component, event, helper) {
        // console.group(component.getType() + '.handleConfirmClick');
        // console.log(component, event, helper, this);
        component.set('v.confirmLoading', true);
        
        if(component.get('v.selectedUserItem') == null) {
            var caNameLabel = $A.get('$Label.c.SO_LV_CA_Name');
            helper.processErrors(component, helper, [{message: caNameLabel + ' must be filled out'}]);
            component.set('v.confirmLoading', false);
        } else {
            var opp = component.get('v.record');
            opp.SPO_DepositAmount__c = component.get('v.depositAmount');
            opp.SPO_DepositComment__c = component.get('v.depositComment');
            opp.SPO_CACode__c = component.get('v.caCode');

            helper.apexActionPromise(component, 'c.addPersoOrderDeposit', {opp: opp})
                .then(
                    $A.getCallback(function (result) {
                        component.set('v.record', result);
                        var updateOrderEvent = $A.get('e.c:MIY_OrderUpdate');
                        updateOrderEvent.setParams({'oldData': opp,'newData': result});
                        updateOrderEvent.fire();
                        component.find('modalOverlayLib').notifyClose();
                    })
                )
                .catch($A.getCallback(function (e) {
                    console.error(e);
                }))
                .finally($A.getCallback(function () {
                    component.set('v.confirmLoading', false);
                }));
        }
        // console.groupEnd();

    },
});