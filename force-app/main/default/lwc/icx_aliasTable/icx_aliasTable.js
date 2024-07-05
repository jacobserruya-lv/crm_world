import { api, LightningElement, track, wire } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import getAliases from '@salesforce/apex/ICX_Client360_SF.getAliases';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import { NavigationMixin } from 'lightning/navigation';

export default class Icx_aliasTable extends NavigationMixin(LightningElement)  {
    @track tableData = [];
    isWithSubtitles = true;
    objectName = 'Alias_Member__c';
    condition = 'WHERE Client__c  =: accountId';
    @track recordsListlength=0;
    @api sfRecordId;

    @wire(getrecordsListSize,{accountId:'$sfRecordId' ,objectName:'$objectName',condition:'$condition'})
    wiredListSize({error,data}){ 
        if(data)
        {
           this.recordsListlength = data;
           console.log('The length of the  Alias records list',JSON.stringify(this.recordsListlength));
        }
        if (error) {
            console.error('No results',error);
        }
    }

    @wire(getAliases, { accountId: '$sfRecordId' })
    wiredAlias({ error, data }) {

        if (data) {

                console.log(' alias data', data)
            this.tableData.title = {
                type: 'text',
                label: 'Alias',
                iconSrc: imagesResource + `/images/client360/aliasIcon.svg`,
                isWithIcon: true,
                isHeader: true,
                hasLength: true,
                length: this.recordsListlength,
                titleClass: 'title-bold title-navigation cursor-pointer',

            }

            this.tableData.rows = data.map(alias => {
                return alias = [
                    { value: alias.Alias__r?.Name, type: 'text', label: 'Alias Name' },
                    { value: alias.Alias__r?.Status__c, type: 'text', label: 'Status' },
                ]
            });
            this.tableData.idList = data.map(alias => alias.Alias__r?.Id);
            console.log('Allaiasse',JSON.stringify( this.tableData.idList));

        }

        if (error) {
            console.error(error);
        }
    }

    navigateToAlias(event)
    {
        let aliasId = this.tableData.idList[event.detail];
        console.log('ugvsd',aliasId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: aliasId,
                objectApiName:'Alias__c',
                // relationshipApiName: 'Alias_Member__r',
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
              relationshipApiName: 'Alias_Members__r',
              actionName: 'view'
            },
        });
    }
}