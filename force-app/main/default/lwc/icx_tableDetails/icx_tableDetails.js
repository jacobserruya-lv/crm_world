import { api, LightningElement, track } from 'lwc';
import {getGuidId} from 'c/utils';


export default class Icx_tableDetails extends LightningElement {
    @api category;
    @api detailsValues;
    @api selectedCurrency;

    renderedCallback() {
        console.log('TableDetails category', JSON.stringify(this.category))
        console.log('TableDetails detailsValues', JSON.stringify(this.detailsValues))
        console.log('TableDetails selectedCurrency', this.selectedCurrency)
    }
    get getGuidId()
    {
        return getGuidId();
    }
}