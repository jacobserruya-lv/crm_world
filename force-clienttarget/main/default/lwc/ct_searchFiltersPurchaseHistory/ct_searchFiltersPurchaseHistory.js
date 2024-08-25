import { LightningElement, api, track, wire } from "lwc";
import {
  subscribe,
  publish,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import CL_STATE_EXCHANGE_CHANNEL from "@salesforce/messageChannel/clStateExchange__c";
import CL_STATE_RESET_CHANNEL from "@salesforce/messageChannel/clStateReset__c";
import getProductCategoriesList from "@salesforce/apex/CT_CSVParseController.getProductCategoriesList";

export default class ct_purchaseHistory extends LightningElement {
  @api clientListWorkflow;
  @api isDreamIdFlow;
  @track storage = {
    purchaseValue: "",
    productCategories: []
  };
  resetSubscription = null;
  stateSubscription = null;
  globalStateReceived = false;
  isPurchaseValueChosen = false;
  purchaseValue = "";
  productCategoriesInitialState = [];
  productCategories = [];
  error;
  @wire(getProductCategoriesList)
  getProductCategoriesList({ data, error }) {
    if (data) {
      this.productCategories = data.map( category => {
        return {
          id: category.Id,
          name: category.Name,
          value: category.API_Name__c,
          include: { label: "Yes", state: false },
          exclude: { label: "No", state: false }
        }
      });
      this.productCategoriesInitialState = JSON.parse(
        JSON.stringify(this.productCategories)
      );
    } else if (error) {
      this.error = error;
    }
  }
  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.dispatchEvent(new CustomEvent("purchasehistorysmounted"));
    if (!this.globalStateReceived) {
      this.productCategoriesInitialState = JSON.parse(
        JSON.stringify(this.productCategories)
      );
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
        if (message.purchaseHistory) {
          this.handleStateExchangeMessage(message);
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleResetMessage(message) {
    if (message.handleFiltersReset === "purchasehistory") {
      this.storage = {
        purchaseValue: "",
        productCategories: []
      };
      this.purchaseValue = "";
      this.globalStateReceived = false;
      this.isPurchaseValueChosen = false;
      this.productCategories = JSON.parse(
        JSON.stringify(this.productCategoriesInitialState)
      );
      const payload = { purchaseHistory: this.storage };
      publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
    }
  }

  handleStateExchangeMessage(state) {
    if (
      state.purchaseHistory &&
      JSON.stringify(state.purchaseHistory) !== JSON.stringify(this.storage)
    ) {
      if (state.purchaseHistory.productCategories.length > 0) {
        this.globalStateReceived = true;
        this.handleProductCategoriesChange(
          state.purchaseHistory.productCategories
        );
      }
      if (state.purchaseHistory.purchaseValue) {
        this.handlePurchaseChange(state.purchaseHistory.purchaseValue);
      }
    }
  }

  get isDisabled() {
    return this.clientListWorkflow ||
      this.isDreamIdFlow ||
      !this.isPurchaseValueChosen
      ? true
      : false;
  }

  get isPurchaseOptionsDisabled() {
    return this.clientListWorkflow || this.isDreamIdFlow ? true : false;
  }

  get purchaseOptions() {
    return [
      { label: "Historical", value: "has_purchase" },
      { label: "12 MR", value: "has_purchase_12mr" },
      { label: "YTD", value: "has_purchase_ytd" }
    ];
  }

  handlePurchaseChange(param) {
    this.isPurchaseValueChosen = true;
    this.purchaseValue = param.detail ? param.detail.value : param;
    this.storage.purchaseValue = this.purchaseValue;
    const payload = { purchaseHistory: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  handleProductCategoriesChange(param) {
    if (param.target) {
      let currentCategory = param.target.getAttribute("data-id");
      let result = this.productCategories.map((item) => {
        if (
          item.id === currentCategory &&
          item.include.label === param.target.label
        ) {
          item.include.state = param.target.checked;
          item.exclude.state = false;
        } else if (
          item.id === currentCategory &&
          item.exclude.label === param.target.label
        ) {
          item.exclude.state = param.target.checked;
          item.include.state = false;
        }
        return item;
      });
      this.productCategories = result;
      this.storage.productCategories = result.reduce(function (
        categories,
        item
      ) {
        if (item.exclude.state === true || item.include.state === true) {
          categories.push(item);
        }
        return categories;
      },
      []);
      const payload = { purchaseHistory: this.storage };
      publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
    } else {
      this.productCategoriesInitialState = JSON.parse(
        JSON.stringify(this.productCategories)
      );
      this.storage.productCategories = param;
      this.productCategories = this.productCategories.map((category) => {
        this.storage.productCategories.map((currentCategoryState) => {
          if (currentCategoryState.id === category.id) {
            category = JSON.parse(JSON.stringify(currentCategoryState));
          }
          return currentCategoryState;
        });
        return category;
      });
    }
  }
}