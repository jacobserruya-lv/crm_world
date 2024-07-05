({
    doInit : function(component, event, helper) {
        document.title = $A.get("$Label.c.LV_SO_Header_Creation");
        helper.searchSku(component);
        helper.getOrderSettings(component);
    },

    /*redirect: function (component){
        var orderSettings = component.get("v.orderSettings");//window.location.href; 
        console.log("orderSettings newbrief", orderSettings);

        // navigateToSObject does not work when inside a lightning app
        var urlEvent = $A.get("e.force:navigateToURL");
        if (urlEvent){
            urlEvent.setParams({
                "url": orderSettings.MakeItYoursAppUrl__c
            });
            urlEvent.fire();
        } else {
            console.log("nope");
            window.location.href = orderSettings.MakeItYoursAppUrl__c;
        }    
    },*/

    doCustomToast: function(component, evt, helper){
        console.log("===");
        var p = evt.getParams();
        component.set("v.toastType", p.type)
        component.set("v.toastTitle", p.title);
        component.set("v.toastMessage", p.message);
        component.set("v.showToast", true);
        console.log(p);
        window.setTimeout(function(){
            helper.closeToast(component);
        }, 5000);

    },

    closeToast: function(component, event, helper){
        helper.closeToast(component);
    }

})