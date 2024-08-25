({
	
	OnInit: function (cmp, event, helper) {
        cmp.set('v.columns', [
            { label: 'Case Number', fieldName: 'url', type: 'url' ,typeAttributes: { label: { fieldName: 'CaseNumber'},  target: '_self'}, sortable: true} ,
            { label: 'Shipping Group', fieldName: 'Shipping_group__c', type: 'text'  },
            { label: 'Shipping Group (New Format)', fieldName: 'OrderShipping', type: 'text'  },
			{ label: 'Client Name', fieldName: 'AccountName', type: 'text' },
			{ label: 'Issue Category', fieldName: 'Issue_Category__c', type: 'text' },
			{ label: 'Created Date', fieldName: 'CreatedDate', type: 'date-local' ,sortable: true }
        ]);
        
       if(cmp.get('v.sObjectName') == 'Case'){
           helper.getValueCase(cmp);
       }
	},
    itemsChange: function(cmp, evt,helper) {
        helper.getData(cmp);
    }
})