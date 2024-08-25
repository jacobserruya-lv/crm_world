import { LightningElement, api, track } from 'lwc';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import validIcon from '@salesforce/resourceUrl/Twist_check_icon';
import invalidIcon from '@salesforce/resourceUrl/Twist_circle_icon';

export default class TwistPasswordValidityCriteria extends LightningElement {

    @track customLabels = {};
    @track iconHasHeightChars = invalidIcon;
    @track iconHasDigit = invalidIcon;
    @track iconHasUpperCaseLetter = invalidIcon;
    @track iconHasLowerCaseLetter = invalidIcon;
    @track iconHasSpecialChar = invalidIcon;

    @api language;

    wrapperElement = null;
    
    connectedCallback() {
        this.wrapperElement = this.template.querySelector('.wrapper');
        apexTranslateLabels({
            labels: [
                'Twist_Reset_Password_Form_Validation_PasswordCriteriaTitle',
                'Twist_Reset_Password_Form_Validation_PasswordCriteriaHasHeightChars',
                'Twist_Reset_Password_Form_Validation_PasswordCriteriaHasDigit',
                'Twist_Reset_Password_Form_Validation_PasswordCriteriaHasUpperCaseLetter',
                'Twist_Reset_Password_Form_Validation_PasswordCriteriaHasLowerCaseLetter',
                'Twist_Reset_Password_Form_Validation_PasswordCriteriaHasSpecialChar'
            ],
            language: this.language
        })
        .then(result => { this.customLabels = result })
        .catch(console.error);
    }

    errorCallback(error, stack) {
        console.error(error);
    }

    /**
     * @param {Boolean} doShow
     */
    @api
    show(doShow) {
        if(!this.wrapperElement){
            this.wrapperElement = this.template.querySelector('.wrapper');
        }
        const method = doShow ? 'add' : 'remove';
        this.wrapperElement.classList[method]('visible');
    }

    /**
     * @param {Boolean} status
     */
    @api
    setCheckIconRegardingCriteria_HasHeightChars(status) {
        this.iconHasHeightChars = status ? validIcon : invalidIcon;
    }

    /**
     * @param {Boolean} status
     */
     @api
     setCheckIconRegardingCriteria_HasDigit(status) {
         this.iconHasDigit = status ? validIcon : invalidIcon;
     }

    /**
     * @param {Boolean} status
     */
     @api
     setCheckIconRegardingCriteria_HasUpperCaseLetter(status) {
         this.iconHasUpperCaseLetter = status ? validIcon : invalidIcon;
     }
    /**
     * @param {Boolean} status
     */

     @api
     setCheckIconRegardingCriteria_HasLowerCaseLetter(status) {
         this.iconHasLowerCaseLetter = status ? validIcon : invalidIcon;
     }

    /**
     * @param {Boolean} status
     */
     @api
     setCheckIconRegardingCriteria_HasSpecialChar(status) {
         this.iconHasSpecialChar = status ? validIcon : invalidIcon;     }

     get classHasHeightChars() {
        return this.iconHasHeightChars == validIcon ? 'validText' : 'invalidText';
     }
     get classHasDigit() {
        return this.iconHasDigit == validIcon ? 'validText' : 'invalidText';
     }
     get classHasUpperCaseLetter() {
        return this.iconHasUpperCaseLetter == validIcon ? 'validText' : 'invalidText';
     }
     get classHasLowerCaseLetter() {
        return this.iconHasLowerCaseLetter == validIcon ? 'validText' : 'invalidText';  
     }
     get classHasSpecialChar() {
        return this.iconHasSpecialChar == validIcon ? 'validText' : 'invalidText';
     }

}