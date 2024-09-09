import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  subscribe,
  publish,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import CL_STATE_EXCHANGE_CHANNEL from "@salesforce/messageChannel/clStateExchange__c";
import CL_STATE_RESET_CHANNEL from "@salesforce/messageChannel/clStateReset__c";
import readCSV from "@salesforce/apex/CT_CSVParseController.readCSVFile";

const columns = [{ label: "DreamId", fieldName: "DreamId" }];
export default class Ct_uploadCSV extends LightningElement {
  @api recordId;
  @api isFileLoaded;
  @api isFilterSelectionFlow;
  @track error;
  @track columns = columns;
  @track data;
  isDreamIdFlow;
  subscription;
  @wire(MessageContext)
  messageContext;

  // accepted parameters
  get acceptedFormats() {
    return [".csv"];
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  subscribeToMessageChannel() {
    this.subscription = subscribe(
      this.messageContext,
      CL_STATE_RESET_CHANNEL,
      (message) => this.handleResetMessage(message),
      { scope: APPLICATION_SCOPE }
    );
  }

  handleResetMessage(message) {
    if (message.handleFiltersReset === "dreamidlistreset") {
      this.data = [];
      this.isDreamIdFlow = false;
      this.dispatchEvent(
        new CustomEvent("dreamidflow", {
          detail: {
            isdreamidflow: this.isDreamIdFlow
          }
        })
      );
      const payload = { handleDreamIdListUpdate: this.data };
      publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
    }
  }

  handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    let idsArray = [];
    let i = 0;

    // calling apex class
    readCSV({ idContentDocument: uploadedFiles[0].documentId })
      .then((result) => {
        this.data = result.split('\n').map(l => l.replace("\r", "").replace("﻿", "")).filter(l => !!l);
        if (this.data.length > 50000) {
          throw 'Too many results, We currently do not support more than 50,000 results!';
        }
        this.isDreamIdFlow = true;
        this.dispatchEvent(
          new CustomEvent("dreamidflow", {
            detail: {
              isdreamidflow: this.isDreamIdFlow
            }
          })
        );
        const payload = { handleDreamIdListUpdate: this.data };
        publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
      })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success!",
            message: "Number of Dream ID's uploaded {1}",
            messageData: [
              "Salesforce",
              {
                idsArray,
                label: `${this.data.length}`
              }
            ],
            variant: "success",
            mode: "dismissible"
          })
        );
      })
      .catch((error) => {
        this.isDreamIdFlow = false;
        this.isFileLoaded = false;
        this.dispatchEvent(
          new CustomEvent("dreamidflow", {
            detail: {
              isdreamidflow: this.isDreamIdFlow
            }
          })
        );
        this.error = error.body?.message || error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!!",
            message: "Something wrong with this file: " + this.error,
            variant: "error"
          })
        );
      });
  }

  get textHeaderForComponent() {
    return this.isFileLoaded
      ? "1 file was loaded successfully"
      : "Upload Dream ID Using .CSV File";
  }
}