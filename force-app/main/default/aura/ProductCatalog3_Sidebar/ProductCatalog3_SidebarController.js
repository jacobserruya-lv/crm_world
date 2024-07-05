({
    closeSidebar : function(component) {
        component.set('v.open', false);
    },

    getFavProducts: function(cmp, event, helper){
        helper.getFavProducts(cmp, event, helper);
    }
})