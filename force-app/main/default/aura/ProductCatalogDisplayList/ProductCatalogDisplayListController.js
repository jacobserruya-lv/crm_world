({
    doInit : function(component, event, helper) {
        helper.getNewProducts(component, event, helper);
    },

    changeSlide: function (component, event) {
        // console.groupCollapsed('--ProductCatalogRecentlyViewedController.changeSlide--');

        event.stopPropagation();
        var dirValue = event.getSource().get("v.value");
        var slideIndex = component.get("v.slideIndex");
        var slides = component.get("v.newProducts");
        var slideItemCount = component.get('v.slideItemCount');
        var newSlide = slideIndex;

        /*if (dirValue === 'next' && slideIndex < (slides.length - (slideItemCount / 2))) {
            newSlide = (slideIndex + (slideItemCount / 2));
        } else if (dirValue === 'prev' && slideIndex >= (slideItemCount / 2)) {
            newSlide = (slideIndex - (slideItemCount / 2));
        } else if (dirValue >= 0 && dirValue <= (slides.length - (slideItemCount / 2))) {
            newSlide = dirValue;
        }*/

        if (dirValue === 'next' && slideIndex < slides.length - slideItemCount ) {
            newSlide = slideIndex + slideItemCount;
        } else if (dirValue === 'prev' && slideIndex >= slideItemCount) {
            newSlide = slideIndex - slideItemCount;
        } else if (dirValue >= 0 && dirValue <= slides.length - slideItemCount) {
            newSlide = dirValue;
        }

        // console.table({changeSlide: {dirValue:dirValue, slideIndex:slideIndex, slideItemCount:slideItemCount, newSlide:newSlide}});
        // console.table(slides);
        if (newSlide !== slideIndex) {
            // console.log('newSlide !== slideIndex');
            component.set('v.slideIndex', newSlide);
        }
        // console.groupEnd();
    },

    clearFavorites : function(component, event, helper) {
        helper.clearFavorites(component, event, helper);
    },

    removeFavorite: function(cmp, event, helper) {
        event.stopPropagation();
        if(cmp.get('v.title') == 'Favorites')
            helper.removeFavorite(cmp, event, helper);
    }
})