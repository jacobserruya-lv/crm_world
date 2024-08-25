import { LightningElement,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getUserInfo from '@salesforce/apex/ICX_Account_Highlight.getUserInfo';
import iconics from '@salesforce/resourceUrl/iconics';
import { loadStyle } from 'lightning/platformResourceLoader';
import USER_ID from '@salesforce/user/Id';

import Name_FIELD from '@salesforce/schema/Account.Name';
import PersonEmail_FIELD from '@salesforce/schema/Account.PersonEmail';
import PersonMobilePhone_FIELD from '@salesforce/schema/Account.PersonMobilePhone';
import WorkPhone_FIELD from '@salesforce/schema/Account.Phone';
import PersonHomePhone_FIELD from '@salesforce/schema/Account.PersonHomePhone';
import RelationshipComment_FIELD from '@salesforce/schema/Account.Relationship_Comment__c';
import PersonBirthdate_FIELD from '@salesforce/schema/Account.PersonBirthdate';
import IsLifestyle_FIELD from '@salesforce/schema/Account.IsLifestyle__c';
import Gifts_offered_for_this_clilent_FIELD from '@salesforce/schema/Account.Gifts_offered_for_this_clilent__c';
import CreatedById_FIELD from '@salesforce/schema/Account.CreatedById';
import LastModifiedById_FIELD from '@salesforce/schema/Account.LastModifiedById';
import Age_FIELD from '@salesforce/schema/Account.Age_Calculator__c';
import segmentation_FIELD from '@salesforce/schema/Account.Segmentation_To_Display__c';
import CreatedDate_FIELD from '@salesforce/schema/Account.CreatedDate';
import LastModifiedDate_FIELD from '@salesforce/schema/Account.LastModifiedDate';
import OwnerId_FIELD from '@salesforce/schema/Account.OwnerId';
import DREAMID_FIELD from '@salesforce/schema/Account.DREAMID__c';
import WORLDWIDEID_FIELD from '@salesforce/schema/Account.WW_RMSId__c';





export default class Icx_ClientInformationSF extends LightningElement {
    recordId;
    authToEdit;
    objectApiName='Account';
    isUserIconics = false;
    isUserIcon = false;

    clientInformation = [Name_FIELD, OwnerId_FIELD,Age_FIELD,{"fieldApiName":"AttachedStore__pc","objectApiName":"Account" }, PersonBirthdate_FIELD, DREAMID_FIELD,{"fieldApiName":"Nationality__pc","objectApiName":"Account"},WORLDWIDEID_FIELD,{"fieldApiName":"PreferredContactChannel__pc","objectApiName":"Account" },{"fieldApiName":"PassportNumber__pc","objectApiName":"Account" }, 
                         segmentation_FIELD, {"fieldApiName":"ICONICS_Comment__pc","objectApiName":"Account" }, {"fieldApiName":"Typology__pc","objectApiName":"Account" }];

    otherUse = [{"fieldApiName":"PrimaryAddressLine1__pc","objectApiName":"Account" },{"fieldApiName":"Gender__pc","objectApiName":"Account" },{"fieldApiName":"PrimaryAddressLine2__pc","objectApiName":"Account" },
               {"fieldApiName":"PreferredLanguage__pc","objectApiName":"Account" },{"fieldApiName":"PrimaryAddressLine3__pc","objectApiName":"Account" },PersonEmail_FIELD,{"fieldApiName":"PrimaryZipCode__pc","objectApiName":"Account" },
               PersonMobilePhone_FIELD,{"fieldApiName":"PrimaryCity__pc","objectApiName":"Account" },WorkPhone_FIELD,{"fieldApiName":"PrimaryStateProvince__pc","objectApiName":"Account" },PersonHomePhone_FIELD,{"fieldApiName":"PrimaryCountry__pc","objectApiName":"Account" },
               {"fieldApiName":"Company__pc","objectApiName":"Account" },RelationshipComment_FIELD,PersonBirthdate_FIELD,IsLifestyle_FIELD,  {"fieldApiName":"Anniversary__pc","objectApiName":"Account" } ];

    fieldsOptIn = [{"fieldApiName":"Can_Be_Contacted_By_Phone__pc","objectApiName":"Account" },{"fieldApiName":"Can_Be_Contacted_By_Mail__pc","objectApiName":"Account" },{"fieldApiName":"Can_Be_Contacted_By_Email__pc","objectApiName":"Account" },{"fieldApiName":"Can_Be_Contacted_By_SMS__pc","objectApiName":"Account" }]
    fieldsEventGift = [{"fieldApiName":"Invited__pc","objectApiName":"Account" },Gifts_offered_for_this_clilent_FIELD];

    fieldSystemInfo = [CreatedById_FIELD,CreatedDate_FIELD,LastModifiedById_FIELD,LastModifiedDate_FIELD]

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
         console.log(' currentPageReference.state' , JSON.stringify(currentPageReference.state));
         this.recordId = currentPageReference.state?.c__accountId;
         this.authToEdit = currentPageReference.state?.c__authToEdit;
         
          console.log(' recordId client info', this.recordId);
       }
    }
 
   
    @wire(getUserInfo, { userId : USER_ID  })
   wiredgetUserInfo({ error, data }) {



       if (data) {
           
           this.userDetails = data;
           this.error = undefined;

           if (this.userDetails && this.userDetails.Profile.Name.includes('ICONiCS') ) {
            this.isUserIconics= true;
            this.isUserIcon= false;
        }else if(this.userDetails && (this.userDetails.Profile.Name.includes('ICON_Corporate')||this.userDetails.Profile.Name.includes('ICON_SA Manager') ||this.userDetails.Profile.Name.includes('ICON_SAManager'))) {
            this.isUserIconics= false;
            this.isUserIcon= true;
        }else if(this.userDetails && this.userDetails.Profile.Name.includes('Admin') ){
            this.isUserIconics= true;
            this.isUserIcon= true;
        }else{
            this.isUserIconics= false;
            this.isUserIcon= false;
        }

       } else if (error) {
           this.error = error;    

           console.log(' error',this.error);
           
       }

   }  


    connectedCallback()
    {
         loadStyle(this, iconics + 'styles/prechat-slds.min.css');
    }

    get getMode()
    {
        console.log('display the edit auth here',this.authToEdit);
        if(this.isUserIconics && this.authToEdit)
        {
            return 'view';
        }
        return 'readonly';
    }
  
}