({

    doInit : function(component, event, helper) {
        //helper.getPicklistValue(component);
        var requestType = component.get("v.requestType");
        var taskCategory = component.get("v.taskCategory"); //naomi 02/05/2022
        console.log("requestType", requestType);
        if (!$A.util.isEmpty(requestType)) {
            component.set("v.item.qualification.RequestType__c", requestType);
            // Request fields are managed in the Screen Flow (ex: Request to Store without SKU)
            if (requestType !== 'RequestToStore') {
                component.set("v.item.qualification.CreateRequest__c", true);
            }
            console.log("update qualif request", component.get("v.item.qualification.RequestType__c"));
        }
        if(!$A.util.isEmpty(component.get("v.clientPhone")))
            component.set("v.item.qualification.Phone__c", component.get("v.clientPhone"));
        if(!$A.util.isEmpty(component.get("v.clientEmail")))
            component.set("v.item.qualification.Email__c", component.get("v.clientEmail"));

        if(requestType =='DistantCareService'){
            //default value on Distant care service store 
            var action = component.get("c.getDCSstore");  
            action.setCallback(this, (response) => {
                const state = response.getState();
                if (state === 'SUCCESS' && response.getReturnValue()!=null) {
                    component.set("v.item.qualification.Store__c",response.getReturnValue().Id);
                }else{
                    component.set("v.item.qualification.Store__c",null);
                }
            }); 
            $A.enqueueAction(action);

             //default list of store according to user's country 
             var action2 = component.get("c.getUserZone");  
             action2.setCallback(this, (response) => {
                 const state = response.getState();
                 console.log("userZone: ",response.getReturnValue());
                 if (state === 'SUCCESS' && response.getReturnValue()!=null) {
                    
                     component.set("v.userZone",response.getReturnValue());
                 }else{
                     component.set("v.userZone",null);
                 }
             }); 
             $A.enqueueAction(action2);
        }
        
                 //naomi 02/05/2022
        
        console.log("taskCategory", taskCategory);
        let category = ['Neverfull','Digital Collectibles'];
        if(taskCategory=='Neverfull' && component.get('v.item.qualification.Product__c')==null)
        {
            component.set("v.item.qualification.Product_Unknown__c",'Neverfull');
            component.set("v.item.qualification.ProductGender__c",'Female');
            component.set("v.item.qualification.ProductCategory__c",'MAR');
            // component.set("v.item.qualification.ProductCollection__c",'');
            //////////////////////////////////////
            component.set("v.item.title",'Neverfull');
            component.set("v.item.subtitle", (component.get("v.item.qualification.ProductCategory__c") + ' • ' + component.get("v.item.qualification.ProductGender__c") + 
            ' • ' + (component.get("v.item.qualification.ProductCollection__c")?component.get("v.item.qualification.ProductCollection__c"):'')));
            // component.set("v.item.relatedName",'');
        }
        else if(taskCategory == 'Digital Collectibles' && component.get('v.item.qualification.Product__c')==null)
        {
            component.set("v.item.qualification.Product_Unknown__c",'Digital Collectibles');
            component.set("v.item.qualification.ProductGender__c",'Unisex');
            component.set("v.item.qualification.ProductCategory__c",'');
            // component.set("v.item.qualification.ProductCollection__c",'');
            //////////////////////////////////////
            component.set("v.item.title",'Digital Collectibles');
            component.set("v.item.subtitle", (component.get("v.item.qualification.ProductGender__c") + 
            ' • ' + (component.get("v.item.qualification.ProductCollection__c")?component.get("v.item.qualification.ProductCollection__c"):'')));
            // component.set("v.item.relatedName",'');
        }
        else if(!category.includes(taskCategory) && category.includes(component.get('v.item.title')) && component.get('v.item.qualification.Product__c')==null )
        {
            component.set("v.item.qualification.Product_Unknown__c",'');
            component.set("v.item.qualification.ProductGender__c",'');
            component.set("v.item.qualification.ProductCategory__c",'');
            component.set("v.item.qualification.ProductCollection__c",'');
            //////////////////////////////////////
            component.set("v.item.title",'');
            component.set("v.item.subtitle",'');
            // component.set("v.item.relatedName",'');
        }

        console.log("product_unknown",component.get("v.item.qualification.Product_Unknown__c"));
        console.log("ProductGender",component.get("v.item.qualification.ProductGender__c"));
        console.log("ProductCategory", component.get("v.item.qualification.ProductCategory__c"));
        
        // var defaultProductDescription = {value: 'Digital Collectibles', label:'Digital Collectibles'};
        // component.set("v.defaultProductDescription" ,defaultProductDescription);
    },

    onRemoveSelectedItem : function(component, event, helper) {
        //const itemId = event.getSource().get('v.name');
        helper.removeSelectedItem(component, null);
    },
   /* onRemoveSelectedItem2 : function(component, event, helper) {
        var selectedItem = event.currentTarget; // Get the target object
        var itemId = selectedItem.dataset.index; // Get its value i.e. the index
        helper.removeSelectedItem(component, itemId);
    },*/

    redirectTab : function (component, event) {
        var selectedItem = event.currentTarget; // Get the target object
        var caseID = selectedItem.dataset.index; // Get its value i.e. the index
        console.log("caseID", caseID);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(responseConsole) {

            // open sub-tab in the Console app
            if (responseConsole) {
                workspaceAPI.getFocusedTabInfo().then(function(response) {

                    var focusedTabId = response.tabId;
                    if (response.isSubtab) {
                        focusedTabId = response.parentTabId;
                    }

                    workspaceAPI.openSubtab({
                        parentTabId : focusedTabId,
                        recordId : caseID,
                        //url : '/lightning/r/Case/' + caseID + '/view',
                        focus: true                    
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            } else {
                // if not in a Console app
                var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                    "recordId" : caseID,
                    "isredirect" : "true"
                });
                urlEvent.fire();
            }
            
        })
        .catch(function(error) {
            console.log(error);
        });

    },

    onRequestChecked : function(component, event, helper) {
        /*var createRequest = component.get("v.item").qualification.CreateRequest__c;
        var cmpTarget = component.find('moreInfo');
        //console.log("component.get(v.createRequest)", component.get("v.createRequest"));
        if (createRequest  == true) {
            //$A.util.toggleClass(cmpTarget, '');
            $A.util.removeClass(cmpTarget, 'slds-hide');
        } else {
            $A.util.addClass(cmpTarget, 'slds-hide');
        }*/
    }
})