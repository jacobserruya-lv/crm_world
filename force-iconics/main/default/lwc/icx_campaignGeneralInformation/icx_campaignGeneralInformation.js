import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListCount, getRelatedListRecords } from 'lightning/uiRelatedListApi';
import USER_ID from '@salesforce/user/Id';
import CAMPAIGNID_FIELD from "@salesforce/schema/CampaignMember__c.Campaign__c";
import Icx_addSkuModal from 'c/icx_addSkuModal';
import isManagerUser from '@salesforce/apex/ICX_CampaignListViewController.isManagerUser';
// import DESCRIPTION_FIELD from "@salesforce/schema/Campaign__c.Description__c";
// import TOOLKITCOMMENTS_FIELD from "@salesforce/schema/Campaign__c.ToolkitComments__c";
// import STATUS_FIELD from "@salesforce/schema/Campaign__c.Status__c";
// import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
// import PROFILE_NAME_FIELD from '@salesforce/schema/ContentDocument.';




export default class Icx_campaignGeneralInformation extends LightningElement {
    @api recordId;
    @track campaignMemberId;
    @track campaignLookupId;
    @api objectApiName;
    isProductSkuTab;



    @wire(getRecord, {
        recordId: "$campaignMemberId",
        fields: [CAMPAIGNID_FIELD]
    }) wirecampaign({ error, data }) {
        if (data) {

            this.campaignLookupId = getFieldValue(data, CAMPAIGNID_FIELD);
            console.log('nao campaignLookupId', this.campaignLookupId);


        } else if (error) {
            console.error('error get campaign', error);
        }
    }

    @wire(isManagerUser, {})
    wiredManagerUser({ error, data }) {
        if (data) {
            this.isManager = data;
        } else if (error) {
            console.log('there is an error: ' + error);
        }
    }


    connectedCallback() {
        console.log('nao general info objectApiName', this.objectApiName);
        if (this.objectApiName == 'CampaignMember__c') {
            this.campaignMemberId = this.recordId;
        }

    }

    get campaignId() {
        return this.campaignMemberId ? this.campaignLookupId ? this.campaignLookupId : null : this.recordId;
    }

    handleActive(event) {
        if (event.target.value == 'productsSku' && this.isManager) this.isProductSkuTab = true;
        else this.isProductSkuTab = false;
    }

    async handleAddSku() {
        const res = await Icx_addSkuModal.open({
            campaignId: this.recordId,
            size: 'large'
        })
    }

}