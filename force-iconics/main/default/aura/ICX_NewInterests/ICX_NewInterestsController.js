({
    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        const fields = event.getParam('fields');
        //fields.ContactId = component.get("v.recordId");
        fields.isActive__c = true;
        fields.source__c = 'Iconics';
        component.find('recordEditForm').submit(fields);

        component.destroy();
    },
    closeBtn : function(component, event, helper) {
        component.destroy();
    }
})