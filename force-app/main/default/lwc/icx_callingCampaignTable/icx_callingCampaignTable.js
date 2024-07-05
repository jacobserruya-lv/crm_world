import { api, LightningElement, track, wire } from 'lwc';
import getCallingCampaigns from '@salesforce/apex/ICX_Client360_SF.getCallingCampaigns';
import imagesResource from '@salesforce/resourceUrl/iconics';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import { NavigationMixin } from 'lightning/navigation';
import Time_Since_Last_Change__c from '@salesforce/schema/SPO_FirmOrder__ChangeEvent.Time_Since_Last_Change__c';

export default class Icx_callingCampaignTable extends NavigationMixin(LightningElement) {
    @api sfRecordId;
    @track listCallingCampaigns = [];
    @track tableCallingCampaigns = [];
    @track listCallingCampaignSize;
    @api editCalling;
    @api createCalling;
    @api deleteCalling;
    objectName = 'Calling_Campaign__c';
    condition = 'WHERE Client__c =: accountId';
    @api isViewMoreButton = false;

    @wire(getCallingCampaigns, { accountId: '$sfRecordId'})
    wiredCallingCampaigns({ error, data }) {

        if (data) {
            this.listCallingCampaigns = data

            console.log('barukh data',data);
            console.log('listCallingCampaigns',this.listCallingCampaigns);

        }

        if (error) {
            console.error(error);
        }
    }

    connectedCallback(){
        
        getrecordsListSize({accountId:this.sfRecordId,objectName:this.objectName,condition:this.condition})
        .then((result)=>
        {
            this.listCallingCampaignSize = result;
            console.log("Display the length of CallingCampaign List", this.listCallingCampaignSize);
            // this.listCallingCampaigns.length = this.listCallingCampaignSize;
            this.tableCallingCampaigns.title.length = this.listCallingCampaignSize;
            console.log("Display the length of CallingCampaign List for second time", this.tableCallingCampaigns.title.length );
        })
        .catch((error)=>
        {
            console.log('Display the error',error);
        });
        
        console.log('nao in calling campaign for created calling : ' , this.createCalling);
        this.tableCallingCampaigns.title = {
            type: 'text',
            label: 'Calling Campaigns',
            iconSrc: imagesResource + `/images/client360/callingCampaignIcon.svg`,
            titleClass: 'title-bold title-navigation cursor-pointer',
            isWithIcon: true,
            recordId:'$sfRecordId',
            isHeader: true,
            length:this.listCallingCampaignSize ,
            hasLength: true,
        }
    }

    renderedCallback() {
        
    }
    navigateToViewListPage() {
        console.log('Try to navigate to a list calling campaigns', this.sfRecordId)
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                objectApiName: 'Account',
                recordId: this.sfRecordId,
                relationshipApiName: 'Calling_Campaigns__r',
              actionName: 'view'
            },
        });
    }

    navigateToCreatePage() {
        console.log('Try to create a new record');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
              //recordId: sfRecordId,
              objectApiName: 'Calling_Campaign__c',
              actionName: 'new'
            },
        });
    }

    handleEditNavigation(event){
      
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: this.listCallingCampaigns[event.details].Id,
                objectApiName: 'Calling_Campaign__c',
                actionName: 'edit'
            },
        });
    }

      
    navigateToCallingCampaigns(event){
        let callingCampignsId = this.listCallingCampaigns[event.detail].Id;
        console.log("I just want to fount out callingCampaigns Activation");
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: callingCampignsId,
                    objectApiName: 'Calling_Campaign__c',
                    actionName: 'view'
                },
            });
     }

    // navigateToViewListPage() {

    //     consolee.log('Try to navigate to a List')
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__objectPage',
    //         attributes: {
    //           //recordId: sfRecordId,
    //           objectApiName: 'Calling_Campaign__c',
    //           actionName: 'view'
    //         },
    //     });
    // }
}