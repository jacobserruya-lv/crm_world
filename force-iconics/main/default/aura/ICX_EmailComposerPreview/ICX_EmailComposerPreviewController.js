({
	handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },
    handleSendEmail : function(component, event, helper) {
        if(!$A.util.isEmpty(component.get("v.parent"))){
			component.get("v.parent").sendMail();
		}
    }
})