({
	onInit : function(component, event, helper) {
		helper.getStoreList(component, event, helper);
	},
    
    handleRecordLookUpIdChange : function(cmp, event, helper) {

        //var storeList=cmp.get('v.storeList');
        helper.handleStoreChanged(cmp);
        /*var recordLookupId = cmp.get('v.RecordLookUpId');
        console.log(JSON.stringify(event.getParams()));
        
        if (!$A.util.isEmpty(recordLookupId)) {
            console.log("recordLookupId", recordLookupId);
            for (var i = 0; i < storeList.length; i++) {
                if (storeList[i].Id == recordLookupId) {
                    cmp.set('v.retailStoreId', storeList[i].RetailStoreId__c);
                    console.log('enter on the', cmp.get('v.retailStoreId'));
                    break;
                }
            }
        }
        else {
            console.log("empty retailStoreId");
            cmp.set('v.retailStoreId', null);
            cmp.set("v.UserId", null);
        }*/
        
  	}
})