import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import REASON_FIELD from '@salesforce/schema/Fraud_Comment__c.Reason__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FRAUD_COMMENT_OBJECT from '@salesforce/schema/Fraud_Comment__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedComments from '@salesforce/apex/ICX_Client360_SF.getRelatedComments'; // Import custom Apex method

export default class Icx_twistPostComment extends LightningElement {
    @api sfRecordId;
    @track records = [];
    @track isLoading = false;
    listReasonOptions;
    selectedReason = '';
    userId = USER_ID;
    userName;
    @track isOpen = false;
    @track disabledPostComment = true;


    @wire(getObjectInfo, { objectApiName: FRAUD_COMMENT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: REASON_FIELD
    })
    picklistValues({ error, data }) {
        if (data) {
            this.listReasonOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error loading picklist values:', error);
        }
    }

    @wire(getRecord, {
        recordId: '$userId',
        fields: [NAME_FIELD]
    })
    wireUser({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }

    handleListReasonOptions(event) {
        this.selectedReason = event.target.value;
        this.disabledPostComment = false;
    }

    get isDisabledMessageVisible() {
        return this.disabledPostComment && this.selectedReason === '';
    }

    // Imperative method to fetch related list records
    fetchRelatedComments() {
        getRelatedComments({ parentRecordId: this.sfRecordId })
            .then(result => {
                if (result) {
                    console.log('Data received:', result);
                    this.records = result.map(record => ({
                        id: record.Id,
                        Comment__c: record.Comment__c,
                        OwnerName: record.TechOwnerName__c,
                        Reason__c: record.Reason__c,
                        CreatedDate: record.CreatedDate
                    }));
                    localStorage.setItem('recordsData', JSON.stringify(this.records));
                }
            })
            .catch(error => {
                console.error('Error loading related list records:', error);
            });
    }

    connectedCallback() {
        const recordsData = localStorage.getItem('recordsData');
        if (recordsData) {
            this.records = JSON.parse(recordsData);
        } else {
            this.records = [];
        }
        this.fetchRelatedComments(); // Call the method to fetch related list records
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Reason__c = this.selectedReason;
        fields.Client__c = this.sfRecordId;

        if (fields.Comment__c) {
            this.isLoading = true;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleSuccess(event) {
        const tempRecord = {
            id: event.detail.id,
            Comment__c: event.detail.fields.Comment__c.value,
            OwnerName: this.userName,
            CreatedDate: event.detail.fields.CreatedDate.value,
            Reason__c: this.selectedReason
        };

        this.records.unshift(tempRecord);
        localStorage.setItem('recordsData', JSON.stringify(this.records));

        this.isLoading = false;

        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => field.reset());
        }
    }

    handleError(event) {
        const message = 'Something went wrong! Retry or contact an administrator';
        this.showToast('Error', message, 'error');
        this.isLoading = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}