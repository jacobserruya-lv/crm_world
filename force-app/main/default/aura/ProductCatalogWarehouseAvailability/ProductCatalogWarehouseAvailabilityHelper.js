({
	checkEmeaStock : function(cmp, helper, AvailabilityText) {
		var selectedZone = cmp.get('v.selectedZone');
		var product = cmp.get('v.product');
		//console.log('product', product);
		//console.log('productId', product.id);
		
		var action = cmp.get("c.getRegionStock");
		if(selectedZone.indexOf('EMEA') > -1){
			//console.log('I have EMEA');
			action.setParams({
                'zoneName': 'EMEA',
                'warehouseName':'LV1',
                'productId': product.id,
        	});
		}
        else{
			//console.log('Its AMERICAS');
            action.setParams({
                'zoneName': 'AMERICAS',
                'warehouseName':'LV1',               
                'productId': product.id,
        	});
		}
		//console.log('params ', action.getParams());
        action.setCallback(this, function (result) {
                var state = result.getState();
                if (state === 'SUCCESS') {
					console.log('is stock',result.getReturnValue() );
                    if (result.getReturnValue()){
						cmp.set('v.AvailabilityText', AvailabilityText) ;
					}else{
						cmp.set('v.AvailabilityText', 'Not Orderable') ;
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
})