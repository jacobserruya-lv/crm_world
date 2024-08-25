({
    doInit : function(component, event, helper) {
        helper.getFiche(component, event, helper);
        helper.environmentalSectionCountryFilter(component, event, helper);
    },

    getFiche: function(cmp, event, helper) {
        event.stopPropagation();
        var cookie = $A.get("$Label.c.ProductCatalogPdfCookie");
        var Link = cmp.get('v.pdfLink');
        Link = Link+'?'+cookie;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": Link,
        });
        urlEvent.fire();
    }, 
})