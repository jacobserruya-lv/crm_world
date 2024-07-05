({
    handleItemClick: function (component) {
        // console.group(component.getType() + '.handleItemClick');
        component.set('v.isExpanded', false);
        // console.groupEnd();
    },
    handleInputChange: function (component, event) {
        // console.group(component.getType() + '.handleInputChange');

        var nonEmptyMenu = (component.get('v.options').length > 0 || component.get('v.spinnerActive'));
        if (event.getParam('value') != null && nonEmptyMenu) {
            component.set('v.isExpanded', true);
        }
        // console.groupEnd();
    },
    handleInputFocus: function (component) {
        // console.group(component.getType() + '.handleInputFocus');
        if (component.get('v.inputValue') != null && (component.get('v.options').length > 0)) {
            component.set('v.isExpanded', true);
        }
        // console.groupEnd();
    },
    handleInputBlur: function (component) {
        // console.group(component.getType() + '.handleInputBlur');
        if (!component.get('v.isOverDropdown')) {
            component.set('v.isExpanded', false);
        }
        // console.groupEnd();
    },
    handleOptionsChange: function (component, event) {
        // console.group(component.getType() + '.handleOptionsChange');
        if (event.getParam('value').length == 0) {
            component.set('v.isExpanded', false);
        }
        // console.groupEnd();
    },
    clearInput: function (component) {
        component.set('v.inputValue', null);
    },
    handleMouseEnter: function (component) {
        // console.group(component.getType() + '.handleMouseEnter');
        component.set('v.isOverDropdown', true);
        // console.groupEnd();
    },
    handleMouseLeave: function (component) {
        // console.group(component.getType() + '.handleMouseLeave');
        component.set('v.isOverDropdown', false);
        // console.groupEnd();
    },

})