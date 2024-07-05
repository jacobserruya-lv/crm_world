({
    closeModal: function (component) {
        component.find('modalOverlayLib').notifyClose();
    },
    handleConfirmClick: function (component, event, helper) {
        var validity = component.find("CloneReason").get("v.validity");
        var numberFO = component.get('v.record.TECH_Nb_FO__c');
        if (validity.valid || numberFO==0) {
        var mycomment = component.find('CloneReason').get("v.value");
       	component.set('v.confirmLoading', true);
        var action = component.get('c.duplicateOrder');
        action.setStorable();
        action.setParams({
            'order':component.get('v.record'),
            'comment': mycomment
        });
    
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var pageRefUrl = response.getReturnValue();
                var urlEvent = $A.get('e.force:navigateToURL');
                urlEvent.setParams({'url': pageRefUrl});
                urlEvent.fire();
            }
        
            else if (state == 'ERROR') {
                helper.processErrors(component, helper, response.getError());
                component.set('v.confirmLoading', false);
            }
            
        });
        $A.enqueueAction(action);
        
    }
    else if(!validity.valid ) {
        alert('Please write a clone reason');
    }
    },
   
});