({
    doInit : function(component, event, helper) {

        //var recId = component.get("v.recordId");
        //component.set("v.sObjectId", recId);
        console.log("*** => " + component.get("v.recordId"));
        helper.getProductSettings(component);
        helper.getProduct(component);
        /*if (component.get("v.sObjectName") === 'Opportunity') {
            component.set("v.oppId", recId);
            helper.getProductFromOpportunity(component);
        }*/
    },
    
    recordChangeHandler : function(component, event, helper) {
        var id = event.getParam("recordId");
        // console.log("Event Params in SO_ProductSummary " + JSON.stringify(event.getParams));
        component.set("v.recordId", id);
        //console.log('v.recordId=' + id);
        
        // not available in sandbox in Spring '17
        /*
        var service = component.find("service");
        service.reloadRecord();*/

		// addon
        helper.getProduct(component);
	},

	fullScreen : function(component) {
        component.set("v.fullScreen", true);
	},

	closeDialog : function(component) {
        component.set("v.fullScreen", false);
	}

})