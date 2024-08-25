({
   init : function(cmp, event, helper) {
      // Figure out which buttons to display
      var availableActions = cmp.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "PAUSE") {
            cmp.set("v.canPause", true);
         } else if (availableActions[i] == "BACK") {
            cmp.set("v.canBack", true);
         } else if (availableActions[i] == "NEXT") {
            cmp.set("v.canNext", true);
         } else if (availableActions[i] == "FINISH") {
            cmp.set("v.canFinish", true);
         }
      }
       
       helper.buildCustomButtons(cmp, event);
   },
        
    onButtonPressed: function(cmp, event, helper) {

        // Figure out which action was called
        var actionClicked = event.getSource().getLocalId();
        console.log("actionClicked", actionClicked);
        cmp.set("v.buttonClicked", actionClicked);

        // Fire an event
        var appEvent = $A.get("e.c:ICX_Flow_FooterEvent");
        appEvent.setParams({
            "action" : actionClicked,
            "recordId" : cmp.get("v.recordId")
        });
        appEvent.fire();

        var validationRequired = cmp.get("v.validationRequired");
        if (!$A.util.isEmpty(validationRequired) && validationRequired == false) {
            // Fire that action
            var navigate = cmp.get('v.navigateFlow');
            navigate(actionClicked);
        }
   }
})