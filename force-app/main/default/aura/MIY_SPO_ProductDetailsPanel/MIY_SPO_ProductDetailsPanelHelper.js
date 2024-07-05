({
    getProductSettings: function(component) {
        this.apexActionPromise(component, 'c.getProductSettings')
            .then($A.getCallback(function (result) {
                component.set('v.productSettings', result);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
        },
    getMaterialAndColorOptions: function (component) {
        // console.group('MIY_SPO_ProductDetailsPanel.h.getMaterialAndColorOptions');
        this.apexActionPromise(component, 'c.getMaterialAndColorOptions')
            .then($A.getCallback(function (result) {
                component.set('v.materialAndColorOptions', result);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
        // console.groupEnd();
    },
    getOrderData: function (component) {
        // console.group('MIY_SPO_ProductDetailsPanel.h.getOrderData');
        var orderId = component.get('v.recordId');
        this.apexActionPromise(component,'c.getOrder',{orderId: orderId})
            .then($A.getCallback(function (result) {
                component.set('v.record', result);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
        // console.groupEnd();
    },
    getUserProfile: function(component) {
        this.apexActionPromise(component,'c.getUserProfileName')
            .then($A.getCallback(function (result) {
                component.set('v.userProfile', result);
                if (result === 'SPO_Production' ) {
                    component.set('v.storeMode', false);
                }
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
    },
    getIsApprover: function(component) {
        this.apexActionPromise(component,'c.isJapanApprover')
            .then($A.getCallback(function (result) {
                component.set('v.isApprover', result);
            }))
            .catch($A.getCallback(function (e) {
                console.error(e);
            }));
    },
    apexActionPromise: function (component, actionName, params, ignoreExisting, isDebug) {
        return new Promise($A.getCallback(function (resolve, reject) {
            if (typeof isDebug === 'undefined') {isDebug = component.get('v.isDebugMode');}
            var action = component.get(actionName);
            if (params) {
                action.setParams(params);
            }
            if (ignoreExisting) {
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

});