({
	getVisualforceHost : function(component, event) {

        // call Apex controller
        var action = component.get("c.getVisualforceHost");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                console.log("response success", response.getReturnValue());
                component.set("v.vfHost", response.getReturnValue());
            } else {
                // error message
                console.log('error', state);
            }
        });
        $A.enqueueAction(action);
	},

    handleDownload : function(component, event) {
        console.log("handleDownload");
        /*var data = component.get("v.base64");
        var blob = new Blob([data], {
            type: "application/pdf",
            data: "application/pdf;headers=Content-Disposition: attachment;filename=" + component.get("v.fileName") + ".pdf;base64," + data
        });
        var url = window.URL.createObjectURL(blob);
        var oURL = component.find("oURL");
        oURL.set("v.value", url);
        oURL.set("v.label", url);    	*/
    },
})