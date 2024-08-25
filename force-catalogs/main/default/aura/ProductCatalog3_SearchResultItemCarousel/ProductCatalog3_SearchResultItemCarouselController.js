({
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
    },

    changeScreens: function (component, event) {
        event.stopPropagation();
        var dirValue = event.getSource().get("v.value");
        var slideIndex = component.get("v.slideIndex");
        var slides = component.get("v.slides");
        var newSlide = slideIndex;

        if (dirValue === 'next' && slideIndex < (slides.length - 1)) {
            newSlide = (slideIndex + 1);
        } else if (dirValue === 'prev' && slideIndex > 0) {
            newSlide = (slideIndex - 1);
        } else if (dirValue >= 0 && dirValue <= (slides.length - 1)) {
            newSlide = dirValue;
        }

        if (newSlide !== slideIndex) {
            component.set('v.slideIndex', newSlide);
        }
    },

    openProduct:function(cmp,event,helper) {
		//console.log('openFavorite');
		var product = cmp.get('v.product');
		var myEvent = $A.get('e.c:ProductCatalog3_productClickEvent');
        myEvent.setParams({ 'product': product});
        myEvent.fire();

	}

})