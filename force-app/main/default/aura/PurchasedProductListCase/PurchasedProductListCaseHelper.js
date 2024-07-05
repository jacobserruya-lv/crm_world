({
	doInit : function(component) {
		// call Apex controller
		var action 		= component.get("c.FindPurchasedProductDB");
		//var recordId 	= component.find("idFromSearch").get("v.value");
		var recordId	= component.get("v.recordId");
		//var idAttr		= component.set("v.id",recordId);
		action.setParams({
			//"Id" : component.get("v.recordId")
			"Id"	: recordId
		});

		action.setCallback (this, function(response){
			var state = response.getState();
			if(component.isValid() && state === 'SUCCESS'){
				component.set("v.purchasedProducts", response.getReturnValue());
			}
		});

		$A.enqueueAction(action);
	},

	addProductToEventFromIndex : function(component, event, index){
		console.log('adding');

		var recordId	= component.get("v.recordId");
		var pp			= component.get("v.purchasedProducts");

		// Call Apex controller method
		var action = component.get("c.updatePurchasedProductOnEvent");
		action.setParams({
			"caseId" 	: recordId,
			"tId"		: pp[index].pps[0].TechTransactionId__c,
            "ppId"		: pp[index].pps[0].Id
            
		});

		action.setCallback (this, function(response){
			var state = response.getState();
			if(component.isValid() && state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire()
			}
		});

		$A.enqueueAction(action);
	}

})