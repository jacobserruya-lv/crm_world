({
	getClients : function(component, page) {

        var clientData = {
            "lastName": 		component.get("v.lastname"),
            "firstName": 		component.get("v.firstname"),
            "email": 			component.get("v.email"),
            "phoneNumber": 		component.get("v.phone"),
            "passportNumber": 	component.get("v.passport"),
            "country": 			component.get("v.country"),
            "zipCode": 			component.get("v.postalcode"),
            "storeCode":		component.get("v.storeCode"),
            "dreamId":			component.get("v.dreamId")
            
            //"givenName": 		?
            //"dreamId":		?
        };

        var isRmsSearch = component.get("v.isRmsSearch");
        console.log("isRmsSearch", isRmsSearch);
        //  action = component.get("c.findAll");
        var action = (isRmsSearch == true ? component.get("c.findAll") : component.get("c.findAllInSalesforce"));
        console.log("action", JSON.stringify(action));

        var pageSize = component.get("v.pageSize");
        
        // Call RMS webservice is filter changed (or if the page is not changed), otherwise just get a sublist from the last RMS call
        var callRms = page ? false : true;
        console.log('clientData', clientData);

        if (isRmsSearch == true) {
            action.setParams({
                //"clientJson":	$A.util.json.encode(clientData), // method not working when LockerService activated
                "clientJson":	JSON.stringify(clientData), // TODO LockerService convert json to 'SO_Util.SearchClientData' Apex Type in Apex Controller
                "pageSize": 	pageSize,
                "pageNumber": 	page || 1,
                "callRms":		callRms//component.get("v.callRms") || false
            });
        } else {
            action.setParams({
                "clientJson":	JSON.stringify(clientData),
                "pageSize": 	pageSize,
                "pageNumber": 	page || 1
            });
        }
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            
            if (state === "SUCCESS") {
                var result = a.getReturnValue();
                console.log("json>result", JSON.stringify(result));
                
                component.set("v.clients", result.sobjects); // SF search
                //component.set("v.clientRmsList", result.clientRmsList);
                component.set("v.clientRmsList", (!$A.util.isEmpty(result.clientRmsList) ? JSON.parse(result.clientRmsList) : null)); // RMS search (null if Salesforce search)
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total/pageSize));
                
                // for Salesforce search, don't predefined a value for Page Next or Previous
                if (isRmsSearch == true) {
                    component.set("v.startIndexClientList", 0);
                }
                
                //getClientsByPage(component);
            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('error', errors[0].message);
                        // Display toast message to indicate status
                        var toastParams = {
                            "type": "error",
                            // "mode": "sticky",
                            "title": "Error!",
                            "message": errors[0].message
                        };
                        var toastEvent = $A.get("e.force:showToast");
                        if (toastEvent) {
                            toastEvent.setParams(toastParams);
                            
                            toastEvent.fire();
                        } else {
                            toastEvent = $A.get("e.c:SO_CustomToastEvent");
                            toastEvent.setParams(toastParams);
                            toastEvent.fire();
                        }
                    }
                } else {
                    console.log("Unknown error");
                }
            }

            /*window.setTimeout(
                $A.getCallback(function() {
                    console.log("timeout reached");
                }), 2000
            );*/

            var spinner = component.find("spinner"); // replace by events (aura:waiting, aura:doneWaiting)
            $A.util.toggleClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
        
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
	},

    // building the sub-list to display X clients per page
	getClientsByPage : function(component, page) {
        var pageSize = component.get("v.pageSize");

        component.set("v.page", page || 1);
        component.set("v.startIndexClientList", (page-1) * pageSize);
        
        // call Salesforce in Salesforce search pagination
        if (component.get("v.isRmsSearch") == false) {
            this.getClients(component, page);
        }
    }
})