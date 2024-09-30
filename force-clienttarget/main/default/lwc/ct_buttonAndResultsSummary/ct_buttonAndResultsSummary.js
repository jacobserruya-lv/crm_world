import { LightningElement, api } from 'lwc';
import DeleteNotInPerimeterMessage from '@salesforce/label/c.CT_DeleteNotInPerimeterMessage';
import DeleteMissingStoreMessage from '@salesforce/label/c.CT_DeleteMissingStoreMessage';
import DeleteUnattachedClientsMessage from '@salesforce/label/c.CT_DeleteUnattachedClientsMessage';
import DownloadNotInPerimeterMessage from '@salesforce/label/c.CT_DownloadNotInPerimeterMessage';

export default class Ct_buttonAndResultsSummary extends LightningElement {
  @api amountOfClients;
  @api notInPerimeter;
  @api clientsMissingStore;
  @api unattachedDreamIds;
  isDeleteButtonClicked = false;

  connectedCallback() {
    this.isDeleteButtonClicked = false;
  }

  get downloadClientsMessage() {
    return DownloadNotInPerimeterMessage;
  }

  get isRemoveMessageDisplay() {
    return this.removeClientsMessages.length && !this.isDeleteButtonClicked;
  }

  get removeClientsMessages() {
    return [
      this.notInPerimeter?.length && DeleteNotInPerimeterMessage.replace('{numOfClients}', this.notInPerimeter.length),
      this.unattachedDreamIds?.data?.length && DeleteUnattachedClientsMessage.replace('{numOfClients}', this.unattachedDreamIds.data.length),
      this.clientsMissingStore?.data?.length && DeleteMissingStoreMessage.replace('{numOfClients}', this.clientsMissingStore?.data?.length)
    ].filter(Boolean);
  } 

  get allErrorsDreamIds() {
    return [...new Set([
      ...(this.notInPerimeter || []),
      ...(this.unattachedDreamIds?.data || []),
      ...(this.clientsMissingStore?.data || [])
    ])];
  }

  handleBackClick(){
    const selectedEvent = new CustomEvent("goback");
    this.dispatchEvent(selectedEvent);
  }

  getCsvContent() {
    let reasonByDreamId = {};

    const addDreamIds = (dreamIds = [], message) => {
      dreamIds.forEach((dreamId) => {
        const existMessage = reasonByDreamId[dreamId];
        const updatedMessage = `${existMessage ? existMessage + '; ' : ''}` + message;
        reasonByDreamId[dreamId] = updatedMessage;
      });
    };

    addDreamIds(this.notInPerimeter, 'Client is not in your perimeter');
    addDreamIds(this.unattachedDreamIds?.data, 'Client is not attached to a CA');
    addDreamIds(this.clientsMissingStore?.data, 'Client is not attached to a store');
    
    return Object.entries(reasonByDreamId).join('\n');
  }

  handleDownloadClients(event) {
    const csvContent = this.getCsvContent();
    const downloadElement = document.createElement("a");
    downloadElement.href =
      "data:text/csv;charset=utf-8," + encodeURI(csvContent);
    downloadElement.target = "_self";
    downloadElement.download = `to_delete_dreamIds.csv`;
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  handleDeleteClients() {
    this.isDeleteButtonClicked = true;
    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: true}, bubbles: true, composed: true})); 
    setTimeout(() => this.dispatchEvent(new CustomEvent('deleteclients')), 50);
  }
}