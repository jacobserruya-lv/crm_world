import { LightningElement, track, api } from 'lwc';

import Twist_UI from '@salesforce/resourceUrl/Twist_UI';
import apexInitComponentConfig from '@salesforce/apex/TWIST_ResetPassword.initForgotPasswordComponentConfig';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import apexAlternativeLogin from '@salesforce/apex/TWIST_AlternativeLogin.requestAlternativeLogin';


import {
    showPageLoader,
    hidePageLoader,
    isEmailValid,
    sendPageView,
    sendEvent,
    lwcNameToCamelCase,
    focusOnEmail
} from 'c/twistUtils';

export default class twistAlternativeLogin extends LightningElement {

    /* Component properties ******************************************************************** */

    @api queryParams;
    @api autodata;
    @api metaLanguage
    oQueryParams;

    twistArrowIcon = Twist_UI + '/arrow-back.svg';

    @api language;
    @track isSubmitButtonDisabled = false;
    @track componentConfig = {};
    @track customLabels = {};
    @track user = {
        email: null
    };
    @track alternativeLoginForm = {
        form: { error: null }, // stores general form errors eventually
        email: { value: null, error: null }
    
    };
     @track isAlternativeLoginPage = false;
     @track validity = false;
    /* Getters ********************************************************************************* */

    get emailFieldCssClass() {
        return 'form__input_email email_alternative_login' + (this.alternativeLoginForm.email.error||this.alternativeLoginForm.form.error ? ' error' : '');
    }

    get linkToRegistration() {
        return this.componentConfig.registrationUrl;
    }
    get ariaInvalid() {
        return this.validity ? 'true' : 'false';
    }


    /* Component life cycle ******************************************************************** */

    connectedCallback() {
        this.init();
    }
    
    /* Event handlers ************************************************************************** */
    
    handleTwistGaLwcRendered() {
        sendPageView.call(this); // Tagging Plan: line 22
    }

    handleClickOnLinkToRegistration(e) {
        // sendEvent.call(this, {
        //     actionId: "create_new_account", //Tagging Plan: line 27
        //     categoryGa: "mylv",
        //     actionGa: "password_forgotten",
        //     labelGa: "create_new_account",
        //     actionPosition: "i_dont_have_an_account"
        // });
    }

     handleClickOnBackToLoginPageButton(event) {
        // sendEvent.call(this, { //Tagging Plan: line 23
        //     actionId: "cancel",
        //     categoryGa: "mylv",
        //     actionGa: "password_forgotten",
        //     labelGa: "cancel",
        //     actionPosition: "change_your_password"
        // });
        location.href = this.componentConfig.loginUrl;
     }


    handleOnBlur(event){
        this.clearFormErrors(); //added in order to avoid 2 lines of errors
        this.alternativeLoginForm.email.value = event.target.value;
        this.updateErrorIfEmailFieldIsInvalid(event.target.value);
    }
    handleEnter(event){
        if(event.keyCode === 13){
            // event.preventDefault();
            this.handleOnBlur(event);
            this.handleClickOnSubmitButton(event);
        }
    }
    handleClickOnSubmitButton(event) {
        if (this.isFormValid()) {
            this.validity = false;
            this.isSubmitButtonDisabled = true;
            //Tagging Plan: line 42
            sendEvent.call(this, { 
                actionId: 'one_click_login_intention',
                categoryGa:'mylv',
                actionGa:'connexion_module',
                labelGa:'one_click_login_intention',
                actionPosition:'i_already_have_an_account'
            });
            showPageLoader();
            this.clearFormErrors();
            this.requestAlternativeLogin();
        }
        else{
            const emailField = this.template.querySelector('[data-id="email"]');
            focusOnEmail(emailField);
            this.validity = true;
        }
        
    }

    /* Util methods **************************************************************************** */
    
    init() {
        this.oQueryParams = JSON.parse(this.queryParams);

        Promise.all([
            apexInitComponentConfig({queryParams: this.oQueryParams}),
            apexTranslateLabels({
                labels: [
                    'Twist_Forgot_Password_Form_LoginText',
                    'Twist_Login_Form_WelcomeBackTitle',
                    'Twist_Alternative_Login_Form_EmailSentSuccessfullyText',
                    'Twist_Alternative_Login_Form_IdentificationHintText',
                    'Twist_Forgot_Password_Form_EmailFieldLabel',
                    'Twist_Forgot_Password_Form_SubmitButtonLabel',
                    'Twist_Login_Form_DontHaveAccountText',
                    'Twist_Login_Form_CreateYourAccountText',
                    'Twist_Login_Form_Validation_Email_Format',
                    'Twist_Login_Form_UseAnAlternativeLogin'
                ],
                language: this.language
            })
        ])
        .then(result => {
            this.componentConfig = result[0];
            this.customLabels = result[1];
            if(this.oQueryParams.email) {
                this.user.email = isEmailValid(this.oQueryParams.email, this.componentConfig.AllowPlusSymbolInEmail) ? this.oQueryParams.email : '';
                this.alternativeLoginForm.email.value = this.user.email != null ? this.user.email : '';
            }
            this.setPageTitle();

        })
        .catch(error => {
            this.alternativeLoginForm.form.error = `Error: ${error}`;
        })
        .finally(() => {
            this.dispatchEvent(new CustomEvent('childlwcrendered', { detail: lwcNameToCamelCase(this.template.host.localName) }));
        });
    }

    requestAlternativeLogin() {
        apexAlternativeLogin({
            userEmail: this.alternativeLoginForm.email.value.trim(),
            language: this.language,
            langCountry: this.oQueryParams.langCountry,
            dispatchCountry: (this.oQueryParams.dispatchCountry ? this.oQueryParams.dispatchCountry : ''),
            origin: this.oQueryParams.origin
        })
        .then(response => {
             if (!response.success) {
                this.updateFormErrors(response);
            }
            else {
                this.isAlternativeLoginPage = true
            }
            this.isSubmitButtonDisabled = false;
            hidePageLoader();
        })
        .catch(error => {
            this.isSubmitButtonDisabled = false;
            hidePageLoader();
        });
    }

    isFormValid() {
        return !this.updateErrorIfEmailFieldIsInvalid(this.alternativeLoginForm.email.value);
    }

    clearFormErrors() {
        for (const key of Object.keys(this.alternativeLoginForm)) {
            this.alternativeLoginForm[key].error = null;
        }
    }

    /**
     * @param {Object} response
     */
    updateFormErrors(response) {
        delete response.success;
        for (const key of Object.keys(response)) {
            this.alternativeLoginForm[key].error = response[key];
        }
    }

    /**
     * @param {String} value
     * @return {Boolean} true if this field is invalid, false otherwise
     */
    updateErrorIfEmailFieldIsInvalid(value) {
        const isEmailFieldInvalid =  !isEmailValid(value, this.componentConfig.AllowPlusSymbolInEmail);
        this.alternativeLoginForm.email.error = isEmailFieldInvalid ? this.customLabels.Twist_Login_Form_Validation_Email_Format : null;
        return isEmailFieldInvalid;
    }
    
    setPageTitle() {
        document.title = this.customLabels.Twist_Login_Form_UseAnAlternativeLogin;
    }

}