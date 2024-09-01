import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createRecords from '@salesforce/apex/Ex_new_brand_experience_modal_Controller.createBrandEventAndStoreHierarchyRecords';
import getRecordTypes from '@salesforce/apex/Ex_new_brand_experience_modal_Controller.getRecordTypes';

import createNewEventLbl from '@salesforce/label/c.E_E_store_hierarchy_CreateNewEvent';
import eventDetailsLbl from '@salesforce/label/c.E_E_store_hierarchy_EventDetails';
import startDateLbl from '@salesforce/label/c.E_E_store_hierarchy_StartDate';
import endDateLbl from '@salesforce/label/c.E_E_store_hierarchy_EndDate';
import descriptionLbl from '@salesforce/label/c.E_E_store_hierarchy_Description';
import createLbl from '@salesforce/label/c.E_E_store_hierarchy_Create';
import cancelLbl from '@salesforce/label/c.E_E_store_hierarchy_Cancel';
import dateValidationMessageLbl from '@salesforce/label/c.E_E_DateValidationMessage';
import createdLbl from '@salesforce/label/c.E_E_Created';
import creationErrorMessageLbl from '@salesforce/label/c.E_E_CreationErrorMessage';
import nextLbl from '@salesforce/label/c.E_E_next';


export default class Ex_new_brand_experience_modal extends NavigationMixin(LightningElement) {
    @api iscustomlistview;
    labels={
        createNewEvent:createNewEventLbl,
        eventDetails:eventDetailsLbl,
        startDate:startDateLbl,
        endDate:endDateLbl,
        description:descriptionLbl,
        create:createLbl,
        cancel: cancelLbl,
        dateValidationMessage: dateValidationMessageLbl,
        created: createdLbl,
        creationErrorMessage: creationErrorMessageLbl,
        next: nextLbl

    };
    step=0;
    recordTypeOptions = [];
    @track eventRecord = {};
    selectedStoreItems = [];
    isSaving = false;
    isStoreSelected = false;
    disableSaveFlag = true;
    disabledNextBtn = true;
    typeVal;
   
    get isChooseRTStep(){
        return this.step === 0;
    }
    @wire(getRecordTypes)
    wiredRecordTypes({ error, data }) {
        if (data) {
            this.recordTypeOptions = data.map(recordType => {
                return { label: recordType.Name, value: recordType.Id };
            });
        } else if (error) {
            console.error('Error fetching record types:', error);
        }
    }
    handleRTChange(event){
        this.eventRecord.recordTypeId = event.target.value;
        let recordtypelabel = this.recordTypeOptions.find(x=> x.value == event.target.value)?.label;
        if(recordtypelabel == "In-Store Animation"){
            this.typeVal = "In-Store Animation";
            this.eventRecord.type = "In-Store Animation";
        }
      
        this.disabledNextBtn = false;

    }
    saveName(event){
        this.eventRecord.name = event.target.value;
        this.disableSave();
    }
    saveStart(event){
        this.eventRecord.startDate = event.target.value;
        this.disableSave();
        this.dateValiditation();
    }
    saveEnd(event){
        this.eventRecord.endDate = event.target.value;
        this.disableSave();
        this.dateValiditation();
    }
    saveType(event){
        this.eventRecord.type = event.target.value;
        this.disableSave();
    }
    saveSubType(event){
        this.eventRecord.subType = event.target.value;
        this.disableSave();
    }
    saveDescription(event){
        this.eventRecord.description = event.target.value;
    }

    dateValiditation(){
        const endDateError = this.template.querySelector('.endDate');
        if(this.eventRecord && this.eventRecord.startDate && this.eventRecord.endDate && this.eventRecord.startDate > this.eventRecord.endDate){
            endDateError.setCustomValidity(this.labels.dateValidationMessage);
            this.disableSaveFlag=true;
        }
        else{
            endDateError.setCustomValidity('');
            this.disableSave();
        }
        endDateError.reportValidity();
    }



    navigateToRecord(eventId) {
        this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
        recordId: eventId,
        actionName: 'view'
        }
        });
    }
    handleNext(){
        this.step++;
    }
    handleSave(){
        this.isSaving = true;
        const selectedStoreItems =this.template.querySelector('c-ex_store_hierarchy').selectedStoreItems;
        const selectedStoreIds = selectedStoreItems.map((x) => x.Id);
        this.eventRecord.selectedStores = selectedStoreIds;

        createRecords({eventRecord: this.eventRecord})
        .then(response => {
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Events & Experience '+response.Name+ ' '+ this.labels.created,
                variant: 'success',
                }),
            );
        this.dispatchEvent(new CustomEvent('close'))
        this.navigateToRecord(response.Id);
        })
        .catch(error => {
            console.error('Error: createRecords', error);
            this.dispatchEvent(
                new ShowToastEvent({
                title: 'Error',
                message: this.labels.creationErrorMessage +error.body.pageErrors[0].message,
                variant: 'error',
                }),
                );
        })
        .finally(() => {
            this.isSaving = false;
        })
    }

    handleCancel(){
        this.step = 0;
        this.typeVal = "";
        this.eventRecord = {};
        if(this.iscustomlistview)
            this.dispatchEvent(new CustomEvent('close'));
        else {
    
            window.history.back();
        }
    }
    storeselected(event){
        this.isStoreSelected=event.detail;
        this.disableSave();
    }

    disableSave(){
        if (Object.keys(this.eventRecord).length > 0 && this.isStoreSelected && this.eventRecord.name?.length!==0 && this.eventRecord.startDate!=null && this.eventRecord.endDate!=null 
                && this.eventRecord.type != null && this.eventRecord.type != '' && this.eventRecord.subType != null && this.eventRecord.subType != '' ) {
            this.disableSaveFlag=false;
        }
        else this.disableSaveFlag=true;
    }
}