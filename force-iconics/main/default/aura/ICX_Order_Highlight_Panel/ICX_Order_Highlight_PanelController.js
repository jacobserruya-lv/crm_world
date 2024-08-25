({
    navigateToRecord: function(component, event, helper){
        var recordId =  event.target.id;

        if(!$A.util.isEmpty(recordId)){
             var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
            "recordId":recordId
             });
             navEvt.fire();
        }
    }
})