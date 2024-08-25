({
	getStoreList : function(cmp, event, helper) {
        var action = cmp.get('c.getOpenStores');
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (state === 'SUCCESS') {
               cmp.set('v.storeList', result.getReturnValue());
                this.handleStoreChanged(cmp);
        	}
            else if (state === 'ERROR') {
                console.log(result);
            }
            else {
                console.error('Unknown error');
            }
        });
        $A.enqueueAction(action);
	},

    handleStoreChanged : function (cmp) {
        var recordLookupId = cmp.get('v.RecordLookUpId');
        if (!$A.util.isEmpty(recordLookupId)) {
            var storeList = cmp.get('v.storeList');
            console.log("recordLookupId", recordLookupId);
            for (var i = 0; i < storeList.length; i++) {
                if (storeList[i].Id == recordLookupId) {
                    cmp.set('v.retailStoreId', storeList[i].RetailStoreId__c);
                    //cmp.set("v.userReadOnly", false);
                    console.log('enter on the', cmp.get('v.retailStoreId'));
                    break;
                }
            }
        }
        else {
            console.log("empty retailStoreId");
            cmp.set('v.retailStoreId', null);
            cmp.set("v.UserId", null);
            //cmp.set("v.userReadOnly", true);
        }

    }
})