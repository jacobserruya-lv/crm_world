import { LightningElement, track, wire, api } from "lwc";
import {
  subscribe,
  publish,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CURRENT_USER_MZL from "@salesforce/schema/User.MANAGEMENT_ZONE_LEVEL__c";
import CURRENT_USER_MZSL1 from "@salesforce/schema/User.MGMT_ZONE_SUB_LEVEL1__c";
import CURRENT_USER_MZSL2 from "@salesforce/schema/User.MGMT_ZONE_SUB_LEVEL2__c";
import CURRENT_USER_MZSL3 from "@salesforce/schema/User.MGMT_ZONE_SUB_LEVEL3__c";
import CURRENT_USER_STORE from "@salesforce/schema/User.TECH_DefaultStoreName__c";
import CURRENT_USER_ID from "@salesforce/user/Id";
import CL_STATE_EXCHANGE_CHANNEL from "@salesforce/messageChannel/clStateExchange__c";
import CL_STATE_RESET_CHANNEL from "@salesforce/messageChannel/clStateReset__c";
import getManagementZoneLevel from "@salesforce/apex/CL_controller.getManagementZoneLevel";
import getManagementZoneSubLevel1 from "@salesforce/apex/CL_controller.getManagementZoneSubLevel1";
import getManagementZoneSubLevel2 from "@salesforce/apex/CL_controller.getManagementZoneSubLevel2";
import getManagementZoneSubLevel3 from "@salesforce/apex/CL_controller.getManagementZoneSubLevel3";
import getDefaultStore from "@salesforce/apex/CL_controller.getDefaultStore";
import getAssignedCA from "@salesforce/apex/CL_controller.getAssignedCA";
import getCurrentUserSettings from "@salesforce/apex/CL_controller.getCurrentUserSettings";
import Icon from "@salesforce/resourceUrl/ctCssLib";

const technicalUsers = [
  // 'DEF COUNTRY NORTH ASIA Technical User',
  // 'DEF COUNTRY KOREA Technical User',
  // 'DEF COUNTRY ISRAEL Technical User',
  // 'DEF COUNTRY CHINA Technical User',
  'World Wide Technical User'
];

export default class Ct_searchFiltersStoreHierarchy extends LightningElement {
  @api mainStorage;
  @api userSettings = {};
  @api defaultStoreId;
  @api isReassignStep;
  @api isUnlockStoreHierarchy;
  @track storage = {
    userSettingsApplied: false,
    userSelectionApplied: false,
    management_zone_level: "",
    management_zone_level_1: "",
    management_zone_level_2: "",
    management_zone_level_3: "",
    default_store: "",
    prefered_ca: []
  };
  resetSubscription = null;
  stateSubscription = null;
  handleFiltersReset;
  locationIconUrlPNG = `${Icon}/icons/location/location@3x.png`;
  homeIconUrlPNG = `${Icon}/icons/home/home@3x.png`;
  isEmptyClientList;
  error;
  isMzlDisabled = false;
  isMzl1Disabled = true;
  isMzl2Disabled = true;
  isMzl3Disabled = true;
  isDefaultStoreDisabled = true;
  isPreferedCaDisabled = true;
  showCaList = false;
  userSettingsApplied = false;
  userSelectionApplied = false;
  isStoreHierarchySaved = false;
  currentUserMzlSettings;
  currentUserMzl1Settings;
  currentUserMzl2Settings;
  currentUserMzl3Settings;
  currentUserStoreSettings;
  managementZoneLevel = [];
  selectedManagementZoneLevel;
  selectedManagementZoneSubLevel1;
  selectedManagementZoneSubLevel2;
  selectedManagementZoneSubLevel3;
  selectedDefaultStore;
  selectedCaList = [];
  selectedZone;
  countriesLevel;
  @wire(getRecord, {
    recordId: CURRENT_USER_ID,
    fields: [
      CURRENT_USER_MZL,
      CURRENT_USER_MZSL1,
      CURRENT_USER_MZSL2,
      CURRENT_USER_MZSL3,
      CURRENT_USER_STORE
    ]
  })
  getUserManagementZonesSettings({ data, error }) {
    if (data) {
      this.currentUserMzlSettings = getFieldValue(data, CURRENT_USER_MZL);
      this.currentUserMzl1Settings = getFieldValue(data, CURRENT_USER_MZSL1);
      this.currentUserMzl2Settings = getFieldValue(data, CURRENT_USER_MZSL2);
      this.currentUserMzl3Settings = getFieldValue(data, CURRENT_USER_MZSL3);
      this.currentUserStoreSettings = getFieldValue(data, CURRENT_USER_STORE);
      
      this.onUserSettings(
        this.currentUserMzlSettings,
        this.currentUserMzl1Settings,
        this.currentUserMzl2Settings,
        this.currentUserMzl3Settings,
        this.currentUserStoreSettings,
        this.storage.userSelectionApplied,
        this.mainStorage,
        false
      );
    } else if (error) {
      this.error = error;
    }
  }
  @wire(getManagementZoneSubLevel1, {
    selectedManagementZoneLevel: "$selectedManagementZoneLevel"
  })
  managementZoneSubLevel1Value;
  @wire(getManagementZoneSubLevel2, {
    selectedManagementZoneSubLevel1: "$selectedManagementZoneSubLevel1"
  })
  managementZoneSubLevel2Value;
  @wire(getManagementZoneSubLevel3, {
    selectedManagementZoneSubLevel2: "$selectedManagementZoneSubLevel2"
  })
  managementZoneSubLevel3Value;
  @wire(getDefaultStore, {
    selectedManagementZoneSubLevel3: "$selectedManagementZoneSubLevel3"
  })
  defaultStoreValue;
  @wire(getAssignedCA, {
    selectedDefaultStore: "$selectedDefaultStore",
    technicalUsers: "$technicalUsers"
  })
  assignedCaValue;
  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    const initCallBack = this.isReassignStep ? getCurrentUserSettings : () => Promise.resolve(null);
    initCallBack()
    .then(user => {
      this.currentUserMzlSettings = this.currentUserMzlSettings || user?.MANAGEMENT_ZONE_LEVEL__c;
      this.currentUserMzl1Settings = this.currentUserMzl1Settings || user?.MGMT_ZONE_SUB_LEVEL1__c;
      this.currentUserMzl2Settings = this.currentUserMzl2Settings || user?.MGMT_ZONE_SUB_LEVEL2__c;
      this.currentUserMzl3Settings = this.currentUserMzl3Settings || user?.MGMT_ZONE_SUB_LEVEL3__c;
      this.currentUserStoreSettings = this.currentUserStoreSettings || user?.TECH_DefaultStoreName__c;
    })
    .finally(() => {
      this.managementZoneLevelData();
      this.subscribeToMessageChannel();
      this.dispatchEvent(new CustomEvent("storehierarchymounted"));
  
      if (this.defaultStoreId?.value && !this.isStoreHierarchySaved) {
        this.dispatchEvent(new CustomEvent("savedolddefaultstore", { 
          detail: { storeHierarchy: this.storage },
          bubbles: true,
          composed: true
        }));
        if (!this.isUnlockStoreHierarchy) {
          this.defaultStoreId = null;
          //this.handleDefaultStoreChange(this.defaultStoreId.value);
        }
        this.isStoreHierarchySaved = true;
      }
    });
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
        if (message.storeHierarchy) {
          this.handleStateExchangeMessage(message);
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleResetMessage(message) {
    if (message.handleFiltersReset === "storehierarchy") {
      this.storage = {
        userSettingsApplied: this.userSettingsApplied,
        userSelectionApplied: false,
        management_zone_level: "",
        management_zone_level_1: "",
        management_zone_level_2: "",
        management_zone_level_3: "",
        default_store: (!this.isUnlockStoreHierarchy && this.isReassignStep && this.defaultStoreId?.value) ?? '',
        prefered_ca: []
      };
      this.selectedManagementZoneLevel = undefined;
      this.selectedManagementZoneSubLevel1 = undefined;
      this.selectedManagementZoneSubLevel2 = undefined;
      this.selectedManagementZoneSubLevel3 = undefined;
      this.selectedDefaultStore = !this.isUnlockStoreHierarchy && this.defaultStoreId?.value;
      this.isMzlDisabled = false;
      this.isMzl1Disabled = true;
      this.isMzl2Disabled = true;
      this.isMzl3Disabled = true;
      this.isDefaultStoreDisabled = true;
      this.isPreferedCaDisabled = !(!this.isUnlockStoreHierarchy && this.defaultStoreId);
      this.showCaList = false;
      this.userSelectionApplied = false;
      this.userSettingsApplied = this.storage.userSettingsApplied;

      this.handleEmptyClientListChange(false);
      if (this.userSettingsApplied) {
        this.onUserSettings(
          this.currentUserMzlSettings,
          this.currentUserMzl1Settings,
          this.currentUserMzl2Settings,
          this.currentUserMzl3Settings,
          (!this.isUnlockStoreHierarchy && this.defaultStoreId?.value) ?? this.currentUserStoreSettings,
          this.storage.userSelectionApplied,
          this.mainStorage,
          true
        );
      }
      const payload = { storeHierarchy: this.storage };
      publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
      this.dispatchEvent(new CustomEvent("storehierarchyreset"));
    }
  }

  handlePartialReset(level) {
    this.showCaList = false;
    this.template.querySelector('c-ct_search-filters-ca-multi-select')?.handleResetFromParent();
    this.selectedCaList = [];
    this.storage.prefered_ca = this.selectedCaList;
    
    if (level < 4) {
      this.selectedDefaultStore = undefined;
      this.storage.default_store = this.selectedDefaultStore;
      this.isPreferedCaDisabled = true;
    }
    if (level < 3) {
      this.selectedManagementZoneSubLevel3 = undefined;
      this.storage.management_zone_level_3 = this.selectedManagementZoneSubLevel3;
      this.isDefaultStoreDisabled = true;
    }
    if (level < 2) {
      this.selectedManagementZoneSubLevel2 = undefined;
      this.storage.management_zone_level_2 = this.selectedManagementZoneSubLevel2;
      this.isMzl3Disabled = true;
    }
    if (level < 1) {
      this.selectedManagementZoneSubLevel1 = undefined;
      this.storage.management_zone_level_1 = this.selectedManagementZoneSubLevel1;
      this.isMzl2Disabled = true;
    }
  }

  handleStateExchangeMessage(state) {
    if (
      state.storeHierarchy &&
      JSON.stringify(state.storeHierarchy) !== JSON.stringify(this.storage)
    ) {
      if (state.storeHierarchy.management_zone_level) {
        this.handleManagementZoneLevelChange(
          state.storeHierarchy.management_zone_level
        );
      }
      if (state.storeHierarchy.management_zone_level_1) {
        this.handleManagementZoneSubLevel1Change(
          state.storeHierarchy.management_zone_level_1
        );
      }
      if (state.storeHierarchy.management_zone_level_2) {
        this.handleManagementZoneSubLevel2Change(
          state.storeHierarchy.management_zone_level_2
        );
      }
      if (state.storeHierarchy.management_zone_level_3) {
        this.handleManagementZoneSubLevel3Change(
          state.storeHierarchy.management_zone_level_3
        );
      }
      if (state.storeHierarchy.default_store) {
        this.handleDefaultStoreChange(state.storeHierarchy.default_store);
      }
      if (state.storeHierarchy.prefered_ca) {
        this.handleCustomerAdvisorsUpdate(state.storeHierarchy.prefered_ca);
      }
    }
  }

  onUserSettings(mzl, mzl1, mzl2, mzl3, currentStore, userSelection, mainStorage, resetCall) {
    if ((!userSelection && !mainStorage) || resetCall) {
      this.userSettingsApplied = true;
      this.storage.userSettingsApplied = this.userSettingsApplied;
      if (mzl) {
        this.handleManagementZoneLevelChange(mzl, true);
      }
      if (mzl1) {
        this.handleManagementZoneSubLevel1Change(mzl1, true);
      }
      if (mzl2) {
        this.handleManagementZoneSubLevel2Change(mzl2, true);
      }
      if (mzl3) {
        this.handleManagementZoneSubLevel3Change(mzl3, true);
      }
      if (currentStore) {
        this.handleDefaultStoreChange(currentStore, true);
      }
      this.userSettings = JSON.parse(JSON.stringify(this.storage));
      this.dispatchEvent(
        new CustomEvent("usersettingsapplied", { detail: this.userSettings })
      );
    } else {
      this.userSettingsApplied = true;
      this.storage.userSettingsApplied = this.userSettingsApplied;
      this.userSettings = this.userSettings ?? JSON.parse(JSON.stringify(this.mainStorage));
      this.dispatchEvent(
        new CustomEvent("usersettingsapplied", { detail: this.userSettings })
      );
    }
  }

  managementZoneLevelData() {
    getManagementZoneLevel()
      .then((result) => {
        result.map((zone) => {
          this.managementZoneLevel = [
            ...this.managementZoneLevel,
            {
              label: zone.MANAGEMENT_ZONE_LEVEL_TECH__c,
              value: zone.MANAGEMENT_ZONE_LEVEL__c
            }
          ];
          return zone;
        });
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.managementZoneLevel = [];
      });
    return this.managementZoneLevel;
  }

  get displayMzl() {
    return this.storage.userSettingsApplied && this.selectedManagementZoneLevel
      ? "display-none"
      : "filter-mzl";
  }

  async handleManagementZoneLevelChange(param, isUserSettings) {
    this.selectedManagementZoneLevel = param.target
      ? param.target.value
      : param;
    this.storage.management_zone_level = this.selectedManagementZoneLevel;
    
    if (this.isReassignStep && (!this.currentUserMzl2Settings || this.isUnlockStoreHierarchy)) {
      // const shouldUseLevelOne = this.currentUserMzl1Settings && !this.isUnlockStoreHierarchy;
      // this.countriesLevel = shouldUseLevelOne  ? 'level1' : 'zone';
      // this.selectedZone = shouldUseLevelOne ? this.currentUserMzl1Settings : this.selectedManagementZoneLevel;
      // this.selectedManagementZoneSubLevel2 = 'ignoreCache' + Date.now().toString();
      // this.managementZoneSubLevel3Value.data = await getManagementZoneSubLevel3({
      //   selectedZone: this.selectedZone,
      //   selectedManagementZoneSubLevel2: this.selectedManagementZoneSubLevel2,
      //   level: this.countriesLevel
      // });
    } else {
      this.countriesLevel = 'ignoreCache' + Date.now().toString();
      this.selectedZone = 'ignoreCache' + Date.now().toString();
    }
    
    this.isMzlDisabled = !!(isUserSettings || this.userSettings?.management_zone_level || this.currentUserMzlSettings || this.isMzlDisabled);
    this.isMzl1Disabled = false;
    if (this.userSettingsApplied !== true) {
      this.userSelectionApplied = true;
      this.storage.userSelectionApplied = this.userSelectionApplied;
    }
    if (param.target) {
      this.handlePartialReset(0);
    }
    const payload = { storeHierarchy: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  get managementZoneSubLevel1() {
    let managementZoneSubLevel1Data = [];
    if (this.managementZoneSubLevel1Value.data) {
      this.managementZoneSubLevel1Value.data.map((zone) => {
        managementZoneSubLevel1Data = [
          ...managementZoneSubLevel1Data,
          {
            label: zone.MGMT_ZONE_SUB_LEVEL1_TECH__c,
            value: zone.MGMT_ZONE_SUB_LEVEL1__c
          }
        ];
        return zone;
      });
    }
    this.error = this.managementZoneSubLevel1Value.error;
    return managementZoneSubLevel1Data;
  }

  handleManagementZoneSubLevel1Change(param, isUserSettings) {
    this.selectedManagementZoneSubLevel1 = param.target
      ? param.target.value
      : param;
    this.storage.management_zone_level_1 = this.selectedManagementZoneSubLevel1;
    this.isMzl1Disabled = !!(!this.isUnlockStoreHierarchy && (isUserSettings || this.userSettings?.management_zone_level_1 || this.currentUserMzl1Settings || this.isMzl1Disabled));
    this.isMzl2Disabled = false;
    if (this.userSettingsApplied !== true) {
      this.userSelectionApplied = true;
      this.storage.userSelectionApplied = this.userSelectionApplied;
    }
    if (param.target) {
      this.handlePartialReset(1);
    }
    const payload = { storeHierarchy: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  get countryDisabled() {
    return !this.selectedManagementZoneLevel || (this.currentUserMzl3Settings && !this.isUnlockStoreHierarchy);
  }

  get storeDisabled() {
    return !this.selectedManagementZoneSubLevel3;
  }

  get preferredCaDisabled() {
    return !this.selectedDefaultStore;
  }

  get caIdsList() {
    return this.assignedCaValue?.data?.map(c => c.Id);
  }

  get displayMzl1() {
    return this.storage.userSettingsApplied &&
      this.selectedManagementZoneSubLevel1
      ? "display-none"
      : "filter-mzl";
  }

  get managementZoneSubLevel2() {
    let managementZoneSubLevel2Data = [];
    if (this.managementZoneSubLevel2Value.data) {
      this.managementZoneSubLevel2Value.data.map((zone) => {
        managementZoneSubLevel2Data = [
          ...managementZoneSubLevel2Data,
          {
            label: zone.MGMT_ZONE_SUB_LEVEL2_TECH__c,
            value: zone.MGMT_ZONE_SUB_LEVEL2__c
          }
        ];
        return zone;
      });
    }
    this.error = this.managementZoneSubLevel2Value.error;
    return managementZoneSubLevel2Data;
  }

  handleManagementZoneSubLevel2Change(param, isUserSettings) {
    this.selectedManagementZoneSubLevel2 = param.target
      ? param.target.value
      : param;
    this.storage.management_zone_level_2 = this.selectedManagementZoneSubLevel2;
    this.isMzl2Disabled = !!(!this.isUnlockStoreHierarchy && (isUserSettings || this.userSettings?.management_zone_level_2 || this.currentUserMzl2Settings|| this.isMzl2Disabled));
    this.isMzl3Disabled = false;
    if (this.userSettingsApplied !== true) {
      this.userSelectionApplied = true;
      this.storage.userSelectionApplied = this.userSelectionApplied;
    }
    if (param.target) {
      this.handlePartialReset(2);
    }
    const payload = { storeHierarchy: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  get displayMzl2() {
    return this.storage.userSettingsApplied &&
      this.selectedManagementZoneSubLevel2
      ? "display-none"
      : "filter-mzl";
  }

  get managementZoneSubLevel3() {
    let managementZoneSubLevel3Data = [];
    if (this.managementZoneSubLevel3Value.data) {
      this.managementZoneSubLevel3Value.data.map((zone) => {
        managementZoneSubLevel3Data = [
          ...managementZoneSubLevel3Data,
          {
            label: zone.MGMT_ZONE_SUB_LEVEL3_TECH__c,
            value: zone.MGMT_ZONE_SUB_LEVEL3__c
          }
        ];
        return zone;
      });
    }
    this.error = this.managementZoneSubLevel3Value.error;
    return managementZoneSubLevel3Data;
  }

  handleManagementZoneSubLevel3Change(param, isUserSettings) {
    this.selectedManagementZoneSubLevel3 = param.target
      ? param.target.value
      : param;
    this.storage.management_zone_level_3 = this.selectedManagementZoneSubLevel3;
    this.isMzl3Disabled = !!(!this.isUnlockStoreHierarchy && (isUserSettings || this.userSettings?.management_zone_level_3 || this.currentUserMzl3Settings || this.isMzl3Disabled));
    this.isDefaultStoreDisabled = false;
    if (this.userSettingsApplied !== true) {
      this.userSelectionApplied = true;
      this.storage.userSelectionApplied = this.userSelectionApplied;
    }
    if (param.target) {
      this.handlePartialReset(3);
    }
    const payload = { storeHierarchy: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  get displayMzl3() {
    return this.storage.userSettingsApplied &&
      this.selectedManagementZoneSubLevel3
      ? "display-none"
      : "filter-mzl";
  }

  get defaultStore() {
    let defaultStoreData = [];
    if (this.defaultStoreValue.data) {
      this.defaultStoreValue.data.map((store) => {
        defaultStoreData = [
          ...defaultStoreData,
          {
            label: store.Name,
            value: store.RetailStoreId__c
          }
        ];
        return store;
      });
    }

    if (this.defaultStoreId && !this.isUnlockStoreHierarchy) {
      defaultStoreData = [...defaultStoreData, this.defaultStoreId];
      defaultStoreData = this.getSetOfObjectsByKey(defaultStoreData, 'value');
    }

    this.error = this.defaultStoreValue.error;
    return defaultStoreData;
  }

  get disabeldDefaultStore() {
    return (!(this.isReassignStep && !this.isUnlockStoreHierarchy) && this.isDefaultStoreDisabled) || !this.selectedManagementZoneSubLevel3;
  }

  get technicalUsers() {
    return this.isReassignStep ? [] : technicalUsers;
  }

  getSetOfObjectsByKey(array, key) {
    const uniqKeys = {};
    return array.filter((item) => {
      const isExist = uniqKeys[item[key]];
      uniqKeys[item[key]] = true;
      return !isExist;
    });
  }

  handleDefaultStoreChange(param, isUserSettings) {
    this.selectedDefaultStore = param.target ? param.target.value : param === 'reset' ? '' : param;
    this.storage.default_store = this.selectedDefaultStore;
    this.isDefaultStoreDisabled = !this.isUnlockStoreHierarchy && (isUserSettings || this.userSettings?.default_store || this.isDefaultStoreDisabled);
    this.isPreferedCaDisabled = !this.storage.default_store;
    this.userSelectionApplied = true;
    this.storage.userSelectionApplied = this.userSelectionApplied;
    if (param.target) {
      this.handlePartialReset(4);
    }
    const payload = { storeHierarchy: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  get assignedCA() {
    let assignedCaData = [];
    if (this.assignedCaValue.data) {
      this.assignedCaValue.data.map((user) => {
        assignedCaData = [
          ...assignedCaData,
          {
            label: user.Name,
            value: user.Id,
            employeeNumber: user.WWEmployeeNumber__c,
            clients: 0
          }
        ];
        return user;
      });
      this.showCaList = true;
      assignedCaData.sort((a, b) => {
        return a.label.localeCompare(b.label);
      });
    }
    this.error = this.assignedCaValue.error;
    return assignedCaData;
  }

  handleCustomerAdvisorsUpdate(param) {
    let isReset = false;
    const selectedArray = param.detail
                        ? Array.from(param.detail)
                        : Array.from(param);
    if (selectedArray[0] === 'reset') {
      this.selectedCaList = [];
      isReset = true;
    } else {
      this.selectedCaList = selectedArray;
    }
    this.storage.prefered_ca = this.selectedCaList;
    this.isPreferedCaDisabled = !this.selectedDefaultStore;
    this.showCaList = false;
    this.userSelectionApplied = true;
    this.storage.userSelectionApplied = this.userSelectionApplied;
    if (isReset) {
      this.template.querySelector('c-ct_search-filters-ca-multi-select')?.handleSelectedCaChange();
    }
    const payload = { storeHierarchy: this.storage };
    publish(this.messageContext, CL_STATE_EXCHANGE_CHANNEL, payload);
  }

  @api
  handleEmptyClientListChange(value) {
    this.isEmptyClientList = value.target ? value.target.checked : value;
    let el = this.template.querySelector(".filters-empty-client-list");
    if (!value.target && el) {
      el.checked = this.isEmptyClientList;
      this.dispatchEvent(
        new CustomEvent("updateclientlistworkflow", { detail: false })
      );
    } else {
      this.dispatchEvent(new CustomEvent("updateclientlistworkflow"));
    }
  }
}