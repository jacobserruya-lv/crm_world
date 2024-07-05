({
    getProducts: function (cmp, event, helper, page, searchKey, advencedSearch) {
        // console.group('--ProductCatalogListHelper.getProducts--');
        var action;
        if(advencedSearch){
            console.log('search referential');
            action = cmp.get('c.getReferentialProduct');
        }else{
            action = cmp.get('c.getAllProductCatalogs');
        }
        var pageSize = cmp.get('v.pageSize');
        var stores = cmp.get('v.selectedStores');
        //var searchKey = cmp.get('v.searchKey');
        //action.setStorable();
        action.setParams({
            'searchKey': searchKey,
            'pageSize': pageSize || 9,
            'pageNumber': page || 1,
            'stores': stores,
        });
        helper.showSpinner(cmp);
        if (searchKey.length > 1) {
            action.setCallback(this, function (result) {
                var state = result.getState();
                helper.hideSpinner(cmp);
                if (state === 'SUCCESS') {
                    var pageResult = result.getReturnValue();
                    cmp.set('v.productsStock', '');
                    cmp.set('v.productsPrices', '');
                    cmp.set("v.productVariations", '');
                    cmp.set('v.products', pageResult.products);
                    cmp.set('v.page', pageResult.page);
                    cmp.set('v.total', pageResult.total);
                    cmp.set('v.pages', Math.ceil(pageResult.total / pageSize));

                    var myEvent = $A.get('e.c:ProductCatalogGetResultsEvent');
                    myEvent.setParams({'searchKey': searchKey, 'total': pageResult.total});
                    myEvent.fire();
                    /*if (page > 1  && searchKey.length >= 2 ){
                        helper.getStock(cmp,event,helper);
                    }*/

                    //if only one product
                    //console.log('stores.length', stores.length);
                    //console.log('max', cmp.get('v.maxMyList'));
                    if (pageResult.products.length == 1 && stores.length <= cmp.get('v.maxMyList') + 1) {
                        //cmp.set('v.selectedProduct',pageResult.products[0]);
                        /*var variantStock = cmp.get('v.productVariationsStock');
                        var myStock;
                        var productStock;*/

                        var myProduct = pageResult.products[0];
                        var myEvent2 = $A.get('e.c:ProductCatalogGetResultsEvent');
                        myEvent2.setParams({
                            'searchKey': searchKey,
                            'total': pageResult.total,
                            'selectedProduct': myProduct
                        });
                        myEvent2.fire();
                        helper.itemClicked(cmp, event, helper, pageResult.products[0]);
                    }
                }
                else if (state === 'ERROR') {
                    helper.handleError(result);
                }
                else {
                    console.error('Unknown error');
                }
            });
            $A.enqueueAction(action);
        }
        // console.groupEnd();
    },

    clearProductAvailability: function () {
        var myEvent = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
        myEvent.setParams({'product': null, 'productClicked': true});
        myEvent.fire();
    },

    clearProductSummary: function () {
        var myEvent = $A.get('e.c:ProductCatalogGetSummaryEvent');
        myEvent.setParams({
            'product': null,
            'productClicked': true,
            'productVariations': [],
            'productVariationsStock': []
        });
        myEvent.fire();
    },

    handleError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    },

    showSpinner: function (cmp) {
        cmp.set('v.toggleSpinner', true);
    },

    hideSpinner: function (cmp) {
        cmp.set('v.toggleSpinner', false);
    },

    showError: function (cmp) {
        cmp.set("v.showErrorMsg", true);
    },

    hideError: function (cmp) {
        cmp.set("v.showErrorMsg", false);
    },

    getProductVariant: function (cmp, event, helper) {
        var myEvent = $A.get('e.c:ProductCatalogSummarySpinnerEvent');
        myEvent.setParams({'show': true});
        myEvent.fire();
        var selectedProduct = cmp.get('v.selectedProduct');
        // console.log('selectedProduct ' , selectedProduct.sku);
        var digitalStore = cmp.get("v.digitalStore");
        var action = cmp.get('c.getProductVariantData');
        var actionParams = {
            'sku': selectedProduct.sku,
            'digitalStore' : digitalStore
        };
        //action.setStorable();
        action.setParams(actionParams);

        action.setCallback(this, function (result) {
            //console.group(cmp.getType() + '.c.getProductVariantData', actionParams)
            var state = result.getState();
            if (state === 'SUCCESS') {
                var productVariation = result.getReturnValue();
                //console.log('return: ',productVariation);
                if(productVariation !=null && productVariation.Size != null){
                    productVariation.Size = (productVariation.Size).sort(helper.compareSize);
                }
                cmp.set('v.productVariations', productVariation);
                var digitalStoresForAtgPrice = cmp.get('v.digitalStoresForAtgPrice');
               // console.log('digitalStoresForAtgPrice:',digitalStoresForAtgPrice);
                if(digitalStoresForAtgPrice.indexOf(digitalStore) > -1 && productVariation != null) {
                        var myEvent2 = $A.get('e.c:ProductCatalogUpdateDigitalPriceEvent');
                        myEvent2.setParams({
                            'digitalPrice': productVariation.price,
                            'digitalCurrency': productVariation.currencyCoin
                        });
                        myEvent2.fire();
                    }
                    else {
                        var myEvent3 = $A.get('e.c:ProductCatalogUpdateDigitalPriceEvent');
                        myEvent3.setParams({
                            'digitalPrice': -1,
                            'digitalCurrency': ''
                        });
                        myEvent3.fire();
                    }

                var myEvent = $A.get('e.c:ProductCatalogGetSummaryEvent');
                myEvent.setParams({
                    'productVariations': productVariation,
                    'product': selectedProduct,
                    'productClicked': true,
                    'productVariationsStock': []
                });
                myEvent.fire();
            }
            else if (state === 'ERROR') {
                helper.handleError(result);
            }
            else {
                console.error('Unknown error');
            }
            console.groupEnd();
        });
        $A.enqueueAction(action);
    },

    getInitData: function(cmp, event, helper) {
        var action = cmp.get('c.getInitData');
        //var action = cmp.get('c.getDigitalStoresAtgPrice');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var initData = response.getReturnValue();
                cmp.set('v.digitalStoresForAtgPrice', initData['digitalStoreCodesAtgPrice']);
                cmp.set('v.myFavorites', initData['MyFavorites']);
            }
            else if(state === "ERROR") {
                helper.handleError(response);
            }
        });

        $A.enqueueAction(action);

    },

    compareSize: function (a, b) {
        var comparison = 0;
        if (a.Value > b.Value) {
            comparison = 1;
        } else if (a.Value < b.Value) {
            comparison = -1;
        }
        return comparison;
    },
    
    itemClicked: function (cmp, event, helper, product=null) {
        console.group(cmp.getType() + '.h.itemClicked2');
        cmp.set('v.isInProccess', true);
        var stores = cmp.get('v.selectedStores');
        var products = cmp.get('v.products');
        var digitalStore = cmp.get('v.digitalStore');
        var myEvent2 = $A.get('e.c:ProductCatalogUpdateDigitalPriceEvent');
        myEvent2.setParams({
            'digitalPrice': -1,
            'digitalCurrency': null
        });
        myEvent2.fire();
        var selectedProduct;
        if(product){
            selectedProduct = product;
        }
        else if (event.getParam('product')) {
            console.log('event product',event.getParam('product'));
            selectedProduct = event.getParam('product');
            console.log('event product',selectedProduct);
        }

        else if (cmp.get('v.selectedProduct')) {
            var prevProduct = cmp.get('v.selectedProduct');
            //var products = cmp.get('v.products');
            selectedProduct = products.find(function (product) {
                return product.sku === prevProduct.sku;
            });
            console.log('prevProduct ', prevProduct);
            console.log('selected ', selectedProduct);
        }
        else {
            selectedProduct = {};
        }
        selectedProduct = Object.assign({},selectedProduct);
        //console.log('selectedProduct1', Object.assign({},selectedProduct));
        if (selectedProduct && Object.keys(selectedProduct).length) {
		    if (selectedProduct && selectedProduct.sku != cmp.get('v.selectedProduct').sku) {


                var myEvent = $A.get('e.c:ProductCatalogAvailabilitySpinnerEvent');
                myEvent.setParams({'show': true});
                myEvent.fire();
                var exeStock = cmp.get('c.getProductsAvailabilitiesByProductId');
                var exePrice = cmp.get('c.getProductsPricesByProductId');
                var exeVariation = cmp.get('c.getProductVariantData');

                exePrice.setParams({'stores': stores, 'products': selectedProduct.sku});
                exePrice.setBackground();
                exeStock.setParams({'stores': stores, 'products': selectedProduct.sku});
                exeStock.setBackground();

                exeVariation.setParams({'sku': selectedProduct.sku, 'digitalStore': digitalStore});
                exeVariation.setBackground();
                cmp.set('v.selectedProduct', selectedProduct);

                if(selectedProduct.isPersoProduct && selectedProduct.stockRequest == false){
                    Promise.all([
                        helper.serverSideCall(cmp, exePrice, 'price'),
                        helper.serverSideCall(cmp, exeVariation, 'variation')
                    ]).then($A.getCallback(
                        function (response) {
                            //console.log(response);
                            //console.log('selected data', selectedProduct.sku);
                            cmp.set('v.productsPrices', response[0]);
                            cmp.set('v.productVariations', response[1]);
                            helper.updateProductVariant(cmp, event, helper);
                           
                                //console.log($A.get('e.c:ProductCatalogGetAvailabilityEvent'));
                            var myEvent = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
                            myEvent.setParams({
                                'product': selectedProduct,
                                'productClicked': true,
                                'productsStock': [],
                                'selectedStores': stores,
                                'productsPrices' : cmp.get('v.productsPrices')
                            });
                            myEvent.fire();
            
                            //cmp.set('v.productsStock', pageResult);
                            //cmp.set('v.itemClickedStock', pageResult);
            
                            //helper.getProductVariant(cmp, event, helper);
                        }
                        
                    )).catch(
                        function (error) {
                            console.log(error);
                        }
                    );

                }else{

                    Promise.all([
                        helper.serverSideCall(cmp, exeStock, 'stock'),
                        helper.serverSideCall(cmp, exePrice, 'price'),
                        helper.serverSideCall(cmp, exeVariation, 'variation')
                    ]).then($A.getCallback(
                        function (response) {
                            //console.log(response);
                            //console.log('selected data', selectedProduct.sku);

                            cmp.set('v.productsPrices', response[1]);
                            cmp.set('v.productVariations', response[2]);
                            helper.updateStockData(cmp, event, helper, response[0], selectedProduct);
                            helper.updateProductVariant(cmp, event, helper);
                        }
                    )).catch(
                        function (error) {
                            console.log(error);
                        }
                    );
                }
            } /*else {
                helper.clearProductAvailability();
                helper.clearProductSummary();
                cmp.set('v.selectedProduct', {});
            }*/

       }else{
            helper.clearProductAvailability();
            helper.clearProductSummary();
            cmp.set('v.selectedProduct', {});
        }
        //cmp.set('v.selectedProduct', selectedProduct);
        //console.groupEnd();
        
    },

    serverSideCall : function(component,action, name) {
        var currentdate = new Date();
        var datetime = currentdate.getDate() + "/"
            + (currentdate.getMonth()+1)  + "/"
            + currentdate.getFullYear() + " @ "
            + currentdate.getHours() + ":"
            + currentdate.getMinutes() + ":"
            + currentdate.getSeconds();
        console.log('my action start time', name + ' ' +datetime);

        return new Promise($A.getCallback(function(resolve, reject) {
            action.setCallback(this,
                function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var currentdateEND = new Date();
                        var datetimeEND = currentdateEND.getDate() + "/"
                            + (currentdateEND.getMonth()+1)  + "/"
                            + currentdateEND.getFullYear() + " @ "
                            + currentdateEND.getHours() + ":"
                            + currentdateEND.getMinutes() + ":"
                            + currentdateEND.getSeconds();
                        console.log('my action END time', name + ' ' +datetimeEND);
                        resolve(response.getReturnValue());
                    } else {
                        reject(new Error(response.getError()));
                    }
                });
            $A.enqueueAction(action);
        }));
    },

    updateProductVariant: function(cmp, event, helper){
        var productVariation = cmp.get('v.productVariations');
        //productVariation = Object.assign({}, productVariation);
        //console.log('productVariation', productVariation);
        var digitalStore = cmp.get('v.digitalStore');
        var selectedProduct = cmp.get('v.selectedProduct');
        selectedProduct = Object.assign({},selectedProduct);
        //cmp.set('v.selectedProduct', selectedProduct);
        //console.log('updating variation', selectedProduct);
        //console.log('return: ',productVariation);
        if(productVariation !=null && productVariation.Size != null){
            productVariation.Size = (productVariation.Size).sort(helper.compareSize);
        }
        var digitalStoresForAtgPrice = cmp.get('v.digitalStoresForAtgPrice');
        if(digitalStoresForAtgPrice.indexOf(digitalStore) > -1 && productVariation != null) {
            var myEvent2 = $A.get('e.c:ProductCatalogUpdateDigitalPriceEvent');
            myEvent2.setParams({
                'digitalPrice': productVariation.price,
                'digitalCurrency': productVariation.currencyCoin
            });
            myEvent2.fire();
        }
        else {
            var myEvent3 = $A.get('e.c:ProductCatalogUpdateDigitalPriceEvent');
            myEvent3.setParams({
                'digitalPrice': -1,
                'digitalCurrency': ''
            });
            myEvent3.fire();
        }

        var myEvent = $A.get('e.c:ProductCatalogGetSummaryEvent');
        myEvent.setParams({
            'productVariations': productVariation,
            'product': selectedProduct,
            'productClicked': true,
            'productVariationsStock': []
        });
        myEvent.fire();
    },

     updateStockData: function(cmp, event, helper, pageResult, product) {
        //console.log('pageResult', pageResult);
        if (pageResult == null) {
            cmp.set('v.wsError', true);
            cmp.set('v.errorCode', 'unknown');
            helper.clearProductSummary();
            helper.clearProductAvailability();
            var myEvent = $A.get('e.c:ProductCatalogAvailabilitySpinnerEvent');
            myEvent.setParams({'show': false});
            myEvent.fire();
            cmp.set('v.selectedProduct', {});
        }
        else if (pageResult['ERROR']) {
            console.error('myError is ', pageResult['ERROR'][0].errorCode);
            cmp.set('v.wsError', true);
            cmp.set('v.errorCode', pageResult['ERROR'][0].errorCode);
            helper.clearProductSummary();
            helper.clearProductAvailability();
            var myEvent1 = $A.get('e.c:ProductCatalogAvailabilitySpinnerEvent');
            myEvent1.setParams({'show': false});
            myEvent1.fire();
            cmp.set('v.selectedProduct', {});
        } else {
            //var product = cmp.get('v.selectedProduct');
            //console.log('product', product);
            var stores = cmp.get('v.selectedStores');
            //cmp.set('v.productsStock',pageResult);

            if (cmp.get('v.selectedProduct')) {
                //console.log($A.get('e.c:ProductCatalogGetAvailabilityEvent'));
                var myEvent = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
                myEvent.setParams({
                    'product': product,
                    'productClicked': true,
                    'productsStock': pageResult,
                    'selectedStores': stores,
                    'productsPrices' : cmp.get('v.productsPrices')
                });
                myEvent.fire();

                //cmp.set('v.productsStock', pageResult);
                cmp.set('v.itemClickedStock', pageResult);

                //helper.getProductVariant(cmp, event, helper);
            }
        }
         
         cmp.set('v.isInProccess', false);
         cmp.set("v.emptyProductStocks", false);
    },
})