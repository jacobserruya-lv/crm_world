({
/*	navigateToDetailsView : function(component) {
		var product = component.get("v.product");
        var myEvent = $A.get("e.force:navigateToSObject");
        myEvent.setParams({
            "recordId": product.Id
        });
        myEvent.fire();
	},

    doInit : function(component, event, helper) {

        if (component.get("v.selected")) {
	  //      helper.fireColorSelected(component);
        }
    },*/

/*	colorSelected : function(component, event, helper) {
        helper.fireColorSelected(component);
    },

    colorChanged: function(comp, event, helper) {        
        //var otherColorDiv = comp.find("otherColorDiv");
        ///if (event.getParam("color") === 'OTHER') {
        $A.log("colorChanged Tile");
        var typeColor = event.getParam("type");
        var color = event.getParam("color");

        if (typeColor === comp.get("v.type") && color !== comp.get("v.color")) {
            var divId = comp.find("tileDiv");
            $A.util.removeClass(divId, 'select');
    	}
    },*/

    handleMouseEnter : function(component, event, helper) {
        var popover = component.find("popover");
        $A.util.removeClass(popover,'slds-hide');

        // not working perfectly / workaround in Read mode (return an array, don't know why?)
        /*if (popover.length == undefined) {
            $A.util.removeClass(popover,'slds-hide');
        } else {
            console.log("component.find(popover).length", component.find("popover").length);
            for(var cmp in popover) {
                $A.util.removeClass(popover[cmp], "slds-hide");
            }
        }*/
    },
    //make a mouse leave handler here
    handleMouseLeave : function(component, event, helper) {
        var popover = component.find("popover");
        $A.util.addClass(popover,'slds-hide');

        // not working perfectly / workaround in Read mode (return an array, don't know why?)
        /*if (popover.length == undefined) {
            $A.util.addClass(popover,'slds-hide');
        } else {
            for(var cmp in popover) {
                $A.util.addClass(popover[cmp], "slds-hide");
            }
        }*/
    }
})