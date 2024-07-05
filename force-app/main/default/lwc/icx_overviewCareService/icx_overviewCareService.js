import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import {
    profilesCheckout
} from 'c/utils';
import imagesResource from '@salesforce/resourceUrl/iconics';
import USER_ID from '@salesforce/user/Id';
import getUserProfileId from '@salesforce/apex/ICX_Client360_SF.getUserProfileId';
import { NavigationMixin } from 'lightning/navigation';
import getUserInfo from '@salesforce/apex/ICX_Account_Highlight.getUserInfo';
import getCareServiceRecords from '@salesforce/apex/ICX_Client360_SF.getCareServiceRecords';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
//import getGeneralCareService from '@salesforce/apex/ICX_Client360_SF.getGeneralCareService';





export default class Icx_overviewCareService extends NavigationMixin(LightningElement) {

    @api sfRecordId;
    @track generalCareServicelist = [];
    @track tableDataGeneralCareService = [];
    createNewSpacialButton;
    careServiceLimit = 3;
    careServiceOffset = 0;
    objectName = 'CareService__c';
    condition = 'WHERE Client__c =: accountId';
    @track recordsListlength = 0;


    @wire(getrecordsListSize,{accountId:'$sfRecordId' ,objectName:'$objectName',condition:'$condition'})
    wiredListSize({error,data}){ 
        console.log('The length of the  CARE SERVICE records list',data);
        if(data)
        {
           this.recordsListlength = data;
           console.log('inside care service',JSON.stringify(this.recordsListlength));
           console.log('The length of the records list',JSON.stringify(data));
        }
        if (error) {
            console.error('No results',error);
        }
    }

handleResultCareService(result,listCareService)
{
    for (let i = 0; i < result.length; i++) {
        listCareService.push(result[i]);
        for(let j=0; j<listCareService[i].item.length; j++)
        {
        

            if(listCareService[i].item[j].type=='image-html' &&  new DOMParser().parseFromString(listCareService[i].item[j].value, "text/html").querySelector("img").getAttribute('src')==' ' )
            {

                listCareService[i].item[j].value='<img src="https://fr.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louis%20vuitton--12345_PM2_Front%20view.jpg" alt="image not available" style="height:100px; width:100px;" border="0"/>';
                console.log(listCareService[i].item[j].value);
            }
        }
    }
}

    @wire(getCareServiceRecords, {accountId: '$sfRecordId' ,myLimit:'$careServiceLimit' ,myOffset:'$careServiceOffset',type:'ALL'})
    wiredCareServiceRecords({error,data}) {
        console.log('  data', data);

        if (data) {
            let tempResult = JSON.parse(JSON.stringify(data)); //need to create a deep copy to be able to change the value wich is in read only in the result
            this.handleResultCareService(tempResult, this.generalCareServicelist);
 
            console.log('Care Now',this.generalCareServicelist);
            this.isDataRecords = true;

            console.log(' data care service', data);
            console.log('listGeneralCareService on wire', JSON.stringify(this.generalCareServicelist));

        }

        if (error) {
            console.error(' error ',error);
        }
        this.tableDataGeneralCareService.title = {
            type: 'text',
            label: 'Care Service',
            iconSrc: imagesResource + `/images/client360/careServiceIcon.svg`,
            isWithIcon: true,
            hasLength: true,
            titleClass: 'title-bold title-navigation cursor-pointer',
            length: this.recordsListlength,
            recordId: '$sfRecordId',
            isHeader: true,
            // titleClass: 'title-bold',

        }
    }



    
    @wire(getUserInfo, {  userId: USER_ID})
    wiredgetUserInfo({   error,   data }) {


        if (data) {

            this.userDetails = data;
            this.error = undefined;

            if ((this.userDetails && this.userDetails.Profile.Name.includes('ICONiCS')) || this.userDetails && this.userDetails.Profile.Name.includes('Admin')) {
                this.createNewSpacialButton = true;
                console.log('The value is :', this.createNewSpacialButton);

            } else if (this.userDetails && (this.userDetails.Profile.Name.includes('ICON_Corporate') || this.userDetails.Profile.Name.includes('ICON_SA Manager') || this.userDetails.Profile.Name.includes('ICON_SAManager'))) {
                this.createNewSpacialButton = false;
                console.log('The value is :', this.createNewSpacialButton);
            }

        } else if (error) {
            this.error = error;

            console.log(' error', this.error);

        }

        this.createNewSpacialButton = false; //they don't want to see the new
    }







    navigateToCareServiceFlow(event)
    {
        console.log('Navigate to care service flow');
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__ICX_DistantCareServiceFlowLuanch',
            },
            state: {
                c__accountId: this.sfRecordId,
                c__sObject: 'Account' ,
                c__recordId: null
    
             }
        });

    }

    navigateToCareService(event){
        let careServiceId = this.generalCareServicelist[event.detail].Id;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: careServiceId,
                    objectApiName: 'CareService__c',
                    actionName: 'view'
                },
            });
     }


     handelViewNavigation()
     {
        console.log('dinamic table is on ');
         this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.sfRecordId,
                objectApiName: 'Account',
                relationshipApiName: 'Care_Services__r',
                actionName: 'view'
            },
        });
     }

     


}