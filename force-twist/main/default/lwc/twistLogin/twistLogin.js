import { LightningElement, track, api } from 'lwc';

import Twist_UI from '@salesforce/resourceUrl/Twist_UI';
import apexInitComponentConfig from '@salesforce/apex/TWIST_Login.initComponentConfig';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import apexLogin from '@salesforce/apex/TWIST_Login.login';
import isAlternativeLoginEnabled from '@salesforce/apex/TWIST_Login.isAlternativeLoginEnabled';
import isLineButtonEnabled from '@salesforce/apex/TWIST_Login.isLineButtonEnabled';

import {
    clearFormErrrors,
    updateFormErrors,
    showPageLoader,
    hidePageLoader,
    isEmailValid,
    sendPageView,
    sendEvent,
    lwcNameToCamelCase
} from 'c/twistUtils';

export default class TwistLogin extends LightningElement {

    /* Component properties ******************************************************************** */

    @api queryParams;
    @api autodata;
    oQueryParams;

    twistLineLogo = Twist_UI + '/Twist_Line_Social_Login_Logo.svg';
    twistEyeIcon = Twist_UI + '/visibility-stroke.svg' ;
    twistEyeStrikeThroughIcon = Twist_UI + '/visibility.svg' ;

    @api language;
    
    @track isPasswordShown;
    @track isLoginButtonDisabled = false;
    @track showOTCLink = false;
    @track eyeIconSrc;
    @track componentConfig = {};
    @track customLabels = {};
    @track loginForm = {
        form: { error: null }, // stores general form errors eventually
        email: { value: null, error: null },
        password: { value: null, error: null, type: null }
    };
    @track socialMediaProviders = {};
    @track showLineButtonAccordingOrigin = false;

    /* Getters ********************************************************************************* */

    get emailFieldCssClass() {
        return 'form__input_email' + (this.loginForm.email.error || this.loginForm.form.error ? ' error' : '');
    }

    get passwordFieldCssClass() {
        return 'form__input_password eye-icon__wrapper' + (this.loginForm.password.error || this.loginForm.form.error ? ' error' : '');
    }

    get linkToRegistration() {
        let urlSplit = location.href.split('?');
        return this.componentConfig.registrationBaseUrl + '?' + urlSplit[1] + (this.oQueryParams.dispatchCountry ? '&dispatchCountry=' + this.oQueryParams.dispatchCountry : '');
    }
    get showLineButton() {
        return this.socialMediaProviders.LineLV && this.showLineButtonAccordingOrigin;
    }
    /* Component life cycle ******************************************************************** */

    constructor() {
        super();
        this.isPasswordShown = false;
        this.updateEyeIconSrc();
        this.updatePasswordFieldType();
    }

    connectedCallback() {
        this.init();
    }

    /* Event handlers ************************************************************************** */

    handleTwistGaLwcRendered() {
        sendPageView.call(this); // Tagging Plan: line 9
    }
    
    handleClickOnLinkToRegistration(e) {
        //Tagging Plan: line 11
        sendEvent.call(this, {
            actionId : 'create_new_account',
            actionGa :'create_new_account',
            categoryGa :'mylv',
            actionPosition : 'i_dont_have_an_account'
        });
    }

    handleFormEmailChange(event){
        this.loginForm.form.error = null
        this.loginForm.email.value = event.target.value;
        this.updateErrorIfEmailFieldIsInvalid(event.target.value)
    }

    handleFormPasswordChange(event){
        this.loginForm.form.error = null
        this.loginForm.password.value = event.target.value;
        this.updateErrorIfPasswordFieldIsInvalid(event.target.value)
    }
    
    handleClickOnForgotPasswordLink() {
        location.href = this.componentConfig.forgotPasswordUrl;
        //Tagging Plan: line 10
        sendEvent.call(this, {
            actionId: 'forgot_your_password',
            categoryGa:'mylv',
            actionGa:'forgot_your_password',
            actionPosition:'i_already_have_an_account'
        });
    }

    handleClickOnUseAnAlternativeLoginLink() {
        location.href = this.componentConfig.alternativeLoginUrl;
            //Tagging Plan: line 41
            sendEvent.call(this, {
                actionId: 'one_click_login_request',
                categoryGa:'mylv',
                actionGa:'connexion_module',
                labelGa : 'one_click_login_request',
                actionPosition:'i_already_have_an_account'
            });
    }
    
    handleClickOnLoginButton(event) {
        if(this.isFormValid()) {
            this.isLoginButtonDisabled = true;
            //Tagging Plan: line 12
            sendEvent.call(this, {
                actionId: 'sign_in_intention',
                categoryGa:'mylv',
                actionGa:'i_already_have_an_account',
                labelGa : 'sign_in_intention',
                actionPosition:'i_already_have_an_account'
            });
            showPageLoader();
            clearFormErrrors(this.loginForm);

            this.doLogin();
            
        }
    }

    /* Util methods **************************************************************************** */
            
