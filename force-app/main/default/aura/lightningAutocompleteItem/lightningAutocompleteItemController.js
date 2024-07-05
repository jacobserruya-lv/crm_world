({
    handleItemClick: function (component) {
        // console.group(component.getType() + '.handleItemClick');
        component.set('v.selectedValue', component.get('v.value'));
        // console.groupEnd();
    },
})