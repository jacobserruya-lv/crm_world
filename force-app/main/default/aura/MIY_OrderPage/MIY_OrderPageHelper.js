({
    getOrderData: function (component) {
        // console.group(component.getType() + '.h.getOrderData');

        var action = component.get('c.getOrder');
        var orderId = component.get('v.recordId');
        action.setParams({orderId: orderId});
        action.setStorable({ignoreExisting: true});
        action.setCallback(this, function (response) {
            console.group(component.getType() + '.c.getOrder', orderId);

            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log(response.getReturnValue());
                component.set('v.record', response.getReturnValue());
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error('Error message: ' + errors[0].message);
                    }
                } else {
                    console.error('Unknown error');
                }
            }
            console.groupEnd();
        });
        $A.enqueueAction(action);

        // console.groupEnd();
    },
    getProductSettings: function(component) { //MIY-1969
        var action = component.get('c.getProductSettings');
        action.setCallback(this, function(result) {component.set('v.productSettings', result.getReturnValue());});
        action.setStorable();
        $A.enqueueAction(action);
    },
    getLatestOrder: function (component, event, helper) {
        // console.group(component.getType() + '.h.getLatestOrder');

        var action = component.get('c.getLatestOrder');
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.getLatestOrder');

            var state = response.getState();
            if (state === 'SUCCESS') {
                var latestOrder = response.getReturnValue();
                // console.log(latestOrder);
                component.set('v.record', latestOrder);
                component.set('v.recordId', latestOrder.Id);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error('Error message: ' + errors[0].message);
                    }
                } else {
                    console.error('Unknown error');
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);

        // console.groupEnd();
    },

    getMIYSettingsForWarnings: function(component) {
        var action = component.get('c.getMiySettingsForWarnings');
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.' + action.getName(), action.getParams());

            var state = response.getState();
            if (state === 'SUCCESS') {
                var warningsMap = response.getReturnValue();
                // console.log(warningsMap);
                component.set('v.warningsMap', warningsMap);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error('Error message: ' + errors[0].message);
                    }
                } else {
                    console.error('Unknown error');
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
    },
    getStoreMode: function (component) {
        var action = component.get('c.getUserProfileName');
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.h.getUserProfileName');

            var state = response.getState();
            if (state === 'SUCCESS') {
                var profileName = response.getReturnValue();
                // console.log(profileName);
                if (profileName === 'SPO_Production') {
                    component.set('v.storeMode', false);
                } else {
                    component.set('v.storeMode', true);
                }
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error($A.get('$Label.c.MIY_OrderPage_Error').replace('{0}', errors[0].message));
                    }
                } else {
                    console.error($A.get('$Label.c.MIY_OrderPage_Unknown_Error'));
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);
    },
    getUserProfile: function(component) {
        var action = component.get('c.getUserProfileName');
        action.setStorable();
        action.setCallback(this, function (response) {
            // console.groupCollapsed(component.getType() + '.c.getUserProfileName');

            var state = response.getState();
            if (state === 'SUCCESS') {
                var profileName = response.getReturnValue();
                // console.log(profileName);
                component.set('v.userProfile', profileName);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error($A.get('$Label.c.MIY_OrderPage_Error').replace('{0}', errors[0].message));
                    }
                } else {
                    console.error($A.get('$Label.c.MIY_OrderPage_Unknown_Error'));
                }
            }
            // console.groupEnd();
        });
        $A.enqueueAction(action);

    },
    apexActionPromise: function (component, actionName, params, ignoreExisting, isDebug) {
        return new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get(actionName);
            action.setParams(params);
            if (!ignoreExisting) {
                action.setStorable({ignoreExisting: ignoreExisting});
            }
            action.setCallback(this, function (response) {
                if (isDebug) {
                    console.groupCollapsed(component.getType() + '.c.' + action.getName(), Object.assign({}, action.getParams()));
                }
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var returnValue = response.getReturnValue();
                    if (isDebug) {
                        console.log(returnValue);
                    }
                    resolve(returnValue);
                }
                else if (state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            $A.reportError('Error message:', errors[0].message);
                            reject(new Error(errors[0].message));
                        }
                    } else {
                        $A.reportError('Unknown error');
                        reject(new Error('Unknown error'));
                    }
                }
                if (isDebug) {
                    console.groupEnd();
                }
            });
            $A.enqueueAction(action);
        }));
    },
    getQuickActions: function (component) {
        console.group(component.getType() + '.h.getQuickActions');
        var actionAPI = component.find("quickActionAPI");
        console.log(actionAPI);
        actionAPI.getAvailableActions().then(function(result){
            console.log('result:',result);
        }).catch(function(e){
            console.log(e);
            if(e.errors){
                console.error(e.errors);
            }
        });
        console.groupEnd();
    },
    checkPermissionSetGroup: function (component) { // MIY-2224
        var action = component.get("c.isUserInPermissionSetGroup");
        action.setParams({ permissionSetGroupName: 'NY Squad' });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isUserInPermissionSetGroup = response.getReturnValue();
                component.set("v.isUserInPermissionSetGroup", isUserInPermissionSetGroup);

                if (isUserInPermissionSetGroup) {
                    console.log("User has the permission set");
                } else {
                    console.log("User does not have the permission set");
                }
            }
            else {
                console.log("Error in getting permission set information");
            }
        });
        $A.enqueueAction(action);
    }

});