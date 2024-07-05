import { api, LightningElement } from "lwc";

export default class Ct_genericHeaderAndButton extends LightningElement {
  @api headerTitle;
  @api isError = false;

  handleBackClick() {
    const selectedEvent = new CustomEvent("goback");
    this.dispatchEvent(selectedEvent);
  }
}