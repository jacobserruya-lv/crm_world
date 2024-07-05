({
    onFilterChange: function (component, event) {
        component.set('v.cleanSearch', event.getParam('searchKey') == '');
    },

})