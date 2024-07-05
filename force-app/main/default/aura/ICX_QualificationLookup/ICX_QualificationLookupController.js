({
    doInit: function(component, event, helper) {
        console.log("doInit > level fields INIT", component.get("v.level1Field"), component.get("v.level2Field"), component.get("v.level3Field"));
        helper.setupField(component, event);

        console.log("component.get(v.recordTypeId)", component.get("v.recordTypeId"));
        if (!$A.util.isEmpty(component.get("v.recordTypeId"))) {
            //var sObject = component.get("v.object"); 
            //component.set("v.objectWebService", sObject);
            helper.getPicklist(component);
            //helper.getNatureandcategory(component,event, helper);
            console.log(component.get("v.recordId"));

        } else if (!$A.util.isEmpty(component.get("v.recordId"))) {
            helper.getRecordInfo(component, event);
        }
        console.log(component.get("v.recordId"));
        
       /* console.log("doInit > level values", component.get("v.level1Value"), component.get("v.level2Value"), component.get("v.level3Value"));
        // when BACK button, display the selection list
        if (!$A.util.isEmpty(component.get("v.level3Value"))) {
            component.set("v.showDomainList", true);
            component.set("v.showNatureList", false);
        } else if (!$A.util.isEmpty(component.get("v.level2Value"))) {
            component.set("v.showCategoryList", true);
            component.set("v.showNatureList", false);
        } else if (!$A.util.isEmpty(component.get("v.level1Value"))) {
            component.set("v.showNatureList", true);
        }*/
    },
    
    doneRendering: function(cmp, event, helper) {
     
        if(!cmp.get("v.isDoneRendering")){
            cmp.set("v.isDoneRendering", true);
            
            if(cmp.get("v.accountId") != null)
            {
                console.log('Publish on Account Selected Channel' + cmp.get("v.accountId"));
                var payload = { recordId: cmp.get("v.accountId"), currentRecordId: cmp.get("v.recordId")};
                cmp.find("ICX_AccountSelected").publish(payload);
            }
        }
    },
    
    onLastLevelNoResult : function(component, event, helper) {
        if (component.get("v.lastLevelNoResult") == true) {//} && component.get("v.isManualSelection") == true) {
            console.log("onlastlevel no result > go next");
            helper.goFlowNext(component, event);
        }
    },

    handleSelection : function(component, event, helper) {          
        // var value = event.getParam("value");
        // var field = event.getParam("field");
        var level = event.getParam("level");
        var action = event.getParam("action");
        
        var currentLevel = component.get("v.levelCurrent");
        // console.log("currentLevel", currentLevel);
        //console.log("level", level);
        //console.log("action", action);
        if (currentLevel != level) {
            if (level == 1) {
                //helper.level1Changed(component, event);
                if (action === 'Change') {
                    component.set("v.showNatureList", true);
                    component.set("v.showCategoryList", false);
                    component.set("v.showDomainList", false);
                } else {
                    component.set("v.showNatureList", false);            
                    component.set("v.showCategoryList", true);            
                    component.set("v.showDomainList", false);
                    
                    component.set("v.level2Value", null);
                    component.set("v.level3Value", null);
                }
            } else if (level == 2) {
                if (action === 'Change') {
                    component.set("v.showNatureList", false);
                    component.set("v.showCategoryList", true);
                    component.set("v.showDomainList", false);                    
                } else {
                    //helper.level2Changed(component, event);
                    component.set("v.showNatureList", false);            
                    component.set("v.showCategoryList", false);            
                    component.set("v.showDomainList", true); 
                    
                    component.set("v.level3Value", null);
                }
                
            } else if (level == 3) {
                if (action === 'Change') {
                    component.set("v.showNatureList", false);
                    component.set("v.showCategoryList", false);
                    component.set("v.showDomainList", true);                    
                } else {
                    //helper.level3Changed(component, event);
                    component.set("v.showDomainList", false);            
                }
            }
            component.set("v.levelCurrent", level);

            // on last selection, auto-next
            //console.log("lastLevelNoResult",component.get("v.lastLevelNoResult"));
            if (action === 'Select' && component.get("v.levelLast") == level) {
                console.log("select level");
                helper.goFlowNext(component, event);
            }
        } else {
            if (level == 1) {
                if (action === 'Change') {
                    component.set("v.showNatureList", true);
                    component.set("v.showCategoryList", false);
                    component.set("v.showDomainList", false);
                } else {
                    helper.level1Changed(component, event);
                }
            } else if (level == 2) {
                if (action === 'Change') {
                    component.set("v.showCategoryList", true);
                    component.set("v.showDomainList", false);
                } else {
                    helper.level2Changed(component, event);
                }
            } else if (level == 3) {
                if (action === 'Change') {
                    component.set("v.showDomainList", true);
                } else {
                    helper.level3Changed(component, event);                    
                }
            }

            if (action === 'Select' && component.get("v.levelLast") == level) {
                console.log("select last level");
                helper.goFlowNext(component, event);
            }
        }
        
        // Avoid loop screen: from the next screen then BACK button then automatically next screen
        //component.set("v.isManualSelection", true);
    },

    handleFastSelection : function(component, event, helper) {

        var level1 = event.getParam("level1");
        var level2 = event.getParam("level2");
        var level3 = event.getParam("level3");

        //console.log("handleFastSelection level1", level1);

        if (!$A.util.isEmpty(level1)) {
            component.set("v.level1Value", (!$A.util.isEmpty(level1) ? level1.value : null));
            component.set("v.level2Value", (!$A.util.isEmpty(level2) ? level2.value : null));
            component.set("v.level3Value", (!$A.util.isEmpty(level3) ? level3.value : null));

            component.set("v.showNatureList", false);
            component.set("v.showCategoryList", false);
            component.set("v.showDomainList", false);                    
            // lastLevelNoResult

            //var currentLevel = component.get("v.levelCurrent");
            //component.get("v.levelLast")
            helper.goFlowNext(component, event);
        }
    },

    findValus : function(component, event, helper) {         
        var recordTypeId = component.get("v.recordTypeId");
        console.log("findValus < recordTypeId", recordTypeId);
        if (!$A.util.isEmpty(recordTypeId)) {
            helper.getPicklist(component);
        }
      
    }

})