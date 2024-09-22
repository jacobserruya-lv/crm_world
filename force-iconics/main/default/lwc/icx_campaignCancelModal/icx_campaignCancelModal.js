import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { updateRecord } from "lightning/uiRecordApi";

export default class Icx_campaignCancelModal extends LightningModal {

    @api recordId;

    handleCancel(){
        const fields = {
            Id: this.recordId,
            Status__c: 'Cancelled'
        };

        updateRecord({fields})
        .then(() =>{
            console.log('Campaign is cancelled');
        })
        .catch(error =>{
            console.log('there is an error during updating campaign record');
        })

        this.close('okay');
        location.reload(true);
    }

    handleClose(){
        this.close('okay');
    }
}