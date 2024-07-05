({
    fireOpportunitySPAEvent : function(component,event) {
        //console.log('component.get("v.opp")2', component.get("v.opp"));
        var product;
        
        console.log("component.get(v.showProduct)", component.get("v.showProduct"));
        if (component.get("v.showProduct")) {
            product = component.get("v.product");
        } else {
            product = component.get("v.productNotFound");
        }
        /*//Get the No inspiration SKU value
        var noskubtn = component.get("v.noskubtnclick");
        // Get the value of opportunity to reset if the button noskubtn is clicked
        if(noskubtn){
            var opp = component.get("v.opp");
            opp.Name ="";
            opp.SPO_CommercialLocalComment__c = "";
            opp.SPO_CreationType__c = "";
            opp.SPO_ColorMetalicparts__c ="";
            opp.SPO_Sizewidth__c ="";
            opp.SPO_SizeHeight__c="";
            opp.SPO_SizeLenght__c="";
        }*/

        //Pass the values grabbed from this LC Form to the next child LC via Lightning Events:
        var appEvent = $A.get("e.c:SO_OpportunitySPAEvent");
        //var paramsEvent = event.getParams();
        appEvent.setParams({
            "opp" : component.get("v.opp"),
            "product" : product,
            //"account" : component.get("v.account"),
            "channel": "Product"
        });
        console.log("$$$ this is account" + component.get("v.account"));
        appEvent.fire();
    },
        
    // Fire Component (Bubbling) event to ask the SO_OpportunitySPA LC (Parent) to go to the next child LC:
    fireNextPage: function(component) {
        console.log("fireNextPage product");
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({
            "componentAction" : 'Product_Next' 
        });
        cmpEvent.fire();
    },

    /*fireNextPage2: function(component) {
        console.log("fireNextPage Personalization_Next");
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({
            "componentAction" : 'Personalization_Next' 
        });
        cmpEvent.fire();
    },

    fireNextPage3: function(component) {
        console.log("fireNextPage AccountSearch_Next");
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({
            "componentAction" : 'AccountSearch_Next' 
        });
        cmpEvent.fire();
    },

    fireBackPage1: function(component) {
        console.log("fireBackPage Summary Back");
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({
            "componentAction" : 'Summary_Back' 
        });
        cmpEvent.fire();
    },

    fireBackPage2: function(component) {
        console.log("fireBackPage Account Back");
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({
            "componentAction" : 'AccountSearch_Back' 
        });
        cmpEvent.fire();
    },

    fireBackPage3: function(component) {
        console.log("fireBackPage Customize Back");
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({
            "componentAction" : 'Personalization_Back' 
        });
        cmpEvent.fire();
    },*/

    setProduct : function(component, product) {
        //var opp = component.get("v.opp");
        //console.log("opp", opp);

        if ($A.util.isUndefined(component.get("v.opp"))) {
            component.set("v.opp", {'sobjectType':'Opportunity'});
        }
        var opp = component.get("v.opp");
        console.log("opp", opp);

        console.log("productId", product.Id);
        opp.SPO_BaseSKURefmodelSKU__c = product.Id;
        opp.SPO_ProductCategory__c = (product.SPO_Category__c == 'BELTS' ? 'Belts' : product.SPO_Category__c);//product.ProductCategory__c;
        /*opp.Name = "";
        opp.SPO_CommercialLocalComment__c = "";
        opp.SPO_CreationType__c ="";
        opp.SPO_ColorMetalicparts__c = "";
        opp.SPO_SizeLenght__c = "";
        opp.SPO_SizeHeight__c = "";
        opp.SPO_Sizewidth__c = "";
        component.set("v.opp",opp);*/
        // TODO check if the new Lightning version will be only Creation (and not possible to use MTO anymore)
        //opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)';//type;
    },
    
    // Find product "M99999 - ARTICLE GENERIQUE REPARATION" if Product Not Found selected
    setProductNotFound: function(cmp) {
        var action = cmp.get("c.getProductNotFound");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var prod =  response.getReturnValue();
                prod.ProductCategory__c = "Leather goods";
                cmp.set("v.productNotFound", prod);
                var opp = cmp.get("v.opp");
                opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)';
                this.setProduct(cmp, prod);
                console.log("setProductNotFound", prod);
                this.fireNextPage(cmp);
                this.fireOpportunitySPAEvent(cmp);

                /*var cmpEvent = cmp.getEvent("productEvent");                
                cmpEvent.setParams({
                    "product": prod
                });
                cmpEvent.fire();*/
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
            var spinner = cmp.find("spinner"); // replace by events (aura:waiting, aura:doneWaiting)
            $A.util.toggleClass(spinner, "slds-hide");

    	});
        var spinner = cmp.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");

        action.setStorable();
        $A.enqueueAction(action);        
    },

    updateMTO : function (component){
        var opp = component.get("v.opp");
        var isMTO = component.get("v.isMTO");
        var filterCategory = component.get('v.filterCategory');
        // var product = component.get("v.product");

        if (isMTO){
            opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';

            var product = component.get("v.product");
            opp.Name = product.SKUCode__c + " - " + product.Name;
            opp.SPO_CommercialLocalComment__c = "MTO Order";
            opp.SPO_CreationType__c = (filterCategory == 'Softsided leather goods' ? 'Soft': "Hardsided");
            opp.SPO_SpecialOrderSKUCodeRef__c = product.Id;
            // opp.SPO_ProductCategory__c = (product.SPO_Category__c == 'BELTS' ? 'Belts' : product.SPO_Category__c);
        } else {
            var productId = opp.SPO_BaseSKURefmodelSKU__c;
            var storeId = opp.SPO_Store__c;
            var caId = opp.OwnerId;
            var email = opp.FollowUpByClientAdvisorEmail__c;
            opp = {'sobjectType':'Opportunity'}; // New Opportunity to have all fields cleared
            opp.SPO_BaseSKURefmodelSKU__c = productId;
            opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)';
            opp.SPO_Store__c = storeId;
            opp.OwnerId = caId;
            opp.FollowUpByClientAdvisorEmail__c = email;
            // opp.SPO_ProductCategory__c = (product.SPO_Category__c == 'BELTS' ? 'Belts' : product.SPO_Category__c);
            // opp.Name = "";
            // opp.SPO_CommercialLocalComment__c = "";
            opp.SPO_CreationType__c = (
                filterCategory == 'Softsided leather goods' 
                    ? 'Soft'
                    : (filterCategory == 'Hardsided leather goods' ? 'Hardsided' : null)
            );
            // opp.SPO_SpecialOrderSKUCodeRef__c = "";
        }

        component.set("v.opp", opp);
    },

    isMTOEnabled : function (component){
        var action = component.get("c.getIsMTOEnabled");

        action.setCallback(this, function(result){
            var state = result.getState();

            if (state === "SUCCESS"){
                var isMTOEnabled = result.getReturnValue();
                component.set("v.isMTOEnabled", isMTOEnabled);
            } else {
                console.log("unable to fetch isMTOEnabled");
            }
        });

        $A.enqueueAction(action);
    }
})