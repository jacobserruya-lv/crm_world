({
    doInit: function(component, event, helper) {
        //Fire this event because Leather goods is selected by default
        var category = component.get("v.category");
        if(category ==""){
            category = "Hardsided leather goods";
        }
        component.set("v.category",category);

        var myEvent = $A.get("e.c:ProductFilterChange");
        myEvent.setParams({
            "searchKey" : "",
            "category"  : component.get("v.category"),
            "obsolete"  : ""
        });
        console.log("category params on ProductFilterChange event " + myEvent.getParam("category"));
        myEvent.fire();

        if (component.get("v.advancedSearch")) {
            helper.getProductCategoryList(component);
        }

        helper.initMTOEnabled(component);
    },

    searchKeyChange: function(component, event, helper) {
        helper.fireProductFilterChangeEvent(component);
    },

    // search the default Sku
    // MIY-1420 adding category param in order ther product will show on the page in case the category is other than Hardsided (which is the efault)
    setDefaultSku: function(component, event, helper) {
        var params = event.getParam('arguments');
        
        if (params) {
            var skuParam = params.sku;
            var categoryParam;

            switch (params.category) {
                case 'HARDSIDED':
                    categoryParam = 'Hardsided leather goods';
                    break;
                case 'BELTS':
                    categoryParam = 'Belts';
                    break;
                default:
                    categoryParam = 'Softsided leather goods';
            }
            component.set("v.searchKey", skuParam);
            component.set("v.category", categoryParam);
            helper.fireProductFilterChangeEvent(component);
        }
    },

    handleCollapse: function(cmp) {
        var section = cmp.find("filterSection");
        console.log(section);
        for (var i in section) {
            $A.util.toggleClass(section[i], 'slds-show');
            $A.util.toggleClass(section[i], 'slds-hide');
        }
    },

    changeMTO: function(cmp) {
            var isMTO = cmp.get("v.isMTO");
            isMTO = !isMTO;
            cmp.set("v.isMTO", isMTO);
        }
        /*,

        reset: function(component, event, helper) {
            component.set("v.searchKey", "");
            helper.fireProductFilterChangeEvent(component);
        }*/
})