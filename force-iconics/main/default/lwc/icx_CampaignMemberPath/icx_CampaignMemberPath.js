import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import CAMPAIGN_MEMBER_OBJECT from '@salesforce/schema/CampaignMember__c';
import STATUS_FIELD from '@salesforce/schema/CampaignMember__c.Status__c';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isManagerUser from '@salesforce/apex/ICX_CampaignListViewController.isManagerUser';
const fields = [ STATUS_FIELD ];


export default class Icx_CampaignMemberPath extends LightningElement {
    @api recordId;
    @api currentStatus; 

    @track isManager;
    @track memberRecordTypeId;
    @track pathValues = [];
    isLoading = false;
    @track showDescription = false;

    @wire(isManagerUser, {})
    wiredManagerUser({error, data}){
        if(data){
            this.isManager = data;
        }else if(error){
            console.log('there is an error: '+ error);
        }
    }

    @wire(getRecord, {recordId: '$recordId', fields})
    wiredRecord({error, data}){
        if(data){
            this.currentStatus = getFieldValue(data, STATUS_FIELD);
        }else if(error){
            console.log('error: ' + error);
        }
    }

    @wire(getObjectInfo, {objectApiName: CAMPAIGN_MEMBER_OBJECT})
    wiredObject({error, data}){
        if(data){
            this.memberRecordTypeId = data.defaultRecordTypeId;
        }
    }

    @wire(getPicklistValuesByRecordType, {objectApiName: 'CampaignMember__c', recordTypeId: '$memberRecordTypeId'})
    wiredPickList({error, data}){
        if(data && data.picklistFieldValues){
            let allValues = data.picklistFieldValues['Status__c'];
            this.pathValues = [];
            allValues.values
            .filter(option => option.label !== 'Cancelled')
            .map(option=>{
                this.pathValues.push({
                    label : option.label,
                    value : option.value
                });
            });

            if(this.currentStatus === 'Cancelled' || this.isManager){
                this.pathValues.push({
                    label : 'Cancelled',
                    value : 'Cancelled'
                })
            }

        }else if(error){
            console.log('error: ' + JSON.stringify(error));
        }
    }

    handleOpenDescription(){
        this.showDescription = true;
    }

    handleCloseDescription(){
        this.showDescription = false;
    }

    handleSelect(event){
        this.currentStatus = event.target.value;
        console.log('event: '+ JSON.stringify(this.currentStatus));
    }

    get statusDescription(){
        switch (this.currentStatus){
            case 'New':
                return 'The status is set to \'new\' when a client is added to the campaign and has not yet been contacted.';
            case 'Pending':
                return 'The status is \'pending\' if the client has been contacted and another action is awaiting completion. For example: following up with the client or waiting for the client\'s response. (manual action)'
            case 'Completed':
                return 'The status is \'completed\' when the client has been contacted, the \'Campaign Follow-Up\' section is filled out, and there are no further actions pending. (manual action)'
            case 'Cancelled':
                return 'The campaign is cancelled.'
        }
    }

    handleChangeStatus(){
        this.isLoading = true;
        const fields = {
            'Id': this.recordId,
            'Status__c': this.currentStatus
        };
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(()=> {
            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Status is changed sucessfully!',
                variant: 'success',
            });
            document.dispatchEvent(evt);
        })
        .catch((error)=>{
            const evt = new ShowToastEvent({
                title: 'Error updating record',
                message: error.body.message,
                variant: 'error',
            });
            document.dispatchEvent(evt);
        })
        .finally(()=>{
            this.isLoading = false;
        })
    }

}