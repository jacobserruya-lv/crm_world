import { wire, track, LightningElement } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import {
  subscribe,
  publish,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getBasicClientList from "@salesforce/apex/CL_controller.getBasicClientList";
import getClientsByEngineFilters from "@salesforce/apex/CL_controller.getClientsByEngineFilters";
import getQueryConfig from "@salesforce/apex/CL_controller.getQueryConfig";
import getNotContactableClients from "@salesforce/apex/CL_controller.getNotContactableClients";
import getIsAllClientsInMyPerimeter from "@salesforce/apex/CL_controller.getIsAllClientsInMyPerimeter";
import isAllFromOneStore from "@salesforce/apex/CT_CSVParseController.isAllFromOneStore";
import isAllClientsWithStore from "@salesforce/apex/CT_CSVParseController.isAllClientsWithStore";
import getClientsMissingStore from "@salesforce/apex/CT_CSVParseController.getClientsMissingStore";
import getUnattachedDreamIds from "@salesforce/apex/CL_controller.getUnattachedDreamIds";
import getAllStores from "@salesforce/apex/CL_controller.getAllStores";
import CL_STATE_EXCHANGE_CHANNEL from "@salesforce/messageChannel/clStateExchange__c";
import CL_STATE_RESET_CHANNEL from "@salesforce/messageChannel/clStateReset__c";
import ct_searchFilters from "@salesforce/resourceUrl/ctCssLib";
import getActionPermissionByProfile from "@salesforce/apex/CL_controller.getActionPermissionByProfile";
import { MarketingEngineQueryBuilder} from './ct_marketingEngineQueryBuilder';
import * as Types from "./ct_types";

const PHONE_COUNTRIES = ["CHINA"];
export default class Ct_mainContainer extends LightningElement {
  /**
   * @type {Types.Storage}
   */
  @track storage = {
    dreamIdList: null,
    storeHierarchy: null,
    clientFilters: null,
    purchaseHistory: null,
    clientList: null,
    clientListInfo: null,
    eventInfo: null,
    campaignInfo: null
  };
  @track isLoading = false;
  spinnerText = "Search for Clients";
  subscription = null;
  clientListQuery = { filters: [], size: 0, from: 0 };
  queryBase = {};
  clients = null;
  error = null;
  stateAccumulator;
  userSettings;
  isDreamIdFlow = false;
  isFilterSelectionFlow = false;
  isUploadFileDisabled = false;
  isEmptyClientList = false;
  isFirstStep = false;
  isActionSelectionStep = false;
  isReassignStep = false;
  isClientListCreatedStep = false;
  isClientAddedToAnEventStep = false;
  isClientPushedToCampaignStep = false;
  isEmptyClientListCreatedStep = false;
  isExclusiveAccessStep = false;
  isCreateClientListModal = false;
  isExclusiveSalesModal = false;
  isAddClientsToAnEventModal = false;
  isPushToCampaign = false;
  isClientListCreatedSuccessfully = false;
  isAddingClientsToEventFinished = false;
  isAddingClientsToEventFinishedWithTotalError = false;
  isPushingClientsToCampaignFinished = false;
  isPushingClientsToCampaignFinishedWithTotalError = false;
  isAllClientsInMyPerimeter = false;
  isTriggeredFromFirstPage = false;
  unlockStoreHierarchy = false;
  saveApiCache = true;
  phoneCountries = PHONE_COUNTRIES;
  userPerimeter = {
    type: "",
    zone: ""
  };
  notInPerimeterClients = [];
  savedPerimeter;
  @wire(getBasicClientList, {
    dreamIds: "$storage.dreamIdList"
  })
  clientListOnDreamIdResult;
  @wire(getNotContactableClients, {
    dreamIds: "$storage.dreamIdList",
    phoneCountries: "$phoneCountries"
  })
  notContactableClients;
  @wire(isAllFromOneStore, {
    dreamIds: "$storage.dreamIdList"
  })
  allFromOneStore;
  @wire(isAllClientsWithStore, {
    dreamIds: "$storage.dreamIdList"
  })
  allClientsWithStore;
  @wire(getClientsMissingStore, {
    dreamIds: "$storage.dreamIdList"
  })
  clientsMissingStore;
  @wire(getUnattachedDreamIds, {
    dreamIds: "$storage.dreamIdList"
  })
  unattachedDreamIds;
  @wire(getAllStores)
  allStoresList;
  @wire(getQueryConfig)
  queryConfigMdt;
  @wire(MessageContext)
  messageContext;

  userCanPushToCampaign = false;

  constructor() {
    super();
    this.handleSpinner();
    this.handleDefaultStoreSaved();
  }

  goToCreateClientList() {
    this.isCreateClientListModal = !this.isCreateClientListModal;

    if (this.isEmptyClientList) {
      const filtersElement = this.template.querySelector("c-ct_search-filters");
      filtersElement?.uncheckEmptyClientList();
    }
  }

  goToExclusiveSales() {
    this.isExclusiveSalesModal = !this.isExclusiveSalesModal;
  }

  goToAddClientsToAnEvent() {
    this.isAddClientsToAnEventModal = !this.isAddClientsToAnEventModal;
  }

  goToPushToCampaign() {
    this.isPushToCampaign = !this.isPushToCampaign;
  }

  handleClientCreatedSuccessfully() {
    this.isClientListCreatedSuccessfully = true;
  }

  handleAddingClientsToEventFinished(event) {
    this.isAddingClientsToEventFinishedWithTotalError =
      event.detail.errorsListLength === this.storage.dreamIdList.length;
    this.isAddingClientsToEventFinished = true;
  }

  handlePushingClientsToCampaignFinished(event) {
    this.isPushingClientsToCampaignFinishedWithTotalError =
      event.detail.errorsListLength === this.storage.dreamIdList.length;
    this.isPushingClientsToCampaignFinished = true;
  }

  connectedCallback() {
    getActionPermissionByProfile().then((data) => {
      if (data) {
        this.unlockStoreHierarchy = data.unlockStoreProfiles;
        this.userCanPushToCampaign = data.pushToCampaign;
      }

      Promise.all([
        loadStyle(this, ct_searchFilters + "/ct_searchFilters.css")
      ]).catch((error) => {
        console.log(error.body.message);
      });
      this.isFirstStep = true;
      this.subscribeToMessageChannel();
    });
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
      CL_STATE_EXCHANGE_CHANNEL,
      (message) => {
        if (
          message.storeHierarchy ||
          message.clientFilters ||
          message.purchaseHistory ||
          message.handleDreamIdListUpdate ||
          message.handleNewClientList
        ) {
          this.handleStateExchangeMessage(message);
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleSpinner() {
    this.template.addEventListener("loadspinner", (event) => {
      this.isLoading = event.detail.isLoading;
      this.spinnerText = event.detail?.text || "Loading";
    });
  }

  handleDefaultStoreSaved() {
    this.template.addEventListener("savedolddefaultstore", (event) => {
      if (!this.savedPerimeter) {
        this.savedPerimeter = JSON.parse(
          JSON.stringify(event.detail.storeHierarchy)
        );
      }
    });
  }

  resetDefaultStore() {
    if (this.savedPerimeter) {
      const default_store = this.savedPerimeter.default_store || "reset";
      const prefered_ca =
        default_store === "reset" ? ["reset"] : this.savedPerimeter.prefered_ca;
      const storeHierarchy = {
        ...this.savedPerimeter,
        default_store,
        prefered_ca
      };

      let resetPayload = { handleFiltersReset: "storehierarchy" };
      publish(this.messageContext, CL_STATE_RESET_CHANNEL, resetPayload);

      let savedPerimeterPayload = { storeHierarchy: storeHierarchy };
      publish(
        this.messageContext,
        CL_STATE_EXCHANGE_CHANNEL,
        savedPerimeterPayload
      );
      this.savedPerimeter = null;
    }
  }

  handleAllFiltersReset() {
    let payload = { handleFiltersReset: "dreamidlistreset" };
    publish(this.messageContext, CL_STATE_RESET_CHANNEL, payload);
    payload = { handleFiltersReset: "storehierarchy" };
    publish(this.messageContext, CL_STATE_RESET_CHANNEL, payload);
    payload = { handleFiltersReset: "filters" };
    publish(this.messageContext, CL_STATE_RESET_CHANNEL, payload);
    payload = { handleFiltersReset: "purchasehistory" };
    publish(this.messageContext, CL_STATE_RESET_CHANNEL, payload);
    this.storage = {
      dreamIdList: null,
      storeHierarchy: this.userSettings || null,
      clientFilters: null,
      purchaseHistory: null,
      clientList: null,
      clientListInfo: null
    };
    this.clientListQuery = { filters: [], size: 0, from: 0 };
    this.isDreamIdFlow = false;
    this.isFilterSelectionFlow = false;
    this.isUploadFileDisabled = false;
    this.savedPerimeter = null;
  }

  handleResetOnEmptyClientList() {
    this.isEmptyClientList = !this.isEmptyClientList;
    this.isCreateClientListModal = this.isEmptyClientList;
    this.isTriggeredFromFirstPage = this.isCreateClientListModal;
  }

  handleResetOnDreamIdFlow() {
    let payload = { handleFiltersReset: "filters" };
    publish(this.messageContext, CL_STATE_RESET_CHANNEL, payload);
    payload = { handleFiltersReset: "purchasehistory" };
    publish(this.messageContext, CL_STATE_RESET_CHANNEL, payload);
    this.storage = {
      dreamIdList: this.storage.dreamIdList,
      storeHierarchy: this.storage.storeHierarchy || this.userSettings,
      clientFilters: null,
      purchaseHistory: null,
      clientList: null,
      clientListInfo: null
    };
    this.clientListQuery = { filters: [], size: 0, from: 0 };
    this.isDreamIdFlow = true;
    this.isFilterSelectionFlow = false;
    this.isUploadFileDisabled = false;
  }

  handleUserSettingsApplied(event) {
    //  BUG CSV UPLOAD UNAVAILABLE STATE INCONSISTANCY ON BACK BUTTON PRESSED
    this.userSettings = this.userSettings ?? event.detail;
    if (
      JSON.stringify(this.userSettings) ===
        JSON.stringify(this.storage.storeHierarchy) &&
      !this.storage.clientFilters &&
      !this.storage.purchaseHistory &&
      !this.storage.storeHierarchy?.default_store
    ) {
      this.isFilterSelectionFlow = false;
      this.isUploadFileDisabled = false;
    }
  }

  handleStoreHierarchyMounted() {
    if (this.storage.storeHierarchy !== null && !this.isDreamIdFlow) {
      this.isFilterSelectionFlow = true;
    }
    const payload = { storeHierarchy: this.storage.storeHierarchy };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  initUserPerimeter() {
    this.userPerimeter = { type: "", zone: "" };

    if (this.userSettings) {
      const {
        management_zone_level,
        management_zone_level_1,
        management_zone_level_2,
        management_zone_level_3,
        default_store
      } = this.userSettings;

      if (default_store) {
        this.userPerimeter = { type: "store", zone: default_store };
      } else if (management_zone_level_3) {
        this.userPerimeter = { type: "level3", zone: management_zone_level_3 };
      } else if (management_zone_level_2) {
        this.userPerimeter = { type: "level2", zone: management_zone_level_2 };
      } else if (management_zone_level_1) {
        this.userPerimeter = { type: "level1", zone: management_zone_level_1 };
      } else if (management_zone_level) {
        this.userPerimeter = { type: "level", zone: management_zone_level };
      }

      if (this.storage?.dreamIdList?.length > 0) {
        getIsAllClientsInMyPerimeter({
          type: this.userPerimeter.type,
          zone: this.userPerimeter.zone,
          dreamIds: this.storage.dreamIdList
        }).then((data) => {
          this.isAllClientsInMyPerimeter = data?.length < 1;
          this.notInPerimeterClients = data || [];
        });
      }
    }
  }

  handleFiltersClientsMounted() {
    if (this.storage.clientFilters !== null && !this.isDreamIdFlow) {
      this.isFilterSelectionFlow = true;
      this.isUploadFileDisabled = true;
    }
    const payload = { clientFilters: this.storage.clientFilters };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  handlePurchaseHistoryMounted() {
    if (this.storage.purchaseHistory !== null && !this.isDreamIdFlow) {
      this.isFilterSelectionFlow = true;
      this.isUploadFileDisabled = true;
    }
    const payload = { purchaseHistory: this.storage.purchaseHistory };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  handleNewSaSelectionMounted() {
    const payload = { handleNewClientList: this.storage.clientList };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  handleDeleteClients() {
    const clientsToDelete = [
      ...(this.notInPerimeterClients || []),
      ...(this.clientsMissingStore?.data || []),
      ...(this.unattachedDreamIds?.data || [])
    ];
    const isToDeleteDreamId = (c) => clientsToDelete.indexOf(c.DREAMID__c) == -1;
    const updatedList = [...this.storage.clientList].filter(isToDeleteDreamId);
    const payload = { handleNewClientList: updatedList };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);

    this.notInPerimeterClients = [];
    this.template.querySelector("c-ct_result-list")?.reloadClients(updatedList);
  }

  get isCampaignFlow() {
    return this.storage.assignedCaByDreamId &&
           Object.values(this.storage.assignedCaByDreamId).filter(Boolean).length;
  }

  get isClientListCreatedHeader() {
    return this.isClientListCreatedSuccessfully
      ? "Client list successfully Created"
      : "Creating a client list has started successfully";
  }

  get clientsAddedToAnEventHeader() {
    return !this.isAddingClientsToEventFinished
      ? "Adding client to the event in progress"
      : this.isAddingClientsToEventFinishedWithTotalError
      ? "couldn't add any of the clients to the event"
      : "Clients successfully added to the Event";
  }

  get campaignId() {
    return this.storage?.campaignInfo?.id;
  }
  
  get clientsPushedToCampaignHeader() {
    return !this.isPushingClientsToCampaignFinished
      ? "Pushing clients to the campaign in progress"
      : this.isPushingClientsToCampaignFinishedWithTotalError
      ? "couldn't push any of the clients to the campaign"
      : "Clients successfully pushed to the Campaign";
  }

  /**
   * @type {Types.QueryConfig}
   */
  get queryConfig() {
    return JSON.parse(this.queryConfigMdt?.data?.data__c || "") || {};
  }

  get isClentListEmpty() {
    return !this.storage.clientList || this.storage.clientList.length < 1;
  }

  get isAllDreamIdsFromOneStore() {
    return this.allFromOneStore?.data;
  }

  get isDataAvailable() {
    return this.clientListOnDreamIdResult?.data?.length > 0;
  }

  get amountOfClients() {
    let amountOfClients;
    if (
      this.storage.clientList !== null &&
      this.storage.clientList.length > 0
    ) {
      amountOfClients = this.storage.clientList.length;
    } else {
      amountOfClients = 0;
    }
    return amountOfClients;
  }

  get contactableClients() {
    const notContactableClients = this.notContactableClients?.data?.map(
      (c) => c.DREAMID__c
    );
    return [...this.storage.clientList].filter(
      (c) => !notContactableClients.includes(c.DREAMID__c)
    );
  }

  get isAllClientsWithStore() {
    return this.allClientsWithStore?.data;
  }

  getStoreHierarchyLevel() {
    const userSettings = this.storage?.storeHierarchy || {};
    const {
      management_zone_level,
      management_zone_level_1,
      management_zone_level_2,
      management_zone_level_3,
      default_store
    } = userSettings;

    if (default_store) {
      return { type: "store", zone: default_store };
    } else if (management_zone_level_3) {
      return { type: "level3", zone: management_zone_level_3 };
    } else if (management_zone_level_2) {
      return { type: "level2", zone: management_zone_level_2 };
    } else if (management_zone_level_1) {
      return { type: "level1", zone: management_zone_level_1 };
    } else if (management_zone_level) {
      return { type: "level", zone: management_zone_level };
    }

    return { type: "", zone: "" };
  }

  /**
   * @param {Types.MtEngineResponse} mtEngineResponse the response getting from apex is actually a string and have to be parsed
   * @returns {[string | number]}
   */
  parseMtEngineResponseIntoDreamIds (mtEngineResponse) {
    const responseBody = JSON.parse(mtEngineResponse);
    console.log(`Number of clients found on Data Platform: ${responseBody.Contacts.length}`);
    return responseBody.Contacts.map(c => c.dream_id);
  }

  handleFiltersClientSearch() {
    this.spinnerText = "Search for Clients";
    this.isLoading = true;

    if (!this.isEmptyClientList) {
      const ownerIds = this.storage.storeHierarchy?.prefered_ca?.map(
        (ca) => ca.employeeNumber
      );
      const storeHierarchyLevel = this.getStoreHierarchyLevel();
      const queryManager = new MarketingEngineQueryBuilder(this.queryConfig);
      const query = queryManager.createCTQuery(
        JSON.parse(JSON.stringify(this.storage))
      );
      
      console.log({ query });

      getClientsByEngineFilters({
        filters: JSON.stringify(query),
        type: storeHierarchyLevel.type,
        zone: storeHierarchyLevel.zone,
        ignoreCache: this.saveApiCache ? "useCache" : Date.now().toString(),
        ownerIds: ownerIds || []
      })
      .then(this.parseMtEngineResponseIntoDreamIds)
      .then((dreamIds) => getBasicClientList({dreamIds}))
      .then((clients) => {
        this.storage.dreamIdList = clients.map(c => c.DREAMID__c);
        this.initUserPerimeter();
        this.initializeClients(clients);
        this.saveApiCache = true;
        this.goToNextStep();
      })
      .catch((error) => {
        this.error = error?.body?.message;
        this.isLoading = false;

        const toastEvent = new ShowToastEvent({
          title: "Error!",
          message: `Something went wrong, please try adding more filters (${
            this.error || ""
          })`,
          variant: "error"
        });
        this.dispatchEvent(toastEvent);
      });
    } else {
      this.goToNextStep();
    }
  }

  handleDreamIdClientSearch() {
    this.spinnerText = "Search for Clients";
    this.isLoading = true;
    const dataResult = this.clientListOnDreamIdResult.data;
    this.initUserPerimeter();

    setTimeout(() => {
      if (dataResult) {
        this.initializeClients(dataResult);
      }
      this.goToNextStep();
    }, 100);
  }

  initializeClients(data) {
    this.error = this.clientListOnDreamIdResult.error;
    this.storage.clientList = data;
    this.storage.dreamIdList = this.storage.clientList.map((c) => c.DREAMID__c);

    //Delete Fake Id From DreamIds
    const fakeId = this.storage?.dreamIdList
      ? this.storage?.dreamIdList[this.storage.dreamIdList.length - 1]
      : null;
    if (fakeId?.includes("FakeIdToIgnoreCache")) {
      this.storage.dreamIdList.pop();
    }
  }

  checkIfValueInState(storage) {
    if (!this.userSettings) {
      return false;
    }

    let localCheck = [];
    for (let value of Object.values(storage)) {
      if (
        value !== null &&
        JSON.stringify(this.userSettings) !== JSON.stringify(value)
      ) {
        localCheck.push(
          Object.keys(value).some(
            (key) =>
              (Array.isArray(value[key]) && value[key].length !== 0) ||
              (!Array.isArray(value[key]) &&
                value[key] !== "" &&
                typeof value[key] !== "boolean")
          )
        );
      }
    }

    return localCheck.some((key) => key === true);
  }

  makeStateExchange(type, message) {
    this.storage[type] = message;
    this.handleStateToFiltersConversion(this.storage[type]);
    if (this.isDreamIdFlow) {
      this.isFilterSelectionFlow = false;
      this.isUploadFileDisabled = false;
    } else {
      const { clientFilters, purchaseHistory } = this.storage;
      this.isFilterSelectionFlow = this.checkIfValueInState(this.storage);
      this.isUploadFileDisabled = this.checkIfValueInState({
        clientFilters,
        purchaseHistory
      });
    }
  }

  handleStateExchangeMessage(message) {
    let type = Object.getOwnPropertyNames(message);
    if (message.storeHierarchy) {
      this.makeStateExchange(type, message.storeHierarchy);
      this.initUserPerimeter();
    } else if (message.clientFilters) {
      this.makeStateExchange(type, message.clientFilters);
    } else if (message.purchaseHistory) {
      this.makeStateExchange(type, message.purchaseHistory);
    } else if (message.handleDreamIdListUpdate) {
      const newDreamIds = message.handleDreamIdListUpdate.dreamIds;
      this.storage.dreamIdList = [
        ...newDreamIds,
        "FakeIdToIgnoreCache" + Date.now()
      ]; // Ignore cache By Fake data
      this.storage.assignedCaByDreamId = message.handleDreamIdListUpdate.assignedCaByDreamId;
    } else if (message.handleNewClientList) {
      this.storage.clientList = null;
      this.storage.clientList = message.handleNewClientList;
      this.storage.dreamIdList = message.handleNewClientList.map(
        (c) => c.DREAMID__c
      );
      this.saveApiCache = false;
      this.initUserPerimeter();
    }
  }

  handleStateToFiltersConversion(state) {
    if (!this.stateAccumulator) {
      this.stateAccumulator = state;
      this.filters = this.stateAccumulator;
    } else if (this.stateAccumulator !== state) {
      this.stateAccumulator = { ...this.stateAccumulator, ...state };
      this.filters = this.stateAccumulator;
    }
  }

  handleDreamIdFlow(event) {
    this.isDreamIdFlow = event.detail.isdreamidflow;
    if (this.isDreamIdFlow) {
      this.handleResetOnDreamIdFlow();
    }
  }

  set filters(filtersSelection) {
    this.clientListQuery = { filters: [], size: 0, from: 0 };
    const isEqual = "=";
    const isIn = "isIn";
    const or = "or";
    for (const [key, value] of Object.entries(filtersSelection)) {
      if (
        (key === "management_zone_level" ||
          key === "management_zone_level_1" ||
          key === "management_zone_level_2" ||
          key === "management_zone_level_3") &&
        value !== ""
      ) {
        this.queryBase.left = key;
        this.queryBase.operator = isEqual;
        this.queryBase.right = value;
        this.clientListQuery.filters.push(this.queryBase);
        this.queryBase = {};
      } else if (key === "default_store" && value !== "") {
        this.queryBase.left = key;
        this.queryBase.operator = isEqual;
        this.queryBase.right = value;
        this.clientListQuery.filters.push(this.queryBase);
        this.queryBase = {};
      } else if (
        key === "prefered_ca" &&
        Array.isArray(value) &&
        value.length !== 0
      ) {
        this.queryBase.left = key;
        this.queryBase.operator = isIn;
        this.queryBase.right = [
          ...new Set(value.map((c) => c.employeeNumber || ""))
        ];
        this.clientListQuery.filters.push(this.queryBase);
        this.queryBase = {};
      } else if (
        key === "gender" &&
        Array.isArray(value) &&
        value.length !== 0
      ) {
        this.queryBase.left = key;
        this.queryBase.operator = isIn;
        this.queryBase.right = value;
        this.clientListQuery.filters.push(this.queryBase);
        this.queryBase = {};
      } else if (key === "segmentationValue" && value !== "") {
        if (value.length > 1) {
          value.forEach((val) => {
            const prevQuery = this.queryBase.left;
            this.queryBase.left = {
              left: val,
              operator: isEqual,
              right: true
            };
            this.queryBase.operator = or;
            this.queryBase.right = this.queryBase.right
              ? {
                  left: this.queryBase.right,
                  operator: or,
                  right: prevQuery
                }
              : prevQuery;
          });
        } else {
          this.queryBase.left = value[0];
          this.queryBase.operator = isEqual;
          this.queryBase.right = true;
        }

        if (this.queryBase.left != null) {
          this.clientListQuery.filters.push(this.queryBase);
        }
        this.queryBase = {};
      } else if (key === "contactableValue" && value !== "") {
        value.forEach((val) => {
          this.queryBase.left = val;
          this.queryBase.operator = isEqual;
          this.queryBase.right = true;
          this.clientListQuery.filters.push(this.queryBase);
          this.queryBase = {};
        });
      } else if (key === "purchaseValue" && value !== "") {
        this.queryBase.left = value;
        this.queryBase.operator = isEqual;
        this.queryBase.right = true;
        this.clientListQuery.filters.push(this.queryBase);
        this.queryBase = {};
      } else if (key === "productCategories" && value.length > 0) {
        const includeProductCategories = value
          .filter(({ exclude }) => !exclude.state)
          ?.map(({ value }) => value);
        const excludeProductCategories = value
          .filter(({ exclude }) => !!exclude.state)
          ?.map(({ value }) => value);

        if (includeProductCategories?.length > 0) {
          const query = {
            left: "product_categories",
            operator: isIn,
            right: [...includeProductCategories],
            invertFlag: false
          };
          this.clientListQuery.filters.push(query);
        }

        if (excludeProductCategories?.length > 0) {
          const query = {
            left: "product_categories",
            operator: isIn,
            right: [...excludeProductCategories],
            invertFlag: true
          };
          this.clientListQuery.filters.push(query);
        }
      }
    }
  }

  get filters() {
    return this.clientListQuery;
  }

  goBack(event) {
    this.isFirstStep = true;
    this.isActionSelectionStep = false;
    this.isReassignStep = false;
    this.isClientListCreatedStep = false;
    this.isClientAddedToAnEventStep = false;
    this.isClientPushedToCampaignStep = false;
    this.isEmptyClientListCreatedStep = false;
    this.isExclusiveAccessStep = false;
    this.isEmptyClientList = false;
    this.isAllClientsInMyPerimeter = false;
    this.isAddingClientsToEventFinished = false;
    this.isAddingClientsToEventFinishedWithTotalError = false;
    this.isPushingClientsToCampaignFinished = false;
    this.isPushingClientsToCampaignFinishedWithTotalError = false;

    if (event?.detail?.reset) {
      setTimeout(() => this.handleAllFiltersReset(), 200);
    } else {
      setTimeout(() => this.resetDefaultStore(), 200);
    }
  }

  goToNextStep() {
    this.isFirstStep = false;
    this.isActionSelectionStep = true;
    this.isReassignStep = false;
    this.isClientListCreatedStep = false;
    this.isClientAddedToAnEventStep = false;
    this.isClientPushedToCampaignStep = false;
    this.isEmptyClientListCreatedStep = false;
    this.isExclusiveAccessStep = false;
    return this.isActionSelectionStep;
  }

  goToReassign() {
    this.isFirstStep = false;
    this.isActionSelectionStep = false;
    this.isReassignStep = true;
    this.isClientListCreatedStep = false;
    this.isClientAddedToAnEventStep = false;
    this.isClientPushedToCampaignStep = false;
    this.isEmptyClientListCreatedStep = false;
    this.isExclusiveAccessStep = false;
  }

  goToCLSummary(event) {
    this.storage.clientListInfo = event.detail.clientListDetails;
    this.isFirstStep = false;
    this.isActionSelectionStep = false;
    this.isReassignStep = false;
    this.isClientListCreatedStep = true;
    this.isEmptyClientListCreatedStep = event.detail.empty;
    this.isExclusiveAccessStep = false;
    this.isClientListCreatedSuccessfully = false;
  }

  goToExclusiveSummary(event) {
    this.storage.clientListInfo = event.detail.clientListDetails;
    this.storage.clientListInfo.clientListOptions.numberOfClients =
      this.contactableClients.length;
    this.isFirstStep = false;
    this.isActionSelectionStep = false;
    this.isReassignStep = false;
    this.isClientListCreatedStep = false;
    this.isEmptyClientListCreatedStep = false;
    this.isExclusiveAccessStep = true;
  }

  goToEventSummary(event) {
    this.storage.eventInfo = event.detail.eventInfo;
    this.isClientAddedToAnEventStep = true;
    this.isClientPushedToCampaignStep = false;
    this.isFirstStep = false;
    this.isActionSelectionStep = false;
    this.isReassignStep = false;
    this.isClientListCreatedStep = false;
    this.isEmptyClientListCreatedStep = false;
    this.isExclusiveAccessStep = false;
    this.isClientListCreatedSuccessfully = false;
    this.isAddingClientsToEventFinished = false;
    this.isAddingClientsToEventFinishedWithTotalError = false;
  }

  goToCampaignSummery(event) {
    this.storage.campaignInfo = event.detail.campaignInfo;
    this.isClientPushedToCampaignStep = true;
    this.isClientAddedToAnEventStep = false;
    this.isFirstStep = false;
    this.isActionSelectionStep = false;
    this.isReassignStep = false;
    this.isClientListCreatedStep = false;
    this.isEmptyClientListCreatedStep = false;
    this.isExclusiveAccessStep = false;
    this.isClientListCreatedSuccessfully = false;
    this.isAddingClientsToEventFinished = false;
    this.isAddingClientsToEventFinishedWithTotalError = false;
  }
}