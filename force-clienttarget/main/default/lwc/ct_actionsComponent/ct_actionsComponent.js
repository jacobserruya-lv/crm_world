import { LightningElement, api, wire } from "lwc";
import getExclusiveOfferSettings from "@salesforce/apex/CL_controller.getExclusiveOfferSettings";
import getIsAllClientsInMyZone from "@salesforce/apex/CL_controller.getIsAllClientsInMyZone";

export default class Ct_actionsComponent extends LightningElement {
  @api isAllDreamIdsFromOneStore;
  @api isAllClientsInMyPerimeter;
  @api isAllClientsWithStore;
  @api isClentListEmpty;
  @api isUnlockStoreHierarchy;

  @wire(getIsAllClientsInMyZone)
  allClientsInMyZone;

  @wire(getExclusiveOfferSettings)
  exclusiveOfferSettings;

  get isExclusiveOfferDisplayed() {
    return this.exclusiveOfferSettings?.data?.isDisplay__c;
  }

  get isAllClientsInMyZone() {
    return this.allClientsInMyZone?.data === 'true';
  }

  goToReassign() {
    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: true}, bubbles: true, composed: true})); 

    setTimeout(() => {
      const selectedEvent = new CustomEvent("gotoreassign");
      this.dispatchEvent(selectedEvent);
    }, 100);
  }

  goToCreateClientList() {
    this.dispatchEvent(new CustomEvent('gotocreateclientlist'));
  }

  goToExclusiveSales() {
    this.dispatchEvent(new CustomEvent('gotoexclusivesales'));
  }

  goToAddClientsToAnEvent() {
    this.dispatchEvent(new CustomEvent('gottoaddclientstoanevent'));
  }

  get disableAddClientToAnEvent () {
    return !this.isAllClientsWithStore || !this.isAllClientsInMyPerimeter || this.isClentListEmpty;
  }

  get eventDisabledMessage () {
    return this.isClentListEmpty ? 'We did not find any clients' : 'Select only clients attached to a store in your perimeter';
  }

  get disabeldReattach () {
    const zonePerimeter = this.isUnlockStoreHierarchy ? this.isAllClientsInMyZone : this.isAllClientsInMyPerimeter;
    return this.isClentListEmpty || !zonePerimeter;
  }

  get disabeldExclusiveCreation () {
    return !this.isAllClientsInMyPerimeter || this.isClentListEmpty;
  }

  get disableRegularCreation() {
    return !this.isAllClientsWithStore || this.disabeldExclusiveCreation;
  }

  get reattachDisabeldMessage () {
    return !this.isAllClientsInMyPerimeter ? 'Select only clients that are within your perimeter' : 'Select only clients from one store for Reattach';
  }

  get exclusiveDisabledMessage () {
    return this.isClentListEmpty ? 'We did not find any clients' : 'Select only clients that are within your perimeter';
  }

  get clientListDisabledMessage () {
    return this.isClentListEmpty ? 'You can only create empty client list' :
           !this.isAllClientsInMyPerimeter  ? 'You can only create empty client list (Some clients are not in your perimeter)' :
           'You can only create empty client list (Some clients are not attached to any store)';
  }
}