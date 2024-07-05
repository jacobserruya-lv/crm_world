({
	getFirmOrderList : function(component, event) {
        //var params = event.getParams();
        console.log('getFirmOrderList');
        var action = component.get("c.getFirmOrderList");
        action.setParams({
            "oppId": component.get("v.recordId")
    	});

        action.setCallback(this, function(a) {
            var state = a.getState();

            if (state === "SUCCESS") {
	            var result = a.getReturnValue();
                var counter = 0;
                var count = 0;
               
                
                component.set("v.firmOrderList", result);

                //if order has more than 1 firm order, show the button All receive in store
                for(var i=0;i<result.length;i++){
                   if(result[i].SPO_FirmOrderStatus__c =="Distribution in progress" 
                    || result[i].SPO_FirmOrderStatus__c =="Sent to MyPR"){
                        component.set("v.dislayBtn",true);
                    }
                    if(result[i].SPO_FirmOrderStatus__c.indexOf("Cancelled")==-1 && result[i].IsInferiorVmaxDate__c) {
                        counter++;
                        component.set("v.firmOrderNotCancelledCount",counter);
                    }
                    if(result[i].SPO_FirmOrderStatus__c.indexOf("Distribution in progress")!=-1 || result[i].SPO_FirmOrderStatus__c.indexOf("Received in store")!=-1) {
                        component.set("v.atLeastOneFOinDistrib",true);
                    }
                    if(result[i].SPO_FirmOrderStatus__c.indexOf("Creation in progress")!=-1) {
                        component.set("v.atLeastOneFOinCreation",true);
                    }
                      if(result[i].SPO_FirmOrderStatus__c.indexOf("Cancelled")==-1 && (!result[i].IsInferiorVmaxDate__c)) {
                        count++;
                        component.set("v.firmOrderSuperiorVmaxDate",count);
                    }
                    
                    
                    console.log('+++counter='+counter);
                    console.log('+++firmOrderNotCancelledCount='+component.get("v.firmOrderNotCancelledCount"));
                    console.log('+++count='+count);
                    console.log('+++firmOrderSuperiorVmaxDate='+component.get("v.firmOrderSuperiorVmaxDate"));
                    console.log('+++atLeastOneFOinDistrib='+component.get("v.atLeastOneFOinDistrib"));
                    console.log('+++atLeastOneFOinCrearion='+component.get("v.atLeastOneFOinCreation"));
                    
                   
                }
                
                // this.openModal(component);

            } else if (state === "ERROR") {
                var errors = a.getError();
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
                        } else {
                         //   toastEvent = $A.get("e.c:SO_CustomToastEvent");
                         //   toastEvent.setParams(toastParams);
                         //   toastEvent.fire();
                        }
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            //var spinner = component.find("spinner"); // replace by events (aura:waiting, aura:doneWaiting)
            //$A.util.toggleClass(spinner, "slds-hide");
    	});
        //var spinner = component.find("spinner");
        //$A.util.toggleClass(spinner, "slds-hide");

        // local store if a new request with same parameters are executed again
        //action.setStorable();// no storable because after saving, records with old values will be kept in cache
    	$A.enqueueAction(action);
	},

    getUser:function(component, event){
        var action = component.get("c.getUser");
        action.setCallback(this,function(res){
            var state = res.getState();
            if(state==="SUCCESS"){
                var response = res.getReturnValue();
                console.log(">>>>> response from Apex User =>",JSON.stringify(response));
                 var profileName = response.Profile.Name;
                 console.log(">>>>> response profileName String =>",profileName);
                 component.set("v.profileName",profileName);
                 var subString = "ICON_";
                 if(profileName.indexOf(subString) !== -1 || profileName == "System Administrator"){
                     component.set("v.eligibleProfile",true);
                 }
            }
             $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },

    updateFirmOrders:function(component,event){
        var action = component.get("c.updateFirmOrderDB");

       action.setParams({
            "oppId": component.get("v.recordId")
        });

        action.setCallback(this, function(a) {
            var state = a.getState();

            if (state === "SUCCESS") {
                // var result = a.getReturnValue();
                
                //component.set("v.firmOrderList", result);
				 window.location.reload();
                $A.get('e.force:refreshView').fire();

            } else if (state === "ERROR") {
                var errors = a.getError();
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

        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
       
    },
    cancelAllFirmOrders:function(component, event){
        console.log('h.cancelAllFirmOrders :IN');
        var action = component.get("c.cancelFirmOrderDB");

       action.setParams({
            "oppId": component.get("v.recordId"),
            "who": component.get("v.profileName"),
            "stopBriefR": component.get("v.StopBriefReason"),
            "stopBriefC": component.get("v.StopBriefComment")
        });

        action.setCallback(this, function(a) {
            var state = a.getState();

            if (state === "SUCCESS") {
                var result = a.getReturnValue();
                console.log('h.cancelAllFirmOrders.result= '+JSON.stringify(result));
                //component.set("v.firmOrderList", result);
                //Native Event refresh does not work, compel to force via browser
                window.location.reload();
                $A.get('e.force:refreshView').fire();

            } else if (state === "ERROR") {
                var errors = a.getError();
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
		window.location.reload();
        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
        
    },
    getSORList : function(cmp, event) {
        // TODO get stores in the country of the user
        console.log('+++h.getSORList:IN');
        var action = cmp.get("c.getSORJson");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.stopOrderList", JSON.parse(response.getReturnValue()));

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
            $A.get('e.force:refreshView').fire();
        });
        // optionally set storable, abortable, background flag here
        action.setStorable();
        $A.enqueueAction(action);        
    },
})