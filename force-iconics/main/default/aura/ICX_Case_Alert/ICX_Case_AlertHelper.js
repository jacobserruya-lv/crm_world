({
    getCaseData : function(component) {
        console.log('getCaseData');
       /* var action = component.get("c.getCase");
        action.setParams({recordId: component.get("v.recordId")});
        action.setCallback(this, function(result){
            if(result.getState() === "SUCCESS"){
                var caseData = result.getReturnValue();
                caseData.Priority = caseData.Priority.toLowerCase();
                component.set("v.caseData", caseData);

                if (caseData.Status != 'Closed') {
                    this.addTimer(component);
                }
            }
        });
        $A.enqueueAction(action);*/
        
        var action2 = component.get("c.getEmails");
        action2.setParams({recordId: component.get("v.recordId")});
        action2.setCallback(this, function(result){
            if(result.getState() === "SUCCESS"){
                var emails = result.getReturnValue();
                var hasAttachment = false;
                emails.forEach(function(email){
                    if(email.HasAttachment || email.Has_Files__c) {
                        hasAttachment = true;
                    }
                }, this);
                component.set("v.hasAttachment", hasAttachment);
            }
        });
        $A.enqueueAction(action2);
        
        this.getFiles(component);
        this.getSourceEmail(component);

        //this.getParentRecord(component);
    },

    getSourceEmail: function(component) {
        var sourceId = (!$A.util.isEmpty(component.get("v.caseData.SourceId")) ? component.get("v.caseData.SourceId") : 
                        !$A.util.isEmpty(component.get("v.caseData.Parent.SourceId")) ? component.get("v.caseData.Parent.SourceId") : '');
        
        if (!$A.util.isEmpty(sourceId)) {
            var action = component.get("c.getSourceEmail");
            action.setParams({recordId: sourceId});
            action.setCallback(this, function(result){
                if(result.getState() === "SUCCESS"){
                    var emailData = result.getReturnValue();
                    component.set("v.emailMessage", emailData);
                }
            });
            $A.enqueueAction(action);
        }

    },

    getFiles: function (component) {
        console.log("getFiles");
		var action = component.get("c.getRelatedFiles");
		action.setParams({recordId: component.get("v.recordId")});
		action.setCallback(this,function(result) {
            console.log("getFiles result", result);
			if(result.getState() ==="SUCCESS" ){
				component.set("v.filesData", result.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},

    getParentRecord: function (component) {
        console.log("getParentRecord");

        var caseData = component.get("v.caseData");
        console.log("caseData", caseData);
        var sObjectType;
        if (!$A.util.isEmpty(caseData)) {
            if (caseData.Origin == 'Phone') {
                sObjectType = 'Task';
            } /* else if (caseData.Origin == 'Messaging') {
                sObjectType = 'MessagingSession';
            } else if (caseData.Origin == 'Chat') {
                sObjectType = 'LiveChatTranscript';
            }*/
        }
        console.log("sObjectType", sObjectType);

        if (!$A.util.isEmpty(sObjectType)) {
            var action = component.get("c.getParentRecordId");
            action.setParams({
                caseRecordId: component.get("v.recordId"),
                sObjectType : sObjectType
            });
            action.setCallback(this,function(result) {
                if(result.getState() ==="SUCCESS" ){
                    component.set("v.parentRecordId", result.getReturnValue());
                    console.log("getParentRecord result", result.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
	},

    getLastReplyEmail: function (component) {
        console.log("getLastReplyEmail");

        var action = component.get("c.getLastReplyEmail");
        action.setParams({
            caseRecordId: component.get("v.recordId")
        });
        action.setCallback(this,function(result) {
            if(result.getState() ==="SUCCESS" ){
                component.set("v.lastReplyEmail", result.getReturnValue());
                console.log("getLastReplyEmail lastReplyEmail", result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},

    // Inspiration from: http://bobbuzzard.blogspot.com/2017/09/taking-moment-with-lightning-component.html
    addTimer : function(cmp) {
        var self=this;
        
        var caseData = cmp.get("v.caseData");
        var dayDuration = caseData.Request_Age__c;
        //console.log("dayDuration", dayDuration);
        
        if (dayDuration > 0) {
            // More than 1 day, no timer and display the number of days
            var dayText = (dayDuration > 1 ? ' days' : 'day');
            cmp.set("v.timerMessage", dayDuration + dayText);
            return; // no timer when the Case lasts more than 0 day
        }

        // load timer on init
        self.timerFired(cmp, self);

        var offsetInMinute = this.offsetDuration(cmp);
        //console.log("offsetInMinute/60", offsetInMinute/60);
        var time;
        if (offsetInMinute/60 > 1) {
            // more than 1 hour, the timer is executed every hour
            time = 3600000; // 1 hour in milliseconds = 60 sec * 60 min * 1000 (in milliseconds)
        } else {
            // less than 1 hour, the timer is executed every minute
            time = 60000; // every minute (60 sec * 1000 milliseconds)
        }
        //console.log("time", time);

        window.setInterval($A.getCallback(function() {
            if (cmp.isValid()) {
                self.timerFired(cmp, self);
            }
        }), time);
    },
    timerFired : function(cmp, helper) {

        var now=new Date();
        var caseData = cmp.get("v.caseData");
        var startTime = new Date(caseData.CreatedDate);
        //startTime=  cmp.get("v.creationDate");
        //console.log("startTime", startTime);

        var diffMillis=now-startTime;
        var diffMins=Math.floor(diffMillis/60000);
        //console.log("diffMins", diffMins);
        
        var msg='';
       // var templateData=[];
        var offset = (diffMins+60)%60;

        //var offset = helper.offsetDuration();
        //console.log("offset", offset);
        if (diffMins >= 60) { //offset >= 60) {
            var hourSet = Math.floor(offset / 60) + 1;
            console.log("hourSet", hourSet);
            msg = hourSet + 'h';
        } else {
            msg = offset + 'min';            
        }
        //console.log('Msg = ' + msg);
        cmp.set("v.timerMessage", msg);
    },

    offsetDuration : function(cmp) {
        var now=new Date();
        var caseData = cmp.get("v.caseData");
        var startTime = new Date(caseData.CreatedDate);
        //startTime=  cmp.get("v.creationDate");
        //console.log("startTime", startTime);

        var diffMillis=now-startTime;
        var diffMins=Math.floor(diffMillis/60000);
        //console.log("diffMins", diffMins);
        
        return (diffMins+60)%60;
    }
})