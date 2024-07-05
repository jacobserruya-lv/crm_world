import { LightningElement, track, api } from 'lwc';

import apexGetPageDirection from '@salesforce/apex/TWIST_WireService.getPageDirection';
import apexGetLanguage from '@salesforce/apex/TWIST_Login.getLanguage';
import apexTranslateLabel from '@salesforce/apex/TWIST_i18nTranslations.translateSingleLabel';
import apexBuildError404Url from '@salesforce/apex/TWIST_WireService.buildError404Url';

import { extractMainChildComponentQueryParams, hidePageLoaderIfAllChildLwcRendered } from 'c/twistUtils';

export default class TwistForgotPasswordWrapper extends LightningElement {

    // Passed by the $Lightning.createComponent() function in the TWIST_LWCWrapper VFP
    @api queryParams;
    @api autodata;
    @api windowFunctions;
    
    @track forgotPasswordComponentQueryParams;
    @track oQueryParams;

    @track language;
    @track mainWrapperCssClasses ;
    @track title;

    lwcRenderStatus = {
        TwistForgotPassword: false,
        TwistHeader: false,
        TwistFooter: false,
        TwistSideBar: false
    }

    connectedCallback() {
        this.oQueryParams = JSON.parse(this.queryParams);
        const mainChildComponentQueryParams = extractMainChildComponentQueryParams(this.oQueryParams);
        if (mainChildComponentQueryParams === null) { // at least one param required by main child Component is missing
            apexBuildError404Url({
                langCountry: this.oQueryParams.langCountry,
                origin: this.oQueryParams.origin,
                clientId: this.oQueryParams.clientId
            })
            .then(url => {
                location.href = url;
            });
            return;
        }

        this.forgotPasswordComponentQueryParams = JSON.stringify(mainChildComponentQueryParams);

        Promise.all([
            apexGetLanguage({ langCountry: this.oQueryParams.langCountry }),
            apexGetPageDirection({ langCountry: this.oQueryParams.langCountry })
        ])
        .then(result => {
            this.language = result[0];
            this.mainWrapperCssClasses= result[1];
            apexTranslateLabel({
                label: 'Twist_Header_Reset_Password',
                language: this.language
            })
            .then(title => { this.title = title })
            .catch(error => { console.error('error', error) });
        })
        .catch(error => {
            console.error(`Error: ${typeof error == 'object' ? JSON.stringify(error) : error}`);
        });
    }

    handleChildLwcRendered(e) {
        hidePageLoaderIfAllChildLwcRendered.call(this, e.detail);
    }

}