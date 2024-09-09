import { LightningElement, api, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import CL_STATE_RESET_CHANNEL from "@salesforce/messageChannel/clStateReset__c";

export default class Ct_searchFiltersCaMultiSelect extends LightningElement {
  @api options;
  @api clientsForCaList;
  @api showCaList;
  @api isDisabled;
  @api selectedCa;
  caSearchInput = "";
  isOpened = false;
  isRendered = false;
  subscription = null;
  handleFiltersReset;
  selectedCustomerAdvisor;
  customerAdvisors = [];
  customerAdvisorsNames = [];
  @wire(MessageContext)
  messageContext;

  get searchedOptions() {
    return [...this.options]?.filter((client) => {
      if (client.label?.toUpperCase().includes(this.caSearchInput?.toUpperCase())) {
        return client;
      }
    });
  }

  get preferedCaInputValue() {
    return this.customerAdvisors.length > 0 ? `${this.customerAdvisors.length} options selected` : 'Select an Option (optional)';
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
    if (this.selectedCa.length) {
      this.handleCustomerAdviserSelection(this.selectedCa);
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
    if (message.handleFiltersReset === "storehierarchy") {
      let existsCaList = this.template.querySelector(".filters-ca-selection");
      if (existsCaList) {
        let elements = this.template.querySelectorAll(
          "[type=checkbox]:checked"
        );
        elements.forEach(function (value) {
          value.checked = false;
        });
      }
      this.customerAdvisors = [];
      this.isOpened = true;
      this.handlePreferedCaClick();
    }
  }

  handleCustomerAdviserSelection(param) {
    const target = param.target ?? param;
    if (target?.checked) {
      this.template
        .querySelector(".filters-ca-holder")
        .classList.remove("slds-has-error");
      this.selectedCustomerAdvisor = target.value;
      let preferedCaData = [];
      this.options.map((item, i) => {
        if (item.value === target.value) {
          preferedCaData.push({
            clients: item.clients || '0',
            id: i,
            employeeNumber: item.employeeNumber,
            options: [
              {
                label: item.label,
                value: item.value
              }
            ]
          });
        }
        return item;
      });
      this.customerAdvisors = [...this.customerAdvisors, ...preferedCaData];
      this.customerAdvisors = [...new Set(this.customerAdvisors)];
    } else if (Array.isArray(param)) {
      this.customerAdvisors = param;
    } else {
      this.customerAdvisors = [...this.customerAdvisors.filter(
        (value) => value.options[0].value !== target.value
      )];
    }
  }

  @api
  handleSelectedCaChange() {
    this.handleCustomerAdviserSelection([]);
  }

  handleSelectedCustomerAdvisers() {
    if (this.customerAdvisors.length === 0) {
      this.template
        .querySelector(".filters-ca-holder")
        .classList.add("slds-has-error");
    } else {
      this.template
        .querySelector(".filters-ca-selection")
        .classList.toggle("slds-hide");
      this.dispatchEvent(
        new CustomEvent("customeradvisorsupdate", {
          detail: this.customerAdvisors
        })
      );
      this.caSearchInput = "";
    }
  }

  autoCheckedSelectedCa() {
    this.isRendered = true;
    const elements = this.template.querySelectorAll('[type=checkbox]:checked');
    if (this.customerAdvisors.length > 0 && elements?.length === 0) {
      this.template.querySelectorAll('.slds-checkbox > input')?.forEach(e => {
        e.checked = this.customerAdvisors.find(c => e.value === c.options[0]?.value);
      });
    }
  }

  handleCaSearch(event) {
    this.caSearchInput = event?.target?.value;
  }

  removeSelectedCustomerAdvisers() {
    let elements = this.template.querySelectorAll("[type=checkbox]:checked");
    elements.forEach((value) => {
      value.checked = false;
    });
    this.customerAdvisors = [];
    this.caSearchInput = "";
    this.handlePreferedCaClick();
    this.dispatchEvent(new CustomEvent("customeradvisorsupdate", {
      detail: this.customerAdvisors
    }));
  }

  handlePreferedCaClick() {
    let existsCaList = this.template.querySelector(".filters-ca-selection");
    if (existsCaList && this.isOpened === false) {
      if (!this.isRendered) {
        this.autoCheckedSelectedCa();
      }
      existsCaList.classList.remove("slds-hide");
      this.isOpened = true;
    } else if (existsCaList && this.isOpened === true) {
      existsCaList.classList.add("slds-hide");
      this.isOpened = false;
    }
  }

  @api 
  handleResetFromParent() {
    const message = { handleFiltersReset: "storehierarchy" };
    this.handleResetMessage(message);
  }
}