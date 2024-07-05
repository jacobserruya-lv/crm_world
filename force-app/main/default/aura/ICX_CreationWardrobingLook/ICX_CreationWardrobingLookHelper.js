({
    initData: function(component, event, helper){
        //get Parameters from the server side
        var action = component.get('c.getRecords');
        action.setParams({
           RecordId : component.get("v.recordId")
    	});
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (state === 'SUCCESS') {
                var url = result.getReturnValue();
                component.set('v.mystr',url);
            }else {
                console.error('Unknown error');
            }
        });
        $A.enqueueAction(action);
   	},
    
    navigateToUrl: function(component, event, helper){
        var values = component.get("v.mystr");
   	 	var urlEvent = $A.get("e.force:navigateToURL");
    	urlEvent.setParams({
      		"url": $A.get("$Label.c.ICX_WardrobingUrl")+ values
   		 });
        console.log('URL=', $A.get("$Label.c.ICX_WardrobingUrl")+ values);
    	urlEvent.fire();
    }
})