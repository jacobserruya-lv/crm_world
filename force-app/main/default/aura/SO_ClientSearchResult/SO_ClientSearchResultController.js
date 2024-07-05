({
    filterChange: function(component, event, helper) {
        component.set("v.lastname", event.getParam("lastname"));
        component.set("v.firstname", event.getParam("firstname"));
        component.set("v.email", event.getParam("email"));
        component.set("v.phone", event.getParam("phone"));
        component.set("v.passport", event.getParam("passport"));
        component.set("v.country", event.getParam("country"));
        component.set("v.postalcode", event.getParam("postalcode"));
        component.set("v.storeCode", event.getParam("storeCode"));
        component.set("v.isRmsSearch", event.getParam("isRmsSearch"));
        component.set("v.isCustomerServiceView", event.getParam("isCustomerServiceView"));
        component.set("v.dreamId", event.getParam("dreamId"));

        helper.getClients(component);
	},

    pageChange: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        var direction = event.getParam("direction");
        page = direction === "previous" ? (page - 1) : (page + 1);

        helper.getClientsByPage(component, page);
	},

   /* // spinner used by aura:waiting and aura:doneWaiting events
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, "slds-hide");
    },
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, "slds-hide");
    },*/

    clientSelected : function(component, event) {

        var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.index; // Get its value i.e. the index

        if (component.get("v.isRmsSearch") == true) {
            var rmsClient = component.get("v.clientRmsList")[index];
            console.log('rmsClient', rmsClient);
            //var clientSalesforce = component.get("v.clients")[index];
            //console.log("clientSalesforce", clientSalesforce);
            
            // use for 'slds-is-selected' CSS (display the client selected)
            component.set("v.clientRmsSelected", rmsClient.RMSId);
            //        component.set("v.clientRmsSelected", rms);
            
            /*var account = {"sobjectType": "Account",
                           "LastName": rmsClient.LastName,
                           "FirstName": rmsClient.FirstName,
                           "RMSId__pc": rmsClient.RMSId,
                           "WW_RMSId__c": rmsClient.WWRmsClientCode
                          };*/

            var client = component.get("v.clients")[index];
            client.RMSId__pc = rmsClient.RMSId;
            client.WW_RMSId__c = rmsClient.WWRmsClientCode;
            if (client.DREAMID__c == '0') {
                client.DREAMID__c = null;
            }
            console.log('client', client);

            var cmpEvent = component.getEvent("clientEvent");                
            cmpEvent.setParams({
                "account": client
            });
            cmpEvent.fire();
        } else {
            var clientSalesforce = component.get("v.clients")[index];
            console.log('clientSalesforce', clientSalesforce);
            
            // use for 'slds-is-selected' CSS (display the client selected)
            component.set("v.clientSalesforceSelected", clientSalesforce.Id);
            
            var cmpEvent2 = component.getEvent("clientEvent");                
            cmpEvent2.setParams({
                "account": clientSalesforce
            });
            cmpEvent2.fire();
        }

/*
		var client = component.get("v.client");
        var myEvent = $A.get("e.ltng:selectSObject");
        myEvent.setParams({"recordId": client.Id, channel: "Clients"});//, "account" : rms});
        myEvent.fire();*/
    },


	onMouseMove: function(component, event, helper) {
        console.log("onMouseMove.target", event.target);
        /* console.log("onMouseMove.currentTarget", event.currentTarget);
        console.log("isSearchRMS", component.get("v.isRmsSearch"));
         console.log("isCustomerServiceView", component.get("v.isCustomerServiceView"));*/
        if (component.get("v.isCustomerServiceView")) {
           // console.log("event", event);
            if (event.target === event.currentTarget) return;
           // console.log("target");
            var el = event.target;
            while (el && (!el.dataset || !el.dataset.index)) {
                el = el.parentElement;
            }
            //console.log("el", JSON.stringify(el));
            if (el) {
                //var clients = (component.get("v.isRmsSearch") ? component.get("v.clientRmsList") : component.get("v.clients"));
                var clients = component.get("v.clients");
                //console.log("event", event);
               	console.log("el.offsetTop", el.offsetTop);
                console.log("el.offsetLeft", el.offsetLeft);
                console.log("el.clientLeft", el.clientLeft);
                console.log("event.pageX", event.pageX);
                console.log("event.clientX", event.clientX);
                console.log("el.scrollLeft", el.scrollLeft);
                
                component.find("popup").showPopup(clients[el.dataset.index], el.offsetLeft - 10, el.offsetTop, component.get("v.isCustomerServiceView"));
                //var popover = component.find("popup");
                //console.log('handleMouseEnter',popover);
                //$A.util.removeClass(popover,'slds-hide');
                //component.find("popup").showPopup(clients[el.dataset.index], event.clientX - 920, el.offsetTop - 46 - 565);
                //component.find("popup").showPopup(clients[el.dataset.index], event.clientX + 20, el.offsetTop - 46 - 565);
                //component.find("popup").showPopup(clients[el.dataset.index], el.clientX + 20 - 920, el.offsetTop - 46 - 565);
            }
        }
        
    },

    onMouseLeave: function(component, event, helper) {
        console.log("onMouseLeave");
        if (component.get("v.isCustomerServiceView")) {
            if (event.target === component.find("list").getElement()) {
                component.find("popup").hidePopup();    
                //var popover = component.find("popup");
                //$A.util.addClass(popover,'slds-hide');
            }
        }
    }
})