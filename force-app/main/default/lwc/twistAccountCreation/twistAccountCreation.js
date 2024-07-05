import { LightningElement, track, api, wire } from "lwc";

import Twist_UI from "@salesforce/resourceUrl/Twist_UI";
import apexInitComponentConfig from "@salesforce/apex/TWIST_Registration.initComponentConfig";
import apexTranslateLabels from "@salesforce/apex/TWIST_i18nTranslations.translateLabelsList";
import isValidCode from "@salesforce/apex/TWIST_Registration.isValidCode";
import submitRegistrationForm from "@salesforce/apex/TWIST_Registration.submitRegistrationForm";
import getTermConditionLink from "@salesforce/apex/TWIST_Registration.getTermConditionLink";
import apexIsUserIdentity from "@salesforce/apex/TWIST_Account_Confirmation.isUserIdentity";
import isLineButtonEnabled from '@salesforce/apex/TWIST_Login.isLineButtonEnabled';

import {
    isEmailValid,
    showPageLoader,
    hidePageLoader,
    hasHeightChars,
    hasDigit,
    hasUpperCaseLetter,
    hasLowerCaseLetter,
    hasSpecialChar,
    doesPasswordMatchStringPattern,
    allowTriggerNewPageViewEvent,
    sendPageView,
    sendEvent,
    lwcNameToCamelCase,
    hasLegalAge,
    includesString,
    setFieldErrorMessage
} from 'c/twistUtils';
import CnameTarget from "@salesforce/schema/Domain.CnameTarget";


export default class TwistAccountCreation extends LightningElement {
    /* Component properties ******************************************************************** */
    
    @api queryParams;
    @api autodata;
    
    oQueryParams;
    
    passwordValidityCriteriaElt = null;
    twistLineLogo = Twist_UI + '/Twist_Line_Social_Login_Logo.svg';
    twistLogoLV = Twist_UI + "/SmallLogo.png";
    chevronLV = Twist_UI + "/Chevrons.svg";
    twistEyeIcon = Twist_UI + "/visibility-stroke.svg";
    twistEyeStrikeThroughIcon = Twist_UI + "/visibility.svg";
    currentSection = 1;
    registrationFormField;
    socialParams;

    
    @api language;
    @api langCountry;
    @track isPasswordShown = false;
    @track isConfirmPasswordShown = false;
    @track doesEmailExist = false;
    @track formData = {};
    @track isCreateYourAccountButtonDisabled = false;
    @track componentConfig = {};
    @track customLabels = {};
    @track form = { error: null };
    @track verificationCode;
    @track socialMediaProviders = {};
    
    @track newCodeGeneratedMessage;
    @track isLogInModalDisplayed = false;
    @track isDisabledLoginButton=false;
    @track loginModalErrorMsg;

    @wire(getTermConditionLink, { langCountry: "$oQueryParams.langCountry" }) termAndConditionLink;

    
    /* LWC life cycle ********************************************************************************* */
    
    connectedCallback() {
        this.init();
    }
    
    renderedCallback() {
        this.passwordValidityCriteriaElt = this.template.querySelector("c-twist-password-validity-criteria");
    }
    
    errorCallback(error, stack) {
        console.error(error);
    }
    
