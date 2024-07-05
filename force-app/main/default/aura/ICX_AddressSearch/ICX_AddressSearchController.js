({
    doInit : function(component, event, helper) {
        var hostname = window.location.hostname;
        component.set('v.lightningHost', hostname);
        //var arr = hostname.split(".");
        //var instance = arr[0];
        //console.log("hostname LC", hostname);
        //console.log("instance LC", instance); // http://louisvuitton--c.na46.visual.force.com

        helper.checkLoginCountry(component);
        helper.getVisualforceHost(component, event);
        
        window.addEventListener("message", function(event) {
            // https://louisvuitton--iconics--c.cs70.visual.force.com
            //console.log("event.origin", event.origin);            
            //if (event.origin.indexOf(ciscoEndUrl) === -1) {
            //if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
            //    return;
            //}
            // Handle the message
            console.log(JSON.stringify(event.data));
            
            if (!$A.util.isUndefined(event.data)) {
                if (event.data.focus) {
                    console.log("Focus/event.data.size", true, event.data.height);
                    component.set("v.iframeHeight", event.data.height);
                   // if (event.data.size && event.data.size)
                } else {//if (!event.data.focus){
                    component.set("v.iframeHeight", "2.5rem;");
                }
                
                if (event.data.type === 'Place') {
                    helper.sendItemSelected(component, JSON.parse(event.data.address));
					//component.set("v.iframeHeight", "2.5rem;");
				}
            }
        }, false);

    },

    /*scriptsLoaded: function (component, event, helper) {
        console.log("Google API JS Loaded");

      ///  var input = document.getElementById("ddd");//component.find("prptext3");//.getElement();//get("v.value");//var discount = component.find("AURA-ID");
      //  var autocomplete = new google.maps.places.Autocomplete(input);
        
        var autoCompleteOne = new google.maps.places.Autocomplete(
            (document.getElementById('autocomplete_one')),
            { types: ['geocode'] });
        
        // When the user selects an address from the dropdown,
        // populate the address fields in the form.
        google.maps.event.addListener(autoCompleteOne, 'place_changed', function() {
            console.log();
            //fillInAddress('one');
            console.log("PLACE", autoCompleteOne.getPlace());
        });

    },
    loadOptions: function (component, event, helper) {
        var opts = [
            { value: "de", label: "German" },
            { value: "es", label: "Spanish" },
            { value: "ta", label: "Tamil" },
            { value: "en", label: "English" }
        ];
        component.set("v.options");
    },*/
    /*handleSelect : function(component, event, helper) {
        console.log("handleSelect");
        console.log("event.target", event.target.dataset.record);
        console.log("event.currentTarget", event.currentTarget.dataset.index);
        
        var selectedRecord = component.get("v.filteredOptions")[event.currentTarget.dataset.index];
        console.log("handleSelect>selectedRecord", selectedRecord);
        
        component.set("v.searchKey", selectedRecord.formatted_address);

        var searchLookup = component.find("searchLookup");
        //$A.util.addClass(searchLookup, 'slds-combobox-lookup');
        $A.util.removeClass(searchLookup, 'slds-is-open');

        helper.sendItemSelected(component, selectedRecord);
        //var selected = event.getSource().get("v.record");
    },
    
    onBlur : function(component, event, helper) {
        // Delay hiding combobox so that we can capture selected result
        const blurTimeout = window.setTimeout(
            $A.getCallback(() => {
                //component.set('v.hasFocus', false);
                component.set('v.blurTimeout', null);
                var searchLookup = component.find("searchLookup");
                $A.util.removeClass(searchLookup, 'slds-is-open');
            }),
            300
        );
        component.set('v.blurTimeout', blurTimeout);
    },
    
    keyPressController: function (component, event, helper) {
        
        var prpAct2=component.find("prptext3");
        var prpActVal2 = prpAct2.get("v.value");
        prpAct2.set("v.errors", null);
        var searchKey = component.get("v.searchKey");
        var Language = component.get("v.selectedValue");


        // Ignore search terms that are too small
        if (typeof searchKey === 'undefined' || searchKey.length < 2) {
            helper.openListbox(component, searchKey);
            component.set('v.filteredOptions', []);
            return;
        }
        
        // Apply search throttling (prevents search if user is still typing)
        let searchTimeout = component.get('v.searchThrottlingTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        searchTimeout = window.setTimeout(
            $A.getCallback(() => {
                // Send search event if it long enougth
                //const searchTerm = component.get('v.searchTerm');
                if (searchKey.length >= 2) {
                    //const searchEvent = component.getEvent('onSearch');
                    //searchEvent.fire();
                    helper.openListbox(component, searchKey);
               		helper.sendToVF(component, event);
                //helper.displayOptionsLocation(component, searchKey,Language);
                }
                component.set('v.searchThrottlingTimeout', null);
            }),
            300
        );
        component.set('v.searchThrottlingTimeout', searchTimeout);
    },
    clear: function (component, event, helper) {
        helper.clearComponentConfig(component);
    },

	sendToVF : function(component, event, helper) {
        helper.sendToVF(component, event);
    }*/

})