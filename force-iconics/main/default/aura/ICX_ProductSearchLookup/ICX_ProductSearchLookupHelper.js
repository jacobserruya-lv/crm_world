({
    // find all products linked to record id (= ICX_ProductEnquired__c.RelatedTo__c) -> return List<LookupSearchResult>
    getCurrentSelection : function(component, event) {
        var action = component.get("c.searchAllRecords");
        var recId = component.get('v.recordId');
        console.log("getCurrentSelection recId", recId);

        action.setParams({
            recordId : recId
        });

        action.setCallback(this, (response) => {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Process server success response
                const returnValue = response.getReturnValue();
            	console.log("returnValue", JSON.stringify(returnValue));
                var selection = component.get("v.selection");
            
            	// Known Products
                if (!$A.util.isEmpty(returnValue[0])) {
            		console.log("init returnValue 0 ", JSON.stringify(returnValue[0]));
		            selection = selection.concat(returnValue[0]);
            	}
				// Unknown products
                if (!$A.util.isEmpty(returnValue[1])) {
            		console.log("init returnValue 1 ", JSON.stringify(returnValue[1]));
		            selection = selection.concat(returnValue[1]);
            	}

        		// clone records for the New Request scenario (we don't want to delete or update existing records related to a Task for example)
        		var requestType = component.get("v.requestType");
                if (!$A.util.isEmpty(requestType)) {
                    // for each selection, change some changes in the records and add a flag to clone or not the request creation
                    for (var key in selection) {
                        var selectionItem = selection[key];
                        console.log("selectionItem=" + JSON.stringify(selectionItem));
                        // TODO parent
                        selectionItem.cloneForRequestCreation = true;
                        //console.log("careItem", careItem);
                    }
                }
        
        		// if Request Type, need a product for PODWithSKU or need a unknown product if PODWithoutSku
        		this.updateSelection(component, selection);
        
        		//var requestType2 = component.get("v.requestType");
                if (requestType === 'PODWithoutSku' && $A.util.isEmpty(returnValue[1])) {
                    // add unknown product by default
                    console.log("add unknown product by default");
                    this.addUnknownProduct(component);
                }
        		/*var requestType = component.get("v.requestType");
                if (requestType === 'PODWithoutSku') {
                    if ($A.util.isEmpty(returnValue[1])) {
                        // add unknown product by default
                        console.log("add unknown product by default");
                        component.set("v.selection", []);
                    } else {
                        component.set("v.selection", selection);
                    }
                } else if (requestType === 'PODWithSKU' && $A.util.isEmpty(returnValue[0])) {
                    component.set("v.selection", []);
                } else {
                    component.set("v.selection", selection);
                }

        		component.set("v.selection", selection);
            	console.log("init selection", JSON.stringify(selection));
                component.set("v.productList", returnValue[0]);
                component.set("v.unknownList", returnValue[1]);*/

	            // useful for Lightning Flow to know if a product was defined
    	        component.set("v.selectionSize", returnValue[0].length);
    	        component.set("v.unknownProductSize", returnValue[1].length);
            
        //        console.log(component.get(v.selection), component.get('v.selection'));
            }
            else if (state === 'ERROR') {
                // Retrieve the error message sent by the server
                const errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    const error = errors[0];
                    if (typeof error.message != 'undefined') {
                        message = error.message;
                    } else if (typeof error.pageErrors != 'undefined' && Array.isArray(error.pageErrors) && error.pageErrors.length > 0) {
                        const pageError = error.pageErrors[0];
                        if (typeof pageError.message != 'undefined') {
                            message = pageError.message;
                        }
                    }
                }
                // Display error in console
                console.error('Error: '+ message);
                console.error(JSON.stringify(errors));
                // Fire error toast if available (LEX only)
                const toastEvent = $A.get('e.force:showToast');
                if (typeof toastEvent !== 'undefined') {
                    toastEvent.setParams({
                        title : 'Server Error',
                        message : message,
                        type : 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
            }
        });

        $A.enqueueAction(action);
    },

	addUnknownProduct : function(component) {
    	var productId = null;
    	var actionType = "ADD";
    	this.updateProductSelected(component, productId, actionType, null);
    },

    updateProduct : function(component, event) {
    	var productId = event.getParam("recordId");
    	var actionType = event.getParam("action");
    	var lookupSearchItem = event.getParam("item");
    	this.updateProductSelected(component, productId, actionType, lookupSearchItem);
    },

    updateProductSelected : function(component, productId, actionType, lookupSearchItem) {
        console.log("updateProduct " + actionType + ", recordId=" + component.get('v.recordId') + ", product=" + productId + "," + JSON.stringify(lookupSearchItem));

        var requestType = component.get("v.requestType");
        var isRelatedToParent = ($A.util.isEmpty(requestType) ? false : true);

        var action;// = (actionType === 'ADD' ? component.get("c.addProduct") : component.get("c.removeProductEnquired"));//removeProduct"));

		if (actionType === 'ADD') {
            action = component.get("c.addProduct");
            
            action.setParams({
                productId : productId, 
                recordId : component.get('v.recordId'),
                isRelatedToParent : isRelatedToParent,
                comment:component.get('v.comment')
            });
            
        } else if (actionType === 'REMOVE') {
            // Delete record only when new call (not for New Request)
            action = component.get("c.removeProductEnquired");
            
            action.setParams({
                recordId : productId,
                isRelatedToParent : isRelatedToParent
            });
        }

        action.setCallback(this, (response) => {
            const state = response.getState();
            if (state === 'SUCCESS') {
	            // Process server success response
            	var selection = component.get("v.selection");
            	console.log("current selection", JSON.stringify(selection));

            	if (actionType === 'REMOVE') {
                    const updatedSelection = selection.filter(item => item.qualification.Id !== productId);
            		console.log("updatedSelection", updatedSelection);
            		//component.set('v.selection', updatedSelection);

            		this.updateSelection(component, updatedSelection); 
            
                } else if (actionType === 'ADD') {
            		var lookupResult = response.getReturnValue();
            		console.log("lookupResult", JSON.stringify(lookupResult));
                    if (!$A.util.isEmpty(lookupResult)) {
                        if (!$A.util.isEmpty(lookupSearchItem)) {
                            // Known Product
                            //lookupSearchItem.cloneForRequestCreation = false;
                            lookupSearchItem.qualification = lookupResult.qualification;
                            selection.push(lookupSearchItem);
                                                   
                            
                            //var productList = component.get("v.productList");
                            //productList.push(lookupSearchItem);
                            //component.set("v.productList", productList);
                        } else {
                            // Unknown product selected
                            //lookupResult.cloneForRequestCreation = ($A.util.isEmpty(component.get("v.requestType")) ? false : true);
                            selection.push(lookupResult); 
                            
                            //var unknownList = component.get("v.unknownList");
                            //unknownList.push(lookupSearchItem);
                            //component.set("v.unknownList", unknownList);
                        }
                        this.updateSelection(component, selection);
                        //component.set('v.selection', selection);                
                    }
                }
            	var selection2 = component.get("v.selection");
            	console.log("updateproduct selection", JSON.stringify(selection2));

                // for mono-product
                component.set("v.selectionId", (actionType === 'REMOVE' ? null : productId));

            	// useful for Lightning Flow to know if a product was defined
            	component.set("v.selectionSize", selection.length);
            }
            else if (state === 'ERROR') {
                // Retrieve the error message sent by the server
                const errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    const error = errors[0];
                    if (typeof error.message != 'undefined') {
                        message = error.message;
                    } else if (typeof error.pageErrors != 'undefined' && Array.isArray(error.pageErrors) && error.pageErrors.length > 0) {
                        const pageError = error.pageErrors[0];
                        if (typeof pageError.message != 'undefined') {
                            message = pageError.message;
                        }
                    }
                }
                // Display error in console
                console.error('Error: '+ message);
                console.error(JSON.stringify(errors));
                // Fire error toast if available (LEX only)
                const toastEvent = $A.get('e.force:showToast');
                if (typeof toastEvent !== 'undefined') {
                    toastEvent.setParams({
                        title : 'Server Error',
                        message : message,
                        type : 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
            }
        });

        $A.enqueueAction(action);
    },
        
    isReadOnly : function (component, event) {
        var readOnly = component.get("v.readOnly");
        var requestType = component.get("v.requestType");

        // Don't do that. In App Builder, just set readOnly field to true
        var isClosed = component.get("v.simpleCase.IsClosed");
        //console.log("component.get(v.simpleCase.Status)", component.get("v.simpleCase.Status"));
        //if (component.get("v.simpleCase.Status") === 'Closed') {
        console.log("isClosed", isClosed);
        if ($A.util.isEmpty(requestType) && isClosed == true) {
            //console.log("isReadOnly Closed");
            readOnly = true;
            console.log("status closed > readOnly", readOnly);
        }

        // Only Admin and ICONICS profiles can add/remove a product
        var userRecord = component.get("v.userRecord");
        if (readOnly == false && userRecord !== null) {
            var profileName = userRecord.Profile.Name.toUpperCase();
            //console.log("profileName", profileName);
            if ((profileName.indexOf("SYSTEM") == -1 && profileName.indexOf("ICONICS") == -1)) {
                readOnly = true;
                console.log("profileName", profileName);
            }
        }
        component.set("v.readOnly", readOnly);
    },

    saveAll : function(component, event) {

        var requestType = component.get("v.requestType");
        console.log("saveAll> requestType", requestType);
        var selection = component.get("v.selection");
        console.log("saveAll> selection", JSON.stringify(selection));

        // for New Request, remove id when the products are reused from a Task for example (=> cloneForRequestCreation = true) 
        if (!$A.util.isEmpty(requestType)) {
            for (var i in selection) {
                console.log("selection[i]", selection[i]);

                var qualification = selection[i].qualification;
                qualification.RequestType__c = requestType;

                if (selection[i].cloneForRequestCreation == true) {
                    // qualification.Parent__c = qualification.Id;
                    // If the existing parent record is already defined, don't create a new Qualification, just update it (ex: BACK button was creating a new Qualification even with an existing qualification from Request Creation)
                    if ($A.util.isEmpty(qualification.ParentRelatedTo__c)) {
                        qualification.Id = null;
                    }
                    qualification.ParentRelatedTo__c = component.get("v.recordId");//qualification.RelatedTo__c;
                    qualification.RelatedTo__c = null;
                    qualification.Request__c = null;
                    console.log("saveAll > qualif", qualification);
                }
            }
        }

        console.log("saveAll > selection", JSON.stringify(selection));   
        var action = component.get("c.saveAll");        
        action.setParams({
            productListJson : JSON.stringify(selection)
        });

        action.setCallback(this, (response) => {
            const state = response.getState();
            if (state === 'SUCCESS') {
                var navigate = component.get('v.navigateFlow');
            	var actionParam = event.getParam("action");
                console.log("navigate", navigate);
                if (!$A.util.isEmpty(navigate) && !$A.util.isEmpty(actionParam)) {
                	navigate(actionParam);
        		}
            }
            else if (state === 'ERROR') {
                // Retrieve the error message sent by the server
                const errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    const error = errors[0];
                    if (typeof error.message != 'undefined') {
                        message = error.message;
                    } else if (typeof error.pageErrors != 'undefined' && Array.isArray(error.pageErrors) && error.pageErrors.length > 0) {
                        const pageError = error.pageErrors[0];
                        if (typeof pageError.message != 'undefined') {
                            message = pageError.message;
                        }
                    }
                }
                // Display error in console
                console.error('Error: '+ message);
                console.error(JSON.stringify(errors));
                // Fire error toast if available (LEX only)
                const toastEvent = $A.get('e.force:showToast');
                if (typeof toastEvent !== 'undefined') {
                    toastEvent.setParams({
                        title : 'Server Error',
                        message : message,
                        type : 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

	updateSelection : function(component, selection) {
        const productSelection = selection.filter(item => !$A.util.isEmpty(item.qualification.Product__c));
        const unknownSelection = selection.filter(item => $A.util.isEmpty(item.qualification.Product__c));

        console.log("productSelection", JSON.stringify(productSelection));
        console.log("unknownSelection", JSON.stringify(unknownSelection));

        component.set("v.productList", productSelection);
        component.set("v.unknownList", unknownSelection);

        // if Request Type, need a product for PODWithSKU or need a unknown product if PODWithoutSku
        var requestType = component.get("v.requestType");
        console.log("requestType", requestType);
        if (requestType === 'PODWithoutSku') {
            component.set("v.selection", unknownSelection);
            //if ($A.util.isEmpty(unknownSelection)) {
                // add unknown product by default
            //    console.log("add unknown product by default");                    
            //}
        } else if (requestType === 'PODWithSKU') {
            component.set("v.selection", productSelection);
        } else if (requestType === 'RequestToStore') {
            component.set("v.selection", (!$A.util.isEmpty(productSelection) ? productSelection : unknownSelection));
        } else {
            //const newProduct = selection.filter(item => ($A.util.isEmpty(item.cloneForRequestCreation) || item.cloneForRequestCreation == false));
            //console.log("newProduct", newProduct);
            component.set("v.selection", selection);
        }
        console.log("selection updatedselection", JSON.stringify(component.get("v.selection")));
    },

	validate : function(component, event) {
        // Set the validate attribute to a function that includes validation logic
        component.set('v.validate', function() {
            console.log("component.get(v.selection)", component.get("v.selection").length);
            if (component.get("v.required")) {
                if (!$A.util.isEmpty(component.get("v.selection"))) {
                    // If the component is valid...
                    var selectionList = component.get("v.selection");
                    
                    var requestType = component.get("v.requestType");
                    for (var i in selectionList) {
                        var qualification = selectionList[i].qualification;
                        console.log("validateRequestType > qualification", JSON.stringify(qualification));
                        //var requestType = qualification.RequestType__c;
                        console.log("validateRequestType > requestType", requestType);
                        

                        if ('PODWithSKU' === requestType) {   
                            if ($A.util.isEmpty(qualification.Store__c))
                                var error1 = $A.get("$Label.c.ICX_Flow_Store_Missing");             
                            if ( $A.util.isEmpty(qualification.Product__c)
                                || $A.util.isEmpty(qualification.ProductCollection__c)
                                || $A.util.isEmpty(qualification.ProductUnitPrice__c)
                                || $A.util.isEmpty(qualification.ProductCurrency__c)) 
                                var error1 = $A.get("$Label.c.ICX_Flow_Product_Error_Missing");
                                return { isValid: false, errorMessage: error1};


                        } else if ('PODWithoutSku' === requestType) {  
                            if ($A.util.isEmpty(qualification.Store__c))
                                var error2 = $A.get("$Label.c.ICX_Flow_Store_Missing");                          
                            if ( $A.util.isEmpty(qualification.ProductCollection__c)
                                || $A.util.isEmpty(qualification.ProductGender__c)
                                || $A.util.isEmpty(qualification.ProductCategory__c)
                                || $A.util.isEmpty(qualification.Product_Unknown__c)
                                || $A.util.isEmpty(qualification.ProductCurrency__c)) 
                                var error2 = $A.get("$Label.c.ICX_Flow_Product_Error_Missing");
                                return { isValid: false, errorMessage: error2};
                            
                          
                        } else if ($A.util.isEmpty(qualification.Product__c)) {
                            // Unknown Product
                            if('DistantCareService' === requestType){    
                                if ($A.util.isEmpty(qualification.Store__c))
                                    var error3 = $A.get("$Label.c.ICX_Flow_Store_Missing");                    
                                if ($A.util.isEmpty(qualification.Email__c) || $A.util.isEmpty(qualification.Phone__c) )
                                var error3 = $A.get("$Label.c.ICX_Flow_Email_Phone_Missing");
                                if ($A.util.isEmpty(qualification.Follow_up_By_Call__c) && $A.util.isEmpty(qualification.Follow_up_By_Email__c) )
                                var error3 = $A.get("$Label.c.ICX_Flow_Followup_Missing");
                                
                            }
                            if (($A.util.isEmpty(qualification.ProductCollection__c) && requestType != 'DistantCareService')
                                || $A.util.isEmpty(qualification.ProductGender__c)
                                || $A.util.isEmpty(qualification.ProductCategory__c)
                                || $A.util.isEmpty(qualification.Product_Unknown__c)
                                || $A.util.isEmpty(qualification.Product_Unknown__c.trim())) 
                                var error3 = $A.get("$Label.c.ICX_Flow_Product_Error_Missing");
                                return { isValid: false, errorMessage: error3};
                            
                                
                        }                       
                        
                        if('DistantCareService' === requestType){    
                        if ($A.util.isEmpty(qualification.Store__c))
                            var error4 = $A.get("$Label.c.ICX_Flow_Store_Missing");                    
                        if ($A.util.isEmpty(qualification.Email__c) || $A.util.isEmpty(qualification.Phone__c) )
                        var error4 = $A.get("$Label.c.ICX_Flow_Email_Phone_Missing");
                        if ($A.util.isEmpty(qualification.Follow_up_By_Call__c) && $A.util.isEmpty(qualification.Follow_up_By_Email__c) )
                        var error4 = $A.get("$Label.c.ICX_Flow_Followup_Missing");
                        return { isValid: false, errorMessage: error4};
                    }
                        /*else if ('RequestToStore' === requestType) {
                        if ($A.util.isEmpty(qualification.Store__c)) {
                            var error = 'Missing store';//$A.get("$Label.c.ICX_Flow_Product_Error_Required");
                            return { isValid: false, errorMessage: error};
                        }
                    }*/
                    }
                    return { isValid: true };
                } else {
                    // If the component is invalid...
                    var error = $A.get("$Label.c.ICX_Flow_Product_Error_Required");
                    return { isValid: false, errorMessage: error};
                }
            }
        })
    },

})