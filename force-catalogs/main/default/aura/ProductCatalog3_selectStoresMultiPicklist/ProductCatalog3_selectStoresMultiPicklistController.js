({

	handleMouseLeave: function(cmp, event, helper) {
		helper.handleMouseLeave(cmp, event, helper);
	},
	   
	handleMouseEnter: function(cmp, event, helper) {
		//console.log('getting out');
	    cmp.set('v.dropdownOver',true);
	},
	
	handleClick: function(cmp, event, helper) {
		//if(cmp.get('v.localItems').length > 0) {
			cmp.set('v.dropdownOpen', !cmp.get('v.dropdownOpen'));
			if(cmp.get('v.setup') && !cmp.get('v.dropdownOpen')){
				helper.handleMouseLeave(cmp, event, helper);
			}
		//}
	},
	
	handleSelection: function(cmp, event, helper) {
		//console.log('handle selection');
		helper.handleSelection(cmp, event, helper);
	},
	
	prepareItems: function(cmp, event, helper) { 
		helper.prepareItems(cmp, helper, cmp.get('v.items'));
	},

	addToMyList: function(cmp, event,helper) {
		helper.addToMyList(cmp, event, helper);
	},

	clearListSelection: function(cmp,event,helper) {
		helper.handleSelection(cmp, event, helper, 'clear');
	},

	selectAllList: function(cmp,event,helper) {
		helper.handleSelection(cmp, event, helper, 'select all');
	}
})