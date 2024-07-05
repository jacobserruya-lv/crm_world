import { LightningElement, api, track} from 'lwc';
import Twist_UI from '@salesforce/resourceUrl/Twist_UI';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import socialMediaCreationAndLogin from "@salesforce/apex/TWIST_Account_Confirmation.socialMediaCreationAndLogin";

export default class TwistLoginModal extends LightningElement {

    @api showModal;
    @api language;
    @api email;
    @api socialParams;
    @api oQueryParams;
    @api forgotPasswordUrl;
    @api passwordMaxlength;

    @track customLabels = {};
    @track password;
    @track eyeIconSrcPassword;
    @track isPasswordShown = false;
    @track errorMessage;
    @track loading;

    twistEyeIcon = Twist_UI + "/visibility-stroke.svg";
    twistEyeStrikeThroughIcon = Twist_UI + "/visibility.svg";

    twistCloseIcon = Twist_UI + '/close-image.png';

    // constructor() {
    //     super();
    //     this.isPasswordShown = false;
    //     this.updateEyeIconSrcPassword();
    //     this.showModal = false;
    // }
   
    handleOnLogIn() {
        this.loading = true;
        this.errorMessage = undefined;
        try{
            socialMediaCreationAndLogin({email: this.email, password: this.password, socialParams: this.socialParams, queryParams: this.oQueryParams})
                .then((response)=> {
                    this.loading = false;
                    if(response.success){
                        location.href = response.redirectUrl;
                    }
                    else{
                        this.errorMessage = response.form
                    }
                })
            }catch (error) {
                this.errorMessage = error;
            }        
        }
    handleClickOnForgotPasswordLink() {
        location.href = this.forgotPasswordUrl;
            //Tagging Plan: line 10
            sendEvent.call(this, {
                actionId: 'forgot_your_password',
                categoryGa:'mylv',
                actionGa:'forgot_your_password',
                actionPosition:'i_already_have_an_account'
            });
    }       
    connectedCallback() {
        this.init();
    }
    renderedCallback(){
        this.updateEyeIconSrcPassword();
    }
    init() {
        apexTranslateLabels({
            labels: [
                'Twist_Login_Form_PasswordFieldLabel',
                'Twist_Forgot_Password_Form_LoginText',
                'Twist_Account_Creation_EmailAlreadyRegistered',
                'Twist_Login_Form_ForgotPasswordLink'
            ],
            language: this.language
        })
        .then(result => {
            this.customLabels = result;
        })
        .catch(error => {
            console.error('error', error);
        });
    }
    get passwordFieldCssClass() {
        return 'form__input_password eye-icon__wrapper';
    }
    get passwordFieldType() {
        return this.isPasswordShown ? "text" : "password";
    }
    get eyeIconSrcConfirmPassword() {
        return this.isConfirmPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }
    toggleShowPassword(event) {
        this.isPasswordShown = !this.isPasswordShown;
        this.updateEyeIconSrcPassword();
    }
    handleFormPasswordChange(event){
       this.password = event.target.value;
    }
    updateEyeIconSrcPassword() {
        this.eyeIconSrcPassword = this.isPasswordShown ? this.twistEyeStrikeThroughIcon : this.twistEyeIcon;
    }
}