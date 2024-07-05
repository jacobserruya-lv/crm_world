({
	getData : function(cmp) {
       var caseId ="";
        if(!$A.util.isUndefined(cmp.get('v.recordId'))){
           caseId = cmp.get('v.recordId');
        }
        
       var action = cmp.get('c.getDuplicateCases');
		action.setParams({
			      ShippingGroup : cmp.get('v.shippingGroup'),
            OrderShipping : cmp.get('v.orderShipping'),
            AccId : cmp.get('v.accountId'),
            CaseId: caseId
		 });
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var mydata = response.getReturnValue();
                var formattedData;
                if(mydata){
                	formattedData = mydata.map(function (record){
                        record.url ='/lightning/r/Case/'+record.Id+'/view' ;
                        if(!$A.util.isUndefined(record.AccountId)){
                          record.AccountName = record.Account.Name;
                        }else{
                          record.AccountName=''; 
                          
                        }

                       
                          if(!$A.util.isUndefined(record.Order_Shipping__c)){
                          record.OrderShipping = record.Order_Shipping__r.ShippingNumber__c; // not working if we do not use variables
                        }
                     
                        return record;
                	});

                }

                cmp.set('v.listSize',formattedData.length);
                cmp.set('v.data', formattedData);

            
            }else if(state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
    getValueCase: function(cmp) { 
        
        var action = cmp.get("c.getCase");
        action.setParams({
          CaseId : cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) { 
          var state = response.getState();
          if(state === "SUCCESS") {
           	var result = response.getReturnValue();
            cmp.set("v.shippingGroup", result.Shipping_group__c);
            let OrderShipping = result.Order_Shipping__c ?result.Order_Shipping__r.ShippingNumber__c:null;
            cmp.set("v.orderShipping",OrderShipping );
            cmp.set("v.accountId", result.AccountId);
                
          }else if(state === "ERROR") {
            var errors = response.getError();
            console.error(errors);
          }
        }); 
        $A.enqueueAction(action);
    },
    
})