import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';

import getActionReasons from '@salesforce/apex/OrderActionReasonService.getByAction';

import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import RMS_ID_FIELD from '@salesforce/schema/User.RMS_ID__c';
import WWEMPLOYEENUMBER_FIELD from '@salesforce/schema/User.WWEmployeeNumber__c';

import {getRecord } from 'lightning/uiRecordApi';

import actionRefundShippingFees from '@salesforce/apex/Account_OrderDetailsControllerLC.sendActionRefundShippingFees';

export default class Icx_orderActionRefundShippingFees extends LightningModal {
    @api content;
    @api orderdetailsapi; // Order__c.orderNumber__c
    @api products; // list of product to display
    @api orderaction; // [{ label: 'Exchange', value: 'exchange' }, { label: 'Return', value: 'return' }, ...] 
    
    @track userId = USER_ID;
    wwemployeeid;

    isLoading = false;
    
    reasons;
    reasonSelected;

    @wire(getActionReasons, {action : '$orderaction.value'})
    wiredgetActionReasons({ error, data }) {
        let options = [];
        if(data) {
            for(let i =0; i < data.length; i++) {
                let option = {label: data[i].MasterLabel, value: data[i].Reason_Code__c};
                options.push(option);
            }
            
        }
        else if (error) {

        }
        console.log('reasons:'+options);
        this.reasons = options;

        if (this.reasons.length >= 1) {
            this.reasonSelected = this.reasons[0].value;
        }
    }

    

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

    async handleSave() {
        this.isLoading = true;
        this.disableClose = true;

        let isOk = true;   

        if (isOk){
            var jsonResponse = [];

            // For each product selected
            console.log('xxx-xxx-'+this.products);
            for (let i=0; i<this.products.length; i++) {
                let productToRefund =  this.products[i];
            
                await actionRefundShippingFees({
                    amount : parseFloat(+productToRefund.shipment?.delivery_fees),
                    paymentMethod : this.orderdetailsapi.paymentMethod.payment_method,
                    employeeId : this.wwemployeeid,
                    orderNumber : this.orderdetailsapi.order_id,
                    orderAction : this.orderaction.value,
                    reasonCode : this.reasonSelected,
                    shippingNumber: productToRefund.request_id,
                    lineNumber: parseInt(productToRefund.line_number),
                    shippingId: productToRefund.reason.Id
                })
                .then(result => {           
                    console.log('JGU-result OK: '+JSON.stringify(result));
                    jsonResponse.push(result);
                })
                .catch(error => {
                    console.log('JGU-result Error: '+JSON.stringify(error.body.message));
                    let response = {
                        "status": "error",
                        "message": JSON.stringify(error.body.message)
                    };

                    jsonResponse.push(response);
                });
            }

            this.isLoading = false;
            this.disableClose = false;

            this.close(jsonResponse);
        }
        else {            
            this.isLoading = false;
            this.disableClose = false;
        }
    }
}