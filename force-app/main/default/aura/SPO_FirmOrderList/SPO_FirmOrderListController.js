({
    getFirmOrders : function(component, event, helper) {
	console.log('getFirmOrders');
		helper.getUser(component, event);
        helper.getFirmOrderList(component, event);
        helper.getSORList(component, event);
    },

    updateFirmOrders:function(component,event,helper){
    	helper.updateFirmOrders(component,event);
    },
    cancelAllFirmOrder:function(component,event,helper){
    	console.log("+++cancelAllFirmOrder");
    	//var attribute1 = component.get('v.firmOrderList');
    	helper.cancelAllFirmOrders(component,event);

    },
    openModalCloseOpp : function(component,helper,event){
        //for display modal on click button Close change tracking
        component.set("v.isOpen", true);       
    
    },
    closeModalCO : function(component,helper,event){
        //for display modal on click button Close change tracking
        component.set("v.isOpen", false);
    
    },
     openModalCloseFO : function(component,helper,event){
        //for display modal on click button Close change tracking
        component.set("v.isOpen1", true);       
    
    },
    closeModalCFO : function(component,helper,event){
        //for display modal on click button Close change tracking
        component.set("v.isOpen1", false);
    
    },
   
})