({
    doInit: function(component, event, helper) {
        // Prepare a new record from template if the Record ID is empty
        var defaultNationality = {value: '', label:''};
        if ($A.util.isEmpty(component.get("v.recordId"))) {
            
            console.log("recordId empty", component.get("v.recordId"));
            defaultNationality.label = "Not communicated";
            defaultNationality.value = "777";
            helper.loadNewRecord(component, event);
        }
        component.set("v.defaultNationality" ,defaultNationality);
    },

    save: function (component, event, helper) {
        //var toast = $A.get("e.force:showToast");
        var callback;

        var notifLib = component.find('notifLib');
        var isNewRecord = $A.util.isEmpty(component.get("v.recordId"));
        if (isNewRecord && (!helper.validateCreationMandatoryFields(component, 'fieldId'))) {
			// ICX_Account_Highlight_Creation should see the error and hide the Spinner
            var params = event.getParam("arguments");
            if (params) {
                callback = params.callback;
                if (callback) callback(null, "err");
            }
            return;
        } else {
            var params = event.getParam("arguments");
            console.log("params error", JSON.stringify(params));
            if (params) {
                callback = params.callback;
            }
            
            //var promise = helper.saveAccount(component);
            var promise = helper.getCountry(component);
            promise.then($A.getCallback(function(result) {
                console.log("promise 1", result);
                
                var account = component.get("v.simpleAccount");
                if (!$A.util.isEmpty(result)) {
                    let country = (!$A.util.isEmpty(result.Account__c) ? result.Account__c : result.PicklistValueSet__c);
                    console.log("country", country);
                    
                    // Set country fields based on the selected country (SPO_Country_Code__pc)
                    account.PrimaryCountry__pc = country;
                    account.SPO_Country__pc = country;
                    account.SPO_Country_code__pc = account.HomeAddressCountryCode__pc;
                    account.SPO_Primary_Province_State__pc = account.PrimaryStateProvince__pc;
                    
                    //  component.set("v.account", account);
                } else {
                    account.PrimaryCountry__pc = null;
                    account.SPO_Country__pc = null;
                    account.SPO_Country_code__pc = null;
                    account.SPO_Primary_Province_State__pc = null;
                }
                
                if (isNewRecord) {
                    // Only CSC Users can create a prospect in Salesforce manually (otherwise, we should retrieve the current user to see his profile)
                    // <aura:attribute name="currentUser" type="User"/>
                    // <force:recordData aura:id="recordLoader" recordId="{!$SObjectType.CurrentUser.Id}"  fields="Profile.Name" targetFields="{!v.currentUser}"/>
                    account.Source__c = 'Manual';
                    if($A.util.isEmpty(account.Nationality__pc)){
                       account.Nationality__pc = 'NAT';
                       account.NationalityCountryCode__pc= '777';
                        
                    }
                    
                }
                
                return helper.saveAccount(component);
            }))
            //promise.then($A.getCallback(function(result) {
            .then($A.getCallback(function() {
                //var promise = helper.saveAccount(component);
                //promise.then($A.getCallback(function() {
                console.log("promise 2");
                
                return helper.linkCallToNewAccount(component);
            }))
            .then($A.getCallback(function() {
                console.log("Promise 3");
                helper.fireHighlightEvent(component);
                
                console.log("promise3 > isNewRecord" + isNewRecord);
                // only for new record / for update "Error in $A.getCallback() [notif.notifyClose is not a function]"
                if (isNewRecord) {
                    helper.handleOK(component, notifLib);     
                }
                
                if (callback) callback(component.get("v.recordId"), null);
            }))
            .catch($A.getCallback(function(err) {
                console.log('catch: ' + err);
                helper.handleError(component, err, notifLib);            
                
                if (callback) callback(null, err);
            }))
        }

    },

	handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log("eventParams.changeType", eventParams.changeType);
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            // record is changed, so refresh the component (or other component logic)
            helper.handleOK(component);
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
			helper.getPicklistValue(component);
            helper.getRegions(component);
			helper.createPhone(component);
            
            
            // Clear the Not Applicable (NA) value for China
            var acc = component.get("v.simpleAccount");
            if (acc.PrimaryStateProvince__pc === 'NA' && acc.SPO_Country_code__pc === 'CHN') {
                component.set("v.simpleAccount.PrimaryStateProvince__pc", null);
                component.set("v.simpleAccount.SPO_Primary_Province_State__pc", null);
            }

            /*var p = helper.findCallDetail2(component);
            p.then(function (response) {
                console.log("createPhone success", response);
                helper.createPhone(component);
            }).catch(function (err) {
                console.log("err", err);
            })*/
        } else if(eventParams.changeType === "REMOVED") {
            console.log("REMOVED>eventParams", eventParams);
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log("ERROR>eventParams", eventParams);
            // there’s an error while loading, saving or deleting the record
        }
    },

    phoneChanged: function(comp, event, helper) {        
        //console.log("phoneChanged Panel", event);

       	var type = event.getParam("type");
        var countryCode = event.getParam("countryCode");
        var localePhone = event.getParam("localePhone");
        var internationalPhone = event.getParam("internationalPhone");

        var account = comp.get("v.simpleAccount");
        if (type == "MOBILE") {
            account.MobilePhoneCountryCode__pc = countryCode;
            account.LocalMobilePhone__pc = localePhone;
            account.PersonMobilePhone = internationalPhone;
        } else if (type == "HOME") {
            account.HomePhoneCountrycode__pc = countryCode;
            account.LocalHomePhone__pc = localePhone;
            account.PersonHomePhone = internationalPhone;
        } else if (type == "WORK") {
            account.WorkPhoneCountryCode__pc = countryCode;
            account.LocalWorkPhone__pc = localePhone;
            account.Phone = internationalPhone;
        }

        //console.log("type", type);
        //console.log("countryCode", countryCode);
        //console.log("localePhone", localePhone);
        //console.log("internationalPhone", internationalPhone);
    },

    onCivilityChanged: function(comp, event, helper) {
        var salutation = comp.get("v.simpleAccount.Salutation");

        // update Gender
        if (salutation == '02' || salutation == '87'||salutation == '28M' ||salutation == 'SM') { // Mr or Sirs
            comp.set("v.simpleAccount.Gender__pc", "Male");
        } else if (salutation == '03' || salutation == '04' || salutation == '88' ||salutation == '28F' ||salutation == 'SF') { // Mrs or Ms or Ladies
            comp.set("v.simpleAccount.Gender__pc", "Female");
        } else if (salutation =='05' ) { 
            comp.set("v.simpleAccount.Gender__pc", "Netural");
        }else if (salutation =='00' ) { 
            comp.set("v.simpleAccount.Gender__pc", "Other");
        }
    },

    addressChanged : function(component, event, helper) {
        var streetNumber = event.getParam("street_number");
        var route = event.getParam("route");
        var locality = event.getParam("locality");
        var postalCode = event.getParam("postal_code");
        var administrativeAreaLevel1 = event.getParam("administrative_area_level_1");
        var administrativeAreaLevel2 = event.getParam("administrative_area_level_2");
        var countryISO2 = event.getParam("country");
        //var latitude = event.getParam("latitude");
        //var longitude = event.getParam("longitude");
        
        console.log("streetNumber", streetNumber);
        console.log("route", route);
        console.log("locality", locality);
        console.log("postalCode", postalCode);
        console.log("administrativeAreaLevel1", administrativeAreaLevel1);
        console.log("administrativeAreaLevel2", administrativeAreaLevel2);
        console.log("countryISO2", countryISO2);
        //console.log("latitude", latitude);
        //console.log("longitude", longitude);

        let account = component.get("v.simpleAccount");
        account.PrimaryAddressLine1__pc = (!$A.util.isEmpty(streetNumber) ? streetNumber.long_name + ' ' : '') + (!$A.util.isEmpty(route) ? route.long_name : '');
        //v.simpleAccount.PrimaryAddressLine2__pc
        //v.simpleAccount.PrimaryAddressLine3__pc
        account.PrimaryCity__pc = (!$A.util.isEmpty(locality) ? locality.long_name : '');
        account.PrimaryZipCode__pc = (!$A.util.isEmpty(postalCode) ? postalCode.long_name : '');
        account.PrimaryStateProvince__pc = (!$A.util.isEmpty(administrativeAreaLevel1) ? administrativeAreaLevel1.long_name : '');
        account.SPO_Primary_Province_State__pc = (!$A.util.isEmpty(administrativeAreaLevel1) ? administrativeAreaLevel1.long_name : '');
        account.PrimaryCity__pc = (!$A.util.isEmpty(locality) ? locality.long_name : '');
        //account.PrimaryCity__pc = (!$A.util.isEmpty(locality) ? locality : '');

        // Convert from ISO2 to ISO3 country code
        if (!$A.util.isUndefined(countryISO2) && !$A.util.isEmpty(countryISO2.short_name)) {
            var action 	= component.get("c.getCountryFromISO2");
            action.setParams({
                "iso2Code" : countryISO2.short_name
            });
            action.setCallback (this, function(response){
                var state = response.getState();
                if (state === 'SUCCESS') {
                    console.log("state", state);
                    var result =  response.getReturnValue();
                    console.log("getCountry>result", result);
                    
                    if (!$A.util.isEmpty(result)) {
                        let country = (!$A.util.isEmpty(result.Account__c) ? result.Account__c : result.PicklistValueSet__c);

                        // Set country fields based on the selected country (SPO_Country_Code__pc)
                        var account = component.get("v.simpleAccount");
                        account.PrimaryCountry__pc = country;
                        account.SPO_Country__pc = country;
                        account.SPO_Country_code__pc = result.Iso3Code__c;
                        account.HomeAddressCountryCode__pc = result.Iso3Code__c;
                        component.set("v.simpleAccount", account);
                        helper.getRegions(component);

                    }
                }
            });
            console.log("action getCountry", action);
            $A.enqueueAction(action);
        }
        //v.simpleAccount.PrimaryCountry__pc
        //v.simpleAccount.SPO_Country_code__pc
        component.set("v.simpleAccount", account);
        
    },

    getRegions : function(component, event, helper) {
        // clear the existing region
        component.set("v.simpleAccount.PrimaryStateProvince__pc", null);
        component.set("v.simpleAccount.SPO_Primary_Province_State__pc", null);

        // get regions of the selected country
        helper.getRegions(component);
        
    }
})