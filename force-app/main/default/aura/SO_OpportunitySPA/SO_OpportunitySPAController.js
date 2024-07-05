({
    doInit : function(component) {
        
        // Hide both account, product and confirm child Components on init:        
        /*var toggleText = component.find("personalizationDiv");
        $A.util.addClass(toggleText,'toggle');       

        toggleText = component.find("accountDiv");
        $A.util.addClass(toggleText,'toggle');
        
        toggleText = component.find("summaryDiv");
        $A.util.addClass(toggleText,'toggle');*/
    },

    handleClickOnTab : function(component, event) {
        // "action" attribute gives the current action compared to the target action
        // maybe use aura:method for SPAClient, SPAProduct, SPAPerso to use existing newt(), back() actions with mandatory fields
        var selectedItem = event.currentTarget; // Get the target object
        //console.log(selectedItem);
        var itemClass = selectedItem.getAttribute("class");
        var tab = selectedItem.getAttribute("data-index");

        if (itemClass.indexOf("slds-is-current") !== -1){
            //console.log("current");
            return;
        }

        var action = null;
        //console.log(tab);
        if (itemClass.indexOf("slds-is-complete") !== -1){
            //console.log("go back");
            action = "back";
        }
        else {
            //console.log("incomplete");
            action = "next";
        }

        console.log("tab", tab);
        console.log("action", action);
        if (!$A.util.isEmpty(tab) && !$A.util.isEmpty(action)) {
            //helper.fireJumpToEvent(component, tab, action);
            if (action == 'back' && tab == 0) {
                var customizeComponent = component.find("perso");
                if (customizeComponent) {
                    customizeComponent.previous();
                }
            }
            else if (action == 'next' && tab == 1) {
                var productComponent = component.find("productComponent");
                if (productComponent) {
                    console.log("next prod");
                    productComponent.next();
                }
            }
            else if (action == 'back' && tab == 1) {
                var clientComponent = component.find("clientSearch");
                if (clientComponent) {
                    clientComponent.previous();
                }
            }
            else if (action == 'next' && tab == 2) {
                var customizeComponent = component.find("perso");
                if (customizeComponent) {
                    customizeComponent.next();
                }
            }
            else if (action == 'back' && tab == 2) {
                var summaryComponent = component.find("summary");
                if (summaryComponent) {
                    summaryComponent.previous();
                }
            }
            else if (action == 'next' && tab == 3) {
                var clientComponent = component.find("clientSearch");
                if (clientComponent) {
                    clientComponent.next();
                }
            }
        }
    },
    
    handleApplicationEvent : function(component, event) {
        var params = event.getParams();
        //console.log("params", params);
        if (params.channel !== "Init") {
            component.set("v.opp", params.opp);
        }

        if (params.channel === "Product") {
            component.set("v.product", params.product);
        }

        //if (params.channel === "Personalization") {
        //}
        if (params.channel === "Account") {
            component.set("v.account", params.account);
            component.set("v.store", params.store);
        }
    },

    /*handleClientSelected : function(component, event, helper) {
        var params = event.getParams();
        //component.set("v.account", params.account);
    },

    handleProductSelected : function(component, event, helper) {
        var params = event.getParams();
        //component.set("v.product", params.product);
    },*/

    handleBubbling : function(component, event, helper) {

        //var lastAction = component.get("v.action");
        //component.set("v.lastAction", lastAction);

        var params = event.getParams();
        var navigateAction = params.componentAction;
        component.set("v.action", navigateAction);

        //helper.handleBubbling(component, navigateAction);
        console.log("navigateAction: " + navigateAction);
                
        // Based on the name of the component to hide received in the Bubble event use CSS to hide the current child LC and unhide the next child LC:
        switch (navigateAction) {
            case "Product_Next":
                //if (this.productValidation(component)) {
                    //component.set("v.action", navigateAction);
                helper.next(component, "personalizationDiv", "productDiv", "personalizationIndicator", "productIndicator");
                //}                
                break;

            case "Personalization_Back":
                helper.back(component, "productDiv", "personalizationDiv", "productIndicator", "personalizationIndicator");

                helper.incomplete(component, "personalizationDiv", "personalizationIndicator");
                helper.incomplete(component, "accountDiv", "accountIndicator");
                helper.incomplete(component, "summaryDiv", "summaryIndicator");
                break;

            case "Personalization_Next":
                helper.next(component, "accountDiv", "personalizationDiv", "accountIndicator", "personalizationIndicator");                

                helper.complete(component, "productDiv", "productIndicator");
                helper.complete(component, "personalizationDiv", "personalizationIndicator");
                //this.complete(component, "accountDiv", "accountIndicator");
                break;

            case "AccountSearch_Back":
                helper.back(component, "personalizationDiv", "accountDiv", "personalizationIndicator", "accountIndicator");                
                helper.incomplete(component, "summaryDiv", "summaryIndicator");
                helper.incomplete(component, "accountDiv", "accountIndicator");
                break;

            case "AccountSearch_Next":
                //if (this.clientValidation(component)) {
                    //component.set("v.action", navigateAction);
                helper.next(component, "summaryDiv", "accountDiv", "summaryIndicator", "accountIndicator");                
                
                helper.complete(component, "productDiv", "productIndicator");
                helper.complete(component, "personalizationDiv", "personalizationIndicator");
                helper.complete(component, "accountDiv", "accountIndicator");
                //}
                break;

            case "Summary_Back":
                helper.back(component, "accountDiv", "summaryDiv", "accountIndicator", "summaryIndicator");    
                break;
        }
    }
})