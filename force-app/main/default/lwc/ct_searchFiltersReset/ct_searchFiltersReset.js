import { LightningElement, wire, api } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import CL_STATE_RESET_CHANNEL from "@salesforce/messageChannel/clStateReset__c";

export default class ct_searchFiltersReset extends LightningElement {
  @wire(MessageContext) messageContext;
  @api name;
  handleFiltersReset() {
    const payload = { handleFiltersReset: this.name };
    publish(this.messageContext, CL_STATE_RESET_CHANNEL, payload);
  }
}