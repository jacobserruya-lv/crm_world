({
	getEmailsData : function(component) {
		var action = component.get("c.getEmails");
        action.setParams({recordId: component.get("v.recordId")});
        action.setCallback(this, function(result){
            if(result.getState() === "SUCCESS"){
                var emailsData = {};
                emailsData.headers = [
                    {label: "Subject", type: "Record", sortable: true},
                    {label: "Date", type: "Date", sortable: true},
                    {label: "Status", type: "String", sortable: true},
                    {label: "", type: "Icon", sortable: false},
					{label: "", type: "Icon", sortable: false}
                ];
        		emailsData.rows = [];
                var emails = result.getReturnValue();
                emails.forEach(function(email){
                    emailsData.rows.push(this.createRow(email));
                }, this);
                component.set("v.emailsData", emailsData);
            }
        });
        $A.enqueueAction(action);
	},
    
    createRow : function(email){
        var row = [];
        row.push({label: email.Subject, id: email.Id});
        row.push({date: email.MessageDate});
        row.push({label: email.Status});
        if(email.HasAttachment || email.Has_Files__c)
            row.push({label: 'Has Attachment', iconName:'utility:attach'});
        else
            row.push({label: 'No Attachment'});
		if(email.Incoming)
            row.push({label: 'Incoming', iconName:'utility:undo'});
        else
            row.push({label: 'Outgoing', iconName:'utility:redo'});
        return row;
    }
})