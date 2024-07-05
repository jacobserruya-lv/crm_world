({
	doInit : function(cmp, event, helper) {
		var product = Object.assign({},cmp.get('v.product'));
		var warehouseZone = cmp.get('v.warehouse');
		var warehouse = 'Orderable'+warehouseZone.replace(/\s/g, '');
		
		//console.log('product', product.retailStoreId);
		/*console.log('warehouseZone', warehouseZone);
		console.log('product[warehouse]', product[warehouse]);*/
		console.log('selectedZone', cmp.get('v.selectedZone'));
		var selectedZone = cmp.get('v.selectedZone');
        cmp.set('v.warehouseZone',warehouseZone);
		if(warehouseZone == 'EMEA' && 
           (selectedZone.indexOf('EMEA') > -1 || selectedZone.indexOf('AMERICAS') >- 1) &&
           product[warehouse] != 'Not Orderable' && product[warehouse]){
			   helper.checkEmeaStock(cmp,helper, product[warehouse]);
		}
		else if(product[warehouse] != '') { 
			cmp.set('v.AvailabilityText', product[warehouse]) ;
		}
	}
})