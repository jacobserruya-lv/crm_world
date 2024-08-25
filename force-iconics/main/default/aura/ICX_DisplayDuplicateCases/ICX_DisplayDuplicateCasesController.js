({
	OnInit: function (cmp, event, helper) {
        helper.validate(cmp, event);
	},
    handleKeyUp: function (cmp, event,helper) {
        var queryTerm = cmp.find('enter-search').get('v.value');
        cmp.set('v.shippingGroup', queryTerm);
    },
    IsChecked: function (cmp, event,helper) {
        var queryTerm = cmp.find('IsCheck').get('v.checked');
        cmp.set('v.continue', queryTerm);
    }
 

})