({
    /*doInit: function(component, event, helper) {
        helper.getProductSettings(component);
    },*/

	navigateToDetailsView : function(component) {
		var product = component.get("v.product");
        var myEvent = $A.get("e.force:navigateToSObject");
        myEvent.setParams({
            "recordId": product.Id
        });
        myEvent.fire();
	},

	productSelected : function(component) {
		var product = component.get("v.product");
		console.log('product' + product);
        var myEvent = $A.get("e.ltng:selectSObject");
        myEvent.setParams({"recordId": product.Id, channel: "Products"});
        myEvent.fire();
    },

    handleMouseEnter : function(component, event, helper) {
        var popover = component.find("title");
        //console.log("popover", popover);
        if ($A.util.isUndefined(popover) === false) {
        	$A.util.removeClass(popover,'slds-hide');
        }
    },
    //make a mouse leave handler here
    handleMouseLeave : function(component, event, helper) {
        var popover = component.find("title");
        //console.log("popover leave", popover);
        if ($A.util.isUndefined(popover) === false) {
	        $A.util.addClass(popover,'slds-hide');
        }
    }

})