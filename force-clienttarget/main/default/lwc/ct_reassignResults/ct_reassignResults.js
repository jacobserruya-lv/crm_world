import { LightningElement, api } from "lwc";

export default class Ct_reassignResults extends LightningElement {
  @api isReassignStep;
  @api storage;
  @api allStoresList;
  @api isUnlockStoreHierarchy;

  //Return variable for use in Result list of Reassign step
  connectedCallback() {
    return this.isReassignStep;
  }

  handleUserSettingsApplied(event) {
    this.dispatchEvent(
      new CustomEvent("usersettingsapplied", { detail: event.detail })
    );
  }

  handleStoreHierarchyMounted() {
    this.dispatchEvent(new CustomEvent("storehierarchymounted"));
  }

  handleNewSaSelectionMounted() {
    this.dispatchEvent(new CustomEvent("newsaselectionmounted"));
  }

  handleDoneAssignment() {
    this.dispatchEvent(new CustomEvent("goback", { detail: { reset: true } }));
  }

  get clientList() {
    return [...this.storage.clientList];
  }

  get storeHierarchy() {
    return this.storage.storeHierarchy;
  }
}