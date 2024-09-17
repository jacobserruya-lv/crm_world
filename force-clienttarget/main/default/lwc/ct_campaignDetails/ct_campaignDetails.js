import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import getCampaignJobDetails from "@salesforce/apex/CL_controller.getClientListJobDetails";
import deleteChildJob from "@salesforce/apex/CL_controller.deleteChildJob";
import readCSV from "@salesforce/apex/CT_CSVParseController.readCSVFile";

export default class Ct_campaignDetails extends NavigationMixin(LightningElement) {
  /**
  * @type {{ id, string name: String, startDate: string, endDate: string, description: String, jobId: String, errorFileId: String }}
  */
  @api campaignInfo;
  activeSections = ["CAMPAIGN INFO"];

  jobIdToFetch;
  campaignJobDetails;
  errorFile;

  get isThereAnyErrors() {
    return this.errorFile;
  }

  get errorsListLength() {
    return this.errorFile?.split('\n')?.filter(Boolean).length - 1 || 0;
  }

  get campaignProgressData() {
    let percent = 5;
    if (!!this.campaignJobDetails) {
      const progressPercent = parseInt(this.campaignJobDetails.JobItemsProcessed / this.campaignJobDetails.TotalJobItems * 100);
      percent = progressPercent > 5 ? progressPercent : 5;
    }
    return percent;
  }

  get campaignStatus() {
    return this.campaignJobDetails?.Status === "Completed" ?
           this.campaignJobDetails?.Status : this.campaignProgressData + '%';
  }

  connectedCallback() {
    this.jobIdToFetch = this.campaignInfo.jobId;
    this.fetchJobData();
  }

  fetchJobData() {
    let jobProcess = setInterval(() => {
      getCampaignJobDetails({
        jobId: this.jobIdToFetch
      })
      .then(data => {
        this.campaignJobDetails = data;

        if (data?.Status == "Completed") {
          deleteChildJob({ jobId: this.jobIdToFetch });

          readCSV({
            idContentDocument: this.campaignInfo.errorFileId
          }).then(result => {
            this.errorFile = result;
            this.dispatchEvent(new CustomEvent("pushingclientstocampaignfinish", {
              detail: {
                errorsListLength: this.errorsListLength
              }
            }));
            clearInterval(jobProcess);
          })
        }
      });
    }, 5000);
  }

  handleErrorsDownload() {
    // const titles = ['DreamId', 'Message'];
    // const csvContent = [[titles, ...this.errorsList].join("\n")];
    const downloadElement = document.createElement('a');
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(this.errorFile);
    downloadElement.target = '_self';
    downloadElement.download = 'errors.csv';
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  handleGoToCampaignDetailsClick() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
        attributes: {
          recordId: this.campaignInfo.id,
          actionName: 'view',
        },
      });
  }

  handleEditClick() {
    console.log(`Edit list? ${this.isReassignStep}`);
  }

  handleSectionToggle(event) {
    console.log(`Currently opened section: ${event.detail.openSections} `);
  }
}