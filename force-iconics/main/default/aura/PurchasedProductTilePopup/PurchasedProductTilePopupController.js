({
	showPopup : function(component, event, helper) {
        var args = event.getParam('arguments');
        component.set("v.fund", args.fund);
		var popup = component.find('popup').getElement();

        /*if (popup && popup.setAttribute) {
            popup.setAttribute("style", "left:" + args.x + "px;top:" + args.y + "px");
        }*/
        $A.util.removeClass(popup, 'slds-hidden');
	},
    
    hidePopup: function(component) {
        var popup = component.find('popup').getElement();
        $A.util.addClass(popup, 'slds-hidden');
    }
})