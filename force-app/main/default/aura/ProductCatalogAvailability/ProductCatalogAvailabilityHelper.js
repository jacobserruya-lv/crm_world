({

    clearProductAvailability: function(cmp, clearDefault) {
        //console.log('clearing.... ');
        if(clearDefault) {
            cmp.set('v.defaultAvailability', null);
        }
        cmp.set('v.selectedAvailabilities', []);
        cmp.set('v.nearbyAvailabilities', []);
        cmp.set('v.showSelectedStores', false);
        cmp.set('v.showNearbyStores', false);
        cmp.set('v.noProductAvailabilities', false);
        cmp.set('v.selectedAvailabilitiesFilterd', []);
        cmp.set('v.nearbyAvailabilitiesFilterd', []);
        cmp.set('v.searchStore','');
        /*cmp.set('v.digitalPrice', -1);
        cmp.set('v.digitalCurrency','');*/
    },


    getCurrentUserDefaultStore: function(cmp,helper) {
        var action = cmp.get("c.getUserDefaultStoreCode");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.userStores", result);
                cmp.set("v.lastSelectedStore", result.lastDigitalStore ? result.lastDigitalStore : result.defaultStore);

            } else if (state === "ERROR") {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
    },


    handleError: function(response) {
        var errors = response.getError();
        if(errors[0] && errors[0].message){
            console.error("Error Message: " + errors[0].message);
        }
        else {
            console.error("Unknown error");
        }
    },

    prepareAvailabilities: function(cmp, helper, productAvailabilities, productPrices) {
        console.group(cmp.getType() + '.h.prepareAvailabilities', Array.from(productAvailabilities), Object.assign({},productPrices));
        console.group(cmp.getType() + '.h.prepareAvailabilities');
        //console.log('productPrices', productPrices);
        var userStores = cmp.get('v.userStores');
        var selectedStores = cmp.get('v.selectedStores');
        var digitalPrice = cmp.get('v.digitalPrice');
        var digitalCurrency = cmp.get('v.digitalCurrency');
        //var defaultStore = userStores.defaultStore;
        var lastSelectedDigitalStore = userStores.lastDigitalStore;
        var inCm;
        var noStock = true;
        var defaultAvailability = cmp.get('v.defaultAvailability');
        console.log('defaultAvailability', defaultAvailability);


        var nearbyAvailabilities = [], selectedAvailabilities = []/*, defaultAvailability*/;
        //var price = -1, currency = '';
        productAvailabilities = productAvailabilities.sort(function(x, y) { return x.isDigital == y.isDigital ? 0 : x.isDigital ? -1 : 1 });

        for(var i = 0; i < productAvailabilities.length; i++) {
            if(productAvailabilities[i].isDefault) {
                if (productAvailabilities[i].store.retailStoreId != lastSelectedDigitalStore) {
                    productAvailabilities[i].isLastDigital = true;
                    lastSelectedDigitalStore = productAvailabilities[i].store.retailStoreId;
                }
                //defaultAvailability = productAvailabilities[i];

                if (productAvailabilities[i].csc || productAvailabilities[i].online) {
                    noStock = false;
                }

                //console.log('digitalPrice', digitalPrice);
                //console.log('digitalCurrency', digitalCurrency);

                if (defaultAvailability == null){
                    if (digitalPrice > -1) {
                        productAvailabilities[i].price = digitalPrice;
                        productAvailabilities[i].currencyCoin = digitalCurrency;
                    }
                    else {
                        
                        if (productPrices[productAvailabilities[i].store.countryCode]) {
                            
                            productAvailabilities[i].price = productPrices[productAvailabilities[i].store.countryCode]['R'].price;
                            productAvailabilities[i].currencyCoin = productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin;
                            //console.log('productPrices[productAvailabilities[i].store.countryCode].currencyCoin', productPrices[productAvailabilities[i].store.countryCode]['R'].currencyCoin);
                        }
                    }
                }
                else
                {
                    productAvailabilities[i].price = defaultAvailability.price;
                    productAvailabilities[i].currencyCoin = defaultAvailability.currencyCoin;
                }


                console.log('productAvailabilities[i]', productAvailabilities[i]);
                cmp.set('v.defaultAvailability', productAvailabilities[i]);
                productAvailabilities.splice(i, 1);
                break;
            }
        }


        if(selectedStores && ((selectedStores.length === 2 && (selectedStores[0] === lastSelectedDigitalStore || selectedStores[1] === lastSelectedDigitalStore)) || selectedStores.length === 1)) {
            for(i = 0; i < productAvailabilities.length; i++) {
                if(productPrices[productAvailabilities[i].store.countryCode]) {
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
                if(productAvailabilities[i].store.retailStoreId.toUpperCase() === selectedStores[0].toUpperCase() ||
                    (selectedStores[1] && productAvailabilities[i].store.retailStoreId.toUpperCase() === selectedStores[1].toUpperCase())) {
                    selectedAvailabilities.push(productAvailabilities[i]);

                }
                else if(productAvailabilities[i].isNearby) {
                    nearbyAvailabilities.push(productAvailabilities[i]);
                }

                if(productAvailabilities[i].inStock > 0 && productAvailabilities[i].inStock != null  ) {
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
        else if(selectedStores && selectedStores.length > 1) {
            for(i = 0; i < productAvailabilities.length; i++) {
                if(productPrices[productAvailabilities[i].store.countryCode]) { 
                    console.log('is duty free' , productAvailabilities[i].store.DutyFree);
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
                if(selectedStores.findIndex(function(storeName) { return productAvailabilities[i].store.retailStoreId.toUpperCase() === storeName.toUpperCase(); }) > -1) {
                    selectedAvailabilities.push(productAvailabilities[i]);
                }
                if(productAvailabilities[i].inStock > 0 || productAvailabilities[i].inStock != null  ) {
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

        var event = $A.get('e.c:ProductCatalogGetProductNoStock');
        event.setParams({
            'myProductNoStock': noStock,
        });
        event.fire();

        helper.hideSpinner(cmp);
        //console.groupEnd();
    },

    hidePopover: function(cmp, availabilities, type) {
        for(var i = 0; i < availabilities.length; i++) {
            availabilities[i].displayPopover = false;
        }
        cmp.set('v.' + type, availabilities);
    },


    showSpinner : function(cmp) {
        cmp.set("v.toggleSpinner", true);
    },


    hideSpinner : function(cmp) {
        cmp.set("v.toggleSpinner", false);
    },

    handleSpinner: function(cmp, helper, show) {
        show ? helper.showSpinner(cmp) : helper.hideSpinner(cmp);
    },

    productRequest: function(cmp, event, helper) {
        var product = cmp.get("v.product");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Case",
            "defaultFieldValues": {
                'Subject' : 'Product Request',
                'Description' : product.sku,
                'Status': 'New',
                'Type': 'Featured Request',
            }

        });
        createRecordEvent.fire();
    },

    compareStock: function (a, b) {

        //console.log('comparing')
        var comparison = 0;
        if (a.storeName > b.storeName) {
            comparison = 1;
        } else if (a.storeName < b.storeName) {
            comparison = -1;
        }
        return comparison;
    },
    

})