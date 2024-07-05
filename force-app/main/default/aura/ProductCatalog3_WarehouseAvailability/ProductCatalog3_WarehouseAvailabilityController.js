({
	doInit : function(cmp, event, helper) {
        var warehouseAvailability = [];
        var availabilityText;
        var KBRW;
        var product = Object.assign({},cmp.get('v.product'));
        var selectedStores = cmp.get('v.selectedStores');
        var selectedWarehouses = cmp.get('v.selectedWarehouses');
        //console.log('selectedWarehouses', selectedWarehouses);
        var AvailabilityLine =[];
        var flag=false;

        for(var i=0; i < selectedWarehouses.length; i++){
            var warehouseZone = selectedWarehouses[i];
            //console.log('warehouseZone', warehouseZone);
            if(warehouseZone != 'null'){
                var warehouse = 'Orderable'+warehouseZone.replace(/\s/g, '');
                var selectedZone = cmp.get('v.selectedZone');
                
                //cmp.set('v.warehouseZone',warehouseZone);
                if(warehouseZone == 'EMEA' && 
                (selectedZone.indexOf('EMEA') > -1 || selectedZone.indexOf('AMERICAS') >- 1) &&
                product[warehouse] != 'Not Orderable' && product[warehouse]){
                    availabilityText = helper.checkEmeaStock(cmp,helper, product[warehouse]);
                }
                else if(product[warehouse] != '') { 
                    //cmp.set('v.AvailabilityText', product[warehouse]) ;
                    availabilityText =  product[warehouse]
                    
                }
                
                if(warehouseAvailability.length > 0){ 
                    for(var j=0; j<warehouseAvailability.length; j++){
                        if ((availabilityText && warehouseAvailability[j].Name == availabilityText) || 
                        (!availabilityText && warehouseAvailability[j].Name == 'No data')){
                            flag=true;
                            warehouseAvailability[j].Zone = warehouseAvailability[j].Zone +', '+warehouseZone;
                        }
                    }
                    if(!flag){
                        AvailabilityLine['Name'] = availabilityText?availabilityText:"No data";
                        AvailabilityLine['Zone'] = warehouseZone;  
                        warehouseAvailability.push(AvailabilityLine); 
                    }
                    flag=false;
                }else{
                    AvailabilityLine['Name'] = availabilityText?availabilityText:"No data";
                    AvailabilityLine['Zone'] = warehouseZone;   
                    AvailabilityLine['Zone'] = warehouseZone;   
                    warehouseAvailability.push(AvailabilityLine);
                }  
            
            }
        }
        //console.log('warehouse avail', warehouseAvailability);
        cmp.set('v.warehouseAvailability',warehouseAvailability);


		//var warehouseZone = cmp.get('v.warehouse');
		//var warehouse = 'Orderable'+warehouseZone.replace(/\s/g, '');
		
		//console.log('product', product.retailStoreId);
		// console.log('warehouseZone', warehouseZone);
        // console.log('product[warehouse]', product[warehouse]);
        // console.log('selectedZone', cmp.get('v.selectedZone'));
		/*var selectedZone = cmp.get('v.selectedZone');
        cmp.set('v.warehouseZone',warehouseZone);
		if(warehouseZone == 'EMEA' && 
           (selectedZone.indexOf('EMEA') > -1 || selectedZone.indexOf('AMERICAS') >- 1) &&
           product[warehouse] != 'Not Orderable' && product[warehouse]){
			   helper.checkEmeaStock(cmp,helper, product[warehouse]);
		}
		else if(product[warehouse] != '') { 
			cmp.set('v.AvailabilityText', product[warehouse]) ;
        }*/

        KBRW = helper.getKBRWStatus(cmp,helper,product, selectedStores);
        
       /* window.setTimeout(
            (function() {
                var action2 = cmp.get('c.fireKBRWQtyChangeEvent');
                $A.enqueueAction(action2); 
            }), 3000
        )*/
        

    },
    
    getSearchKey : function(cmp, event) {
        var searchKey = event.getParam("searchKey");
        // set the handler attributes based on event data
        cmp.set("v.searchKey", searchKey);
    },

    fireKBRWQtyChangeEvent : function(cmp, event) {
        debugger;
        var cmpEvent = cmp.getEvent("KBRWQtyChangeEvent");
        var KBRWQty = cmp.get('v.KBRWQty');
        cmpEvent.setParams({"KBRW_Qty" : KBRWQty});
        cmpEvent.fire();
    }
})