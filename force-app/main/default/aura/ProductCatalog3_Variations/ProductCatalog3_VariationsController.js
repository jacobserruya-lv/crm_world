({
	changeProductDataName: function (cmp, event, helper) {
		var hoverName = event.getParam('hoverName');
		cmp.set('v.hoverName', hoverName);
	}
})