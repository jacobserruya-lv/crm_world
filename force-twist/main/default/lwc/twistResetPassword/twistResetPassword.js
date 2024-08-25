import { LightningElement, track, api } from 'lwc';

import Twist_UI from '@salesforce/resourceUrl/Twist_UI';
import apexValidateToken from '@salesforce/apex/TWIST_ResetPassword.validateToken';
import apexGetUserInfo from '@salesforce/apex/TWIST_ResetPassword.getUserByResetPasswordToken';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import apexDoResetPassword from '@salesforce/apex/TWIST_ResetPassword.doResetPassword';

import {
    showPageLoader,
    hidePageLoader,
    clearFormErrrors,
    updateFormErrors,
    hasHeightChars,
    hasDigit,
    hasUpperCaseLetter,
    hasLowerCaseLetter,
    hasSpecialChar,
    doesPasswordMatchStringPattern,
    sendPageView,
    sendEvent,
    lwcNameToCamelCase
} from 'c/twistUtils';

export default class TwistResetPassword extends LightningElement {
    
    /* Component properties ******************************************************************** */

    @api queryParams;
    @api autodata;
    oQueryParams;
    
    passwordValidityCriteriaElt = null;
    twistEyeIcon = Twist_UI + '/visibility-stroke.svg';
    twistEyeStrikeThroughIcon = Twist_UI + '/visibility.svg';
    maxPasswordLength = 20; // JSI rather get this value via a service
    isComponentRendered = false;
    
    @api language;
    
    @track isSubmitButtonDisabled = false;
    @track customLabels = {};
    @track resetPasswordForm = {
        form: { error: null }, // stores general form errors eventually
        password: { value: null, error: null, type: null },
        confirmPassword: { value: null, error: null, type: null }
    };
    @track user = {
        email: null,
        firstName: null,
        lastName: null
    };
    @track eyeIconSrcPassword;
    @track eyeIconSrcConfirmPassword;
    @track isPasswordShown;
    @track isConfirmPasswordShown;
    
    /* Getters ********************************************************************************* */
    
    get passwordFieldCssClass() {
        return 'form__input_password eye-icon__wrapper' + (this.resetPasswordForm.password.error ? ' error' : '');
    }

    get confirmPasswordFieldCssClass() {
        return 'form__input_password eye-icon__wrapper' + (this.resetPasswordForm.confirmPassword.error ? ' error' : '');
    }
    
    /* Component life cycle ******************************************************************** */
    
    constructor() {
        super();
        this.isPasswordShown = false;
        this.isConfirmPasswordShown = false;
        this.updateEyeIconSrcPassword();
        this.updateEyeIconSrcConfirmPassword();
        this.updatePasswordFieldType();
        this.updateConfirmPasswordFieldType();
    }

    connectedCallback() {
        this.oQueryParams = JSON.parse(this.queryParams);
        apexValidateToken({
            language: this.language,
            queryParams: this.oQueryParams
        })
        .then(response => {
            if (!response.success && response.redirectUrl) {
                location.href = response.redirectUrl;
            }
            this.init();
        })
        .catch(error => {
            console.error(error);
        });
    }

    renderedCallback() {
        this.isComponentRendered = true;
        this.passwordValidityCriteriaElt = this.template.querySelector('c-twist-password-validity-criteria');
    }

    errorCallback(error, stack) {
        console.error(error);
    }
    
    /* Event handlers ************************************************************************** */

    handleTwistGaLwcRendered() {
        sendPageView.call(this); // Tagging Plan: line 64
    }

    handleFormPasswordChange(event){
        if (this.isComponentRendered) {
            const password = event.target.value;
            this.resetPasswordForm.password.value = password;
    
            this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasHeightChars(hasHeightChars(password));
            this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasDigit(hasDigit(password));
            this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasUpperCaseLetter(hasUpperCaseLetter(password));
            this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasLowerCaseLetter(hasLowerCaseLetter(password));
            this.passwordValidityCriteriaElt.setCheckIconRegardingCriteria_HasSpecialChar(hasSpecialChar(password));
    
            this.showErrorIfPasswordIsEmpty()
                || this.showErrorIfPasswordContainsEmail()
                || this.showErrorIfPasswordContainsFirstOrLastNames()
                || this.showErrorIfPasswordDoesNotMatchValidityCriteria()
                || this.showErrorIfPasswordIsTooLong();
        }
    }
    
