({
    goBack: function (cmp, event, helper) {
        //window.history.back();
        cmp.set('v.product', {});
    },

    display: function (component, event, helper) {
        helper.toggleHelper(component, event);
    },

    displayOut: function (component, event, helper) {
        helper.toggleHelper(component, event);
    },
    handleThumbClick: function (component, event, helper) {
        component.set('v.currentImageSrc', event.getSource().get('v.value'));
    },

    handleFavoriteClick: function (component, event, helper) {
        var isFav = component.get('v.favorite');
        component.set('v.favorite', !isFav);
        helper.manageFavorites(component, event, helper);
    },

    initData: function (cmp, event, helper) {

        helper.isInFavorites(cmp, event, helper);
        var product = cmp.get('v.product');
        var season = product.season;
        if (/^\d+$/.test(season)) {
            product.season = "";
            cmp.set('v.product', product);
        }

        if (product.status == 30 || product.status == 50 || product.status == 55 || product.status == 60) {
            var labelName = 'Product_Referantial_Status_' + cmp.get('v.product.status') + '_Short';
            cmp.set('v.statusText', $A.getReference('$Label.c.' + labelName));
        } else {
            cmp.set('v.statusText', '');
        }
    },

    isFavorite: function (cmp, event, helper) {
        helper.isInFavorites(cmp, event, helper);
    },

    createLook: function (cmp, event) {
        event.stopPropagation();
        var url = $A.get("{!$Label.c.ProductCatalogCreateLookLink}");
        var product = cmp.get('v.product');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url + product.sku
        });
        urlEvent.fire();
    },

    nowyours: function (cmp, event, helper) {
        event.stopPropagation();

        var product = cmp.get('v.product');

        var url = $A.get("{!$Label.c.ProductCatalogNYLink}");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url + product.name
        });
        urlEvent.fire();
    },
})