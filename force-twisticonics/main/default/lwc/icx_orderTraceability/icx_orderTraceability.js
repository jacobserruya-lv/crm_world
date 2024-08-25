import { LightningElement, api, track, wire } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import getTraceabilityRecords from '@salesforce/apex/TraceabilityService.selectByOrderNumber'

export default class Icx_OrderTraceability extends LightningElement {
    @track traceabilities;
    @track wiredTraceabilityList;
    @track error;

    @track orderNumber = this.orderdetailsapi?.order_id;

    @api 
    get orderdetailsapi() {
        return this._orderdetailsapi;
      }
    set orderdetailsapi(value) {
        this._orderdetailsapi = value;
        this.orderNumber = value?.order_id;
        console.log('Traceability refresh:');
        refreshApex(this.wiredTraceabilityList);
        //this.optionsToDisplay = this.options();
        // if (this.traceabilities != null) {
        //     getTraceabilityRecords({orderNumber: value.order_id})
        //     .then(result => {
        //         console.log('Traceability refresh - OK :'+JSON.stringify(this.traceabilities));
        //         this.traceabilities = result;
        //     })
        //     .catch(error => {
        //         console.log('Traceability refresh - error.message: ' + error.message);
        //         this.error = error;
        //         this.traceabilities = undefined;
        //     })
    }
      


    tableColumns = [
        {label: 'Owner', fieldName: 'Tech_SubmitedBy_Name__c'},
        {label: 'Action', fieldName: 'Action__c'},
        {label: 'Order Shipping', fieldName: 'ShippingNumber__c'},
        {label: 'Reason (if applicable)', fieldName: 'Reason__c'},
        {label: 'Time stamp', fieldName: 'SubmitedDate__c', type: 'date', typeAttributes:{year: '2-digit', month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit"}},
        {label: 'Additional information (if applicable)', fieldName: 'AdditionalInformation__c'},
    ]

    
    @wire(getTraceabilityRecords, {orderNumber: '$orderNumber'}) 
    traceabityRecords(result) {
        this.wiredTraceabilityList = result;

        if(result.data) {

            let tempRecords = [];
            
            console.log('result.data: ' + JSON.stringify(result.data));
            result.data.forEach( obj => {
                let tempRecord = {};
                tempRecord.Tech_SubmitedBy_Name__c = obj.Tech_SubmitedBy_Name__c;
                tempRecord.Action__c = obj.Action__c;
                tempRecord.ShippingNumber__c = obj.OrderShipping__r?.ShippingNumber__c;
                tempRecord.Reason__c = obj.Reason__c;
                tempRecord.SubmitedDate__c = obj.SubmitedDate__c;
                tempRecord.AdditionalInformation__c = obj.AdditionalInformation__c;
                tempRecords.push( tempRecord );
            } );

            this.traceabilities = tempRecords;
        }
        else if(result.error) {
            console.log('error.message: ' + error.message);
            this.error = result.error;
            this.traceabilities = undefined;
        }
    }

    // connectedCallback() {
    //     getTraceabilityRecords({orderNumber: this.orderdetailsapi.order_id})
    //     .then(result => {
    //         this.traceabilities = result;
    //     })
    //     .catch(error => {
    //         console.log('error.message: ' + error.message);
    //         this.error = error;
    //         this.traceabilities = undefined;
    //     })
    // }
}