({
    handleClick: function(component, event) {

        //var telInput = jQuery("#intlTelPhone");
        var telInput = jQuery('#' + component.get("v.titleId"));

        this.reset(component, event);

        if (jQuery.trim(telInput.val())) {
            if (this.isValidNumber(component, event)) {
                var cmpTarget = component.find('validMsg');
                $A.util.removeClass(cmpTarget, 'slds-hide');
            } else {
                //telInput.addClass("error");
                var cmpTarget2 = component.find('errorMsg');
                $A.util.removeClass(cmpTarget2, 'slds-hide');
            }            
        }
        this.handleCountry(component, event);
        this.handlePhone(component, event);
        
        this.firePhoneEvent(component);
    },
    
    isValidNumber: function(component, event) {
        var telInput = jQuery('#' + component.get("v.titleId"));

        var isValid = telInput.intlTelInput("isValidNumber");
        //console.log('isValid', isValid);
        return isValid;
    },

    reset : function(component, event) {
        //var telInput = jQuery("#intlTelPhone");
        //telInput.removeClass("error");

        var cmpTarget = component.find('errorMsg');
        $A.util.addClass(cmpTarget, 'slds-hide');
        //jQuery("#errorMsg").addClass("slds-hide");

        var cmpValid = component.find('validMsg');
        $A.util.addClass(cmpValid, 'slds-hide');
        //jQuery("#validMsg").addClass("slds-hide");
    },
    
    handleCountry : function(component, event) {
        //var telInput = jQuery("#intlTelPhone");
        var telInput = jQuery('#' + component.get("v.titleId"));

        if (jQuery.trim(telInput.val())) {
            var countryData = telInput.intlTelInput("getSelectedCountryData");
            if (countryData && !$A.util.isEmpty(countryData.iso2)) {//countryData.iso2) {
                //console.log("countryData.iso2", countryData.iso2);
                component.set("v.countryCode", countryData.iso2.toUpperCase());
            }
        } else {
            component.set("v.countryCode", "");
        }
    },

    handlePhone : function(component, event) {
        //var telInput = jQuery("#intlTelPhone");
        var telInput = jQuery('#' + component.get("v.titleId"));
        //console.log('telInput', telInput.val());

        var intlNumber = telInput.intlTelInput("getNumber");
        //console.log('intlNumber', intlNumber);
        component.set("v.internationalPhone", intlNumber);

        var localeNumber = telInput.intlTelInput("getNumber", intlTelInputUtils.numberFormat.NATIONAL);
        var localeNumberFormat = this.formatNumber(localeNumber); // National gives space between numbers depending on the country
        //console.log('localeNumberFormat', localeNumberFormat);
        component.set("v.localePhone", localeNumberFormat);
        
        // if 33611223344 or 611223344 for FR => 0611223344
        // Maybe a problem to replace the value. Maybe let the local phone as is without space if the international phone is ok.
        if (telInput.val() !== localeNumberFormat) {
            //console.log('lInput.val() !== localeNumberFormat');
            telInput.val(localeNumberFormat);
        }
    },
    
    /*updatePhone : function(component) {
        //var telInput = jQuery("#intlTelPhone");
        var telInput = jQuery('#' + component.get("v.titleId"));
        //console.log('telInput', telInput.val());
        
        var intlNumber = telInput.intlTelInput("getNumber");
        //console.log('intlNumber', intlNumber);
        component.set("v.internationalPhone", intlNumber);
        
        var localeNumber = telInput.intlTelInput("getNumber", intlTelInputUtils.numberFormat.NATIONAL);
        var localeNumberFormat = this.formatNumber(localeNumber); // National gives space between numbers depending on the country
        //console.log('localeNumberFormat', localeNumberFormat);
        component.set("v.localePhone", localeNumberFormat);
    },*/

    // Filter non-digits from input value.
    // Remove any non numeric characters from the phone number but leave any plus sign at the beginning
    formatNumber : function(phone) {
        //console.log("phone", phone);
        /*if (phone && !$A.util.isUndefined(phone) && /\D/g.test(phone)) {
            return phone.replace(/\D/g, '');
        }
        return phone;*/
        console.log("phone", phone);
        if (phone && !$A.util.isUndefined(phone) && /\D/g.test(phone)) {
            //phone = phone.replace(/[^\d\+]/g,'');
            if (phone.substr(0, 1) == "+") {
                phone = "+" + phone.replace(/\D/g,'');
            } else {
                phone = phone.replace(/\D/g,'');
            }
        }
        return phone;
    },

    firePhoneEvent: function(component) {
        var myEvent = component.getEvent("phoneEvent");
        myEvent.setParams({
            "type": component.get("v.type"),
            "countryCode": component.get("v.countryCode"),
            "localePhone": component.get("v.localePhone"),
            "internationalPhone": component.get("v.internationalPhone")
        });
        myEvent.fire();
    },

})