import { LightningElement, api, track } from 'lwc';
import Twist_UI from '@salesforce/resourceUrl/Twist_UI';

export default class TwistFooterSocialMedia extends LightningElement {
    
    @api isMobileVersion;
    @api socialMediaConfig;
    @api socialMediaCloseIconSide;
    @track closeIconClassName;
    
    @track wrapperClassName;
    
    twistCloseIcon = Twist_UI + '/Close.svg';
    
    hideSocialMedia() {
        this.dispatchEvent(new Event('hidesocialmedia'));
    }
    
    connectedCallback() {
        const isMobileVersion = (/true/i).test(this.isMobileVersion);
        this.wrapperClassName = isMobileVersion ? 'followUsMobile' : 'followUs';
        this.socialMediaCloseIconSide == 'ara' ?  this.closeIconClassName = 'closeIconRight': this.closeIconClassName = 'closeIconLeft';
    }
    
}