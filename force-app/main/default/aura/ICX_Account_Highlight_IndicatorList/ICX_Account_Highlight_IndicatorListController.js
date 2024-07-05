({
    doInit : function(component, event, helper) {
        // load open cases only if account is empty to find cases related to the email
        if ($A.util.isEmpty(component.get("v.accountId"))) {
            helper.getOpenCases(component, event);
            helper.getComplaints(component, event);
            helper.getIndicators(component, event);
        }

    },

    onAccountChange : function(component, event, helper) {
        console.log('indicator List onAccountChange');
        helper.getOpenCases(component, event);
        helper.getComplaints(component, event);
        helper.getIndicators(component, event);
        /*console.log('onRecordChange', component.get("v.recordId"));
        if (component.get("v.sObjectName") === 'Case') {
        //if (!$A.util.isUndefined(component.get("v.recordId")) && component.get("v.sObjectName") === 'Case') {
            helper.getAccount(component, event);
        } else {
            //var recId = component.get("v.recordId");
            //component.set("v.accountId", recId);
        }*/
	},

    handleOpenCasesMouseEnter : function(component, event, helper) {
        var popover = component.find("popupOpenCases");
        $A.util.removeClass(popover,'slds-hide');
    },

    //make a mouse leave handler here
    handleOpenCasesMouseLeave : function(component, event, helper) {
        var popover = component.find("popupOpenCases");
        $A.util.addClass(popover,'slds-hide');
    },

    handleComplaintsMouseEnter : function(component, event, helper) {
        var popover = component.find("popupComplaints");
        $A.util.removeClass(popover,'slds-hide');
    },

    //make a mouse leave handler here
    handleComplaintsCasesMouseLeave : function(component, event, helper) {
        var popover = component.find("popupComplaints");
        $A.util.addClass(popover,'slds-hide');
    }
})