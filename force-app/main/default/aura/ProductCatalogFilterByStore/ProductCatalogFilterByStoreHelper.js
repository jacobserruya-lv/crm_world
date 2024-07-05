({

	getStoreHierarchy: function(cmp, helper, callback) {
        /*var action = cmp.get('c.getUserLocationPickListValues');
        action.setParams({
    		'fieldNames': ['MANAGEMENT_ZONE_LEVEL__c', 'MGMT_ZONE_SUB_LEVEL1__c', 'MGMT_ZONE_SUB_LEVEL2__c', 'MGMT_ZONE_SUB_LEVEL3__c', 'DefaultStore__c']
        });*/

        var action = cmp.get('c.getUserStoreHierarchy');

        action.setCallback(this, function(response) {
        	var state = response.getState();
            if(state === "SUCCESS") {
            	cmp.set('v.ManagementZoneLevelMap', response.getReturnValue());
            	callback();
            }
            else if(state === "ERROR") {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
    },


    getCurrentUser: function(cmp, event, helper) {
    	var action = cmp.get('c.getUser');

        action.setCallback(this, function(response) {
        	var state = response.getState();
            if(state === "SUCCESS") {
            	helper.setupUserData(cmp, event, helper, response)
            }
            else if(state === "ERROR") {
                helper.handleError(response);
            }
        });

        $A.enqueueAction(action);
    },

    setupUserData: function(cmp, event, helper, response) {
        var currentUser = response.getReturnValue();
        var managementZoneLevelMap = cmp.get('v.ManagementZoneLevelMap');
        //var userStoreCode = currentUser['DefaultStore__c'];
        var userStoreCode = currentUser['My_Stores_Lists__c'];
        var selectedStores = [];
        //console.log('current user' , currentUser);
        console.log('managementZoneLevelMap ', managementZoneLevelMap);

        cmp.set('v.Warehouse_List', managementZoneLevelMap['Warehouse']);
        cmp.set('v.MANAGEMENT_ZONE_LEVEL__c_List', Object.keys(managementZoneLevelMap['zone']).sort());
        cmp.set('v.selectedZoneLevel', managementZoneLevelMap['userStores']['mgmtZones'] || '');

        var storesWarehouses = managementZoneLevelMap['Warehouse'];
        var warehousesName = Object.keys(managementZoneLevelMap['Warehouse']);
        var selectedWarehouses = [];

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

        var digitalStores = managementZoneLevelMap['DigitalStores']['DigitalStores'];
        cmp.set('v.digitalStores', digitalStores);

        var currentStores = [];
        var stores;
        var countries = managementZoneLevelMap['userStores']['countries'];
        for (var j = 0; j < countries.length; j++) {
            stores = managementZoneLevelMap['countries'][countries[j]];
            //console.log('stores',managementZoneLevelMap['countries'][countries[j]]);
            currentStores = currentStores.concat(stores);
        }

        cmp.set('v.physicalStores', currentStores);
        var userStores = JSON.parse(Object.keys(managementZoneLevelMap.userStores)[0]);
        cmp.set('v.selectedDigitalStore', userStores.lastDigitalStore);
        cmp.set('v.userStores', userStores);

        var userStoresCode = [];
        if (userStoreCode) {
            userStoresCode = userStoreCode.split(';');
        }
        for(var k = 0; k < userStoresCode.length; k++){
            for(var y = 0; y < warehousesName.length; y++){
                //console.log(storesWarhouses[warehousesName[j]]);
                //var warehouseNameInList = 'Orderable'+ warehousesName[j].replace(/\s/g, '');
                if(storesWarehouses[warehousesName[y]].includes(userStoresCode[k]) &&
                    storesWarehouses[warehousesName[y]] != null &&
                    !selectedWarehouses.includes(warehousesName[y])) {
                    selectedWarehouses.push(warehousesName[y]);
                    break;
                }
            }
        }
        cmp.set('v.selectedPhysicalStores', userStoresCode);
        cmp.set('v.mySelectedList',userStoresCode);
        cmp.set('v.selectedWarehouses', selectedWarehouses);
        console.log('selectedWarehouses', selectedWarehouses);


     //helper.locationFiltersChange(cmp, event, helper, selectedStores);
        helper.fireSearchFilterChange(cmp, helper, selectedStores);
    },

     locationFiltersChange: function(cmp, event, helper, selectedStores) {
         //var timer = setTimeout(function () {

         var managementZoneLevelMap = cmp.get('v.ManagementZoneLevelMap');
        
         //cmp.set('v.MANAGEMENT_ZONE_LEVEL__c_List', Object.keys(managementZoneLevelMap['zone']));
         var countriesList = [];
         var selectedZones = cmp.get('v.selectedZoneLevel');
         for (var i = 0; i < selectedZones.length; i++) {
             var zoneCountries = managementZoneLevelMap['zone'][selectedZones[i]];
             countriesList = countriesList.concat(zoneCountries);
         }

         //console.log('countriesList', countriesList);
         var selectedCountries = cmp.get('v.selectedZoneLevel3');

         if(countriesList.length > 0) {
             for (var i = selectedCountries.length -1; i >= 0 ; i--) {
                 //console.log('if for with ', selectedCountries[i]);
                 //console.log(countriesList.includes(selectedCountries[i]));
                 if (!countriesList.includes(selectedCountries[i])) {
                     //console.log('remove...');
                     selectedCountries.splice(i,1);
                 }
             }
         }
         else{
             selectedCountries = [];
             
         }
         //console.log('selectedCountries after',selectedCountries);
        cmp.set('v.selectedZoneLevel3', selectedCountries) ;
         cmp.set('v.MGMT_ZONE_SUB_LEVEL3__c_List', countriesList.sort() || []);

        if(selectedCountries.length == 0) {
            cmp.set('v.physicalStores',  []);
            cmp.set('v.selectedWarehouses',[]);
        }else{
            helper.setStoresByZone3(cmp, event, helper, selectedCountries);
        }

         //}, 200);
        //I think we don't need it, but have to test 2019-03-14
       //helper.setStoresByZone3(cmp, helper, selectedCountries);
    },

    fireSearchFilterChange: function(cmp, helper, selectedStoresByCode, digitalStore) {
        console.log('fiering search');
        var searchKey = cmp.get('v.searchKey');
		var advencedSearch = cmp.get('v.advencedSearch');
		var selectedStores = helper.storeCodesToNames(selectedStoresByCode);
        var selectedWarehouses = cmp.get('v.selectedWarehouses');
        //console.log('selectedWarehouses fiering search', selectedWarehouses);
        console.log('selected Zone level ', cmp.get('v.selectedZoneLevel'));
        helper.unselectProduct(cmp, event, helper);
		var event = $A.get('e.c:ProductCatalogFiltersChangeEvent');
        event.setParams({   'searchKey': searchKey, 
                            'selectedStores': selectedStores, 
                            'digitalStore': digitalStore, 
                            'selectedWarehouses' : selectedWarehouses,    
                            'advencedSearch': advencedSearch,
                            'selectedZone': cmp.get('v.selectedZoneLevel')});
    	event.fire();
    },

    digitalStoreChange: function(cmp, helper) {
    	var action = cmp.get('c.updateDigitalStore');
    	action.setParams({ 'digitalStore': cmp.get('v.selectedDigitalStore') });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if(state === "SUCCESS") {
            	var userStores = response.getReturnValue();
            	cmp.set('v.userStores', userStores);
            	//helper.fireGetAvailabilityAndSummaryEvents(cmp, helper);
				event = $A.get('e.c:ProductCatalogGetDigitalStoreEvent');
                event.setParams({
                    'digitalStore': cmp.get('v.selectedDigitalStore'),
                });
                event.fire();
            }
            else if(state === "ERROR") {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
        //console.log('helper change digital ' + cmp.get('v.digitalStores'));
    },

    fireGetAvailabilityAndSummaryEvents: function(cmp, helper) {
		var event = $A.get('e.c:ProductCatalogSummarySpinnerEvent');
		event.setParams({ 'show' : true });
		event.fire();

        var selectedStores = helper.storeCodesToNames(cmp.get('v.selectedPhysicalStores').concat([cmp.get('v.selectedDigitalStore')]));
        event = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
        event.setParams({
        	'product': null,
        	'productClicked': false,
        	'selectedStores': selectedStores,
        	'lastSelectedStore': cmp.get('v.lastSelectedStore'),
        	'userStores': cmp.get('v.userStores')
        });
        event.fire();
    },

    storeCodesToNames: function(stores) {
       return stores.reduce(function(result, storeCode, index) {

    		result.push(typeof storeCode === 'object' ? storeCode.retailStoreId : storeCode.substr(storeCode.length - 3, storeCode.length));
    		return result;
    	}, []);
    },

	parseStoreObj: function(stores) {
		return stores.reduce(function(result, store, index) {
			result.push(store.name + ' - ' + store.retailStoreId);
			return result;
		}, []);
	},

	handleError: function(response) {
    	var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.error("Error message: " + errors[0].message);
            }
        }
        else {
            console.error("Unknown error");
        }
    },

    findStoreIndex: function(stores, storeCode) {
    	return stores.findIndex(function(store) {
    		return store.substr(store.length - 3, store.length) === storeCode;
    	});
    },

    updateListStores: function(cmp, event, helper) {
        var selectedStores = helper.storeCodesToNames(cmp.get('v.selectedPhysicalStores').concat([cmp.get('v.selectedDigitalStore')]));
        var selectedPhysicalStores = cmp.get('v.selectedPhysicalStores');
        //console.log('selectedPhysicalStores', selectedPhysicalStores);
        var selectedWarehouses = cmp.get('v.selectedWarehouses');
        var selectedZone = cmp.get('v.selectedZoneLevel');
        var myEvent = $A.get('e.c:ProductCatalogUpdateListStores');
        myEvent.setParams({ 'selectedStores': selectedStores, 'selectedWarehouses': selectedWarehouses, 'selectedZone' : selectedZone});
        myEvent.fire();
    },



    setStoresByZone3: function(cmp, event, helper, selectedZoneStores) {
	    //console.log('zone store');
        var myEvent = $A.get('e.c:ProductCatalogUpdateListStores');

       // var timer = setTimeout(function () {
           var zoneLevel3 = cmp.get('v.ManagementZoneLevelMap')['countries'];
            //console.log('zoneLevel3', zoneLevel3);
            var selectedStores = [];

            cmp.set('v.selectedZoneLevel3', selectedZoneStores);

            for(var i = 0; i < selectedZoneStores.length; i++) {
                if(zoneLevel3[selectedZoneStores[i]] ) {
                    selectedStores = selectedStores.concat(zoneLevel3[selectedZoneStores[i]]);
                }
            }
            cmp.set('v.lastSelectedStore', selectedStores.length ? selectedStores[0].substr(selectedStores[0].length - 3, selectedStores[0].length) : '');

            var mappedSelectedStores = selectedStores.map(function(val) {
                //result.push();
                return {
                    'name': val.substr(0, val.length - 6),
                    'retailStoreId': val.substr(val.length - 3, val.length),
                    'isDefault': true,
                };
            });
            //console.log('selectedStores', mappedSelectedStores);
            var warehouses = cmp.get('v.Warehouse_List');
            //console.log('warehouses',warehouses );
            var warehousesName = Object.keys(warehouses);
            //console.log('warehousesName', warehousesName);
            var selectedWarehouses = [];
            for(var y=0; y < mappedSelectedStores.length; y ++) {
                for (var j = 0; j < warehousesName.length; j++) {
                    //console.log(warehouses[warehousesName[j]]);
                    //console.log('mappedSelectedStores[i].retailStoreId', mappedSelectedStores[i].retailStoreId);
                    //var warehouseNameInList = 'Orderable'+ warehousesName[j].replace(/\s/g, '');
                    if (warehouses[warehousesName[j]].includes(mappedSelectedStores[y].retailStoreId) &&
                        warehouses[warehousesName[j]] != 'null' &&
                        !selectedWarehouses.includes(warehousesName[j])) {
                        selectedWarehouses.push(warehousesName[j]);
                        break;
                    }
                }
            }
            cmp.set('v.physicalStores', mappedSelectedStores);
            cmp.set('v.selectedPhysicalStores', mappedSelectedStores);
            cmp.set('v.selectedWarehouses', selectedWarehouses);
            //console.log('selectedWarehouses', selectedWarehouses);

            var allSelectedStores = helper.storeCodesToNames(cmp.get('v.selectedPhysicalStores').concat([cmp.get('v.selectedDigitalStore')]));
            var selectedZone = cmp.get('v.selectedZoneLevel');
            myEvent.setParams({ 'selectedStores': allSelectedStores, 'selectedWarehouses': selectedWarehouses, 'selectedZone' : selectedZone});
            myEvent.fire();
      // }, 100);

    },

    unselectProduct: function(cmp, event, helper){
        var myEvent = $A.get('e.c:ProductCatalogItemClickedEvent');
        myEvent.setParams({ 'product': '' , 'productsStock': {} ,  'productsPrices': {}});
        myEvent.fire();

        myEvent = $A.get('e.c:ProductCatalogGetSummaryEvent');
        myEvent.setParams({ 'product':'' , 'productClicked': false});
        myEvent.fire();

        myEvent = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
        myEvent.setParams({'product': null, 'productClicked': true});
        myEvent.fire();
    }

})