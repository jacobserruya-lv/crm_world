import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAllCampaigns from "@salesforce/apex/CT_CampaignController.getAllCampaigns";
import pushClientsToCampaignFromBatch from '@salesforce/apex/CT_CampaignController.pushClientsToCampaignFromBatch';

export default class Ct_pushToCampaignModal extends LightningElement {
    @api storage;
  
    errorMsg = '';
    errorsList = [];
  
    campaignId = null;
    campaignSearchValue = '';
  
    @wire(getAllCampaigns)
    campaignsList;
  
    get campaignOptions() {
      return this.campaignsList?.data?.filter(({ Name }) => !this.campaignSearchValue || Name.includes(this.campaignSearchValue))
                                        ?.map(({ Name, Id }) => ({ label: Name, value: Id }));
    }
  
    get selectedCampaignInfo() {
      const selectedCampaign = this.campaignsList?.data?.find(({ Id }) => Id === this.campaignId) || {};
      
      return {
        id: selectedCampaign.Id,
        name: selectedCampaign.Name,
        description: selectedCampaign.Description__c,
        startDate: selectedCampaign.StartDate__c,
        endDate: selectedCampaign.EndDate__c
      };
    }
  
    get isFieldsNotFill() {
      return !(this.campaignId);
    }
  
    campaignOnFocus() {
      this.campaignId  = '';
    }
  
    handleCampaignChange = (value) => {
      this.campaignId = value;
    }
  
    closePicklist(e) {
      const target = e.target;
      if (target?.nodeName?.toLowerCase() != "c-ct_searchable-combobox") {
        this.template.querySelector('c-ct_searchable-combobox')?.closePicklist();
      }
    }
  
    @api
    closeModal() {
      this.expirationDate = null;
      this.topologyValue = null;
      this.offerCodeValue = null;
      this.isClientListIcon = null;
      this.dispatchEvent(new CustomEvent("destroycampaignmodal"));
    }
  
    loadSpinner(load, text) {
      this.dispatchEvent(new CustomEvent('loadspinner', {detail: {isLoading: load, text}, bubbles: true, composed: true})); 
    }
  
    handleAddClients() {
      this.errorMsg = '';
  
      this.loadSpinner(true, 'Adding clients to the campaign, please wait');
      const assignedCaByDreamId = this.storage.assignedCaByDreamId || {};
      
      if (Object.keys(assignedCaByDreamId).length == 0) {
        // Not using reduce since it takes way more time
        this.storage.dreamIdList.forEach((dreamId) => {
          assignedCaByDreamId[dreamId] = null;
        });
      }

      pushClientsToCampaignFromBatch({
        campaignId: this.campaignId,
        assignedCaByDreamId: assignedCaByDreamId
      })
        .then(({ jobId, errorFileId }) => {
          const selectedCampaign = new CustomEvent("clientspushedtocampaign", {
            detail: {
              campaignInfo: { 
                ...this.selectedCampaignInfo,
                jobId,
                errorFileId
              }
            }
          });
          this.loadSpinner(false);
          this.dispatchEvent(selectedCampaign);
        })
        .then(() => {
          this.toastMessage("Success!", 'Pushing clients to the campaign, job started successfully!', 'success');
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
  
    handleErrorsDownload() {
      const titles = ['DreamId', 'Message'];
      const csvContent = [[titles, ...this.errorsList].join("\n")];
      const downloadElement = document.createElement('a');
      downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvContent);
      downloadElement.target = '_self';
      downloadElement.download = 'errors.csv';
      document.body.appendChild(downloadElement);
      downloadElement.click();
    }
}