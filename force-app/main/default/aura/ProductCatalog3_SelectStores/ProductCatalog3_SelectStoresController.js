({
	
	setupLists: function(cmp, event, helper) {
        /*helper.getStoreHierarchy(cmp, helper, function() {
        	helper.getCurrentUser(cmp, event, helper);
		});*/
		
		helper.setupUserData(cmp, event, helper);
    },
    
    searchFilterChange: function(cmp, event, helper) {
		cmp.set('v.searchKey', event.getParam("searchKey") || '');
    	cmp.set('v.advencedSearch', event.getParam("advencedSearch"));
    	var selectedDigitalStore = cmp.get('v.selectedDigitalStore');
    	var selectedPhysicalStores = cmp.get('v.selectedPhysicalStores');
    	helper.fireSearchFilterChange(cmp, helper, selectedPhysicalStores.concat([selectedDigitalStore]),selectedDigitalStore );
    },
	
	storeSelectionChange: function(cmp, event, helper) {
		var selectedDigitalStore, selectedPhysicalStores;
		var picklistName = event.getParam('name');
		
		if(picklistName === 'digitalStores' ) {
			selectedDigitalStore = event.getParam('selectedItems')[0];
			selectedDigitalStore = selectedDigitalStore ? selectedDigitalStore.substr(selectedDigitalStore.length - 3, selectedDigitalStore.length) : '';
			cmp.set('v.selectedDigitalStore', selectedDigitalStore);
			cmp.set('v.lastSelectedStore', selectedDigitalStore);
			//console.log('my digital ' + cmp.get('v.digitalStores'));
			helper.digitalStoreChange(cmp, helper);
		}
		else if(picklistName === 'physicalStores') {
			selectedPhysicalStores = event.getParam('selectedItems');
			cmp.set('v.selectedPhysicalStores', selectedPhysicalStores);
			if(!selectedPhysicalStores.length) {
				cmp.set('v.lastSelectedStore', cmp.get('v.selectedDigitalStore'));
			}
			else {
				cmp.set('v.lastSelectedStore', selectedPhysicalStores[0].substr(selectedPhysicalStores[0].length - 3, selectedPhysicalStores[0].length));
			}
		}
		else if(picklistName === 'ZoneLevel' || picklistName === 'ZoneLevel1' || picklistName === 'ZoneLevel2')
        {
                cmp.set('v.selectedPhysicalStores', []);
                cmp.set('v.lastSelectedStore', cmp.get('v.selectedDigitalStore'));
                selectedDigitalStore = cmp.get('v.selectedDigitalStore');
                if (picklistName === 'ZoneLevel') {
                    var selectedZones = event.getParam('selectedItems');
                    cmp.set('v.selectedZoneLevel', selectedZones);
                }
                helper.locationFiltersChange(cmp, event, helper, [selectedDigitalStore], false);
                //helper.fireGetAvailabilityAndSummaryEvents(cmp, helper);

        }
		else {

			var selectedCountries = event.getParam('selectedItems');
			//cmp.set('v.selectedZoneLevel3', selectedZones);
			helper.setStoresByZone3(cmp, event, helper, selectedCountries);

			//helper.fireGetAvailabilityAndSummaryEvents(cmp, helper);

			
		}
		 helper.updateListStores(cmp,event, helper);
        
        //helper.unselectProduct(cmp, event, helper);
		
	},

    /*changeSelectedList:function(cmp, event, helper) {
		console.log('here...');
    	cmp.set('v.selectedPhysicalStores', cmp.get('v.mySelectedList'));
    }*/
    
})