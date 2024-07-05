import { LightningElement, api } from 'lwc';
import DeleteNotInPerimeterMessage from '@salesforce/label/c.CT_DeleteNotInPerimeterMessage';
import DeleteMissingStoreMessage from '@salesforce/label/c.CT_DeleteMissingStoreMessage';
import DeleteNotInPerimeterAndMissingStoreMessage from '@salesforce/label/c.CT_DeleteNotInPerimeterAndMissingStoreMessage';
import DownloadNotInPerimeterMessage from '@salesforce/label/c.CT_DownloadNotInPerimeterMessage';

export default class Ct_buttonAndResultsSummary extends LightningElement {
  @api amountOfClients;
  @api notInPerimeter;
  @api clientsMissingStore;
  isDeleteButtonClicked = false;

  connectedCallback() {
    this.isDeleteButtonClicked = false;
  }

  get removeClientsMessage() {
    const notInPerimeterLength = Number(this.notInPerimeter.length);
    const missStoreLength = Number(this.clientsMissingStore?.data?.length);
    const isBothMessages = notInPerimeterLength && missStoreLength;
    const notInPerimeterMessage = DeleteNotInPerimeterMessage.replace('{numOfClients}', notInPerimeterLength);
    const missingStoreMessage = DeleteMissingStoreMessage.replace('{numOfClients}', missStoreLength);
    const notInPerimeterAndMissingStoreMessage = DeleteNotInPerimeterAndMissingStoreMessage
                                                .replace('{perimeterNumOfClients}', notInPerimeterLength)
                                                .replace('{storeNumOfClients}', missStoreLength);
    return isBothMessages ? notInPerimeterAndMissingStoreMessage : notInPerimeterLength ? notInPerimeterMessage : missingStoreMessage;
  }

  get downloadClientsMessage() {
    return DownloadNotInPerimeterMessage;
  }

  get isRemoveMessageDisplay() {
    return this.notInPerimeter?.length || this.clientsMissingStore?.data?.length && !this.isDeleteButtonClicked;
  }

  handleBackClick(){
    const selectedEvent = new CustomEvent("goback");
    this.dispatchEvent(selectedEvent);
  }

  handleDownloadClients() {
    this.dispatchEvent(new CustomEvent('downloadclients'));
  }

  handleDeleteClients() {
    this.isDeleteButtonClicked = true;
    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: true}, bubbles: true, composed: true})); 
    setTimeout(() => this.dispatchEvent(new CustomEvent('deleteclients')), 50);
  }
}