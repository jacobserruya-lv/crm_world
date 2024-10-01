({
	onInit : function(component, event, helper) {
		helper.populateOptions(component, event, helper);
	},
    handleChange: function(component, event, helper) {
        
        var phone = component.find("Phone").get("v.value");
        if (phone && !$A.util.isUndefined(phone) && /\D/g.test(phone)) {
        	phone = phone.replace(/\D/g,'');
        }
        component.set("v.localPhone",phone);
        helper.setInternationalPhone(component,phone);
	},
    handleBlur: function(component, event, helper) {
        
        var phone = component.find("Phone").get("v.value");
        var Option = component.get("v.CurrentSelection");
            if (phone){
        if(Option.RemoveFirstDigit__c == true && phone.substr(0, 1) == Option.FirstDigit__c.toString()&& component.get("v.flag") ){
            phone = phone.replace(phone.substr(0, 1),'');
            component.set("v.localPhone",phone);
            component.set("v.flag",false);
        } 
        helper.setInternationalPhone(component,phone);
    }
    },
    handleChangeValue: function(component, event, helper) {
		
        var Selections = component.get("v.Selection");
        component.set("v.CurrentSelection" ,Selections.filter(selection => selection.CountryCallingCode__c === component.get("v.value"))[0]);
        component.set("v.flag",true);
        helper.setInternationalPhone(component,component.get("v.localPhone"));
        
    },
    
 
    
})