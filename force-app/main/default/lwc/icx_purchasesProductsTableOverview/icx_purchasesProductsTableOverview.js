import { api, LightningElement, track, wire } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import getPurchases from '@salesforce/apex/ICX_Client360_SF.getPurchases';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import { NavigationMixin } from 'lightning/navigation';
import getPurchasesAPI from '@salesforce/apex/icx_Client360_API.getPurchases';
import {getGuidId,ToastError,dateFormat2} from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDreamID from '@salesforce/apex/ICX_Client360_SF.getDreamID';

export default class Icx_purchasesProductsTableOverview extends NavigationMixin(LightningElement)  {


    isWithSubtitles = true;
    @api sfRecordId;
    @track dreamId;
    objectName = 'PPR_PurchProduct__c';
    condition = 'WHERE Client__c =: accountId';
    recordsListlength;
    @track tableData = [];
    @track purchasesProducts ;
    @track isLoading = true;

    @track newSearch='1';
    scrollType = 'NEXT';
    @track refSaleID; 
    numTrans = '3';
    @track products;
    imagePlaceholder = imagesResource+'/images/imgUndefinedLV.png';
    openDetails = true;




    @wire(getrecordsListSize,{accountId:'$sfRecordId' ,objectName:'$objectName',condition:'$condition'})
    wiredListSize({error,data}){ 
        if(data)
        {
           this.recordsListlength = data;
        }
        else{
            this.recordsListlength =0;

        }
        if (error) {
            console.error('error',error);
        }
    }


    @wire(getPurchases, { accountId: '$sfRecordId' })
    wiredPurchases({ error, data }) {
        this.tableData.title = {
            type: 'text',
            label: 'Purchases',
            iconSrc: imagesResource + `/images/client360/purchasesIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            hasLength: true,
            length: this.recordsListlength,
            titleClass: 'title-bold title-navigation cursor-pointer',

        }

        if (data) {

            

            this.purchasesProducts = data.length>0?data:undefined;
            this.tableData.idList = data.map(purchase => purchase.Id);

            console.log('purchasesProducts', JSON.stringify(this.purchasesProducts))

        }


        if (error) {
            console.error(error);
        }
        this.isLoading = false;

    }


    
   
    navigateToPurchase(event)
    {
        let purchaseId = this.tableData.idList[event.detail];
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: purchaseId,
                objectApiName: 'Purchased_Products__c',
                actionName: 'view'
            },
        });
    }
   

    navigateToViewListPage() {
        console.log('Try to navigate to a list')
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
            objectApiName: 'Account',
              recordId: this.sfRecordId,
              relationshipApiName: 'Purchased_Products__r',
              actionName: 'view'
            },
        });
    }


    connectedCallback()
    {

        this.tableData.title = {
            type: 'text',
            label: 'Purchases',
            iconSrc: imagesResource + `/images/client360/purchasesIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            titleClass: 'title-bold title-navigation cursor-pointer',
        }

      
     //   this.init();
    
    }

    async init()
    {
        let responseDreamId = await this.getDreamId();

        if(this.dreamId)
        {
            console.log('nao purchase overview dreamid', this.dreamId);
            let responsePurchase = await this.getPurchases();  
        }
        else{
            const evt = new ShowToastEvent({
                title: 'WARNING : ' + 'No Dream ID for this Client',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }

    }


    getPurchases()
    {
        console.log(' before calling purchase ',  this.accountId, this.newSearch, this.scrollType, this.refSaleID , this.numTrans)
        getPurchasesAPI({dreamId : this.dreamId, newSearch:this.newSearch, scrollType:this.scrollType, refSaleID:this.refSaleID,numTrans :this.numTrans})
        .then(result => {
            this.handleResultPurchase(result.purchases);
          
            this.errorPurchases = undefined;
            
        })
        .catch(error => {
            console.error('error purchases :',error);

            const errorJSON = JSON.parse(error.body?.message);
            this.errorPurchases = errorJSON.errorMessage;    
            
            if(errorJSON.statusCode!='404')
            {

                ToastError(this.errorPurchases,this);
            }            
        })
        .finally(() => {
            if(!this.products)
            {
                this.products=[];

            }
            this.isLoading = false;

          });
        
        
        
    }


    handleResultPurchase(purchases)
    {
        console.log(' this.purchases',purchases)
        
        if(!this.products)
        {
            this.products = [];
        }
           
            for(let i = 0; i<purchases.length;i++)
            {
                this.products.push(purchases[i]);
            }

        


        this.purchasesProducts = this.products.map(product => {
            let currentProduct=[];
            currentProduct.id = product.wwsid;
            currentProduct.name=product.productName;
            currentProduct.sku = product.sku;
            currentProduct.quantity = product.quantity;
            currentProduct.sales = product.sales;
            currentProduct.currencyCode = product.currencyCode;
            currentProduct.storeName = product.StoreName;
            currentProduct.purchasedProductDate = product.purchasedProductDate.slice(0,4)+'.'+product.purchasedProductDate.slice(4,6)+'.'+product.purchasedProductDate.slice(6);
            currentProduct.OwnerName = product.OwnerName;
            currentProduct.productImage=(product.productImage &&product.productImage != " ") ? product.productImage : this.imagePlaceholder;
            return currentProduct;

         
        });



        console.log(' this.purchasesProducts',this.purchasesProducts)
        console.log(' this.tableData',this.tableData)

        
    }

    getDreamId()
    {
       return getDreamID({accountId:this.sfRecordId})
        .then(result => {
            this.dreamId = result?result:undefined;
            console.log(' dreamdId', this.dreamId);
            
        })
        .catch(error => {
    
            const errorJSON = JSON.parse(error.body?.message);                    

                ToastError(errorJSON.errorMessage,this);
          
        })

    }
}