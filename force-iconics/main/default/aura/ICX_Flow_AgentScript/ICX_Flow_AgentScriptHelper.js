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
                this.changeIframeUrl(component, event);
            } else {
                // error message
                console.log('error', state);
            }
        });
        $A.enqueueAction(action);
	},
    
    changeIframeUrl : function(component, event) {
        var newUrl = 'https://' + component.get("v.vfHost") + 
            '/apex/ICX_Flow_AgentScript?language=' + component.get("v.language") + 
            '&label=' + component.get("v.label") + 
            '&size=' + (component.get("v.width") == 'SMALL' ? 'small' : component.get("v.messageSize")) + 
            '&showCopyButton=' + component.get("v.copyDisplay");
        component.set("v.iframeUrl", encodeURI(newUrl));
    }
})