({
	/**
	 * After this component has init, create input fields
	 *
	 * @param component - This prechat UI component.
	 * @param event - The Aura event.
	 * @param helper - This component's helper.
	 */
	onInit: function(component, event, helper) {
		// Get array of pre-chat fields defined in Setup using the prechatAPI component
		var prechatFields = component.find("prechatAPI").getPrechatFields();
		console.log(prechatFields);
		var email = prechatFields.find(function(field) {
			return field.name === "Email";
		});

		var firstName = prechatFields.find(function(field) {
			return field.name === "FirstName";
		});

		var lastName = prechatFields.find(function(field) {
			return field.name === "LastName";
		});
        var phone = prechatFields.find(function(field) {
			return field.name === "MobilePhone";
		});
        console.log(phone);
		
		// Append an input element to the prechatForm div.
		helper.renderFields(component,helper, email, firstName, lastName,phone);

		helper.defineTranslations(component);

		helper.defineWebSiteLink(component);
		
	},

	/**
	 * Handler for when the start chat button is clicked
	 */
	onStartButtonClick: function(cmp, event, helper) {
        console.log('123');
		var prechatInfo = helper.createStartChatDataArray(cmp);
		if(cmp.find("prechatAPI").validateFields(prechatInfo).valid) {
			let email = '';
            let phone = '';
            if(!$A.util.isUndefinedOrNull(cmp.find("phoneId"))){
                phone = cmp.find("phoneId").get("v.internationalPhone")
			}
			if(!$A.util.isUndefinedOrNull(cmp.find("emailId"))){
				email = cmp.find("emailId").get("v.value")
			}
			let iAgree = cmp.find("iAgree").get("v.checked")
			//cmp.find("prechatAPI").startChat(prechatInfo);
			var event1 = new CustomEvent(
				"setCustomField",
				{
					detail: {
						callback: cmp.find("prechatAPI").startChat.bind(this, prechatInfo),
						emailField: email,
						iAgreeField: iAgree,
                        mobilePhoneField: phone
                        
					}
				}
			);
			//Dispatch the event.
			document.dispatchEvent(event1);
				
		} else {
			console.warn("Prechat fields did not pass validation!");
		}
	}
	
	,
	 Showhide: function(component, event, helper) {
		if(component.find("iAgree").get("v.checked")==true){
			component.find("btn").set('v.variant','brand');
			component.find("btn").set('v.disabled',false);
			
		}else{
			component.find("btn").set('v.variant','success');
			component.find("btn").set('v.disabled',true);
		}

	}
    
    

});