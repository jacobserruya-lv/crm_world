import { LightningElement, wire, api, track } from 'lwc';
// import { getRelatedListRecords} from 'lightning/uiRelatedListApi';
import {getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getAttachedNote from '@salesforce/apex/OrderNoteService.getAttachedNote'
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import RMS_ID_FIELD from '@salesforce/schema/User.RMS_ID__c';
import ORDER_ID_FIELD from '@salesforce/schema/Order__c.Id';
import ORDERSHIPPING_ID_FIELD from '@salesforce/schema/OrderShipping__c.Id';

export default class Icx_orderComment extends LightningElement {
    @api 
    get recordid() {
        return this._recordid;
    }
    set recordid(recordid) {
        this.records = null;
        console.log('JGU-@api icx_orderComment - @api recordid : ' + recordid);
        this._recordid = recordid;
    }

    @api     
    get orderdetailsapi() {
        return this._orderdetailsapi;
    }
    set orderdetailsapi(orderdetailsapi) {
        //this.records = null;
        console.log('JGU-@api icx_orderComment - @api orderdetailsapi : ' + orderdetailsapi + '// recordId : ' + this.recordid);
        this._orderdetailsapi = orderdetailsapi;
        refreshApex(this.wiredCommentList);
    };

    @track _recordid;
    @track _orderdetailsapi;

    @track wiredCommentList;

    @track userId = USER_ID;
    error;
    records;
    pageSize = 1999;
    @track recordIdApiName;
    @track recordIdError;
    
    @track isLoading = false;
    _disabledPostComment = true;
    get disabledPostComment() { return this._disabledPostComment;}

    // Allow to manage dynamicly the height
    get commentHeight() {
        // if no records
        if(this.records.length==0){//set the minimum height
            return 'height:1rem;';
        }
        // if more than 2 records
        else if(this.records.length>2){//set the max height
                return 'height:12rem;';
        }
        // in other cases
        return '';//don't set any height (height will be dynamic)
    }

    // I didn't find a way to do work this string directly at the @wire level. (It's why i created this function...)
//     get wireWhereClause(){
//        return "{ and: [{Type__c: {eq: 'ATTACHED_NOTE'}},{ or: [ {and : [{Order__c: {eq: " + this.recordid + "}},{Order_Shipping__c: {eq: null}}]},{Order_Shipping__c: {eq: " + this.recordid +"}}]}]}";
//    }
   
   @wire(getAttachedNote, {recordId: "$recordid"}) 
   attachedNoteRecords(result) {
       this.wiredCommentList = result;

       console.log('JGU-@wire (attachedNoteRecords - id) : '+this.recordid);

       if (result.data) {
            console.log('JGU-@wire (attachedNoteRecords - result.data) : '+result.data);
            // console.log('JGU-@wire (dataLoading - before) : '+this.dataLoading);
            // console.log('JGU-@wire (dataLoading - data) : '+JSON.stringify(data));

            let tempRecords = [];

            result.data.forEach( obj => {
                let tempRecord = {};
                tempRecord.id = obj.id;
                // tempRecord.linkToCase = '/'+tempRecord.id;
                tempRecord.Description__c = obj.Description__c;
                // console.log('JGU-@wire (obj.fields.ClientAdvisor__r) : '+obj.fields.ClientAdvisor__r);
                // console.log('JGU-@wire (obj.fields.ClientAdvisor__r.value) : '+obj.fields.ClientAdvisor__r.value);
                // console.log('JGU-@wire (obj.fields.ClientAdvisor__r.value.fields) : '+obj.fields.ClientAdvisor__r.value.fields);
                // console.log('JGU-@wire (obj.fields.ClientAdvisor__r.value.fields.Name) : '+obj.fields.ClientAdvisor__r.value.fields.Name);
                // console.log('JGU-@wire (obj.fields.ClientAdvisor__r.value.fields.Name.value) : '+obj.fields.ClientAdvisor__r.value.fields.Name.value);
                if (obj.ClientAdvisor__r != null) {
                    tempRecord.ClientAdvisorName = obj.ClientAdvisor__r.Name;
                    if (obj.ClientAdvisor__r.RMS_ID__c) {
                        tempRecord.ClientAdvisorName = tempRecord.ClientAdvisorName + ' - ' + obj.ClientAdvisor__r.RMS_ID__c;
                    }
                }
                else tempRecord.ClientAdvisorName = 'CA unknown';
                tempRecord.createdDate = obj.CreatedDate;
                // tempRecord.status = obj.fields.Status.value;
                tempRecords.push( tempRecord );
            } );

            // Add retrieved records to the current list of records already displayed
            // if (this.records ==  null) this.records = tempRecords.reverse();
            // else this.records = (this.records.reverse().concat(tempRecords)).reverse();

            this.records = tempRecords.reverse();

            console.log('JGU-@wire (dataLoading - this.records) :'+ JSON.stringify(this.records));
            // this.currentpageToken = data.currentpageToken;
            // this.nextPageToken = data.nextPageToken;
            // this.hasMore = (this.nextPageToken != null);
            // this.error = undefined;

        } else if (result.error) {
            // console.log('JGU-@wire | error: '+ error );
            // console.log(error);
            this.error = 'Unknown error';
            if (Array.isArray(result.error.body)) {
                this.error = result.error.body.map(e => e.message).join(', ');
            } else if (typeof result.error.body.message === 'string') {
                this.error = result.error.body.message;
            }
            this.records = undefined;
        }
   }

    // @wire(getRelatedListRecords, {
    //     parentRecordId: "$recordid",
    //     relatedListId: 'Order_Notes__r',
    //     fields: ['Order_Note__c.Id', 'Order_Note__c.Description__c', 'Order_Note__c.ClientAdvisor__c', 'Order_Note__c.ClientAdvisor__r.Name', 'Order_Note__c.ClientAdvisor__r.RMS_ID__c', 'Order_Note__c.CreatedDate', 'Order_Note__c.Type__c'],
    //     sortBy : ['CreatedDate'],
    //     pageSize: '$pageSize',
    //     where: '$wireWhereClause'
    // })listInfo(result) {
    //     this.wiredCommentList = result;

    //     if (result.data) {
    //         console.log('JGU-@wire (dataLoading - id) : '+this.recordid);
    //         // console.log('JGU-@wire (dataLoading - before) : '+this.dataLoading);
    //         // console.log('JGU-@wire (dataLoading - data) : '+JSON.stringify(data));

    //         let tempRecords = [];

    //         result.data.records.forEach( obj => {
    //             let tempRecord = {};
    //             tempRecord.id = obj.id;
    //             // tempRecord.linkToCase = '/'+tempRecord.id;
    //             tempRecord.Description__c = obj.fields.Description__c.value;
    //             // console.log('JGU-@wire (obj.fields.ClientAdvisor__r) : '+obj.fields.ClientAdvisor__r);
    //             // console.log('JGU-@wire (obj.fields.ClientAdvisor__r.value) : '+obj.fields.ClientAdvisor__r.value);
    //             // console.log('JGU-@wire (obj.fields.ClientAdvisor__r.value.fields) : '+obj.fields.ClientAdvisor__r.value.fields);
    //             // console.log('JGU-@wire (obj.fields.ClientAdvisor__r.value.fields.Name) : '+obj.fields.ClientAdvisor__r.value.fields.Name);
    //             // console.log('JGU-@wire (obj.fields.ClientAdvisor__r.value.fields.Name.value) : '+obj.fields.ClientAdvisor__r.value.fields.Name.value);
    //             if (obj.fields.ClientAdvisor__r.value != null) {
    //                 tempRecord.ClientAdvisorName = obj.fields.ClientAdvisor__r.value.fields.Name.value;
    //                 if (obj.fields.ClientAdvisor__r.value.fields.RMS_ID__c.value) {
    //                     tempRecord.ClientAdvisorName = tempRecord.ClientAdvisorName + ' - ' + obj.fields.ClientAdvisor__r.value.fields.RMS_ID__c.value;
    //                 }
    //             }
    //             else tempRecord.ClientAdvisorName = 'CA unknown';
    //             tempRecord.createdDate = obj.fields.CreatedDate.value;
    //             // tempRecord.status = obj.fields.Status.value;
    //             tempRecords.push( tempRecord );
    //         } );

    //         // Add retrieved records to the current list of records already displayed
    //         if (this.records ==  null) this.records = tempRecords.reverse();
    //         else this.records = (this.records.reverse().concat(tempRecords)).reverse();

    //         console.log('JGU-@wire (dataLoading - this.records) :'+ JSON.stringify(this.records));
    //         // this.currentpageToken = data.currentpageToken;
    //         // this.nextPageToken = data.nextPageToken;
    //         // this.hasMore = (this.nextPageToken != null);
    //         // this.error = undefined;

    //     } else if (result.error) {
    //         // console.log('JGU-@wire | error: '+ error );
    //         // console.log(error);
    //         this.error = 'Unknown error';
    //         if (Array.isArray(result.error.body)) {
    //             this.error = result.error.body.map(e => e.message).join(', ');
    //         } else if (typeof result.error.body.message === 'string') {
    //             this.error = result.error.body.message;
    //         }
    //         this.records = undefined;
    //     }
    //     // this.dataLoading = false;
    //     // console.log('JGU-@wire (dataLoading - after) : '+this.dataLoading);
    // }

    @wire(getRecord, {
        recordId: "$userId",
        fields: [NAME_FIELD, RMS_ID_FIELD]
    }) wireuser({error, data}) {
        console.log('JGU-@wire (getRecord User - data) : '+JSON.stringify(data));
        // console.log('JGU-@wire (getRecord User - error) : '+JSON.stringify(error));
        if (error) {
           this.errorUser = error ; 
        } else if (data) {
            this.userName = data.fields.Name.value;
            if (data.fields.RMS_ID__c.value) this.userName = this.userName + ' - ' + data.fields.RMS_ID__c.value;
        }
    }

    @wire(getRecord, {
        recordId: "$recordid",
        optionalFields: [ORDER_ID_FIELD, ORDERSHIPPING_ID_FIELD]
    }) wireRecordId({error, data}) {
        console.log('JGU-@wire (getRecord wireRecordId-recordId) : '+this.recordid);
        console.log('JGU-@wire (getRecord wireRecordId-data) : '+JSON.stringify(data));
        console.log('JGU-@wire (getRecord wireRecordId-error) : '+JSON.stringify(error));

        // console.log('JGU-@wire (getRecord wireRecordId-ORDER_ID_FIELD) : '+getFieldValue(data, ORDER_ID_FIELD));
        // console.log('JGU-@wire (getRecord wireRecordId-ORDERSHIPPING_ID_FIELD) : '+getFieldValue(data, ORDERSHIPPING_ID_FIELD));

        if (error) {
            this.recordIdError = JSON.stringify(error) ; 
        } else if (data) {
            this.recordIdApiName = data.apiName;
        }
    }

    handleChangeDescription(event) {
        this._disabledPostComment = (event.target.value.trim() === '');
    }

    handleSubmit(event) {
        event.preventDefault();

        const fields = event.detail.fields;
        if (fields.Description__c) {
            if (this.recordIdApiName == 'Order__c') {
                fields.Order__c = this.recordid;
            }
            else {
                fields.Order_Shipping__c = this.recordid;
                fields.Order__c = this.orderdetailsapi.order_SF_Id;
            }

            fields.Type__c = 'ATTACHED_NOTE';
            fields.ClientAdvisor__c = this.userId;
            // console.log('JGU-submit comment');
            this.isLoading = true;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleSuccess(event) {
        let tempRecord = {};
        console.log('JGU-@wire (handleSuccess - data) : '+JSON.stringify(event.detail));
        tempRecord.id = event.detail.id.value;
        tempRecord.Description__c = event.detail.fields.Description__c.value;
        
        tempRecord.ClientAdvisorName = this.userName;
        tempRecord.createdDate = event.detail.fields.CreatedDate.value;
        
        // console.log('JGU-clear comment');
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        // console.log('JGU-refresh comments');
        this.records = [tempRecord].concat(this.records);
        this.isLoading = false;
    }

    handleError(event) {
        let message = event.detail.detail;
        //do some stuff with message to make it more readable
        message = "Something went wrong! Retry or contact an administrator";
        this.showToast(TOAST_TITLE_ERROR, message, TOAST_VARIANT_ERROR);
        this.clearEditMode();        
        this.isLoading = false;
    }

    showToast(theTitle, theMessage, theVariant) {
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
     this.dispatchEvent(event);
    }
}