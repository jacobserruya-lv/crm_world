({
    manageFavorites: function(cmp,event,helper) {
        var favorite = cmp.get('v.favorite');
        var action = cmp.get('c.updateFavorites');
        action.setParams({
            'Sku': favorite.sku
        });
        action.setCallback(this, function (result) {
            var state = result.getState();

            if (state === 'SUCCESS') {
                cmp.set('v.myFavorites', result.getReturnValue());
                var myEvent = $A.get('e.c:ProductCatalogUpdateFavoriteListEvent');
                myEvent.setParams({
                    'myFavorites': result.getReturnValue().join(','),
                    'src': 'listItem'
                });
                myEvent.fire();
            }
            else if (state === 'ERROR') {
                helper.handleError(result);
            }
            else {
                console.error('Unknown error');
            }
        });
        $A.enqueueAction(action);

    },

    handleError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    },

})