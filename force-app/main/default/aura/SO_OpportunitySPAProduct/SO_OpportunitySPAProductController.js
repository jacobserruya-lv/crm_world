({
    doInit : function(component, event, helper) {
        //var divProductSelected = component.find("displayProductSelected");
        //$A.util.addClass(divProductSelected,'slds-hide');       

        helper.isMTOEnabled(component);
    },

    /*goBack : function(component, event, helper) {        
        // Fire Component (Bubbling) event to ask the SO_OpportunitySPA LC (Parent) to go back to previous child LC:        
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({"componentAction" : 'Product_Back'});
        cmpEvent.fire();
        
        helper.fireOpportunitySPAEvent(component);
    },*/
    
    goNext : function(component, event, helper) {

        if ($A.util.isEmpty(component.get("v.product")) && component.get("v.showProduct")) {
            // Display toast message to indicate status
            var toastParams = {};
            // console.log('$A.get("e.force:showToast")', toastEvent);
            toastParams = {
                "type": "error",
                //"mode": "sticky",
                "title": "Product required!",
                "message": "Select a product"
            };
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            } else {
                toastEvent = $A.get("e.c:SO_CustomToastEvent");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }

        } else {
            //if (!component.get("v.showProduct")) {
            //    helper.setProductNotFound(component);
            //} else {
            helper.fireNextPage(component);
            helper.fireOpportunitySPAEvent(component);
            //}

        }
    },

    //handleTabJump : function(component, event, helper){
        /*console.log("jumping by SO_OpportunitySPAProduct");
        var params = event.getParams();
        var toastEventParams = {};
        var fireToast = false;
        console.log ("tabto -> " + params.tabTo);
        console.log ("action -> " + params.action);
        var product = component.get("v.product");
        var opp = component.get("v.opp");
        var brief = component.get("v.briefFile");
        var acc = component.get("v.account");

        // Get the material inside and outside to check if they are not empty. This requires in the handle tab jump
        var extMats = "" + opp.SPO_ExteriorMaterial1__c + opp.SPO_ExteriorMaterial2__c + opp.SPO_ExteriorMaterial3__c;
            extMats = extMats.replace(new RegExp('undefined', 'g'), '');
            console.log("Ext Material -> " + extMats);
            var intMats = "" + opp.SPO_LiningInteriorMaterial1__c + opp.SPO_LiningInteriorMaterial2__c;
            intMats = intMats.replace(new RegExp('undefined', 'g'), '');
            console.log("Int Material -> " + intMats);

        console.log("Product Opp Id : ", product);
        if( params.action == 'next' && params.tabTo == 1){
            // var toastEvent = $A.get("e.force:showToast");
            if (product == null) {
                toastEventParams = {
                    "type": "error",
                    //"mode": "sticky",
                    "title": "Product required!",
                    "message": "Please select a product"
                    };
                fireToast = true;
            } else {
                console.log("Jumping to Customize tab ");
            helper.fireNextPage(component);
            helper.fireOpportunitySPAEvent(component,event);
                }
        }
            else if(params.action == "next" && params.tabTo == 2){
                console.log("Jumping to Client tab ");
                    if(opp.Name == null 
                        || opp.SPO_CreationType__c == ""
                        || opp.SPO_ColorMetalicparts__c == "" 
                        || opp.SPO_CommercialLocalComment__c == ""
                        || extMats == ""
                        || intMats == "") {
                    toastEventParams = {
                    "type": "error",
                    //"mode": "sticky",
                    "title": "Required fields needed!",
                    "message": "Required fields are Brief Name, Comment,Creation Type, Color metalic, Outside and Inside Color"
                    };
                fireToast = true;
                } else{
                    //Check if it is not fire from Personalization, it means that the required fields are not completed, don fire
                    helper.fireOpportunitySPAEvent(component,event);
                    helper.fireNextPage2(component);
                }
        } 
        else if(params.action == "next" && params.tabTo == 3){
                if(acc == null){
                toastEventParams = {
                    "type": "error",
                    //"mode": "sticky",
                    "title": "Client is required!",
                    "message": "Please select a client from below search results"
                    };
                fireToast = true;
                } else{
                    console.log("Jumping to Client Summary tab");
                    helper.fireNextPage3(component);
                    helper.fireOpportunitySPAEvent(component,event);
                }
        } 
        else if(component.isValid() && params.action == "back" && params.tabTo == 2){
            helper.fireBackPage1(component,event);
        } 
        else if(component.isValid() && params.action == "back" && params.tabTo == 1){
            helper.fireBackPage2(component,event);
        } 
        else if(component.isValid() && params.action == "back" && params.tabTo == 0){
            helper.fireBackPage3(component,event);
        }

        if (fireToast){
            console.log("fireToast");
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent){
                toastEvent.setParams(toastEventParams);
                toastEvent.fire();
            } else {
                console.log("toastEvent not found");
                var customToast = $A.get("e.c:SO_CustomToastEvent");
                console.log("using custom toast");
                customToast.setParams(toastEventParams);
                console.log(customToast);
                customToast.fire();
            }

        }*/
    //},
    
    handleApplicationEvent : function(component, event, helper) {
        //console.log('product handleApplicationEvent > event', event);
        var params = event.getParams();
        console.log("params in SO_OppSPAProduct, line 69" + JSON.stringify(params));

        //  init product (Creation button in the product page of Make It Your App)
        if (params.channel == 'Init') {
            var productFilter = component.find("productFilter");
            productFilter.initSku(params.product.SKUCode__c, params.product.MainGroup__c);
            
            // stop event
            event.stopPropagation();

        } else {
            component.set("v.opp", params.opp);
            component.set("v.account", params.account);
            console.log(component.get("v.account"));
        }
    },
    
    handleProductSelected : function(component, event, helper) {
        //console.log('event', event);
        //var productId = event.getParam("recordId");
        //component.set("v.productId", productId);
        var params = event.getParams();
        component.set("v.product", params.product);

        if (component.get("v.isMTOEnabled")){
            var canSelectMTO = params.product.MTO__c;
            component.set("v.canSelectMTO", canSelectMTO);
            if (!canSelectMTO){
                component.set("v.isMTO", false);
            }
        }
            
        helper.updateMTO(component);
        helper.setProduct(component, params.product);
        
        //var divProductSelected = component.find("displayProductSelected");
        //$A.util.removeClass(divProductSelected,'slds-hide');       
        /*var opp = component.get("v.opp");
        opp.SPO_BaseSKURefmodelSKU__c = params.product.Id;
        opp.SPO_ProductCategory__c = params.product.ProductCategory__c;
        // TODO check if the new version will be only Creation (and not possible to use MTO anymore)
        opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)';*/
    },

    displayProduct : function(component, event, helper) {
        //var opp = component.get("v.opp");
        //var isDisplayOrder = opp.SPO_DisplayOrder__c;
        //component.set("v.noskubtnclick",true);
        var showProduct = component.get("v.showProduct");
        // change value
        component.set("v.showProduct", !showProduct);

        if (showProduct) {
            helper.setProductNotFound(component);
        }/* else {
            component.set("v.product", null);
        }*/
       // opp.SPO_DisplayOrder__c = !opp.SPO_DisplayOrder__c;
    },

    updateMTO : function(component, event, helper){
        helper.updateMTO(component);
    }

})