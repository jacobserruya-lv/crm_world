import { LightningElement, api } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';


export default class Icx_orderShippingTileKit extends LightningElement {
    @api product;
    @api productCurrency;
    @api orderStatus;
    @api trackingNumber;
    pictureUrl;
    itemIdIconSrc = imagesResource + `/images/orderPage/itemIcon.svg`
    parcelNumberIconSrc = imagesResource + `/images/orderPage/shippingIcon.svg`
    trackingNumberIconSrc = imagesResource + `/images/orderPage/trackingIcon.svg`

    connectedCallback() {
        if (this.product) {
            const imagePlaceholder = imagesResource + '/images/imgUndefinedLV.png';
            this.pictureUrl = this.product.productImage ? this.product.productImage : imagePlaceholder + '?wid=50&amp;hei=50';
        }
    }
}