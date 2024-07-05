({
    getOpenCases : function(component, event) {

        var accountId = component.get("v.accountId");
        var relatedId = component.get("v.relatedRecordId");

        var param1 = (!$A.util.isEmpty(accountId) ? accountId : relatedId);
        if (!$A.util.isEmpty(param1)) {
            var caseService = component.find("caseService");
            caseService.findOpenCases(param1, $A.getCallback(function(error, data) {
                component.set("v.openCases", data);
            }));
        }
	},

    getComplaints : function(component, event) {
        var accountId = component.get("v.accountId");
        var relatedId = component.get("v.relatedRecordId");

        var param1 = (!$A.util.isEmpty(accountId) ? accountId : relatedId);
        if (!$A.util.isEmpty(param1)) {
            var caseService = component.find("caseService");
            caseService.findComplaints(param1, $A.getCallback(function(error, data) {
                component.set("v.complaintIndicator", data);
            }));
        }
	},

    getIndicators : function(component, event) {
        var helper = this;
        var accountId = component.get("v.accountId");
        var relatedId = component.get("v.relatedRecordId");

        var param1 = (!$A.util.isEmpty(accountId) ? accountId : relatedId);
        if (!$A.util.isEmpty(param1)) {
            var caseService = component.find("caseService");
            caseService.findIndicators(param1, $A.getCallback(function(error, data) {
             //   component.set("v.openCases", data.openCaseList);
             //   component.set("v.complaintIndicator", data.complaintList);
                
                
                // Workaround : get care duration
                for (var key in data.careList) {
                    var careItem = data.careList[key];
                    careItem.Duration = helper.getDurationInDays(careItem.CreatedDate);
                    //console.log("careItem", careItem);
                }
                component.set("v.careServices", data.careList);
            }));
        }
	},


    getDurationInDays : function(createdDate) {
        var oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds
        var today = new Date();
        var secondDate = new Date(createdDate);

        var diffDays = Math.round(Math.abs((today.getTime() - secondDate.getTime())/(oneDay)));
		console.log("diffDays", diffDays);
        return diffDays;
    }
})