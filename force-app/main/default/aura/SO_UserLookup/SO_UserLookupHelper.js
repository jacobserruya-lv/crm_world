({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.SO_LookupUserDB");
      // set param to method
      if(getInputkeyWord.length > 0)  {
      	action.setParams({
            'userName': getInputkeyWord,
            'ObjName' : component.get("v.objectAPIName")
          });
      }
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log("Response from server " + JSON.stringify(returnValue));
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (returnValue.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", returnValue);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
})