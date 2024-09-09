import { track, api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import getAllEventVariationById from "@salesforce/apex/CL_controller.getAllEventVariationById";
import getAllPublishedEvents from "@salesforce/apex/CL_controller.getAllPublishedEvents";
import addClientsToAnEventFromBatch from '@salesforce/apex/CL_controller.addClientsToAnEventFromBatch';
import EVENT_TYPE_FIELD from "@salesforce/schema/Brand_Experience__c.Type__c";

export default class ct_addClientsToAnEventModal extends LightningElement {
  defaultRecordTypeId = "012000000000000AAA";
  @api storage;

  isEventRequired = true;
  isVariationRequired = false;

  errorMsg = '';
  errorsList = [];

  eventId = null;
  variationId = null;

  eventSearchValue = '';
  variationSearchValue = '';

  eventTypeValue = '';

  @wire(getAllPublishedEvents, {
    eventType: '$eventTypeValue'
  })
  publishedEvents;

  @wire(getAllEventVariationById, {
    id: '$eventId'
  })
  publishedVariations;

  @wire(getPicklistValues,{
    recordTypeId: '$defaultRecordTypeId',
    fieldApiName: EVENT_TYPE_FIELD
  }) eventTypePicklist;

  get eventTypeOptions() {
    return this.eventTypePicklist?.data?.values || [];
  }

  get eventOptions() {
    console.log(this.publishedEvents);
    return this.publishedEvents?.data?.filter(({ Name }) => !this.eventSearchValue || Name.includes(this.eventSearchValue))
                                      ?.map(({ Name, Id }) => ({ label: Name, value: Id }));
  }

  get variationOptions() {
    return this.publishedVariations?.data?.map(({ Name, Store__r, Id }) => ({ 
      label: Name + (Store__r ? ` - ${Store__r.Name} - ${Store__r.RetailStoreId__c}` : ''), 
      value: Id 
    }))?.filter(({ label }) => !this.variationSearchValue || label.includes(this.variationSearchValue));
                                         
  }

  get selectedEventInfo() {
    const infoId = this.variationId || this.eventId;
    const options = this.variationId ? this.publishedVariations : this.publishedEvents;
    const selectedEvent = options?.data?.find(({ Id }) => Id === infoId) || {};
    
    return {
      id: selectedEvent.Id,
      name: selectedEvent.Name + (selectedEvent.Store__r ? ` - ${selectedEvent.Store__r.Name} - ${selectedEvent.Store__r.RetailStoreId__c}` : ''),
      description: selectedEvent.Description__c,
      startDate: selectedEvent[this.variationId ? 'StartDateTime__c' : 'StartDate__c'],
      endDate: selectedEvent[this.variationId ? 'EndDateTime__c' : 'EndDate__c']
    };
  }

  get isFieldsNotFill() {
    return !(this.eventId);
  }

  eventOnFocus() {
    this.eventId  = '';
  }

  handleEventTypeValueChanged = (event) => {
    this.eventTypeValue = event.detail.value;
  }

  handleEventChange = (value) => {
    this.eventId = value;

    if (!this.eventId) {
      this.variationId = null;
      const variationField = this.template.querySelector('c-ct_searchable-combobox.variation-combobox');
      variationField?.reset();
    }

    //this.fieldValidation();
  }

  handleVariationChange = (value) => {
    this.variationId = value;
  }

  fieldValidation() {
      const eventField = this.template.querySelector('c-ct_searchable-combobox.event-combobox');
      if (!eventField) {
        return;
      }

      if (!this.eventId) {
        this.inputField.setCustomValidity('Please choose one of the picklist options.');
      } else {
        this.inputField.setCustomValidity('');
      }
  }

  closePicklists(event) {
      this.template.querySelectorAll('c-ct_searchable-combobox').forEach(element => {
        if(event.target?.id != element?.id) {
          element.closePicklist();
        }
      })
  }

  @api
  closeModal() {
    this.expirationDate = null;
    this.topologyValue = null;
    this.offerCodeValue = null;
    this.isClientListIcon = null;
    this.dispatchEvent(new CustomEvent("destroyeventmodal"));
  }

  loadSpinner(load, text) {
    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: load, text}, bubbles: true, composed: true})); 
  }

  handleAddClients() {
    this.errorMsg = '';

    this.loadSpinner(true, 'Adding clients to the event, please wait');

    addClientsToAnEventFromBatch({
      eventId: this.eventId,
      variationId: this.variationId,
      eventType: this.eventTypeValue,
      dreamIdsList: [...this.storage.dreamIdList]
    })
      .then(({ jobId, errorFileId }) => {
        const selectedEvent = new CustomEvent("clientsaddedtoanevent", {
          detail: {
            eventInfo: { 
              ...this.selectedEventInfo,
              jobId,
              errorFileId
            }
          }
        });
        this.loadSpinner(false);
        this.dispatchEvent(selectedEvent);
      })
      .then(() => {
        this.toastMessage("Success!", 'Adding clients to the Event, job started successfully!', 'success');
        this.closeModal();
      })
      .catch((error) => {
        this.loadSpinner(false);
        this.errorMsg = error?.body?.message || error;
        this.toastMessage("error!", 'Something went wrong: ' + this.errorMsg, 'error');
      });
  }

  toastMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  handleErrorsDownload() {
    const titles = ['DreamId', 'Message'];
    const csvContent = [[titles, ...this.errorsList].join("\n")];
    const downloadElement = document.createElement('a');
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvContent);
    downloadElement.target = '_self';
    downloadElement.download = 'errors.csv';
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }
}