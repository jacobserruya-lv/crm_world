import { LightningElement, api, wire } from 'lwc';
    import {  getRecord, getFieldValue } from "lightning/uiRecordApi";
    
    import VARIATION_GUEST from "@salesforce/schema/Brand_Experience_Variation__c.Nb_Guest__c";
    import EXPERIENCE_GUEST from "@salesforce/schema/Brand_Experience__c.Global_Nb_Guest__c";
    
    
    const variationFields = [VARIATION_GUEST];
    const experienceFields = [EXPERIENCE_GUEST];
    
    export default class Ex_guest_number extends LightningElement {
    
        @api recordId;      
        @api title;
        @api objectApiName;
        @api fieldName;
      
    
        @wire(getRecord, { recordId: "$recordId", fields: experienceFields })
        recordExperience;
    
        @wire(getRecord, { recordId: "$recordId", fields: variationFields })
        recordVariation;
    
        get myGuestNumber() {
            return getFieldValue(this.record?.data, this.fieldMetaByName(this.fieldName)) ?? 0;
        }
    
       
    
        fieldMetaByName(apiName){
            return this.fields?.find((item) => item.fieldApiName == apiName);
        }
    
        get record(){
            switch (this.objectApiName) {
                case 'Brand_Experience__c':
                    return this.recordExperience
                case 'Brand_Experience_Variation__c':
                    return this.recordVariation
                default:
                    return null;
            }
        }
    
         get fields(){
            switch (this.objectApiName) {
                case 'Brand_Experience__c':
                    return experienceFields ?? []
                case 'Brand_Experience_Variation__c':
                    return variationFields ?? []
                default:
                    return [];
            }
        }

       
    }