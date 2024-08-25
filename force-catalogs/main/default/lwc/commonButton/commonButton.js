import { api, LightningElement } from 'lwc';

export default class CommonButton extends LightningElement {
    @api myclass;
    @api myFunction;
    @api title;
}