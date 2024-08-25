import { LightningElement, api } from 'lwc';
import getRelatedTransaction from '@salesforce/apex/ICX_RelatedTransaction.getRelatedTransaction';

export default class Icx_relatedtransaction extends LightningElement {
    @api recordId;

    appointmentFields;
    
    connectedCallback() {
        getRelatedTransaction({recordId : this.recordId }).then(res => {
            res ? this.appointmentFields = res : false ;
        });
    } 
}