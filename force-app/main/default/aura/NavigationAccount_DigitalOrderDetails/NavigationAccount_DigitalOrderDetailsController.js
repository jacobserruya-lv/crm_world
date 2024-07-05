({
    init: function(cmp, evt, helper) {
    
        var workspaceAPI = cmp.find("workspace"); 
        workspaceAPI.getEnclosingTabId()
        .then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: " Order"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:orders",
            })

         
        })
        .catch(function(error) {
                console.log(error);
         });

        var myPageRef = cmp.get("v.pageReference");
        var orderNumber = myPageRef.state.c__orderNumber;
        var orders = myPageRef.state.c__orders;
        var accountId = myPageRef.state.c__accountId;
           

        

        cmp.set("v.accountId", accountId);

        cmp.set("v.orderNumber", orderNumber);
     //   var ord = JSON.parse(orders);

        cmp.set("v.orders", orders);
    },

    
    handleClose: function(cmp, evt, helper) {
        /*var CloseClicked = evt.getParam('close');
        console.log(CloseClicked);
    
        var workspaceAPI = cmp.find("workspace"); 
        workspaceAPI.getEnclosingTabId()
        .then(function(response) {
            var focusedTabId = response.tabId;
          
            workspaceAPI.closeTab({tabId: focusedTabId});

        })
        .catch(function(error) {
                console.log(error);
         });*/
    }
})