    init() {
        this.oQueryParams = JSON.parse(this.queryParams);
        this.dispatchCanModalBeShownEvent();
        Promise.all([
            apexInitComponentConfig({ queryParams: this.oQueryParams }),
            apexTranslateLabels({
                labels: [
                    "Twist_Account_Creation_Form_ContinueButtonLabel",
                    "Twist_Account_Creation_Form_ActivateButtonLabel",
                    "Twist_Account_Creation_TitleActivateYourAccount",
                    "Twist_Account_Creation_TextAccountCreation",
                    "Twist_Account_Creation_TitleAccountCreation",
                    "Twist_Account_Creation_EmailFieldLabel",
                    "Twist_Account_Creation_EmailConfirmationFieldLabel",
                    "Twist_Account_Creation_PasswordFieldLabel",
                    "Twist_Account_Creation_TitleFieldLabel",
                    "Twist_Account_Creation_FirstNameFieldLabel",
                    "Twist_Account_Creation_LastNameFieldLabel",
                    "Twist_Account_Creation_FirstName2FieldLabel",
                    "Twist_Account_Creation_LastName2FieldLabel",
                    "Twist_Account_Creation_CountryFieldLabel",
                    "Twist_Account_Creation_DateOfBirthFieldLabel",
                    "Twist_Account_Creation_CheckFieldLabel",
                    "Twist_Account_Creation_CheckFieldLinkLabel",
                    "Twist_Account_Creation_EndTextAccountCreation",
                    "Twist_Account_Creation_ActivationCodeSecondeLineText",
                    "Twist_Account_Creation_ActivationCodeText",
                    "Twist_Account_Creation_AccountCodeFieldLabel",
                    "Twist_Account_Creation_SendAgainLink",
                    "Twist_Account_Creation_TermAndConditionsLink",
                    "Twist_Account_Creation_ByCreatingText",
                    "Twist_Account_Creation_LoginHereLink",
                    "Twist_Account_Creation_ConfirmationText",
                    "Twist_Account_Creation_Validation_EmailDoNotMatch",
                    "Twist_Login_Form_Validation_Email_Format",
                    "Twist_Form_FieldCantBeEmpty",
                    "Twist_Account_Creation_TitleConfirmationPage",
                    "IDENTITY_Registration_Verification_Section_Error",
                    "Twist_Reset_Password_Form_Validation_PasswordContainsEmail",
                    "Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames",
                    "Twist_Reset_Password_Form_Validation_PasswordDoesNotMatchValidityCriteria",
                    "Twist_Reset_Password_Form_Validation_PasswordIsTooLong",
                    "Twist_Reset_Password_Form_Validation_WordCharacters",
                    "TWIST_Registration_Verification_IncorrectCode_Error",
                    "TWIST_Registration_Verification_Code_Limit",
                    "Twist_Account_Creation_Title_Placeholder",
                    "Twist_Account_Creation_Country_Placeholder",
                    "Twist_Reset_Password_Form_ConfirmPasswordFieldLabel",
                    "Twist_Partial_Activation_Form_PartialActivationYourEmailText",
                    "Twist_Partial_Activation_Form_PartialActivationSubtitle",
                    "Twist_Account_Creation_Form_AccountCreationProcessError",
                    "Twist_Account_Creation_SecondTextAccountCreation",
                    "Twist_Account_Creation_Form_AccountCreationRegexNotMatch",
                    "Twist_Account_Creation_Validation_RestrictionBirthdate",
                    "Twist_Account_Creation_Form_AccountUserExistsError",
                    "Twist_Account_Creation_AccountNewCodeGeneratedLabel",
                    "Twist_Login_Page_Social_Login_Line",
                    "Twist_Social_Line_Text_For_Second_Option",
                    "Twist_Account_Creation_Validation_RestrictionBirthdate",
                    "Twist_Account_Creation_Wrong_birthdate",
                    "Twist_Account_Creation_Age_Legal_Reached",
                    "Twist_Account_Creation_CheckFieldLabel_Privacy_Policy",
                    "Twist_Account_Creation_CheckFieldLabel_Newsletter",
                    "Twist_Account_Creation_BirthDate_Inconsistent"
                ],
                language: this.language
            }),
            isLineButtonEnabled({langCountry: this.oQueryParams.langCountry, origin:  this.oQueryParams.origin})
        ])
        .then((result) => {
            this.componentConfig = result[0];
            if (result[0].mode === "LOGIN") {
                this.handleClickOnLoginHereLink();
                return;
            }

            this.formData = result[0]?.formData ? { ...result[0]?.formData } : { ...result[0]?.socialParams };
            this.socialParams = { ...result[0]?.socialParams };

            this.registrationFormField = result[0]?.form;
            this.maxPasswordLength = result[0]?.form?.password?.Validation_Max_Length__c ?? 20;
            
            if (this.componentConfig.client_country) {
                this.formData.country = this.componentConfig.client_country;
            }
            
            this.customLabels = result[1];
            this.socialMediaProviders = result[0]?.socialMediaProviders;
            this.showLineButtonAccordingOrigin =  result[2];
        })
        .catch((error) => {
            this.form.error = `Error: ${error}`;
        })
        .finally(() => {
            if(this.componentConfig.mode != 'LOGIN'){
                this.dispatchEvent(new CustomEvent("childlwcrendered", { detail: lwcNameToCamelCase(this.template.host.localName) }));
            }
            
        });
    }
    
    /* Getters & Setters ********************************************************************************* */

