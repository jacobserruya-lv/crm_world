import { api, LightningElement, track, wire } from "lwc";
import imagesResource from "@salesforce/resourceUrl/iconics";
import getRequests from "@salesforce/apex/ICX_Client360_SF.getAllRequests";
import USER_ID from "@salesforce/user/Id";
import getUserInfo from "@salesforce/apex/ICX_Account_Highlight.getUserInfo";
import getrecordsListSize from "@salesforce/apex/ICX_Client360_SF.getrecordsListSize";
import { NavigationMixin } from "lightning/navigation";
import { createRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { dateFormat2 } from "c/utils";
import getContactId from "@salesforce/apex/ICX_Client360_SF.getContactId";

import CASE_OBJECT from "@salesforce/schema/Case";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Icx_complaintsTable extends NavigationMixin(LightningElement) {
  @track tableData = [];
  isWithSubtitles = true;

  @api sfRecordId;
  @api authorizationToCreate;
  @track contactId;
  createNewSpacialButton = false;
  case;
  caseId;
  caseAccountId;
  isComplaint = false;
  isRemoteConsent = false;

  @track recordsListlength = 0;
  objectName = "Case";
  condition = "WHERE AccountId =: accountId AND Type != 'Complaints' ";
  objectInfo;
  @track isLoading = false;
  @track isShowModal = false;

  @track requestCreationRecordTypeChosen = "Call Case";
  @track requestCreationRecordTypeOption;

  connectedCallback() {
    console.log("display in requestTable the value here", this.authorizationToCreate);
    console.log("display in requestTable the value here", this.authorizationToCreate);
  }

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  objectInfo;

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

  @wire(getRequests, { accountId: "$sfRecordId", isComplaint: "$isComplaint",isRemoteConsent:"$isRemoteConsent" })
  wiredClientRequests({ error, data }) {
    if (data) {
      this.tableData.title = {
        type: "text",
        label: "Requests",
        iconSrc: imagesResource + `/images/client360/requestIcon.svg`,
        isWithIcon: true,
        isHeader: true,
        titleClass: "title-bold title-navigation cursor-pointer",
        hasLength: true,
        length: this.recordsListlength
      };

      this.tableData.rows = data.map((request) => {
        return (request = [
          { value: request.CaseNumber, type: "text", label: "Number" },
          { value: request.RecordType.Name, type: "text", label: "Type" },
          // { value: request.CreatedDate.split('T')[0].replaceAll('-',' '), type: 'text', label: 'Created Date' },
          {
            value: dateFormat2(
              request.CreatedDate.split("T")[0].split("-")[0],
              request.CreatedDate.split("T")[0].split("-")[1],
              request.CreatedDate.split("T")[0].split("-")[2]
            ),
            type: "text",
            label: "Created Date"
          },

          { value: request.Status, type: "text", label: "Status" }
        ]);
      });

      this.tableData.idList = data.map((request) => request.Id);
    }

    if (error) {
      console.error(error);
    }
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

  @wire(getUserInfo, {
    userId: USER_ID
  })
  wiredgetUserInfo({ error, data }) {
    if (data) {
      this.userDetails = data;
      this.error = undefined;
      console.log("The value is :", this.createNewSpacialButton);

      if (
        (this.userDetails && this.userDetails.Profile.Name.includes("ICONiCS")) ||
        (this.userDetails && this.userDetails.Profile.Name.includes("Admin"))
      ) {
        this.createNewSpacialButton = true;
        console.log("The value is :", this.createNewSpacialButton);
      } else if (
        this.userDetails &&
        (this.userDetails.Profile.Name.includes("ICON_Corporate") ||
          this.userDetails.Profile.Name.includes("ICON_SA Manager") ||
          this.userDetails.Profile.Name.includes("ICON_SAManager"))
      ) {
        this.createNewSpacialButton = false;
        console.log("The value is :", this.createNewSpacialButton);
      }
    } else if (error) {
      this.error = error;

      console.log(" error in userinfo", this.error);
    }
  }




  async navigateToRequestCreationPage() {
    if (!this.contactId) {
      let responseContactId = await getContactId({ accountId: this.sfRecordId })
        .then((result) => {
          this.contactId = result;
          console.log("nao contact id", this.contactId);
        })
        .catch((error) => {
          console.error(error);
        });
    }

    let defaultValues =
      "AccountId=" +
      this.sfRecordId +
      ",ContactId=" +
      this.contactId +
      ",Tech_Flow_Completed__c=true";
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Case",
        actionName: "new"
      },
      state: {
        useRecordTypeCheck: 1,
        defaultFieldValues: defaultValues
      }
    });
  }



  navigateToRequest(event) {
    let requestId = this.tableData.idList[event.detail];
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: requestId,
        objectApiName: "Case",
        actionName: "view"
      }
    });
  }
}