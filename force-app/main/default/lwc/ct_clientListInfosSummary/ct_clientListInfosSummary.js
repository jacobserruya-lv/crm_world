import { LightningElement, api, wire } from "lwc";
import getClientListJobDetails from "@salesforce/apex/CL_controller.getClientListJobDetails";
import getChildJobId from "@salesforce/apex/CL_controller.getChildJobId";
import deleteChildJob from "@salesforce/apex/CL_controller.deleteChildJob";

export default class Ct_clientListInfosSummary extends LightningElement {
  @api isReassignStep;
  @api clientListInfo;
  @api notContactableClients;
  activeSections = ["CLIENT LIST INFOS"];
  clientListJobDetails;
  membersJobDetails;
  membersJobId;
  jobIdToFetch;
  isChildJob = false;

  get clientListOptions() {
    return this.clientListInfo.clientListOptions;
  }

  get clientListName() {
    let { clientListName } = this.clientListOptions;
    return clientListName;
  }

  get expirationDate() {
    let { expirationDate } = this.clientListOptions;
    return expirationDate;
  }

  get clientListDescription() {
    let { clientListDescription } = this.clientListOptions;
    return clientListDescription;
  }

  get numberOfClients() {
    let { numberOfClients } = this.clientListOptions;
    return numberOfClients ?? 0 ;
  }

  get clientListJobId() {
    return this.clientListInfo.clientListId;
  }

  get clientListProgressData() {
    let percent = 5;
    if (!!this.clientListJobDetails) {
      const progressPercent = parseInt(this.clientListJobDetails.JobItemsProcessed / this.clientListJobDetails.TotalJobItems * 100);
      percent = progressPercent > 5 ? progressPercent : 5;
    }
    return percent;
  }

  get membersProgressData() {
    return this.membersJobDetails ?
           this.membersJobDetails.TotalJobItems === 0 ? 100 :
           parseInt(this.membersJobDetails.JobItemsProcessed / this.membersJobDetails.TotalJobItems * 100) : 0;
  }

  get membersStatus() {
    return this.membersJobDetails?.Status === "Completed" ?
           this.membersJobDetails?.Status : this.membersProgressData + '%';
  }

  get clientListStatus() {
    return this.clientListJobDetails?.Status === "Completed" ?
           this.clientListJobDetails?.Status : this.clientListProgressData + '%';
  }

  get showProgressBar() {
    return true;
  }

  get isNotContactableClients() {
    return this.notContactableClients?.data?.length > 0;
  }

  get isClientListWithMembers() {
    return this.numberOfClients > 0;
  }

  connectedCallback() {
    this.activeSections = this.isReassignStep === true ? [""] : ["CLIENT LIST INFOS"];
    if (this.showProgressBar) {
      this.jobIdToFetch = this.clientListJobId;
      this.fetchJobData();
    } else {
      this.clientListCreationFinish();
    }
    return this.isReassignStep;
  }

  fetchJobData() {
    let jobProcess = setInterval(() => {
      getClientListJobDetails({
        jobId: this.jobIdToFetch
      })
      .then(data => {
        this.isChildJob ? this.membersJobDetails = data : this.clientListJobDetails = data;

        if (data?.Status == "Completed") {
          if (this.isChildJob || !this.isClientListWithMembers) {
            deleteChildJob({jobId: this.jobIdToFetch});
            this.clientListCreationFinish();
            clearInterval(jobProcess);
          } else {
            this.getMembersJob();
          }
        }
      });
    }, 5000);
  }

  getMembersJob() {
    getChildJobId({parentJobId: this.clientListJobId})
      .then((data) => {
        this.membersJobId = data?.Job_Id__c;
        this.jobIdToFetch = this.membersJobId; 
        this.isChildJob = true;
      });
  }

  clientListCreationFinish() {
    this.dispatchEvent(new CustomEvent("createclientlistfinish"));
  }

  arrayOfObjectsToCSV(arr) {
    const titles = Object.keys(arr[0]);

    return [titles, ...arr].map(obj => {
      return Object.values(obj).toString();
    }).join('\n')
  }

  handleNotContactableClientsDownload() {
    const csvContent = this.arrayOfObjectsToCSV(this.notContactableClients?.data);
    const downloadElement = document.createElement('a');
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvContent);
    downloadElement.target = '_self';
    downloadElement.download = 'NotContactableClients.csv';
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  handleEditClick() {
    console.log(`Edit list? ${this.isReassignStep}`);
  }

  handleSectionToggle(event) {
    console.log(`Currently opened section: ${event.detail.openSections} `);
  }
}