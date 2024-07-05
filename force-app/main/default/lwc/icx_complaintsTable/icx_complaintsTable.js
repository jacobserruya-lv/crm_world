import { api, LightningElement, track, wire } from "lwc";
import imagesResource from "@salesforce/resourceUrl/iconics";
import getAllRequests from "@salesforce/apex/ICX_Client360_SF.getAllRequests";
import getrecordsListSize from "@salesforce/apex/ICX_Client360_SF.getrecordsListSize";
import { NavigationMixin } from "lightning/navigation";
import { dateFormat2 } from "c/utils";

export default class Icx_complaintsTable extends NavigationMixin(LightningElement) {
  @track tableData = [];
  isWithSubtitles = true;
  isComplaint = true;
  isRemoteConsent = false;
  objectName = "Case";
  condition = "WHERE AccountId =: accountId AND Type = 'Complaints' ";
  @track recordsListlength = 0;
  @api sfRecordId;

  @wire(getrecordsListSize, {
    accountId: "$sfRecordId",
    objectName: "$objectName",
    condition: "$condition"
  })
  wiredListSize({ error, data }) {
    if (data) {
      this.recordsListlength = data;
      console.log(
        "The length of the  complaints records list",
        JSON.stringify(this.recordsListlength)
      );
    }
    if (error) {
      console.error("No results", error);
    }
  }

  @wire(getAllRequests, { accountId: "$sfRecordId", isComplaint: "$isComplaint",isRemoteConsent:"$isRemoteConsent" })
  wiredClientComplaints({ error, data }) {
    if (data) {
      this.tableData.title = {
        type: "text",
        label: "Complaints",
        iconSrc: imagesResource + `/images/client360/complaintsIcon.svg`,
        isWithIcon: true,
        isHeader: true,
        hasLength: true,
        titleClass: "title-bold title-navigation cursor-pointer",
        length: this.recordsListlength
      };

      this.tableData.rows = data.map((complaint) => {
        return (complaint = [
          { value: complaint.CaseNumber, type: "text-top", label: "Number" },
          { value: complaint.RecordType.Name, type: "text", label: "Type" },
          // { value: complaint.CreatedDate.split('T')[0].replaceAll('-',' '), type: 'text', label: 'Created Date' },
          {
            value: dateFormat2(
              complaint.CreatedDate.split("T")[0].split("-")[0],
              complaint.CreatedDate.split("T")[0].split("-")[1],
              complaint.CreatedDate.split("T")[0].split("-")[2]
            ),
            type: "text",
            label: "Created Date"
          },

          { value: complaint.Status, type: "text", label: "Status" }
        ]);
      });

      this.tableData.idList = data.map((complaint) => complaint.Id);
      console.log("complaint", data);
    }

    if (error) {
      console.error(error);
    }
  }

  navigateToComplaints(event) {
    let complaintsId = this.tableData.idList[event.detail];
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: complaintsId,
        objectApiName: "Case",
        actionName: "view"
      }
    });
  }

  navigateToViewListPage() {
    console.log("Try to navigate to a list");
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
}