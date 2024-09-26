({
    onInit: function (component, event, helper) {
        const currentRecordId = component.get("v.recordId");
        let refreshPermited;

        const action = component.get("c.refreshAllowed");
        action.setParams({ recordId: currentRecordId });
        action.setCallback(this, (result) => {
            const status = result.getState();
            if (status == 'SUCCESS') {
                refreshPermited = result.getReturnValue();

                window.addEventListener('message', (e) => {
                    if (refreshPermited) {
                        console.log('Refresh page ==>', refreshPermited);
                        $A.get('e.force:refreshView').fire();
                    }

                }, false)
            }
        })
        $A.enqueueAction(action);
    }
})