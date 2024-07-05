import { api, LightningElement } from "lwc";

export default class Icx_globalOverview extends LightningElement {
  @api recordId;
  @api authorizationToCreate;
  appName;
  hideSFsearchBar;

  connectedCallback() {
    console.log("display the value here", this.authorizationToCreate);
  }
}