({
    save : function(cmp) {
        console.log("save opp", cmp.get("v.opp"));
        console.log("save acc", cmp.get("v.account"));

        //var opp = cmp.get("v.opp");
        //opp.StageName = "Brief in progress";
        
        // TODO find on existing app which date to set
        //opp.CloseDate = new Date();
        
        //if (!opp.SPO_DisplayOrder__c) {
            // TODO upsert account
            // then insert opp with accountId
        //}

        //console.log("opp to save", opp);
        var briefFiles = cmp.get("v.briefFiles");
        console.log("briefFiles in SO_Opp Summary " + JSON.stringify(briefFiles));
        var dimensionsFiles = cmp.get("v.dimensionsFiles");
        console.log("dimensionsFiles in SO_Opp Summary " + dimensionsFiles.length);
        var listFiles = briefFiles.concat(dimensionsFiles);
        console.log("listFiles in SO_Opp Summary " + listFiles.length);
        var listFilesJSON = $A.util.json.encode(listFiles);
        var base64DataChar = listFilesJSON.base64Data;
        console.log("listFilesJSON base64DataChar in SO_Opp Summary " + base64DataChar);
        var buttonClicked = cmp.get("v.buttonClicked");
        console.log("This is button Clicked +" + buttonClicked);
        // for (f : listFiles){
        //     listFilesJSON.push($A.util.json.encode(f));
        // }
        // console.log(listFilesJSON);
        var toastParamsValidateRequest = {
            "title":"Success!",
            "type":"success",
            "message":"Success, your order has been sucessfully sent to the Ateliers"
        }

        var toastParamsValidate = {
            "title":"Success!",
            "type":"success",
            "message":"Success, your brief was successfully saved as draft"
        }

        var action = cmp.get("c.saveOppWithFiles");
        action.setParams({
            "opp" : cmp.get("v.opp"),
            "acc" : cmp.get("v.account"),
            "listFilesJSON": listFilesJSON,
            "buttonName":buttonClicked
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toast = $A.get("e.force:showToast");
                if(toast){
                    if(buttonClicked == "validate"){
                        toast.setParams(toastParamsValidate);
                        toast.fire(); 
                    } else {
                        toast.setParams(toastParamsValidateRequest);
                        toast.fire();
                    }
                    
                } else {
                    console.log("Toast event is not working here ");
                    var toastEvent = $A.get("e.c:SO_CustomToastEvent");
                    if(buttonClicked == "validate"){
                        toastEvent.setParams(toastParamsValidate);
                        toastEvent.fire(); 
                    } else {
                        toastEvent.setParams(toastParamsValidateRequest);
                        toastEvent.fire();
                    }
                }
                
                var responseStore = response.getReturnValue();
                console.log("responseStore", responseStore);
                cmp.set("v.buttonDisabled",true);
                this.navigate(responseStore.Id);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("ERROR", response);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        var toastParamsError = {
                            "title":"Error!",
                            "type":"error",
                            "message": errors[0].message
                        }
                        var toast = $A.get("e.force:showToast");
                        if (toast){
                            toast.setParams(toastParamsError);
                            toast.fire(); 
                        } else {
                            console.log("Toast event is not working here ");
                            toastEvent = $A.get("e.c:SO_CustomToastEvent");
                            toastEvent.setParams(toastParamsError);
                            toastEvent.fire(); 
                        }
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            var spinner = cmp.find("spinner");
                $A.util.toggleClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("spinner");
                $A.util.toggleClass(spinner, "slds-hide");
        $A.enqueueAction(action);   
        
    },

    navigate : function (oppId) {
        console.log("oppIdto navigate", oppId);
        // var navEvt = $A.get("e.force:navigateToSObject");
        // if (navEvt){
        //     navEvt.setParams({
        //         "recordId": oppId
        //         //"slideDevName": "related"
        //     });
        //     navEvt.fire();
        // } else {
        //     console.log("nope");
        // }

        // navigateToSObject does not work when inside a lightning app
        var urlEvent = $A.get("e.force:navigateToURL");
        if (urlEvent){
            urlEvent.setParams({
              "url": "/" + oppId
            });
            urlEvent.fire();
        } else {
            console.log("+++urlEvent is false");
            //window.location.href="/one/one.app#/sObject/" + oppId + "/view";
            // [Summer 18] URL below commented May 2 2018, replaced by event
            //window.location.href="/one/one.app#/alohaRedirect/" + oppId;
           /* //[Summer 18] event replacing window.location BUT does not work so workaround
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "isredirect": "true",
                "recordId": ""+oppId,
                "slideDevName": "detail"
            });
            navEvt.fire();*/
            //[Summer 18 workaround]
            window.location.href="/lightning/r/Opportunity/"+oppId+"/view";
        }
    },

    findOppById : function(component) {

        if ($A.util.isEmpty(component.get("v.recordId")) === false) {
            
            var action = component.get("c.findOppById");
            action.setParams({
                "oppId" : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseReturn = response.getReturnValue();
                    component.set("v.opp", responseReturn);
                    console.log("responseReturn", responseReturn);
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                
            });
            
            $A.enqueueAction(action);        
        }
	},
    /*fireOpportunitySPAEvent : function(component) {
        //Pass the values grabbed from this LC Form to the next child LC via Lightning Events:
        var appEvent = $A.get("e.c:SO_OpportunitySPAEvent");
        appEvent.setParams({
            "opp" : component.get("v.opp")
        });
        appEvent.fire();
    }*/
   
})