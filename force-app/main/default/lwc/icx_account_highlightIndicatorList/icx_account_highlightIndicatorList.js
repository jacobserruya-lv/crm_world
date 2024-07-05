import { LightningElement, api, track, wire } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import getIndicatorList from '@salesforce/apex/ICX_CaseDataServiceControllerLC.getIndicatorList';

import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

export default class Icx_account_highlightIndicatorList extends LightningElement {
    @api accountId;
    @api widthXSmall = false;
    @track indicatorList; // track decorator mandatory to display data in local environment

    //@api flexipageRegionWidth;
    @api width; // flexipageRegionWidth doesn't work, maybe because this LWC is inside another component

    followupRequestList = [];
    pendingAnswerList = [];
    //profileName;
    showCscIndicator = false;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILE_NAME_FIELD]
    }) wireuser({error, data}) {
        if (error) {
            console.log("error", error);
           //this.error = error ; 
        } else if (data) {
            //this.profileName = data.fields.Profile.displayValue;
            this.showCscIndicator = data.fields.Profile.displayValue.startsWith("ICONiCS") || data.fields.Profile.displayValue.startsWith("System");
           // this.currentUserProfile = data.fields.Email.value;
        }
    }

    connectedCallback() {
        console.log('accountId', this.accountId);
        if (this.accountId) {
            getIndicatorList({
                recordId : this.accountId
            })
            .then(result => {
                console.log('result', result);

                // Workaround : get care duration
                for (var key in result.careList) {
                    let careItem = result.careList[key];
                    careItem.Duration = this.getDurationInDays(careItem.CreatedDate);
                    careItem.label = (careItem.SKU__c === undefined ? careItem.Product_Sku_unknown__c : careItem.SKU__c + ' - ' + careItem.Product_Name__c);
                }

                for (var key in result.openMessagingList) {
                    let messagingItem = result.openMessagingList[key];
                    //messagingItem.Duration = this.getDurationInDays(messagingItem.CreatedDate);
                    this.pendingAnswerList.push(messagingItem);
                }

                /*let complaintWrapper = [];
                for (var key in result.complaintList) {
                    let complaintList = result.complaintList[key];
                    complaintWrapper.push(this.generateWrapper(complaintList));
                }
                result.complaintList = complaintWrapper;*/

                for (var key in result.openCaseList) {
                    let openCase = result.openCaseList[key];
                    if (openCase.record.Resolution__c === 'Request to Store' || openCase.record.RecordType.DeveloperName === 'Operation_Exception') {
                        //this.followupRequestList.push(this.generateWrapper(openCase));
                        this.followupRequestList.push(openCase);
                    } else {
                        //this.pendingAnswerList.push(this.generateWrapper(openCase));
                        this.pendingAnswerList.push(openCase);
                    }
                }
                result.followupRequestList = this.followupRequestList;

                // Sort by date
                this.pendingAnswerList.sort(function(a,b){
                    // Turn your strings into dates, and then subtract them
                    // to get a value that is either negative, positive, or zero.
                    return new Date(b.record.CreatedDate) - new Date(a.record.CreatedDate);
                  });
                result.pendingAnswerList = this.pendingAnswerList;

                this.indicatorList = result;
            })
            .catch(error => {
                console.log("Error", error);
            });
        }
    }

    /*generateWrapper(record) {
        let result;
        if (record.Id.startsWith("500")) {
            // Case record
            result = {
                id : record.Id,
                record : record,
                label : record.CaseNumber + ' - ' + record.Status,
                image : record.Case_Origin_IMG__c,
                age : record.Request_Age__c,
                subLabel : (record.RecordType.DeveloperName === 'Call_Case' || record.RecordType.DeveloperName === 'Web_Email_Case' ? '' : record.RecordType.Name)
            }
        } else {
            // MessagingSession record (starts by "0Mw")
            result = {
                id : record.Id,
                record : record,
                label : record.Name + ' - ' + record.Status,
                image : '<img src="/resource/iconics/images/channel/messaging.jpg" alt="Messaging" style="height:30px; width:30px;" border="0"/>', // record.ChannelType
                age : record.Duration,
                subLabel : record.ChannelType
            }
        }
        return result;
    }*/

    handleOpenCasesMouseEnter(event) {
        //console.log("handleOpenCasesMouseEnter");
        //let popup = this.template.querySelector('c-icx_account_highlight-indicator-popup');
        //console.log("popup", popup);
        this.template.querySelector('c-icx_account_highlight-indicator-popup').classList.remove('slds-hide');
    }

    handleOpenCasesMouseLeave(event) {
        //console.log("handleOpenCasesMouseLeave");
        //let popup = this.template.querySelector('c-icx_account_highlight-indicator-popup');
        //console.log("popup", popup);
        this.template.querySelector('c-icx_account_highlight-indicator-popup').classList.add('slds-hide');
    }

    get classAlignSmall() {
        return (this.widthXSmall == true || this.width === 'XLARGE' ? '' : 'slds-col highlight-indicator-list__wrapper slds-size_6-of-12 slds-m-bottom_medium');
     }
    get classWrapperList() {
        return (this.widthXSmall == true || this.width === 'XLARGE' ? 'highlight-indicator-list__wrapper_vertical' : 'highlight-indicator-list__wrapper_horizontal');
    }
    get classTopSize() {
        return (this.widthXSmall == true || this.width === 'XLARGE' ? 'slds-size_6-of-12' : '');
     }
    get classSize() {
       return (this.widthXSmall == true || this.width === 'XLARGE' ? 'slds-size_6-of-12' : 'slds-m-top_x-small');
    }
    get classIndicator() {
        return 'highlight-indicator-list__wrapper highlight-indicator-list__wrapper_vertical ';// + (this.widthXSmall == true ? 'xsmall-top' : '');
    }
    get classSubName() {
        return 'highlight-indicator-list__indicator slds-truncate ' +
            (this.indicatorList.openCaseList.length > 0 ? ' highlight-indicator-list__indicator_priority_med' : '') +
           // (this.widthXSmall == false && (this.width === 'LARGE' || this.width === 'XLARGE') ? ' slds-size_6-of-12' : '');
            (this.widthXSmall == false ? ' slds-size_6-of-12' : '');
    }
    get classIndicatorNumber() {
        return 'highlight-indicator-list__value ' + (this.widthXSmall == true ? 'highlight-indicator-list__value_xsmall' : (this.width === 'SMALL' || this.width === 'MEDIUM' ? 'slds-p-top_xx-small' : ''));
    }
    get classComplaints() {
        return 'highlight-indicator-list__indicator slds-truncate ' + (this.indicatorList.complaintList.length > 0 ? ' highlight-indicator-list__indicator_priority_high ' +  (this.widthXSmall == false ? ' slds-size_6-of-12' : '') : ' slds-hide');
    }
    get classCareService() {
        return 'highlight-indicator-list__wrapper ' + ((this.widthXSmall == true || this.width === 'LARGE' || this.width === 'XLARGE') ? ' highlight-indicator-list__wrapper_vertical ' + (this.widthXSmall == true ? 'xsmall-top' : '') : '');
    }
    get classCareServiceSub() {
        return 'highlight-indicator-list__indicator' + (this.indicatorList.careList.length > 0 ? ' highlight-indicator-list__indicator_priority_med' : '');
    }
    get showIndicatorSmallWidthForCSC() {
        return this.widthXSmall && this.showCscIndicator;
    }
    get isComplaintEmpty() {
        return this.indicatorList.complaintList.length > 0;
    }
    get showOpenCaseListEmpty() {
        return this.showCscIndicator == false && this.indicatorList.openCaseList.length > 0;
    }
    get showFollowupRequestList() {
        return this.showCscIndicator == true && this.indicatorList.followupRequestList.length > 0;
    }
    get showPendingAnswerList() {
        return this.showCscIndicator == true && this.indicatorList.pendingAnswerList.length > 0;
    }
    get showCareListSmallWidth() {
        return this.widthXSmall == true && this.indicatorList.careList.length > 0;
    }
    get showCareListNotSmallWidth() {
        return this.widthXSmall == false && this.indicatorList.careList.length > 0;
    }
            
    getDurationInDays(createdDate) {
        var oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds
        var today = new Date();
        var secondDate = new Date(createdDate);

        var diffDays = Math.round(Math.abs((today.getTime() - secondDate.getTime())/(oneDay)));
		//console.log("diffDays", diffDays);
        return diffDays;
    }
}