import { track, api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import createClientListWithMembers from "@salesforce/apex/CT_CSVParseController.createCLwithMembers";
import TOPOLOGY_FIELD from "@salesforce/schema/CLI_CliList__c.Typology_new__c";
import OFERCODE_FIELD from "@salesforce/schema/CLI_CliList__c.Offer_Code_new__c";

export default class Ct_giveAccessExclusiveSalesModal extends LightningElement {
  defaultRecordTypeId = "012000000000000AAA";
  expirationDate;
  topologyValue;
  offerCodeValue;
  @track isClientListIcon = false;
  @api storage;
  @api notContactableClients;
  @api phoneCountries;
  otherParams;

  minExpirationDate = new Date().toISOString();
  maxExpirationDate = new Date(new Date().setFullYear(new Date().getFullYear() + 3)).toISOString();

  @wire(getPicklistValues, {
    recordTypeId: "$defaultRecordTypeId",
    fieldApiName: TOPOLOGY_FIELD
  })
  topologyPicklist;

  @wire(getPicklistValues, {
    recordTypeId: "$defaultRecordTypeId",
    fieldApiName: OFERCODE_FIELD
  })
  offerCodePicklist;

  get topologyOptions() {
    return this.topologyPicklist?.data?.values;
  }

  get offerCodeOptions() {
    const controllerValues = this.offerCodePicklist?.data?.controllerValues  || {};
    const values = this.offerCodePicklist?.data?.values || [];
    const isDependencePicklist = Object.keys(controllerValues).length > 0;
    return !isDependencePicklist ? values : values.filter(o => o.validFor.includes(controllerValues[this.topologyValue]));
  }

  get isClentListEmpty() {
    return !this.storage.clientList || this.storage.clientList.length < 1 ;
  }

  get exclusiveSalesModalOptions() {
    return {
      expirationDate: this.expirationDate,
      clientListName: this.description,
      clientListDescription: this.description,
      dreamIdList: null, //this.storage.dreamIdList,
      numberOfClients: this.storage.clientList
        ? this.storage.clientList.length
        : null,
      otherParams: this.otherParams,
      isEmptyClientList: false
    };
  }

  get description() {
    return `Exclusive Sale: ${this.topologyValue}`;
  }

  get isFieldsNotFill() {
    return !(
      !!this.isValidExpirationDate &&
      !!this.expirationDate &&
      !!this.topologyValue &&
      !!this.offerCodeValue
    );
  }

  get isValidExpirationDate() {
    if (!this.expirationDate) {
      return false;
    }
    const expirationDateTS = new Date(this.expirationDate).getTime();
    return expirationDateTS > new Date(this.minExpirationDate).getTime() &&
           expirationDateTS < new Date(this.maxExpirationDate).getTime();
  }

  handleTopologyChange(event) {
    this.topologyValue = event.detail.value;
  }

  handleOfferCodeChange(event) {
    this.offerCodeValue = event.detail.value;
  }

  @api
  closeModal() {
    this.expirationDate = null;
    this.topologyValue = null;
    this.offerCodeValue = null;
    this.isClientListIcon = null;
    this.dispatchEvent(new CustomEvent("destroyexclusivemodal"));
  }

  handleExpirationDate(event) {
    this.expirationDate = event.target.value;
  }

  loadSpinner(load, text) {
    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: load, text}, bubbles: true, composed: true})); 
  }

  handleGiveAccessExclusive() {
    this.loadSpinner(true, 'Creating client list, please wait');

    this.otherParams = {
      type: "exclusive",
      showInIcon: `${this.isClientListIcon}`,
      topology: this.topologyValue,
      offerCode: this.offerCodeValue,
      contactableClients: "true",
      phoneCountries: this.phoneCountries?.toString()
    };

    createClientListWithMembers({
      name: this.description,
      expirationDate: this.expirationDate,
      description: this.description,
      dreamIdsList: [...this.storage.dreamIdList],
      caListFilter: null,
      otherParams: JSON.stringify(this.otherParams)
    })
      .then((jobId) => {
        if (jobId && jobId !== "null") {
          const selectedEvent = new CustomEvent("giveaccessexclusive", {
            detail: {
              clientListDetails: {
                clientListOptions: this.exclusiveSalesModalOptions,
                clientListId: jobId
              }
            }
          });
          this.loadSpinner(false);
          this.dispatchEvent(selectedEvent);
        } else {
          throw 'JobId was not found.';
        }
      })
      .then(() => {
        let message = 'Creating Exclusive client list has started successfully!';
        
        const notContactableClientsLength = this.notContactableClients?.data?.length;
        if (notContactableClientsLength) {
          message += ` But we found ${notContactableClientsLength} without email or phone!`;
        }

        this.toastMessage("Success!", message, !!notContactableClientsLength ? 'warning' : 'success');
        this.closeModal();
      })
      .catch((error) => {
        this.loadSpinner(false);
        this.errorMsg = error?.body?.message || error;
        this.toastMessage("error!", 'Something went wrong: ' + this.errorMsg, 'error');
      });
  }

  handleClientListIconToggle(event) {
    this.isClientListIcon = event.detail.checked;
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
}