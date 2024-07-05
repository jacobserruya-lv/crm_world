({	checkDocument : function(component,event,helper){

	var action = component.get("c.getDocumentId");

		console.log(">>>>>>>> V RecordId " + JSON.stringify(component.get("v.recordId")));
		action.setParams({
			"oppId" : component.get("v.recordId")
		});

		action.setCallback(this,function(res){
			console.log("Res from Apex :" + JSON.stringify(res));
			var state = res.getState();

			if(state === "SUCCESS"){
				var docId = res.getReturnValue();
				console.log(">>>>>>>>>> document Id : " + docId);

				var btn = component.find("printbtn");

				//If there is no document linked, disable the boutton
				if(docId.length === 0){
					console.log(">>>>>>>>>>docId length " + docId.length);
					btn.set("v.disabled",true);
					//$A.util.addClass(btn, 'disBtn');
				}
				
				component.set("v.docId",docId);
				console.log(">>>>>>>> doc Id" + JSON.stringify(component.get("v.docId")));
			}
		});

		$A.enqueueAction(action);
},

	redirectPage : function (component) {

		var docId = component.get("v.docId");

		if(docId.length > 0){
			for(var i=0; i<docId.length;i++){
	        		var paramUrl = "/sfc/servlet.shepherd/document/download/"+docId[i]+"?operationContext=S1";
	    			console.log(">>>>>>>>>> paramUrl " + paramUrl);
					var urlEvent = $A.get("e.force:navigateToURL");
	    			urlEvent.setParams({
	       				"url": paramUrl
	    		 	});
	    		 	urlEvent.fire();
	    			
	        }
		}
    	
	},
})