import { LightningElement, api, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import PRODUCT_SELECTED_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';


export default class Icx_orderShippingKitComponents extends LightningElement {
    products;
    productSelectionSubscription;
    @api productSelected;

    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    get products() {
        return this.products;
    }

    connectedCallback() {
        this.handleOrderShipping(this.productSelected)

        // Subscribe to ProductSelected message
        this.productSelectionSubscription = subscribe(
            this.messageContext,
            PRODUCT_SELECTED_MESSAGE,
            (message) => {
                console.log('orderShippingKitComponent message : ', message)
                this.handleOrderShipping(message.orderShipping)
            }
        );
    }

    handleOrderShipping(orderShipping) {
        this.products = orderShipping.lines.filter(line => line.kit_flag !== 'Y');
        this.productCurrency = orderShipping.currency_Z;
        this.orderStatus = orderShipping.statusIconics;
        this.trackingNumber = orderShipping.trackingNumber;
    }
}