    handleFormPasswordFocus(handleFormPasswordFocus){
        this.passwordValidityCriteriaElt.show(true);
    }
    
    handleFormPasswordBlur(event){
        this.passwordValidityCriteriaElt.show(false);
    }
    
    handleFormConfirmPasswordChange(event){
        this.resetPasswordForm.confirmPassword.value = event.target.value;
        this.showErrorIfFieldIsEmpty() || this.showErrorIfPasswordsMismatch();
    }
    
    handleClickOnSubmitButton(e) {
        sendEvent.call(this, { // Tagging Plan: line 65
            actionId: "update_password",
            categoryGa: "mylv",
            actionGa: "update_password"
        });
        if (this.isFormValid()) {
            showPageLoader();
            this.isSubmitButtonDisabled = true;
            clearFormErrrors(this.resetPasswordForm);
            this.doResetPassword();
        }
    }
    
    /* Util methods **************************************************************************** */

    init() {
        Promise.all([
            apexGetUserInfo({
                token: this.oQueryParams.token,
                language: this.language
            }),
            apexTranslateLabels({
                labels: [
                    'Twist_Reset_Password_Form_ResetYourPasswordTitle',
                    'Twist_Reset_Password_Form_YourEmailText',
                    'Twist_Reset_Password_Form_EnterNewPasswordText',
                    'Twist_Reset_Password_Form_PasswordFieldLabel',
                    'Twist_Reset_Password_Form_ConfirmPasswordFieldLabel',
                    'Twist_Reset_Password_Form_Validation_PasswordsDoNotMatch',
                    'Twist_Reset_Password_Form_Validation_PasswordContainsEmail',
                    'Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames',
                    'Twist_Reset_Password_Form_Validation_PasswordDoesNotMatchValidityCriteria',
                    'Twist_Reset_Password_Form_Validation_PasswordIsTooLong',
                    'Twist_Reset_Password_Form_Validation_WordCharacters',
                    'Twist_Reset_Password_Form_SubmitButtonLabel',
                    'Twist_Form_FieldCantBeEmpty'
                ],
                language: this.language
            })
        ])
        .then(result => {
            this.setUser(result[0]);
            this.setCustomLabels(result[1]);
        })
        .catch(error => {
            this.resetPasswordForm.form.error = `Error: ${error}`;
        })
        .finally(() => {
            this.dispatchEvent(new CustomEvent('childlwcrendered', { detail: lwcNameToCamelCase(this.template.host.localName) }));
        });
    }

    doResetPassword() {
        apexDoResetPassword({
            password: this.resetPasswordForm.password.value,
            confirmPassword: this.resetPasswordForm.confirmPassword.value,
            language: this.language,
            queryParams: this.oQueryParams
        })
        .then(response => {
            if (!response.success) {
                if (response.redirectUrl) {
                    location.href = response.redirectUrl;
                    return;
                }
                updateFormErrors(this.resetPasswordForm,response);
            }
            else {
                location.href = response.redirectUrl;
            }
            this.isSubmitButtonDisabled = false;
            hidePageLoader();
        })
        .catch(error => {
            console.error(error);
            this.isSubmitButtonDisabled = false;
            hidePageLoader();
        });
    }

    /**
     * @param {Object} customLabels
     */
    setCustomLabels(customLabels) {
        this.customLabels = customLabels;
    }

    /**
     * @param {Object} response
     */
    setUser(response) {
        if (!response.success) {
            updateFormErrors(this.resetPasswordForm, response);
        }
        else {
            delete response.success;
            this.user = response;
        }
    }
    
    isFormValid() {
            return !this.showErrorIfFieldIsEmpty()
            && !this.showErrorIfPasswordContainsEmail()
            && !this.showErrorIfPasswordContainsFirstOrLastNames()
            && !this.showErrorIfPasswordDoesNotMatchValidityCriteria()
            && !this.showErrorIfPasswordIsTooLong()
            && !this.showErrorIfPasswordsMismatch();
    }

