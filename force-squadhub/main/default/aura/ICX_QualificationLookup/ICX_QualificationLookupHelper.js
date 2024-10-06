({
    level1Changed : function(component, event) {
        console.log("natureChanged");
        if (!$A.util.isEmpty(component.get("v.level1Value"))) {
            component.set("v.showNatureList", false);
            component.set("v.showCategoryList", true);
            component.set("v.showDomainList", false);
            
            component.set("v.level2Value", null);
            component.set("v.level2Label", null);
            component.set("v.level3Value", null);
            component.set("v.level3Label", null);
        }
    },
    
    level2Changed : function(component, event) {
        console.log("categoryChanged");
        if (!$A.util.isEmpty(component.get("v.level2Value"))) {
            component.set("v.showNatureList", false);
            component.set("v.showCategoryList", false);
            component.set("v.showDomainList", true);
            
            component.set("v.level3Value", null);
            component.set("v.level3Label", null);
        }
    },
    
    level3Changed : function(component, event) {
        console.log("domainChanged");
        if (!$A.util.isEmpty(component.get("v.level3Value"))) {
            component.set("v.showNatureList", false);
            component.set("v.showCategoryList", false);
            component.set("v.showDomainList", false);
        }
    },

    // Flow: go directly to the next screen
    goFlowNext : function(component) {
        console.log("Go flow next");
        
        var flowAutoNextOnLastSelection = component.get("v.flowAutoNextOnLastSelection");
        var navigate = component.get("v.navigateFlow");
        //console.log("navigate", navigate);
        if (flowAutoNextOnLastSelection === true && !$A.util.isEmpty(navigate)) {
            console.log("Go flow next!");
            //component.set("v.flowAutoBackOnSelection", true);
            navigate("NEXT");
        }
    },

    getRecordInfo : function(component) {
        console.log("getRecordInfo START");
        var recordId = component.get("v.recordId");

        if (!$A.util.isEmpty(recordId)) {
            var sObject = component.get("v.object");

            var action = component.get('c.getRecordTypeId');
            action.setParams({
                'recordId' : component.get("v.recordId"),
                'sObjectType' : sObject
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    console.log("sObject",sObject);
                    /*if (sObject === 'Case') {
                        component.set("v.objectWebService", "Case");
                        component.set("v.fastFieldList", ['Type', 'Category__c', 'Domaine__c']);

                        component.set("v.level1Field", "Type");
                        component.set("v.level2Field", "Category__c");
                        component.set("v.level3Field", "Domaine__c");
                        
                        // for Fast qualification, as User Interface API doesn't support Task object, get the dependant picklists from Case in Call record type
                        //component.set("v.object", "Case");
                    } else if (sObject === 'Task') {
                        component.set("v.objectWebService", "Case");
                        component.set("v.fastFieldList", ['Type', 'Category__c', 'Domaine__c']);

                        component.set("v.level1Field", "Type");//Nature__c");
                        component.set("v.level2Field", "Category__c");
                        component.set("v.level3Field", "Domaine__c");
                        console.log("qualification lookup task");
                    } else if (sObject === 'LiveChatTranscript') {
                        component.set("v.objectWebService", "Case");
                        component.set("v.fastFieldList", ['Type', 'Category__c', 'Domaine__c']);

                        component.set("v.level1Field", "Type");
                        component.set("v.level2Field", "Category__c");
                        component.set("v.level3Field", "Domaine__c");
                    }*/

                    //this.setupField(component, event);

                    var result = response.getReturnValue();
                    console.log("getRecordInfo > result", result);
                    
                    component.set("v.recordTypeId", result);
                    /*
                     // when BACK button, display the selection list
                    console.log("doInit > level values", component.get("v.level1Value"), component.get("v.level2Value"), component.get("v.level3Value"));
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

                    console.log("getRecordInfo STOP");
                } else if(state === "ERROR") {
                    //  helper.handleError(response);
                }
            });
            $A.enqueueAction(action);
        }
    },

    getPicklist : function(component) {
        var recordTypeId = component.get("v.recordTypeId");
        var sObject = component.get("v.objectWebService");

        if (!$A.util.isEmpty(recordTypeId) && !$A.util.isEmpty(sObject)) {
            //var sObject = component.get("v.object");

            console.log("getPicklist recordTypeId/sObject", recordTypeId, sObject);
            var action = component.get('c.getPicklist');
            action.setParams({
                'recordTypeId' : recordTypeId,
                'sObjectType' : sObject
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var listParser = response.getReturnValue();
                    component.set("v.picklistFieldValues", listParser);
                    console.log("getPicklist > picklistFieldValues", listParser);
                    //console.log("component.get(v.level2Value)", component.get("v.level2Value"));
                    //console.log("component.get(v.level3Value)", component.get("v.level3Value"));

                    if (!$A.util.isEmpty(component.get("v.level3Value"))) {
                        component.set("v.showDomainList", true);
                        component.set("v.showNatureList", false);
                    } else if (!$A.util.isEmpty(component.get("v.level2Value"))) {
                        component.set("v.showCategoryList", true);
                        component.set("v.showNatureList", false);
                    } else if (!$A.util.isEmpty(component.get("v.level1Value"))) {
                        component.set("v.showNatureList", true);
                    }

                    /*var fastFieldList = component.get("v.fastFieldList");
                    if (!$A.util.isEmpty(fastFieldList)) {
                        this.setupField(component, event);
                    }*/
                    
                    var fieldLevelList = component.get("v.fastFieldList");
                    var showParentWithChildrenList = component.get("v.showParentWithChildrenList");
                    console.log("listParser/fieldLevelList/showParentWithChildrenList", listParser, fieldLevelList, showParentWithChildrenList);
                    // getFieldList(ICX_PicklistValuesParser parser, List<String> fieldLevelList, List<Boolean> showParentWithChildrenList)
                    /*var action2 = component.get('c.getFieldList');
                    action2.setParams({
                        'parser' : JSON.stringify(listParser),
                        'fieldLevelList' : component.get("v.fastFieldList"),
                        'showParentWithChildrenList' : component.get("v.showParentWithChildrenList")
                    });
                    
                    action2.setCallback(this, function(response2) {
                        var state = response2.getState();
                        if (state === "SUCCESS") {
                            var result = response2.getReturnValue();
                            var qualificationList = JSON.parse(result);
                            component.set('v.qualificationList', qualificationList);
                            console.log("qualificationList", qualificationList);
                            
                            // TODO
                            // get Level 1 in a Set (no duplicate)
                            const level1FilterList = [];
                            qualificationList.forEach((item) => {
                                if (!$A.util.isEmpty(item.level1) && !level1FilterList.some(x => (x.value === item.level1.value))) {
                                	level1FilterList.push(item.level1);
                            	}
							})
                            console.log("level1FilterList", level1FilterList);
                            
                            var level1Value = 'Transfer'; // Product Information
                            const level2FilterList = [];
                            if (!$A.util.isEmpty(level1Value)) {
                                qualificationList.forEach((item) => {
                                    if (item.level1.value === level1Value && !$A.util.isEmpty(item.level2) && !level2FilterList.some(x => (x.value === item.level2.value))) {
                                 	   level2FilterList.push(item.level2);
                                	}
								})
                            }
                            console.log("level2FilterList", level2FilterList);

                            var level2Value = ''; // Price
                            const level3FilterList = [];
                            if (!$A.util.isEmpty(level2Value)) {
                                qualificationList.forEach((item) => {
                                    if (item.level1.value === level1Value && item.level2.value === level2Value && !$A.util.isEmpty(item.level3) && !level3FilterList.some(x => (x.value === item.level3.value))) {
                                        level3FilterList.push(item.level3);
                                    }
                                })
                            }
                            console.log("level3FilterList", level3FilterList);
                        }
                    });
                    $A.enqueueAction(action2);*/

                    /*    console.log("sObject",sObject);
     
                    var result = response.getReturnValue();
                    //console.log("getRecordInfo > result", result);
                    
                    component.set("v.recordTypeId", result);
                    
                     // when BACK button, display the selection list

                    console.log("getRecordInfo STOP");
                } else if(state === "ERROR") {
                    //  helper.handleError(response);*/
                }
            });
            $A.enqueueAction(action);
        }
    },

    setupField : function (component, event, helper) {
        var sObject = component.get("v.object");

        console.log("sObject",sObject);
        // Unsupported object with UI API should used a supported object (Case in this example)
        if (sObject === 'Task' || sObject === 'LiveChatTranscript' || sObject === 'MessagingSession') {
            // These objects only use this Lightning Component for the Qualification Screen (if anothers field depedencies are requests. This should be changed) 
            component.set("v.fastFieldList", ['Type', 'Category__c', 'Domaine__c']);
            component.set("v.objectWebService", "Case");
        
            component.set("v.level1Field", "Type");
            component.set("v.level2Field", "Category__c");
            component.set("v.level3Field", "Domaine__c");
        } else if (sObject === 'Case') {
            // Case can request values from a different Record Type 
            component.set("v.fastFieldList", [component.get("v.level1Field"), component.get("v.level2Field"), component.get("v.level3Field")]);
            //component.set("v.fastFieldList", ['Type', 'Category__c', 'Domaine__c']);
            component.set("v.objectWebService", "Case");
        
            //component.set("v.level1Field", "Type");
            //component.set("v.level2Field", "Category__c");
            //component.set("v.level3Field", "Domaine__c");
        }

        /*var sObject = component.get("v.object");

        console.log("sObject",sObject);
        if (sObject === 'Case') {
            component.set("v.fastFieldList", ['Type', 'Category__c', 'Domaine__c']);
            component.set("v.objectWebService", "Case");
            
            component.set("v.level1Field", "Type");
            component.set("v.level2Field", "Category__c");
            component.set("v.level3Field", "Domaine__c");
            
            // for Fast qualification, as User Interface API doesn't support Task object, get the dependant picklists from Case in Call record type
            //component.set("v.object", "Case");
        } else if (sObject === 'Task') {
            component.set("v.fastFieldList", ['Type', 'Category__c', 'Domaine__c']);
            component.set("v.objectWebService", "Case");
            
            component.set("v.level1Field", "Type");//Nature__c");
            component.set("v.level2Field", "Category__c");
            component.set("v.level3Field", "Domaine__c");
            console.log("qualification lookup task");
        } else if (sObject === 'LiveChatTranscript') {
            component.set("v.fastFieldList", ['Type', 'Category__c', 'Domaine__c']);
            component.set("v.objectWebService", "Case");
            
            component.set("v.level1Field", "Type");
            component.set("v.level2Field", "Category__c");
            component.set("v.level3Field", "Domaine__c");
        }*/
        
        // when BACK button, display the selection list
        console.log("doInit > level values", component.get("v.level1Value"), component.get("v.level2Value"), component.get("v.level3Value"));
        // when BACK button, display the selection list
        if (!$A.util.isEmpty(component.get("v.level3Value"))) {
            component.set("v.showDomainList", true);
            component.set("v.showNatureList", false);
        } else if (!$A.util.isEmpty(component.get("v.level2Value"))) {
            component.set("v.showCategoryList", true);
            component.set("v.showNatureList", false);
        } else if (!$A.util.isEmpty(component.get("v.level1Value"))) {
            component.set("v.showNatureList", true);
        }
    },
    /*getNatureandcategory: function (component, event, helper) {
        var action = component.get('c.getNatureAndCategory');
           action.setParams({
              'recordId' : component.get("v.recordId"),
           	});
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var result = response.getReturnValue();
               console.log(result);
                if(result!=null){
                   console.log(result.Category__c);
                   console.log(result.Type);
                   component.set("v.Category", result.Category__c);
                   component.set("v.Nature", result.Type);

                }
              }
            });
          $A.enqueueAction(action);
    }*/
    
})