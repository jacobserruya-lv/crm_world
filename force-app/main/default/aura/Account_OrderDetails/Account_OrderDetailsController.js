({
    onInit : function(component, event, helper) {
       
         helper.getOrderLineDetails(component, event, helper) ;
         helper.isBackOfficeUser(component, event, helper) ;
         helper.getPicklistShipping(component, event, helper) ;
         helper.getActionPicklist(component, event, helper) ;
        
    },
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    reloadComponent: function(component, event, helper) {
       debugger;
       console.log( JSON.parse(JSON.stringify( event.getParam("OrderDetails"))));
       var result = event.getParam("OrderDetails");
       var message = event.getParam("OrderNumber");
        if(message === component.get("v.details").OrderId){
            result.orderLines.forEach(element => element.statusHistory.reverse());
            component.set("v.details", result);
        }
        
    }

})