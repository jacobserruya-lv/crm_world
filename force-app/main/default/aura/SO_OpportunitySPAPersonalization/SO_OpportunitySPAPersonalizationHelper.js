({
    fireOpportunitySPAEvent : function(component) {
        //console.log('component.get("v.opp")2', component.get("v.opp"));
        //Pass the values grabbed from this LC Form to the next child LC via Lightning Events:
        var appEvent = $A.get("e.c:SO_OpportunitySPAEvent");
        appEvent.setParams({
            "opp" : component.get("v.opp"),
            "channel" : "Personalization"
        });
        appEvent.fire();
    },

   /* findStoreAndFireOpportunitySPAEvent : function(component) {
        var action = component.get("c.getStore");
        action.setParams({
            "storeCode": component.get("v.storeCode")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("storeResponse", storeResponse);
                component.set("v.store", storeResponse);
                
                var opp = component.get("v.opp");
                opp.SPO_Store__c = storeResponse.Id;

                this.fireOpportunitySPAEvent(component);

            } else if (state === "INCOMPLETE") {
                // do something
                console.log("incomplete");
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

    },*/

    /*findStore : function(component) {
        var action = component.get("c.getStore");
        action.setParams({
            "storeCode": component.get("v.storeCode")//.SPO_Store__c
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //console.log("storeResponse", storeResponse);
                component.set("v.store", storeResponse);
                
                var opp = component.get("v.opp");
                opp.SPO_Store__c = storeResponse.Id;
            } else if (state === "INCOMPLETE") {
                // do something
                console.log("incomplete");
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

    getStoreList : function(cmp) {
        // TODO get stores in the country of the user
        
        var action = cmp.get("c.getStoreJson");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.storeList", JSON.parse(response.getReturnValue()));


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

    getUser : function(cmp) {
        // TODO get current user store
        // TODO get stores in the country of the user
        var action = cmp.get("c.getUser");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                cmp.set("v.user", storeResponse);
                
                
                
                cmp.set("v.storeCode", storeResponse.DefaultStore__c);

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
        //action.storable();
        $A.enqueueAction(action);        
    },*/

    getSPAPersonalizationJson : function(cmp) {
        var action = cmp.get("c.getSPAPersonalizationJson");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // TODO use v.options for <ui:inputSelect> and not in page
                //console.log("response.getReturnValue()", response.getReturnValue());
                var returnValue = response.getReturnValue();

                cmp.set("v.colorMetalicList",	 JSON.parse(returnValue.COLORMETALIC));
                cmp.set("v.creationTypeList",	 JSON.parse(returnValue.CREATIONTYPE));
                cmp.set("v.exoList",	         JSON.parse(returnValue.ISEXO));
                //cmp.set("v.paintingList",	   	 JSON.parse(returnValue.PAINTING));
                cmp.set("v.paintingStyleList",	 JSON.parse(returnValue.PAINTINGSTYLE));
                cmp.set("v.productCategoryList", JSON.parse(returnValue.PRODUCTCATEGORY));
                cmp.set("v.specialEventList",    JSON.parse(returnValue.SPECIALEVENT));
                //cmp.set("v.unitList",			 JSON.parse(returnValue.UNIT));
                //cmp.set(attribute, JSON.parse(response.getReturnValue()));
                
                /*var result = response.getReturnValue();
                var typeOpts = new Array();
                // Set the result on the ui:inputSelect component
                for (var i = 0; i < result.length; i++) {
                    typeOpts.push({label: result[i], value: result[i]});//, selected: result[i] === type});
                }
                cmp.find("unitField").set("v.options", typeOpts);*/

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
        
    isValid : function(component, auraId) {    
        var cmpAuraId = component.find(auraId);
        console.log("$$ cmpAuraId in helper isValid " + JSON.stringify(cmpAuraId));
        var validity;
        if(cmpAuraId.constructor == Array){
            validity = cmpAuraId[0].get("v.validity").valid;
        } else {
            validity = cmpAuraId.get("v.validity").valid;
        }
        
        if (!validity) {
            cmpAuraId.showHelpMessageIfInvalid();
        }
        return validity;
    },

    findOppById : function(component) {

        if ($A.util.isEmpty(component.get("v.recordId")) === false) {
            
            var action = component.get("c.findOppById");
            action.setParams({
                "oppId" : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseReturn = response.getReturnValue();
                    component.set("v.opp", responseReturn);
                    console.log("responseReturn", responseReturn);
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
	},

    retrievePrices : function(component, event){
        var store = component.get("v.store");

        if (store){
            var storeCode = store.RetailStoreId__c;
            var product = component.get("v.product");
            var baseSKU = product.SKUCode__c;

            this.retrievePricesRMS(component, storeCode, baseSKU);
        }
    },

    retrievePricesRMS : function(component, storeCode, baseSKU){
        console.log("retrievePrices");
        console.log("storeCode => " + storeCode);
        console.log("baseSKU => " + baseSKU);

        var action = component.get("c.retrievePricesFromRMS");
        action.setParams({
            "storeCode" : storeCode,
            "baseSKU" : baseSKU
        });

        action.setCallback(this, function(result){
            
            var state = result.getState();
            var error = "";
            var opp = component.get("v.opp");

            if (state === "SUCCESS"){
                console.log("Server Call SUCCESS!");

                var priceResults = result.getReturnValue();
                console.log(priceResults);
                if (priceResults.calloutSuccessResult){

                    var unitPrice = priceResults.articlePrice;
                    opp.SPO_UnitRetailPrice__c = unitPrice;
                    opp.SPO_UnitRetailPriceQuotation__c = unitPrice;
                    opp.Amount = opp.SPO_SkuQuantity__c * unitPrice;
                    opp.SPO_StoreCurrency__c = priceResults.storeCurrency;
                } else {

                    error = $A.get("$Label.c.LV_SO_MTO_RMSCalloutFailed");
                    opp.SPO_UnitRetailPrice__c = "";
                    opp.SPO_UnitRetailPriceQuotation__c = "";
                    opp.Amount = "";
                    opp.SPO_StoreCurrency__c = "";
                }
            } else {
                error = $A.get("$Label.c.LV_SO_MTO_ServerCallFailed");
                opp.SPO_UnitRetailPrice__c = "";
                opp.SPO_UnitRetailPriceQuotation__c = "";
                opp.Amount = "";
                opp.SPO_StoreCurrency__c = "";
            }

            if (error){

                var toastEvent = $A.get("e.force:showToast");
                if (!toastEvent){
                    toastEvent = $A.get("e.c:SO_CustomToastEvent");
                }
                var toastParams = {};
                console.log('toastEvent -->', toastEvent);
                toastParams = {
                    "type":"error",
                    "title": error,
                    "message": $A.get("$Label.c.LV_SO_MTO_PricesErrorMessage")
                };

                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
            
            component.set("v.opp", opp);
            var spinner = component.find("spinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });

        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");

        $A.enqueueAction(action);
    }

   /* loadRecord: function(component) {
        component.find("recordCreator").getNewRecord(
            "Opportunity",	// sObject type (entity API name)
            null,      		// record type
            null,      		// default record values
            false,     		// skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.opp");
                var error = component.get("v.newContactError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.sobjectType);
                }
            })
        );
    }*/

    /*getUnitList : function(cmp) {
    	this.callServer(cmp, "c.getUnitJson", "v.unitList");
    },
    getColorMetalicList : function(cmp) {
    	this.callServer(cmp, "c.getColorMetalicJson", "v.colorMetalicList");
    },
    getPaintingList : function(cmp) {
    	this.callServer(cmp, "c.getPaintingJson", "v.paintingList");
    },
    getPaintingStyleList : function(cmp) {
    	this.callServer(cmp, "c.getPaintingStyleJson", "v.paintingStyleList");
    },
    getCreationTypeList : function(cmp) {
    	this.callServer(cmp, "c.getCreationTypeJson", "v.creationTypeList");
    },
    getProductCategoryList : function(cmp) {
    	this.callServer(cmp, "c.getProductCategoryJson", "v.productCategoryList");
    },
    getSpecialEventList : function(cmp) {
    	this.callServer(cmp, "c.getSpecialEventJson", "v.specialEventList");
    },
        callServer : function(cmp, method, attribute) {        
        var action = cmp.get(method);
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // TODO use v.options for <ui:inputSelect> and not in page
                cmp.set(attribute, JSON.parse(response.getReturnValue()));
                
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
*/
})