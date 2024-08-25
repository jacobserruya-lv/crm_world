({
    doInit : function(component, event, helper) {
        // console.log('doInit', component.get("v.recordId"));
        // console.log('component.get(v.sObjectName)', component.get("v.sObjectName"));
        // if (component.get("v.sObjectName") === 'Case') {
        //     helper.getAccount(component, event);
        // } else {
        //     //var recId = component.get("v.recordId");
        //     //component.set("v.accountId", recId);
        // }
        helper.getUserInfo(component, event);

        var objName = component.get("v.sObjectName");
        var width = component.get("v.width");
        debugger;
        
        if (objName == "Task" && width == 'SMALL') {
            component.set("v.widthXSmall", true);
        }
        helper.identityUser(component, event, helper) ;
        helper.countriesExcluded(component, event, helper) ;   
        helper.getIndicators(component,event);
       
    },
    
    onRecordChange : function(component, event) {
    
        component.find('recordDataAccount').reloadRecord(true);
    },
    
    goToAccount : function(component) {
        var accountId = component.get("v.recordId");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": accountId
        });
        navEvt.fire();
    },
    
    goToMaps : function(component) {
        var address = component.get("v.simpleAccount.PrimaryAddressCompacted__pc");
        
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "https://www.google.com/maps/?q=" + address
        });
        navEvt.fire();
    },
    
    goToStore : function(component) {
        var storeid = component.get("v.simpleAccount.Store__pc");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": storeid
        });
        navEvt.fire();
    },

    goToUser : function(component) {
        var ownerId = component.get("v.simpleAccount.OwnerId");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": ownerId
        });
        navEvt.fire();
    },

    /*fireEvent : function(component, event) {
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "mode" : "EDIT"
        });
        cmpEvent.fire();
    },*/

	editCase: function(component, event, helper){
		helper.editAccount(component, event);
	},

    afterScriptsLoaded: function(component, event, helper) {
        var clipboard = new Clipboard('.highlight__copy-details-btn', {
            target: function(trigger) {
                var id = component.get("v.recordId");
                return document.getElementById(id + '_details');
            }
        });

        clipboard.on('success', function(e) {
            e.trigger.textContent = 'Details Copied!';
            e.clearSelection();
        });
        clipboard.on('error', function(e) {
            e.trigger.textContent = 'Error Copying!';
        });
    },
    handleRecordUpdated: function(component, event, helper) {
        console.log('in the update record testtttt');
        var eventParams = event.getParams();
        if(eventParams.changeType === "ERROR") {
            console.log("Error in record action.", component.get('v.accountError'));
            component.set("v.displayAction", false);

        } else {
            var action = component.get("c.getPicklistOptions");
            var account = component.get("v.simpleAccount");
            console.log('action:');
            console.log(action);
            console.log('simpleaccount in update:');
            console.log(account);
            action.setParams({account: account});
            action.setStorable();
            
            //console.log("recordUpdated simlpeAccount.salutation",account.Salutation);
            
            action.setCallback(this, function (result) {

                if (result.getState() === "SUCCESS") {
                    var picklistOptions = result.getReturnValue();
                    component.set("v.picklistOptions", picklistOptions);
                    console.log("picklistOptions:");
                    console.log(picklistOptions);
                    // load null (on account changed with empty salutation, the salutation should then be updated)
                    component.set("v.salutationLabel", null);
                    if (picklistOptions && picklistOptions.Salutation && account) {
                        for (var i = 0; i < picklistOptions.Salutation.length; i++) {
                            if (picklistOptions.Salutation[i]['value'] === account.Salutation) {
                                component.set("v.salutationLabel", picklistOptions.Salutation[i]['label']);
                                break;
                            }
                        }
                    }
                   helper.displayRMSButton(component, event, helper);
                   helper.getIndicators(component,event);
                }
            });
            $A.enqueueAction(action);

           // console.log("Record is " + eventParams.changeType.toLowerCase() + " successfully.", component.get("v.salutationLabel"));
        }
    },

    handleMenuSelect : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue === 'Edit') {
            helper.editAccount(component, event);
        } else if (selectedMenuItemValue === 'Replace') {
            helper.searchAccount(component, event);
        }
    },

    searchAccount : function(component, event, helper) {
        helper.searchAccount(component, event);
    },
    
    handleApplicationEvent : function(component, event, helper) {
        var message = event.getParam("exculsiveSalesName");
        var record = event.getParam("recordId");
        if(record === component.get("v.recordId")){
          component.set("v.exclusiveSales",true);
          component.set("v.exculsiveSalesMessage",message);
        }

    },
    
    sendClientToRMSConso: function(component, event, helper) {
        
        var simpleAccount = component.get("v.simpleAccount");
        if( simpleAccount!= null && simpleAccount.Status_RMSID__c == 'Failed'){
           var errorRMS = simpleAccount.Error_RMSID__c;
           var error = (errorRMS != null  ? errorRMS.substr(errorRMS.indexOf(">>"),errorRMS.length): '');
           
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": 'Warning',
                "message": 'Please contact Contact IS with the indicated error '+ error,
                "type": 'Warning'
            });  
            toastEvent.fire(); 
           // component.set("v.simpleAccount.Status_RMSID__c",'');
            return;
        }
        
        helper.sendToRMS(component, event);
    },
    handleOpenCasesMouseEnter : function(component, event, helper) {
        component.set('v.showPopup',"true");
        component.set('v.showPopupName',event.currentTarget.dataset.value);

    },
    handleOpenCasesMouseLeave : function(component, event, helper) {
        
        component.set('v.showPopup',"false");
        component.set('v.showPopupName'," ");

    }
    
    
})