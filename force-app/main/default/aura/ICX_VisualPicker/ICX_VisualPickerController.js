({
    init: function(component, event, helper) { 
        
        // NEXT BUTTON for FLOW: http://releasenotes.docs.salesforce.com/en-us/winter19/release-notes/rn_forcecom_flow_validate_attribute.htm
        // Set the validate attribute to a function that includes validation logic. 
        component.set('v.validate', function() { 
            if (component.get("v.required") == false || !$A.util.isEmpty(component.get("v.selection"))) { 
                return { isValid: true }; 
            } else { 
                //If the component is invalid, return the isValid parameter as false and return an error message. 
                return { 
                    isValid: false, 
                    errorMessage: '/*A message that helps your user enter a valid value or explains what went wrong.*/' 
                }; 
            }}) 
    },

    onSelection : function(component, event, helper) {
        //console.log("onSelection");

        var selectedItem = event.currentTarget; // Get the target object
        if (!$A.util.isEmpty(selectedItem)) {
            var index = selectedItem.dataset.index; // Get its value i.e. the index

            var item = component.get("v.itemList")[index];
            if (!$A.util.isEmpty(item)) {
                component.set("v.selectionLabel", item.label);
                component.set("v.selection", item.value);
            }
            helper.fireEvent(component, event);
        }

    },

    onChangeSelect : function(component, event, helper) {
        helper.fireEvent(component, event);
    }
})