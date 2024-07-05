import { LightningElement, api, track } from 'lwc';

import Twist_UI from '@salesforce/resourceUrl/Twist_UI';
import apexGetPageDirection from '@salesforce/apex/TWIST_WireService.getPageDirection';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import apexGetHeaderAndFooterUrls from '@salesforce/apex/TWIST_WireService.getHeaderAndFooterUrls';

import { hidePageLoader } from 'c/twistUtils';

export default class TwistError extends LightningElement {
    
    @api queryParams;
    oQueryParams;
    
    isRenderedCallbackExecuted = false;
    twist404Icon = Twist_UI + '/404-large.jpg';
    twistLocalisationIcon = Twist_UI + '/localisation.jpg';
    twistPhoneIcon = Twist_UI + '/phone.png';
    @api language;
    
    @track customLabels = {};
    @track mainWrapperCssClasses;
    @track urls = {};
    
    /* Component life cycle ******************************************************************** */
    
    errorCallback(error, stack) {
        console.error('error', error)
    }
    
    connectedCallback() {
        this.init();
    }
    
    handleClickToCustomerService() {
        location.href = this.urls.Contact;
    }
    
    handleClickFindAStore() {
        location.href = this.urls.Stores;
    }
    
    /* Util methods **************************************************************************** */
    
    init() {
        this.oQueryParams = JSON.parse(this.queryParams);

        apexGetHeaderAndFooterUrls({langCountry: this.oQueryParams.langCountry})
        .then(data => {
            this.urls = data;
        })
        .catch(error => {
            console.log(error, 'Error when retrieving URLs');
        })
        apexGetPageDirection({ langCountry: this.oQueryParams.langCountry})
        .then(direction => {
            this.mainWrapperCssClasses = direction;
        });

        apexTranslateLabels({
            labels: [
                'TWIST_Exception_Title',
                'TWIST_Exception_Page_Description',
                'TWIST_Exception_Page_Client_Services',
                'TWIST_Exception_Page_Description_II',
                'TWIST_Exception',
                'TWIST_Exception_Button',
                'TWIST_Exception_File_Location_Button'
            ],
            language: this.language
        })
        .then(result => {
            this.customLabels = result;
            hidePageLoader();
        })
        .catch(error => {
            console.error('error', error);
        });
    }
    
}