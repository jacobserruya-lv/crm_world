({
    findPicklist : function(component, event, helper) {

        var params = event.getParam("arguments");
        
        var action 	= component.get("c.getPicklist");
        action.setParams({
            "recordTypeId" : params.recordTypeId,
            "sObjectType" : params.object
        });
        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log("result", response.getReturnValue());
                params.callback(null, response.getReturnValue());
            } else {
                console.log("error", response.getError());
                params.callback(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    findFieldList : function(component, event, helper) {

        var params = event.getParam("arguments");
        
        var action 	= component.get("c.getFieldList");
        action.setParams({
            "parser" : params.parser,
            "fieldLevelList" : params.fieldLevelList,
            "showParentWithChildrenList" : params.showParentWithChildrenList,
            "hierarchyDependantFieldList" : params.hierarchyDependantFieldList
        });
        console.log("ICX_PiclistDataService > findFieldList", params.parser, params.fieldLevelList, params.showParentWithChildrenList);

        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                params.callback(null, response.getReturnValue());
            } else {
                params.callback(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

})