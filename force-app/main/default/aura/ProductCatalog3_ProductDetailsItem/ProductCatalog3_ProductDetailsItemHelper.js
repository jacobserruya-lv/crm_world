({
    helperMethod : function() {

    },
    toggleHelper : function(component,event) {
        var toggleText = component.find("tooltip");
        $A.util.toggleClass(toggleText, "toggle");
    },

    manageFavorites: function(cmp,event,helper) {
        var product = cmp.get('v.product');
        var action = cmp.get('c.updateFavorites');
        action.setParams({
            'Sku': product.sku
        });
        action.setCallback(this, function (result) {
            var state = result.getState();

            if (state === 'SUCCESS') {
                cmp.set('v.myFavorites', result.getReturnValue());
                helper.isInFavorites(cmp,event,helper);
                
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

    isInFavorites: function(cmp,event,helper) {
        var myFavorites = cmp.get('v.myFavorites');
        var product = cmp.get('v.product');
        if(myFavorites.includes(product.sku)){
            cmp.set('v.favorite', true);
        }
        else
        {
            cmp.set('v.favorite', false);
        }
    },

})