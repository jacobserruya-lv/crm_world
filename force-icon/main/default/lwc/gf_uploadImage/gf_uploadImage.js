import { LightningElement,api,wire } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { uploadFileToAkamaiNS } from 'c/wrdbNetStorageServices';
import { RefreshEvent } from "lightning/refresh";

import GIFT_OBJECT from '@salesforce/schema/GiftCatalog__c';
import IMAGE_FIELD from "@salesforce/schema/GiftCatalog__c.GiftImageURL__c";
import ID_FIELD from "@salesforce/schema/GiftCatalog__c.Id";


export default class Gf_uploadImage extends LightningElement {
    @api recordId;
    file;
    isFileUpload = false
    loader = false

    get acceptedFormats() {
        return ['.jpg', '.png', '.jpeg', '.mp4', '.gif'];
    }

    get isDisabled() {
        return !(this.file) || this.loader;
    }

    @wire(getObjectInfo, { objectApiName: GIFT_OBJECT }) 
    giftMetadata;

    async handleClick(){
        this.loader = true;

        const { accessUrl } = await uploadFileToAkamaiNS(this.file);

        const fields = {}
        fields[IMAGE_FIELD.fieldApiName] = accessUrl;
        fields[ID_FIELD.fieldApiName] = this.recordId;

        const recordInput = { fields };
        updateRecord(recordInput)
        .then(record => {
            this.loader = false;
            this.showToast('Success' , 'Record updated' ,'success');
            this.dispatchEvent(new CloseActionScreenEvent());
           
            eval("$A.get('e.force:refreshView').fire();");
        })
        .catch(error => {
            this.loader = false;
            this.showToast('Error updating record' , error?.body?.message ,'error')
        });    
    }

    handleUploadFinished(event) {
        this.file = event.target.files[0];
        this.isFileUpload = true;
        this.showToast('Success' , 'file uploaded' ,'success');
    }

    showToast(title ,message , variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }   
}