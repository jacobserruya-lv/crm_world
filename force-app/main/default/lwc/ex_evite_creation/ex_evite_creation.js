import { LightningElement,api,wire } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { uploadFileToAkamaiNS } from 'c/wrdbNetStorageServices';
import { RefreshEvent } from "lightning/refresh";


import EVITE_OBJECT from '@salesforce/schema/Brand_Experience_Variation_Evite__c';
import LANGUAGE_FIELD from "@salesforce/schema/Brand_Experience_Variation_Evite__c.Language__c";
import NAME_FIELD from "@salesforce/schema/Brand_Experience_Variation_Evite__c.Name";
import URL_FIELD from "@salesforce/schema/Brand_Experience_Variation_Evite__c.URL__c";
import VARIATION_FIELD from "@salesforce/schema/Brand_Experience_Variation_Evite__c.Experience_Variation__c";


export default class Ex_evite_creation extends LightningElement {

    @api recordId;

    selectedLanguage = '';
    eviteName = '';
    file;
    isFileUpload = false
    loader = false

    get acceptedFormats() {
        return ['.jpg', '.png', '.jpeg', '.mp4', '.gif'];
    }

    get options() {
        return this.languagePicklist?.data?.values;
    }

    get isDisabled() {
        return !(this.file && this.eviteName && this.selectedLanguage ) || this.loader;
    }


    @wire(getObjectInfo, { objectApiName: EVITE_OBJECT }) 
    eviteMetadata;

    @wire(getPicklistValues,{
        recordTypeId: '$eviteMetadata.data.defaultRecordTypeId', 
        fieldApiName: LANGUAGE_FIELD 
    })
    languagePicklist;

    async handleClick(){

        //check required fields 

        this.loader = true;

        const { accessUrl } = await uploadFileToAkamaiNS(this.file);

        const fields = {}
        fields[URL_FIELD.fieldApiName] = accessUrl;
        fields[NAME_FIELD.fieldApiName] = this.eviteName;
        fields[LANGUAGE_FIELD.fieldApiName] = this.selectedLanguage;
        fields[VARIATION_FIELD.fieldApiName] = this.recordId;


        const recordInput = { apiName: EVITE_OBJECT.objectApiName, fields };
        createRecord(recordInput)
        .then(record => {
            this.loader = false;
            this.showToast('Success' , 'Record created' ,'success');
            this.dispatchEvent(new CloseActionScreenEvent());
           
            eval("$A.get('e.force:refreshView').fire();");
        })
        .catch(error => {
            this.loader = false;
            this.showToast('Error creating record' , error.body.message ,'error')
        });    


    }


    handleInputChange(event) {
        this.eviteName = event.detail.value;
    }

    handleChange(event) {
        this.selectedLanguage = event.detail.value;
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