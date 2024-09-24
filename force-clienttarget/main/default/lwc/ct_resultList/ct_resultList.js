import { api, LightningElement, wire } from "lwc";
import {
  MessageContext,
  publish
} from "lightning/messageService";
import CL_STATE_EXCHANGE_CHANNEL from "@salesforce/messageChannel/clStateExchange__c";
import getClientList from "@salesforce/apex/CL_controller.getClientList";
import CURRENT_USER_ID from "@salesforce/user/Id";
import CURRENT_USER_CURRENCY from "@salesforce/schema/User.Currency__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { regularColumns, campaignColumns, reattachColumns } from "./tableColumns";

const turnoverByCurrency = {
  'USD': 'Turnover12mrTaxInclUSD__pc',
  'EUR': 'Turnover12mrTaxInclEUR__pc',
  'CNY': 'Turnover12mrTaxInclCNY__pc',
  'JPY': 'Turnover12mrTaxInclJPY__pc'
};
const symbolByCurrency = {
  'USD': '$',
  'EUR': '€',
  'CNY': 'CNY¥',
  'JPY': 'JPY¥'
};

export default class Ct_resultList extends LightningElement {
  @api campaignId = '';
  @api customPageSize;
  @api enableInfiniteLoading;
  @api isExclusiveAccessStep;
  @api isReassignStep;
  @api isActionSelectionStep;
  @api isClientListCreatedStep;
  @api isClientAddedToAnEventStep;
  @api clientList;
  @api mainStorage;
  @api isDreamIdFlow;
  @api allStoresList;
  @api isUnlockStoreHierarchy;

