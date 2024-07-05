({
	loadComments : function(component) {
		var action = component.get("c.getCareServiceFromId");
        var type = component.get("v.CommentsType");
        var json;
        var obj = [];
        
        action.setParams({
            'sID' :component.get("v.recordId")
        });
    
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                
                var item = a.getReturnValue();
                if(type == "Follow Up") {
                    if(item.Followup_Comments__c == undefined){
                        json = '[]';
                        component.set("v.commentsError", true);
                    } else {
                    	json = item.Followup_Comments__c;
                    }
                } else {
                    if(json = item.ICON_Comments__c== undefined){
                        json = '[]';
                        component.set("v.commentsError", true);
                    } else {
                        json = item.ICON_Comments__c;
                    }
                }
                  
                try {
                    obj = JSON.parse(json);
                } catch(e) {
                    console.log('error is',e);
                    component.set("v.commentsError", true); 
                }                
                console.log('json before parse is ',json);                         
                console.log('json parsed is ',obj);            
                component.set("v.comments", obj); 
            }
        });
    
        $A.enqueueAction(action);
	}
    
})