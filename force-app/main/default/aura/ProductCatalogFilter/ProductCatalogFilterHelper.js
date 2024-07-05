({  
    filterChange: function(cmp, event, helper) {

        //event.stopImmediatePropagation();

       var event1 = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
        event1.setParams({
        	'product': null, 
            'productsStock': '',
        });
        event1.fire();
        
    	var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
        //if(cmp.get('v.searchKey').length > 1) {
            myEvent.setParams({'searchKey': cmp.get('v.searchKey'), 'advencedSearch': false});
            var timer = cmp.get("v.timer");
            clearTimeout(timer);
            timer = setTimeout(function () {
                if(cmp.get('v.searchKey').length > 1 || cmp.get('v.searchKey').length == 0) {
                    cmp.set('v.advenced', false);
                    myEvent.fire();
                }
                cmp.set('v.timer', null);
            }, 500);
            cmp.set("v.timer", timer);
       // }
    },
    
    searching: function(cmp,event,helper) {
        cmp.set('v.searching',event.getParam('searching'));
    },
    
    newSearchKey: function(cmp,event,helper) {
        if(cmp.get('v.searchKey') != event.getParam('searchKey')) {
            cmp.set('v.searchKey', event.getParam('searchKey'));
        }
    },
    
    toggleStoreFilterExpanded: function(cmp,event, helper) {
        cmp.set('v.isStoreFilterExpanding', true);
    	var isExpanded = cmp.get('v.isStoreFilterExpanded');
        cmp.set('v.isStoreFilterExpanded', !isExpanded);

        var action = cmp.get('c.updateStoreHierarchyState');
        action.setParams({
            state: !isExpanded,
        });
        action.setCallback(this, function(result) { 
            
        });
        $A.enqueueAction(action);

        // reset classes after transition
        setTimeout(function () {
            cmp.set('v.isStoreFilterExpanding', false);
        }, 300);
    },
    
    getStoreState: function(cmp, event, helper) {
        var action = cmp.get('c.getStoreHierarchyState');
        action.setParams({
        });
        action.setCallback(this, function(result) { 
            var state = result.getState();
            if(state === 'SUCCESS'){
                var resultSettings = result.getReturnValue();
                cmp.set('v.isStoreFilterExpanded', resultSettings.isOpen__c);
            }
            else if(state === 'ERROR'){
                helper.handleError(result);
            } 
            else {
                console.error('Unknown error');
            }
        });
        $A.enqueueAction(action);      
    },
    
    handleError: function(response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.error("Error message: " + errors[0].message);
            }
        }
        else {
            console.error("Unknown error");
        }
    },
        
})