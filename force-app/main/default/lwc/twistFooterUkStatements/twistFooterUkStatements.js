import { LightningElement, api, track } from 'lwc';
import Twist_UI from '@salesforce/resourceUrl/Twist_UI';

export default class TwistFooterUkStatements extends LightningElement {
    @api isMobileVersion;
    @api ukStatementConfig;
    
    @track wrapperClassName;
    
    twistCloseIcon = Twist_UI + '/Close.svg';
    
    hideMsaTransparencySection() {
        this.dispatchEvent(new Event('hidemsatransparencysection'));
    }
    
    connectedCallback() {
        const isMobileVersion = (/true/i).test(this.isMobileVersion);
        this.wrapperClassName = isMobileVersion ? 'msaTransparencyMobile' : 'msaTransparency';
    }
}