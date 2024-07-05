({
    getContentFile : function(cmp) {
	   var action = cmp.get("c.getFileContent");
       action.setParams({
           "recordId" : cmp.get("v.recordId")
       });
       
       action.setCallback(this, function(response) {
           var state = response.getState();
           var response = response.getReturnValue();
           
           if(state === "SUCCESS"){
               cmp.set("v.fileContent", response);
           }
       });
       $A.enqueueAction(action); 
	}
})