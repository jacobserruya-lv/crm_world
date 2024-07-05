({
	previousPage : function() {
        var myEvent = $A.get("e.c:ProductPageChange");
        myEvent.setParams({ "direction": "previous"});
        myEvent.fire();
	},
	nextPage : function() {
        var myEvent = $A.get("e.c:ProductPageChange");
        myEvent.setParams({ "direction": "next"});
        myEvent.fire();
	}
})