// https://github.com/pozil/sfdc-ui-lookup
// https://developer.salesforce.com/blogs/2018/07/10-tips-for-implementing-an-efficient-lightning-lookup-component.html
({
    search : function(component, event, helper) {
        const action = event.getParam('arguments').serverAction;

        action.setParams({
            searchTerm : component.get('v.searchTerm'),
            selectedIds : helper.getSelectedIds(component)
        });

        action.setCallback(this, (response) => {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Process server success response
                const returnValue = response.getReturnValue();
                component.set('v.searchResults', returnValue);
            }
            else if (state === 'ERROR') {
                // Retrieve the error message sent by the server
                const errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    const error = errors[0];
                    if (typeof error.message != 'undefined') {
                        message = error.message;
                    } else if (typeof error.pageErrors != 'undefined' && Array.isArray(error.pageErrors) && error.pageErrors.length > 0) {
                        const pageError = error.pageErrors[0];
                        if (typeof pageError.message != 'undefined') {
                            message = pageError.message;
                        }
                    }
                }
                // Display error in console
                console.error('Error: '+ message);
                console.error(JSON.stringify(errors));
                // Fire error toast if available (LEX only)
           		const toastEvent = $A.get('e.force:showToast');
                if (typeof toastEvent !== 'undefined') {
                    toastEvent.setParams({
                        title : 'Server Error',
                        message : message,
                        type : 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
            }
        });

        //action.setStorable(); // Enables client-side cache & makes action abortable
        $A.enqueueAction(action);
	},
/*
    buildSelection : function(component, event, helper) {
    	console.log("buildSelection");
        const action = event.getParam('arguments').serverAction;
        const recordId = event.getParam('arguments').recordId;

        action.setParams({
            recordId : recordId
        });

        action.setCallback(this, (response) => {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Process server success response
                const returnValue = response.getReturnValue();
            	console.log("returnValue", JSON.stringify(returnValue));
                component.set("v.selection", returnValue);
        //        console.log(component.get(v.selection), component.get('v.selection'));
            }
            else if (state === 'ERROR') {
                // Retrieve the error message sent by the server
                const errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    const error = errors[0];
                    if (typeof error.message != 'undefined') {
                        message = error.message;
                    } else if (typeof error.pageErrors != 'undefined' && Array.isArray(error.pageErrors) && error.pageErrors.length > 0) {
                        const pageError = error.pageErrors[0];
                        if (typeof pageError.message != 'undefined') {
                            message = pageError.message;
                        }
                    }
                }
                // Display error in console
                console.error('Error: '+ message);
                console.error(JSON.stringify(errors));
                // Fire error toast if available (LEX only)
                const toastEvent = $A.get('e.force:showToast');
                if (typeof toastEvent !== 'undefined') {
                    toastEvent.setParams({
                        title : 'Server Error',
                        message : message,
                        type : 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
            }
        });

        $A.enqueueAction(action);
    },*/

    onInput : function(component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        const newSearchTerm = event.target.value;
        helper.updateSearchTerm(component, newSearchTerm);
    },

    onResultClick : function(component, event, helper) {
        const recordId = event.currentTarget.id;
        helper.selectResult(component, recordId);
    },

    onComboboxClick : function(component, event, helper) {
        // Hide combobox immediatly
        const blurTimeout = component.get('v.blurTimeout');
        if (blurTimeout) {
            clearTimeout(blurTimeout);
        }
        component.set('v.hasFocus', false);
    },

    onFocus : function(component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        component.set('v.hasFocus', true);
    },

    onBlur : function(component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }        
        // Delay hiding combobox so that we can capture selected result
        const blurTimeout = window.setTimeout(
            $A.getCallback(() => {
                component.set('v.hasFocus', false);
                component.set('v.blurTimeout', null);
            }),
            300
        );
        component.set('v.blurTimeout', blurTimeout);
    },

    onRemoveSelectedItem : function(component, event, helper) {
        const itemId = event.getSource().get('v.name');
        helper.removeSelectedItem(component, itemId);
    },
    onRemoveSelectedItem2 : function(component, event, helper) {
        var selectedItem = event.currentTarget; // Get the target object
        var itemId = selectedItem.dataset.index; // Get its value i.e. the index
        helper.removeSelectedItem(component, itemId);
    },
  /* onRemoveSelectedItem3 : function(component, event, helper) {
        var itemId = event.getParam("recordId"); 
        helper.filterSelection(component, itemId);
    },*/
    onClearSelection : function(component, event, helper) {
        helper.clearSelection(component);
    },

    redirectTab : function (component, event) {
        var selectedItem = event.currentTarget; // Get the target object
        var caseID = selectedItem.dataset.index; // Get its value i.e. the index
        console.log("caseID", caseID);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(responseConsole) {

            // open sub-tab in the Console app
            if (responseConsole) {
                workspaceAPI.getFocusedTabInfo().then(function(response) {

                    var focusedTabId = response.tabId;
                    if (response.isSubtab) {
                        focusedTabId = response.parentTabId;
                    }

                    workspaceAPI.openSubtab({
                        parentTabId : focusedTabId,
                        recordId : caseID,
                        //url : '/lightning/r/Case/' + caseID + '/view',
                        focus: true                    
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            } else {
                // if not in a Console app
                var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                    "recordId" : caseID,
                    "isredirect" : "true"
                });
                urlEvent.fire();
            }
            
        })
        .catch(function(error) {
            console.log(error);
        });

    },
    
    onRequestCheck : function (component, event) {
		console.log("onRequestCheck");
    },
                
	addUnknownProduct : function(component, event, helper) {
        /*const selection = component.get('v.selection');
        selection.push({
            title : "Unknown product"
        });
        component.set('v.selection', selection);*/

        //console.log("selectResult", JSON.stringify(selection));
        const searchEvent = component.getEvent('onSearchAction');
        searchEvent.setParams({
            "action": "ADD",
            "recordId": null
        });
        searchEvent.fire();
    }

})