({
	populateOptions : function(component, event, helper) {
        var items = [];
        var action = component.get("c.getCountryPhoneCodes");
    	action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
               var values = response.getReturnValue();
               for(var i = 0; i < values.length; i++){
                    var item = {
                        "label": values[i].CountryCallingCode__c,
                        "value": values[i].CountryCallingCode__c
                    };
                    items.push(item);
                    if(values[i].DeveloperName == component.get("v.countryCode")){
                       component.set("v.CurrentSelection", values[i]);
                       component.set("v.value", item.value);
                     }
                }
                component.set("v.Selection", values);
                component.set("v.options", items);
            }
    	});
        $A.enqueueAction(action);
		
	},
    setInternationalPhone:function(component,phone) {
    	var internationalPhone='';
    	internationalPhone = internationalPhone.concat(component.get("v.CurrentSelection").CountryCallingCode__c ,phone)
        component.set("v.internationalPhone",internationalPhone);
	}	
})