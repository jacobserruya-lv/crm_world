({
    //doInit : function(component, event, helper) {
   	recordChangeHandler : function(component, event, helper) {
        // Hardcoding images in this demo component
    	/*component.set("v.slides", [
            'https://s3-us-west-1.amazonaws.com/sfdc-demo/houses/living_room.jpg',
            'https://s3-us-west-1.amazonaws.com/sfdc-demo/houses/eatinkitchen.jpg',
			'https://s3-us-west-1.amazonaws.com/sfdc-demo/houses/kitchen.jpg'
        ]);*/
        var id = event.getParam("recordId");
        component.set("v.recordId", id);

        // To be more generic, maybe add a event param 'sObject' to know which object to retrieve
        helper.getProduct(component);
    },

	fullScreen : function(component) {
        component.set("v.fullScreen", true);
	},

	closeDialog : function(component) {
        component.set("v.fullScreen", false);
	}

})