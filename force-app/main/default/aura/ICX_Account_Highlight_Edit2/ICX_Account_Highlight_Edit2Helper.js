({
    // Prepare a new record from template if the Record ID is empty
    loadNewRecord : function(component, event) {

        var helper = this;
        
        var taskRecordId = component.get("v.taskRecordId");
        console.log("taskRecordId > ", taskRecordId);
        console.log("simpleAccount > ", JSON.stringify(component.get("v.simpleAccount")));
        
        if ($A.util.isEmpty(component.get("v.recordId")) && !$A.util.isEmpty(taskRecordId)) {
            var action 	= component.get("c.getObjectDetail");
            action.setParams({
                "recordId" : taskRecordId
            });
            //action.setStorable();
            action.setCallback (this, function(response){
                var state = response.getState();
                if (state === 'SUCCESS') {
                    console.log("state", state);
                    var result =  response.getReturnValue();
                    console.log("result", result);
                    if (!$A.util.isEmpty(result)) {
                        if (!$A.util.isEmpty(result.Phone_Number__c)) {
                            component.set("v.taskPhoneNumber", result.Phone_Number__c);
                        }
                        console.log("email", result.SuppliedEmail);
                        if (!$A.util.isEmpty(result.SuppliedEmail)) {
                            component.set("v.suppliedEmail", result.SuppliedEmail);
                            //component.set("v.simpleAccount.PersonEmail", result.SuppliedEmail);
                        }
                    }
                    helper.loadRecord(component);
                }
            });
            $A.enqueueAction(action);
        } else {
            console.log("Account already exists");
            helper.loadRecord(component);
        }
    },
    
    loadRecord : function(component) {
        console.log("loadRecord");
        
        // get predefined values from RMS search for exemple (ICX_Flow_Account)
        var simpleAccount = component.get("v.simpleAccount");
        
        // Prepare a new record from template
        component.find("recordDataAccount").getNewRecord(
            "Account", // sObject type (entityAPIName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.account");
                var error = component.get("v.accountError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.sobjectType, simpleAccount);
                    //helper.findCallDetail(component);
                    if (!$A.util.isEmpty(simpleAccount)) {
                        //component.set("v.simpleAccount", simpleAccount);
                        component.set("v.simpleAccount.FirstName", simpleAccount.FirstName);
                        component.set("v.simpleAccount.LastName", simpleAccount.LastName);
                        component.set("v.simpleAccount.PersonMobilePhone", simpleAccount.PersonMobilePhone);
                        component.set("v.simpleAccount.SPO_Country_code__pc", simpleAccount.SPO_Country_code__pc);
                        component.set("v.simpleAccount.PrimaryZipCode__pc", simpleAccount.PrimaryZipCode__pc);
                        component.set("v.simpleAccount.PersonEmail", simpleAccount.PersonEmail);
                    }
                    // email from the record
                    if (!$A.util.isEmpty(component.get("v.suppliedEmail"))) {
                        component.set("v.simpleAccount.PersonEmail", component.get("v.suppliedEmail"));
                    }
                }
            })
        );
        
        console.log("loadRecord email",component.get("v.suppliedEmail"));
        console.log("loadRecord phone",component.get("v.taskPhoneNumber"));
    },

    linkCallToNewAccount : function (component){//, helper) {
        var newAccountId = component.get("v.recordId");
        var callRecordId = component.get("v.taskRecordId");
        
        console.log("linkCallToNewAccount > newAccountId", newAccountId);
        console.log("linkCallToNewAccount > callRecordId", callRecordId);

        if (!$A.util.isEmpty(newAccountId)) {
            // update object with account
            var caseService = component.find("caseService");
            console.log("caseService", caseService);
            caseService.updateObject(
                newAccountId,
                callRecordId,
                $A.getCallback(function(error, data) {
                    console.log("callback error", error);
                    console.log("callback data", data);
                })
            );
        }
    },

    saveAccount : function (component) {
        return new Promise(function (resolve, reject) {
            
           // var recId = component.get("v.recordId");
            //var helper = this;
            component.find("recordDataAccount").saveRecord($A.getCallback(function(saveResult) {
                // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful 
                // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // handle component related logic in event handler
                    console.log("success recordID", saveResult.recordId);
                    component.set("v.recordId", saveResult.recordId);
                    resolve(saveResult);
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                    reject(saveResult.error[0].message);
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                    //helper.handleError(component, saveResult.error[0].message);
                    reject(saveResult.error[0].message);
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    reject(saveResult.error[0].message);
                }
            }));
        });
    },

    handleOK: function(component, notifLib) {
        var resultsToast = $A.get("e.force:showToast");
        
        resultsToast.setParams({
            "title": "Saved",
            "message": "The record was updated.",
            "type": "success"
        });
        resultsToast.fire();

        var overlay = component.find("overlayLib");
        console.log("handle Ok > notifLib", notifLib);
        //var notif = (!$A.util.isUndefined(notifLib) ? notifLib : component.find('notifLib'));
        var notif = (!$A.util.isUndefined(overlay) ? overlay : notifLib);
        console.log("handle Ok > notif", notif);

        notif.notifyClose();
        //component.find("overlayLib").notifyClose();
	},

	handleError : function(component, error, notifLib) {
        console.log("handle ko > notifLib", notifLib);
        var notifLib2 = component.find('notifLib');
        var notif = (!$A.util.isUndefined(notifLib2) ? notifLib2 : notifLib);
        console.log("handle ko > notif", notif);
		notif.showNotice({
        //component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Error",
            "message": error
        });
    },

	getPicklistValue: function(component){
		var action= component.get("c.getPicklistOptions");
		action.setParams({account: component.get("v.simpleAccount")});
		action.setCallback(this, function(result){
			if(result.getState() === "SUCCESS"){
				var options = result.getReturnValue();
                console.log('options', options);
                component.set("v.salutationOpts",options.Salutation);
				component.set("v.genderOpts",options.Gender__pc);
				component.set("v.nationalityOpts",options.Nationality__pc);
				component.set("v.languageOpts",options.PreferredLanguage__pc);
				component.set("v.segmentationOpts",options.Ind_10K__c);
				component.set("v.typologyOpts",options.Typology__pc);
				component.set("v.phoneCountryCodeOpts",options.TECH_PhoneCountryCode__pc);
				component.set("v.countryCodeOpts",options.SPO_Country_code__pc);
                component.set("v.province",options.SPO_Primary_Province_State__pc);
				component.set("v.show", true);
			}
            this.getRegions(component);
            
		});
		$A.enqueueAction(action);
	},

    createPhone : function (component, event) {
        // For a new prospect, predefined the phone number if the phone number came from the Task Page layout
        var taskPhoneNumber = component.get("v.taskPhoneNumber");
        if (!$A.util.isEmpty(taskPhoneNumber)) {
            component.get("v.simpleAccount").PersonMobilePhone = taskPhoneNumber;
        }
        
        $A.createComponents([
            ["c:Account_PhoneFormatter",{
                "type" : "MOBILE",
                "title" : "Mobile",
                "countryCode" : component.get("v.simpleAccount").MobilePhoneCountryCode__pc,
                "localePhone" : component.get("v.simpleAccount").LocalMobilePhone__pc,
                "internationalPhone" : component.get("v.simpleAccount").PersonMobilePhone
            }],
            ["c:Account_PhoneFormatter",{
                "type" : "HOME",
                "title" : "Home",
                "countryCode" : component.get("v.simpleAccount").HomePhoneCountrycode__pc,
                "localePhone" : component.get("v.simpleAccount").LocalHomePhone__pc,
                "internationalPhone" : component.get("v.simpleAccount").PersonHomePhone
            }],
            ["c:Account_PhoneFormatter",{
                "type" : "WORK",
                "title" : "Work",
                "countryCode" : component.get("v.simpleAccount").WorkPhoneCountryCode__pc,
                "localePhone" : component.get("v.simpleAccount").LocalWorkPhone__pc,
                "internationalPhone" : component.get("v.simpleAccount").Phone
            }]
        ],
        function(components, status, errorMessage) {
        	if (status === "SUCCESS") {
            	var mobDiv = component.find("mobileDiv");
                mobDiv.set("v.body", components[0]);
            	var homeDiv = component.find("homeDiv");
                homeDiv.set("v.body", components[1]);
            	var workDiv = component.find("workDiv");
                workDiv.set("v.body", components[2]);
            }
        }
		);
    },

    fireHighlightEvent: function(component) {
        console.log("fireHighlightEvent");
        //var myEvent = $A.get("e.c:ICX_Account_Highlight_Event"); // component.getEvent("cmpEvent"); 
        var myEvent = $A.get("e.c:ICX_Account_Highlight_Event"); // component.getEvent("cmpEvent"); 
        //var myEvent = component.getEvent("cmpEvent");
		//console.log("myEvent", myEvent);
        myEvent.setParams({
            "recordId": component.get("v.recordId"),
            "currentRecordId": component.get("v.taskRecordId")
        });
        console.log("event", myEvent);
        myEvent.fire();
    },

    getCountry : function(component) {
        return new Promise(function (resolve, reject) {
            var account = component.get("v.simpleAccount");
            console.log("account > ", account);
            
            if (!$A.util.isEmpty(account.HomeAddressCountryCode__pc)) {
                var action 	= component.get("c.getCountry");
                action.setParams({
                    "iso3Code" : account.HomeAddressCountryCode__pc
                });
                action.setCallback (this, function(response){
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        console.log("state", state);
                        var result =  response.getReturnValue();
                        console.log("getCountry>result", result);
                        resolve(result);
                        
                        /*if (!$A.util.isEmpty(result)) {
                            let country = (!$A.util.isEmpty(result.Account__c) ? result.Account__c : result.PicklistValueSet__c);
                            console.log("country", country);
                            account.PrimaryCountry__pc = country;
                            account.SPO_Country__pc = country;
                            //component.set("v.account", account);
                        }*/
                    } else {
                        reject(response.error[0].message);
                    }
                });
                console.log("action getCountry", action);
                $A.enqueueAction(action);
            } else {
                // continue the transaction for this Promise
                resolve();
            }
        });
    },

    getRegions : function(component) {
        // TODO: uncomment when go prod for all LV systems to get China region code
            var countryCode = component.get("v.simpleAccount.HomeAddressCountryCode__pc");
            console.log("simpleAccount.HomeAddressCountryCode__pc", countryCode);
        
            if(component.get("v.simpleAccount.HomeAddressCountryCode__pc") == "CHN"){
                component.set("v.regionList", component.get("v.province"));
            }
            else{
                var action 	= component.get("c.getRegionList");
                action.setParams({
                    "iso3Country" : countryCode
                });
                action.setCallback (this, function(response){
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        var result =  response.getReturnValue();
                        console.log("getRegionList>result", result);
                        component.set("v.regionList", result);
                    }
                });
                $A.enqueueAction(action);
            }
       
    },

    validateCreationMandatoryFields: function(component, auraId) {
        console.log("validateCreationMandatoryFields>auraId", auraId);
        var validContact = true;

         // Show error messages if required fields are blank
        var allValid = component.find(auraId).reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        console.log("validateCreationMandatoryFields>allValid", allValid);
        if (allValid) {
            return(validContact);
        }  
    }

})