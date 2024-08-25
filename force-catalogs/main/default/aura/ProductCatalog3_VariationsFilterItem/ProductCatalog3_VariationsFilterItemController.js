({
    init: function (cmp) {
        cmp.set("v.skinMaterialButton", 'filterSkin__btn');
    },

    onmouseover: function (cmp) {
        var variant = cmp.get('v.variant');
        var myEvent = cmp.getEvent('productCatalogVariantFilterHover');
        myEvent.setParams({ 'hoverName': variant.Name });
        myEvent.fire();
    },

    onmouseout: function (cmp) {
        var myEvent = cmp.getEvent('productCatalogVariantFilterHover');
        myEvent.setParams({ 'hoverName': '' });
        myEvent.fire();
    },

    filterClick: function (cmp) {
        var variant = cmp.get('v.variant');
        var title = cmp.get('v.title');
        var myEvent = $A.get('e.c:ProductCatalogVariantFilterClickEvent');
        myEvent.setParams({ 'variantfilter': variant.Name, 'filterTitle': title, 'variantFilterImg': variant.img });
        myEvent.fire();
    }
})