    get componentForm(){
        return this.componentConfig.mode == "PARTIAL_ACTIVATION"? 'component__form is--accountActivation' : 'component__form';
    }

    get isCurrentSectionAccountCreation() {
        return this.currentSection == 1;
    }
    
    get isCurrentSectionActivateYourAccount() {
        return this.currentSection == 2;
    }
    
    get isCurrentSectionConfirmationMessage() {
        return this.currentSection == 3;
    }

    get regexNoDigitAndSpecialChars() {
        return "^[\\p{L}'\\-\\s]+$"; // except hyphen and single quote
    }
    
    get isGlobalError() {
        return this.form.error;
    }
    
    get isEmailDisabled() {
        return this.componentConfig.modeInfo.isEmailReadOnly || this.isLogInModalDisplayed;
    }

    set emailInSystem(val) {
        this.doesEmailExist = val;
        if (this.doesEmailExist) {
            this.setErrorMessage(this.registrationFormField.email.Field__c, this.customLabels.Twist_Account_Creation_Form_AccountUserExistsError);
        }
    }
    
    get emailInSystem() {
        if (this.doesEmailExist) {
            this.setErrorMessage(this.registrationFormField.email.Field__c, this.customLabels.Twist_Account_Creation_Form_AccountUserExistsError);
        }
        return this.doesEmailExist;
    }
    
    get passwordFieldType() {
        return this.isPasswordShown ? "text" : "password";
    }
    
    get eyeIconSrcPassword() {
        return this.isPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }
    
    get eyeIconSrcConfirmPassword() {
        return this.isConfirmPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }
    
    get confirmPasswordFieldType() {
        return this.isConfirmPasswordShown ? "text" : "password";
    }
    
    get showCountryField(){
        return this.registrationFormField.country && this.componentConfig.showCountryList;
    }
    
    get showLineButton() {
        return this.showSocialMediaButton('LineLV') && this.showLineButtonAccordingOrigin;
    }

    get showLineTWButton() {
        return this.showSocialMediaButton('LineLVTW');
    }
    
    /* Event handlers ************************************************************************** */
    
    handleTwistGaLwcRendered() {
        sendPageView.call(this); // Tagging Plan: line 42
    }
    
    handlePaste(event) {
        event.preventDefault();
    }
    
    handleOnKeyPress(event) {
        if (this.doesNotMatchRegexp(event.key, this.regexNoDigitAndSpecialChars)) {
            event.preventDefault();
        }
    }
    
    handleInputBlur(event){
        const targetId = event?.detail?.targetId || event.target.dataset.id;
        const value = event?.detail?.value || event.target.value;
        const oldValue = this.formData[targetId];

        if (Object.keys(this.registrationFormField).includes(targetId)) {
            this.formData[targetId] = value;
        }
        const isFieldInvalid = this.isFieldInvalid(targetId);
        switch(targetId) {
            case this.registrationFormField.email.Field__c:
                if (value) {
                    if (oldValue != value) {
                        this.doesEmailExist = false;
                    }
                    if (!this.doesEmailExist && !isFieldInvalid) {
                        this.checkIfUserExists();
                    }
                }
                break;

            case this.registrationFormField.password.Field__c:
                this.handleFormPasswordBlur();
                break;
        }

        return isFieldInvalid;
    }

    handleCheckboxChange(event) {
        let targetId = event.target.dataset.id;
        let value = event.target.checked;
        sendEvent.call(this, { // Tagging Plan: lines 31 & 32
            actionId: value ? "tick_checkbox" : "untick_checkbox",
            categoryGa: "mylv",
            actionGa: value ? "tick_checkbox" : "untick_checkbox",
            contentId: "newsletter_subscription",
            actionType: "newsletter_subscription"
        });
        
        if (Object.keys(this.registrationFormField).includes(targetId)) {
            this.formData[targetId] = String(value);
        }
        this.isFieldInvalid(targetId);
    }
    
    handleCheckboxChangePrivacyPolicy(event) {
        let targetId = event.target.dataset.id;
        let value = event.target.checked;
       /* sendEvent.call(this, { // Tagging Plan: lines 31 & 32
            actionId: value ? "tick_checkbox" : "untick_checkbox",
            categoryGa: "mylv",
            actionGa: value ? "tick_checkbox" : "untick_checkbox",
            contentId: "privacy_policy",
            actionType: "privacy_policy"
        });*/
        
        if (Object.keys(this.registrationFormField).includes(targetId)) {
            this.formData[targetId] = String(value);
        }
        this.isFieldInvalid(targetId);
        // For now we don't need to store the information
    }

