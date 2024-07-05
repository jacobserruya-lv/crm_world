import { api, LightningElement, track, wire } from 'lwc';
import getFamilies from '@salesforce/apex/ICX_Client360_SF.getFamilies';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import imagesResource from '@salesforce/resourceUrl/iconics';
import { NavigationMixin } from 'lightning/navigation';

export default class Icx_familiesTable extends NavigationMixin(LightningElement) {
    @api sfRecordId;
    @api isNotWithPicture;
    listFamilies = [];
    tableFamilies = [];
    objectName = 'Family_Member__c';
    condition = 'WHERE Client__c =: accountId';
    recordsListlength=0;
    isLoading = true;


    @wire(getrecordsListSize,{accountId: '$sfRecordId', objectName :'$objectName', condition:'$condition'})
    wiredListSize({error,data}){ 
        if(data)
        {
           this.recordsListlength = data;
           console.log('The length of the records list family',JSON.stringify(this.recordsListlength));
        }
        if (error) {
            console.error('No results',error);
        }
    }

    @wire(getFamilies, { accountId: '$sfRecordId' })
    wiredFamilies({ error, data }) {

        if (data) {
            this.listFamilies = data
            console.log('Display familyData',JSON.stringify(data));
            console.log('Display familyList',JSON.stringify(this.listFamilies));
        }

        if (error) {
            console.error(error);
        }
        this.tableFamilies.title = {
            type: 'text',
            label: 'Families',
            iconSrc: imagesResource + `/images/client360/familiesIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            hasLength: true,
            length: this.recordsListlength,
            titleClass: 'title-bold title-navigation cursor-pointer',

    
        }
        this.isLoading = false;
    }

    connectedCallback()
    {
       

    }
    
    renderedCallback() {
        console.log('dans families')
      
    }

    navigateToFamilies(event)
    {
        let FamiliesId = this.listFamilies[event.detail].Id;
        //let FamiliesIdTest = this.listFamilies[event.detail].get('Id');
        console.log('not even here',FamiliesId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: FamiliesId,
                objectApiName: 'Family_Member__c',
                actionName: 'view'
            },
        });
    }

    
    navigateToViewListPage() {
        console.log('Try to navigate to a list')
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
            objectApiName: 'Account',
              recordId: this.sfRecordId,
              relationshipApiName: 'Family_Members__r',
              actionName: 'view'
            },
        });
    }
}