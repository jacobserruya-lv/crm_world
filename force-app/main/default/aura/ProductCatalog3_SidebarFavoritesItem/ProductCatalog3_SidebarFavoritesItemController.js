({
    favorite: function(cmp, event, helper) {
	    //console.log('in favorite');
	    event.stopPropagation();
	    helper.manageFavorites(cmp, event,helper);
	},
	
	openFavorite:function(cmp,event,helper) {
		var favorite = cmp.get('v.favorite');
		var myEvent = $A.get('e.c:ProductCatalog3_productClickEvent');
        myEvent.setParams({ 'product': favorite, 'fromWhere': 'favorite'});
        myEvent.fire();

	}
})