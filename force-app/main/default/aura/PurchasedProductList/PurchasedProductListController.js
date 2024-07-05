({
	doInit : function(component, event, helper) {
		helper.doInit(component);
	},

	addToEvent :function(component,event,helper){
		// This method only work with AURA's syntax (ui:button..)
		//Get DOM event, index to pass to helper
        var domEvent 	= event.getParams().domEvent;
        var bodySpan 	= domEvent.target.nextSibling;
        var index 		= bodySpan.dataset.index;

		helper.addProductToEventFromIndex(component, event, index);
	},

	addToEventHTML :function(component, event, helper){
		// This method only work with HTML syntax
        var self = this;  // safe reference

        var index = event.target.dataset.index;
        console.log(index);

        helper.addProductToEventFromIndex(component, event, index);
	}
})