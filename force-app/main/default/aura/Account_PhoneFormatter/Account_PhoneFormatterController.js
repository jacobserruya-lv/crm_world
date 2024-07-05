({
    afterScriptsLoaded: function(component, event, helper) {
        //console.log("component.get(v.countryCode)", component.get("v.countryCode"));
        var inputId = "intlTelPhone" + component.get("v.title");
        component.set("v.titleId", inputId);

        //var phone = jQuery("#intlTelPhone");
        var phone = jQuery('#' + component.get("v.titleId"));
        phone.intlTelInput({
            // allowDropdown: false,
            // autoHideDialCode: false,
            autoPlaceholder: "off", // placeholder is confusing for users
            // dropdownContainer: "body",
            // excludeCountries: ["us"],
            // formatOnDisplay: false,
            // geoIpLookup: function(callback) {
            //   $.get("http://ipinfo.io", function() {}, "jsonp").always(function(resp) {
            //     var countryCode = (resp && resp.country) ? resp.country : "";
            //     callback(countryCode);
            //   });
            // },
            // hiddenInput: "full_number",
            // initialCountry: "auto",
            //nationalMode: true,
            // onlyCountries: ['us', 'gb', 'ch', 'ca', 'do'],
            // placeholderNumberType: "MOBILE",
            // preferredCountries: ['cn', 'jp'],
            // separateDialCode: true,
            //utilsScript: $A.get('$Resource.PhoneFormatter') + '/js/phoneformatter.js'
        });
        
        /*var phoneJs = $A.get('$Resource.PhoneFormatter') + '/js/phoneformatter.js';
        jQuery.fn.intlTelInput.loadUtils(phoneJs);*/
        
        // listen to the telephone input for changes
        phone.on("countrychange", function(e, countryData) {
            if (!$A.util.isUndefined(countryData) && !$A.util.isEmpty(countryData.iso2)) {
                component.set("v.countryCode", countryData.iso2.toUpperCase());
            }
            //helper.handleClick(component, event);
            //helper.reset(component, event);
            //helper.handleCountry(component, event);

        });

        var internationalPhone = component.get("v.internationalPhone");
        if (!$A.util.isEmpty(internationalPhone)) {
            phone.intlTelInput("setNumber", internationalPhone);
            //var intlNumber = phone.intlTelInput("getNumber");
            //console.log('intlNumber', intlNumber);

            var intlNumber = phone.intlTelInput("getNumber");
            if (intlNumber === internationalPhone) { // If international phone givent is a real international phone
                var countryData = phone.intlTelInput("getSelectedCountryData");
                component.set("v.countryCode", countryData.iso2.toUpperCase());
            } else {
                // set the country flag
                var countryCode = component.get("v.countryCode");
                if (!$A.util.isEmpty(countryCode)) {
                    phone.intlTelInput("setCountry", countryCode);
                } else {
                    phone.intlTelInput("setCountry", "");                    
                }
            }
            
        } else {
            // 1 flag, 1 phone => default flag
            // 1 flag, no phone => default flag
            // no flag, 1 phone => empty flag
            // no flag, no phone => User flag
            var localePhone = component.get("v.localePhone");
            if (!$A.util.isEmpty(localePhone)) {
                phone.intlTelInput("setNumber", localePhone);
            }

            var countryCode2 = component.get("v.countryCode");
            if (!$A.util.isEmpty(countryCode2)) {
                phone.intlTelInput("setCountry", countryCode2);
            } else {
                if ($A.util.isEmpty(localePhone)) {
                    phone.intlTelInput("setCountry", $A.get("$Locale.userLocaleCountry"));
                } else {
                    // if the locale phone givent is an international phone
                    var intlNumber2 = phone.intlTelInput("getNumber");
                    if (intlNumber2 === localePhone) {
                        var countryData2 = phone.intlTelInput("getSelectedCountryData");
                        component.set("v.countryCode", countryData2.iso2.toUpperCase());
                    } else {
                        phone.intlTelInput("setCountry", "");                    
                    }
                }
            }
        }

        helper.handleClick(component, event);
    },

    onInputChanged : function(component, event, helper) {
        //var phone = jQuery("#intlTelPhone");
        var phone = jQuery('#' + component.get("v.titleId"));

        // Filter non-digits from input value.
        var phoneValue = phone.val();
        phone.val(helper.formatNumber(phoneValue));

        //helper.handleClick(component, event);
       // helper.reset(component, event);
        if (helper.isValidNumber(component, event)) {
            helper.handleClick(component, event);
        } else {
            helper.reset(component, event);
            helper.handleCountry(component, event);
            helper.handlePhone(component, event);
            //helper.updatePhone(component);

           // var intlNumber = phone.intlTelInput("getNumber");
           // console.log('reset intlNumber', intlNumber);
           // component.set("v.internationalPhone", intlNumber);

            //component.set("v.localePhone", phoneValue);
        }
    },

    handleClick: function(component, event, helper) {
        //console.log("handleClick");
        helper.handleClick(component, event);
    }
})