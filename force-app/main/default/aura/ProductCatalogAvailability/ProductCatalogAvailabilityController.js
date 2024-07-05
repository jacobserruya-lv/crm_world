({
    getProductCatalogAvailability : function(cmp, event, helper) {
        //console.group(cmp.getType() + '.getProductCatalogAvailability', arguments);
        helper.clearProductAvailability(cmp, true);
        var productClicked = event.getParam('productClicked');
        //var product = productClicked ? event.getParam('product') : cmp.get('v.product');
        //var productsStock = productClicked ? event.getParam('productsStock') : cmp.get('v.productsStock');
        var product = Object.assign({},event.getParam('product'));
        var productsStock = event.getParam('productsStock');
        cmp.set('v.productsStock',productsStock );

        var selectedStores = event.getParam('selectedStores');
        var lastSelectedStore = productClicked ? cmp.get('v.lastSelectedStore') : event.getParam('lastSelectedStore');

        //debugger;
        var productsPrices = Object.assign({},event.getParam('productsPrices'));

        var userStores = event.getParam('userStores');

        if(userStores) {
            cmp.set('v.userStores', userStores);
            console.log('user store avail ' ,cmp.get('v.userStores'));
        }
        if(selectedStores && !selectedStores.length) {
            cmp.set('v.noStoresSelected', true);
            return;
        }
        else {
            cmp.set('v.noStoresSelected', false);
        }

        cmp.set('v.lastSelectedStore', lastSelectedStore);
        cmp.set('v.selectedStores', selectedStores);

        cmp.set('v.productsPrices', productsPrices);

        //console.log('persoProduct', product);
       if(product.isPersoProduct && !product.stockRequest){
           var prices =  Object.values(productsPrices[product.sku]);
           cmp.set('v.selectedProductPrices',prices);
        }else{
            cmp.set('v.selectedProductPrices',[]);
        }

        //console.log('my prices', cmp.get('v.selectedProductPrices'));
        //if(product != null) {
            // console.log('in if product');
            helper.showSpinner(cmp);
            //var stock;
            if(productsStock) {
                //var stock = productsStock[product.id];
                var stock = productsStock[product.sku];

                var prices = [];
                if(productsPrices != null)
                    prices = productsPrices[product.sku];
                

                if (stock) {
                    helper.hideSpinner(cmp);
                    cmp.set('v.noProductAvailabilities', false);
                    helper.prepareAvailabilities(cmp, helper, stock || [], prices || []);

                }
                else
                {
                    // console.log('no avail');
                    cmp.set('v.noProductAvailabilities', true);
                    helper.clearProductAvailability(cmp, true);
                    helper.hideSpinner(cmp);
                }
            }
            else {
                helper.hideSpinner(cmp);
                helper.clearProductAvailability(cmp, true);

            }

        //}
        cmp.set('v.product', product);
        console.groupEnd();
    },

    setSelectedStores: function(cmp, event, helper) {
        cmp.getProductCatalogAvailability(cmp, event, helper);
    },

    doInit: function(cmp, event, helper) {
        helper.getCurrentUserDefaultStore(cmp, helper);
    },

    toggleStoreDisplay: function(cmp, event, helper) {
        // var availabilityId = event.currentTarget.dataset.id;
        var selectedStoreName = event.getSource().get("v.value");//event.currentTarget.dataset.storename;
        var type = event.getSource().get("v.name");//event.currentTarget.dataset.type;
        var parallelType = (type === 'nearbyAvailabilitiesFilterd') ? 'selectedAvailabilitiesFilterd' : 'nearbyAvailabilitiesFilterd';

        var currentAvailabilities = cmp.get('v.' + type);
        var parallelAvailabilities = cmp.get('v.' + parallelType);
       

        for(var i = 0; i < currentAvailabilities.length; i++) {
            if(currentAvailabilities[i].storeName.toUpperCase() === selectedStoreName.toUpperCase()) {
                currentAvailabilities[i].displayPopover = !currentAvailabilities[i].displayPopover;
                var openingHours = [];
                var dayOptions = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                for(var j = 0; j < dayOptions.length; j++) {
                    if(currentAvailabilities[i].store.openingHours && currentAvailabilities[i].store.openingHours[dayOptions[j]]) {
                        openingHours.push({ 'day': dayOptions[j] , 'openingHours': currentAvailabilities[i].store.openingHours[dayOptions[j]] });
                    }
                }
                // console.log('openingHours', openingHours)
                cmp.set('v.currentOpeningDays', openingHours);
            }
            else if(currentAvailabilities[i].displayPopover){
                currentAvailabilities[i].displayPopover = false;
            }
        }
        for(var k = 0; k < parallelAvailabilities.length; k++) {
            if(parallelAvailabilities[k].displayPopover) {
                parallelAvailabilities[k].displayPopover = false;
            }
        }
        cmp.set('v.' + type, currentAvailabilities);
        cmp.set('v.' + parallelType, parallelAvailabilities);
    },

    openMapView : function(cmp, event, helper) {
        if(event.currentTarget.dataset.link) {
            window.open(event.currentTarget.dataset.link, '_blank');
        }
    },

    handleMouseLeave: function(cmp, event, helper) {
        var availabilities = cmp.get('v.nearbyAvailabilities');
        helper.hidePopover(cmp, availabilities, 'nearbyAvailabilities');

        availabilities = cmp.get('v.selectedAvailabilities');
        helper.hidePopover(cmp, availabilities, 'selectedAvailabilities');
    },

    showSpinner : function(cmp, event, helper) {
        helper.showSpinner(cmp);
    },

    hideSpinner : function(cmp, event, helper) {
        helper.hideSpinner(cmp);
    },

    handleSpinner: function(cmp, event, helper) {
        var show = event.getParam('show');
        helper.handleSpinner(cmp, helper, show);
    },
    productRequest: function(cmp,event,helper) {
        helper.productRequest(cmp, event, helper);
    },

    updateDigitalPrice: function(cmp,event,helper){
        //console.group(cmp.getType() + '.updateDigitalPrice');
        //console.log('event params:',event.getParam('digitalPrice'), event.getParam('digitalCurrency'));
        //console.log('old:',cmp.get('v.digitalPrice'),cmp.get('v.digitalCurrency'));
        cmp.set('v.digitalPrice', event.getParam('digitalPrice'));
        cmp.set('v.digitalCurrency', event.getParam('digitalCurrency'));
        var product = cmp.get('v.product');
        //var productsStock = cmp.get('v.productsStock');
        //var productsPrices = cmp.get('v.productsPrices');
        //console.log('new:',cmp.get('v.digitalPrice'),cmp.get('v.digitalCurrency'));

        var defaultAvailability = cmp.get('v.defaultAvailability');

        if(cmp.get('v.digitalPrice') > -1  && product && defaultAvailability) {
                defaultAvailability.price = cmp.get('v.digitalPrice');
                defaultAvailability.currencyCoin = cmp.get('v.digitalCurrency');
                cmp.set('v.defaultAvailability',defaultAvailability);
        }
       // console.groupEnd();
    },

    showAvailable: function(cmp,event,helper){
        cmp.set('v.showOnlyAvailable',!cmp.get('v.showOnlyAvailable'));
    },

    storeNameChange: function(cmp,event,helper){
        var searchStoreName = cmp.get('v.searchStore').toUpperCase();
        console.log('searchStoreName', searchStoreName);
        var nearbyAvailabilities = cmp.get('v.nearbyAvailabilities');
        var selectedAvailabilities = cmp.get('v.selectedAvailabilities');
        var selectedAvailabilitiesFilterd = [];
        var nearbyAvailabilitiesFilterd = [];
        if (nearbyAvailabilities.length > 0){
            for(var i=0; i<nearbyAvailabilities.length; i++){
                if (nearbyAvailabilities[i].storeName.includes(searchStoreName) || nearbyAvailabilities[i].store.retailStoreId.includes(searchStoreName)){
                    nearbyAvailabilitiesFilterd.push(nearbyAvailabilities[i]);
                }
            }
        }
        cmp.set('v.nearbyAvailabilitiesFilterd', nearbyAvailabilitiesFilterd);
        if (selectedAvailabilities.length > 0){
            for(var j=0; j<selectedAvailabilities.length; j++){
                console.log('storeName',selectedAvailabilities[j].storeName);
                if (selectedAvailabilities[j].storeName.includes(searchStoreName) || selectedAvailabilities[j].store.retailStoreId.includes(searchStoreName)){
                    selectedAvailabilitiesFilterd.push(selectedAvailabilities[j]);
                }
            }
        }
        cmp.set('v.selectedAvailabilitiesFilterd', selectedAvailabilitiesFilterd);

    }
})