({
	getUser : function(component) {
		var action = component.get("c.getUser");
        action.setCallback(this,function(res){
            var state = res.getState();
            if(state==="SUCCESS"){
                var response = res.getReturnValue();
                console.log(">>>>> response from Apex User =>",JSON.stringify(response));
                var profileName = response.Profile.Name;
                console.log(">>>>> response profileName String =>",profileName);
                var subString = "ICON_";
                if(profileName.indexOf(subString) !== -1 || profileName == "System Administrator"){
                    component.set("v.dispalyBtn",true);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    getOpp : function(component){
         var action = component.get("c.getOpportunityByFirmOrder");
        action.setParams({
            "foId": component.get("v.recordId")
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            var firmOrder = res.getReturnValue();
            console.log("Firm Order returned: "+firmOrder);

            if(state === "SUCCESS"){
                
                component.set("v.opp",firmOrder.SPO_BriefName__c);
               
             
                console.log("Opportunity related to current firm order: "+firmOrder.SPO_BriefName__c);
                this.getCompleteOpp(component);
                $A.get('e.force:refreshView').fire();
               
            }
        });

        $A.enqueueAction(action);
    },
    
    
    getCompleteOpp : function(component){
    
      var action = component.get("c.findOpportunityById");

        action.setParams({
            "oppId": component.get("v.opp")
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            var opportunity = res.getReturnValue();
            console.log("VALUE RETURNED "+res.getReturnValue());
         console.log(">>>>> response from Apex Opportunité =>",JSON.stringify(opportunity));

            if(state === "SUCCESS"){
                
                component.set("v.opp",opportunity);
                 

                $A.get('e.force:refreshView').fire();
               
            } 
        });

        $A.enqueueAction(action);
        
    },
    
    updateOppCancelSection : function(component, stopOrderReason, stopOrderComment){
    console.log("Mise à jour des Stop Order reason & Stop order comment $$$$$$$$$$$$$$$$$$$$$$");
        
      var opp = component.get("v.opp");
      var fo = component.get("v.fo");
      
       
      opp.SPO_StopBriefReason__c = stopOrderReason;
      opp.SPO_StopBriefComment__c = stopOrderComment;
        
      var action = component.get("c.updateStopOrderField");

        action.setParams({
            "opp": opp,
            "fo": fo
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            var opportunity = res.getReturnValue();

            if(state === "SUCCESS"){
                
                component.set("v.opp",opportunity);
                component.set('v.isOpen', false);
       
                $A.get('e.force:refreshView').fire();
                 console.log("Firm order and order cancelled successfully");
               
            } else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('error', errors[0].message);
                        // Display toast message to indicate status
                        var toastParams = {
                                "type": "error",
                                "mode": "sticky",
                                "title": "Error!",
                                "message": errors[0].message
                            };
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent) {
                            toastEvent.setParams(toastParams);
                            
                            toastEvent.fire();
                        } 
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            var spinner = component.find("spinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });

        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");

        $A.enqueueAction(action);
        
    },
    
    
    
    
    
    getTodayDate:function(component){
         var today = new Date();
    	var monthDigit = today.getMonth() + 1;
   		if (monthDigit <= 9) {
        monthDigit = '0' + monthDigit;
    	}
    		component.set('v.today', today.getFullYear() + "-" + monthDigit + "-" + today.getDate());
    		console.log('Today date is : '+today);
    },
    
    updateFirmOrderStatus:function(component){
        var action = component.get("c.updateFirmOrderReceivedInStore");
      
        action.setParams({
            "foId": component.get("v.recordId")
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            var firmOrder = res.getReturnValue();

            if(state === "SUCCESS"){
                
                component.set("v.recordId",firmOrder.Id);

                $A.get('e.force:refreshView').fire();
                console.log("Firm order status update successfully");
            } else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('error', errors[0].message);
                        // Display toast message to indicate status
                        var toastParams = {
                                "type": "error",
                                "mode": "sticky",
                                "title": "Error!",
                                "message": errors[0].message
                            };
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent) {
                            toastEvent.setParams(toastParams);
                            
                            toastEvent.fire();
                        } 
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            var spinner = component.find("spinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });

        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");

        $A.enqueueAction(action);
    },
        
    CancelFirmOrderJS:function(component){
        console.log("+++ h.CancelFirmOrderJS : IN");
        var action = component.get("c.cancelFirmOrderDB");
        var recordId = component.get("v.recordId");
        console.log(">>>>>>>>>>> v record Id in SPO Firm Order Tile",recordId);
        var opp = component.get("v.opp");
      
        action.setParams({
            "foId": recordId,
            "opp": opp
        });
		
        action.setCallback(this,function(res){
            var state = res.getState();
            var firmOrder = res.getReturnValue();

            if(state === "SUCCESS"){
                
                component.set("v.recordId",firmOrder.Id);
                console.log("Firm order status update successfully");
                //because native refresh event "e.force:refreshView" does NOT work
                window.location.reload();
                $A.get("e.force:refreshView").fire();
                
            } else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('error', errors[0].message);
                        // Display toast message to indicate status
                        var toastParams = {
                                "type": "error",
                                "mode": "sticky",
                                "title": "Error!",
                                "message": errors[0].message
                            };
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent) {
                            toastEvent.setParams(toastParams);
                            
                            toastEvent.fire();
                        } 
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            var spinner = component.find("spinner");
            $A.util.toggleClass(spinner, "slds-hide");
           
            
        });

        var cmpTarget = component.find("cancelModal");
        var cmpBack = component.find("MB-Back");
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
        $A.util.removeClass(cmpTarget, "slds-fade-in-open");
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
         window.location.reload();
            $A.get("e.force:refreshView").fire();
        $A.enqueueAction(action);
    },
    
    
    
    
     getSORList : function(cmp) {
        // TODO get stores in the country of the user
        
        var action = cmp.get("c.getSORJson");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.stopOrderList", JSON.parse(response.getReturnValue()));

                /*var resultList = JSON.parse(response.getReturnValue());
                var storeCode = cmp.get("v.storeCode");
                var opts = [];
                for (var index in resultList) {
                    var val = resultList[index].value;
                    if (val === storeCode) {
                        opts.push({ value: resultList[index].value, label: resultList[index].label, selected: true });
                    } else {
                        opts.push({ value: resultList[index].value, label: resultList[index].label });
                    }
                }
                cmp.find("storeSelect").set("v.options", opts);*/

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
    	});
        // optionally set storable, abortable, background flag here
        action.setStorable();
        $A.enqueueAction(action);        
    },
    
    fireRefresh : function(){
        var refresh = $A.get("e.force:refreshView");
        if (refresh) {
            refresh.fire();
        } else {
            window.location.reload();
        }
         //$A.get('e.force:refreshView').fire();
    },
    
   /* cancelFirmOrderStatus:function(component){
		 var action = component.get("c.cancelFirmOrder");
         console.log('CALL APEX METHOD CANCEL FIRM ORDER');
     	 action.setParams({
            "foId": component.get("v.recordId")
        });

        action.setCallback(this,function(res){
            var state = res.getState();
            var firmOrder = res.getReturnValue();

            if(state === "SUCCESS"){
                console.log('SUCCESS');
                component.set("v.recordId",firmOrder.Id);
 
                $A.get('e.force:refreshView').fire();
                console.log("Firm order status update successfully");
            } else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('error', errors[0].message);
                        // Display toast message to indicate status
                        var toastParams = {
                                "type": "error",
                                "mode": "sticky",
                                "title": "Error!",
                                "message": errors[0].message
                            };
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent) {
                            toastEvent.setParams(toastParams);
                            
                            toastEvent.fire();
                        } 
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            var spinner = component.find("spinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });

        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");

        $A.enqueueAction(action);
	},*/
})