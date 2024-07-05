({
    init: function(cmp, evt, helper) {
 
        var myPageRef = cmp.get("v.pageReference");
        var accountId = myPageRef.state.c__accountId;
        var parentTabId = myPageRef.state.c__focusTabId;

        cmp.set("v.accountId", myPageRef.state.c__accountId);
        cmp.set("v.dreamAccountClient", myPageRef.state.c__dreamAccountClient);
        cmp.set("v.moreClientInfo", myPageRef.state.c__moreClientInfo);
        cmp.set("v.moreClientInfoSF", myPageRef.state.c__moreClientInfoSF);
        cmp.set("v.isProductDetails", myPageRef.state.c__isProductDetails);
      

        var workspaceAPI = cmp.find("workspace"); 


        if( cmp.get("v.dreamAccountClient"))
        {
    
            
        workspaceAPI.getEnclosingTabId()
        .then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: myPageRef.state.c__accountName
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:account",
            })
            
            
        })
        .catch(function(error) {
            console.error(error);
        });
    
        }

        if( cmp.get("v.moreClientInfo"))
        {

            workspaceAPI.getAllTabInfo().then(function(response) {
                workspaceAPI.getEnclosingTabId()
                .then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: myPageRef.state.c__label
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "standard:account_info",
                    })
                    
                    
                })
                .catch(function(error) {
                    console.log(error);
                });
            })
                .catch(function(error) {
                console.log(error);
            });
        }

        if( cmp.get("v.moreClientInfoSF"))
        {
            workspaceAPI.getEnclosingTabId()
            .then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: myPageRef.state.c__label
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "standard:account_info",
                })
    
             
            })
            .catch(function(error) {
                    console.log(error);
             });
        }
        

        if( cmp.get("v.isProductDetails"))
        {
            workspaceAPI.getEnclosingTabId()
            .then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: myPageRef.state.c__label
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "standard:buyer_account",
                })
    
             
            })
            .catch(function(error) {
                    console.log(error);
             });
        }

    },

})