({
    doInit: function(component, event, helper) {
        var recordId = (!$A.util.isEmpty(component.get("v.recordId")) ? component.get("v.recordId") : component.get("v.pageReference").state.c__recordId);
        component.set("v.recordId", recordId);
        
        var recordData = component.find("caseRecordLoader");
        recordData.reloadRecord(true); 
        
    },
    handleRecordUpdated: function(component, event, helper){
        var eventParams = event.getParams();
        console.log("eventParams.changeType", eventParams.changeType);
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
            console.log('handleSpam record id', component.get("v.recordId"));
            console.log('handleSpam', JSON.stringify(component.get("v.simpleCase")));
            helper.handleSpam(component, event);
        } else if(eventParams.changeType === "REMOVED") {
            console.log("REMOVED>eventParams", eventParams);
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log("ERROR>eventParams", eventParams);
            // there’s an error while loading, saving or deleting the record
        }
    }
})