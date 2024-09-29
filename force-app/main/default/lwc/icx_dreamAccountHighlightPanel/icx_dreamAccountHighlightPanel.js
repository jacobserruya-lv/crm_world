import { LightningElement, api, wire, track } from "lwc";
import modalPopUp from 'c/icx_modalPopUp_EditUser';
import imagesResource from "@salesforce/resourceUrl/iconics";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getIndicatorList from "@salesforce/apex/ICX_CaseDataServiceControllerLC.getIndicatorList";
import getUserInfo from "@salesforce/apex/ICX_Account_Highlight.getUserInfo";
import permissionSetEditUser from '@salesforce/customPermission/Icx_MyLvEdit';
//import revealAppName from "@salesforce/apex/ICX_Client360_SF.getAppName";

import USER_ID from "@salesforce/user/Id";
import { loadStyle } from "lightning/platformResourceLoader";
import styleResource from "@salesforce/resourceUrl/iconics";
import { ToastError, dateFormat, dateFormat2 } from "c/utils";
import Phone from "@salesforce/schema/UserChangeEvent.Phone";
import EMAIL_FIELD from '@salesforce/schema/User.Email';

export default class Icx_dreamAccountHighlightPanel extends NavigationMixin(LightningElement) {
  @api accountId;
  @api SObject;
  @api displayHorizontalFormat;
  @api account;
  @api isLoading;
  @api authToEditModal;
  @api currentSObject;
  userFields = [EMAIL_FIELD];
  @api isMultiMatch =false;
  @api accountList;
  @api recordId;
  userDetails;
  isUserIconics = false;
  isUserIcon = false;
  isUserClient360 = false;
  pendingAnswersLength = 0;
  pendingCareServiceLength = 0;
  complaintsResolvedLength = 0;
  complaintsPendingLength = 0;
  surveyPendingLength = 0;
  pmp;
  pmh;
  pp;
  indicatorList = [];
  @track fieldsForCopy = [];
  showSpeaker = false;
  displayPhoneIcone = true;
  showBell = false;
  lvEmailSize;
  lvMiddleSize;
  showPendingAnswers = false;

  showPendingCareService = false;
  showPendingComplaints = false;
  showResolvedComplaints = false;
  showPendingSurveys = false;
  dreamAccountClient = false;
  editAvailable = false;
  searchAvailable = true;
  appName;
  hideSFsearchBar;
  iconicsApp;
  Name = "Name";
  Dream_ID = "Dream ID";
  Language = "Language";
  Last_Contact = "Last Contact";
  Phone = "Phone";
  Email = "Email";
  Address = "Address";

