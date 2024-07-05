import { LightningElement, api } from 'lwc';

export default class Icx_button extends LightningElement {
    @api label;
    @api link;

    get buttonLabel() {
        return (this.label==null)?"Button Label":this.label;
    }

    handleButtonClick(event) {
        // open a new window
        if (this.link != null) {
            window.open(this.link, '_blank');
        }
    }
}