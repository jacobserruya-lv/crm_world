import { LightningElement, api, wire } from 'lwc';
import {  getRecord } from "lightning/uiRecordApi";
import getKPIValues from '@salesforce/apex/Ex_nomination_kpi_controller.getKPIValues';

import TARGET_CLIENT_FIELD from "@salesforce/schema/Brand_Experience_Variation__c.Nb_Target_Clients__c";


const variationFields = [TARGET_CLIENT_FIELD];

export default class Ex_nomination_kpi extends LightningElement {

    @api recordId;
    @api firstCounterFieldName;
    @api secondCounterFieldName;
    @api title;
    @api objectApiName;
    
    get fieldList() {
        let lst = [];
        this.firstCounterFieldName ? lst.push(this.firstCounterFieldName) : null;
        this.secondCounterFieldName ? lst.push(this.secondCounterFieldName) : null;
        console.log('field list', lst);
        return lst;
    }
    @wire(getRecord, { recordId: "$recordId", fields: variationFields })
    recordVariation;

    @wire(getKPIValues, { recordId: "$recordId", objectApiName: "$objectApiName", fields: "$fieldList" })
    kpiMap;

    get firstCounter() {
        if(this.firstCounterFieldName == undefined)
            return undefined;
        if(this.fieldMetaByName(this.firstCounterFieldName))
            return this.recordVariation.data && this.recordVariation.data.fields[this.firstCounterFieldName]?.value != null ? this.recordVariation.data.fields[this.firstCounterFieldName]?.value : 0;
        return (this.kpiMap.data && this.kpiMap.data[this.firstCounterFieldName]) ?? 0;
    }
    get secondCounter() {
        if(this.secondCounterFieldName == undefined)
            return undefined;
        if(this.fieldMetaByName(this.secondCounterFieldName))
            return this.recordVariation.data && this.recordVariation.data.fields[this.secondCounterFieldName]?.value != null ? this.recordVariation.data.fields[this.secondCounterFieldName]?.value : 0;
        return (this.kpiMap.data && this.kpiMap.data[this.secondCounterFieldName]) ?? 0;
    }

    fieldMetaByName(apiName){
        return variationFields.find((item) => item.fieldApiName == apiName);
    }
}