({
	showPopup : function(component, event, helper) {
        var args = event.getParam('arguments');
        console.log("args", args);
        component.set("v.account", args.account);
        component.set("v.isCustomerServiceView", args.isCustomerServiceView);
        console.log("account", JSON.stringify(args.account));
		var popup = component.find('popup').getElement();
        if (popup && popup.setAttribute) {
            popup.setAttribute("style", "left:calc(" + args.x + "px - 24rem);position:absolute;");
//            popup.setAttribute("style", "left:calc(" + args.x + "px - 24rem);top:" + args.y + "px;position:absolute;");
//            popup.setAttribute("style", "left:" + args.x + "px;top:" + args.y + "px;position:absolute;");
        }
        $A.util.removeClass(popup, 'slds-hide');
	},
    
    hidePopup: function(component) {
        var popup = component.find('popup').getElement();
        $A.util.addClass(popup, 'slds-hide');
    }
    
})