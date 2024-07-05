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
    ignoreCache: "$ignoreCache"
  })
  fullClientsList({data, error}) {
    if (data) {
      this.fullClients = data;
      this.paginationData = this.initializeClients(data);
      if (!this.storeRetail && this.isReassignStep) {
        this.storeRetail = this.getStoreRetail();
      }
      if (this.searchLoading) {
        this.page = 0;
        this.searchLoading = false;
      }
      this.tableLoader = false;
      this.refreshReassignTable();
    }
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
  pageSize = 20;
  activeSections = ["RESULTS"];
  columns = [
    {
      label: "Name",
      fieldName: "linkToClientAccount",
      type: "url",
      typeAttributes: {
        label: { fieldName: "name" },
        tooltip: "Name",
        target: "_blank"
      }
    },
    //{ label: "Segmentation", fieldName: "segmentation" },
    { label: "12MR", fieldName: "purchasePeriod" },
    { label: "Last Transaction", fieldName: "lastTransaction", type: "date" },
    {
      label: "DreamID",
      fieldName: "dreamId",
      cellAttributes: { alignment: "left" }
    },
    {
      label: "Preferred CA",
      fieldName: "linkToCaAccount",
      type: "url",
      typeAttributes: {
        label: { fieldName: "preferredCa" },
        tooltip: "Preferred CA",
        target: "_blank"
      }
    },
    { label: "Attached Store", fieldName: "attachedStore" },
    { label: "Country/Region", fieldName: "country" },
    {
      type: 'action',
      typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] },
    },
  ];

  get storeHierarchy() {
    return this.mainStorage;
  }

  get startIndex() {
    return this.page * this.pageSize;
  }

  get endIndex() {
    return (this.page * this.pageSize) + this.pageSize;
  }

  get paginationDreamIds() {
    return [...this.listData].slice(this.startIndex, this.endIndex).map(c => c.DREAMID__c);
  }

  initializeClients(clients) {
    return clients.map((client) => 
      ({
        id: client?.Id,
        name: client?.Name,
        linkToClientAccount: `https://${this.url}/lightning/r/Account/${client?.Id}/view`,
        segmentation: client?.Segmentation_To_Display__c,
        purchasePeriod: this.getTurnoverByCurrency(client),
        lastTransaction: client?.LastTrans__pc,
        dreamId: client?.DREAMID__c,
        preferredCa: client?.Owner?.Name,
        preferredCaId: client?.Owner?.Id,
        linkToCaAccount: `https://${this.url}/lightning/r/Account/${client?.Owner?.Id}/view`,
        attachedStore: client?.Store__pr?.Name || this.getStoreNameByRetailId(client?.Owner?.DefaultStore__c),
        country: client?.PrimaryCountry__pc,
        storeId: client?.Store__pr?.RetailStoreId__c || client?.Owner?.DefaultStore__c,
        caToAssign: ""
      })
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
      this.reassignTableElement.clientList = this.paginationData;
      this.reassignTableElement.refreshTableData();
    }   
  }

  connectedCallback() {
    this.listData = this.clientList ? [...this.clientList] : [];
  }

  renderedCallback() {
    if (!this.isReassignStep) {
      if (!this.isRenderd) {
        this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: false}, bubbles: true, composed: true})); 
        this.isRenderd = true;
      }
    } else {
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

  handleReassignSuccessfully(event) {
    this.ignoreCache = 'ignorecache' + Date.now();
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
    this.dispatchEvent(new CustomEvent("doneassignment"));
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
    }, 1000);
  }

  handleRowAction(event) {
    const row = event.detail.row;
    this.deleteRow(row);
  }

  deleteRow(row) {
    const { id } = row;
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
    return {value: storeValue, label: storeLabel};
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
    return this.isReassignStep && !!this.storeRetail;
  }
  
  handleSectionToggle() {}
}