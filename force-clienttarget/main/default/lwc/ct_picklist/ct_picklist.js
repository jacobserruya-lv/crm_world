import { api, LightningElement } from "lwc";

export default class Ct_picklist extends LightningElement {
  @api item;
  value = "Select an Option";
  placeholder = "Select an Option";

  get options() {
    return [this.item.options[0], this.item.options[1]];
  }

  handleChange(event) {
    this.value = event.detail.value;
  }
}