import { track, api, LightningElement } from "lwc";

import createClientListWithMembers from "@salesforce/apex/CT_CSVParseController.createCLwithMembers";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

export default class ct_createClientListModal extends NavigationMixin(
  LightningElement
) {
  @api storage;
  @api isAllClientsInMyPerimeter;
  @api isAllClientsWithStore;
  @api isTriggeredFromFirstPage;
  @api userPerimeter;
  expirationDate = null;
  clientListName = null;
  description = null;
  createEmptyChecklist;
  otherParams;

  minExpirationDate = new Date().toISOString();
  maxExpirationDate = new Date(new Date().setFullYear(new Date().getFullYear() + 3)).toISOString();

  get clientListOptions() {
    return {
      expirationDate: this.expirationDate,
      clientListName: this.clientListName,
      clientListDescription: this.description,
      dreamIdList: null, //this.storage.dreamIdList,
      numberOfClients: !this.isClientListEmpty ?
                       this.storage?.clientList?.length : null,
      otherParams: this.otherParams,
      isEmptyClientList: this.createEmptyChecklist
    };
  }

  get isDisabled() {
    return !(this.expirationDate && this.clientListName && this.isValidExpirationDate) || (this.isClientListEmpty && !this.createEmptyChecklist);
  }

  get isClientListEmpty() {
    return this.isTriggeredFromFirstPage || (!this.storage.clientList || this.storage.clientList.length < 1) || !this.isAllClientsInMyPerimeter || !this.isAllClientsWithStore;
  }

  get isValidExpirationDate() {
    if (!this.expirationDate) {
      return false;
    }
    const expirationDateTS = new Date(this.expirationDate).getTime();
    return expirationDateTS > new Date(this.minExpirationDate).getTime() &&
           expirationDateTS < new Date(this.maxExpirationDate).getTime();
  }

  connectedCallback() {
    this.createEmptyChecklist = this.isClientListEmpty;
    this.loadSpinner(false);
  }

  loadSpinner(load, text) {
    this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: load, text}, bubbles: true, composed: true})); 
  }

  @api
  closeModal() {
    this.expirationDate = null;
    this.clientListName = null;
    this.description = null;
    this.createEmptyChecklist = null;
    this.dispatchEvent(new CustomEvent("destroyclientlistmodal"));
  }

  handleExpirationDate(event) {
    this.expirationDate = event.target.value;
  }

  handleClientListName(event) {
    this.clientListName = event.target.value;
  }

  handleDescription(event) {
    this.description = event.target.value;
  }

  handleCreateEmptyChecklist(event) {
    this.createEmptyChecklist = event.detail.checked;
  }

  transformDoubleToSingleQuoted(array) {
    const toJSON = JSON.stringify(array);
    const singleQuotedJSON = toJSON.replace(/"/g, "'");
    return singleQuotedJSON;
  }

  getStoreHierarchyFilter() {
    const storeHierarchy = this.storage.storeHierarchy || {};
    let storeHierarchyFilter = { type: '', zone: '' };

    const { 
      management_zone_level,
      management_zone_level_1,
      management_zone_level_2,
      management_zone_level_3, 
      default_store 
    } = storeHierarchy;

    if (default_store) {
      storeHierarchyFilter = { type: 'store', zone: default_store };
    } else if(management_zone_level_3) {
      storeHierarchyFilter = { type: 'level3', zone: management_zone_level_3 };
    } else if(management_zone_level_2) {
      storeHierarchyFilter = { type: 'level2', zone: management_zone_level_2 };
    } else if(management_zone_level_1) {
      storeHierarchyFilter = { type: 'level1', zone: management_zone_level_1 };
    } else if(management_zone_level) {
      storeHierarchyFilter = { type: 'level', zone: management_zone_level };
    }
    
    return storeHierarchyFilter;
  }

  handleCreateClientList() {
    this.loadSpinner(true, 'Creating client list, please wait, This may take some time');
    
    this.otherParams = {
      type: "regular",
      showInIcon: "true"
    };

    const dreamIdList = !this.isClientListEmpty && Array.isArray(this.storage.dreamIdList) ? [...this.storage.dreamIdList] : [];
    const caIdsListFilter = this.createEmptyChecklist && Array.isArray(this.storage.storeHierarchy?.prefered_ca) ? [...this.storage?.storeHierarchy?.prefered_ca].map(c => c.options && c.options[0].value) : [];
    const storeHierarchyFilter = this.getStoreHierarchyFilter();

    if (this.createEmptyChecklist) {
      this.otherParams = {
        ...this.otherParams,
        zone: storeHierarchyFilter.zone,
        zoneType: storeHierarchyFilter.type,
        createEmpty: "true"
      }
    }

    createClientListWithMembers({
      name: this.clientListName,
      expirationDate: this.expirationDate,
      description: this.description,
      dreamIdsList: dreamIdList,
      caListFilter: caIdsListFilter,
      otherParams: JSON.stringify(this.otherParams)
    })
      .then((jobId) => {
        if (jobId && jobId !== "null") {
          const selectedEvent = new CustomEvent("createclientlist", {
            detail: {
              empty: dreamIdList.length === 0,
              clientListDetails: {
                clientListOptions: this.clientListOptions,
                clientListId: jobId
              }
            }
          });
          this.dispatchEvent(selectedEvent);
          this.loadSpinner(false);
        } else {
          throw 'JobId was not found.';
        }
      })
      .then(() => {
        this.toastMessage("Success!", 'Creating a client list has started successfully!', "success");
        this.closeModal();
      })
      .catch((error) => {
        this.loadSpinner(false);
        this.errorMsg = error?.body?.message || error;
        this.toastMessage("error!", 'Something went wrong: ' + this.errorMsg, 'error');
      });
  }

  toastMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
}