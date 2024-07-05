({
    getProductVariation: function (cmp, event, helper) {
        cmp.set('v.variantFilter', '');
        cmp.set('v.filterTitle', '');
        cmp.set('v.listVariationFiltered', []);
        cmp.set('v.isFiltered', false);
        helper.getProductVariation(cmp, event, helper);
    },

    resetFilters: function (cmp, event, helper) {
        cmp.set('v.variantFilter', '');
        cmp.set('v.filterTitle', '');
        cmp.set('v.listVariationFiltered', []);
        cmp.set('v.isFiltered', false);
        helper.updateVariationsFilter(cmp, event, helper);
    },

    updateFilterList: function (cmp, event) {
        const filterTitle = event.getParam('filterTitle');
        const variantfilter = event.getParam('variantfilter');
        const variantfilterImg = event.getParam('variantFilterImg');
        const productVariationsData = cmp.get('v.productVariationsData');
        const variations = productVariationsData.variations;
        let isFiltered = cmp.get('v.isFiltered');
        let variationsColors = cmp.get('v.productColors');
        let variationsSkin = cmp.get('v.listProductSkinMaterials');
        let variationsMaterial = cmp.get('v.productMaterials');
        let newVariantionsColors = [];
        let newVariantionsSkin = [];
        let newVariantionsMaterials = [];
        let listVariationFiltered = cmp.get('v.listVariationFiltered');;
        if (variations) {

            if (filterTitle == 'Color') {
                newVariantionsColors = variationsColors.filter(el => el.Name == variantfilter);
                if (listVariationFiltered.length > 0) {
                    listVariationFiltered = listVariationFiltered.filter(el =>
                        el.MarketingColorName == variantfilter
                    );
                } else {
                    listVariationFiltered = variations.filter(el =>
                        el.MarketingColorName == variantfilter);
                }
                listVariationFiltered.map((el, index) => {
                    if (!newVariantionsSkin.some(v => v.Name == el.SkinMaterial) && el.SkinMaterial) {
                        newVariantionsSkin = [...newVariantionsSkin,
                        { 'Name': el.SkinMaterial, 'img': null }];
                    }
                    if (!newVariantionsMaterials.some(v => v.Name == el.materialTypeName)) {
                        newVariantionsMaterials = [...newVariantionsMaterials,
                        { 'Name': el.materialTypeName, 'img': el.materialImg }];
                    }
                })
            }

            if (filterTitle == 'Material') {
                newVariantionsMaterials = variationsMaterial.filter(el => el.Name == variantfilter);
                if (listVariationFiltered.length > 0) {
                    listVariationFiltered = listVariationFiltered.filter(el =>
                        el.materialTypeName == variantfilter
                    );
                } else {
                    listVariationFiltered = variations.filter(el =>
                        el.materialTypeName == variantfilter);
                } listVariationFiltered.map((el, index) => {
                    if (!newVariantionsSkin.some(v => v.Name == el.SkinMaterial) && el.SkinMaterial) {
                        newVariantionsSkin = [...newVariantionsSkin,
                        { 'Name': el.SkinMaterial, 'img': null }];
                    }
                    if (!newVariantionsColors.some(v => v.Name == el.MarketingColorName)) {
                        newVariantionsColors = [...newVariantionsColors,
                        { 'Name': el.MarketingColorName, 'img': el.colorImg }];
                    }
                })
            }

            if (filterTitle == 'Material Sub-type') {
                newVariantionsSkin = variationsSkin.filter(el => el.Name == variantfilter);
                if (listVariationFiltered.length > 0) {
                    listVariationFiltered = listVariationFiltered.filter(el =>
                        el.SkinMaterial == variantfilter
                    );
                } else {
                    listVariationFiltered = variations.filter(el =>
                        el.SkinMaterial == variantfilter);
                } listVariationFiltered.map((el, index) => {
                    if (!newVariantionsColors.some(v => v.Name == el.MarketingColorName)) {
                        newVariantionsColors = [...newVariantionsColors,
                        { 'Name': el.MarketingColorName, 'img': el.colorImg }];
                    }
                    if (!newVariantionsMaterials.some(v => v.Name == el.materialTypeName)) {
                        newVariantionsMaterials = [...newVariantionsMaterials,
                        { 'Name': el.materialTypeName, 'img': el.materialImg }];
                    }
                })
            }

            isFiltered = true;

            variationsColors = newVariantionsColors;
            variationsSkin = newVariantionsSkin;
            variationsMaterial = newVariantionsMaterials;
        }

        cmp.set('v.listProductSkinMaterials', variationsSkin);
        cmp.set('v.productMaterials', variationsMaterial);
        cmp.set('v.productColors', variationsColors);
        cmp.set('v.variantFilter', variantfilter);
        cmp.set('v.filterTitle', filterTitle);
        cmp.set('v.listVariationFiltered', listVariationFiltered);
        cmp.set('v.isFiltered', isFiltered);

    },

    handleFilterToggle: function (component) {
        component.set('v.filtersShown', !component.get('v.filtersShown'));
    },
})