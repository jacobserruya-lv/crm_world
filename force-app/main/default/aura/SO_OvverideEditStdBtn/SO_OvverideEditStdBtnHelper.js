({
    getOpportunity: function(component) {
        
            var action = component.get("c.findOppById");
            action.setParams({
                "oppId": component.get("v.recordId")
            });
            action.setCallback(this, function(a) {
                var result = a.getReturnValue();
                component.set("v.opp", result);
                console.log("v.opp", result);
                this.navigateToRecord(result.Id);
                /*   if(v.isOpen === true){
                    this.navigateToRecord(result.Id);
                }else{
                    this.editOpp(result.Id);
                }*/
              
                             
            });
            $A.enqueueAction(action);
        }, 
    
        getUser : function(component) {
        var action = component.get("c.getUserProfile");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("$$$ user -> ", JSON.stringify(result));
                component.set("v.currentUsr", result);
                console.log("$$$ user -> ", JSON.stringify(component.get("v.currentUsr")));
                console.log("result",result.Profile.Name);
                
                if(result.Profile.Name != null){
                     if(result.Profile.Name === "System Administrator"){
                    	this.navigateToEditOpp(component.get("v.recordId"));
               		 }else{
                    	console.log("Le profil n'est pas system admin");
                	 }
                    
                }else{
                    console.log("User has no profile");
                }
                    
               
            }
        });         

        // optionally set storable, abortable, background flag here
        action.setStorable();
        $A.enqueueAction(action);        
    },
                           
    
    navigateToRecord : function (oppId){
        console.log("oppIdto navigate", oppId);
        var urlEvent = $A.get("e.force:navigateToURL");
        if (urlEvent){
            urlEvent.setParams({
                "url": "/" +oppId
            });
            urlEvent.fire();
        } else {
            console.log("nope");
            //deprecated by [Summer 18] but clean solution no work also
            //window.location.href="/one/one.app#/alohaRedirect/" + oppId;
            //[Summer 18 workaround]
            window.location.href="/lightning/r/Opportunity/"+oppId+"/view";
        }
    },
    
      navigateToEditOpp : function(oppId) {
              var urlEvent = $A.get("e.force:navigateToURL");
        if (urlEvent){
            urlEvent.setParams({
                "url": "/" +oppId+ "/e?nooverride=1"
            });
            urlEvent.fire();
        } else {
            console.log("nope");
            //deprecated by [Summer 18] but clean solution no work also
            //window.location.href="/one/one.app#/alohaRedirect/" + oppId;
            //[Summer 18 workaround]
            window.location.href="/lightning/r/Opportunity/"+oppId+"/view";
        }
	}
    
  
    
    
    
    
    
    
})