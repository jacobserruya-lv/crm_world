({
    doInit : function(component, event, helper) {
        /* after creating opportunity, get all data for Detail page */
        helper.findOppById(component);
        helper.setUser(component);
        
        console.log("summary > opp", component.get("v.opp"));
        console.log("summary > account", component.get("v.account"));
        console.log("summary > store", component.get("v.store"));
        console.log("summary > product", component.get("v.product"));
    },

    /*handleApplicationEvent : function(component, event) {
        console.log('summary handleApplicationEvent');
        var params = event.getParams();
        component.set("v.opp", params.opp);

        if (params.channel === "Account") {
            component.set("v.account", params.account);
            component.set("v.store", params.store);
        }
        if (params.channel === "Product") {
            component.set("v.product", params.product);
        }
        //if (params.channel === "Personalization") {
        //}
        console.log("summary > opp", component.get("v.opp"));
        console.log("summary > account", component.get("v.account"));
        console.log("summary > store", component.get("v.store"));
        console.log("summary > product", component.get("v.product"));
    },*/
    
    save : function(component, event, helper) {
        var buttonClicked = event.getSource().getLocalId();
        console.log("ButtonClicked is : " + buttonClicked);
        component.set("v.buttonClicked",buttonClicked);
        helper.save(component);
        
        /*// Fire Component (Bubbling) event to ask the SO_OpportunitySPA LC (Parent) to go back to previous child LC:        
        var cmpEvent = component.getEvent("bubblingEvent");
        cmpEvent.setParams({"componentAction" : 'Summary_Next'});
        cmpEvent.fire();*/
        
        //helper.fireOpportunitySPAEvent(component);
    },

    handleMenuSelect : function(component, event, helper){
        component.set("v.showAction", true);
        component.set("v.mode", "Edit");
        component.set("v.showMenu", false);
    },

    saveAction : function(component, event, helper) {
        console.log("saving action");
        helper.save(component);
    },

    cancelAction : function (component, event, helper){
        console.log("cancel action");
        component.set("v.showAction", false);
        component.set("v.mode", "Read");
        component.set("v.showMenu", true);

        $A.get('e.force:refreshView').fire();
    }
    
})