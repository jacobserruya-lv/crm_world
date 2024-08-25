({
    setupUserData: function (cmp, event, helper) {
        //console.log('I am here in setup settings');
        //var currentUser = response.getReturnValue();
        var currentUser = cmp.get('v.currentUserData');
        var managementZoneLevelMap = cmp.get('v.ManagementZoneLevelMap');
        //console.log('currentUser',currentUser);
        //console.log('managementZoneLevelMap',managementZoneLevelMap);
        if (currentUser && managementZoneLevelMap) {
            //var userStoreCode = currentUser['DefaultStore__c'];
            var userStoreCode = currentUser['My_Stores_Lists__c'];

            //console.log('current user' , currentUser);
            //console.log('managementZoneLevelMap ', managementZoneLevelMap);

            cmp.set('v.MANAGEMENT_ZONE_LEVEL__c_List', Object.keys(managementZoneLevelMap['zone']).sort());
            cmp.set('v.selectedZoneLevel', managementZoneLevelMap['userStores']['mgmtZones'] || '');

            var selectedZones = managementZoneLevelMap['userStores']['mgmtZones'];
            var countriesList = [];
            if (selectedZones) {
                for (var i = 0; i < selectedZones.length; i++) {
                    var zoneCountries = managementZoneLevelMap['zone'][selectedZones[i]];
                    countriesList = countriesList.concat(zoneCountries);
                }
            }

            cmp.set('v.MGMT_ZONE_SUB_LEVEL3__c_List', countriesList.sort() || []);
            cmp.set('v.selectedZoneLevel3', managementZoneLevelMap['userStores']['countries'] || '');
            cmp.set('v.defaultStore', managementZoneLevelMap['userStores']['stores'] || '');

            var currentStores = [];
            var stores;
            var countries = managementZoneLevelMap['userStores']['countries'];
            console.log('countries', countries);
            for (var j = 0; j < countries.length; j++) {
                stores = managementZoneLevelMap['countries'][countries[j]];
                //console.log('stores',managementZoneLevelMap['countries'][countries[j]]);
                currentStores = currentStores.concat(stores);
            }

            console.log('currentStores', currentStores);
            cmp.set('v.physicalStores', currentStores);
            var userStores = JSON.parse(Object.keys(managementZoneLevelMap.userStores)[0]);
            cmp.set('v.userStores', userStores);

            var userStoresCode = [];
            if (userStoreCode) {
                userStoresCode = userStoreCode.split(';');
            }

            //console.log('userStoresCode',userStoresCode );
            cmp.set('v.selectedPhysicalStores', userStoresCode);
            cmp.set('v.mySelectedList', userStoresCode);
            //console.log('selectedWarehouses', selectedWarehouses);


            //helper.locationFiltersChange(cmp, event, helper, selectedStores);

            //helper.fireSearchFilterChange(cmp, helper, userStoresCode.concat(userStores.lastDigitalStore),userStores.lastDigitalStore);
        }
    },

    updateSetupStoreList: function (cmp, event, helper) {
        //console.group(cmp.getType() + '.h.addToMyList');
        var stores = cmp.get('v.myList');
        console.log('stores', stores);
        var action = cmp.get('c.AddStoreToMyPersonalList');
        action.setParams({
            'storesCode': stores,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('state',state);
            if (state === "SUCCESS") {
                var pageResult = response.getReturnValue();
                console.log('pageResult ', response.getReturnValue());
                var myEvent = $A.get('e.c:ProductCatalog3_updateStoreSetupEvent');
                myEvent.fire();

            }
            else if (state === "ERROR") {
                helper.handleError(response);
            } else {
                console.error('Unknown error');
            }
        });

        $A.enqueueAction(action);

        console.groupEnd();
    },

    locationFiltersChange: function (cmp, event, helper, selectedStores) {
        //var timer = setTimeout(function () {
        //console.log('changing location');
        var managementZoneLevelMap = cmp.get('v.ManagementZoneLevelMap');

        //cmp.set('v.MANAGEMENT_ZONE_LEVEL__c_List', Object.keys(managementZoneLevelMap['zone']));
        var countriesList = [];
        var selectedZones = cmp.get('v.selectedZoneLevel');
        //console.log('selectedZones', selectedZones);
        for (var i = 0; i < selectedZones.length; i++) {
            var zoneCountries = managementZoneLevelMap['zone'][selectedZones[i]];
            countriesList = countriesList.concat(zoneCountries);
        }

        //console.log('countriesList', countriesList);
        //console.log('countriesList', countriesList);
        var selectedCountries = cmp.get('v.selectedZoneLevel3');

        if (countriesList.length > 0) {
            for (var i = selectedCountries.length - 1; i >= 0; i--) {
                //console.log('if for with ', selectedCountries[i]);
                //console.log(countriesList.includes(selectedCountries[i]));
                if (!countriesList.includes(selectedCountries[i])) {
                    //console.log('remove...');
                    selectedCountries.splice(i, 1);
                }
            }
        }
        else {
            selectedCountries = [];

        }
        //console.log('selectedCountries after',selectedCountries);
        cmp.set('v.selectedZoneLevel3', selectedCountries);
        cmp.set('v.MGMT_ZONE_SUB_LEVEL3__c_List', countriesList.sort() || []);

        if (selectedCountries.length == 0) {
            cmp.set('v.physicalStores', []);
        } else {
            helper.setStoresByZone3(cmp, event, helper, selectedCountries);
        }

        //}, 200);
        //I think we don't need it, but have to test 2019-03-14
        //helper.setStoresByZone3(cmp, helper, selectedCountries);
    },

    setStoresByZone3: function (cmp, event, helper, selectedZoneStores) {
        //console.log('zone store');
        //var myEvent = $A.get('e.c:ProductCatalog3_UpdateMyListStores');

        // var timer = setTimeout(function () {
        var zoneLevel3 = cmp.get('v.ManagementZoneLevelMap')['countries'];
        //console.log('zoneLevel3', zoneLevel3);
        var selectedStores = [];

        cmp.set('v.selectedZoneLevel3', selectedZoneStores);

        for (var i = 0; i < selectedZoneStores.length; i++) {
            if (zoneLevel3[selectedZoneStores[i]]) {
                selectedStores = selectedStores.concat(zoneLevel3[selectedZoneStores[i]]);
            }
        }
        cmp.set('v.lastSelectedStore', selectedStores.length ? selectedStores[0].substr(selectedStores[0].length - 3, selectedStores[0].length) : '');

        var mappedSelectedStores = selectedStores.map(function (val) {
            //result.push();
            return {
                'name': val.substr(0, val.length - 6),
                'retailStoreId': val.substr(val.length - 3, val.length),
                'isDefault': true,
            };
        });
        //console.log('selectedStores', mappedSelectedStores);

        cmp.set('v.physicalStores', mappedSelectedStores);
        cmp.set('v.selectedPhysicalStores', mappedSelectedStores);
        //console.log('selectedWarehouses', selectedWarehouses);
        /*if(selectedStores.length > cmp.get('v.maxMyList')){
            cmp.set('v.disabledApply', true);
        }else{
            cmp.set('v.disabledApply', false);
        }*/
        cmp.set('v.myList', selectedStores);


        // }, 100);

    },

    handleError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    },

})