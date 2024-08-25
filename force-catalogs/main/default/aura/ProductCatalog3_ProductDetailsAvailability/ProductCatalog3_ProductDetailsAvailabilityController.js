({
    showAvailable: function (cmp, event, helper) {
        var changeValue = event.getParam("value");
        if (changeValue == "all") {
            cmp.set('v.showOnlyAvailable', false);
        } else {
            cmp.set('v.showOnlyAvailable', true);
        }
    },

    storeNameChange: function (cmp, event, helper) {
        var searchStoreName = cmp.get('v.searchStore').toUpperCase();
        var nearbyAvailabilities = cmp.get('v.nearbyAvailabilities');
        var selectedAvailabilities = cmp.get('v.selectedAvailabilities');
        var selectedAvailabilitiesFilterd = [];
        var nearbyAvailabilitiesFilterd = [];
        if (nearbyAvailabilities.length > 0) {
            for (var i = 0; i < nearbyAvailabilities.length; i++) {
                if (nearbyAvailabilities[i].storeName.includes(searchStoreName) || nearbyAvailabilities[i].store.retailStoreId.includes(searchStoreName)) {
                    nearbyAvailabilitiesFilterd.push(nearbyAvailabilities[i]);
                }
            }
        }
        cmp.set('v.nearbyAvailabilitiesFilterd', nearbyAvailabilitiesFilterd);
        if (selectedAvailabilities.length > 0) {
            for (var j = 0; j < selectedAvailabilities.length; j++) {
                if (selectedAvailabilities[j].storeName.includes(searchStoreName) || selectedAvailabilities[j].store.retailStoreId.includes(searchStoreName)) {
                    selectedAvailabilitiesFilterd.push(selectedAvailabilities[j]);
                }
            }
        }
        cmp.set('v.selectedAvailabilitiesFilterd', selectedAvailabilitiesFilterd);
    },

    getProductStock: function (cmp, event, helper) {
        //add value provider for the whole component
        // here because this is the function called in doInit
        cmp.addValueProvider(
            'i',
            {
                get: function (key, cmp) {
                    let localMap = cmp.get("v." + key);
                    // debugger;
                    return Object.keys(localMap).map(key => localMap[key]);
                    //Object.keys(localMap).map(key => localMap[key].split(';')[0] == 'LV MARSEILLE' ? localMap[key] : null)
                },
            }
        );

        cmp.set('v.defaultAvailability', []);
        cmp.set('v.selectedAvailabilities', []);
        cmp.set('v.nearbyAvailabilities', []);
        cmp.set('v.selectedAvailabilitiesFilterd', []);
        cmp.set('v.nearbyAvailabilitiesFilterd', []);
        // cmp.set('v.digitalPrice', -1);
        cmp.set('v.digitalCurrency', '');

        var stores = cmp.get('v.selectedStores');
        if (stores.length > cmp.get('v.maxMyList')) {
            cmp.set('v.maxStoreError', true);

        } else {
            cmp.set('v.maxStoreError', false);
            var product = cmp.get('v.product');
            if (product.sku != '' && product.sku != null) {
                helper.getProductStock(cmp, event, helper);
            } else {
                console.log('no Sku');
            }
        }


    },

    toggleStoreDisplay: function (cmp, event, helper) {
        // var availabilityId = event.currentTarget.dataset.id;
        var selectedStoreName = event.getSource().get("v.value");//event.currentTarget.dataset.storename;
        var type = event.getSource().get("v.name");//event.currentTarget.dataset.type;
        var parallelType = (type === 'nearbyAvailabilitiesFilterd') ? 'selectedAvailabilitiesFilterd' : 'nearbyAvailabilitiesFilterd';

        var currentAvailabilities = cmp.get('v.' + type);
        var parallelAvailabilities = cmp.get('v.' + parallelType);


        for (var i = 0; i < currentAvailabilities.length; i++) {
            if (currentAvailabilities[i].storeName.toUpperCase() === selectedStoreName.toUpperCase()) {
                currentAvailabilities[i].displayPopover = !currentAvailabilities[i].displayPopover;
                var openingHours = [];
                var dayOptions = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                for (var j = 0; j < dayOptions.length; j++) {
                    if (currentAvailabilities[i].store.openingHours && currentAvailabilities[i].store.openingHours[dayOptions[j]]) {
                        openingHours.push({ 'day': dayOptions[j], 'openingHours': currentAvailabilities[i].store.openingHours[dayOptions[j]] });
                    }
                }
                // console.log('openingHours', openingHours)
                cmp.set('v.currentOpeningDays', openingHours);
            }
            else if (currentAvailabilities[i].displayPopover) {
                currentAvailabilities[i].displayPopover = false;
            }
        }
        for (var k = 0; k < parallelAvailabilities.length; k++) {
            if (parallelAvailabilities[k].displayPopover) {
                parallelAvailabilities[k].displayPopover = false;
            }
        }
        cmp.set('v.' + type, currentAvailabilities);
        cmp.set('v.' + parallelType, parallelAvailabilities);
    },

    openMapView: function (cmp, event, helper) {
        if (event.currentTarget.dataset.link) {
            window.open(event.currentTarget.dataset.link, '_blank');
        }
    },

    updateKBRWQty: function (cmp, event, helper) {
        // //console.log("Hello updateKBRWQty ");
        // var KBRWQtyFromEvent = event.getParam("KBRWQty");
        // //console.log(KBRWQtyFromEvent);
        // cmp.set("v.KBRWQty", KBRWQtyFromEvent);
        // //console.log("Hello" + cmp.get("v.KBRWQty"));



        var KBRWQtyFromEvent = event.getParam("KBRWQty");
        var qtyMap = {};

        for (var i = 0; i < KBRWQtyFromEvent.length; i++) {
            var storename = KBRWQtyFromEvent[i].storeName;
            qtyMap[storename] = storename + ';' + KBRWQtyFromEvent[i].qty + ';' + KBRWQtyFromEvent[i].rms_id;
        }

        cmp.set("v.KBRWQtyMap", qtyMap);

        // debugger;
    }
})