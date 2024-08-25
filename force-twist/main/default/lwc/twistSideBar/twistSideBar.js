import { LightningElement, api, track } from 'lwc';
import sidebarIcons from '@salesforce/resourceUrl/Twist_Sidebar_Icons';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import { lwcNameToCamelCase } from 'c/twistUtils';

export default class TwistSideBar extends LightningElement {

    @api language;

    @track customLabels = {};
    @track iconUrls = {
        speedys: sidebarIcons + '/services-speedys.svg',
        creditCard: sidebarIcons + '/services-credit-card.svg',
        email: sidebarIcons + '/informations-email.svg',
        wishlist: sidebarIcons + '/navigation-wishlist.svg'
    };

    connectedCallback() {
        apexTranslateLabels({
            labels: [
                'Twist_Sidebar_MyLvContentOfMyLvAccount',
                'Twist_Sidebar_ReassuranceOrderHistory',
                'Twist_Sidebar_ReassuranceInformation',
                'Twist_Sidebar_ReassuranceCommunications',
                'Twist_Sidebar_ReassuranceWishlist'
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

}