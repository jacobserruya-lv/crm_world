({
    updateSearchTerm : function(component, searchTerm) {
        // Save search term so that it updates input
        component.set('v.searchTerm', searchTerm.toLowerCase());
        
        // Get previous clean search term
        const cleanSearchTerm = component.set('v.cleanSearchTerm');

        // Compare clean new search term with current one and abort if identical
        const newCleanSearchTerm = searchTerm.trim().replace(/\*/g, '').toLowerCase();
        if (cleanSearchTerm === newCleanSearchTerm) {
            return;
        }

        // Update clean search term for later comparison
        component.set('v.cleanSearchTerm', newCleanSearchTerm);

        // Ignore search terms that are too small
        if (newCleanSearchTerm.length < 2) {
            component.set('v.searchResults', []);
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        let searchTimeout = component.get('v.searchThrottlingTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        searchTimeout = window.setTimeout(
            $A.getCallback(function() {
                // Send search event if it long enougth
                const searchTerm = component.get('v.searchTerm');
                if (searchTerm.length >= 2) {
                    //const searchEvent = component.getEvent('onSearch');
                    //searchEvent.fire();
                    console.log("filter value", searchTerm);
                    var values = component.get("v.values");

                    // filter to search text
                    const result = values.filter(word => word.label.includes(searchTerm));
                    console.log("result", result);
                    
                    // sort by label
                    result.sort(function(a,b) {
                        if (a.label < b.label) return -1;
                        if (a.label > b.label) return 1;
                        return 0;
                    });

                    component.set('v.searchResults', result);
                    component.set('v.openMenu', true);
                    component.set('v.focusIndex', null);
                }
                component.set('v.searchThrottlingTimeout', null);
            }),
            300
        );
        component.set('v.searchThrottlingTimeout', searchTimeout);
    },

    selectResult : function(component, helper, labelId) {
        // Save selection
        const searchResults = component.get('v.searchResults');
        const selectedResult = searchResults.filter(function(result) { return result.label === labelId; });
        if (selectedResult.length > 0) {
            const selection = selectedResult[0];//component.get('v.selection');
            //selection.push(selectedResult[0]);
            component.set('v.selection', selectedResult[0]);//selection);
            helper.sendSelectedEvent(component, selection);
        }
        // Reset search
        component.set('v.searchTerm', '');
        component.set('v.searchResults', []);
        
       // component.set('v.openMenu', false);
    },

    getSelectedIds : function(component) {
        const selection = component.get('v.selection');
        return selection.map(function(element) { return element.id; });
    },

    removeSelectedItem : function(component, removedItemId) {
        const selection = component.get('v.selection');
        const updatedSelection = selection.filter(function(item) { return item.id !== removedItemId; });
        component.set('v.selection', updatedSelection);
    },

    clearSelection : function(component, itemId) {
        component.set('v.selection', []);
    },

    isSelectionAllowed : function(component) {
        return component.get('v.isMultiEntry') || component.get('v.selection').length === 0;
    },

    toggleSearchSpinner : function(component) {
        const spinner = component.find('spinner');
        const searchIcon = component.find('search-icon');

        $A.util.toggleClass(spinner, 'slds-hide');
        $A.util.toggleClass(searchIcon, 'slds-hide');
    },

    // https://github.com/appiphony/Strike-Components/blob/master/aura/strike_lookup/strike_lookupHelper.js
    moveRecordFocusUp: function(component, event, helper) {
       // var openMenu = component.get('v.openMenu');

        //if (openMenu) {
            var focusIndex = component.get('v.focusIndex');
            var options = component.find('lookupMenu').getElement().getElementsByTagName('li');

            if (focusIndex === null || focusIndex === 0) {
                focusIndex = options.length - 1;
            } else {
                --focusIndex;
            }

            component.set('v.focusIndex', focusIndex);
        //}
    },
    moveRecordFocusDown: function(component, event, helper) {
        //var openMenu = component.get('v.openMenu');

        //if (openMenu) {
            var focusIndex = component.get('v.focusIndex');
            var options = component.find('lookupMenu').getElement().getElementsByTagName('li');

            if (focusIndex === null || focusIndex === options.length - 1) {
                focusIndex = 0;
            } else {
                ++focusIndex;
            }

            component.set('v.focusIndex', focusIndex);
        //}
    },

    updateValueByFocusIndex: function(component, event, helper) {
        var focusIndex = component.get('v.focusIndex');

        if (focusIndex == null) {
            focusIndex = 0;
        }

        var records = component.get('v.searchResults');

        if (focusIndex < records.length) {
            const updatedSelection = records[focusIndex];
            console.log("updatedSelection", updatedSelection);
            component.set('v.selection', updatedSelection);
            //component.set('v.value', records[focusIndex].value);
            //component.set('v.valueLabel', records[focusIndex].label);
            //component.set('v.valueSublabel', records[focusIndex].sublabel);
           // component.find('lookupInput').getElement().value = '';

            helper.closeMenu(component, event, helper);
            helper.sendSelectedEvent(component, updatedSelection);
        } else if (focusIndex === records.length) {
            //helper.addNewRecord(component, event, helper);
        }

        //helper.closeMobileLookup(component, event, helper);
    },

    closeMenu: function(component, event, helper) {
        component.set('v.focusIndex', null);
        component.set('v.openMenu', false);
    },

    sendSelectedEvent : function(component, selection) {
        console.log("sendSelectedEvent");
        //var selection = component.get("v.selection");
        console.log("selection", JSON.stringify(selection));

        if (!$A.util.isEmpty(selection)) {
            var myEvent = component.getEvent("onFastQualificationSelectedEvent");
            myEvent.setParams({
                "level1": selection.level1,
                "level2": selection.level2,
                "level3": selection.level3
            });
            console.log("myEvent", JSON.stringify(myEvent.getParams()));
            myEvent.fire();
        }
    }
})