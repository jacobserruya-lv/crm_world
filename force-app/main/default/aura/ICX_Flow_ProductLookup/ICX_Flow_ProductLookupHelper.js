// https://github.com/pozil/sfdc-ui-lookup
// https://developer.salesforce.com/blogs/2018/07/10-tips-for-implementing-an-efficient-lightning-lookup-component.html
({
    updateSearchTerm : function(component, searchTerm) {
        // Cleanup new search term
        const updatedSearchTerm = searchTerm.trim().replace(/\*/g).toLowerCase();
        
        // Compare clean new search term with current one and abort if identical
        const curSearchTerm = component.get('v.searchTerm');
        if (curSearchTerm === updatedSearchTerm) {
            return;
        }

        // Update search term
        component.set('v.searchTerm', updatedSearchTerm);
        
        // Ignore search terms that are too small
        if (updatedSearchTerm.length < 2) {
            component.set('v.searchResults', []);
            return;
        }
        
        // Apply search throttling (prevents search if user is still typing)
        let searchTimeout = component.get('v.searchThrottlingTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        searchTimeout = window.setTimeout(
            $A.getCallback(() => {
                // Send search event if it long enougth
                const searchTerm = component.get('v.searchTerm');
                if (searchTerm.length >= 2) {
                    const searchEvent = component.getEvent('onSearch');
                    searchEvent.fire();
                }
                component.set('v.searchThrottlingTimeout', null);
            }),
            300
        );
        component.set('v.searchThrottlingTimeout', searchTimeout);
    },

    selectResult : function(component, recordId) {
        // Save selection
        const searchResults = component.get('v.searchResults');
        const selectedResult = searchResults.filter(result => result.id === recordId);
        if (selectedResult.length > 0) {
            /*const selection = component.get('v.selection');
            selection.push(selectedResult[0]);
            component.set('v.selection', selection);*/

            //console.log("selectResult", JSON.stringify(selection));
            const searchEvent = component.getEvent('onSearchAction');
            searchEvent.setParams({
                "action": "ADD",
                "recordId": recordId,
                "item" : selectedResult[0]
            });
            searchEvent.fire();
        }
        // Reset search
        const searchInput = component.find('searchInput');
        searchInput.getElement().value = '';
        component.set('v.searchTerm', '');
        component.set('v.searchResults', []);
    },

    getSelectedIds : function(component) {
        const selection = component.get('v.selection');
        console.log("seletion", selection);
        return selection.map(element => element.id);
    },

    removeSelectedItem : function(component, removedItemId) {
        //helper.filterSelection(component, removedItemId);

        console.log("removeSelectedItem");
        const searchEvent = component.getEvent("onSearchAction");
        searchEvent.setParams({
            "action": "REMOVE",
            "recordId": removedItemId
        });
        console.log("searchEvent", searchEvent);
        searchEvent.fire();
   },
    
    filterSelection : function(component, removeItemId) {
        const selection = component.get('v.selection');
        const updatedSelection = selection.filter(item => item.id !== removedItemId);
        component.set('v.selection', updatedSelection);                         
    },

    clearSelection : function(component, itemId) {
        component.set('v.selection', []);
    },

    isSelectionAllowed : function(component) {
        try{
            var myinput = document.getElementById(component.getGlobalId() + "_combobox").value;
            var required = component.get("v.required");
            var dropDown = component.find("dropDown");
            console.log("myinput", myinput);
            console.log("required", required);
            console.log("dropDown", dropDown);
            if(required && (!myinput || myinput == '')){
                //$A.util.addClass(dropDown, 'slds-has-error');
                component.set("v.valid", false);
            }
            else{
                //$A.util.removeClass(dropDown, 'slds-has-error');
                component.set("v.valid", true);
            }
        }
        catch(e){
            this.showError(component, e.message);
        }

        return component.get('v.isMultiEntry') || component.get('v.selection').length === 0;
    },

})