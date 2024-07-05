import { LightningElement, api } from "lwc";
export default class LightningExampleAccordionMultiple extends LightningElement {
  @api storage;
  @api userSettings;
  @api isDreamIdFlow;
  @api isUnlockStoreHierarchy;
  isEmptyClientListWorkflow = false;
  get activeSections() {
    return this.isDreamIdFlow
      ? ["storehierarchy"]
      : ["storehierarchy", "filters", "purchasehistory"];
  }

  handleStoreHierarchyMounted() {
    this.dispatchEvent(new CustomEvent("storehierarchymounted"));
  }

  handleFiltersClientsMounted() {
    this.dispatchEvent(new CustomEvent("filtersclientsmounted"));
  }

  handlePurchaseHistoryMounted() {
    this.dispatchEvent(new CustomEvent("purchasehistorysmounted"));
  }

  handleEmptyClientListWorkflow(event) {
    if (event.detail === false) {
      this.isEmptyClientListWorkflow = false;
    } else {
      this.isEmptyClientListWorkflow = !this.isEmptyClientListWorkflow;
      this.dispatchEvent(new CustomEvent("stateresetonemptyclientlist"));
    }
    return this.isEmptyClientListWorkflow;
  }

  handleUserSettingsApplied(event) {
    this.dispatchEvent(
      new CustomEvent("usersettingsapplied", { detail: event.detail })
    );
  }

  get isEmptyClientListClass() {
    return this.isEmptyClientListWorkflow || this.isDreamIdFlow
      ? "accordion-section-wrapper-disabled"
      : "accordion-section-wrapper";
  }

  get isDreamIdFlowClass() {
    return this.isDreamIdFlow
      ? "accordion-section-wrapper-disabled"
      : "accordion-section-wrapper";
  }

  @api
  uncheckEmptyClientList() {
    const storehierarchyElement =  this.template.querySelector('c-ct_search-filters-store-hierarchy');
    storehierarchyElement?.handleEmptyClientListChange({ target: { checked: false } });
  }
 
	handleSectionToggle(){}

}