  @api reloadClients(clients) {
    this.clientList = clients;
    this.listData = this.clientList ? [...this.clientList] : [];
    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: false}, bubbles: true, composed: true}));
  }

  paginationData = [];
  fullClients = [];
  ignoreCache = 'ignorecache' + Date.now();
  storeRetail;
  tableLoader = true;
  resultWasRefreshed = false;
  isRefreshedDueTheDeletion = false;

  @wire(getRecord, {
    recordId: CURRENT_USER_ID,
    fields: [
      CURRENT_USER_CURRENCY
    ]
  })
  currentUser;

  @wire(MessageContext)
  messageContext;

  @wire(getClientList, {
    dreamIds: "$paginationDreamIds",
    campaignId: "$campaignIdFetcher",
    ignoreCache: "$ignoreCache"
  })
  fullClientsList({data, error}) {
    if (data && !this.isRefreshedDueTheDeletion) {
      this.fullClients = data;
      const shouldMergeResult = !!this.enableInfiniteLoading && !this.searchLoading && !this.resultWasRefreshed;
      this.paginationData = shouldMergeResult ? 
        this.setOfObjects([...this.paginationData, ...this.initializeClients(data)]) :
        this.initializeClients(data);
      if (!this.storeRetail && this.isReassignStep) {
        this.storeRetail = this.getStoreRetail();
      }
      if (this.searchLoading) {
        this.page = 0;
        this.searchLoading = false;
      }
      this.resultWasRefreshed = false;
      this.tableLoader = false;
      this.refreshReassignTable();
    }
    this.isRefreshedDueTheDeletion = false;
  };

  url = window.location.hostname;
  inputSearch;
  isRenderd = false;
  searchTimeout = null;
  searchLoading = false;
  searchHistory = [];
  listData;
  reassignTableElement;
  dataForResultTable;
  page = 0;
  activeSections = ["RESULTS"];

  columns = regularColumns;
  selectionTableColumns = [];

  get pageSize() {
    return Number(this.customPageSize) || 20;
  }

  get storeHierarchy() {
    return this.mainStorage;
  }

  get startIndex() {
    return this.page * this.pageSize;
  }

  get endIndex() {
    return (this.page * this.pageSize) + this.pageSize;
  }

  get rowOffset() {
    return this.enableInfiniteLoading ? 0 : this.startIndex;
  }

  get paginationDreamIds() {
    return [...this.listData].slice(this.startIndex, this.endIndex).map(c => c.DREAMID__c);
  }

  get tableData() {
    return this.paginationData;
  }

  get allTableIds() { 
    return [...this.listData].map(c => c.Id);
  }

  get campaignIdFetcher() {
    return this.campaignId || this.ignoreCache;
  }

  initializeClients(clients) {
    return clients.map((client) => {
        const campaignMember = this.campaignId ? client.Campaign_Members__r?.[0] : null;
        const linkToCampaignAssignedCa =  campaignMember?.AssignedCA__c ? 
          `https://${this.url}/lightning/r/Account/${campaignMember.AssignedCA__c}/view` : null;

        return {
          id: client?.Id,
          name: client?.Name,
          linkToClientAccount: `https://${this.url}/lightning/r/Account/${client?.Id}/view`,
          segmentation: client?.Sub_Segment__c, //client?.Segmentation_To_Display__c,
          purchasePeriod: this.getTurnoverByCurrency(client),
          lastTransaction: client?.LastTrans__pc,
          dreamId: client?.DREAMID__c,
          preferredCa: this.campaignId ? campaignMember?.AssignedCA__r?.Name : client?.Owner?.Name,
          preferredCaId: this.campaignId ? campaignMember?.AssignedCA__c : client?.Owner?.Id,
          linkToCaAccount: this.campaignId ? linkToCampaignAssignedCa : `https://${this.url}/lightning/r/Account/${client?.Owner?.Id}/view`,
          attachedStore: client?.Store__pr?.Name || this.getStoreNameByRetailId(client?.Owner?.DefaultStore__c),
          country: client?.PrimaryCountry__pc,
          storeId: client?.Store__pr?.RetailStoreId__c || client?.Owner?.DefaultStore__c,
          caToAssign: ""
        }
      }
    );
  }

  getTurnoverByCurrency(client = {}) {
    const currentUserCurrency = getFieldValue(this.currentUser.data, CURRENT_USER_CURRENCY);
    const clientCurrency = client?.Owner?.Currency__c || 'EUR';
    const clientTurnoverField = turnoverByCurrency[clientCurrency];
    const clientTurnover = client[clientTurnoverField] || 0;
    const turnoverSymbol = symbolByCurrency[currentUserCurrency] || '€';
    return `${clientTurnover} ${turnoverSymbol}`;
  }

  get isLastPage() {
    return this.startIndex >= this.listData.length - this.pageSize;
  }

  get isFirstPage() {
    return this.page === 0;
  }

  get fullClientsAmount() {
    return this.listData.length;
  }

  get pageDescription() {
    return `${this.startIndex} - ${this.startIndex + this.pageSize > this.listData.length ? this.listData.length : this.startIndex + this.pageSize} of ${this.listData.length}`;
  }

  nextPage() {
    this.page++;
    this.tableLoader = true;
  }

  prevPage() {
    this.page--;
    this.tableLoader = true;
  }

  refreshReassignTable() {
    if (this.reassignTableElement) {
      this.reassignTableElement.clientList = this.tableData;
      this.reassignTableElement.refreshTableData();
      this.reassignTableElement.closeTableLoader();
    }   
  }

  onLoadMore(event) {
    if (this.searchLoader) {
      return;
    }

    if (this.listData.length > this.endIndex) {
      this.nextPage();
    } else if (this.reassignTableElement) {
      this.reassignTableElement.closeTableLoader();
    }
  }

  connectedCallback() {
    this.listData = this.clientList ? [...this.clientList] : [];
    this.selectionTableColumns = this.campaignId ? campaignColumns : reattachColumns;
  }

  renderedCallback() {
    if (!this.isReassignStep) {
      if (!this.isRenderd) {
        this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: false}, bubbles: true, composed: true})); 
        this.isRenderd = true;
      }
    } else if (!this.reassignTableElement) {
      this.reassignTableElement = this.template.querySelector('c-ct_new-sa-selection');
    }
  }

  handleAllRowsSelected() {
    const listToSelect = !!this.inputSearch ? [...this.listData] : [...this.clientList];
    const isAllRowsSelected = !(this.reassignTableElement.selectedClientsAmount < listToSelect.length);

    if (isAllRowsSelected) {
      this.reassignTableElement.selectedRows = [];
      this.reassignTableElement.updateDataTable([]);
    } else {
      const rows = [];
      listToSelect.forEach((client) => {
        rows.push(client.Id);
      });
      this.reassignTableElement.selectedRows = rows;
      this.reassignTableElement.updateDataTable(rows);
    }

    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: false}, bubbles: true, composed: true}));
  }

  resetInfiniteLoading() {
    this.resultWasRefreshed = true;
    this.page = 0;
  }

  handleReassignSuccessfully(event) {
    this.ignoreCache = 'ignorecache' + Date.now();
    this.resetInfiniteLoading();
    if (this.inputSearch) {
      this.handleResultSearch();
    }
    this.reassignTableElement.updateDataAfterReassignFinish();
  }

  getCopyData(data) {
    return JSON.parse(JSON.stringify(data));
  } 

  getStoreNameByRetailId(id) {
    return this.allStoresList?.data ? this.allStoresList.data[id] : '';
  }

  handleUserSettingsApplied(event) {
    this.dispatchEvent(
      new CustomEvent("usersettingsapplied", { detail: event.detail, bubbles: true })
    );
  }

  handleStoreHierarchyMounted() {
    this.dispatchEvent(new CustomEvent("storehierarchymounted", { bubbles: true }));
  }

  handleNewSaSelectionMounted() {
    this.dispatchEvent(new CustomEvent("newsaselectionmounted", { bubbles: true }));
  }

  handleDoneAssignment() {
    this.dispatchEvent(new CustomEvent("goback", { detail: { reset: true } }));
  }

  handleResultSearch(event = null) {
    clearTimeout(this.searchTimeout);

    if (!this.clientList) {
      return;
    }

    this.searchLoading = true;
    this.tableLoader = true;
    let queryTerm = event?.target?.value?.toUpperCase() ?? this.inputSearch;
    let queryTermLength = queryTerm?.length;
    let arrayToSearch = [];

    if (queryTermLength !== 0) {
      if (this.inputSearch?.length > queryTermLength) {
        arrayToSearch = this.searchHistory.pop() ?? [];
      } else {
        arrayToSearch = queryTermLength === 1 ? [...this.clientList] : [...this.listData];
        this.searchHistory.push(arrayToSearch);
      }
    }

    this.searchTimeout = setTimeout(() => {
      if (queryTermLength !== 0) {
        this.listData = arrayToSearch?.filter((client) => {
          if (
            client.Name?.toUpperCase().includes(queryTerm) ||
            client.DREAMID__c?.toUpperCase().includes(queryTerm)
          ) {
            return client;
          }
        });
      } else {
        this.listData = !!this.clientList ? [...this.clientList] : [];
        this.searchHistory = [];
      }
      this.inputSearch = queryTerm;
      if (this.enableInfiniteLoading) {
        this.resetInfiniteLoading();
      }
    }, 1000);
  }

  handleRowAction(event) {
    const row = event.detail.row;
    this.deleteRow(row);
  }

  deleteRow(row) {
    const { id } = row;

    if (this.enableInfiniteLoading) {
      this.isRefreshedDueTheDeletion = true;
      this.paginationData = [...this.paginationData].filter(c => c.id !== id);
      this.refreshReassignTable();
    }

    const isNotClientId = (c) => c.Id !== id;
    this.listData = [...this.listData].filter(isNotClientId);
    this.clientList = [...this.clientList].filter(isNotClientId);
    const payload = { handleNewClientList: this.clientList };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  getStoreRetail() {
    const clientWithStore = this.fullClients?.find(c => !!c?.Store__pr?.Name) ?? 
                            this.fullClients?.find(c => !!c?.Owner?.DefaultStore__c);
    const storeLabel = clientWithStore?.Store__pr?.Name ?? this.allStoresList?.data[clientWithStore?.Owner?.DefaultStore__c];
    const storeValue = clientWithStore?.Store__pr?.RetailStoreId__c ?? clientWithStore?.Owner?.DefaultStore__c;
    return { value: storeValue, label: storeLabel };
  }

  get showDataTable() {
    return (
      this.isClientListCreatedStep ||
      this.isExclusiveAccessStep ||
      this.isActionSelectionStep ||
      this.isClientAddedToAnEventStep
    );
  }

  get searchLoader() {
    return this.searchLoading || this.tableLoader;
  }

  get enableNewSelection() {
    return this.campaignId || (this.isReassignStep && !!this.storeRetail);
  }
  
  setOfObjects(array, identifier = "id") {
    const alreadyExist = {};
    return array.filter((obj) => !alreadyExist[obj[identifier]] && (alreadyExist[obj[identifier]] = true));
  }

  handleSectionToggle() {}
}