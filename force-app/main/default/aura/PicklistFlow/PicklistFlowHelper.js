({
	getPicklist: function(component, helper) {
        var fieldType = component.get("v.field");

        // picklist value (no picklist field or dependent picklist)
        if (!$A.util.isEmpty(component.get("v.valueList"))) {
            return;
        }

        var apiList = component.get("v.apiList");
        if (!$A.util.isEmpty(apiList)) {
            this.buildPicklistFromScratch(component);
        } else if ($A.util.isEmpty(component.get("v.controllingField"))) {
            // for Type (Nature) field, no need to get dependent values

            console.log("fieldType", fieldType);
            console.log("component.get(v.object)", component.get("v.object"));
            var action = component.get('c.getOptions');
           // action.setStorable();
            action.setParams({
                'sObjectType': component.get("v.object"),
                'controllingFieldName' : fieldType
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("getPicklist > result", result);

                    component.set('v.valueList', JSON.parse(result));

                    // go to the next flow if no list and selected value is empty (for usecase where the user were in the Product screen and go back to the Domain page)
                    //if ($A.util.isEmpty(result)) {
                    //    this.goFlowNext(component);
                    //}
                    //callback();
                } else if(state === "ERROR") {
                    //  helper.handleError(response);
                }
            });
            $A.enqueueAction(action);
        } else {
            
            // Important for auto-back 
            var back = component.get("v.flowAutoBackOnSelection");
            component.set("v.flowAutoBackOnSelection", false);

            // Dependent picklist
            console.log("Dependent picklist");
            var action2 = component.get('c.getPicklistMap');
            action2.setParams({
                'sObjectType': component.get("v.object"),
                'controllingFieldName' : component.get("v.controllingField"),
                'dependentFieldName' : component.get("v.field")
            });
            
            action2.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    var resultJSON = response.getReturnValue();
                    console.log("resultJSON", resultJSON);
                    //component.set('v.dependentItemMap', result);
                    
                    // get option list based on the controlling value
                    var controllingValue = component.get("v.controllingValue");
                    console.log("controllingValue", controllingValue);

                    var result = JSON.parse(resultJSON);
                    var dependentList = result[controllingValue];
                    console.log("dependentList", dependentList);
                    component.set('v.valueList', dependentList);
                    component.set("v.noResult", ($A.util.isEmpty(dependentList) ? true : false));

                      // CODE SCAN ANALYZE 2019 put on comment Dead stores should be removed
                      // var selValue = component.get("v.selectedValue");
                     
                    // go to the next flow 
                    if ($A.util.isEmpty(dependentList)) {
                        // flowShowScreen is true on the first load (value sent by flow), then 
                        // if no list  (for usecase where the user were in the Product screen and go back to the Domain page)
                      //  if (component.get("v.flowShowScreen") == false) {
                        console.log("component.get(v.flowAutoBackOnSelection) / field", component.get("v.flowAutoBackOnSelection"), component.get("v.field"));
                        if (back == true) {
                            var navigate = component.get("v.navigateFlow");
                            if (!$A.util.isEmpty(navigate)) {
                                // Important for auto-back 
                                component.set("v.flowAutoBackOnSelection", false);
                                navigate("BACK");
                            }
                        } else {
                            // Important to set to auto-back
                            component.set("v.flowAutoBackOnSelection", true);
                            this.goFlowNext(component);                            
                        }
                        //  } else {
                        //      component.set("v.flowShowScreen", true);                        
                        //  }
                    } 
                    
                    //callback();
                }
                /*else if(state === "ERROR") {
                    //helper.handleError(response);
                }*/
            });
            $A.enqueueAction(action2);
        }
        
    },

    // Flow: go directly to the next screen
    goFlowNext : function(component) {
        if (component.get("v.flowAutoNextOnSelection") == true) {
            var navigate = component.get("v.navigateFlow");
            console.log("navigpicklistflowhelper go next");
            if (!$A.util.isEmpty(navigate)) {
                //component.set("v.flowAutoBackOnSelection", true);
                navigate("NEXT");
            }
        }
    },

    validate : function(component, event) {
        // Set the validate attribute to a function that includes validation logic
        component.set('v.validate', function() {
            if (component.get("v.required")) {
                if (!$A.util.isEmpty(component.get("v.selectedValue"))) {
                    // If the component is valid...
                    return { isValid: true };
                }
                // If the component is invalid...
                var error = $A.get("$Label.c.ICX_Flow_Picklist_Error_Required");
                return { isValid: false, errorMessage: error};
            }
        })
    },

    getAllPicklist : function(component, event, helper) {        
        var picklistFieldValues = component.get("v.picklistFieldValues");
        var recordTypeId = component.get("v.recordTypeId");
        if (!$A.util.isEmpty(picklistFieldValues)) {
            this.filterPicklist(component);
        } else if (!$A.util.isEmpty(recordTypeId)) {
            var sObject = component.get("v.object");
            var targetsObject = (sObject === 'LiveChatTranscript' || sObject === 'Task' ? 'Case' : sObject);
            console.log("recordTypeId/sObject/targetsObject/field", recordTypeId, sObject, targetsObject, component.get("v.field"));
            
            if (!$A.util.isEmpty(sObject)) {
                var picklistService = component.find("picklistService");
                picklistService.getPicklist(recordTypeId, targetsObject, $A.getCallback(function(error, data) {
                    if (!$A.util.isEmpty(data)) {
                        console.log("field/data", component.get("v.field"), data);
                        component.set("v.picklistFieldValues", data);
                        // filter                    
                        //this.filterPicklist(component, helper);
                    }
                }));
            }
        } else {
            this.getPicklist(component, helper);
        }
    },

    filterPicklist : function(component, helper) {

        var self = this;

        var picklistFieldValues = component.get("v.picklistFieldValues");
        var fieldName = component.get("v.field");
        var controllingField = component.get("v.controllingField");
        var controllingFieldValue = component.get("v.controllingValue");
        var hierarchyDependantFields = component.get("v.hierarchyDependantFields");
        console.log("filterPicklist > picklistFieldValues", picklistFieldValues, fieldName, controllingField, controllingFieldValue);
        
        if (!$A.util.isEmpty(picklistFieldValues) && !$A.util.isEmpty(picklistFieldValues.picklistFieldValues)) {
            if (!$A.util.isEmpty(controllingField)) {
                var picklistService = component.find("picklistService");
                picklistService.getFieldList(
                    JSON.stringify(picklistFieldValues),
                    JSON.stringify([controllingField, fieldName]),
                    JSON.stringify([false, false]),
                    hierarchyDependantFields,
                    $A.getCallback(function(error, data2) {
                        console.log("data2", data2);
                        var qualificationList = JSON.parse(data2);
                        
                        const level2FilterList = [];
                        if (!$A.util.isEmpty(controllingFieldValue)) {
                            qualificationList.forEach((item) => {
                                if (item.level1.value === controllingFieldValue && !$A.util.isEmpty(item.level2) && !level2FilterList.some(x => (x.value === item.level2.value))) {
                                    level2FilterList.push(item.level2);
                                }
							})
                            console.log("level2FilterList", level2FilterList);
                            component.set("v.valueList", level2FilterList);

                            var back = component.get("v.flowAutoBackOnSelection");
                            component.set("v.noResult", ($A.util.isEmpty(level2FilterList) ? true : false));
                            // go to the next flow 
                            if ($A.util.isEmpty(level2FilterList)) {
                                // flowShowScreen is true on the first load (value sent by flow), then 
                                // if no list  (for usecase where the user were in the Product screen and go back to the Domain page)
                                //  if (component.get("v.flowShowScreen") == false) {
                                console.log("component.get(v.flowAutoBackOnSelection) / field", back, component.get("v.field"));
                                if (back == true) {
                                    var navigate = component.get("v.navigateFlow");
                                    if (!$A.util.isEmpty(navigate)) {
                                        // Important for auto-back 
                                        component.set("v.flowAutoBackOnSelection", false);
                                        navigate("BACK");
                                    }
                                } else {
                                    // Important to set to auto-back
                                    component.set("v.flowAutoBackOnSelection", true);
                                    self.goFlowNext(component);                            
                                }
                            } 
                        }
                    })
                );
            } else {
                if (!$A.util.isUndefined(picklistFieldValues.picklistFieldValues[fieldName])) {
                    var picklistValues = picklistFieldValues.picklistFieldValues[fieldName].values;    
                    console.log("picklistValues", picklistValues);
                    component.set("v.valueList", picklistValues);
                }
            }
        }

    },

    buildPicklistFromScratch : function(component) {
        var apiList = component.get("v.apiList");
        console.log("apiList", apiList);

        if (!$A.util.isEmpty(apiList)) {
            //var res = apiList.split(",");
            if (!$A.util.isEmpty(apiList)) {

                var apiListSplit = apiList.split(",");

                var jsonResult = [];
                var labelList = component.get("v.labelList");
                var labelListSplit = labelList.split(",");

                for (var i = 0; i < apiListSplit.length; i++) {
                    console.log(apiListSplit[i]);
                    var item1 = {
                        "value": apiListSplit[i].trim(),
                        "label" : labelListSplit[i].trim()
                    };
                    jsonResult.push(item1);
                }
            }
            console.log("jsonResult", jsonResult);
            component.set("v.valueList", jsonResult);
        }
	}
})