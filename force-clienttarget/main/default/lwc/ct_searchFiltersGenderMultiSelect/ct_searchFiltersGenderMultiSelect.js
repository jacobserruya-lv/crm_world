import { LightningElement, api, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import CL_STATE_RESET_CHANNEL from "@salesforce/messageChannel/clStateReset__c";

const SELECT_OPTION_PLACEHOLDER = "Select an Option";

export default class Ct_searchFiltersCaMultiSelect extends LightningElement {
  @api options;
  @api showGenderList;
  @api isDisabled;
  @api selectedGenderList;
  selectedGenderListRecived = false;
  subscription = null;
  handleFiltersReset;
  genderValues = [];
  genderLabels = [];
  preferedGenderInputValue = SELECT_OPTION_PLACEHOLDER;
  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToMessageChannel();
    if (this.selectedGenderList.length) {
      this.handleGenderSelection(this.selectedGenderList);
    }
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
    if (message.handleFiltersReset === "filters") {
      let existsGenderList = this.template.querySelector(
        ".filters-gender-selection"
      );
      existsGenderList.classList.add("slds-hide");
      if (existsGenderList) {
        let elements = this.template.querySelectorAll(
          "[type=checkbox]:checked"
        );
        elements.forEach(function (value) {
          value.checked = false;
        });
      }
      this.genderValues = [];
      this.selectedGenderListRecived = false;
      this.preferedGenderInputValue = SELECT_OPTION_PLACEHOLDER;
    }
  }

  handleGenderSelection(param) {
    if (param.target?.checked) {
      this.template
        .querySelector(".filters-gender-holder")
        .classList.remove("slds-has-error");
      this.genderValues = [...this.genderValues, param.target.value];
      this.genderValues = [...new Set(this.genderValues)];
      this.preferedGenderInputValue = `${this.genderValues.length} options selected`;
    } else if (Array.isArray(param)) {
      this.selectedGenderListRecived = true;
      this.genderValues = param;
      this.preferedGenderInputValue = `${this.genderValues.length} options selected`;
    } else {
      this.genderValues = this.genderValues.filter(
        (value) => value !== param.target.value
      );
      this.preferedGenderInputValue = `${this.genderValues.length} options selected`;
    }
  }

  handleSelectedGender() {
    this.template
      .querySelector(".filters-gender-selection")
      .classList.toggle("slds-hide");
    this.dispatchEvent(
      new CustomEvent("genderupdate", {
        detail: this.genderValues
      })
    );
    this.preferedGenderInputValue =
      this.genderValues.length > 0
        ? `${this.genderValues.length} options selected`
        : SELECT_OPTION_PLACEHOLDER;
  }

  removeSelectedGender() {
    let elements = this.template.querySelectorAll("[type=checkbox]:checked");
    elements.forEach(function (value) {
      value.checked = false;
    });
    this.genderValues = [];
    this.template
      .querySelector(".filters-gender-selection")
      .classList.toggle("slds-hide");
    this.dispatchEvent(
      new CustomEvent("genderupdate", {
        detail: this.genderValues
      })
    );
    this.preferedGenderInputValue = SELECT_OPTION_PLACEHOLDER;
  }

  handleGenderClick() {
    let existsGenderList = this.template.querySelector(
      ".filters-gender-selection"
    );
    existsGenderList.classList.toggle("slds-hide");
    if (this.selectedGenderListRecived) {
      let elements = this.template.querySelectorAll("[type=checkbox]");
      elements.forEach((checkbox) => {
        let match = this.selectedGenderList.find(
          (item) => item === checkbox.value
        );
        if (match) {
          checkbox.checked = true;
        }
      });
    }
  }
}