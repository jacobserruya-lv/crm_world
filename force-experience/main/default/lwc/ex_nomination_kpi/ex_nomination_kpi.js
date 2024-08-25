import { LightningElement, api, wire } from 'lwc';
import {  getRecord, getFieldValue } from "lightning/uiRecordApi";

import TARGET_CLIENT_FIELD from "@salesforce/schema/Brand_Experience_Variation__c.Nb_Target_Clients__c";
import NOMINATED_CLIENT_FIELD from "@salesforce/schema/Brand_Experience_Variation__c.Nb_Nominated_Clients__c";
import CONFIRMED_CLIENT_FIELD from "@salesforce/schema/Brand_Experience_Variation__c.Nb_Confirmed_Clients__c";
import APPOINTMENTS_FIELD from "@salesforce/schema/Brand_Experience_Variation__c.Nb_Appointment__c";


import GLOBAL_TARGET_CLIENT_FIELD from "@salesforce/schema/Brand_Experience__c.Global_Nb_Target_Clients__c";
import GLOBAL_NOMINATED_CLIENT_FIELD from "@salesforce/schema/Brand_Experience__c.Global_Nb_Nominated_Clients__c";
import GLOBAL_CONFIRMED_CLIENT_FIELD  from "@salesforce/schema/Brand_Experience__c.Global_Nb_Confirmed_Clients__c";
import GLOBAL_APPOINTMENTS_FIELD  from "@salesforce/schema/Brand_Experience__c.Global_Nb_Appointment__c";



const variationFields = [TARGET_CLIENT_FIELD, NOMINATED_CLIENT_FIELD, CONFIRMED_CLIENT_FIELD, APPOINTMENTS_FIELD];
const experienceFields = [GLOBAL_TARGET_CLIENT_FIELD, GLOBAL_NOMINATED_CLIENT_FIELD, GLOBAL_CONFIRMED_CLIENT_FIELD, GLOBAL_APPOINTMENTS_FIELD];

export default class Ex_nomination_kpi extends LightningElement {

    @api recordId;
    @api firstCounterFieldName;
    @api secondCounterFieldName;
    @api title;
    @api objectApiName;

    @wire(getRecord, { recordId: "$recordId", fields: experienceFields })
    recordExperience;

    @wire(getRecord, { recordId: "$recordId", fields: variationFields })
    recordVariation;

    get firstCounter() {
        return getFieldValue(this.record?.data, this.fieldMetaByName(this.firstCounterFieldName)) ?? 0;
    }

    get secondCounter() {
        return getFieldValue(this.record?.data, this.fieldMetaByName(this.secondCounterFieldName)) ?? 0;
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