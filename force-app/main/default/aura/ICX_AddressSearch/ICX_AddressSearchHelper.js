({
    
    checkLoginCountry : function (component) {
        // if the user is a user in China, don't show the Google Search
        var action = component.get("c.getCurrentUserLoginCountry");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                let countryResult = response.getReturnValue();
                console.log("checkLoginCountry success", countryResult);
                //component.set("v.isChinaUser", false);
                component.set("v.isChinaUser", (countryResult === 'CN') ? true : false);
            } else {
                // error message
                console.log('error', state);
            }
        });
        $A.enqueueAction(action);
    },

	sendItemSelected : function (component, address) {
       console.log("sendItemSelected > address", address);
       // https://developers.google.com/maps/documentation/geocoding/intro
       // FR : https://www.iso.org/obp/ui/fr/#iso:code:3166:FR
       let streetNumber, route, locality, postalCode, administrativeAreaLevel1, administrativeAreaLevel2, country;
       if (address.address_components) {
           for (var i = 0; i < address.address_components.length; i++) {
               var addressType = address.address_components[i].types[0];
           
               switch (addressType) {
                   case 'street_number' :
                       streetNumber = address.address_components[i];
                       console.log("streetNumber", streetNumber);
                       break;
                   case 'route' :
                       route = address.address_components[i];
                       console.log("route", route);
                       break;
                   case 'locality' :
                       locality = address.address_components[i];
                       console.log("locality", locality);
                       break;
                   case 'postal_code' :
                       postalCode = address.address_components[i];
                       console.log("postalCode", postalCode);
                       break;
                   case 'administrative_area_level_1' : // "long_name":"Centre","short_name":"Centre"
                       administrativeAreaLevel1 = address.address_components[i];
                       console.log("administrativeAreaLevel1", administrativeAreaLevel1);
                       break;
                   case 'administrative_area_level_2' : // "long_name":"Indre-et-Loire","short_name":"37"
                       administrativeAreaLevel2 = address.address_components[i];
                       console.log("administrativeAreaLevel2", administrativeAreaLevel2);
                       break;
                   case 'country' :
                       country = address.address_components[i];
                       console.log("country", country);
                       break;
               }
           }

       }

        // TODO: if China, get the ISO region code from Region__c.GoogleShortName__c field 
        //if ('CHN' === country) {
        //    // Apex call to get Region__c.GoogleShortName__c based on administrativeAreaLevel1
        //} else {
        //    
        //}

        const addressEvent = component.getEvent("addressEvent");
        console.log("addressEvent", addressEvent);
        if (!$A.util.isEmpty(addressEvent)) {
            addressEvent.setParams({
                "street_number": streetNumber,
                "route": route,
                "locality": locality,
                "postal_code": postalCode,
                "administrative_area_level_1": administrativeAreaLevel1,
                "administrative_area_level_2": administrativeAreaLevel2,
                "country": country
            });
            console.log("addressEvent2", addressEvent);
            addressEvent.fire();
        }
    },

    /*sendToVF : function(component, event) {
        var message = {
            search : component.get("v.searchKey"),
            language : 'en'//component.get("v.")
        };

        var vfOrigin = "https://" + component.get("v.vfHost");
        var vfWindow = component.find("vfFrame").getElement().contentWindow;

        console.log("sendto vf");
        vfWindow.postMessage(message, vfOrigin);
    },*/

    getVisualforceHost : function(component, event) {
        // call Apex controller
        var action = component.get("c.getVisualforceHost");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                console.log("response success", response.getReturnValue());
                component.set("v.vfHost", response.getReturnValue());
                
               // this.changeIframeUrl(component, event);
            } else {
                // error message
                console.log('error', state);
            }
        });
        $A.enqueueAction(action);
	},

    /*displayOptionsLocation: function (component, searchKey , Language) {

        var url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=" + searchKey + "&language=" + Language + "&key="
            + 'AIzaSyDUaBvh7ZQYO0xz-7V-t6gLHHkPeHUU7V0';
        //var url = 'https://maps.googleapis.com/maps/api/geocode/json?address=75+rue+du+commerce+75015+Paris' + "&key="
        //+ 'AIzaSyDUaBvh7ZQYO0xz-7V-t6gLHHkPeHUU7V0';

        console.log("url", url);
        var utils = component.find('utilsHttp');
        //Make Ajax request by calling method from utils component
        utils.callAjax("GET", url, true,
            function(xmlhttp) {
                console.log('xmlhttp:', xmlhttp);

                //Show response text if successful
                //Display error message otherwise
                if (xmlhttp.status == 200) {
                    console.log("Result", xmlhttp.responseText);
                    //component.set('v.msg', xmlhttp.responseText);
                    //component.set('v.msgSeverity', 'information');
                    //component.set('v.msgTitle', 'Success');
                } else if (xmlhttp.status == 400) {
                    console.log("There was an error 400");
                    //component.set('v.msg', 'There was an error 400');
                    //component.set('v.msgSeverity', 'error');
                    //component.set('v.msgTitle', 'Error');
                } else {
                    console.log("Something else other than 200 was returned");
                    //component.set('v.msg', 'Something else other than 200 was returned');
                    //component.set('v.msgSeverity', 'error');
                    //component.set('v.msgTitle', 'Error');
                }
            }
        );

        var action = component.get("c.getAddressAutoComplete");
        action.setParams({
           "input": searchKey,
           "langug": Language,
           "types": '(regions)'
       });

       action.setCallback(this, function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               console.log('response.getReturnValue()=' + JSON.stringify(response.getReturnValue()));

               var options = JSON.parse(response.getReturnValue());
               console.log("options", options);
               //var Addressdet = options.result;
               //console.log("Addressdet", Addressdet);
               component.set("v.filteredOptions", options);

               var key = "address_components";
               var o = Addressdet[key]  // value2
               for(var prop in o) {
                   console.log(prop,o[prop]);  
               }
             
               var key1="geometry";
               var o1=Addressdet[key1];
               var key2="location";
               var o2=o1[key2];



               var options = JSON.parse(response.getReturnValue());
               var predictions = options.predictions;
               var addresses = [];
               if (predictions.length > 0) {
                   for (var i = 0; i < predictions.length; i++) {
                       var bc =[];
                       for(var j=0;j<predictions[i].terms.length;j++){
                           bc.push(predictions[i].terms[j].offset , predictions[i].terms[j].value );
                           }
                       addresses.push(
                           {
                               value: predictions[i].types[0],
                               PlaceId: predictions[i].place_id,
                               locaval: bc,
                               label: predictions[i].description                              
                           });
                      
                   }
           
                   component.set("v.filteredOptionsdresses");
               }
           }
       });
       $A.enqueueAction(action);
   },
   sendSelectedOption:function(component,locaval2){
       
       var action1 = component.get("c.processWebResp");
       action1.setParams({
           "Res": locaval2
       });

       action1.setCallback(this, function (response) {
           
           var state = response.getState();
           if (state === "SUCCESS") {
               console.log('Thiswebservice resp >>');
               
           }
           
       });
       
       $A.enqueueAction(action1);
     
       
   },
   displayOptionDetails: function(component,event,placeid,PropId){
       var self = this;
        var action1 = component.get("c.getAddressDetails");
       action1.setParams({
           "PlaceId": placeid
       });

       action1.setCallback(this, function (response) {
           
          var state = response.getState();
           if (state === "SUCCESS") {
               console.log('response.getReturnValue()=' + JSON.stringify(response.getReturnValue()));
               var options = JSON.parse(response.getReturnValue());
               var Addressdet = options.result;
               var key = "address_components";
               var o = Addressdet[key]  // value2
               for(var prop in o) {
                   console.log(prop,o[prop]);  
               }
             
               var key1="geometry";
               var o1=Addressdet[key1];
               var key2="location";
               var o2=o1[key2];
              
               self.insertRecords(component,event,o,o2,PropId);                
           }
   
       });
       $A.enqueueAction(action1);
       
   },
   insertRecords:function(component,event,data,data1,PropId){
       
       for(var prop in data) {
           console.log(prop,data[prop]);  
       }
       var d=data;
       var d1=data1;
       var action1 = component.get("c.processWebResp");
       action1.setParams({
           "Res":JSON.stringify(d),
           "Res1":JSON.stringify(d1),
           "Res2": PropId
       });

       action1.setCallback(this, function (response) {
           
            var state = response.getState();
           if (state === "SUCCESS") {
               
           }
           
       });
       $A.enqueueAction(action1);
       
               
       
   },*/

   /*openListbox: function (component, searchKey) {
       var searchLookup = component.find("searchLookup");

       if (typeof searchKey === 'undefined' || searchKey.length < 2)
       {
           $A.util.addClass(searchLookup, 'slds-combobox-lookup');
           $A.util.removeClass(searchLookup, 'slds-is-open');
           return;
       }

       $A.util.addClass(searchLookup, 'slds-is-open');
       $A.util.removeClass(searchLookup, 'slds-combobox-lookup');
   },

   clearComponentConfig: function (component) {
       var searchLookup = component.find("searchLookup");
       $A.util.addClass(searchLookup, 'slds-combobox-lookup');

       component.set("v.selectedOptionll");
       component.set("v.searchKeyll");

       var iconDirection = component.find("iconDirection");
       $A.util.removeClass(iconDirection, 'slds-input-has-icon_right');
       $A.util.addClass(iconDirection, 'slds-input-has-icon_left');
   },*/
})