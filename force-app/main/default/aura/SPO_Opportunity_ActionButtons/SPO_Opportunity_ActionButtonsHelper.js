({
    getOpportunity: function(component) {
        var action = component.get("c.findOpportunityById");
        action.setParams({
      		"oppId": component.get("v.recordId")
    	});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.opp", result);
            console.log("v.opp", result);
            
            //var opp = component.get("v.opp");
            if(result.TECH_Nb_FO_Received_in_Store__c > 0 && result.StageName == "In progress"){
            var closeOrderLabel = $A.get("$Label.c.LV_SO_Close_Order");
            console.log("Close Order label :" + closeOrderLabel)
            component.find("closeorder").set("v.label",closeOrderLabel);
        }
            //this.getLastFirmOrder(component);
            
            // TODO test this function (no quotation mode) : maybe not used
            //this.initUnitRetailPriceRMS(component);
    	});
    	$A.enqueueAction(action);
    },

    getUser : function(cmp) {
        var action = cmp.get("c.getUser");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("$$$ user -> ", JSON.stringify(storeResponse));
                cmp.set("v.currentUser", storeResponse);
                console.log("$$$ user -> ", JSON.stringify(cmp.get("v.currentUser")));

            }/* else if (state === "INCOMPLETE") {
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
            }*/
        });
        
        // optionally set storable, abortable, background flag here
        action.setStorable();
        $A.enqueueAction(action);        
    },

    updateOpp : function(component, stageName) {
        console.log("updating opp");
		var opp = component.get("v.opp");
        opp.StageName = stageName;
        if(stageName == 'Quotation in progress')
        {
            opp.SPO_Date_Quotation_in_progress__c = new Date();
        }
        else if(stageName == 'Quotation accepted')
        {
            opp.SPO_Date_Quotation_accepted__c = new Date();
        }
        else if(stageName == 'Creation in progress')
        {
            opp.SPO_Date_Creation_in_progress__c = new Date();
        }
		
        var action = component.get("c.updateOpportunity");
        action.setParams({
      		"opp": opp
    	});
    	action.setCallback(this, function(a) {
            var state = a.getState();
            // debugger;
            if (state === "SUCCESS") {
                // debugger;
                var result = a.getReturnValue();
                // debugger;
                component.set("v.opp", result);
                // debugger;
                console.log("result opp", result);
                
                // TODO toast
                // reload page layout
                /*var refresh = $A.get("e.force:refreshView");
                if (refresh) {
                    console.log('e.force:refreshView');
                    refresh.fire();
                } else {
                    console.log('reload');
                    window.location.reload();
                }
                window.location.reload(true);*/
                $A.get('e.force:refreshView').fire();

                // debugger;
                this.closeModal(component);
                // debugger;
                
                //this.fireRefresh();
            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('error', errors[0].message);
                        // Display toast message to indicate status
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent) {
                            toastEvent.setParams({
                                "type": "error",
                                "mode": "sticky",
                                "title": "Error!",
                                "message": errors[0].message
                            });
                            toastEvent.fire();
                        } else {
                            alert(errors[0].message);
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

    /*getLastFirmOrder : function(component) {
		var opp = component.get("v.opp");
		
        var action = component.get("c.findLastFirmOrderByOppId");
        action.setParams({
      		"oppId": opp.Id
    	});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.lastFirmOrder", result);
            console.log("v.lastFirmOrder", result);
            // TODO toast

            this.closeModal(component);
			// reload page layout
            $A.get('e.force:refreshView').fire();
    	});
    	$A.enqueueAction(action);
	},*/

    /*createOrderInERP: function(component) {		
        this.callServer(component, "c.updateOppToERP");
    },

    sendToReferential: function(component) {
        this.callServer(component, "c.updateOppToReferential");
    },*/

    callServer: function(component, methodName) {
        var action = component.get(methodName);
        action.setParams({
      		"opp": component.get("v.opp")
    	});
    	action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var result = a.getReturnValue();
                component.set("v.opp", result);
                
                // TODO toast
                
                this.closeModal(component);
                // reload page layout
                $A.get('e.force:refreshView').fire();
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = a.getError();
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
    	$A.enqueueAction(action);
    },

    closeModal: function(cmp) {
        // waiting standard Modal component / maybe create a custom component for modal: https://webkul.com/blog/how-to-create-responsive-modal-box-in-lightning-component-salesforce/
        var cmpTarget = cmp.find('Modalbox');
        var cmpBack = cmp.find('MB-Back');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');        
    },
    openModal: function(cmp) {
        // waiting standard Modal component / maybe create a custom component for modal: https://webkul.com/blog/how-to-create-responsive-modal-box-in-lightning-component-salesforce/
        var cmpTarget = cmp.find('Modalbox');
        var cmpBack = cmp.find('MB-Back');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    
    /*initUnitRetailPriceRMS: function(component) {
		var opp = component.get("v.opp");
		
        var action = component.get("c.getPrice");
        action.setParams({
      		"opp": opp
    	});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.opp", result);
            // TODO toast

			// reload page layout
            //$A.get('e.force:refreshView').fire();
    	});
    	$A.enqueueAction(action);
    },*/

    isValid : function(component, auraId) {        
        var cmpAuraId = component.find(auraId);
        var validity = cmpAuraId.get("v.validity").valid;
        if (!validity) {
            cmpAuraId.showHelpMessageIfInvalid();
        }
        return validity;
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

    updateFirmOrderStatus:function(component,event,opp){
        var action = component.get("c.updateFirmOrderDB");
        console.log("OppId :" + opp.Id);
        action.setParams({
            "oppId": opp.Id
            //component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("$$$$ Response received :" +  JSON.stringify(result));
                component.set("v.opp", result);
                
                // TODO toast
                
                //this.closeModal(component);
                // reload page layout
                $A.get('e.force:refreshView').fire();
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

        $A.enqueueAction(action);
    }

})