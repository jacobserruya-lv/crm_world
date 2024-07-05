({
   doInit : function(component, event, helper) {
       // Prevent users to add a value while the data is loading
       //component.find("searchInput").set("v.readOnly", true);
       //var searchInput = component.find("searchInput");
       //$A.util.addClass(searchInput,'slds-hide');
       console.log("doInit START");

       var action = component.get('c.getPicklistFast');
       action.setParams({
           //'origin': 'Phone'
           'recordTypeId' : component.get("v.recordTypeId"), 
           'objectType' : component.get("v.objectType"), 
           'fieldLevelList' : component.get("v.fieldLevelList"), 
           'showParentWithChildrenList' : component.get("v.showParentWithChildrenList")
       });
       
       action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               var result = response.getReturnValue();
               console.log("getPicklist > result", result);
               
               // Lower case to easy search
               component.set('v.values', JSON.parse(result));
              //  var searchInput = component.find("searchInput");
          //     $A.util.removeClass(searchInput,'slds-hide');
               
               //callback();
               console.log("doInit STOP");

           } else if(state === "ERROR") {
               //  helper.handleError(response);
           }
       });
       // set as a background action
       action.setBackground();

       $A.enqueueAction(action);
   },

    /*afterRender: function (cmp, helper) {
        this.superAfterRender();
        cmp.find("searchInput").focus();
    },*/

    search : function(component, event, helper) {
        //const action = event.getParam('arguments').serverAction;
        //helper.toggleSearchSpinner(component);
        
        
    },

    onInput : function(component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        const newSearchTerm = event.target.value;
        helper.updateSearchTerm(component, newSearchTerm);
    },

    onResultClick : function(component, event, helper) {
        const labelId = event.currentTarget.id;
        helper.selectResult(component, helper, labelId);

        helper.closeMenu(component, event, helper);
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
            $A.getCallback(function() {
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

    onClearSelection : function(component, event, helper) {
        helper.clearSelection(component);
    },

    // handle key pad: https://github.com/appiphony/Strike-Components/tree/master/aura/strike_lookup
    handleInputKeyDown: function(component, event, helper) {
        console.log('handleInputKeyDown');
        //if (component.get('v.disabled')) {
        //    return;
        //}

        var KEYCODE_TAB = 9;

        var keyCode = event.which || event.keyCode || 0;

        if (keyCode === KEYCODE_TAB) {
            helper.closeMenu(component, event, helper);
        }
    },
    handleInputKeyPress: function(component, event, helper) {
        console.log('handleInputKeyPress');
        //if (component.get('v.disabled')) {
        //    return;
        //}
    },

    handleInputKeyUp: function(component, event, helper) {
        console.log('handleInputKeyUp');
        //if (component.get('v.disabled')) {
        //    return;
        //}

        var KEYCODE_ENTER = 13;
        var KEYCODE_UP = 38;
        var KEYCODE_DOWN = 40;
        var KEYCODE_ESC = 27;

        var keyCode = event.which || event.keyCode || 0;
        console.log('keyCode', keyCode);

        if (keyCode === KEYCODE_ENTER) {
            console.log('handleInputKeyUp KEYCODE_ENTER');
            //const labelId = event.currentTarget.id;
            //console.log("labelId", labelId);
            //helper.selectResult(component, labelId);
            helper.updateValueByFocusIndex(component, event, helper);
        } else if (keyCode === KEYCODE_UP) {
            console.log('handleInputKeyUp KEYCODE_UP');
            helper.moveRecordFocusUp(component, event, helper);
        } else if (keyCode === KEYCODE_DOWN) {
            console.log('handleInputKeyUp KEYCODE_DOWN');
            helper.moveRecordFocusDown(component, event, helper);
        } else if (keyCode === KEYCODE_ESC) {
            helper.closeMenu(component, event, helper);
        } else {
       //     helper.getRecordsBySearchTerm(component, event, helper);
        }
    },

    handleFocusIndexChange: function(component, event, helper) {
        var focusIndex = component.get('v.focusIndex');
        var lookupMenu = component.find('lookupMenu').getElement();

        if (!$A.util.isEmpty(lookupMenu)) {
            var options = lookupMenu.getElementsByTagName('li');
            var focusScrollTop = 0;
            var focusScrollBottom = 0;

            for (var i = 0; i < options.length; i++) {
                var optionSpan = options[i].getElementsByTagName('span')[0];

                if (i === focusIndex) {
                    $A.util.addClass(optionSpan, 'slds-has-focus');
                } else {
                    if (i < focusIndex) {
                        focusScrollTop += options[i].scrollHeight;
                    }

                    $A.util.removeClass(optionSpan, 'slds-has-focus');
                }
            }

            if (focusIndex !== null) {
                focusScrollBottom = focusScrollTop + options[focusIndex].scrollHeight;
            }

            if (focusScrollTop < lookupMenu.scrollTop) {
                lookupMenu.scrollTop = focusScrollTop;
            } else if (focusScrollBottom > lookupMenu.scrollTop + lookupMenu.clientHeight) {
                lookupMenu.scrollTop = focusScrollBottom - lookupMenu.clientHeight;
            }
        }
    },

})