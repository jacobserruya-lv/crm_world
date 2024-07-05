({
    doInit : function(component, event, helper) {
        //if (component.get("v.view") === 'Edit') {
            
        // TODO one server call instead of 7 server calls. The server call could return a map
        /*helper.getCreationTypeList(component);
        helper.getUnitList(component);
        helper.getColorMetalicList(component);
        helper.getPaintingList(component);
        helper.getPaintingStyleList(component);
        helper.getProductCategoryList(component);
        helper.getSpecialEventList(component);*/
        helper.getSPAPersonalizationJson(component);
        helper.findOppById(component);
    
        // TODO get all stores: get current user to get store id and get all stores in the country
        /*if ($A.util.isEmpty(component.get("v.store"))) {
            helper.getUser(component);
        } else {
            component.set("v.storeCode", component.get("v.store").RetailStoreId__c);
        }
        helper.getStoreList(component);*/

        //var opp = component.get("v.opp");
        // init creation type for LG (to display color panels)
        //console.log("opp.SPO_ProductCategory__c", opp.SPO_ProductCategory__c);
        //console.log("opp.SPO_CreationType__c", opp.SPO_CreationType__c);
        // console.log("opp", component.get("v.opp"));
       /* var o = component.get("v.opp");
        console.log("o -> " + JSON.stringify(o));
        if (o != null && ($A.util.isEmpty(o.SPO_ProductCategory__c) || o.SPO_ProductCategory__c == 'Other')){
        console.log("o.SPO_ProductCategory__c -> " + o.SPO_ProductCategory__c);
            o.SPO_ProductCategory__c = 'Leather goods';
        }
        var p = component.get("v.product");
        console.log("product customize", p);
        if (o != null && p != null){
            if ($A.util.isEmpty(o.SPO_Sizewidth__c) && $A.util.isEmpty(o.SPO_SizeHeight__c) && $A.util.isEmpty(o.SPO_SizeLenght__c)){
                o.SPO_Sizewidth__c = p.Witdth__c;
                o.SPO_SizeHeight__c = p.Height__c;
                o.SPO_SizeLenght__c = p.Length__c;
            }
        }
        component.set("v.opp", o);*/
        // console.log("opp -> ", component.get("v.opp"));

        /*var product = component.get("v.product");
        console.log("product 2 customize", product);
        if (product != null && product.ProductCategory__c == 'Other'){
            product.ProductCategory__c = 'Leather goods';
        }
        component.set("v.product", product);

        if ($A.util.isEmpty(opp) === false) {
            // if (opp.SPO_ProductCategory__c === 'Leather goods' && $A.util.isEmpty(opp.SPO_CreationType__c)) {
            //  opp.SPO_CreationType__c = 'Soft';
                // User should choose the category when the generic product is chosen
                //if (opp.SPO_ProductCategory__c === 'Other') {
                //    opp.SPO_ProductCategory__c = '';
                //}

                // component.set("v.existinglock", opp.SPO_LockNumber__c.length > 0);
            // }
            console.log("opp.SPO_SkuQuantity__c", opp.SPO_SkuQuantity__c);
            if ($A.util.isEmpty(opp.SPO_SkuQuantity__c)) {
                opp.SPO_SkuQuantity__c = 1;
            }
        }*/
        
    },
    /*afterRender : function(component, helper){
        console.log("afterRender");
    },*/

    goBack : function(component, event, helper) {        

        // Fire Component (Bubbling) event to ask the SO_OpportunitySPA LC (Parent) to go back to previous child LC:        
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({"componentAction" : 'Personalization_Back'});
        cmpEvent.fire();

        helper.fireOpportunitySPAEvent(component);
    },
    
    goNext : function(component, event, helper) {
        // validate all components called "field"
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        /*var beltSizeInvalid = component.find('beltSize').reduce(function(validdSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').tooLong;
        }, true);*/
        
        // validate fields are filled
        //var storeValidity = helper.isValid(component, "storeSelect");
        
        var opp = component.get("v.opp");

        var productCategoryValid = true;
        if ($A.util.isEmpty(opp.SPO_ProductCategory__c)) {
            productCategoryValid = helper.isValid(component, "productCategory");
        }

        var isLeatherGoodsValid = true;
        var isAccessoriesValid = true;
        var isWatchValid = true;
        if (opp.SPO_ProductCategory__c === "Leather goods") {
            //var creationTypeValidity = helper.isValid(component, "creationTypeSelect");
            var colorMetalicValidity = helper.isValid(component, "colorMetalic");        
            
            var colorMetalicOtherValid = true;
            if (opp.SPO_ColorMetalicparts__c === "Other (free text)") {
                colorMetalicOtherValid = helper.isValid(component, "colorMetalicComment");
            }
            
            var patchStyleValid = true;
            var patchNameValid = true;
            if (opp.SPO_PaintingYN__c === "Yes") {
                patchStyleValid = helper.isValid(component, "patchStyle");
                patchNameValid = helper.isValid(component, "patchName");
            }
            
            var lockValid = true;
            if (opp.SPO_Lock__c === 'Yes' && opp.SPO_CreationType__c == "Hardsided") {
                lockValid = helper.isValid(component, "lockNumber");
            } else if(opp.SPO_Lock__c == "Yes" && opp.SPO_CreationType__c == "Soft") {
                //Clear the old valud set by choosing creation type Hardsided before changing to Soft
                opp.SPO_LockNumber__c = "";
                opp.SPO_Lock__c = "No";
            }
            
            var itemPackValid = true;
            if (opp.SPO_ClientAccessoriesRequested__c === 'Yes') {
                itemPackValid = helper.isValid(component, "commentAccess");
            }
            
            var allDimensionValid = helper.isValid(component, "width") && helper.isValid(component, "length") && helper.isValid(component, "height");
            
            if (colorMetalicValidity && patchStyleValid 
                && patchNameValid       && lockValid 
                && itemPackValid        && colorMetalicOtherValid && allDimensionValid) {
                isLeatherGoodsValid = true;
            } else {
                isLeatherGoodsValid = false;
                
            }

            // At least one exterior and one interior material
            var isMTO = component.get("v.isMTO");
            var extMats = "" + opp.SPO_ExteriorMaterialColor1__c + opp.SPO_ExteriorMaterialolor2__c + opp.SPO_ExteriorMaterialolor3__c;
            extMats = extMats.replace(new RegExp('undefined', 'g'), '');
            console.log("Ext Material -> " + extMats);
            var intMats = "" + opp.SPO_LiningInteriorColor1__c + opp.SPO_LiningInteriorColor2__c;
            intMats = intMats.replace(new RegExp('undefined', 'g'), '');
            console.log("Int Material -> " + intMats);
            if ( (isMTO || (extMats != "" && intMats != ""))){ // No material required for MTO

            } else {
                isLeatherGoodsValid = false;
                var colorExt = component.find('colorext');
                // var toastEvent = $A.get("e.force:showToast");
                var toastParams = {};
                if(extMats == ""){
                    $A.util.removeClass(colorExt,'slds-container--fluid');
                    $A.util.addClass(colorExt,'error');
                    console.log('toastEvent -->', toastEvent);
                    toastParams = {
                        "type":"error",
                        "title": "Outside color is required",
                        "message": "Please choose a color"
                    };
                    // toastEvent.fire();
                } else {
                    console.log('toastEvent -->', toastEvent);
                    toastParams = {
                        "type":"error",
                        "title": "Inside color is required",
                        "message": "Please choose a color"
                    };
                    // toastEvent.fire();
                }

                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent){
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                } else {
                    console.log("toastEvent not found");
                    var customToast = $A.get("e.c:SO_CustomToastEvent");
                    console.log("using custom toast");
                    customToast.setParams(toastParams);
                    console.log(customToast);
                    customToast.fire();
                }
            }
        //     var type = opp.SPO_CreationType__c;
        //     var extMatcolor1 = "" + opp.SPO_ExteriorMaterialColor1__c;
        //     var extMatcolor2 = "" + opp.SPO_ExteriorMaterialColor2__c;
        //     var extMatcolor3 = "" + opp.SPO_ExteriorMaterialColor3__c;
        //     extMatcolor1 = extMatcolor1.replace(new RegExp('undefined', 'g'), '');
        //     extMatcolor2 = extMatcolor2.replace(new RegExp('undefined', 'g'), '');
        //     extMatcolor3 = extMatcolor3.replace(new RegExp('undefined', 'g'), '');
        //     console.log("Ext Material -> " + extMatcolor1);
        //     console.log("Ext Material -> " + extMatcolor2);

        //     var intMatcolor1 = "" + opp.SPO_LiningInteriorColor1__c  ;
        //     var intMatcolor2 = "" + opp.SPO_LiningInteriorColor2__c  ;
        //     intMatcolor1 = intMatcolor1.replace(new RegExp('undefined', 'g'), '');
        //     intMatcolor2 = intMatcolor2.replace(new RegExp('undefined', 'g'), '');
        //     console.log("Ext Material -> " + extMatcolor1);
        //     if (type=="Soft" ){
        //     if (creationTypeValidity && extMatcolor1 != "" && extMatcolor2 != "" && intMatcolor1 != ""){

        //     } else {
        //         isLeatherGoodsValid = false;
        //         var colorExt = component.find('colorext');
                
        //         var toastParams = {};
        //         if(extMatcolor1 == ""){
        //             $A.util.removeClass(colorExt,'slds-container--fluid');
        //             $A.util.addClass(colorExt,'error');
        //             console.log('toastEvent -->', toastEvent);
        //             toastParams = {
        //                 "type":"error",
        //                 "title": "Outside color Material 1 is required",
        //                 "message": "Please choose a color"
        //             };
                    
        //         } else if(extMatcolor2 == ""){
        //            $A.util.removeClass(colorExt,'slds-container--fluid');
        //             $A.util.addClass(colorExt,'error');
        //             console.log('toastEvent -->', toastEvent);
        //             toastParams = {
        //                 "type":"error",
        //                 "title": "Outside color Material 2 is required",
        //                 "message": "Please choose a color"
        //             };
                    
        //         }
        //         else{
        //               console.log('toastEvent -->', toastEvent);
        //             toastParams = {
        //                 "type":"error",
        //                 "title": "Inside color is required ",
        //                 "message": "Please choose a color"
        //             };

        //         }
               
        //         var toastEvent = $A.get("e.force:showToast");
        //         if (toastEvent){
        //             toastEvent.setParams(toastParams);
        //             toastEvent.fire();
        //         } else {
        //             console.log("toastEvent not found");
        //             var customToast = $A.get("e.c:SO_CustomToastEvent");
        //             console.log("using custom toast");
        //             customToast.setParams(toastParams);
        //             console.log(customToast);
        //             customToast.fire();
        //         }
        //     }
        // }
        // else if (type=="Hardsided" ){
        //     if (creationTypeValidity && extMatcolor1 != "" && intMatcolor1 != "" && intMatcolor2 != ""){

        //     } else {
        //         isLeatherGoodsValid = false;
        //         var colorExt = component.find('colorext');
                
        //         var toastParams = {};
        //         if(intMatcolor1 == ""){
        //             $A.util.removeClass(colorExt,'slds-container--fluid');
        //             $A.util.addClass(colorExt,'error');
        //             console.log('toastEvent -->', toastEvent);
        //             toastParams = {
        //                 "type":"error",
        //                 "title": "Inside color Material 1 is required",
        //                 "message": "Please choose a color"
        //             };
                    
        //         } else if(intMatcolor2 == ""){
        //            $A.util.removeClass(colorExt,'slds-container--fluid');
        //             $A.util.addClass(colorExt,'error');
        //             console.log('toastEvent -->', toastEvent);
        //             toastParams = {
        //                 "type":"error",
        //                 "title": "Inside color Material 2 is required",
        //                 "message": "Please choose a color"
        //             };
                    
        //         }
        //         else{
        //               console.log('toastEvent -->', toastEvent);
        //             toastParams = {
        //                 "type":"error",
        //                 "title": "Outside color is required ",
        //                 "message": "Please choose a color"
        //             };

        //         }
               
        //         var toastEvent = $A.get("e.force:showToast");
        //         if (toastEvent){
        //             toastEvent.setParams(toastParams);
        //             toastEvent.fire();
        //         } else {
        //             console.log("toastEvent not found");
        //             var customToast = $A.get("e.c:SO_CustomToastEvent");
        //             console.log("using custom toast");
        //             customToast.setParams(toastParams);
        //             console.log(customToast);
        //             customToast.fire();
        //         }
        //     }
        // }
        } else if (opp.SPO_ProductCategory__c === "Belts") {
            isAccessoriesValid = helper.isValid(component, "beltSize");
        } else if (opp.SPO_ProductCategory__c === "Watches") {
            isWatchValid = helper.isValid(component, "wristSize");
        }

        if (allValid                && isLeatherGoodsValid && isAccessoriesValid && isWatchValid
            && productCategoryValid) {
            //&& storeValidity      && productCategoryValid) {
            //helper.fireActionEvent(component);

            // Fire Component (Bubbling) event to ask the SO_OpportunitySPA LC (Parent) to go to the next child LC:
            var cmpEvent = component.getEvent("bubblingEvent");
            cmpEvent.setParams({"componentAction" : 'Personalization_Next' });
            cmpEvent.fire();
            
//            helper.findStoreAndFireOpportunitySPAEvent(component);
            helper.fireOpportunitySPAEvent(component);
        }
    },

    handleApplicationEvent : function(component, event) {
        var params = event.getParams();
        var opp = params.opp;
        
        console.log("params Perso", params);
        if (params.channel === "Account") {
            component.set("v.account", params.account);
            component.set("v.store", params.store);
        }
        if (params.channel === "Product") {
            component.set("v.product", params.product);
            //console.log("prodcut", params.product);
            
            var o = component.get("v.opp");
            if ($A.util.isUndefined(o.SPO_ProductCategory__c) || o.SPO_ProductCategory__c == 'Other'){
                o.SPO_ProductCategory__c = 'Leather goods';
                component.set("v.opp", o);
            }
            
            if (    o.SPO_Sizewidth__c      !=  params.product.Witdth__c 
                    && o.SPO_SizeHeight__c  !=  params.product.Height__c 
                    && o.SPO_SizeLenght__c  !=  params.product.Length__c){
                o.SPO_Sizewidth__c = params.product.Witdth__c;
                o.SPO_SizeHeight__c = params.product.Height__c;
                o.SPO_SizeLenght__c = params.product.Length__c;
            }
            
            // init creation type for LG (to display color panels)
            // if (opp.SPO_ProductCategory__c === 'Leather goods' && $A.util.isEmpty(opp.SPO_CreationType__c)) {
            //     opp.SPO_CreationType__c = 'Soft';
            // }
            
            // User should choose the category when the generic product is chosen
            //if (opp.SPO_ProductCategory__c === 'Other') {
            //    opp.SPO_ProductCategory__c = '';
            //}
            console.log("opp.SPO_SkuQuantity__c", opp.SPO_SkuQuantity__c);
            if ($A.util.isEmpty(opp.SPO_SkuQuantity__c)) {
                opp.SPO_SkuQuantity__c = 1;
            }
        }
        component.set("v.opp", opp);
    },

    changeCreationType : function(component, event) {
        //This block of code always get undefined when changing when changing the creation type. 
        //So I comment out this code and do the following workaround

        //var newValue = event.getParam("value"); // this code always returns undefind
        //console.log("new CreationType " + newValue);
        //var oldValue = event.getParam("oldValue"); // This line also returns undefin
        //console.log("old CreationType " + oldValue);
        // need to reload color picker components if value changes
        //if (!$A.util.isEmpty(newValue) && oldValue !== newValue) { 
             
            var reload = component.get("v.reloadColorPicker");
            // force to reload component is changing value
            component.set("v.reloadColorPicker", !reload);
        //}

        /* //Get the selected value
        var currentSelectedVal = component.find("creationTypeSelect");
        // Set the value to attribute  
        var selectedCreationType = component.set("v.creationTypeSelected",currentSelectedVal);
        console.log("selected Creation Type : " + selectedCreationType);

        //Get the selected value
        var currentSelectedVal = component.find("creationTypeSelect");
        // Set the value to attribute  
        var selectedCreationType = component.set("v.creationTypeSelected",currentSelectedVal);
        console.log("selected Creation Type : " + selectedCreationType);

        var oppCreationType = component.get("v.opp");
        console.log("Opp Creation Type : " + oppCreationType);
        if(selectedCreationType == "Soft") return;
        else if(selectedCreationType != oppCreationType && oppCreationType == "Soft"){
            var reload = component.get("v.reloadColorPicker");
            // force to reload component is changing value
            component.set("v.reloadColorPicker", !reload);
        } */
    },
    
    changePainting: function(component) {
        var opp = component.get("v.opp");
        
        if (opp.SPO_PaintingYN__c === "Yes") {
            opp.SPO_PaintingYN__c = "No";
            opp.SPO_Patch__c = "";
            opp.SPO_PatchFreeText__c = "";
        } else {
            opp.SPO_PaintingYN__c = "Yes";            
        }
        
        //opp.SPO_PaintingYN__c = (opp.SPO_PaintingYN__c === "Yes" ? "No" : "Yes");
        component.set("v.opp", opp);
    },

    changeLock: function(component) {
        var opp = component.get("v.opp");
        
        if (opp.SPO_Lock__c === "Yes") {
            opp.SPO_Lock__c = "No";
            opp.SPO_LockNumber__c = "";
        } else {
            opp.SPO_Lock__c = "Yes";            
        }
        
        component.set("v.opp", opp);
    },
    
    changeItemPack: function(component) {
        var opp = component.get("v.opp");
        
        if (opp.SPO_ClientAccessoriesRequested__c === "Yes") {
            opp.SPO_ClientAccessoriesRequested__c = "No";
            opp.SPO_CommentClientAccessories__c = "";
        } else {
            opp.SPO_ClientAccessoriesRequested__c = "Yes";            
        }
        
        component.set("v.opp", opp);        
    },

    changeColorMetalic: function(component) {
        var opp = component.get("v.opp");
        
        if (opp.SPO_ColorMetalicparts__c !== "Other (free text)") {
            opp.SPO_ColorMetalicPartsLocalComment__c = "";
            component.set("v.opp", opp);        
        }
    },
    
    onRender : function(component, event, helper) {
        var tab = component.get("v.tab");
        var updateRMSPrices = component.get("v.updateRMSPrices");

        if (tab == 'summary' && updateRMSPrices){
            console.log("updating prices");
            component.set("v.updateRMSPrices", false);
            helper.retrievePrices(component, event);
        }
    },

    retrievePrices : function(component, event, helper){

        helper.retrievePrices(component, event);
    },

    handleRMSflag : function(component, event, helper){
        var store = component.get("v.store");
        var product = component.get("v.product");
        var isMTO = component.get("v.isMTO");
        var updateRMSPrices;

        if (isMTO && store && store.RetailStoreId__c && product && product.SKUCode__c){
            updateRMSPrices = true;
        } else {
            updateRMSPrices = false;
        }

        component.set("v.updateRMSPrices", updateRMSPrices);
    }, 


    changeExo: function(component, event, helper) {
        var reload = component.get("v.reloadColorPicker");
            // force to reload component is changing value
            component.set("v.reloadColorPicker", !reload);
    }

    /*checkNumberLength : function(component){
        var validity = component.find("beltSize").get("v.validity");
        console.log("Validity of beltSize " + validity.valid);

        var allValid = component.find('beltSize').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            alert('All form entries look valid. Ready to submit!');
        } else {
            alert('Please update the invalid form entries and try again.');
        }
    },*/

    /*changeStore: function(component, event, helper) {
        helper.findStore(component);     
    },*/

    /*
    textAreaAdjust : function(component) {
        var comment = component.find("comment");
        console.log("comment", comment);
        var val = comment.get("v.value");
        console.log("val", val);
        
        commentValue = component.get("v.opp.SPO_CommercialLocalComment__c");
        //console.log("commentValue",commentValue.length);
        
        if (val) {
            console.log("length", val.length);
            if((val.length % 20) === 0) {
 //               var row = comment.get("v.rows");
                comment.set("v.rows", comment.get("v.rows") + 1)
            }
        }
         
        console.log("rows", comment.get("v.rows"));
       // console.log("length", comment.get("v.value").length);

        //comment.style.height = "1px";
        //comment.style.height = (25+ comment.scrollHeight)+"px";
    }*/

})