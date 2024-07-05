({
	doInit : function(component, event, helper) {
        
        //1. load existing  comments
         helper.loadComments(component);
        
        //2. set default values to newComment
        var d=new Date(); 
        var date = d.getFullYear()  + "-" +  ("0"+(d.getMonth()+1)).slice(-2) + "-" +("0" + d.getDate()).slice(-2);       
        component.set("v.newComment.Date",date);
        /* would have like to do: var userId = $A.get("$SObjectType.CurrentUser.Id");
        unfortunately, can only get id, not name. have to do server side call   */
        var action = component.get("c.getUserName");
    	action.setCallback(this, function(response){
        	var state = response.getState();
        	if (state === "SUCCESS") {
                //alert(response.getReturnValue());
                component.set("v.newComment.SACode",response.getReturnValue());
         	}
      	});
       	$A.enqueueAction(action);               
	},
    
    success : function(component, event, helper) {
        let button = component.find('submit');
        let inputText = component.find('commentText');
        if(inputText.get("v.value")==="") { 
            button.set('v.disabled',true)
        } else { 
            button.set('v.disabled',false)
        }
    },
    
    saveComment : function(component, event, helper) {                
            helper.saveComment(component);
	}
})