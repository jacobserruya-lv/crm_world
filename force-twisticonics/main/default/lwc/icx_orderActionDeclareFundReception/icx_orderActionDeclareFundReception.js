import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';

import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import RMS_ID_FIELD from '@salesforce/schema/User.RMS_ID__c';
import WWEMPLOYEENUMBER_FIELD from '@salesforce/schema/User.WWEmployeeNumber__c';

import actionFundsReception from '@salesforce/apex/Account_OrderDetailsControllerLC.sendActionFundsReception';
import callToFinor from '@salesforce/apex/Account_OrderDetailsControllerLC.callToFinor';

export default class Ics_orderActionDeclareFundReception extends LightningModal {
    @api orderdetailsapi;

    @api orderaction; // [{ label: 'Exchange', value: 'exchange' }, { label: 'Return', value: 'return' }, ...]

    @track isLoading = false;

    @track userId = USER_ID;

    paymentMethods = [
        { label: 'Bank Transfer', value: 'BANK_TRANSFER' },
        { label: 'Cash on Delivery', value: 'COD' },
        { label: 'Credit Card', value: 'CREDIT_CARD' }
    ];

    paymentMethodSelected;

    orderAmount;
    // Currency ISO CODE
    currency;
    orderAmountMissing = 0;

    @wire(getRecord, {
        recordId: "$userId",
        fields: [NAME_FIELD, RMS_ID_FIELD, WWEMPLOYEENUMBER_FIELD]
    }) wireuser({ error, data }) {
        console.log('JGU-icx_orderHighlightPanel-@wire (getRecord User - data) : ' + JSON.stringify(data));
        // console.log('JGU-@wire (getRecord User - error) : '+JSON.stringify(error));
        if (error) {
            this.errorUser = error;
        } else if (data) {
            this.wwemployeeid = data.fields.WWEmployeeNumber__c.value;
        }
    }


    connectedCallback() {
        this.orderAmount = this.orderdetailsapi?.transactionInfo.total;
        this.currency = this.orderdetailsapi?.transactionInfo.currency_Z;
    }

    // When change the value in  "reason" combobox
    handlePaymentMethodChange(event) {
        setTimeout(() => (this.template.querySelector('lightning-combobox').reportValidity(), this.myValue = null))
        this.paymentMethodSelected = event.detail.value;
    }

    handleCancel() {
        this.close('cancel');
    }

    async handleSave() {
        this.isLoading = true;
        this.disableClose = true;

        // var bodyToSend = {
        //     "order_id": this.orderdetailsapi.order_id,
        //     "requesting_system": "ICONICS",
        //     "amount": parseFloat(+this.orderAmount),
        //     "payment_method": this.paymentMethodSelected,
        //     "transaction_type": "CAPTURE",
        //     "employee_id": this.wwemployeeid
        // }

        var jsonResponse = [];

        if (this.paymentMethodSelected) {

            await actionFundsReception({
                amount: this.orderAmount,
                paymentMethod: this.paymentMethodSelected,
                transactionType: "CAPTURE",
                employeeId: this.wwemployeeid,
                orderAction: this.orderaction.value,
                orderNumber: this.orderdetailsapi.order_id,
                requestId: this.orderdetailsapi.order_id,
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
            this.disableClose = false;

            this.close(jsonResponse);
        }
        else {
            this.isLoading = false;
            this.disableClose = false;
        }
    }

}