  @track isModalOpen = false;
  @track doneIndicator;
  @track birthdateTitle;
  MyLV_IMG =
    '<img src="/resource/iconics/images/MyLV.png" alt="myLV" style="height:30px; width:40px;" border="0"/>';
  get badgeClass() {
    let colorClass;
    switch(this.account.displayedSegment) {
        case 'Prestige':
          colorClass = 'seg1-badge';
          break;
        case 'VVIC':
          colorClass = 'seg1-badge';
          break;
        case 'VIC':
          colorClass = 'seg1-badge';
          break;
        case 'Aspiring Repeater':
          colorClass = 'seg2-badge';
          break;
        case 'Repeater':
          colorClass = 'seg2-badge';
          break;
        case 'Promising One Timer':
          colorClass = 'seg3-badge';
          break;
        case 'One Timer':
          colorClass = 'seg3-badge';
          break;
        // Add more cases as needed
        default:
          colorClass = '';
    }
    return `slds-badge test ${colorClass}`; // Combine with slds-badge class
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.dreamAccountClient = currentPageReference.state?.c__dreamAccountClient;
    }
  }

  openModal() {
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
  }
  submitDetails() {
    this.isModalOpen = false;
  }

  @wire(getUserInfo, { userId: USER_ID })
  wiredgetUserInfo({ error, data }) {
    if (data) {
      this.userDetails = data;
      this.error = undefined;

      if (this.userDetails && this.userDetails.Profile.Name.includes("ICONiCS")) {
        this.isUserIconics = true;
        this.isUserIcon = false;
        console.log("We are here 1");
      } else if (
        this.userDetails &&
        (this.userDetails.Profile.Name.includes("ICON_Corporate") ||
          this.userDetails.Profile.Name.includes("ICON_SA Manager") ||
          this.userDetails.Profile.Name.includes("ICON_SAManager"))
      ) {
        this.isUserIconics = false;
        this.isUserIcon = true;
        console.log("We are here 2");
      } else if (this.userDetails && this.userDetails.Profile.Name.includes("Admin")) {
        this.isUserIconics = true;
        this.isUserIcon = true;
        console.log("We are here 3");
      } else {
        this.isUserIconics = false;
        this.isUserIcon = false;
        console.log("We are here 4");
      }
    } else if (error) {
      this.error = error;

      console.log(" error", this.error);
    }

    this.editAvailable = this.isUserIconics && !this.dreamAccountClient;
    //    this.searchAvailable = this.isUserIconics && !this.dreamAccountClient;

    if (this.isUserIconics && !this.dreamAccountClient) {
      this.getIndicator();
    }
  }

  delay() {
    setTimeout(function () {
      checkWidth();
    }, 200);
  }

  connectedCallback() {
    console.log('isMultiMatch' , this.isMultiMatch);
    console.log('oieuuuuuuuuu' , this.recordId);
    Promise.all([loadStyle(this, styleResource + "/styles/client360.css")]).catch((error) =>
      console.error(" error in loading style", error)
    );
    console.log("See the results of numbers", this.editAvailable);

    //    revealAppName()
    //    .then((result)=>{
    //        console.log('We reach here');
    //        this.appName = result;
    //        console.log('Look over here which App is it ===========>>>>>>>>>>>>>',this.appName);
    //        if(this.appName === 'Client 360')
    //        {
    //            this.hideSFsearchBar = 'hide_search_standart_salesforce';
    //            console.log('And we reveal the AppName here',this.hideSFsearchBar);
    //         }else{
    //             this.iconicsApp = true;
    //             console.log('Look over here twice which App is it ===========>>>>>>>>>>>>>',this.appName);
    //             console.log('Look over here App is it ===========>>>>>>>>>>>>>',this.iconicsApp);
    //         }
    //     })
    //     .catch((error)=>{
    //         console.log('Display the error here',error);
    //     });
  }

  renderedCallback() {
    console.log('isMultiMatch rendered' , this.isMultiMatch);

    var myElement = this.template.querySelector(".LV-slds-truncate");
    if (myElement) {
      var myElementWidth = myElement.clientWidth;
      if (myElementWidth < 120) {
        this.lvEmailSize = "normal";
        this.lvfirstSize = "normal";
        console.log("Say some");
        console.log("Show that alraedy =====>>>>>" + myElementWidth + "px");
      } else {
        this.lvEmailSize = "large";
        this.lvfirstSize = "large";
        console.log("Show that alraedy =====>>>>>" + myElementWidth + "px");
      }
    }
    if (this.account) {
      this.fieldsForCopy = [
        this.Name + ": " + this.account.Name,
        "\n" + this.Dream_ID + ": " + this.account.dreamID,
        "\n" + this.Language + ": " + this.account.Prefered_Language,
        "\n" + this.Last_Contact + ": " + this.account.lastContact,
        "\n" + this.Phone + ": " + this.account.PersonMobilePhone,
        "\n" + this.Email + ": " + this.account.email,
        "\n" + this.Address + ": " + this.account.address
      ];

      if (this.account.Prefered_Language) {
        this.fieldsForCopy[2] = "\n" + this.Language + ": " + this.account.Prefered_Language;
      } else {
        this.fieldsForCopy[2] = "\n" + this.Language + ": " + "N/A";
      }
      if (this.account.PersonMobilePhone) {
        this.fieldsForCopy[4] = "\n" + this.Phone + ": " + this.account.PersonMobilePhone;
      } else {
        this.fieldsForCopy[4] = "\n" + this.Phone + ": " + "Do Not Contact";
      }
      if (this.account.address) {
        this.fieldsForCopy[6] = "\n" + this.Address + ": " + this.account.address;
      } else {
        this.fieldsForCopy[6] = "\n" + this.Address + ": " + "Do Not Contact";
      }

      console.log("Demo of details array", this.fieldsForCopy);

      if (this.account.PersonMobilePhone) {
        this.pmp = "M : " + this.account.PersonMobilePhone;
      } else {
        this.pmp = "";
      }
      if (this.account.PersonHomePhone) {
        this.pmh = "H : " + this.account.PersonHomePhone;
      } else {
        this.pmh = "";
      }
      if (this.account.Phone) {
        this.pp = "P : " + this.account.Phone;
      } else {
        this.pp = "";
      }

      console.log("=>>>>>", this.pmp);
      console.log("=>>>>>", this.pmh);
      console.log("=>>>>>", this.pp);
      let tableTR = this.template.querySelectorAll("img").forEach((el) => {
        if (el.dataset.type == "phone") {
          el.className =
            !this.account.PersonMobilePhone && !this.account.PersonHomePhone && !this.account.Phone
              ? "highlight__icon-detail_disabled"
              : "";
        }
        if (el.dataset.type == "sms") {
          el.className = !this.account.PersonMobilePhone ? "highlight__icon-detail_disabled" : "";
        }

        if (el.dataset.type == "email") {
          el.className = !this.account.email ? "highlight__icon-detail_disabled" : "";
        }
        if (el.dataset.type == "address") {
          el.className = !this.account.address ? "highlight__icon-detail_disabled" : "";
        }
      });

      this.Language_IMG();
    }
  }

   get isEditUserEnabled() {
    var isVisible = permissionSetEditUser && this.account.hasdateIdentity;
    console.log('permissionSetEditUser' + permissionSetEditUser +     ' his.account.lastActivity' +  this.account.isActiveUser + ' José   ' +  isVisible);

    /* if (this.account.isActiveUser && permissionSetEditUser )  */return isVisible; 

    /* else    return  false *//* permissionSetEditUser && this.account.lastActivity */;
    }

  async handleEditUser(){
    const result = await modalPopUp.open({
      content: this.account.userId,
      accountId: this.accountId,
      accountEmail: this.account.email,
      userEmail: this.account.myLVemail,

    }).then((result) => {
      if (result) {
          this.showToastPopUp(result.toastType, result.message);
          setTimeout(() => {
            // Rafraîchir la page après le délai
            window.location.reload();
        }, 2000);
      }

  });
}

  showToastPopUp(variant, message) {
    const evt = new ShowToastEvent({
        title: variant === 'success' ? 'Succès' : variant === 'error' ? 'Erreur' : 'Attention',
        message: message,
        variant: variant
    });
    this.dispatchEvent(evt);

   /*  const modal = this.template.querySelector("c-icx_modal-Pop-Up_-Edit-User");
    modal.show();
    console.log('OK2'); */
  }
  async getIndicator() {
    let responseIndication = await getIndicatorList({ recordId: this.accountId })
      .then((result) => {
        let response = result;
        console.log(" in get indicator response", response);

        let pendingAnswersList = [];
        let pendingCareServiceList = [];
        let complaintsResolved = [];
        let complaintsPending = [];
        let surveysPending = [];

        let speakerIconIndicator = [];
        let bellIconIndicator = [];
        //Open case

        for (var key in response.openMessagingList) {
          let messagingItem = response.openMessagingList[key];

          //icon bell indicator
          if (messagingItem.age <= 2) {
            bellIconIndicator.push(messagingItem);
          }
        }
        for (var key in response.liveChatTranscriptList) {
          let liveChatTranscriptItem = response.liveChatTranscriptList[key];

          //icon bell indicator
          if (liveChatTranscriptItem.age <= 2) {
            bellIconIndicator.push(liveChatTranscriptItem);
          }
        }

        for (var key in response.taskList) {
          let taskItem = response.taskList[key];

          //icon bell indicator
          if (
            taskItem.age <= 2 &&
            taskItem.record.RecordType.DeveloperName === "CSC_Call" &&
            taskItem.record.CallType === "Inbound"
          ) {
            bellIconIndicator.push(taskItem);
          }
        }

        for (var key in response.openCaseList) {
          let openCase = response.openCaseList[key];

          if (
            openCase.record.Resolution__c === "Request to Store" ||
            openCase.record.RecordType.DeveloperName === "Operation_Exception" ||
            openCase.record.RecordType.DeveloperName === "Call_Case" ||
            openCase.record.RecordType.DeveloperName === "Web_Email_Case" ||
            openCase.record.RecordType.DeveloperName === "Product_On_Demand_with_sku"
          ) {
            //||  openCase.record.RecordType.DeveloperName === 'Chat_Messaging'
            if (openCase.record.Status == "New" || openCase.record.Status == "Awaiting") {
              pendingAnswersList.push(openCase);

              //icon speaker indicator
              if (openCase.age <= 2) {
                speakerIconIndicator.push(openCase);
              }
            }
          }

          //icon bell indicator
          if (
            openCase.record.RecordType.DeveloperName === "Call_Case" ||
            openCase.record.RecordType.DeveloperName === "Web_Email_Case" ||
            openCase.record.RecordType.DeveloperName === "Chat_Messaging"
          ) {
            if (openCase.age <= 2) {
              bellIconIndicator.push(openCase);
            }
          }
        }

        if (speakerIconIndicator.length > 0) {
          this.showSpeaker = true;
        }

        if (bellIconIndicator.length >= 3) {
          this.showBell = true;
        }

        // Sort by date
        pendingAnswersList.sort(function (a, b) {
          // Turn your strings into dates, and then subtract them
          // to get a value that is either negative, positive, or zero.
          return new Date(b.record.CreatedDate) - new Date(a.record.CreatedDate);
        });

        response.pendingAnswersList = pendingAnswersList;

        //care service

        // Workaround : get care duration
        for (var key in response.careList) {
          let careItem = response.careList[key];

          var oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
          var today = new Date();
          var secondDate = new Date(careItem.CreatedDate);

          var diffDays = Math.round(Math.abs((today.getTime() - secondDate.getTime()) / oneDay));

          careItem.Duration = diffDays;
          careItem.label =
            careItem.SKU__c === undefined
              ? careItem.Product_Sku_unknown__c
              : careItem.SKU__c + " - " + careItem.Product_Name__c;

          if (
            (careItem.ICONiCS_Status_Detail__c != "Cancelled" &&
              careItem.ICONiCS_Status_Detail__c != "Delivered to Client") ||
            careItem.ICONiCS_Status_Detail__c != "Product stocked"
          ) {
            pendingCareServiceList.push(careItem);
            console.log("careItem  :");
            console.log(careItem);
            console.log(careItem.age);
          }
        }
        // Sort by date
        pendingCareServiceList.sort(function (a, b) {
          // Turn your strings into dates, and then subtract them
          // to get a value that is either negative, positive, or zero.
          return new Date(b.CreatedDate) - new Date(a.CreatedDate);
        });

        response.pendingCareServiceList = pendingCareServiceList;

        //complaint
        for (var key in response.complaintList) {
          let complaint = response.complaintList[key];

          if (
            complaint.record.Status == "Closed" ||
            complaint.record.Status == "Successful" ||
            complaint.record.Status == "Cancelled" ||
            complaint.record.Status == "My Product on Demand (with sku) created"
          ) {
            complaintsResolved.push(complaint);
          } else if (complaint.record.Status == "New" || complaint.record.Status == "Awaiting") {
            complaintsPending.push(complaint);
            console.log("complaint AGE :");
            console.log(complaint.age);
          }
        }

        if(response.surveyList != null)
        {
          for (var key in response.surveyList) {
            let surveyItem = response.surveyList[key];
  
              surveysPending.push(surveyItem);      
              console.log('Display all the surveys instances  now => ',surveysPending);
            }
          }

        response.pendingComplaintsList = complaintsPending;
        response.resolvedComplaintsList = complaintsResolved;

        this.indicatorList.pendingAnswersList = response.pendingAnswersList
          ? response.pendingAnswersList
          : [];
        this.indicatorList.pendingCareServiceList = response.pendingCareServiceList
          ? response.pendingCareServiceList
          : [];
        this.indicatorList.pendingComplaintsList = response.pendingComplaintsList
          ? response.pendingComplaintsList
          : [];
        this.indicatorList.resolvedComplaintsList = response.resolvedComplaintsList
          ? response.resolvedComplaintsList
          : [];
        this.indicatorList.surveysPendingList = response.surveyList
          ?  response.surveyList 
          : [];

        this.pendingAnswersLength = this.indicatorList.pendingAnswersList.length;
        this.pendingCareServiceLength = this.indicatorList.pendingCareServiceList.length;
        this.complaintsPendingLength = this.indicatorList.pendingComplaintsList.length;
        this.complaintsResolvedLength = this.indicatorList.resolvedComplaintsList.length;
        this.surveyPendingLength = this.indicatorList.surveysPendingList.length;


        console.log("indicator in highlight", this.indicatorList);
      })
      .catch((error) => {
        console.error(" indicator error", error);
      });
    this.doneIndicator = true;
  }

  get oobLabel() {
    return this.account?.isUserIdentity || this.account?.dreamID
      ? "Order as Client"
      : "Order as Guest";
  }

  get showSpeakerOrBell() {
    return this.showSpeaker || this.showBell;
  }
  get isUserIconicsAndSF() {
    return this.isUserIconics && !this.dreamAccountClient;
  }

  get MyLVBadge() {
    if (!this.account.hasdateIdentity ){
      this.inactivUser = false;
      return  "highlight__icon-detail_badge_red"
    }else if (this.account.isUserIdentity && this.account.lastActivity && this.account.isActiveUser){
      this.inactivUser = false;
      return  "highlight__icon-detail_badge_green";
    }else {
      this.inactivUser = true;
      return  "highlight__icon-detail_badge_grey";}
   /* return this.account.isUserIdentity && this.account.lastActivity
      ? "highlight__icon-detail_badge_green"
      : "highlight__icon-detail_badge_red";*/
  }
  get MyLVHorizontalBadge() {
    if (!this.account.hasdateIdentity ){
      this.inactivUser = false;
      return  "highlight__LV-horizontal-icon-detail_badge_red"
    }else if (this.account.isUserIdentity && this.account.lastActivity &&   this.account.isActiveUser ){
      this.inactivUser = false;
      return  "highlight__LV-horizontal-icon-detail_badge_green";
    }else {
      this.inactivUser = true;
      return  "highlight__LV-horizontal-icon-detail_badge_grey";}
   /*
    return this.account.isUserIdentity && this.account.lastActivity
      ? "highlight__LV-horizontal-icon-detail_badge_green"
      : "highlight__LV-horizontal-icon-detail_badge_red";*/
  }
  get userIdentityId(){
    console.log('testt micro ' + this.account.userId );
    return this.account.userId; 
    
  }
  get myLVTitle() {
    return  this.account.hasdateIdentity//this.account.isUserIdentity && this.account.lastActivity
    ? this.account.lastActivity
    : "No MyLV Client";
  }
  get myLVValue() {
    if ( this.account.hasdateIdentity){
      return  !this.inactivUser //this.account.isUserIdentity && this.account.myLVemail
    ? this.account.myLVemail
      :  this.account.myLVemail + " (Inactive)";

    }else return "No MyLV Client";
    
  }

  get lvEmailLength() {
    // console.log('Email size >>>>>>>>>>>>',this.lvEmailSize);
    return this.lvEmailSize == "normal" ? "third-item_normal" : "third-item_large";
  }

  get lvfirstSizeSection() {
    return this.lvfirstSize == "normal" ? "first-item_normal" : "first-item_large";
  }
  get phoneIconDisplay() {
    return !this.account.PersonMobilePhone && !this.account.PersonHomePhone && !this.account.Phone
      ? false
      : true;
  }
  get smsIconDisplay() {
    return !this.account.PersonMobilePhone ? false : true;
  }
  get emailIconDisplay() {
    return !this.account.email ? false : true;
  }
  get addressIconDisplay() {
    return !this.account.address ? false : true;
  }

  get identifyObject() {
    console.log("this.sObject : ", this.SObject);
    return this.SObject == "Account" ? true : false;
  }

  get editOtherSobjects() {
    return !this.identifyObject && this.authToEditModal ? true : false;
  }

  get phoneBadge() {
    console.log("show the sObject", this.editOtherSobjects);
    console.log("See the format of component", this.displayHorizontalFormat);
    console.log("show the buttonAuthority", this.identifyObject);
    console.log("Show the value of this.displayPhoneIcone ", this.phoneIconDisplay);
    console.log("Show the value of this.authToEditModal ", this.authToEditModal);
    return !this.phoneIconDisplay
      ? "highlight__icon-detail_badge_grey"
      : this.account.Can_Be_Contacted_By_Phone
      ? "highlight__icon-detail_badge_green"
      : "highlight__icon-detail_badge_red ";
  }

  copyToClipboard() {
    //    .then(()=>{
    console.log("Print successfuly the details", this.fieldsForCopy);
    let extension_link = this.fieldsForCopy;
    var dummy = document.createElement("textarea");
    // to avoid breaking orgain page when copying more words
    // cant copy when adding below this code
    // dummy.style.display = 'none'
    document.body.appendChild(dummy);
    //Be careful if you use texarea. setAttribute('value', value), which works
    // with "input" does not work with "textarea". – Eduard
    dummy.value = extension_link;
    console.log("Print successfuly the details", dummy.value);
    if (dummy.value) {
      dummy.select();
      document.execCommand("copy");
      document.body.removeChild(dummy);
      const event = new ShowToastEvent({
        title: "Success",
        message: "Details copied to clipboard",
        variant: "success"
      });
      this.dispatchEvent(event);
    }
    // })
    // .catch((error)=>{
    else {
      console.log("Failed to copy details", error);
      const eve = new ShowToastEvent({
        title: "Error",
        message: "Failed to copy details",
        varint: "error"
      });
      dispatchEvent(eve);
    }
    // });
  }

  get displayCtiIcon() {
    console.log("Show the value of this.authToEditModal", this.authToEditModal);
    console.log(
      "Show the value of this.account.Can_Be_Contacted_By_Phone  ",
      this.account.Can_Be_Contacted_By_Phone
    );
    return this.authToEditModal && this.account.Can_Be_Contacted_By_Phone ? true : false;
  }

  get textBadge() {
    return !this.smsIconDisplay
      ? "highlight__icon-detail_badge_grey"
      : this.account.Can_Be_Contacted_By_SMS
      ? "highlight__icon-detail_badge_green"
      : "highlight__icon-detail_badge_red";
  }

  get emailBadge() {
    return !this.emailIconDisplay
      ? "highlight__icon-detail_badge_grey"
      : this.account.Can_Be_Contacted_By_Email
      ? "highlight__icon-detail_badge_green"
      : "highlight__icon-detail_badge_red";
  }

  get homeBadge() {
    return !this.addressIconDisplay
      ? "highlight__icon-detail_badge_grey"
      : this.account.Can_Be_Contacted_By_Address
      ? "highlight__icon-detail_badge_green"
      : "highlight__icon-detail_badge_red";
  }

  get LV_background_img() {
    if (this.account.greyMarketStatus) {
      return (
        imagesResource +
        "/images/client360/LV_background_" +
        this.account.greyMarketStatus[0].toUpperCase() +
        this.account.greyMarketStatus.slice(1).toLowerCase() +
        ".svg"
      );
    } else {
      return imagesResource + "/images/client360/LV_background_Grey.svg";
    }
  }

  get Parallel_Market_IMG() {
    if (this.account.Parallel_Market_IMG) {
      return this.account.Parallel_Market_IMG;
    } else if (this.account.greyMarketStatus) {
      return (
        '<img border="0" style="height:23px; width:35px;" alt=' +
        this.account.greyMarketStatus.toLowerCase() +
        ' src="/resource/iconics/images/ParallelMarket' +
        this.account.greyMarketStatus[0].toUpperCase() +
        this.account.greyMarketStatus.slice(1).toLowerCase() +
        '.png">'
      );
    } else {
      return '<img border="0" style="height:23px; width:35px;" alt="Grey" src="/resource/iconics/images/ParallelMarketGrey.png">';
    }
  }

  get segmentation() {
    if (this.account.indic10KImg) {
      console.log(" in segmentation  ", this.account.indic10KImg);

      return this.account.indic10KImg;
    }

    //not in mvp ? --> missing segmentation mapping
    // else if(this.account.segmentationClient)
    // {
    //     console.log(' in segmentation else before ', this.account.segmentationClient)

    //     let segmentationImg;

    //     if (this.account.segmentationClient == "10k this year")
    //     {
    //         segmentationImg = '10K this year';

    //     }
    //     else if(this.account.segmentationClient == "10k")
    //     {
    //         segmentationImg = '10K';

    //     }
    //     else if(this.account.segmentationClient == "potential 10k")
    //     {
    //         segmentationImg = 'Potential10K';

    //     }
    //     else if(this.account.segmentationClient == "50k"){
    //         segmentationImg = '50K';

    //     }

    //       console.log(' in segmentation else after ', segmentationImg)

    //     let imgseg = '<img src="/resource/iconics/images/'+segmentationImg+'.png" alt="'+segmentationImg+'" style="height:40px; width:40px;" border="0"/>';
    //     console.log(' in segmentation else img ', imgseg)

    //     return imgseg;
    // }
  }
  get Gender_IMG() {
    if (this.account.Gender_IMG) {
      return this.account.Gender_IMG;
    } else if (this.account.Gender) {
      return this.account.Gender.toLowerCase() == "female" ||
        this.account.Gender.toLowerCase() == "f"
        ? '<img border="0" style="height:40px; width:40px;" alt="Avatar" src="/resource/iconics/images/Avatarwoman.PNG">'
        : this.account.Gender.toLowerCase() == "male" || this.account.Gender.toLowerCase() == "m"
        ? '<img border="0" style="height:40px; width:40px;" alt="Avatar" src="/resource/iconics/images/Avatarman.PNG">'
        : "";
    }
  }
  Language_IMG() {
    let Language_IMG;

    if (this.account.Prefered_Language) {
      Language_IMG =
        '<img border="0" style=" width:30px;height:20px" alt="' +
        this.account.Prefered_Language +
        '" src="/resource/iconics/images/lang/' +
        this.account.Prefered_Language +
        '.png"></img>';

      const flag_container = this.template.querySelector(".highlight__flag"); //.appendChild(new DOMParser().parseFromString(Language_IMG));

      flag_container ? (flag_container.innerHTML = Language_IMG) : "";
    }
  }
  get Birthday_Cake_IMG() {
    if (this.account.Birthday_Cake_IMG) {
      return this.account.Birthday_Cake_IMG;
    } else if (this.account.birthdate) {
      const today = new Date();
      const birthdate = new Date(this.account.birthdate);

      console.log("nao this.account.birthdate", this.account.birthdate);
      console.log("nao birthdate", birthdate);
      console.log("nao birthdate.getDate", birthdate.getDate());

      if (today.getMonth() == birthdate.getMonth()) {
        if (today.getDate() == birthdate.getDate()) {
          return '<img border="0" alt="red" src="/resource/iconics/images/cakered2.png">';
        } else if (
          birthdate.getDate() - today.getDate() <= 7 &&
          birthdate.getDate() - today.getDate() > 0
        ) {
          return '<img border="0" alt="yellow" src="/resource/iconics/images/cakeyellow2.png">';
        } else if (
          birthdate.getDate() - today.getDate() <= 14 &&
          birthdate.getDate() - today.getDate() > 7
        ) {
          return '<img border="0" alt="green" src="/resource/iconics/images/cakegreen2.png">';
        }
      }
    }
  }

  calculateAge(birthday) {
    // birthday is a date
    var ageDifMs = Date.now() - birthday.getTime();
    var ageDate = new Date(ageDifMs); // miliseconds from epoch
    return Math.abs(ageDate.getUTCFullYear() - 1970);
  }

  get titleBirthdate() {
    if (!this.dreamAccountClient) {
      return this.account.birthdate + " (age " + this.account.age + ")";
    }

    return (
      dateFormat2(
        this.account.birthdate.split("-")[0],
        this.account.birthdate.split("-")[1],
        this.account.birthdate.split("-")[2]
      ) +
      " (age " +
      this.calculateAge(new Date(this.account.birthdate)) +
      ")"
    );
    // return  this.account.birthdate + ' (age ' +this.calculateAge( new Date(this.account.birthdate)) + ')';
  }

  get storeIcon() {
    return imagesResource + "/images/client360/storeIcon.svg";
  }
  get accountIcon() {
    return imagesResource + "/images/client360/accountIcon.svg";
  }
  get starIcon() {
    return imagesResource + "/images/client360/starIcon.svg";
  }
  get calendarIcon() {
    return imagesResource + "/images/client360/calendarIcon.svg";
  }
  get phoneIcon() {
    return imagesResource + "/images/client360/phoneIcon.svg";
  }
  get textIcon() {
    return imagesResource + "/images/client360/textIcon.svg";
  }
  get emailIcon() {
    return imagesResource + "/images/client360/emailIcon2.svg";
  }
  get homeIcon() {
    return imagesResource + "/images/client360/homeIcon.svg";
  }

  get editIcon() {
    return imagesResource + "/images/client360/editIcon.svg";
  }
  get newsletterIcon() {
    return imagesResource + "/images/client360/newsletterIcon.svg";
  }
  get bellIcon2() {
    return imagesResource + "/images/client360/bellIcon2.svg";
  }

  get getFirstPurchaseDate() {
    console.log("nao purchase date", this.account.firstPurchaseDate);
    if (!this.dreamAccountClient) {
      return dateFormat(this.account.firstPurchaseDate);
    } else {
      return dateFormat2(
        this.account.firstPurchaseDate.split("T")[0].split("-")[0],
        this.account.firstPurchaseDate.split("T")[0].split("-")[1],
        this.account.firstPurchaseDate.split("T")[0].split("-")[2]
      );
    }
  }
  get getLastPurchaseDate() {
    if (!this.dreamAccountClient) {
      return this.account.lastPurchaseDate;
    } else {
      return dateFormat2(
        this.account.lastPurchaseDate.split("T")[0].split("-")[0],
        this.account.lastPurchaseDate.split("T")[0].split("-")[1],
        this.account.lastPurchaseDate.split("T")[0].split("-")[2]
      );
    }
  }
  get getLastContact() {
    if (!this.dreamAccountClient) {
      return this.account.lastContact;
    } else {
      return dateFormat2(
        this.account.lastContact.split("T")[0].split("-")[0],
        this.account.lastContact.split("T")[0].split("-")[1],
        this.account.lastContact.split("T")[0].split("-")[2]
      );
    }
  }
  get getLastActivity() {
    if (!this.dreamAccountClient) {
      return this.account.lastActivityDate;
    } else {
      return dateFormat2(
        this.account.lastActivityDate.split("T")[0].split("-")[0],
        this.account.lastActivityDate.split("T")[0].split("-")[1],
        this.account.lastActivityDate.split("T")[0].split("-")[2]
      );
    }
  }

  handleIndicatorMouserEnter(event) {
    switch (event.currentTarget.dataset.value) {
      case "pendingAnswers":
        this.showPendingAnswers = true;
        this.showPendingCareService = false;
        this.showPendingComplaints = false;
        this.showResolvedComplaints = false;
        this.showPendingSurveys = false;
        break;
      case "pendingCareService":
        this.showPendingAnswers = false;
        this.showPendingCareService = true;
        this.showPendingComplaints = false;
        this.showResolvedComplaints = false;
        this.showPendingSurveys = false;
        break;
      case "pendingComplaints":
        this.showPendingAnswers = false;
        this.showPendingCareService = false;
        this.showPendingComplaints = true;
        this.showResolvedComplaints = false;
        this.showPendingSurveys = false;
        break;
      case "resolvedComplaints":
        this.showPendingAnswers = false;
        this.showPendingCareService = false;
        this.showPendingComplaints = false;
        this.showResolvedComplaints = true;
        this.showPendingSurveys = false;
        break;
      case "surveysPending":
        this.showPendingAnswers = false;
        this.showPendingCareService = false;
        this.showPendingComplaints = false;
        this.showResolvedComplaints = false;
        this.showPendingSurveys = true;
        break;
      default:
      // code block
    }
  }
  handleIndicatorMouserLeave() {
    this.showPendingAnswers = false;
    this.showPendingCareService = false;
    this.showPendingComplaints = false;
    this.showResolvedComplaints = false;
    this.showPendingSurveys = false;
  }

  goToCA() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.account.OwnerID,
        objectApiName: "User",
        actionName: "view"
      }
    });
  }

  goToStore() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.account.StoreID,
        objectApiName: "Store",
        actionName: "view"
      }
    });
  }

  navigateToAccount(event) {
    if (!this.dreamAccountClient) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.accountId,
          objectApiName: "Account",
          actionName: "view"
        }
      });
    }
  }

  displayCloseTooltip_LV(event) {
    let targetId = event.target.dataset.targetId;
    let target = this.template.querySelector(`[data-id="${targetId}"]`);
    target.className = target.className.includes("slds-hide")
      ? target.className.replace("slds-hide", "")
      : target.className + "slds-hide";
  }

  handleEdit() {
    this.dispatchEvent(new CustomEvent("editaccount", { detail: this.accountId }));
  }

  handleSearch() {
    console.log("handleSearch dream child");
    this.dispatchEvent(new CustomEvent("searchaccount", { detail: this.accountId }));
  }

  get isButtonDisplay() {
    return;
  }

  handleAccountView() {
    console.log("handleaccountView dream child " + this.accountId);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.accountId,
        objectApiName: "Account",
        actionName: "view"
      }
    });
  }
}