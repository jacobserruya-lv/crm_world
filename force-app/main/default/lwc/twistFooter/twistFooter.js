import { LightningElement, wire , track, api } from 'lwc';

import Twist_UI from '@salesforce/resourceUrl/Twist_UI';

import apexGetSwitchToLanguage from '@salesforce/apex/TWIST_WireService.getSwitchToLanguage';
import apexGetFooterConfig from '@salesforce/apex/TWIST_WireService.getFooterConfig';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';

import {
    lwcNameToCamelCase,
    openLink
} from 'c/twistUtils';

export default class TwistFooter extends LightningElement {

    /* Component properties ******************************************************************** */
    
    @api language;
    @api queryParams;
    @api canModalBeShown;
    @api windowFunctions;
    @api socialMediaCloseIconSide;

    @track areSocialMediaVisible = false;
    @track areMsaTransparencyVisible = false;
    @track areMsaTransparencyMobileVisible = false;
    @track areSocialMediaMobileVisible = false;
    @track customLabels = {};
    @track footerClass = 'footer';
    @track languageSwitchUrl;
    @track showLanguageSwitchLink;
    @track currentlyOpenedSection;
    @track footerConfig;
    @track ukStatements;
    @track hideFlagCountry;

    SECTION_DATA_ID = {
        HELP: 'help',
        SERVICE: 'service',
        ABOUT: 'aboutLouisVuitton',
        CONNECT: 'connect',
        LEGALSECTION: 'legalSection'
    };
    
    twistFooterLogo = Twist_UI + '/logo.svg';
    userRightsLogoSrc = Twist_UI + '/logoUserRights.webp';
    countryFlagUrl;
    openLinkInNewTab = false;

    /* Component life cycle ******************************************************************** */

    connectedCallback() {
        const oQueryParams = JSON.parse(this.queryParams);
        const dispatchCountry = oQueryParams.dispatchCountry;
        const langCountry = oQueryParams.langCountry;

        const origin = oQueryParams.origin;
        Promise.all([
            apexGetFooterConfig({
                langCountry: langCountry,
                dispatchCountry: dispatchCountry,
                origin: origin
            }),
            apexGetSwitchToLanguage({ langCountry: langCountry }),
            apexTranslateLabels({
                labels: [
                    'Twist_Footer_Link_ShipTo',
                    'Twist_Footer_Link_SwitchTo',
                    'Twist_Footer_Link_Sitemap'
                ],
                language: this.language
            })
        ])
        .then(result => {
            if (this.didFooterConfigServiceFail(result[0])) {
                throw "Runtime Error when loading footer config: " + result[0].message;
            }
            this.footerConfig = result[0];
            this.countryFlagUrl = `${Twist_UI}/flags/${this.footerConfig.countryFlag.src}`;
            this.hideFlagCountry = this.footerConfig.hideFlagCountry;
            if (this.footerConfig.isMobileApp || origin === 'checkout') {
                this.footerClass = 'hide';
            }

            this.showLanguageSwitchLink = result[1].isRequired;
            this.socialMediaCloseIconSide = result[1].value;
            if (this.showLanguageSwitchLink) {
                this.languageSwitchUrl = location.href.replace(/\/([a-z]{3})-([a-z]{2})\//, `/${result[1]?.value}-$2/`);
            }
            this.customLabels = result[2];
        })
        .catch(error => {
            console.error(typeof error === "object" ? JSON.stringify(error) : error);
        })
    }

    renderedCallback() {
        this.dispatchEvent(new CustomEvent('childlwcrendered', { detail: lwcNameToCamelCase(this.template.host.localName) }));
    }

    /* Event handlers ************************************************************************** */
    
    handleClickOnLink(event) {
        //const targetId = event?.target?.dataset?.id || event.detail.id; // "event.detail.id" when event is dispatched by a child LWC
        const url = event?.target?.dataset?.url || event.detail.url;
        if (this.canModalBeShown){
            this.dispatchEvent(new CustomEvent(
                'clicklink', {
                detail: { linkToBeRedirected: url, isInNewTab: this.openLinkInNewTab }
            }));
            return;
        }
        openLink(url, this.openLinkInNewTab);
    }
    
    handleExecuteScript(event){
        const functionName = event.detail.script;
        this.windowFunctions[functionName]();
    }
    
    showSocialMedia(){
        this.areSocialMediaVisible = true;
    }
    showMsaTransparencySection(){
        this.areMsaTransparencyVisible = true;
    }
    
    hideSocialMedia(){
        this.areSocialMediaVisible = false;
    }
    hideMsaTransparencySection(){
        this.areMsaTransparencyVisible = false;
    }
    
    handleClickSection(event){
        const targetId = event.target.dataset.id;
        if(this.currentlyOpenedSection && this.currentlyOpenedSection != targetId) {
            this.template.querySelector(`[data-id="${this.currentlyOpenedSection}"]`).classList.add('inactive');
            this.template.querySelector(`[data-section="${this.currentlyOpenedSection}"]`).classList.add('d-none');
        }
        
        if(targetId == this.SECTION_DATA_ID.CONNECT || this.currentlyOpenedSection == this.SECTION_DATA_ID.CONNECT) {
            this.areSocialMediaMobileVisible = !this.areSocialMediaMobileVisible;
        }
        if(targetId == this.SECTION_DATA_ID.LEGALSECTION || this.currentlyOpenedSection == this.SECTION_DATA_ID.LEGALSECTION) {
            this.areMsaTransparencyMobileVisible = !this.areMsaTransparencyMobileVisible;
        }
        this.template.querySelector(`[data-id="${targetId}"]`).classList.toggle('inactive');
        this.template.querySelector(`[data-section="${targetId}"]`).classList.toggle('d-none');
        this.currentlyOpenedSection = targetId ;
    }
    
    /* Util methods ************************************************************************** */
    
    /**
     * @param {Object} response
     * @returns {Boolean}
     */
    didFooterConfigServiceFail(response) {
        return response?.success === false;
    }

}