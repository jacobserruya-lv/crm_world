({
    doInit: function(cmp,event,helper) {
        helper.getStoreState(cmp,event,helper);
    },
    
    filterChange: function(cmp, event, helper) {
        helper.filterChange(cmp, event, helper);
    },
    
    searching: function(cmp,event,helper) {
		helper.searching(cmp,event,helper);   
	},
    
    newSearchKey: function(cmp,event,helper) {
        helper.newSearchKey(cmp,event,helper);
	},

    toggleStoreFilterExpanded: function(cmp,event,helper) {
        helper.toggleStoreFilterExpanded(cmp, event, helper);
    },

    checkAdvenced: function(cmp, event, helper) {
        
        var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
        myEvent.setParams({'searchKey': cmp.get('v.searchKey'), 'advencedSearch': cmp.get('v.advenced')});
        myEvent.fire();
    },


})