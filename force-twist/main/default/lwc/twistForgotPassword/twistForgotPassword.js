import { LightningElement, track, api } from 'lwc';

import Twist_UI from '@salesforce/resourceUrl/Twist_UI';
import apexInitComponentConfig from '@salesforce/apex/TWIST_ResetPassword.initForgotPasswordComponentConfig';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import apexRequestResetPassword from '@salesforce/apex/TWIST_ResetPassword.requestResetPassword';

import {
    showPageLoader,
    hidePageLoader,
    isEmailValid,
    sendPageView,
    sendEvent,
    lwcNameToCamelCase
} from 'c/twistUtils';

export default class TwistForgotPassword extends LightningElement {

    /* Component properties ******************************************************************** */

    @api queryParams;
    @api autodata;
    oQueryParams;

    twistArrowIcon = Twist_UI + '/arrow-back.svg';

    @api language;
    @track isSubmitButtonDisabled = false;
    @track componentConfig = {};
    @track customLabels = {};
    @track user = {
        email: null
    };
    @track forgotPasswordForm = {
        form: { error: null }, // stores general form errors eventually
        email: { value: null, error: null }
    };
    @track isResetPasswordEmailSent = false;

    /* Getters ********************************************************************************* */

    get emailFieldCssClass() {
        return 'form__input_email email_forget_password' + (this.forgotPasswordForm.email.error||this.forgotPasswordForm.form.error ? ' error' : '');
    }

    get linkToRegistration() {
        return this.componentConfig.registrationUrl;
    }

    /* Component life cycle ******************************************************************** */

    connectedCallback() {
        this.init();
    }

    renderedCallback(){
         this.oQueryParams.hasOwnProperty("token-invalid-error-message") ? this.forgotPasswordForm.form.error = this.customLabels.Twist_Forgot_Password_Form_errorMessageWhenResetPasswordFailed : '';
    }
    
    /* Event handlers ************************************************************************** */
    
    handleTwistGaLwcRendered() {
        sendPageView.call(this); // Tagging Plan: line 22
    }

    handleClickOnLinkToRegistration(e) {
        sendEvent.call(this, {
            actionId: "create_new_account", //Tagging Plan: line 27
            categoryGa: "mylv",
            actionGa: "password_forgotten",
            labelGa: "create_new_account",
            actionPosition: "i_dont_have_an_account"
        });
    }

    handleClickOnBackToLoginPageButton(event) {
        sendEvent.call(this, { //Tagging Plan: line 23
            actionId: "cancel",
            categoryGa: "mylv",
            actionGa: "password_forgotten",
            labelGa: "cancel",
            actionPosition: "change_your_password"
        });
        location.href = this.componentConfig.loginUrl;
    }

    handleFormEmailChange(event){
        this.forgotPasswordForm.email.value = event.target.value;
        this.updateErrorIfEmailFieldIsInvalid(event.target.value);
    }

    handleClickOnSubmitButton(event) {
        if (this.isFormValid()) {
            this.isSubmitButtonDisabled = true;
            sendEvent.call(this, { //Tagging Plan: line 24
                actionId: "reset_password",
                categoryGa: "mylv",
                actionGa: "password_forgotten",
                labelGa: "reset_password",
                actionPosition: "change_your_password"
            });
            showPageLoader();
            this.clearFormErrrors();
            this.doRequestResetPassword();
        }
    }

    /* Util methods **************************************************************************** */
    
    init() {
        this.oQueryParams = JSON.parse(this.queryParams);
        Promise.all([
            apexInitComponentConfig({queryParams: this.oQueryParams}),
            apexTranslateLabels({
                labels: [
                    'Twist_Forgot_Password_Form_ChangeYourPasswordTitle',
                    'Twist_Forgot_Password_Form_ChangeYourPasswordHintText',
                    'Twist_Forgot_Password_Form_EmailFieldLabel',
                    'Twist_Forgot_Password_Form_SubmitButtonLabel',
                    'Twist_Login_Form_DontHaveAccountText',
                    'Twist_Login_Form_CreateYourAccountText',
                    'Twist_Login_Form_Validation_Email_Format',
                    'Twist_Forgot_Password_Form_LoginText',
                    'Twist_Forgot_Password_Form_errorMessageWhenResetPasswordFailed',
                    'Twist_Forgot_Password_Form_EmailSentSuccessfullyText'
                ],
                language: this.language
            })
        ])
        .then(result => {
            this.componentConfig = result[0];
            this.customLabels = result[1];
            if(this.oQueryParams.email) {
                this.user.email = isEmailValid(this.oQueryParams.email, this.componentConfig.AllowPlusSymbolInEmail) ? this.oQueryParams.email : '';
                this.forgotPasswordForm.email.value = this.user.email != null ? this.user.email : '';
            }
        })
        .catch(error => {
            this.forgotPasswordForm.form.error = `Error: ${error}`;
        })
        .finally(() => {
            this.dispatchEvent(new CustomEvent('childlwcrendered', { detail: lwcNameToCamelCase(this.template.host.localName) }));
        });
    }

    doRequestResetPassword() {
        apexRequestResetPassword({
            userEmail: this.forgotPasswordForm.email.value.trim(),
            language: this.language,
            langCountry: this.oQueryParams.langCountry,
            dispatchCountry: (this.oQueryParams.dispatchCountry ? this.oQueryParams.dispatchCountry : ''),
            origin: this.oQueryParams.origin,
            sessionInfo: this.oQueryParams.sessionInfo
        })
        .then(response => {
            if (!response.success) {
                this.updateFormErrors(response);
            }
            else {
                this.isResetPasswordEmailSent = true;
                if(response.hasOwnProperty('seenf')) {
                    sendEvent.call(this, { //Tagging Plan: line 25
                        event: "resetPasswordFailure",
                        actionId: "email_not_found",
                        categoryGa: "mylv",
                        actionGa: "password_forgotten",
                        labelGa: "email_not_found"
                    });
                }
                if(response.hasOwnProperty('serps')) {
                    sendEvent.call(this, { //Tagging Plan: line 26
                        event: "resetPasswordSuccess",
                        actionId: "email_sent",
                        categoryGa: "mylv",
                        actionGa: "password_forgotten",
                        labelGa: "email_sent"
                    });
                }
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
        return !this.updateErrorIfEmailFieldIsInvalid(this.forgotPasswordForm.email.value);
    }

    clearFormErrrors() {
        for (const key of Object.keys(this.forgotPasswordForm)) {
            this.forgotPasswordForm[key].error = null;
        }
    }

    /**
     * @param {Object} response
     */
    updateFormErrors(response) {
        delete response.success;
        for (const key of Object.keys(response)) {
            this.forgotPasswordForm[key].error = response[key];
        }
    }

    /**
     * @param {String} value
     * @return {Boolean} true if this field is invalid, false otherwise
     */
    updateErrorIfEmailFieldIsInvalid(value) {
        const isEmailFieldInvalid =  !isEmailValid(value, this.componentConfig.AllowPlusSymbolInEmail);
        this.forgotPasswordForm.email.error = isEmailFieldInvalid ? this.customLabels.Twist_Login_Form_Validation_Email_Format : null;
        return isEmailFieldInvalid;
    }

}