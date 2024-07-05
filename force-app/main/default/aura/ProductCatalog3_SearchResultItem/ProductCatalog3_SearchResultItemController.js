({
    handleFavoriteClick: function (component, event, helper) {
        var isFav = component.get('v.favorite');
        component.set('v.favorite', !isFav);
        helper.manageFavorites(component, event, helper);
    },

    doInit: function (component, event, helper) {
        // console.group(component.getType() + '.doInit');
        helper.isInFavorites(component, event, helper);

        var product = component.get('v.product');
        if (product.status == 30 || product.status == 50 || product.status == 55 || product.status == 60){
            var labelName = 'Product_Referantial_Status_' + component.get('v.product.status') + '_Short';
            component.set('v.statusText', $A.getReference('$Label.c.' + labelName));
        }
        // console.groupEnd();
    },

    isFavorite: function(cmp, event, helper){
        helper.isInFavorites(cmp, event, helper);
    }
})