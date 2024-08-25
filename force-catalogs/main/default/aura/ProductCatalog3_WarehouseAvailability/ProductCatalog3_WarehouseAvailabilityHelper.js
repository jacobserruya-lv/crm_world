({
	checkEmeaStock : function(cmp, helper, AvailabilityText) {
		var selectedZone = cmp.get('v.selectedZone');
		var product = cmp.get('v.product');
		//console.log('product', product);
		//console.log('productId', product.id);
		
		var action = cmp.get("c.getRegionStock");
		if(selectedZone.indexOf('EMEA') > -1 && product != null){
			//console.log('I have EMEA');
			action.setParams({
                'zoneName': 'EMEA',
                'warehouseName':'LV1',
                'productId': product.id,
        	});
		}
        else{
            if(product != null){
             	//console.log('Its AMERICAS');
                action.setParams({
                    'zoneName': 'AMERICAS',
                    'warehouseName':'LV1',               
                    'productId': product.id,
                });   
            }
		}
		//console.log('params ', action.getParams());
        action.setCallback(this, function (result) {
                var state = result.getState();
                if (state === 'SUCCESS') {
					//console.log('is stock',result.getReturnValue() );
                    if (result.getReturnValue()){
						return AvailabilityText ;
					}else{
						return 'Not Orderable';
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
	},
    
    handleError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    },
    getKBRWStatus: function(cmp, helper, product, selectedStores,event){
        console.log('product', product);
        console.log('selectedStores', selectedStores);
        console.log('selectedStores[0]', selectedStores[0]);
        
        var action = cmp.get("c.getOrderableStatus");
        
        var kbrwArray = [];
        var kbrwQtyArray = [];

        action.setParams({
            product : JSON.stringify(product),
            selectedStores: JSON.stringify(selectedStores)
        });

        action.setCallback(this, function (result) {
            var state = result.getState();
            if (state === 'SUCCESS') {
   
                var resultObj = {};
                var resultQtyObj = {};

                var availableToOrder = '';
                var r = result.getReturnValue();



                var counter = 0;
                var counterQty = 0;                
                debugger;

				if(r != '' && r != null){
                    for(var i = 0; i < Object.keys(r).length; i++){
                        if(Object.keys(r)[i].split(':')[0].indexOf('_qty') == -1){
                            resultObj = {};
                            resultObj.FullCountryName = Object.values(r)[i].split(':')[0];
                            resultObj.Country = Object.values(r)[i].split(':')[1];
                            resultObj.Available = Object.values(r)[i].split(':')[2] == 'Y' ? 'Orderable' : Object.values(r)[i].split(':')[2] == 'N' ? 'Not orderable' : 'No Data'; 
                            resultObj.LeadMin = Object.values(r)[i].split(':')[3];  
                            resultObj.LeadMax = Object.values(r)[i].split(':')[4].replace(';','');  
                            kbrwArray.push(resultObj);  
                            counter++;
                        } else {
                            resultQtyObj = {};
                            resultQtyObj.Country = Object.keys(r)[i].replace('_qty', '').split('%')[0];
                            resultQtyObj.storeName = Object.values(r)[i].split(':')[0];
                            resultQtyObj.qty = Object.values(r)[i].split(':')[1];
                            resultQtyObj.rms_id = Object.values(r)[i].split(':')[2].replace(';','');  
                            kbrwQtyArray.push(resultQtyObj);  
                            counterQty++;
                        }
                    }
                }
                
                //debugger;
            }
            else if (state === 'ERROR') {
                helper.handleError(result);
            }
            else {
                console.error('Unknown error');
            }

            cmp.set('v.KBRW', kbrwArray);
            cmp.set('v.KBRWqty', kbrwQtyArray);
             var action2 = $A.get('e.c:ProductCatalogueKBRWQtyChange');
        	 action2.setParams({"KBRWQty" : kbrwQtyArray});
        	 action2.fire();
        });
        $A.enqueueAction(action);
    
    },
})