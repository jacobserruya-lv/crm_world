({
	handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },
    handleOK : function(component, event, helper) {
        if(!$A.util.isEmpty(component.get("v.parent"))){
			component.get("v.parent").save();
		}
    }
})