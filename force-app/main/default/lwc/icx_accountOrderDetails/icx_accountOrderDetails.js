import { LightningElement, wire, track, api } from 'lwc';
import {publish,  subscribe, MessageContext } from 'lightning/messageService';
import ORDER_REFRESH_MESSAGE from '@salesforce/messageChannel/OrderRefresh__c';
import PRODUCT_SELECTED_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';

import OrderNotExist from '@salesforce/label/c.ICX_OrderNotExist';
import OrderError from '@salesforce/label/c.ICX_OrderError';

import getProductDetails from '@salesforce/apex/Account_OrderDetailsControllerLC.getOrderDetailsTwist';
import getBackOfficeUser from '@salesforce/apex/Account_OrderDetailsControllerLC.backOfficeUser';
import getReasonPicklist from '@salesforce/apex/Account_OrderDetailsControllerLC.reasonPicklist';
import getActionPicklist from '@salesforce/apex/Account_OrderDetailsControllerLC.actionPicklist';

export default class Icx_accountOrderDetails extends LightningElement {
    @api recordId;
    @api objectApiName;
    
    @track orderDetails;
    @track error;

    isBackOfficeUser;
    reasonValues;
    allActionValue;

    orderDetailsPanelData;

    isRecordId = true;

    // Expose the labels to use in the template.
    label = {
        OrderNotExist,
        OrderError,
    };

    onRefresh(){
            getProductDetails({orderId: this.recordId, isRecordId: this.isRecordId})
            .then(result => {
                    this.orderDetails = result;
                    console.log('JGU refresh getProductDetails : '+JSON.stringify(result));
                             // Published ProductSelected message
                    publish(this.messageContext, PRODUCT_SELECTED_MESSAGE, {
                        orderShipping: this.orderDetails.order_lines[0]
                    });
                    this.error = undefined;
                })
                .catch(error => {
                    console.log('catch error.message: ' + JSON.stringify(error));
                    console.log('catch error.message: ' + error.body.message);
                    this.error = error;
                    this.orderDetails = undefined;
                });
    }
    
    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    /** Subscription for ProductSelected Lightning message */
    refreshOrderSubscription;

    get isError404() {
        return this.error.body.status == 404;
    }

    // init lifecycle hook known as connectedCallback
    connectedCallback() {
        // Subscribe to ProductSelected message
        this.productSelectionSubscription = subscribe(
            this.messageContext,
            ORDER_REFRESH_MESSAGE,
            (message) => this.onRefresh()
        );

        getProductDetails({orderId: this.recordId, isRecordId: this.isRecordId})
        .then(result => {
                this.orderDetails = result;
                console.log('JGU getProductDetails : '+JSON.stringify(result));
                this.error = undefined;
            })
            .catch(error => {
                console.log('catch error.message: ' + JSON.stringify(error));
                console.log('catch error.message: ' + error.body.message);
                this.error = error;
                this.orderDetails = undefined;
            });
            
        getBackOfficeUser().then(result => {
            this.isBackOfficeUser = result;
        })

        getReasonPicklist().then(result => {
            this.reasonValues = result;
        })

        getActionPicklist().then(result => {
            this.allActionValue = result;
        })
    }
}