    handleComboboxesChange(event) {
        const targetId = event.target.dataset.id;
        const target = this.template.querySelector(`[data-id="${targetId}"]`);
        if (Object.keys(this.registrationFormField).includes(targetId)) {
            this.formData[targetId] = target.value;
        }
        this.isFieldInvalid(targetId);
    }
    
    handleFormPasswordChange(event) {
        if (!this.passwordValidityCriteriaElt) {
            this.passwordValidityCriteriaElt = this.template.querySelector("c-twist-password-validity-criteria");
        }
        
        const password = event.target.value;
        this.formData.password = password;
        
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasHeightChars(hasHeightChars(password));
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasDigit(hasDigit(password));
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasUpperCaseLetter(hasUpperCaseLetter(password));
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasLowerCaseLetter(hasLowerCaseLetter(password));
        this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasSpecialChar(hasSpecialChar(password));

        const fieldDataId = this.registrationFormField.password.Field__c;
        if (this.isFieldRequiredAndEmpty(fieldDataId, password)) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Form_FieldCantBeEmpty);
        }
        if (this.doesPasswordContainsEmail()) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsEmail);
        }
        if (this.doesPasswordContainsFirstOrLastNames()) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames);
        }
        if (!doesPasswordMatchStringPattern(password)) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordDoesNotMatchValidityCriteria);
        }
        if (this.isPasswordTooLong()) {
            this.setErrorMessage(fieldDataId, `${this.customLabels.Twist_Reset_Password_Form_Validation_PasswordIsTooLong} ${this.maxPasswordLength} ${this.customLabels.Twist_Reset_Password_Form_Validation_WordCharacters}`);
        }
    }
    
    handleFormPasswordFocus(event) {
        this.passwordValidityCriteriaElt = this.template.querySelector("c-twist-password-validity-criteria");
        this.passwordValidityCriteriaElt.show(true);
    }
    
    handleFormPasswordBlur(event) {
        this.passwordValidityCriteriaElt = this.template.querySelector("c-twist-password-validity-criteria");
        this.passwordValidityCriteriaElt.show(false);
    }
    
    handleClickOnLoginHereLink() {
        sendEvent.call(this, { // Tagging Plan: line 30
            actionId: "i_already_have_an_account",
            categoryGa: "mylv",
            actionGa: "create_an_account",
            labelGa: "i_already_have_an_account"
        });
        let urlSplit = location.href.split("?");
        location.href = this.componentConfig.loginBaseUrl
            + "?"
            + urlSplit[1]
            + (this.oQueryParams.dispatchCountry ? "&dispatchCountry=" + this.oQueryParams.dispatchCountry : "");
    }

    handleClickOnCreateYourAccountButton(event) {
        if (this.isFormValid()) {
            this.isCreateYourAccountButtonDisabled = true;
            showPageLoader();
        }
    }
    
    handleCodeChange(event) {
        if (!event.target.value) {
            this.setErrorMessage(event.target.dataset.id, this.customLabels.Twist_Form_FieldCantBeEmpty);
        }
        this.verificationCode = event.target.value;
    }
    
    handleTermConditionClick() {
        if (this.termAndConditionLink != null) {
            window.open(this.termAndConditionLink.data);
        }
    }
    
    handleClickOnContinueButton() {
        if(!this.isFormValid()) {
            sendEvent.call(this, { // Tagging Plan: line 55
                pageName: "mylv/account_creation/step_personal_infos",
                actionId: "account_creation_step_failed",
                categoryGa: "mylv",
                actionGa: "create_an_account",
                labelGa: "account_creation_step_failed",
                errorId: this.getErrorFieldsList()
            });
        }
        else {
            showPageLoader();
            this.sendVerificationCode();
        }
    }
    
    handleResendVerificationCode(event) {
        sendEvent.call(this, { // Tagging Plan: line 58
            pageName: "mylv/account_creation/step_activation",
            actionId: "resend_activation_code",
            categoryGa: "mylv",
            actionGa: "create_an_account",
            labelGa: "resend_activation_code"
        });
        
        this.disableLink(event.target.dataset.id);
        this.handleClickOnContinueButton();
    }
    
    handleClickOnActivateAccountButton() {
        try{
            sendEvent.call(this, { // Tagging Plan: line 33
                actionId: "account_creation_request",
                categoryGa: "mylv",
                actionGa: "create_an_account",
                labelGa: "account_creation_request"
            });
            if(this.verificationCode) {
                this.checkCodeIsValid();
            }
            else {
                this.setErrorMessage("activationCode", this.customLabels.Twist_Form_FieldCantBeEmpty);
            }
        }
        catch(e){
            console.error(e);
            this.setErrorMessage("activationCode", "error");
            hidePageLoader();
        }
    }
    
    handleKeypressOnActivationCode(e) {
        if (e.keyCode === 13) {
            this.handleClickOnActivateAccountButton();
            e.preventDefault();
        }
    }
    
    handleResetFieldBirthday(e) {
        this.formData[this.registrationFormField.birthdate.Field__c] = "";
    }
    
    handleToggleShowPassword(event) {
        this.isPasswordShown = !this.isPasswordShown;
        sendEvent.call(this, { // Tagging Plan: line 54
            actionId: this.isPasswordShown ? "show_password" : "hide_password",
            categoryGa: "mylv",
            actionGa: "create_an_account",
            labelGa: this.isPasswordShown ? "show_password" : "hide_password"
        });
    }
    
    handleToggleShowConfirmPassword(event) {
        this.isConfirmPasswordShown = !this.isConfirmPasswordShown;
    }
   
    /* Util methods **************************************************************************** */
    
    doesNotMatchRegexp(term, pattern) {
        var regex = new RegExp(pattern, "u");
        return term && !regex.test(term);
    }

    showActivateYourAccountSection() {
        this.currentSection = 2;
        this.dispatchCanModalBeShownEvent();

        allowTriggerNewPageViewEvent.call(this); // required because a pageView event has already been sent from this page
        sendPageView.call(this, { pageName: "mylv/account_creation/step_activation" }); // Tagging Plan: line 53
    }
    
    showConfirmationMessageSection() {
        this.currentSection = 3;
        this.dispatchCanModalBeShownEvent();
    }
    
    dispatchCanModalBeShownEvent() {
        this.dispatchEvent(new CustomEvent("canmodalbeshown", { detail: this.currentSection == 2 }));
    }

    checkIfUserExists() {
        apexIsUserIdentity({ email : this.formData.email })
        .then(result => {
            if(this.componentConfig.modeInfo.isSocialLogin && result) { // email exists and sociallogin flow -> open popup
                this.isLogInModalDisplayed = true;
            }
            else{
                this.emailInSystem = result;
                if (this.emailInSystem) {
                    sendEvent.call(this, { // Tagging Plan: line 43
                        actionId: "email_not_valid",
                        categoryGa: "mylv",
                        actionGa: "create_an_account",
                        labelGa: "email_not_valid"
                    });
                }
            }
        })
    }
    
    sendVerificationCode() {
        submitRegistrationForm({
            formData: this.formData,
            queryParams: this.oQueryParams,
            socialParams: this.socialParams
        })
        .then(data => {
            hidePageLoader();
            const id = 'resendCode';
            if(!data.success) {
                sendEvent.call(this, { // Tagging Plan: line 55
                    pageName: "mylv/account_creation/step_personal_infos",
                    actionId: "account_creation_step_failed",
                    categoryGa: "mylv",
                    actionGa: "create_an_account",
                    labelGa: "account_creation_step_failed",
                    errorId: data.form
                });

                if (!data.success) {
                    this.setErrorMessage("activationCode", data.form);
                }
                this.form.error = data.form;

                if(this.isCurrentSectionActivateYourAccount){ // in case of too many send again requests
                    this.newCodeGeneratedMessage = null;
                    this.disableLink(id);
                }
            }
            else {
                sendEvent.call(this, { // Tagging Plan: line 56
                    pageName: "mylv/account_creation/step_personal_infos",
                    actionId: "account_creation_step_succeeded",
                    categoryGa: "mylv",
                    actionGa: "create_an_account",
                    labelGa: "account_creation_step_succeeded"
                });
                
                if (this.isCurrentSectionAccountCreation) {
                    this.showActivateYourAccountSection();
                    return;
                }
                
                if (this.isCurrentSectionActivateYourAccount) {
                    this.activateLink(id);
                    this.newCodeGeneratedMessage = this.customLabels.Twist_Account_Creation_AccountNewCodeGeneratedLabel;
                }
            }
        })
        .catch((error) => {
            console.error("error", error);
        })
        .finally(() => {
            hidePageLoader();
        });
    }
    
    disableLink(id) {
        const target = this.template.querySelector(`[data-id="${id}"]`);
        if (target) {
            target.classList.add("disabled-link");
            target.disabled = true;
        }
    }
    
    activateLink(id){
        const target = this.template.querySelector(`[data-id="${id}"]`);
        setTimeout(function(){
            if(target){
                target.classList.remove('disabled-link');
                target.disabled = false;
            }
        }, 60000);
    }
    
    checkCodeIsValid() {
        showPageLoader();
        isValidCode({
            language: this.language,
            activationCode: this.verificationCode,
            identifier: this.formData.email,
            queryParams: this.oQueryParams,
            socialParams: this.socialParams
        })
        .then(isValid => {
            sendEvent.call(this, { // Tagging Plan: line 59
                pageName: "mylv/account_creation/step_activation",
                actionId: isValid ? "account_creation_step_succeeded" : "account_creation_step_failed",
                categoryGa: "mylv",
                actionGa: "create_an_account",
                labelGa: isValid ? "account_creation_step_succeeded" : "account_creation_step_failed"
            });
            if (isValid){
                this.showConfirmationMessageSection();
            }
            else {
                this.setErrorMessage("activationCode", this.customLabels.TWIST_Registration_Verification_IncorrectCode_Error);
            }
        })
        .catch(error => {
            this.setErrorMessage("activationCode", "error")
            console.error("error", error);
        })
        .finally(() => {
            hidePageLoader();
        })
    }

    showSocialMediaButton(providerName) {
        return this.socialMediaProviders[providerName] && !this.oQueryParams?.social_id;
    }

    getErrorFieldsList() {
        let fields = [];
        Object.keys(this.registrationFormField).forEach((element) => {
            if (this.isFieldInvalid(this.registrationFormField[element].Field__c)) {
                fields.push(this.registrationFormField[element].Field__c);
            }
        });
        return fields.join(";");
    }
        
    /* Form validation methods **************************************************************************** */
    
    isFormValid() {
        let isValid = true;
        Object.values(this.registrationFormField).forEach(fieldObject => {
            if (this.isFieldInvalid(fieldObject.Field__c)) {
                isValid = false;
            }
        });
        return isValid;
    }

    /**
     * @param {String} fieldDataId
     * @returns {Boolean}
     */
    isFieldInvalid(fieldDataId) {
        if (!this.getFieldElement(fieldDataId)) {
            return false;
        }
        
        const fieldValue = this.formData[fieldDataId];
        if (this.isFieldRequiredAndEmpty(fieldDataId, fieldValue)) {
            this.setErrorMessage(fieldDataId, this.customLabels.Twist_Form_FieldCantBeEmpty);
            return true;
        }

        this.removeErrorMessage(fieldDataId);
        switch (fieldDataId) {
            case this.registrationFormField.email?.Field__c:
                const isEmailFieldInvalid = !isEmailValid(fieldValue, this.componentConfig.AllowPlusSymbolInEmail) || fieldValue?.toLowerCase().includes("info@");
                if (isEmailFieldInvalid) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Login_Form_Validation_Email_Format);
                    sendEvent.call(this, { // Tagging Plan: line 43
                        actionId: "email_not_valid",
                        categoryGa: "mylv",
                        actionGa: "create_an_account",
                        labelGa: "email_not_valid"
                    });
                }
                return isEmailFieldInvalid;
                
            case this.registrationFormField.emailconfirmation?.Field__c:
                const doEmailsMismatch = (this.formData.email !== fieldValue);
                if (doEmailsMismatch) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Validation_EmailDoNotMatch);
                    sendEvent.call(this, { // Tagging Plan: line 44
                        actionId: "emails_dont_match",
                        categoryGa: "mylv",
                        actionGa: "create_an_account",
                        labelGa: "emails_dont_match"
                    });
                }
                return doEmailsMismatch;
                
            case this.registrationFormField.birthdate?.Field__c:
                if (this.isCurrentSectionAccountCreation) {
                    if (this.isFutureDate(fieldValue)) {
                        this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_BirthDate_Inconsistent);
                        return true;
                    }
                    if (!hasLegalAge(fieldValue, this.componentConfig.legalAge)) {
                        this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Validation_RestrictionBirthdate);
                    }
                }
                return false;
                    
            case this.registrationFormField.password?.Field__c:
                if (this.doesPasswordContainsEmail()) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsEmail);
                    return true;
                }
                if (this.doesPasswordContainsFirstOrLastNames()) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames);
                    return true;
                }
                if (!doesPasswordMatchStringPattern(fieldValue)) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Reset_Password_Form_Validation_PasswordDoesNotMatchValidityCriteria);
                    return true;
                }
                if (this.isPasswordTooLong()) {
                    this.setErrorMessage(fieldDataId, `${this.customLabels.Twist_Reset_Password_Form_Validation_PasswordIsTooLong} ${this.maxPasswordLength} ${this.customLabels.Twist_Reset_Password_Form_Validation_WordCharacters}`);
                    return true;
                }
                return false;

            case this.registrationFormField.passwordconfirmation?.Field__c:
                if (fieldValue !== this.formData.passwordconfirmation) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Validation_EmailDoNotMatch);
                    return true;
                }
                return false;

            case this.registrationFormField.firstname?.Field__c:
            case this.registrationFormField.lastname?.Field__c:
            case this.registrationFormField.firstname2?.Field__c:
            case this.registrationFormField.lastname2?.Field__c:
                if (this.doesNotMatchRegexp(fieldValue, this.regexNoDigitAndSpecialChars)) {
                    this.setErrorMessage(fieldDataId, this.customLabels.Twist_Account_Creation_Form_AccountCreationRegexNotMatch);
                    return true;
                }
                return false;
            
            case this.registrationFormField.country?.Field__c:
            case this.registrationFormField.title?.Field__c:
            case this.registrationFormField.newsletter_agreement?.Field__c:
            case this.registrationFormField.privacy_policy?.Field__c:
                break;
        }
        return false;
    }

    /**
     * @param {String} fieldDataId
     * @param {*} fieldValue
     * @returns {Boolean}
     */
    isFieldRequiredAndEmpty(fieldDataId, fieldValue) {
        if (!this.registrationFormField[fieldDataId].Is_Required__c) {
            return false;
        }
        const fieldElement = this.getFieldElement(fieldDataId);
        return (fieldElement.type !== undefined && fieldElement.type === 'checkbox')
            ? fieldValue !== "true"
            : !fieldValue;
    }

    /**
     * @param {String} fieldDataId
     */
    setErrorMessage(fieldDataId, errorMessage) {
        if (fieldDataId === this.registrationFormField.birthdate?.Field__c) {
            this.template.querySelector("c-date-input-format").setErrorMessage(errorMessage);
        }
        else {
            setFieldErrorMessage(this.template.querySelector(`[data-id="${fieldDataId}"]`), errorMessage);
        }
    }

    /**
     * @param {String} fieldDataId
     */
    removeErrorMessage(fieldDataId) {
        this.setErrorMessage(fieldDataId, "");
    }

    doesPasswordContainsEmail() {
        return includesString(this.formData.password, this.formData.email);
    }

    doesPasswordContainsFirstOrLastNames() {
        return includesString(this.formData.password, this.formData.firstname) || includesString(this.formData.password, this.formData.lastname);
    }

    isPasswordTooLong() {
        return (this.formData.password == undefined || !this.formData.password)
            ? false
            : this.formData.password.length > this.maxPasswordLength;
    }

    /**
     * @param {String} stringDate (YYYY-MM-DD format)
     * @return {Boolean}
     */
    isFutureDate(stringDate) {
        if (stringDate !== undefined && stringDate) {
            const today = new Date();
            const parts = stringDate.split('-');
            const aDate = new Date(today); // clone object
            aDate.setFullYear(parts[0]);
            aDate.setMonth(Number(parts[1]) - 1, parts[2]);
            return aDate >= today;
        }
        return false;
    }

    /**
     * @param {String} fieldDataId
     * @return {Element}
     */
    getFieldElement(fieldDataId) {
        return (fieldDataId == this.registrationFormField.birthdate?.Field__c)
            ? this.template.querySelector("c-date-input-format")?.getDateFieldElement()
            : this.template.querySelector(`[data-id="${fieldDataId}"]`);
    }

}