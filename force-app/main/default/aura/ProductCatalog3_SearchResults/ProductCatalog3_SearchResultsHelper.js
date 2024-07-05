({
    queryTimeout: null,

    // filterChange: function (cmp, event, helper) {
    //     const productsSkusSearch = cmp.get('v.productsSkusSearch');

    //     console.log({ productsSkusSearch })

    //     if (productsSkusSearch.length > 0) {
    //         helper.getProductsCatalog(cmp, event, helper, productsSkusSearch);
    //     } else {
    //         clearTimeout(this.queryTimeout)
    //         cmp.set('v.productsMap', []);
    //         cmp.set('v.productsSkusSearch', []);
    //         cmp.set('v.totalResult', '');
    //         cmp.set('v.isLoading', false);
    //     }
    // },

    getProductsCatalog: function (component, event, helper, listSkusResults) {
        const searchTerm = component.get('v.searchTerm');

        var action = component.get('c.getProductsCatalogFiltered');

        if (searchTerm.length > 0 && listSkusResults.length > 0) {

            component.set('v.isLoading', true);
            // if (action != undefined) {

            action.setParams({
                'listSkus': listSkusResults,
            });
            action.setCallback(this, function (result) {
                var state = result.getState();
                console.log({ state })
                if (state === 'SUCCESS') {
                    var pageResult = result.getReturnValue();
                    helper.formateData(pageResult, component);

                } else if (state === 'ERROR') {
                    helper.handleError(result);
                    component.set('v.isLoading', false);

                } else {
                    console.error('Unknown error');
                    component.set('v.isLoading', false);

                }
            });
            $A.enqueueAction(action);

        } else {
            component.set('v.productsMap', []);
            component.set('v.productsListSF', []);
            component.set('v.totalResult', 0);
            component.set('v.isLoading', false);

        }
    },

    formateData: function (pageResult, component) {
        component.set('v.totalResult', pageResult.total);
        var productsMap = component.get('v.productsMap') || {};
        for (var product of pageResult.products) {
            var slides = [];

            for (var i = 1; i <= 5; i++) {
                if (product['image' + i + 'Url']) {
                    var imgUrl = product['image' + i + 'Url'].split(' ').join('%20');
                    slides.push(imgUrl);
                    product['image' + i + 'Url'] = imgUrl;
                }
            }
            product.images = slides;
            productsMap[product.id] = product;
        }
        component.set('v.productsMap', productsMap);
        component.set('v.productsListSF', pageResult.products);
        // component.set('v.productsSkusSearch', pageResult.products);
        const productsListSF = component.get('v.productsListSF');
        console.log({ productsListSF })

        if (productsListSF.length == 1) {
            var myEvent = $A.get('e.c:ProductCatalog3_productClickEvent');
            myEvent.setParams({ 'product': productsListSF[0], 'fromWhere': '' });
            myEvent.fire();
            component.set('v.isLoading', false);
            // return
        }

        component.set('v.isLoading', false);

    },

    handleError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    }
})