import { LightningElement, api } from 'lwc';

export default class TwistFooterLegalSection extends LightningElement {
    @api legalSectionContent;
    @api windowFunctions;
    @api sitemapLabel;
    @api sitemapUrl;
    
    handleClickOnLink(event) {
        const eventParam = {
            detail: {
                url: event.target.dataset.url,
                id: event.target.dataset.id
            },
        };
        this.dispatchEvent(new CustomEvent('clickonlink', eventParam));
    }

    handleExecuteScript(event){
        const eventParam = {
            detail: {
                script: event.target.dataset.script.replace('()',"")
            },
        };
        this.dispatchEvent(new CustomEvent('executescript', eventParam));
    }
    
    showMsaTransparencySection() {
        this.dispatchEvent(new Event('showmsatransparencysection'));
    }
}

