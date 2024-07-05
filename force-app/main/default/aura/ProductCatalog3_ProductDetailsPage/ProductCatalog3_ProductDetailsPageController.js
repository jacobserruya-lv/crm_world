({

    updateProduct: function (component, event, helper) {
        var product = event.getParam('product');
        component.set('v.product', product);
        // console.log('Show here te mediom results', component.get("v.selectedZone"));
    }
})