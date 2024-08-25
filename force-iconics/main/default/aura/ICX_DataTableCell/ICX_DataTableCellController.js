({
	onInit : function(component, event, helper) {
		var cellIndex = component.get("v.cellIndex");
        var headers = component.get("v.headers");
        var header = headers[cellIndex];
        var type = header.type;
        component.set("v.type", type);
        component.set("v.header", header);
	},
    
    navigateToRecord: function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.currentTarget.dataset.recordId
        });
        navEvt.fire();
    },

	openFile: function(component, event, helper){
		$A.get('e.lightning:openFiles').fire({
			recordIds: [event.currentTarget.dataset.fileId]
		});

	}
})