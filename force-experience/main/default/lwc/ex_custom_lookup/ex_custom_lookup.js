import { LightningElement, api, track } from 'lwc';
import searchRecords from '@salesforce/apex/ex_variation_related_list_CTRL.getFilteredStores';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import requiredMessage from '@salesforce/label/c.E_E_store_hierarchy_RequiredFieldMessage';
import search from '@salesforce/label/c.E_E_store_hierarchy_search';
import noResults from '@salesforce/label/c.E_E_store_hierarchy_noResults';

const DELAY = 300;

export default class Ex_custom_lookup extends LightningElement {
    
  labels = {
    requiredMessage: requiredMessage,
    search: search,
    noResults:noResults
  }
  
    @api objectApiName;
    @api recordId;

    records = null
    iconName = 'custom:custom85';
    boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    isValueSelected; 
    searchString;
    loading = false;
    noRecords = false;
    selectedRecordId;
    selectedRecordName;

    handleSearch(event) {
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        window.clearTimeout(this.delayTimeout);
        if (event.target.value) {
          this.loading = true;
          const searchString = event.target.value;
          this.delayTimeout = setTimeout(() => {
            searchRecords({objectApiName: this.objectApiName, recordId: this.recordId, searchString: searchString })
              .then((result) => {
                if (result && result.length) {
                  this.noRecords = false;
                  this.loading = false;
                  this.records = result;
                  this.error = undefined;
                } else {
                  this.noRecords = true;
                  this.loading = false;
                  this.records = null;
                }
              })
              .catch((ex) => {
                this.loading = false;
                const toastEvent = new ShowToastEvent({
                  title: 'Error',
                  message: ex.body.message,
                });
                this.dispatchEvent(toastEvent);
                this.error = ex;
                this.records = null;
              });
          }, DELAY);
        } else {
          this.records = null;
          this.noRecords = false;
          this.loading = false;
        }
      }
      recordSelected(event) {
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.isValueSelected=true;
        this.selectedRecordId = event.currentTarget.dataset.id;
        this.selectedRecordName=event.currentTarget.dataset.name;
        const selectedEvent = new CustomEvent('storeselected', { detail: {Id: this.selectedRecordId, Name: this.selectedRecordName}});
        this.dispatchEvent(selectedEvent);
      }
      handleRemove(event) {
        this.selectedRecordId =this.selectedRecordName= null;
        this.isValueSelected=false;
        this.noRecords = false;
        const selectedEvent = new CustomEvent('storeselected', { detail: {} });
        this.dispatchEvent(selectedEvent);
      }
      // clear(event) {
      //   this.selectedRecordId =this.selectedRecordName= null;
      //   this.noRecords = false;
      //   const selectedEvent = new CustomEvent('storeselected', { detail: ''});
      //   this.dispatchEvent(selectedEvent);
      // }
      @api
      handleValueRequired(){
          if (!this.selectedRecordId) {
            this.template.querySelector('lightning-input').setCustomValidity(this.labels.requiredMessage);
          }
        else{
            this.template.querySelector('lightning-input').setCustomValidity('');
        }
        this.template.querySelector('lightning-input').reportValidity();
      }
      
}