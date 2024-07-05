({
    getProductStock: function (cmp, event, helper) {
        var product = cmp.get('v.product');
        //console.log('product', product.sku);
        var stores = cmp.get('v.selectedStores');
        var digitalStore = cmp.get('v.digitalStore');
        // var digitalStoresForAtgPrice = cmp.get('v.digitalStoresForAtgPrice');
        var getDigitPrice = false;
        var exeVariation;

        var exeStock = cmp.get('c.getProductsAvailabilitiesByProductId');
        var exePrice = cmp.get('c.getProductsPricesByProductId');

        // if (digitalStoresForAtgPrice.includes(digitalStore)) {
        //     getDigitPrice = true;
        //     exeVariation = cmp.get('c.getProductVariantData');
        //     exeVariation.setParams({ 'sku': product.sku, 'digitalStore': digitalStore });
        //     exeVariation.setBackground();
        // }

        exePrice.setParams({ 'stores': stores, 'products': product.sku });
        exePrice.setBackground();
        exeStock.setParams({ 'stores': stores, 'products': product.sku });
        exeStock.setBackground();

        if (product.isPersoProduct && product.stockRequest == false) {
            Promise.all([
                helper.serverSideCall(cmp, exePrice, 'price')
            ]).then($A.getCallback(
                function (response) {
                    cmp.set('v.productsPrices', response[0]);
                    var prices = Object.values(response[0][product.sku]);
                    cmp.set('v.selectedProductPrices', prices);

                    //console.log($A.get('e.c:ProductCatalogGetAvailabilityEvent'));
                    /*var myEvent = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
                    myEvent.setParams({
                        'product': product,
                        'productClicked': true,
                        'productsStock': [],
                        'selectedStores': stores,
                        'productsPrices' : cmp.get('v.productsPrices')
                    });
                    myEvent.fire();*/

                    //cmp.set('v.productsStock', pageResult);
                    //cmp.set('v.itemClickedStock', pageResult);

                    //helper.getProductVariant(cmp, event, helper);
                }

            )).catch(
                function (error) {
                    console.log(error);
                }
            );

        } else {
            // if (getDigitPrice) {

            //     Promise.all([
            //         helper.serverSideCall(cmp, exeStock, 'stock'),
            //         helper.serverSideCall(cmp, exePrice, 'price'),
            //         helper.serverSideCall(cmp, exeVariation, 'varaition')
            //     ]).then($A.getCallback(
            //         function (response) {
            //             cmp.set('v.productsPrices', response[1]);
            //             cmp.set('v.selectedProductPrices', []);
            //             helper.updateStockData(cmp, event, helper, response[0], product);
            //             helper.updateDigitalPrice(cmp, event, helper, response[2]);
            //         }
            //     )).catch(
            //         function (error) {
            //             console.log(error);
            //         }
            //     );
            // }
            // else {
            Promise.all([
                helper.serverSideCall(cmp, exeStock, 'stock'),
                helper.serverSideCall(cmp, exePrice, 'price')
            ]).then($A.getCallback(
                function (response) {
                    cmp.set('v.productsPrices', response[1]);
                    cmp.set('v.selectedProductPrices', []);
                    helper.updateStockData(cmp, event, helper, response[0], product);
                }
            )).catch(
                function (error) {
                    console.log(error);
                }
            );
            // }
        }

    },

    serverSideCall: function (component, action, name) {
        var currentdate = new Date();
        var datetime = currentdate.getDate() + "/"
            + (currentdate.getMonth() + 1) + "/"
            + currentdate.getFullYear() + " @ "
            + currentdate.getHours() + ":"
            + currentdate.getMinutes() + ":"
            + currentdate.getSeconds();
        //console.log('my action start time', name + ' ' +datetime);

        return new Promise($A.getCallback(function (resolve, reject) {
            action.setCallback(this,
                function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var currentdateEND = new Date();
                        var datetimeEND = currentdateEND.getDate() + "/"
                            + (currentdateEND.getMonth() + 1) + "/"
                            + currentdateEND.getFullYear() + " @ "
                            + currentdateEND.getHours() + ":"
                            + currentdateEND.getMinutes() + ":"
                            + currentdateEND.getSeconds();
                        //console.log('my action END time', name + ' ' +datetimeEND);
                        resolve(response.getReturnValue());
                    } else {
                        reject(new Error(response.getError()));
                    }
                });
            $A.enqueueAction(action);
        }));
    },

    updateStockData: function (cmp, event, helper, productStocks, product) {
        //console.log('pageResult', pageResult);
        if (productStocks == null) {
            cmp.set('v.wsError', true);
            cmp.set('v.errorCode', 'unknown');
            //helper.clearProductSummary();
            //helper.clearProductAvailability();
        }
        else if (productStocks['ERROR']) {
            console.error('myError is ', productStocks['ERROR'][0].errorCode);
            cmp.set('v.wsError', true);
            cmp.set('v.errorCode', productStocks['ERROR'][0].errorCode);
        } else {
            var productsPrices = cmp.get('v.productsPrices');
            var stores = cmp.get('v.selectedStores');
            if (productStocks) {
                var stock = productStocks[product.sku];

                var prices = [];
                if (productsPrices != null)
                    prices = productsPrices[product.sku];


                if (stock) {
                    //helper.hideSpinner(cmp);
                    //cmp.set('v.noProductAvailabilities', false);
                    helper.prepareAvailabilities(cmp, helper, stock || [], prices || []);

                }
            }
        }
    },


    // updateDigitalPrice: function (cmp, event, helper, variations) {
    //     console.log({ variations })
    //     cmp.set('v.digitalPrice', variations.price);
    //     cmp.set('v.digitalCurrency', variations.currencyCoin);
    // },

    prepareAvailabilities: function (cmp, helper, productAvailabilities, productPrices) {
        console.group(cmp.getType() + '.h.prepareAvailabilities', Array.from(productAvailabilities), Object.assign({}, productPrices));
        //console.group(cmp.getType() + '.h.prepareAvailabilities');
        console.log('productPrices', productPrices);
        var userStores = cmp.get('v.userStores');
        var selectedStores = cmp.get('v.selectedStores');
        // var digitalPrice = cmp.get('v.digitalPrice');
        // var digitalCurrency = cmp.get('v.digitalCurrency');
        //var defaultStore = userStores.defaultStore;
        var lastSelectedDigitalStore = userStores.lastDigitalStore;
        var noStock = true;
        var defaultAvailability = cmp.get('v.defaultAvailability');
        //console.log('defaultAvailability', defaultAvailability);


        var nearbyAvailabilities = [], selectedAvailabilities = []/*, defaultAvailability*/;
        //var price = -1, currency = '';
        //productAvailabilities = productAvailabilities.sort(function(x, y) { return x.isDigital == y.isDigital ? 0 : x.isDigital ? -1 : 1 });
        productAvailabilities = productAvailabilities.sort(function (x, y) {
            if (x.store.country < y.store.country) {
                return -1;
            }
            else if (x.store.country > y.store.country) {
                return 1;
            }
            if (x.storeName < y.storeName) {
                return -1;
            }
            else if (x.storeName > y.storeName) {
                return 1;
            }
            return 0;
        });
        for (var i = 0; i < productAvailabilities.length; i++) {
            if (productAvailabilities[i].isDefault) {
                if (productAvailabilities[i].store.retailStoreId != lastSelectedDigitalStore) {
                    productAvailabilities[i].isLastDigital = true;
                    lastSelectedDigitalStore = productAvailabilities[i].store.retailStoreId;
                }
                //defaultAvailability = productAvailabilities[i];

                if (productAvailabilities[i].csc || productAvailabilities[i].online) {
                    noStock = false;
                }

                // console.log('digitalPrice', digitalPrice);
                // console.log('digitalCurrency', digitalCurrency);

                if (defaultAvailability.length == 0) {
                    // if (digitalPrice > -1) {
                    //     productAvailabilities[i].price = digitalPrice;
                    //     productAvailabilities[i].currencyCoin = digitalCurrency;
                    // }
                    // else {
                    //console.log('count4ry code',productAvailabilities[i].store.countryCode );
                    //console.log('productPrices[productAvailabilities[i].store.countryCode]', productPrices[productAvailabilities[i].store.countryCode]);
                    if (productPrices[productAvailabilities[i].store.countryCode]) {

                        productAvailabilities[i].price = productPrices[productAvailabilities[i].store.countryCode]['R'].price;
                        productAvailabilities[i].currencyCoin = productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin;
                        //console.log('productPrices[productAvailabilities[i].store.countryCode].currencyCoin', productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin);
                    }
                    // }
                }
                else {
                    productAvailabilities[i].price = defaultAvailability.price;
                    productAvailabilities[i].currencyCoin = defaultAvailability.currencyCoin;
                }



                //console.log('productAvailabilities[i]', productAvailabilities[i]);
                cmp.set('v.defaultAvailability', productAvailabilities[i]);
                productAvailabilities.splice(i, 1);
                break;
            }
        }


        if (selectedStores && ((selectedStores.length === 2 && (selectedStores[0] === lastSelectedDigitalStore || selectedStores[1] === lastSelectedDigitalStore)) || selectedStores.length === 1)) {
            for (i = 0; i < productAvailabilities.length; i++) {
                if (productPrices[productAvailabilities[i].store.countryCode]) {
                    var storeName = productAvailabilities[i].store.name;
                    //if(productAvailabilities[i].store.DutyFree){
                    // productAvailabilities[i].price = productPrices[productAvailabilities[i].store.countryCode]['W'].price;
                    //productAvailabilities[i].currencyCoin = productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin;
                    //}
                    //else {
                    productAvailabilities[i].price = productPrices[productAvailabilities[i].store.countryCode]['R'].price;
                    productAvailabilities[i].currencyCoin = productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin;
                    //}
                    //productAvailabilities[i].currencyCoin = productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin;
                }
                if (productAvailabilities[i].store.retailStoreId.toUpperCase() === selectedStores[0].toUpperCase() ||
                    (selectedStores[1] && productAvailabilities[i].store.retailStoreId.toUpperCase() === selectedStores[1].toUpperCase())) {
                    selectedAvailabilities.push(productAvailabilities[i]);

                }
                else if (productAvailabilities[i].isNearby) {
                    nearbyAvailabilities.push(productAvailabilities[i]);
                }

                if (productAvailabilities[i].inStock > 0 && productAvailabilities[i].inStock != null) {
                    noStock = false;
                }
            }
            nearbyAvailabilities.sort(helper.compareStock);
            cmp.set('v.showSelectedStores', selectedAvailabilities.length > 0);
            cmp.set('v.selectedAvailabilities', selectedAvailabilities);
            cmp.set('v.selectedAvailabilitiesFilterd', selectedAvailabilities);
            cmp.set('v.showNearbyStores', nearbyAvailabilities.length > 0);
            cmp.set('v.nearbyAvailabilities', nearbyAvailabilities);
            cmp.set('v.nearbyAvailabilitiesFilterd', nearbyAvailabilities);

        }
        else if (selectedStores && selectedStores.length > 1) {
            for (i = 0; i < productAvailabilities.length; i++) {
                if (productPrices[productAvailabilities[i].store.countryCode]) {
                    //console.log('is duty free' , productAvailabilities[i].store.DutyFree);
                    //if(productAvailabilities[i].store.DutyFree){
                    //productAvailabilities[i].price = productPrices[productAvailabilities[i].store.countryCode]['W'].price;
                    //productAvailabilities[i].currencyCoin = productPrices[productAvailabilities[i].store.countryCode]['W'].currencyCoin;
                    //}
                    //else {
                    productAvailabilities[i].price = productPrices[productAvailabilities[i].store.countryCode]['R'].price;
                    productAvailabilities[i].currencyCoin = productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin;
                    //}
                    //productAvailabilities[i].currencyCoin = productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin;
                }
                if (selectedStores.findIndex(function (storeName) { return productAvailabilities[i].store.retailStoreId.toUpperCase() === storeName.toUpperCase(); }) > -1) {
                    selectedAvailabilities.push(productAvailabilities[i]);
                }
                if (productAvailabilities[i].inStock > 0 || productAvailabilities[i].inStock != null) {
                    noStock = false;
                }
            }

            //console.log('selectedAvailability', selectedAvailabilities);

            //selectedAvailabilities = selectedAvailabilities.sort('inStock');
            //console.log('after sort ', selectedAvailabilities);
            //selectedAvailabilities = selectedAvailabilities.sort(helper.compareStock);
            selectedAvailabilities.sort(helper.compareStock);
            //console.log('after sort ', selectedAvailabilities);

            cmp.set('v.showSelectedStores', selectedAvailabilities.length > 0);
            cmp.set('v.selectedAvailabilities', selectedAvailabilities);
            cmp.set('v.selectedAvailabilitiesFilterd', selectedAvailabilities);
            cmp.set('v.showNearbyStores', false);
            cmp.set('v.nearbyAvailabilities', []);
            cmp.set('v.nearbyAvailabilitiesFilterd', []);
        }

        /*var event = $A.get('e.c:ProductCatalogGetProductNoStock');
        event.setParams({
            'myProductNoStock': noStock,
        });
        event.fire();*/

        //helper.hideSpinner(cmp);
        console.groupEnd();


    },

    showSpinner: function (cmp) {
        cmp.set('v.toggleSpinner', true);
    },

    hideSpinner: function (cmp) {
        cmp.set('v.toggleSpinner', false);
    },
})