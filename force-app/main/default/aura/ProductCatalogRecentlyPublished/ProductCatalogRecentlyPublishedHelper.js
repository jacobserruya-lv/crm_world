({
    getNewProducts : function(cmp, event, helper) {
        var action = cmp.get('c.getRecentlyPublished');
        helper.showSpinner(cmp);
        action.setCallback(this, function (result) {
            var state = result.getState();
            helper.hideSpinner(cmp);
            if (state === 'SUCCESS') {
                var pageResult = result.getReturnValue();
                console.log('newProducts ' ,  pageResult.products);
                cmp.set('v.newProducts', pageResult.products);
            }
            else if (state === 'ERROR') {
                helper.hanldeError(result);
            }
            else {
                console.error('Unknown error');
            }
        });
        $A.enqueueAction(action);
	},

    hanldeError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    },

    showSpinner: function (cmp) {
        cmp.set('v.toggleSpinner', true);
    },

    hideSpinner: function (cmp) {
        cmp.set('v.toggleSpinner', false);
    },
})