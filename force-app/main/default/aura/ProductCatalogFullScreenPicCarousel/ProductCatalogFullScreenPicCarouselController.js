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
    
    handleClose : function(component) {
        component.find("overlayLib").notifyClose();
    },

    doInit: function(cmp) {
        console.log('productData ', cmp.get('v.productData'));
        console.log('product ', cmp.get('v.product'));
        var product = cmp.get('v.product');
        if (product.status == 30 || product.status == 50 || product.status == 55 || product.status == 60) {
            var statusText = $A.getReference('$Label.c.Product_Referantial_Status_' + product.status + '_Long');
            cmp.set('v.statusText', statusText);
        }

    }

})