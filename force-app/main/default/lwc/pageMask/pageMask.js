import { LightningElement, track, api } from 'lwc';
import loaderImage from '@salesforce/resourceUrl/Twist_loader';

export default class PageMask extends LightningElement {

    @api show = false;
    @track maskWrapperClassName;
    loaderSrc = loaderImage;

    connectedCallback() {
        this.showMask(this.show);
    }

    errorCallback(error, stack) {
        console.error(error);
    }

    /**
     * @param {Boolean} doShow
     */
    @api showMask(doShow) {
        this.maskWrapperClassName = doShow ? 'slds-show' : 'slds-hide';
    }

}