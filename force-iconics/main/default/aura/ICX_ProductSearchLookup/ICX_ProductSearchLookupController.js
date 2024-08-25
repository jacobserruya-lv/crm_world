({
    onInit : function(component, event, helper) {
        helper.validate(component, event);

        var recId = component.get('v.recordId');
        //console.log("recId", recId);
        // record id not empty -> add criteria to find existing selection from the record id
        if (!$A.util.isEmpty(recId)) {
			helper.getCurrentSelection(component, event);
            helper.isReadOnly(component, event);
        } else if (!$A.util.isEmpty(component.get("v.selectionList"))) {
            const selection = component.get('v.selection');

            //if (!$A.util.isEmpty(component.get("v.selectionList")[0])) {
                selection.push(component.get("v.selectionList")[0]);
            /*}
            if (!$A.util.isEmpty(component.get("v.selectionList")[1])) {
                selection.push(component.get("v.selectionList")[1]);
            }*/
            component.set('v.selection', selection);
        }
    },

    onCaseUpdated : function(component, event, helper) {
       // console.log("onRefreshView");

        var eventParams = event.getParams();
        if (eventParams.changeType === "CHANGED") {
            // get the fields that are changed for this record
            // var changedFields = eventParams.changedFields;
            //console.log('Fields that are changed: ' + JSON.stringify(changedFields));            
            //var newStatus = (typeof changedFields.Status !== 'undefined' ? changedFields.Status.value : '');
            //console.log("newStatus", newStatus);
            helper.isReadOnly(component, event);
        }
    },
    
    userChange : function(component, event, helper) {
        console.log("userChange");

        var recId = component.get('v.recordId');
        // record id not empty -> add criteria to find existing selection from the record id
        if (!$A.util.isEmpty(recId)) {
            helper.isReadOnly(component, event);
        }
    },

    lookupSearch : function(component, event, helper) {
        // Get the ICX_ProductSearchLookup_LC.search server side action
        const serverSearchAction = component.get('c.search');
        // Passes the action to the Lookup component by calling the search method
        component.find('lookup').search(serverSearchAction);
    },

    handleSearchActionEvent : function(component, event, helper) {
        //console.log("handleSearchActionEvent");
		helper.updateProduct(component, event);
    },

    handleSearchEvent : function(component, event, helper) {
        //console.log("handleSearchEvent");
        //console.log("handleSearchEvent event", JSON.stringify(event.getParams()));

        //var action = event.getParam("action");
        //var recordId = event.getParam("recordId");
        //console.log("handleSearchEvent " + action + "," + recordId);
    },

    handleFlowFooterEvent : function (component, event, helper) {
        // if the footer event concerns the actual record (avoid confusion between open tabs)
        if (component.get("v.recordId") === event.getParam("recordId")) {
            console.log("saveAll products");
            // Code commented for the moment (no usage of Product_Enquired__c object for now). To activate for multi-product selection with qualification
            helper.saveAll(component, event);
        }
    },
})