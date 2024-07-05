({
    getFavProducts : function(cmp, event, helper) {
        var favorites = cmp.get('v.myFavorites');
        if(favorites.length > 0){
            var action = cmp.get('c.getFavoriteProducts');
            action.setParams({
                'Favorites': favorites.join(','),
            });

            action.setCallback(this, function (result) {
                var state = result.getState();
                if (state === 'SUCCESS') {
                    var pageResult = result.getReturnValue();
                    //console.log('myFavoritesProducts', pageResult.products);
                    cmp.set('v.myFavoritesProducts', pageResult.products);
                }
                else if (state === 'ERROR') {
                    helper.hanldeError(result);
                }
                else {
                    console.error('Unknown error');
                }
            });
            $A.enqueueAction(action);
        }
        else{
            cmp.set('v.myFavoritesProducts', []);
        }
    },

    hanldeError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    },
})