({
    init: function(component, event, helper) {
        //helper.getInit(component, event);
        helper.getFolders(component, event);

        var channel = component.get("v.channel");
        var action = component.get("c.getQuickTextList");
        action.setParams({
            'channel' : channel
        });
        action.setCallback(this, result => helper.parse(component, result));
        $A.enqueueAction(action);

        helper.getRecentQuickTexts(component, event);
    },

    onInput : function(component, event, helper) {
        // Prevent action if selection is not allowed
        /*if (!helper.isSelectionAllowed(component)) {
            return;
        }*/
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
        console.log("onFocus");
        component.set('v.hasFocus', true);

        var recents = component.get("v.recentQuickTextWrapperList");
        console.log("recents", recents);
        component.set("v.searchResults", recents);
        // Prevent action if selection is not allowed
        /*if (!helper.isSelectionAllowed(component)) {
            return;
        }*/
        component.set('v.hasFocus', true);
    },

    onBlur : function(component, event, helper) {
        // Prevent action if selection is not allowed
        /*if (!helper.isSelectionAllowed(component)) {
            return;
        }*/
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
            //console.log('handleInputKeyUp KEYCODE_ENTER', event.currentTarget);
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

        var searchResults = component.get("v.searchResults");
        if (searchResults.length == 0) {
            return;
        }
        console.log('focusIndex', focusIndex);
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


    handleQuickTextMouseEnter : function(component, event, helper) {
        let quickTextSelectedId = event.target.id;
        console.log("quickTextSelectedId", quickTextSelectedId);
        
        let quickList = component.get("v.searchResults");
        let quickMessage = quickList.filter(quick => quick.quickText.Id === quickTextSelectedId);
        console.log("quickMessage", quickMessage);

        component.set("v.quickTextIdOnMouse", quickMessage[0].quickText.Message);
      /*  var popover = component.find("popupQuickText");
        console.log('handleQuickTextMouseEnter',popover);
        $A.util.removeClass(popover,'slds-hide');*/
    },

    //make a mouse leave handler here
    handleQuickTextMouseLeave : function(component, event, helper) {
       /* var popover = component.find("popupQuickText");
        console.log('handleQuickTextMouseLeave',popover);
        $A.util.addClass(popover,'slds-hide');*/
    }
})