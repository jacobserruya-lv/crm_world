({
	setupLists: function (cmp, event, helper) {
		/*helper.getStoreHierarchy(cmp, helper, function() {
			helper.getCurrentUser(cmp, event, helper);
		});*/
		//console.log('setup');

		helper.setupUserData(cmp, event, helper);
	},

	updateSetupStoreList: function (cmp, event, helper) {
		//console.log('updatetin store setup');
		helper.updateSetupStoreList(cmp, event, helper);
	},

	storeSelectionChange: function (cmp, event, helper) {
		//console.log('store selection change');
		var selectedDigitalStore, selectedPhysicalStores;
		var picklistName = event.getParam('name');

		if (picklistName === 'physicalStores') {
			selectedPhysicalStores = event.getParam('selectedItems');
			cmp.set('v.selectedPhysicalStores', selectedPhysicalStores);
			if (!selectedPhysicalStores.length) {
				cmp.set('v.lastSelectedStore', cmp.get('v.selectedDigitalStore'));
			}
			else {
				cmp.set('v.lastSelectedStore', selectedPhysicalStores[0].substr(selectedPhysicalStores[0].length - 3, selectedPhysicalStores[0].length));
			}
		}
		else if (picklistName === 'ZoneLevel' || picklistName === 'ZoneLevel1' || picklistName === 'ZoneLevel2') {
			if (picklistName === 'ZoneLevel') {
				var selectedZones = event.getParam('selectedItems');
				cmp.set('v.selectedZoneLevel', selectedZones);
			}
			//console.log('changing location');
			helper.locationFiltersChange(cmp, event, helper, [selectedDigitalStore], false);
			//helper.fireGetAvailabilityAndSummaryEvents(cmp, helper);

		}
		else {

			var selectedCountries = event.getParam('selectedItems');
			//cmp.set('v.selectedZoneLevel3', selectedZones);
			helper.setStoresByZone3(cmp, event, helper, selectedCountries);

			//helper.fireGetAvailabilityAndSummaryEvents(cmp, helper);


		}
		//helper.updateListStores(cmp,event, helper);

		//helper.unselectProduct(cmp, event, helper);

	},
})