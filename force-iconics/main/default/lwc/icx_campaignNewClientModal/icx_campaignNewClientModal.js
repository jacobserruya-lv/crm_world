import { LightningElement, api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getRecord,getFieldValue,createRecord } from 'lightning/uiRecordApi';
import PREFERRED_CA_FIELD from"@salesforce/schema/Account.OwnerId";
import USER_ID from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import matchExistMember from '@salesforce/apex/ICX_CampaignClientCAListViewController.matchExistMember';

export default class Icx_campaignNewClientModal extends LightningModal {
    @api campaignId;
    @api isManager;
    @api userId = USER_ID;
    @track clientId;
    @track caId;
    
    
    @wire(getRecord, { recordId: "$clientId", fields: [PREFERRED_CA_FIELD]})
    wiredclient({error, data}){
        if(data){
            let preferredCAId = getFieldValue(data, PREFERRED_CA_FIELD);
            if(preferredCAId){
                this.caId = preferredCAId;
            }else{
                this.caId = (!isManager) ? this.userId : null;
            }      
        }else if(error){
            console.log('There is an error in getRecord: '+ error);
        }
    };

    handleClientId(event){
        this.clientId = event.target.value;
    }

    handleCAId(event){
        this.caId = event.target.value;
        console.log('caId: '+ this.caId);
    }

    handleClose(){
        this.close('okay');
    }

    async handleCreate(){
        const matchMember = await matchExistMember({AccountId: this.clientId, CampaignId: this.campaignId});
        console.log('matchMember ' + matchMember);

        if(matchMember === true){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'This client is already added in the campaign!',
                variant: 'error',
            });
            document.dispatchEvent(evt);
        }else if(matchMember === false){
            const fields = {
                'Member__c': this.clientId,
                'AssignedCA__c': this.caId,
                'Campaign__c': this.campaignId,
                'Status__c': 'New'
            };
    
            const recordInput = {
                apiName: 'CampaignMember__c',
                fields: fields
            };
    
            createRecord(recordInput)
            .then( rec => {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Campaign member is created!',
                    variant: 'success',
                });
                document.dispatchEvent(evt);
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'There is an error during creation: '+ JSON.stringify(error),
                    variant: 'error',
                });
                document.dispatchEvent(evt);
            });
    
            this.close('okay');
            location.reload(true);
        }
    }
}