({
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
})