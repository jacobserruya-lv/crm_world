({
    doInit: function (cmp, event, helper) {

    },

    changeSlide: function (component, event) {
        // console.groupCollapsed('--ProductCatalogRecentlyViewedController.changeSlide--');

        event.stopPropagation();
        var dirValue = event.getSource().get("v.value");
        var slideIndex = component.get("v.slideIndex");
        var slides = component.get("v.recentlyViewedProducts");
        var slideItemCount = component.get('v.slideItemCount');
        var newSlide = slideIndex;

        if (dirValue === 'next' && slideIndex < (slides.length - (slideItemCount / 2))) {
            newSlide = (slideIndex + (slideItemCount / 2));
        } else if (dirValue === 'prev' && slideIndex >= (slideItemCount / 2)) {
            newSlide = (slideIndex - (slideItemCount / 2));
        } else if (dirValue >= 0 && dirValue <= (slides.length - (slideItemCount / 2))) {
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
    itemViewed: function (component, event, helper) {
        // console.groupCollapsed('--ProductCatalogRecentlyViewedController.itemViewed--');

        var selectedProduct = event.getParam('product');
        var recentlyViewedProducts = component.get('v.recentlyViewedProducts');
        var viewedItem = {};

        if (selectedProduct) {
            for(var i=0; i<recentlyViewedProducts.length; i++) {
                if(recentlyViewedProducts[i].Sku == selectedProduct.sku){
                    recentlyViewedProducts.splice(i,1);
                }
            }

            viewedItem.Sku = selectedProduct.sku;
            if (selectedProduct['image1Url']) {
                viewedItem.Value = selectedProduct['image1Url'].split(' ').join('%20');
            }
            // console.log(viewedItem);
            // console.table(recentlyViewedProducts);

            recentlyViewedProducts.push(viewedItem);

            component.set('v.recentlyViewedProducts', recentlyViewedProducts);

            var maxSlides = component.get('v.slideItemCount');
            if (recentlyViewedProducts.length > maxSlides) {
                var slidePage = Math.floor((recentlyViewedProducts.length - 1) / (maxSlides / 2));
                var slideIndex = (slidePage - 1) * (maxSlides / 2);
                component.set('v.slideIndex', slideIndex);
            }
        }
        // console.groupEnd();
    },
})