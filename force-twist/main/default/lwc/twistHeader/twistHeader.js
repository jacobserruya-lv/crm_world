import { LightningElement, api, track } from 'lwc';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import apexGetHeaderAndFooterUrls from '@salesforce/apex/TWIST_WireService.getHeaderAndFooterUrls';
import Twist_UI from '@salesforce/resourceUrl/Twist_UI';
import { lwcNameToCamelCase } from 'c/twistUtils';

export default class TwistHeader extends LightningElement {

    twistHeaderLogo = Twist_UI + '/twist-header-logo.png';

    @api language;
    @api title;
    @api langCountry;
    @api canModalBeShown;
    @track customLabels = {};
    @track urls = {};

    connectedCallback() {
        apexGetHeaderAndFooterUrls({langCountry: this.langCountry})
        .then(data => {
            this.urls = data;
        })
        .catch(error => {
            console.log(error, 'Error when retrieving URLs');
        })
        apexTranslateLabels({
            labels: [
                'Twist_Header_LouisVuitton',
                'Twist_Header_LoginToMyLV'
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

    renderedCallback() {
        this.dispatchEvent(new CustomEvent('childlwcrendered', { detail: lwcNameToCamelCase(this.template.host.localName) }));
    }

    handleClickOnLink(event) {
        const targetId = event.currentTarget.dataset.id;
        if(this.canModalBeShown){
            this.dispatchEvent(new CustomEvent('clicklink', { detail: { linkToBeRedirected : this.urls[targetId] }}))
        }
        else{
            location.href = this.urls[targetId];
        }
    }
}