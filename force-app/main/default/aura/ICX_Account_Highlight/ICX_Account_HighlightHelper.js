({
    getAccount : function(component, event) {
        
        // change recordId to get Account Id from Case
        var caseService = component.find("caseService");
        caseService.findAccount(component.get("v.recordId"),component.get("v.accountApi"),$A.getCallback(function(error, data) {
            component.set("v.recordId", data);
            component.set("v.accountChanged", true);
            //component.find('recordDataAccount').reloadRecord(true);
            //component.set("v.accountId", data);
        }));
	},

    /*getOpenCases : function(component, event) {
        var accountId = component.get("v.simpleAccount.Id");

        var caseService = component.find("caseService");
        caseService.findOpenCases(accountId, $A.getCallback(function(error, data) {
            component.set("v.openCases", data);
        }));
	},

    getComplaints : function(component, event) {
        var accountId = component.get("v.simpleAccount.Id");

        var caseService = component.find("caseService");
        caseService.findComplaints(accountId, $A.getCallback(function(error, data) {
            component.set("v.complaintIndicator", data);
        }));
	}*/
})