({
	previousPage : function() {
        var myEvent = $A.get("e.c:SO_ClientSearchResultPageChangeEvent");
        myEvent.setParams({ "direction": "previous"});
        myEvent.fire();
	},
	nextPage : function() {
        var myEvent = $A.get("e.c:SO_ClientSearchResultPageChangeEvent");
        myEvent.setParams({ "direction": "next"});
        myEvent.fire();
	}
})