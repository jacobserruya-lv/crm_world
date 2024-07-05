import { api, LightningElement, track, wire } from "lwc";
import imagesResource from "@salesforce/resourceUrl/iconics";
import getAllRequests from "@salesforce/apex/ICX_Client360_SF.getAllRequests";
import getrecordsListSize from "@salesforce/apex/ICX_Client360_SF.getrecordsListSizeRemoteConsent"; //not a generic function, only for remote consent
import { NavigationMixin } from "lightning/navigation";
import { dateFormat2 } from "c/utils";

export default class Icx_remoteConsentTable extends NavigationMixin(LightningElement) {
    @track tableData = [];
    isWithSubtitles = true;
    isComplaint = false;
    isRemoteConsent = true;

    @track recordsListlength = 0;
    @api sfRecordId;
  
    @wire(getrecordsListSize, {
      accountId: "$sfRecordId"
    })
    wiredListSize({ error, data }) {
      if (data) {
        this.recordsListlength = data;
        console.log("The length of the  remote consent records list",JSON.stringify(this.recordsListlength));
      }
      if (error) {
        console.error("length of the  remote consent error", error);
      }
    }
  
    @wire(getAllRequests, { accountId: "$sfRecordId", isComplaint: "$isComplaint",isRemoteConsent:"$isRemoteConsent" })
    wiredClientRemoteConsent({ error, data }) {
      if (data) {
        this.tableData.title = {
          type: "text",
          label: "Remote Consent",
          iconSrc: imagesResource + `/images/client360/requestIcon.svg`,
          isWithIcon: true,
          isHeader: true,
          hasLength: true,
          titleClass: "title-bold title-navigation cursor-pointer",
          length: this.recordsListlength
        };
  
        this.tableData.rows = data.map((remoteConsent) => {
          return (remoteConsent = [
            { value: remoteConsent.CaseNumber, type: "text-top", label: "Number" },
            { value: remoteConsent.RecordType.Name, type: "text", label: "Type" },
            {
              value: dateFormat2(
                remoteConsent.CreatedDate.split("T")[0].split("-")[0],
                remoteConsent.CreatedDate.split("T")[0].split("-")[1],
                remoteConsent.CreatedDate.split("T")[0].split("-")[2]
              ),
              type: "text",
              label: "Created Date"
            },
  
            { value: remoteConsent.Status, type: "text", label: "Status" }
          ]);
        });
  
        this.tableData.idList = data.map((remoteConsent) => remoteConsent.Id);
        console.log("remoteConsent", data);
      }
  
      if (error) {
        console.error(error);
      }
    }
  
    navigateToRemoteConsent(event) {
      let remoteConsentIds = this.tableData.idList[event.detail];
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: remoteConsentIds,
          objectApiName: "Case",
          actionName: "view"
        }
      });

    }
  
    navigateToViewListRequestPage() {
      this[NavigationMixin.Navigate]({
        type: "standard__recordRelationshipPage",
        attributes: {
          objectApiName: "Account",
          recordId: this.sfRecordId,
          relationshipApiName: "Cases",
          actionName: "view"
        }
      });

    }

    get remoteConsentNotEmpty()
    {
      return this.recordsListlength>0;
    }
}