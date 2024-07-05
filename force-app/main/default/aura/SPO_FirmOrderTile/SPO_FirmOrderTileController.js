({
	doInit : function(component, event, helper) {
		helper.getUser(component);
        helper.getTodayDate(component);
       
        helper.getOpp(component);
        helper.getSORList(component);        
       
	},

	updateFirmOrder:function(component,event,helper){
		helper.updateFirmOrderStatus(component);
	},
    getOpp:function(component,event,helper){
		  helper.getOpp(component);
	},
    
    updateOpp : function(component,event,helper){
        var opp = component.get("v.opp");
        console.log("$$$$$$$$$$ Info GETTER :" +opp);
        console.log("$$$$$$$$$$ Stop Order Reason :" + opp.SPO_StopBriefReason__c);
        console.log("$$$$$$$$$$ Stop order comment :" +opp.SPO_StopBriefComment__c) ;
        helper.updateOppCancelSection(component, opp.SPO_StopBriefReason__c, opp.SPO_StopBriefComment__c);
        //helper.updateFirmOrderStatus(component);
    },
    
    cancelFirmOrder:function(component,event,helper){
          console.log("+++ c.cancelFirmOrder : IN");
          helper.CancelFirmOrderJS(component);
	},    
    
  /*  cancelFirmOrder:function(component,event,helper){
		helper.cancelFirmOrderStatus(component);
	},*/
    
    openModal : function(component,helper,event){
        //for display modal on click button Close change tracking
        component.set("v.isOpen", true);       
    
	},
    closeModal : function(component,helper,event){
        //for display modal on click button Close change tracking
        component.set("v.isOpen", false);
    
	},
    
    onPicklistChange: function(component, event, helper) {
        // get the value of select option
        alert(event.getSource().get("v.value"));
    },
    handleClickToRecord: function (component, event, helper) {
        console.log("+++handleClickToRecord");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    
   
    
        
})