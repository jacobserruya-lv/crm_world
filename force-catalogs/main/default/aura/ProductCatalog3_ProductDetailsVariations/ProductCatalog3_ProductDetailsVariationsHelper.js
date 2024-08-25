({
    getProductVariation: function (cmp, event, helper) {
        var product = cmp.get('v.product');
        var exeVariation = cmp.get('c.getVariationsProducts');

        exeVariation.setParams({ 'productS': JSON.stringify(product) });
        exeVariation.setCallback(this, function (result) {
            var state = result.getState();
            if (state === 'SUCCESS') {
                var pageResult = result.getReturnValue();
                cmp.set('v.productVariationsData', pageResult);
                helper.updateVariationsFilter(cmp, event, helper);
            }
            else if (state === 'ERROR') {
                helper.handleError(result);
            }
            else {
                console.error('Unknown error');
            }
        });
        $A.enqueueAction(exeVariation);
    },

    handleError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    },

    updateVariationsFilter: function (cmp, event, helper) {
        const productVariationsData = cmp.get('v.productVariationsData');
        const product = cmp.get('v.product');

        if (productVariationsData) {
            const variations = productVariationsData.variations;

            let variationsColors = [];
            let variationsMaterials = [];
            let variationsSkinMaterials = [];

            if (variations.length > 0) {
                if (product.materialTypeName) {
                    variationsMaterials.unshift({ 'Name': product.materialTypeName, 'img': product.materialImg });
                }
                if (product.MarketingColorName) {
                    variationsColors.unshift({ 'Name': product.MarketingColorName, 'img': product.colorImg });
                }
                if (product.SkinMaterial) {
                    variationsSkinMaterials.unshift({ 'Name': product.SkinMaterial, 'img': null });
                }

                variations.map((variation, index) => {
                    if (variation.MarketingColorName && !(variationsColors.some(v => v.Name == variation.MarketingColorName))) {
                        variationsColors.push({ 'Name': variation.MarketingColorName, 'img': variation.colorImg });
                    }
                    if (variation.materialTypeName && !(variationsMaterials.some(v => v.Name == variation.materialTypeName))) {
                        variationsMaterials.push({ 'Name': variation.materialTypeName, 'img': variation.materialImg });
                    }
                    if (variation.SkinMaterial && !(variationsSkinMaterials.some(v => v.Name == variation.SkinMaterial))) {
                        variationsSkinMaterials.push({ 'Name': variation.SkinMaterial, 'img': null });
                    }
                    return variationsColors, variationsMaterials, variationsSkinMaterials;
                })

                cmp.set('v.productMaterials', variationsMaterials);
                cmp.set('v.productColors', variationsColors);
                cmp.set('v.listProductSkinMaterials', variationsSkinMaterials);
            }
        } else {
            cmp.set('v.productMaterials', []);
            cmp.set('v.productColors', []);
            cmp.set('v.listProductSkinMaterials', []);

        }
    }
})