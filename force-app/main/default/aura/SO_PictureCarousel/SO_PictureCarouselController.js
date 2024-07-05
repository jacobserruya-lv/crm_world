({
    init: function(component, event, helper){
        helper.setSlideWidth(component);
        /*var action =  component.get("c.getProductSettings");
        action.setCallback(this, function(response)
        {
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                component.set("v.productSettings", response);
            }
        });
        $A.enqueueAction(action);*/

    },
    next: function(component) {
    	var slideIndex = component.get("v.slideIndex");
    	var slides = component.get("v.slides");
        if (slideIndex + 1 < slides.length) {
            slideIndex = slideIndex + 1;
	        component.set("v.slideIndex", slideIndex);
        }
	},

    prev: function(component) {
       	var slideIndex = component.get("v.slideIndex");
        if (slideIndex > 0) {
            slideIndex = slideIndex - 1;
	        component.set("v.slideIndex", slideIndex);
        }
    }

})