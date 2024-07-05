import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import getEventJobDetails from "@salesforce/apex/CL_controller.getClientListJobDetails";
import deleteChildJob from "@salesforce/apex/CL_controller.deleteChildJob";
import readCSV from "@salesforce/apex/CT_CSVParseController.readCSVFile";

export default class Ct_eventInfosSummary extends NavigationMixin(LightningElement) {
  /**
   * @type {{ id, string name: String, startDate: string, endDate: string, description: String, jobId: String, errorFileId: String }}
   */
  @api eventInfo;
  activeSections = ["EVENT INFO"];

  jobIdToFetch;
  eventJobDetails;
  errorFile;

  get isThereAnyErrors() {
    return this.errorFile;
  }

  get errorsListLength() {
    return this.errorFile?.split('\n')?.filter(Boolean).length - 1 || 0;
  }

  get eventProgressData() {
    let percent = 5;
    if (!!this.eventJobDetails) {
      const progressPercent = parseInt(this.eventJobDetails.JobItemsProcessed / this.eventJobDetails.TotalJobItems * 100);
      percent = progressPercent > 5 ? progressPercent : 5;
    }
    return percent;
  }

  get eventStatus() {
    return this.eventJobDetails?.Status === "Completed" ?
           this.eventJobDetails?.Status : this.eventProgressData + '%';
  }

  connectedCallback() {
    this.jobIdToFetch = this.eventInfo.jobId;
    this.fetchJobData();
  }

  fetchJobData() {
    let jobProcess = setInterval(() => {
      getEventJobDetails({
        jobId: this.jobIdToFetch
      })
      .then(data => {
        this.eventJobDetails = data;

        if (data?.Status == "Completed") {
          deleteChildJob({ jobId: this.jobIdToFetch });

          readCSV({
            idContentDocument: this.eventInfo.errorFileId
          }).then(result => {
            this.errorFile = result;
            this.dispatchEvent(new CustomEvent("addingclientstoeventfinish", {
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

  handleGoToEventDetailsClick() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
        attributes: {
            recordId: this.eventInfo.id,
            actionName: 'view',
        },
      });
  }

  handleEditClick() {
    console.log(`Edit list? ${this.isReassignStep}`);
  }

  handleSectionToggle(event) {
    console.log(`Curently opened section: ${event.detail.openSections} `);
  }
}