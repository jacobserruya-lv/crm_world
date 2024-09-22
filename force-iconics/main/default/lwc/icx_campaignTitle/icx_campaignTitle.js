import { LightningElement, track, api, wire } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import CAMPAIGN_NAME_FIELD from "@salesforce/schema/Campaign__c.Name";
import CAMPAIGN_STATUS_FIELD from"@salesforce/schema/Campaign__c.Status__c";
import isManagerUser from '@salesforce/apex/ICX_CampaignListViewController.isManagerUser';
import Icx_campaignCancelModal from 'c/icx_campaignCancelModal';
import Icx_campaignNewClientModal from 'c/icx_campaignNewClientModal';

export default class Icx_campaignTitle extends LightningElement {
    @api recordId;
    @track isManager;
    @track campaignName;
    @track isCampaignCancelled = false;
    @track tabId;

    @wire(isManagerUser, {})
    wiredManagerUser({error, data}){
        if(data){
            this.isManager = data;
        }else if(error){
            console.log('there is an error: '+ error);
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: [CAMPAIGN_NAME_FIELD, CAMPAIGN_STATUS_FIELD]})
    wiredcampaign({error, data}){
        if(data){
            let campaignStatus = getFieldValue(data, CAMPAIGN_STATUS_FIELD);
            this.campaignName = getFieldValue(data, CAMPAIGN_NAME_FIELD);
            if(campaignStatus === 'Cancelled'){
                this.isCampaignCancelled = true;
            }
            
        }else if(error){
            console.log('There is an error in getRecord: '+ error);
        }
    };

    async handleCancel(){
        const res = await Icx_campaignCancelModal.open({
            recordId: this.recordId,
            size: 'small'
        })
    }

    async handleAddClient(){
        const res = await Icx_campaignNewClientModal.open({
            campaignId: this.recordId,
            isManager: this.isManager,
            size: 'small'
        })
    }

    get isShowCancelButton(){
        if(this.isManager && !this.isCampaignCancelled){
            return true;
        }else{
            return false;
        }
    }

}