({
    doInit: function (component, event, helper) {
        // console.group('MIY_CancelModal.doInit');
        var profile = component.get('v.userProfile');
        var permission = component.get("v.isUserInPermissionSetGroup"); // MIY-2224
        if(profile=='MIY_admin' || profile == 'MIY_Reporting' || profile =='SPO_Production' || profile=='SPO_ExoProduction' || profile == 'SPO_Other' || profile =='System Administrator'||profile=='SPO_NomadeMgnt' || permission ){
            component.set('v.isExpirationDisplayed',false);
        }
        var action = component.get("c.getCancelReasonOptions");
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed('MIY_CancelModal.c.getCancelReasonOptions');

            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.reasonOptions', response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error($A.get('$Label.c.MIY_OrderPage_Error') + errors[0].message);
                    }
                } else {
                    console.error($A.get('$Label.c.MIY_OrderPage_Unknown_Error'));
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
        // console.groupEnd();
    },

    scriptsLoaded: function (component, event, helper) {
        // console.group('MIY_CancelModal.scriptsLoaded');
        var listData = component.get('v.listData');
        var earliestExpireDate;
        var expirationTime;
        var status;
        listData.forEach(function(item) {
            var approvalTime = (item.ProductCatalogue__r ? item.ProductCatalogue__r.LeadTimeApproval__c : 2);
            var itemExpireDate = moment(item.CreatedDate).add(approvalTime, 'd');
            
            expirationTime = (item.IsInferiorVmaxDate__c );
            status = item.SPO_FirmOrderStatus__c;
            
            
            // console.log('approvalTime, itemExpireDate, ProductCatalogue__r:', approvalTime, itemExpireDate.format(), item.ProductCatalogue__r);
            if ((earliestExpireDate == null) || itemExpireDate.isBefore(earliestExpireDate)) {
                
                earliestExpireDate = itemExpireDate;
            }
        });
        
        // console.log('earliestExpireDate:', earliestExpireDate.format());
        
        var userProfile = component.get('v.userProfile');
        var hasPermission = component.get('v.isUserInPermissionSetGroup'); // MIY-2224
        
        var intervalID = window.setInterval(
            $A.getCallback(function() {
                var fromNow = moment().diff(earliestExpireDate);
                console.log('fromNow :>> ', fromNow);
                if (fromNow >= 0) {
                    if ((userProfile == 'MIY_Admin'
                    || userProfile == 'SPO_Other'
                    || userProfile == 'SPO_ExoProduction'
                    //added for MIY-1574
                    || userProfile =='MIY_Reporting'
                    || userProfile == 'SPO_Production'
                    || userProfile=='SPO_NomadeMgnt'
                    || hasPermission // MIY-2224
                    ||
                    
                    ( 
                        ( (new RegExp('ICON_')).test(userProfile) || (new RegExp('ICONiCS_')).test(userProfile) ) 
                        && 
                        (expirationTime == true ) 
                        &&
                        (status == 'Creation in progress')
                        )    
                        ) // MIY-1539: Allow cancellation for these profiles
                        ) {
                            
                            component.set('v.expired', false);
                        } else {
                            component.set('v.expired', true);
                        }
                    window.clearInterval(intervalID);
                } else {
                    var fromNowDuration = moment.duration(fromNow);
                    component.set('v.remainingTimeText', fromNowDuration.humanize());
                }
            }), 1000
        );
        // console.groupEnd();
    },

    handleBack: function (component, event, helper) {
        component.set('v.success', false);
        component.find("cancelModalOverlayLib").notifyClose();
    },

    handleApply: function (component, event, helper) {
        // console.group('MIY_CancelModal.handleApply');
        component.set('v.applyLoading', true);
        var listData = component.get('v.listData');
        var foIds = listData.map(fo => fo.Id);
        var orderId = listData.reduce((acc, cur) => (acc.SPO_BriefName__c || cur.SPO_BriefName__c), {});
        var reason = component.get('v.reasonValue');
        var comment = component.get('v.commentValue');
        var overlayLib = component.find("cancelModalOverlayLib");
        var notifLib = component.find('cancelModalNotifLib');
        var action = component.get("c.cancelFirmOrders");
        action.setParams({
            foIds: foIds,
            orderId: orderId,
            reason: reason,
            comment: comment,
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.group('MIY_CancelModal.c.cancelFirmOrders');
            console.log(response.getReturnValue());
            
            var state = response.getState();
            console.log('state :>> ', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fos = result.fos;
                var cancelWSError = result.cancelWSError;

                if (Array.isArray(fos) && fos.length)
                console.log('fos :>> ', fos);
                {
                    fos.forEach(function(item) {
                        var updateOrderEvent = $A.get("e.c:MIY_FirmOrderUpdate");
                        updateOrderEvent.setParams({
                            'objectId': item.Id,
                            'oldData': listData.find(function(listItem) {return listItem.Id === item.Id}),
                            'newData': item,
                        });
                        updateOrderEvent.fire();
                    });
                    component.set('v.success', true);
                    component.set('v.applyLoading', false);                    
                }      
                overlayLib.notifyClose();
                

                if(cancelWSError != '')
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: "sticky",
                        title: "Cancel Web Service error",
                        message: cancelWSError,
                        type: "error"
                    });
                    toastEvent.fire();
                  
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    errors.forEach(function(err) {
                        if(err.message) {
                            notifLib.showToast({
                                "variant": "error",
                                "title": $A.get('$Label.c.MIY_OrderPage_Error'),
                                "message": errors[0].message
                            });
                            console.error($A.get('$Label.c.MIY_OrderPage_Error') + errors[0].message);
                        } else if (err.pageErrors) {
                            err.pageErrors.forEach(function(pageError) {
                                notifLib.showToast({
                                    "variant": "error",
                                    "title": pageError.statusCode,
                                    "message": pageError.message
                                });
                        console.error(pageError.statusCode + ': ' + pageError.message);
                            });
                        }
                    });
                } else {
                    notifLib.showToast({
                        "variant": "error",
                        "title": $A.get('$Label.c.MIY_OrderPage_Error'),
                        "message": $A.get('$Label.c.MIY_OrderPage_Unknown_Error')
                    });
                   

                    console.error($A.get('$Label.c.MIY_OrderPage_Unknown_Error'));
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
        // console.groupEnd();
    },
})