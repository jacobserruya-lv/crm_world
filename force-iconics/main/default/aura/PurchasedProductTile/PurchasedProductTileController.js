({
    titleClickHandler: function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.item").Id,
        });
        navEvt.fire();
    },

    handleMouseEnter : function(component, event, helper) {
        var popover = component.find("popup");
        console.log('handleMouseEnter',popover);
        $A.util.removeClass(popover,'slds-hide');
    },

    //make a mouse leave handler here
    handleMouseLeave : function(component, event, helper) {
        var popover = component.find("popup");
        console.log('handleMouseLeave',popover);
        $A.util.addClass(popover,'slds-hide');
    }

})