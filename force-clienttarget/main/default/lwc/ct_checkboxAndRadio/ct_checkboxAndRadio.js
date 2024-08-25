import { api, LightningElement } from 'lwc';

export default class Ct_checkboxAndRadio extends LightningElement {
    @api infos;
    @api value;
    @api checkboxChecked = false;

    handleCheckboxClick(){
        this.checkboxChecked = !this.checkboxChecked;
    }

    // connectedCallback() {
    //     let record = {};
        
    //     record.checkboxId = this.infos.value + '-checkbox';
    //     record.radioIdYes = this.infos.value + 'yes-radio';
    //     record.radioIdNo = this.infos.value + 'no-radio';
    
    //     // this.infos = record;
    // }
}