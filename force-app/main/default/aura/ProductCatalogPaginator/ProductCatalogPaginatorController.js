({
	previousPage : function() {
        var myEvent = $A.get("e.c:ProductCatalogPageChangeEvent");
        myEvent.setParams({ "direction": "previous"});
        myEvent.fire();
	},
	
	nextPage : function() {
        var myEvent = $A.get("e.c:ProductCatalogPageChangeEvent");
        myEvent.setParams({ "direction": "next"});
        myEvent.fire();
	},

    firstPage : function() {
        var myEvent = $A.get("e.c:ProductCatalogPageChangeEvent");
        myEvent.setParams({ "direction": "first"});
        myEvent.fire();
    },
    lastPage : function() {
        var myEvent = $A.get("e.c:ProductCatalogPageChangeEvent");
        myEvent.setParams({ "direction": "last"});
        myEvent.fire();
    }
	
})