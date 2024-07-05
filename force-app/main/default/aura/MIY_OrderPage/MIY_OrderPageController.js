({
    doInit: function (cmp, evt, helper) {
        helper.getProductSettings(cmp); //MIY-1969
        // console.group(cmp.getType() + '.doInit');
        var userId = $A.get('$SObjectType.CurrentUser.Id');
        cmp.set('v.userId', userId);

        if (cmp.get('v.recordId') == null) {
            helper.getLatestOrder(cmp, evt, helper);
        } else {
            helper.getOrderData(cmp, evt, helper);
        }
        helper.getMIYSettingsForWarnings(cmp, evt, helper);
        helper.getStoreMode(cmp);
        helper.getUserProfile(cmp);
        helper.checkPermissionSetGroup(cmp); // MIY-2224
        cmp.addEventHandler('force:recordChange', cmp.getReference('c.handleRecordChange'));
        // helper.getQuickActions(cmp);
        // console.groupEnd();
    },

    togglePanelOpen: function (component) {
        // console.group(component.getType() + '.togglePanelOpen');
        component.set('v.panelOpen', !component.get('v.panelOpen'));
        // console.groupEnd();
    },
    editBrief: function (component) {
        // console.group(component.getType() + '.editBrief');
        component.set('v.briefEdit', true);
        // console.groupEnd();
    },
    cancelEditBrief: function (component) {
        // console.group(component.getType() + '.cancelEditBrief');
        component.set('v.briefEdit', false);
        // console.groupEnd();
    },
    saveBrief: function (component) {
        // console.group(component.getType() + '.saveBrief');
        component.set('v.briefSaving', true);
        var briefEditForm = component.find('briefEditForm');
        briefEditForm.submit();
        // console.groupEnd();
    },
    onSaveBriefSuccess: function (component) {
        component.set('v.briefEdit', false);
        component.set('v.briefSaving', false);
    },
    handleUpdateEvent: function (component, event) {
        // console.group(component.getType() + '.handleUpdateEvent');
        // var evtOldData = event.getParam('oldData');
        var evtNewData = event.getParam('newData');
        component.set('v.record', evtNewData);
        // console.groupEnd();
    },
    handleSaveSuccess : function(component) {
        console.group(component.getType() + '.handleSaveSuccess');

        console.groupEnd();
    },
    handleRecordChange : function(component, event, helper) {
        // console.group(component.getType() + '.handleRecordChange', event);
        helper.getOrderData(component, event, helper);
        // console.groupEnd();
    },

});