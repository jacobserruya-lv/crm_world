import { LightningElement, track, api } from 'lwc';

import apexGetLanguage from '@salesforce/apex/TWIST_Login.getLanguage';
import apexTranslateLabel from '@salesforce/apex/TWIST_i18nTranslations.translateSingleLabel';
import apexBuildError404Url from '@salesforce/apex/TWIST_WireService.buildError404Url';
import apexGetPageDirection from '@salesforce/apex/TWIST_WireService.getPageDirection';

import { extractMainChildComponentQueryParams, hidePageLoaderIfAllChildLwcRendered } from 'c/twistUtils';

export default class TwistAccountCreationWrapper extends LightningElement {
   
    // Passed by the $Lightning.createComponent() function in the TWIST_LWCWrapper VFP
    @api queryParams;
    @api autodata;
    @api windowFunctions;
    
    @track accountCreationComponentQueryParams;
    @track oQueryParams;
    @track mainWrapperCssClasses;
    @track language;
    @track title;
    @track canModalBeShown;
    @track isModalDisplayed;
    @track isInNewTab;

    linkToBeRedirected;
    lwcRenderStatus = {
        TwistAccountCreation: false,
        TwistModalStayToContinue: false,
        TwistHeader: false,
        TwistFooter: false
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
        this.accountCreationComponentQueryParams = JSON.stringify(mainChildComponentQueryParams);
              
        apexGetLanguage({ langCountry: this.oQueryParams.langCountry })
        .then(result => {
            this.language = result;
            this.locale = this.oQueryParams.langCountry;
            apexGetPageDirection({ langCountry: this.oQueryParams.langCountry})
            .then(direction => {
                this.mainWrapperCssClasses = direction;
            });
            apexTranslateLabel({
                label: 'Twist_Header_MyLVAccountCreation',
                language: this.language
            })
            .then(result => {
                this.title = result;
            })
            .catch(error => {
                console.error('error', error);
            });
        })
        .catch(error => {
            console.error('Error when getting language', error);
        });
    }

    handleChildLwcRendered(e) {
        hidePageLoaderIfAllChildLwcRendered.call(this, e.detail);
    }

    handleCanModalBeShown(event){
        this.canModalBeShown = event.detail;
    }

    handleOnLinkClicked(event){
        this.isModalDisplayed = true;
        this.linkToBeRedirected = event.detail.linkToBeRedirected;
        this.isInNewTab = event.detail.isInNewTab;
    }
   
    handleSelectedAction(event){
        switch (event.detail) {
            case 'CONTINUE': case 'CLOSE':
                this.isModalDisplayed = false;
                this.linkToBeRedirected = '';
                break;
            case 'LEAVE':
                if(this.isInNewTab){
                    window.open(this.linkToBeRedirected,'_blank');
                }
                else{
                    location.href = this.linkToBeRedirected;
                }
                break;
            default:
                console.error(`wrong value : ${event.detail}`);
        }

    }
}