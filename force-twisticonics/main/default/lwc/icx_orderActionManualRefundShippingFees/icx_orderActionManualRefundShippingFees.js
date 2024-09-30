import { wire,api,track } from 'lwc';
import LightningModal from 'lightning/modal';


import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import RMS_ID_FIELD from '@salesforce/schema/User.RMS_ID__c';
import WWEMPLOYEENUMBER_FIELD from '@salesforce/schema/User.WWEmployeeNumber__c';

import {getRecord } from 'lightning/uiRecordApi';

import actionManualRefundShippingFees from '@salesforce/apex/Account_OrderDetailsControllerLC.sendActionManualRefundShippingFees';


export default class Icx_orderActionManualRefundShippingFees extends LightningModal {

    @api content;
    @api orderdetailsapi; // Order__c.orderNumber__c
    // @api products; // list of product to display
    @api orderaction; // [{ label: 'Exchange', value: 'exchange' }, { label: 'Return', value: 'return' }, ...] 
    
    @track userId = USER_ID;
    wwemployeeid;

    reasonRequired = true;
    @track methodSelected;

    isLoading = false;

     // Refund payment methods
     methods = [
        {label:'Bank Transfer' ,value:'BANK_TRANSFER'},
        {label:'Cash on Delivery' ,value:'COD'},
        {label:'Credit Card' ,value:'CREDIT_CARD'}
    ];




    

    @wire(getRecord, {
        recordId: "$userId",
        fields: [NAME_FIELD, RMS_ID_FIELD, WWEMPLOYEENUMBER_FIELD]
      }) wireuser({error, data}) {
          console.log('JGU-icx_orderHighlightPanel-@wire (getRecord User - data) : '+JSON.stringify(data));
          // console.log('JGU-@wire (getRecord User - error) : '+JSON.stringify(error));
          if (error) {
            this.errorUser = error ; 
          } else if (data) {
              this.wwemployeeid = data.fields.WWEmployeeNumber__c.value;
          }
      }

    // When change the value in  "reason" combobox
    handleReasonChange(event) {        
        setTimeout(() => (this.template.querySelector('lightning-combobox').reportValidity(), this.myValue = null))
        this.reasonSelected = event.detail.value;        
    }

    handleCancel() {
        this.close('cancel');
    }

    async handleYes() {
        this.isLoading = true;
        // this.disableClose = true;


        if (this.methodSelected ){
            var jsonResponse = [];

            await actionManualRefundShippingFees({
                requestingSystem:'ICONiCS',
                amount: parseFloat(this.orderdetailsapi.sumOfShippingFeesWithoutTax),
                paymentMethod: this.methodSelected,
                employeeId: this.wwemployeeid,
                orderNumber: this.orderdetailsapi.order_id,
                orderAction: this.orderaction.value,
                // reasonCode: this.reasonSelected,
                // shippingId: tiles[i].product?.reason.Id,
                // requestId: tiles[i].product?.request_id
            })
                .then(result => {
                    console.log('JGU-result OK: ' + JSON.stringify(result));
                    jsonResponse.push(result);
                })
                .catch(error => {
                    console.log('JGU-result Error: ' + JSON.stringify(error));
                    jsonResponse.push(error);
                });
            this.isLoading = false;
            // this.disableClose = false;

            this.close(jsonResponse);
        }
        else {   
            this.close([JSON.parse('{"status":"error","message":"please selected a payment method"}')]);

            this.isLoading = false;
            // this.disableClose = false;
        }
    }

    handleMethodChange(event) {        
        setTimeout(() => (this.template.querySelector('lightning-combobox').reportValidity(), this.myValue = null))
        this.methodSelected = event.detail.value;        
    }

    // When change the value in  "reason" combobox
    handleReasonChange(event) {        
        setTimeout(() => (this.template.querySelector('lightning-combobox').reportValidity(), this.myValue = null))
        this.reasonSelected = event.detail.value;        
    }
}