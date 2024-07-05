({
	
    saveComment : function(component) {
        console.group(component.getType() + '.h.saveComment')
		var action = component.get("c.addICONComment");        
        var comments = component.get("v.comments");        
        var commentObject = component.get("v.newComment");
        
        console.log('comments are ',Array.from(comments));
        console.log('commentObject is ',Object.assign({},commentObject));
        comments.push(Object.assign({},commentObject));        
        console.log('after push ',Array.from(comments));
        
        try {        	
        	var json = JSON.stringify(comments);
        } catch(e) {
            alert("error in stringify");
        }
        
        var params = {
            'sID' :component.get("v.recordId"),
            'comment': json
        }
        action.setParams(params);
    
        action.setCallback(this, function(a) {
            console.group(component.getType() + '.c.addICONComment', params)

            var val = a.getReturnValue();
            console.log(val);
            console.log('state is ',a.getState());
            if (a.getState() === "SUCCESS") {  
                component.set("v.comments", comments);
                component.set("v.newComment.Comment", '');
                //alert(component.get("v.commentsError"));
                if(component.get("v.commentsError") == true){
                	component.set("v.commentsError", false);
                }
            } else {
               console.error('no success');
            }
            console.groupEnd();
        });
    
        $A.enqueueAction(action);
        console.groupEnd();
	}
    
})