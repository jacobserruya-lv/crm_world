({
    onInit : function(component, event, helper) {
        helper.getEmailsData(component);
	},

    // Page refreshed
    isRefreshed : function(component, event, helper) {
        helper.getEmailsData(component);
    }
})