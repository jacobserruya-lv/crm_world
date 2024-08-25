({
    onInit: function (component, event, helper) {
        ///var lookupComponent = component.find("lookupComponent");
        //lookupComponent.search();

        var defaultSearchCriteria = component.get("v.defaultSearchCriteria");
        console.log("init>defaultSearchCriteria=" + defaultSearchCriteria);
        if (!$A.util.isEmpty(defaultSearchCriteria)) {
            var action = component.get("c.search");
            action.setParams({
                'searchTerm': component.get("v.defaultSearchCriteria"),
                'selectedIds' : null,
                'anOptionalParam' : null
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("defaultSearchCriteria>result", JSON.stringify(result));
                    if(result.length == 0){
                        var selection = component.get('v.selection');
                        selection.push({
                            subtitle:component.get('v.defaultSearchCriteria'),
                            title: component.get('v.defaultSearchCriteria'),
                            id: component.get('v.defaultSearchCriteria'),
                            icon: "standard:email"
                        });
                        component.set('v.selection', selection);
                    }
                    else{
                        var defaultSearchId = component.get('v.defaultSearchId');
                        console.log('@ Default Search Id: ', defaultSearchId);
                        var selection = result[0];
                        
                        if(defaultSearchId){
                            var selectionById = result.filter((record) => record.id == defaultSearchId);
                            selection = selectionById.length == 1 ? selectionById : selection;                      
                            console.log('@ selectionById: ', selectionById);
                        }
                        console.log('@ selection: ', selection);
                        component.set('v.selection', selection);
                    }
                } 
            });
            $A.enqueueAction(action); 
           
            /* var lookupComponent = component.find("lookupComponent");
            var searchResult = lookupComponent.search(action);
            console.log('searchResult=' + searchResult);*/
        }
    },

    lookupSearch : function(component, event, helper) {
        helper.lookupSearch2(component, event);
        /*// Get the lookup component that fired the search event
        const lookupComponent = event.getSource();
        // Get the SampleLookupController.search server side action
        const serverSearchAction = component.get('c.search');
        // You can pass optional parameters to the search action
        // but you can only use setParam and not setParams to do so
        serverSearchAction.setParam('anOptionalParam', 'not used');
        // Pass the action to the lookup component by calling the search method
        lookupComponent.search(serverSearchAction);*/
    },

    clearErrorsOnChange: function(component, event, helper) {
        const selection = component.get('v.selection');
        const errors = component.get('v.errors');
        if (selection.length && errors.length) {
            component.set('v.errors', []);
        }
    },
})