({
    doInit: function (component, event, helper) {
        if (component.get('v.itemData') == null) {
            component.set('v.errors', [{
                title:  helper.formatLabel($A.get('$Label.c.MIY_OrderPage_Error'),''),
                message: 'No Firm Order found.',
            }]);
        }
    },
    handleOk: function (component, event, helper) {
        component.set('v.loading', true);
        helper.markRecieved(component, event, helper);
    },
})