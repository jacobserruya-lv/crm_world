({

	handleMouseLeave: function(cmp, event, helper) {
	    helper.handleMouseLeave(cmp, event, helper);
	},
	   
	handleMouseEnter: function(cmp, event, helper) {
	    cmp.set('v.dropdownOver',true);
	},
	
	handleClick: function(cmp, event, helper) {
		if(cmp.get('v.localItems').length) {
			var mainDiv = cmp.find('multi-picklist-section');
			$A.util.toggleClass(mainDiv, 'slds-is-open');
		}
	},
	
	handleSelection: function(cmp, event, helper) {
		helper.handleSelection(cmp, event, helper);
	},
	
	prepareItems: function(cmp, event, helper) { 
		helper.prepareItems(cmp, helper, cmp.get('v.items'), cmp.get('v.listType'));
	},

	addToMyList: function(cmp, event,helper) {
		helper.addToMyList(cmp, event, helper);
	}
})