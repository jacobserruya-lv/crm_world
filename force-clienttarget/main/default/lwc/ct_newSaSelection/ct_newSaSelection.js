import { LightningElement, api, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import { refreshApex } from '@salesforce/apex';
import CL_STATE_EXCHANGE_CHANNEL from "@salesforce/messageChannel/clStateExchange__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createReassignCL from "@salesforce/apex/CT_CSVParseController.createReassignCL";
import getClientListJobDetails from "@salesforce/apex/CL_controller.getClientListJobDetails";
import getNumberofClientsForCAList from "@salesforce/apex/CL_controller.getNumberofClientsForCAList";
import deleteChildJob from "@salesforce/apex/CL_controller.deleteChildJob";
import Icon from "@salesforce/resourceUrl/ctCssLib";

const columns = [
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
  // { label: "Segmentation", fieldName: "segmentation" },
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
  {
    label: "New preferred CA",
    fieldName: "caToAssign",
    type: "text"
  },
  {
    type: 'action',
    typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] },
  }
];

export default class Ct_newSaSelection extends LightningElement {
  @api name;
  @api storeHierarchy;
  @api clientList;
  @api clientsAmount;
  @api isDreamIdFlow;
  @api isReassignStep;
  @api isUnlockStoreHierarchy;
  @api selectedRows = [];
  @api newCaIsAssigned = false;
  @api defaultStoreId;
  @api store = {
    clientList: []
  };
  clientTableData = [];
  stateSubscription = null;
  isRenderd = false;
  isClientAdvisorCheck = false;
  globalStateReceived = false;
  showDonePopup = false;
  isDone = false;
  clientTableInitialState = [];
  hideCheckboxFromTable = false;
  locationIconUrlPNG = `${Icon}/icons/location/location@3x.png`;
  homeIconUrlPNG = `${Icon}/icons/home/home@3x.png`;
  activeSections = ["newMainCA"];
  columns = columns;
  selectedClientAdvisorValue = "";
  selectedClientAdvisorName = "";
  url = window.location.hostname;
  error;
  @wire(MessageContext)
  messageContext;
  @wire(getNumberofClientsForCAList, {
    caIdsList: "$preferedCaIds"
  })
  numberOfClientsForCA;

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.dispatchEvent(new CustomEvent("newsaselectionmounted"));
    this.refreshTableData();
  }

  renderedCallback() {
    if (!this.isRenderd) {
      this.loadSpinner(false);
      this.isRenderd = true;
    }

    if (!this.isClientAdvisorCheck) {
      this.handleOneClientAdvisor();
    }
  }

  @api
  refreshTableData() {
    this.listData = this.getCopyData(this.clientList) ?? [];
    this.clientTableData = this.listData;
    this.store.clientList = this.clientTableData;
    this.selectedRows = [...new Set([...this.selectedRows])];
    this.updateDataTable(this.selectedRows);
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.stateSubscription);
    this.stateSubscription = null;
  }

  subscribeToMessageChannel() {
    this.stateSubscription = subscribe(
      this.messageContext,
      CL_STATE_EXCHANGE_CHANNEL,
      (message) => {
        if (message.handleNewClientList) {
          this.store.clientList = message.handleNewClientList;
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleStoreHierarchyReset() {
    this.hideCheckboxFromTable = false;
    this.globalStateReceived = false;
    this.isClientAdvisorCheck = false;
    this.selectedClientAdvisorValue = "";
    this.selectedClientAdvisorName = "";
    this.selectedRows = [];
    this.newCaIsAssigned = false;
    this.updateDataTable([]);
  }

  handleRowAction(event) {
    const row = event.detail.row;
    this.dispatchEvent(new CustomEvent("deleterow",{ detail: { row: row }}));
    this.selectedRows = [...this.selectedRows].filter(r => r !== row.id);
  }

  handleAllRowSelection() {
    this.loadSpinner(true);
    setTimeout(() => {
      this.dispatchEvent(new CustomEvent("allrowsselected"));
    }, 10);
  }

  handleDoneAssignment() {
    this.dispatchEvent(new CustomEvent("doneassignment"));
  }

  openDoneModel() {
    if (
      this.selectedClientAdvisorValue &&
      this.selectedRows.length > 0
    ) {
      this.showDonePopup = true;
    } else {
      this.handleDoneAssignment();
    }
  }

  closeDoneModal(event) {
    if (event?.target?.dataset?.save === "true" ) {
      this.isDone = true;
      this.getCreateReassignCL();
    } else {
      this.showDonePopup = false;
    }
  }

  loadSpinner(load, text) {
    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: load, text}, bubbles: true, composed: true}));
  }

  @api
  get selectedClientsAmount() {
    return this.selectedRows?.length;
  }

  set listData(value) {
    this.clientTableData = value;
  }

  get listData() {
    return this.clientList ? this.clientTableData : null;
  }

  get clientAdvisors() {
    return this.storeHierarchy?.prefered_ca?.map(ca => {
      return {
        ...ca,
        clients: this.clientsForCAList ? this.clientsForCAList[ca.options[0].value] ?? 0 : 0
      }
    }) ?? [];
  }

  get preferedCaIds() {
    const fakeIdToIgnoreCache = Date.now();
    const ids = this.storeHierarchy?.prefered_ca?.map(ca => ca.options[0].value);
    return [...ids, fakeIdToIgnoreCache];
  }

  get clientsForCAList() {
    return this.numberOfClientsForCA.data;
  }

  get disabledSaveButton() {
    return !this.newCaIsAssigned || this.selectedRows?.length === 0;
  }

  get disabledCancelButton() {
    return !this.newCaIsAssigned && this.selectedRows?.length === 0;
  }

  handleOneClientAdvisor() {
    if (this.clientAdvisors?.length === 1) {
      this.isClientAdvisorCheck = true;
      const event = {target: {value: this.clientAdvisors[0]?.options[0]?.value}}
      this.handleClientAdvisorSelection(event);
    } else {
      this.isClientAdvisorCheck = false;
    }
  }

  handleUserSettingsApplied(event) {
    this.dispatchEvent(
      new CustomEvent("usersettingsapplied", { detail: event.detail })
    );
  }

  handleStoreHierarchyMounted() {
    this.dispatchEvent(new CustomEvent("storehierarchymounted"));
  }

  handleClientAdvisorSelection(event) {
    this.newCaIsAssigned = true;
    this.hideCheckboxFromTable = false;
    this.selectedClientAdvisorValue = event.target.value;
    this.clientAdvisors.map((clientAdvisor) => {
      if (this.selectedClientAdvisorValue === clientAdvisor.options[0].value) {
        this.selectedClientAdvisorName = clientAdvisor.options[0].label;
      }
      return clientAdvisor;
    });
    this.handleSelectedClientRowData();
  }

  handleWarning(text, variant = "warning", title = "Warning!") {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: text,
        variant: variant
      })
    );
  }

  handleSelectedClientRowData(event) {
    const dataTable = this.template.querySelector("lightning-datatable");
    if (dataTable) {
      const selectedPageRows = dataTable.getSelectedRows();
      const clientsToReassign = [];
      selectedPageRows.map((row) => {
        clientsToReassign.push(row.id);
        if (this.selectedRows.indexOf(row.id) < 0) {
          this.selectedRows = [...this.selectedRows, row.id];
        }
      });
      const allPageIds = [...this.listData].map(c => c.id);
      const elementsToUnCheck = allPageIds.filter(id => clientsToReassign.indexOf(id) < 0);
      this.selectedRows = this.selectedRows.filter(r => !elementsToUnCheck.includes(r));
      this.updateDataTable(clientsToReassign);
    }
  }

  @api
  updateDataTable(clientIdArray) {
    this.listData = this.getCopyData(this.listData).map((client) => {
      const clientIndex = clientIdArray.indexOf(client.id);
      return {
        ...client,
        caToAssign: clientIndex > -1 ? this.selectedClientAdvisorName : ''
      }
    });
  }

  getCopyData(data) {
    return JSON.parse(JSON.stringify(data));
  }

  handleAssignmentCancellation() {
    this.listData = this.getCopyData(this.store.clientList).map((client) => {
      client.caToAssign = "";
      return client;
    });
    this.selectedClientAdvisorValue = "";
    this.selectedClientAdvisorName = "";
    this.selectedRows = [];
  }

  getCreateReassignCL() {
    this.selectedRows = [...new Set([...this.selectedRows])];
    this.loadSpinner(true, 'Loading results, please wait, This may take some time');

    createReassignCL({
      clientIdsList: this.selectedRows,
      caId: this.selectedClientAdvisorValue
    })
      .then((result) => {
        if (result && result !== 'null') {
          this.fetchJobData(result);
        } else {
          throw "Failed to Reattach clients";
        }
      })
      .catch((error) => {
        this.loadSpinner(false);
        this.error = error?.body?.message || error;
        this.handleWarning(
          "Something went wrong... " + this.error,
          "warning",
          "Sorry..."
        );
      });
  }

  fetchJobData(jobIdToFetch) {
    let jobProcess = setInterval(() => {
      getClientListJobDetails({
        jobId: jobIdToFetch
      })
      .then(data => {
        if (data?.Status == "Completed") {
          deleteChildJob({jobId: jobIdToFetch});
          this.dispatchEvent(new CustomEvent("reassignsuccessfully",{ 
            detail: { 
              reassignClientList: this.selectedRows,
              caName: this.selectedClientAdvisorName,
              caId: this.selectedClientAdvisorValue,
              url: `https://${this.url}/lightning/r/Account/${this.selectedClientAdvisorValue}/view`
            }
          }));
          clearInterval(jobProcess);
        } else if (data?.Status == "Failed") {
          throw data.ExtendedStatus;
        } else if (data?.Status == "Aborted") {
          throw "Job Aborted";
        }
      })
      .catch((error) => {
        this.loadSpinner(false);
        this.error = error?.body?.message || error || null;
        this.handleWarning(
          "Something went wrong... " + this.error,
          "warning",
          "Sorry..."
        );
        clearInterval(jobProcess);
      });
    }, 5000);
  }  
  
  @api
  updateDataAfterReassignFinish() {
    refreshApex(this.numberOfClientsForCA);
    this.handleStoreHierarchyReset();
    this.loadSpinner(false);
    this.handleWarning(
      "CA assigned successfully!",
      "success",
      "Success!"
    );

    if (this.isDone) {
      this.isDone = false;
      setTimeout(() => {
        this.handleDoneAssignment();
      }, 1000);
    }
  }

  handleSaveAssignment() {
    if (
      this.selectedClientAdvisorValue &&
      this.selectedRows.length > 0
    ) {
      this.getCreateReassignCL();
    } else {
      this.handleWarning(
        "Please assign CA to a client in order to save",
        "warning",
        "Note!"
      );
    }
  }

  handleSectionToggle() {}
}