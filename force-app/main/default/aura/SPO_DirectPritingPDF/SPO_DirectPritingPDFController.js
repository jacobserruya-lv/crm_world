({
	doInit:function(component,event,helper){
		helper.checkDocument(component);
	},

	directPrint:function(component, event,helper){
		helper.redirectPage(component);
	},
})