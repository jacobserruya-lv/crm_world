import { LightningElement, api } from 'lwc';
import { copyToClipboard } from 'c/icx_utils';

export default class Icx_orderDetailsPanel extends LightningElement {
    @api orderid; // Salesforce ID
    @api orderdetailsapi;

    get isShippingAddressCompanyNameHidden() {        
        return ( !this.orderdetailsapi.ship_to.name.company_name )?'slds-hide':'';
    }

    // The shipping Method should be enrich with 
    get shippingMethod() {
        if (this.orderdetailsapi.fulfillment_type == 'DELIVERY' && this.orderdetailsapi.firstShipment?.carrier_service != undefined) {
            return this.orderdetailsapi.fulfillment_type + ' ' + this.orderdetailsapi.firstShipment?.carrier_service;
        }
        else if (this.orderdetailsapi.fulfillment_type == 'SHIPFORPICKUP') {
            return 'Click & Collect';
        }
        else {
            return this.orderdetailsapi.fulfillment_type;
        }
    }

    async handleCopyPayByLink() {
        await copyToClipboard(this.orderdetailsapi.payByLink, 'Pay by link was successfully copied', this);
      }

    async handleCopyExtendedPayByLink() {
    await copyToClipboard(this.orderdetailsapi.extendedPayByLink, 'Extended Pay by link was successfully copied', this);
    }

    async handleCopyPayAfterAgreementLink() {
    await copyToClipboard(this.orderdetailsapi.payAfterAgreementLink, 'Perso Validation link was successfully copied', this);
    }

    get displayPayByLink() {
        return (this.orderdetailsapi.paymentMethod.isPayByLink 
            && (this.orderdetailsapi.payByLink || this.orderdetailsapi.isPayByLinkExpired));
    }

    get displayExtendedPayByLink() {
        return (this.orderdetailsapi.paymentMethod.isPayByLink 
            && (this.orderdetailsapi.extendedPayByLink || this.orderdetailsapi.isExtendedPayByLinkExpired));
    }

    get displayPersoProductAccepted() {
        return (this.orderdetailsapi.paymentMethod.isPayByLink
            && (this.orderdetailsapi.persoProductAccepted || this.orderdetailsapi.payAfterAgreementLink || this.orderdetailsapi.isPayAfterAgreementLinkExpired));
    }

    get shippingAddressFull() {
        return this.orderdetailsapi.ship_to.address.address.trim()+'\n'+this.orderdetailsapi.ship_to.address.city + ', ' + this.orderdetailsapi.ship_to.address.province + ' ' + this.orderdetailsapi.ship_to.address.postal_code + '\n' + this.orderdetailsapi.ship_to.address.country;
    }

    get billingAddressFull() {
        return this.orderdetailsapi.sold_to.address.address.trim()+'\n'+this.orderdetailsapi.sold_to.address.city + ', ' + this.orderdetailsapi.sold_to.address.province + ' ' + this.orderdetailsapi.sold_to.address.postal_code + '\n' + this.orderdetailsapi.sold_to.address.country;
    }

    async handleCopyShippingAddress() {
        await copyToClipboard(this.shippingAddressFull, 'Shipping Address copied', this);
    }

    async handleCopyBillingAddress() {
        await copyToClipboard(this.billingAddressFull, 'Billing Address copied', this);
    }

    get shippingMapsURI() {
        const addressFull = this.shippingAddressFull;
        return 'https://www.google.com/maps/search/?api=1&query=' + encodeURI(addressFull);
    }

    get billingMapsURI() {
        const addressFull = this.billingAddressFull;
        return 'https://www.google.com/maps/search/?api=1&query=' + encodeURI(addressFull);
    }



}