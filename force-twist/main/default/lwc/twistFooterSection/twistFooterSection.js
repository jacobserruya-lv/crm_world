import { LightningElement, api } from 'lwc';

export default class TwistFooterSection extends LightningElement {

    @api sectionContent
    
    handleClickOnLink(event) {
        const eventParam = {
            detail: {
                url: event.target.dataset.url,
                id: event.target.dataset.id
            },
        };
        this.dispatchEvent(new CustomEvent('clickonlink', eventParam));
    }

}