    /**
    * @returns {Boolean} true if error found, false otherwise
    */
     showErrorIfPasswordIsTooLong() {
        this.resetPasswordForm.password.error = null;
        if (this.resetPasswordForm.password.value && this.resetPasswordForm.password.value.length > this.maxPasswordLength) {
            this.resetPasswordForm.password.error = `${this.customLabels.Twist_Reset_Password_Form_Validation_PasswordIsTooLong} ${this.maxPasswordLength} ${this.customLabels.Twist_Reset_Password_Form_Validation_WordCharacters}`;
            return true;
        }
        return false;
    }
    
    /**
    * @returns {Boolean} true if error found, false otherwise
    */
    showErrorIfPasswordsMismatch() {
        this.resetPasswordForm.confirmPassword.error = null;
        if (this.resetPasswordForm.confirmPassword.value == null) {
            this.resetPasswordForm.confirmPassword.error = this.customLabels.Twist_Form_FieldCantBeEmpty;
            return true;
            }
        if (this.resetPasswordForm.password.value !== this.resetPasswordForm.confirmPassword.value) {
            this.resetPasswordForm.confirmPassword.error = this.customLabels.Twist_Reset_Password_Form_Validation_PasswordsDoNotMatch;
            return true;
        }
        return false;
    }
    
    /**
    * @returns {Boolean} true if error found, false otherwise
    */
    showErrorIfPasswordContainsEmail() {
        if (!this.isComponentRendered) {
            return false;
        }
        this.resetPasswordForm.password.error = null;
        let password = this.resetPasswordForm.password.value;
        if (password) {
            password = password.toLowerCase();
            if (password.includes(this.user.email?.toLowerCase())) {
                this.resetPasswordForm.password.error = this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsEmail;
                return true;
            }
        }
        return false;
    }

    /**
    * @returns {Boolean} true if error found, false otherwise
    */
     showErrorIfPasswordContainsFirstOrLastNames() {
        this.resetPasswordForm.password.error = null;
        let password = this.resetPasswordForm.password.value;
        if (password) {
            password = password.toLowerCase();
            if (password.includes(this.user.firstName?.toLowerCase()) || password.includes(this.user.lastName?.toLowerCase())) {
                this.resetPasswordForm.password.error = this.customLabels.Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames;
                return true;
            }
        }
        return false;
    }

    /**
    * @returns {Boolean} true if error found, false otherwise
    */
    showErrorIfPasswordDoesNotMatchValidityCriteria() {
        if (!doesPasswordMatchStringPattern(this.resetPasswordForm.password.value)) {
            this.resetPasswordForm.password.error = this.customLabels.Twist_Reset_Password_Form_Validation_PasswordDoesNotMatchValidityCriteria;
            return true;
        }
        return false;
    }

    /**
    * @returns {Boolean} true if error found, false otherwise
    */
    showErrorIfFieldIsEmpty(){
        if (this.resetPasswordForm.password.value == null) {
            this.resetPasswordForm.password.error = this.customLabels.Twist_Form_FieldCantBeEmpty;
            return true;
        }
        return false;
    }

    /**
    * @returns {Boolean} true if error found, false otherwise
    */
    showErrorIfPasswordIsEmpty() {
        return this.showErrorIfFieldIsEmpty();
    }
    
    toggleShowPassword(event) {
        this.isPasswordShown = !this.isPasswordShown;
        this.updateEyeIconSrcPassword();
        this.updatePasswordFieldType();
    }
    
    toggleShowConfirmPassword(event) {
        this.isConfirmPasswordShown = !this.isConfirmPasswordShown;
        this.updateEyeIconSrcConfirmPassword();
        this.updateConfirmPasswordFieldType();
    }
    
    updateEyeIconSrcPassword() {
        this.eyeIconSrcPassword = this.isPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }
    
    updateEyeIconSrcConfirmPassword() {
        this.eyeIconSrcConfirmPassword = this.isConfirmPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }
    
    updatePasswordFieldType() {
        this.resetPasswordForm.password.type = this.isPasswordShown ? 'text' : 'password';
    }
    
    updateConfirmPasswordFieldType() {
        this.resetPasswordForm.confirmPassword.type = this.isConfirmPasswordShown ? 'text' : 'password';
    }
    
}