({
     doInit : function(component, event, helper) {
        helper.getUser(component);
       
     
       
       
    },
    
    getOpp : function (component, event, helper){
       helper.getOpportunity(component);
    },
    
    
    
	openModal : function(component,helper,event){
        //for display modal on click button Close change tracking
           component.set("v.isOpen", true);
       // helper.openModal(component, true);
        

	},
    
    closeModal : function(component,helper,event){
        //for display modal on click button Close change tracking
         component.set("v.isOpen", false);
         // helper.closeModal(component, false);
          
    
	},
    
    editOpp : function(component, event,helper){
        helper.navigateToEditOpp(component.get("v.recordId"));
    }
    
 
   
})