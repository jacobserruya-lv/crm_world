({
    setSlideWidth: function (component) {
    	//---- Begin MTOU: get custom settings info
        //var slideWidth = component.find("gallery").getElement().offsetWidth;
        //component.set("v.slideWidth", slideWidth);
        var action =  component.get("c.getProductCarouselWidth");
        action.setCallback(this, function(response)
        {
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('result: ' + result);
                component.set("v.slideWidth", result);
            }
        });
        $A.enqueueAction(action);  
        // End MTOU      
    }
})