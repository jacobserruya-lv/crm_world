import { LightningElement, api, track, wire } from "lwc";
import {
  subscribe,
  publish,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import CL_STATE_EXCHANGE_CHANNEL from "@salesforce/messageChannel/clStateExchange__c";
import CL_STATE_RESET_CHANNEL from "@salesforce/messageChannel/clStateReset__c";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import SUB_SEGMENT_FIELD from "@salesforce/schema/Account.Sub_Segment__c";

export default class Ct_clientFilters extends LightningElement {
  @api clientListWorkflow;
  @api isDreamIdFlow;
  @track storage = {
    gender: [],
    segmentationValue: [],
    contactableValue: []
  };
  resetSubscription = null;
  stateSubscription = null;
  globalStateReceived = false;
  showGenderList = false;
  selectedGenderList = [];
  genderValue = "Select an Option";
  segmentationValue = [];
  contactableValue = [];
  @wire(MessageContext)
  messageContext;

  @wire(getObjectInfo, { 
    objectApiName: ACCOUNT_OBJECT
  }) accountRecordTypeId;

  @wire(getPicklistValues,{
    recordTypeId: '$accountRecordTypeId.data.defaultRecordTypeId',
    fieldApiName: SUB_SEGMENT_FIELD
  }) subSegmentPicklist;

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.dispatchEvent(new CustomEvent("filtersclientsmounted"));
  }

  renderedCallback() {
    if (this.globalStateReceived) {
      this.handleGlobalStateRecived();
    }
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.resetSubscription);
    unsubscribe(this.stateSubscription);
    this.resetSubscription = null;
    this.stateSubscription = null;
  }

  subscribeToMessageChannel() {
    this.resetSubscription = subscribe(
      this.messageContext,
      CL_STATE_RESET_CHANNEL,
      (message) => this.handleResetMessage(message),
      { scope: APPLICATION_SCOPE }
    );
    this.stateSubscription = subscribe(
      this.messageContext,
      CL_STATE_EXCHANGE_CHANNEL,
      (message) => {
        if (message.clientFilters) {
          this.handleStateExchangeMessage(message);
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleResetMessage(message) {
    if (message.handleFiltersReset === "filters") {
      this.storage = {
        gender: [],
        segmentationValue: [],
        contactableValue: []
      };
      this.genderValue = "Select an Option";
      this.globalStateReceived = false;
      this.segmentationValue = [];
      this.contactableValue = [];
      let elements = this.template.querySelectorAll(
        ".filter-contactable-option"
      );
      elements.forEach((option) => {
        option.checked = false;
      });
      this.showGenderList = false;
      const payload = { clientFilters: this.storage };
      publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
    }
  }

  handleStateExchangeMessage(state) {
    if (
      state.clientFilters &&
      JSON.stringify(state.clientFilters) !== JSON.stringify(this.storage)
    ) {
      if (state.clientFilters.gender.length) {
        this.handleGenderUpdate(state.clientFilters.gender);
      }
      if (state.clientFilters.segmentationValue.length) {
        this.handleSegmentationChange(state.clientFilters.segmentationValue);
      }
      if (state.clientFilters.contactableValue.length) {
        this.globalStateReceived = true;
        this.handleContactableChange(state.clientFilters.contactableValue);
      }
    }
  }

  get isDisabled() {
    return this.clientListWorkflow || this.isDreamIdFlow ? true : false;
  }

  get genderOptions() {
    this.showGenderList = true;
    return [
      { label: "Unknown", value: "0" },
      { label: "Female", value: "1" },
      { label: "Male", value: "2" },
      { label: "Other", value: "3" }
    ];
  }

  get subSegmentOptions() {
    return this.subSegmentPicklist?.data?.values || [];
  }

  get segmentationOptions() {
    return [
      // These are the new sub segments
      ...this.subSegmentOptions,
    
      // These are the old segments, for now we only display the Prospect by Rafik's requirement https://vuitton.atlassian.net/browse/SE-691
      { label: "Prospects", value: "is_prospect" },
      // { label: "10K", value: "is_10k" },
      // { label: "Potential 10K", value: "is_potential_10k" },
      // { label: "10K This Year", value: "is_10k_this_year" },
      // { label: "50K", value: "is_50k" },
    ];
  }

  get contactableOptions() {
    return [
      {
        label: "At least one channel",
        name: "contactable_by_at_least_one_chan"
      },
      { label: "SMS/Chat App", name: "contactable_by_sms_or_chat" },
      { label: "Phone", name: "contactable_by_phone" },
      { label: "Email", name: "contactable_by_email" }
    ];
  }

  handleGenderUpdate(param) {
    this.selectedGenderList = param.detail
      ? Array.from(param.detail)
      : Array.from(param);
    this.storage.gender = this.selectedGenderList;
    this.showGenderList = false;
    const payload = { clientFilters: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  get selectedSegmentationValues() {
    return this.segmentationValue.join(",");
  }

  handleSegmentationChange(param) {
    this.segmentationValue = param.detail
      ? Array.from(param.detail?.value)
      : Array.from(param);
    this.storage.segmentationValue = this.segmentationValue;
    const payload = { clientFilters: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  get selectedContactableValues() {
    return this.contactableValue.join(",");
  }

  handleContactableChange(param) {
    let value = param.detail ? param.target?.name : param;

    if (this.contactableValue.includes(value) && !Array.isArray(value)) {
      this.contactableValue = this.contactableValue.filter(
        (option) => option !== value
      );
    } else if (Array.isArray(value)) {
      this.contactableValue.push(...value);
    } else this.contactableValue.push(value);
    this.storage.contactableValue = this.contactableValue;
    const payload = { clientFilters: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  async handleGlobalStateRecived() {
    let elements = this.template.querySelectorAll(".filter-contactable-option");
    elements.forEach((option) => {
      let match = this.contactableValue.find((item) => item === option.name);
      if (match) {
        option.checked = true;
      }
    });
  }
}