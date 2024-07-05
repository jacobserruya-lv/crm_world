import { LightningElement, track, api } from 'lwc';

import { extractMainChildComponentQueryParams } from 'c/twistUtils';

import apexGetPageDirection from '@salesforce/apex/TWIST_WireService.getPageDirection';
import apexGetLanguage from '@salesforce/apex/TWIST_Login.getLanguage';

export default class TwistError404Wrapper extends LightningElement {

    @api queryParams;
    @api windowFunctions;
    
    @track error404ComponentQueryParams;
    @track oQueryParams;
    @track language;
    @track mainWrapperCssClasses;

    connectedCallback() {
        this.oQueryParams = JSON.parse(this.queryParams);
        const mainChildComponentQueryParams = extractMainChildComponentQueryParams(this.oQueryParams);
        this.error404ComponentQueryParams = JSON.stringify(mainChildComponentQueryParams);

        apexGetLanguage({ langCountry: this.oQueryParams.langCountry })
        .then(result => {
            this.language = result;
        })

        apexGetPageDirection({ langCountry: this.oQueryParams.langCountry})
        .then(direction => {
            this.mainWrapperCssClasses = direction;
        })
        .catch(error => {
            console.error('Error when getting language', error);
        });
    }

}