import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import EX_NAME_FIELD from '@salesforce/schema/Brand_Experience__c.Name';
import EX_STARTDATE_FIELD from '@salesforce/schema/Brand_Experience__c.Experience_StartDate__c';
import EX_ENDDATE_FIELD from '@salesforce/schema/Brand_Experience__c.Experience_EndDate__c';
import eventAndExperience from '@salesforce/label/c.E_E_store_hierarchy_EventAndExperience';
import title from '@salesforce/label/c.E_E_store_hierarchy_NewEventAndExperienceActivation';
import createLbl from '@salesforce/label/c.E_E_store_hierarchy_Create';
import cancelLbl from '@salesforce/label/c.E_E_store_hierarchy_Cancel';
import nextLbl from '@salesforce/label/c.E_E_next';
import previousLbl from '@salesforce/label/c.E_E_previous';


const IN_STORE_RT = 'Physical_Event';
const OUT_STORE_RT = 'Out_of_Store_Event';
export default class Ex_activation_creation_modal extends LightningElement {
    @api isOpen;
    @api experienceId;
    @api recordTypeId;
    @api recordTypeName;
    @track store;
    step = 0;

    labels = {
        eventAndExperience: eventAndExperience,
        title: title,
        create:createLbl,
        cancel: cancelLbl,
        next: nextLbl,
        previous: previousLbl
    }
    get showFirstStep(){
        return this.step == 0 ? "display:flex" : "display:none"
    }
    get showSecondStep(){
        return this.step == 1 ? "display:flex" : "display:none"
    }
    get isFirstStep(){
        return this.step == 0;
    }
    get isInStoreRT() {
        return this.recordTypeName == IN_STORE_RT;
    }
    get nominationDefaultVal() {
        return this.recordTypeName == IN_STORE_RT ? true : false;
    }
    get attendanceDefaultVal() {
        return true;
        // return this.recordTypeName == IN_STORE_RT ? true : false;
    }
    get currencyDefaultVal() {
        return this.recordTypeName == OUT_STORE_RT ? 'EUR' : '';
    }

    @wire(getRecord, { recordId: '$experienceId', fields: [EX_NAME_FIELD, EX_STARTDATE_FIELD, EX_ENDDATE_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.experienceName = data.fields.Name.value;
            this.experienceStartDate = data.fields.Experience_StartDate__c.value;
            this.experienceEndDate = data.fields.Experience_EndDate__c.value;
        } else if (error) {
            console.error('Error fetching record:', error);
        }
    }
    handlePrevious(){
        this.step = 0;
    }
    handleNext(){
        let allValid = true;

        if(this.recordTypeName == IN_STORE_RT){
            this.storeValidation();
            if(!(this.store?.Id != null))
                allValid = false;
        }

        const inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(inputField => {
            if (!inputField.reportValidity()) {
                allValid = false;
            }
        });
       
        if (allValid)
            this.step += 1;
        
    }
    closeModal(){
        this.step = 0;
        const event = new CustomEvent('closemodal');
        this.dispatchEvent(event);
    }
    handleSubmit(event){
        event.preventDefault();
        let fields = event.detail.fields;

        fields.Nomination_By_CA__c = event.target.querySelector("lightning-input[data-fieldname='Nomination_By_CA__c']").checked;
        fields.Guests_Authorized__c = event.target.querySelector("lightning-input[data-fieldname='Guests_Authorized__c']").checked;
        fields.Required_Appointment__c = event.target.querySelector("lightning-input[data-fieldname='Required_Appointment__c']").checked;
        fields.AttendanceByCA__c = event.target.querySelector("lightning-input[data-fieldname='AttendanceByCA__c']").checked;
        

        fields.Registration_by_CA = true;
        fields.ClientDateRegistrationLimit__c = false;
        fields.TargetingMethod__c = 'Manual';
        if(this.recordTypeName == IN_STORE_RT){
            fields.Store__c = this.store?.Id;
            fields.calculatedLocation__c = this.store?.Name;
        }
        if(this.recordTypeName == OUT_STORE_RT){
            // fields.Currency__c = !fields.Currency__c ? 'EUR': fields.Currency__c;
            fields.calculatedLocation__c = fields.formatedAddress__c;
        }
        console.log('fields', fields);
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    storeValidation(){
        this.template.querySelector('c-ex_custom_lookup').handleValueRequired();
    }
    handleSuccess(e){
        let message = "Record ID: " + e.detail.id;
        this.showToast('Success', message, 'success');

        const event = new CustomEvent('closemodal');
        this.dispatchEvent(event);
    }
    handleError(){
        console.log('on handle error');
        const event = new CustomEvent('closemodal');
        this.dispatchEvent(event);
    }
    handleError(event) {
        let message = event.detail.detail;
        this.showToast('Error Message', message, 'error');
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
     this.dispatchEvent(event);
    }
    saveStore(event){
        this.store = event.detail;
    }
}