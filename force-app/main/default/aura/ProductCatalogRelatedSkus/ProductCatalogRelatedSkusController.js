({
    handleClose: function (component, event, helper) {
        $A.util.addClass(component, 'pc-related-skus_closed');
    },
    next: function(component) {
        var familySlideIndex = component.get("v.familySlideIndex");
        var slides = component.get("v.productVariations.FamilySku");
        if (familySlideIndex + 1 < slides.length) {
            familySlideIndex = familySlideIndex + 1;
            component.set("v.familySlideIndex", familySlideIndex);
        }
    },

    prev: function(component) {
        var familySlideIndex = component.get("v.familySlideIndex");
        if (familySlideIndex > 0) {
            familySlideIndex = familySlideIndex - 1;
            component.set("v.familySlideIndex", familySlideIndex);
        }
    },

    changeFamilySlide: function (component, event) {
        event.stopPropagation();
        var dirValue = event.getSource().get("v.value");
        var familySlideIndex = component.get("v.familySlideIndex");
        var slides = component.get("v.productVariations.FamilySku");
        var newSlide = familySlideIndex;

        if (dirValue === 'next' && familySlideIndex < (slides.length - 1)) {
            newSlide = (familySlideIndex + 1);
        } else if (dirValue === 'prev' && familySlideIndex > 0) {
            newSlide = (familySlideIndex - 1);
        } else if (dirValue >= 0 && dirValue <= (slides.length - 1)) {
            newSlide = dirValue;
        }

        if (newSlide !== familySlideIndex) {
            component.set('v.familySlideIndex', newSlide);
        }
    },

});