    init() {
        this.oQueryParams = JSON.parse(this.queryParams);   
        Promise.all([
            apexInitComponentConfig({queryParams: this.oQueryParams}),
            apexTranslateLabels({
                labels: [
                    'Twist_Login_Form_PageTitle',
                    'Twist_Login_Form_WelcomeBackTitle',
                    'Twist_Login_Form_WelcomeBackHintText',
                    'Twist_Login_Form_EmailFieldLabel',
                    'Twist_Login_Form_PasswordFieldLabel',
                    'Twist_Login_Form_ForgotPasswordLink',
                    'Twist_Login_Form_UseAnAlternativeLogin',
                    'Twist_Login_Form_SubmitButtonLabel',
                    'Twist_Login_Form_DontHaveAccountText',
                    'Twist_Login_Form_CreateYourAccountText',
                    'Twist_Login_Form_Validation_Email_Format',
                    'Twist_Login_Form_Validation_Password_Empty',
                    'Twist_Login_Form_UseAlternativeLoginLinkToSignIn',
                    'Twist_Login_Page_Social_Login_Line',
                    'Twist_Social_Line_Text_For_Second_Option'
                ],
                language: this.language
            }),
            isAlternativeLoginEnabled({langCountry: this.oQueryParams.langCountry, origin:  this.oQueryParams.origin}),
            isLineButtonEnabled({langCountry: this.oQueryParams.langCountry, origin:  this.oQueryParams.origin})
        ])
        .then(result => {
            this.componentConfig = result[0];
            this.customLabels = result[1];
            this.socialMediaProviders = result[0]?.socialMediaProviders;
            if (this.componentConfig.isRedirectToRegistration) {
                this.redirectToRegistration();
                return;
            }
            this.showOTCLink = result [2]; 
            this.showLineButtonAccordingOrigin = result [3];
            this.setPageTitle();
            //TODO
            // if(result[0].mode === "SOCIAL_REGISTRATION") {
            //     isSocialLoginVisible = false;
            // }
        })
        .catch(error => {
            this.loginForm.form.error = `Error: ${error}`;
        })
        .finally(() => {
            if (!this.componentConfig.isRedirectToRegistration) {
                this.dispatchEvent(new CustomEvent('childlwcrendered', { detail: lwcNameToCamelCase(this.template.host.localName) }));
            }
        });
    }

    doLogin() {
        apexLogin({
            email: this.loginForm.email.value ? this.loginForm.email.value : '',
            password: this.loginForm.password.value,
            queryParams: this.oQueryParams,
            language: this.componentConfig.language
        })
        .then(response => {
            if (!response.success) {
                updateFormErrors(this.loginForm, response);
                if (this.loginForm.form.error) {
                    this.template.querySelector('.global-error-message').scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
                }
                this.isLoginButtonDisabled = false;
                //Tagging Plan: line 13
                sendEvent.call(this, {
                    event:'logInFailure',
                    actionId: 'sign_in_failed',
                    categoryGa:'mylv',
                    actionGa:'connexion_module',
                    labelGa:'sign_in_failed',
                    actionPosition:'i_already_have_an_account'
                });
                hidePageLoader();
            }
            else {
                //Tagging Plan: line 14
                sendEvent.call(this, {
                    event:'logInSuccess',
                    actionId: 'sign_in_succeeded',
                    categoryGa:'mylv',
                    actionGa:'connexion_module',
                    labelGa:'sign_in_succeeded',
                    actionPosition:'i_already_have_an_account'
                });
                location.href = response.redirectUrl;
            }
        })
        .catch(error => {
            this.isLoginButtonDisabled = false;
            hidePageLoader();
        });
    }

    toggleShowPassword(event) {
        this.isPasswordShown = !this.isPasswordShown;
        this.updateEyeIconSrc();
        this.updatePasswordFieldType();
    }

    updateEyeIconSrc() {
        this.eyeIconSrc = this.isPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }

    updatePasswordFieldType() {
        this.loginForm.password.type = this.isPasswordShown ? 'text' : 'password';
    }

    /**
     * @param {String} value
     * @return {Boolean} true if this field is invalid, false otherwise
     */
    updateErrorIfEmailFieldIsInvalid(value) {
        const isEmailFieldInvalid =  !isEmailValid(value, this.componentConfig.AllowPlusSymbolInEmail);
        this.loginForm.email.error = isEmailFieldInvalid ? this.customLabels.Twist_Login_Form_Validation_Email_Format : null;
        return isEmailFieldInvalid;
    }

    /**
     * @param {String} value
     * @return {Boolean} true if this field is invalid, false otherwise
     */
     updateErrorIfPasswordFieldIsInvalid(value) {
        const isPasswordFieldInvalid = !this.isPasswordFieldValid(value);
        this.loginForm.password.error = isPasswordFieldInvalid ? this.customLabels.Twist_Login_Form_Validation_Password_Empty : null;
        return isPasswordFieldInvalid;
    }

    /**
     * @param {String} value
     * @return {Boolean}
     */
    isPasswordFieldValid(value) {
        return typeof value === 'string' && value.length !== 0;
    }

    /**
     * @return {Boolean}
     */
     isFormValid() {
        return this.componentConfig.showUsernameField
            ? !this.updateErrorIfEmailFieldIsInvalid(this.loginForm.email.value) && !this.updateErrorIfPasswordFieldIsInvalid(this.loginForm.password.value)
            : !this.updateErrorIfPasswordFieldIsInvalid(this.loginForm.password.value);
    }

    setPageTitle() {
        document.title = this.customLabels.Twist_Login_Form_PageTitle;
    }
    
    redirectToRegistration(){
        //TO DO IN FUTURE GOOGLE ANALYTICS SEND EVENT
        let urlSplit = location.href.split("?");
        location.href = this.componentConfig.registrationBaseUrl
        + "?"
        + urlSplit[1]
        + (this.oQueryParams.dispatchCountry ? "&dispatchCountry=" + this.oQueryParams.dispatchCountry : "");
    }
}