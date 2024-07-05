({
    getNewProducts : function(cmp, event, helper) {

        var action;
        if(cmp.get('v.title') == 'Recently Published') {
            action = cmp.get('c.getRecentlyPublished');
        }else if(cmp.get('v.title') == 'Favorites') {
            if(event.getParam('src') != 'displayFavorites'){
                action = cmp.get('c.getFavoriteProducts');
                action.setParams({
                    Favorites: event.getParam('myFavorites'),
                });
            }
        }
        if(action) {
            helper.showSpinner(cmp);
            action.setCallback(this, function (result) {
                var state = result.getState();
                helper.hideSpinner(cmp);
                if (state === 'SUCCESS') {
                    var pageResult = result.getReturnValue();
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
        }
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

    clearFavorites: function(cmp, event, helper){
        var action = cmp.get('c.clearMyFavorites');
        action.setCallback(this, function (result) {
            var state = result.getState();
            helper.hideSpinner(cmp);
            if (state === 'SUCCESS') {
                cmp.set('v.newProducts', []);
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

    removeFavorite: function(cmp,event,helper){
        var productSku = event.getParam('productToRemove');
        var favoritesList = cmp.get('v.newProducts');
        var slideIndex = cmp.get('v.slideIndex');
        var newPage;
        for(var i = 0; i < favoritesList.length; i++){
            if (favoritesList[i].sku == productSku){
                console.log('my item is index: ', i);
                console.log('my slide is: ', slideIndex);
                console.log('slideIndex/6', slideIndex/6);
                console.log('favoritesList.length', favoritesList.length);
                
                
                favoritesList.splice(i,1);
                console.log('favoritesList.length', favoritesList.length);
                console.log('i/6', i/6);
                console.log('i',i);
                if(i == favoritesList.length && i/6 == 1 ){
                    newPage =  i - cmp.get('v.slideItemCount');
                    console.log('newPage', newPage);
                }
                break;
            }
        }
        cmp.set('v.newProducts',favoritesList);
        var action = cmp.get('c.updateFavorites');
        action.setParams({
            Sku: productSku
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            helper.hideSpinner(cmp);
            if(state === 'SUCCESS') {
                if(newPage != null){
                    cmp.set('v.slideIndex',newPage);
                }
                var myEvent = $A.get('e.c:ProductCatalogUpdateFavoriteListEvent');                
                myEvent.setParams({
                    'myFavorites': result.getReturnValue().join(','),
                    'src': 'displayFavorites'
                });
                myEvent.fire();
                
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

    
})