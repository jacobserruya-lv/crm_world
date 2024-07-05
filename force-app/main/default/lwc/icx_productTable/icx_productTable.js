import { api, LightningElement, track, wire } from 'lwc';
import getPurchasedProductId from '@salesforce/apex/ICX_Client360_SF.getPurchasedProductId';
import { NavigationMixin } from 'lightning/navigation';



import { CurrentPageReference } from 'lightning/navigation';


export default class Icx_productTable extends NavigationMixin(LightningElement) {
    isWithSubtitles = true;

    @api sfRecordId;
    @api isLoading;
    @api products;
    @api selectedCurrency;
    @api openDetails;
    @api myRowClass;

    @api tableData=[] ;
    @wire(CurrentPageReference) pageRef;

    placeholder = '';



  

    renderedCallback() {

        console.log('product table this.products', JSON.stringify(this.products))
        console.log('product table this.tableData', this.tableData)

      

    }

   

    async openProductDetails(event) {

        if(this.openDetails)
        {

            
            let transactionId = this.tableData.idTransactionNumber[event.detail];
            let productDetailsID ;
            
            //for future use
            // await getPurchasedProductId({transactionNumber: transactionId})
            // .then(result => {
            //     productDetailsID = result;
            //     console.log(' productDetailsID: ',productDetailsID);
            //     console.log(' productDetailsID result: ',result);
                
            // })
            // .catch(error => {
            //     console.log(' error transactionNumber : ', error);
            // });
            
            
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: transactionId,
                    objectApiName: 'PPR_PurchProduct__c',
                    actionName: 'view'
                },
            });
        }
        
    }
}