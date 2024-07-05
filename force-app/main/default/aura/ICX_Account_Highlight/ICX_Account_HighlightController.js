({
    doInit : function(component, event, helper) {
        console.log('doInit', component.get("v.recordId"));
            console.log("*** INIT hightling");
        
        var rec = component.get("v.recordId");
        component.set("v.currentRecordId", rec);
        //if (component.get("v.sObjectName") === 'Case') {
        console.log('sobj name : ' + component.get("v.sObjectName"));
        if (component.get("v.sObjectName") !== 'Account') {
            helper.getAccount(component, event);

            // force:recordData needs a List of fields for 'fields' attribute. To avoid the user to miss the brackets [], this workaround will help
            /*var accountApi = component.get("v.accountApi");
            console.log("accountAPI", accountApi);
            if (!$A.util.isEmpty(accountApi)) {
                console.log("accountAPI2", accountApi);
                let temp = [];
                temp.push(accountApi);
                component.set("v.formattedAccountFields", temp);                
            }*/
        } else {
            //var recId = component.get("v.recordId");
            //component.set("v.accountId", recId);
        }

        /*var analytics = component.find("analytics");
        analytics.addPageAction("Call started", {
            ICX_recordId : "00012345",
            ICX_recordType : "Call",
            ICX_name : "Product Information > Availability",
            ICX_country : "FRA"
        });*/
        
        /*var lightningEvent = $A.get("e.c:AnalyticsServiceEvent");
        lightningEvent.setParams({
            application : "ICONICS", // should be the same name in the "NewRelic" Custom Metadata Type 
            // Any parameters are accepted. For example:
            parameters : {
                ICX_recordId : "My RECORD",
                ICX_caseType : "Call",
                ICX_country : "FRA"
            }
        });
        lightningEvent.fire();*/
    },
    
    /*onAccountChange : function(component, event, helper) {
        console.log('onAccountChange');
        helper.getOpenCases(component, event);
        helper.getComplaints(component, event);
    },*/

    /*goToAccount : function(component) {
        var accountId = component.get("v.simpleAccount.Id");

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": accountId
        });
        navEvt.fire();
    },*/
    handleEvent : function(component, event, helper) {
        
        console.log("*** handleEvent", JSON.stringify(event));
        
        var newAccountId = event.getParam("recordId");           
        var updatedCurrentRecordId = event.getParam("currentRecordId");
        
        var currentAccountId = component.get("v.recordId");
        var currentRecordId = component.get("v.currentRecordId");

        console.log("refreshView > newAccountId", newAccountId);
        console.log("refreshView > updatedCurrentRecordId", updatedCurrentRecordId);
        console.log("refreshView > currentRecordId", currentRecordId);
        console.log("refreshView > currentAccountId", currentAccountId);
        
        // refresh highlight panel when the account id became not empty (account created from the Call or Case detail page for example)
        //if (updatedCurrentRecordId == currentRecordId && $A.util.isEmpty(currentAccountId) && !$A.util.isEmpty(newAccountId)) {
        if (updatedCurrentRecordId == currentRecordId && !$A.util.isEmpty(newAccountId)) {
            component.set("v.recordId", newAccountId);
            // don't refresh the view. For the Screen Flow (ex: Call), the refreshView will close the Flow (with criteria Resolution != null)
            //     $A.get('e.force:refreshView').fire();
        }
        //}
    },

    handleAccountInOtherObject : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
            
            let simpleRecord = component.get("v.simpleRecord");
            console.log("v.simpleRecord", JSON.stringify(simpleRecord));
            
            //let accountId = simpleRecord[accountApi];
            //console.log("accountId", accountId);
            //component.set("v.recordId", newAccountId);
            //$A.get('e.force:refreshView').fire();    

        }
    },

    /*    initRelic : function(component, event, helper) {
        console.log("+++initNewRelic", newrelic);

        if (newrelic) {
            newrelic.setCustomAttribute('userIp', new RegExp("clientSrc=([^;]+)").exec(document.cookie)[1]);
            newrelic.setCustomAttribute('userSid', new RegExp("sid=([^;]+)").exec(document.cookie)[1]);
            var startTimeMs = (new Date).getTime();
        }
        //console.log('+++initNewRelic');
    },*/
})