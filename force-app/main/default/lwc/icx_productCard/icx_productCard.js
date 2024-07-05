import { api, LightningElement } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import { NavigationMixin } from 'lightning/navigation';
import {dateFormat2} from 'c/utils';

export default class Icx_productCard extends NavigationMixin(LightningElement) {
    @api item;
    details;
    @api cardClass;
    @api openDetails;
    
    connectedCallback() {
        const { storeName, purchasedProductDate, OwnerName } = this.item;

        let datePurchase = purchasedProductDate.split('.').length>0? dateFormat2(purchasedProductDate.split('.')[0],purchasedProductDate.split('.')[1],purchasedProductDate.split('.')[2]):dateFormat2(product.purchasedProductDate.slice(0,4),product.purchasedProductDate.slice(4,6),product.purchasedProductDate.slice(6));
        this.details = [
            { src: imagesResource + '/images/client360/homeGrey.png', value: storeName, id: storeName },
            // { src: imagesResource + '/images/client360/calendarGrey.png', value: purchasedProductDate, id: purchasedProductDate },
            { src: imagesResource + '/images/client360/calendarGrey.png', value: datePurchase , id: purchasedProductDate },

            { src: imagesResource + '/images/client360/saGrey.png', value: OwnerName, id: OwnerName }
        ]
    }


    //not used
    redirectProductDetails() {
        if(this.openDetails)
        {

            // const productId = this.item.transactionNumber;
            const productId = this.item.transactionNumber?this.item.transactionNumber:this.item.id;
            console.log('redirect productId',productId);
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: productId,
                    objectApiName: "PPR_PurchProduct__c",
                    actionName: "view"
                },
            });
        }
            
    }
}