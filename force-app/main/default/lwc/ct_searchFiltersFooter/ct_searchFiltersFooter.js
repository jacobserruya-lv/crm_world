import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LightningExampleLayoutSpace extends LightningElement {
  @api isFilterSelectionFlow;
  @api isDreamIdFlow;
  @api isDataAvailable;
  @api isEmptyClientList;
  subscription = null;

  get disabledSearch() {
    return !((this.isDreamIdFlow && this.isDataAvailable) || this.isFilterSelectionFlow || this.isEmptyClientList);
  }

  get isLoading() {
    return this.isDreamIdFlow && !this.isDataAvailable;
  }

  handleResetFilters() {
    this.dispatchEvent(new CustomEvent("resetallfilters"));
  }
  handleSearchClients() {
    if (this.isFilterSelectionFlow || this.isEmptyClientList) {
      this.dispatchEvent(new CustomEvent("filtersclientserch"));
    } else if (this.isDreamIdFlow && this.isDataAvailable) {
      this.dispatchEvent(new CustomEvent("dreamidclientsearch"));
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Warning!",
          message: "Select Management Zone Level or upload Dream ID's",
          variant: "warning"
        })
      );
    }
  }
}