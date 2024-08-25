({
	/**
	 * Create an HTML input element, set necessary attributes, add the element to the DOM
	 */
	renderFields: function(component, helper, email, firstName, lastName, phone) {

		$A.createComponents([
				["lightning:input",{
					"label" : firstName.label,
					"name" : firstName.name,
					"class" : firstName.label,
					"aura:id" : "firstNameId",
					'required': false,
				}],
				["lightning:input",{
					"label" : lastName.label,
					"name" : lastName.name,
					"class" : lastName.label,
					"aura:id" : "lastNameId",
					'required': false,
				}]
			],
			function(components, status, errorMessage){
				if (status === "SUCCESS") {
					component.set('v.firstNameField', components[0]);
					component.set('v.lastNameField', components[1]);
				}
				else if (status === "INCOMPLETE") {
					console.error("No response from server or client is offline.")
				}
				else if (status === "ERROR") {
					console.error("Error: " + errorMessage);
				}
			}
		);
		if(!$A.util.isUndefinedOrNull(email)){
			helper.createEmailComponent(component,email);
        }
        if(!$A.util.isUndefinedOrNull(phone)){
			helper.createPhoneComponent(component,phone);
        }
	},
	createEmailComponent: function(component, email) {
		console.log(email);
		$A.createComponent(
			"lightning:input",{
				"label" : email.label,
				"name" : email.name,
				"class" : email.label,
				"aura:id" : "emailId",
				'required': false,
			},
			function(mycomponent, status, errorMessage){
				if (status === "SUCCESS") {
					component.set('v.emailField', mycomponent);
				}
				else if (status === "INCOMPLETE") {
					console.error("No response from server or client is offline.")
				}
				else if (status === "ERROR") {
					console.error("Error: " + errorMessage);
				}
			}
		);
	},
	createPhoneComponent : function(component,phone) {
		var localeCountry = '';
		if($A.get("$Locale.langLocale")=='ko'){
			localeCountry='KR';
		}else if($A.get("$Locale.langLocale")=='zh_CN'){
			localeCountry='CN';
		}
		$A.createComponent(
			"c:PhoneFormatter",{
				"aura:id" : "phoneId",
				"title" : phone.label,
				"countryCode" : localeCountry ,
			},
			function(mycomponent, status, errorMessage){
				if (status === "SUCCESS") {
					component.set('v.phoneField', mycomponent);
				}
				else if (status === "INCOMPLETE") {
					console.error("No response from server or client is offline.")
				}
				else if (status === "ERROR") {
					console.error("Error: " + errorMessage);
				}
			}
		);
	},
	defineTranslations: function(component) {
		var localeCountry = component.get('v.country');
		var localeLanguage = $A.get("$Locale.langLocale");


		if(localeCountry === 'TWN'){
			component.set("v.legalNoticeFirstPart",$A.get("$Label.c.ICX_LiveChatGDPR_TWN_firstPart"));	
			component.set("v.legalNoticeHereWord",$A.get("$Label.c.ICX_LiveChatGDPR_Hyperlinkword_tw"));	
		}
		else if(localeLanguage === 'en_US')
		{
			component.set("v.legalNoticeFirstPart",$A.get("$Label.c.ICX_LiveChatGDPR_US_firstPart"));	
			component.set("v.legalNoticeHereWord",$A.get("$Label.c.ICX_LiveChatGDPR_Hyperlinkword_us"));	
			component.set("v.legalNoticeSecondPart",$A.get("$Label.c.ICX_LiveChatGDPR_US_secondPart"));

		}
		else {
			component.set("v.legalNoticeFirstPart",$A.get("$Label.c.ICX_LiveChatGDPR_firstPart"));	
			component.set("v.legalNoticeHereWord",$A.get("$Label.c.ICX_LiveChatGDPR_Hyperlinkword"));	
			component.set("v.legalNoticeSecondPart",$A.get("$Label.c.ICX_LiveChatGDPR_secondPart"));	
		}
	},
	defineWebSiteLink: function(component) {
		var localeLanguage = $A.get("$Locale.langLocale");
        var localeCountry = component.get('v.country');

		if(localeCountry === 'TWN'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_TWN_legalNotice"));
		}else if (localeCountry === "INDEN")
		{
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_en_ID_legalNotices"));	
		}else if (localeLanguage === 'ru'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_ru_legalNotice"));	
		}else if(localeLanguage === 'de'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_de_legalNotice"));	
		} else if(localeLanguage === 'en_GB'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_en_GB_legalNotice"));	
		} else if(localeLanguage === 'fr_CA'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_fr_CA_legalNotice"));	
		} else if(localeLanguage === 'en_CA'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_en_CA_legalNotice"));	
		} else if(localeLanguage === 'zh_HK'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_zh_HK_legalNotice"));	
		} else if(localeLanguage === 'en_HK'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_en_HK_legalNotice"));	
		} else if(localeLanguage === 'en_SG'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_en_SG_legalNotice"));	
		} else if(localeLanguage === 'en_AU'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_en_AU_legalNotice"));	
		} else if(localeLanguage === 'en_IE'){
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_en_IE_legalNotice"));	
		} 
		else {
			component.set("v.legalNoticeWebSiteLink",$A.get("$Label.c.ICX_LiveChatGDPR_legalNotice"));	
		}
        
	},
    
	/**
	 * Create an array of data to pass to the prechatAPI component's startChat function
     */
	createStartChatDataArray: function(component) {
		var infos=[];

		var firstName =  {
			name: component.find("firstNameId").get("v.name"),
			label: component.find("firstNameId").get("v.label"),
			value: component.find("firstNameId").get("v.value")
		};
		infos.push(firstName);

		var lastName =  {
			name: component.find("lastNameId").get("v.name"),
			label: component.find("lastNameId").get("v.label"),
			value: component.find("lastNameId").get("v.value")
		};
		infos.push(lastName);
		if(!$A.util.isUndefinedOrNull(component.find("emailId"))){
			var email =  {
				name: component.find("emailId").get("v.name"),
				label: component.find("emailId").get("v.label"),
				value: component.find("emailId").get("v.value")
			};
			infos.push(email);
		}
		if(!$A.util.isUndefinedOrNull(component.find("phoneId"))){
			var phone =  {
				name: 'MobilePhone',
				label: component.find("phoneId").get('v.title'),
				value: component.find("phoneId").get('v.internationalPhone')
			};
        	infos.push(phone);
		}
		console.log(infos);
        return infos;
	}
	
	

});