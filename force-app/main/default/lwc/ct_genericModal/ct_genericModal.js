import { api, LightningElement } from 'lwc';

export default class Ct_genericModal extends LightningElement {
    @api buttonText = "";
    @api modalTitle= "";
    @api modalText = "";
}