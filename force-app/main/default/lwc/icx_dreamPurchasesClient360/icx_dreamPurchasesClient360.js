import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOCALE from '@salesforce/i18n/locale';
import getPurchases from '@salesforce/apex/icx_Client360_API.getPurchases';
import getAggregate from '@salesforce/apex/icx_Client360_API.getAggregate';
import getDreamID from '@salesforce/apex/ICX_Client360_SF.getDreamID';
import { getGuidId, ToastError, dateFormat2 } from 'c/utils';
import imagesResource from '@salesforce/resourceUrl/iconics';
import { CurrentPageReference } from 'lightning/navigation';

export default class Icx_dreamPurchasesClient360 extends LightningElement {


    @api recordId;
    @track isLoading;
    @api accountId;
    @track tableData = []; //need to put tableData here and not in the child component otherwise it does not rendered the child component...
    @track isMorePurchasesRecords = true;
    @track isMorePuchasesLoading = false;
    @track isDataPurchasesProductsLoading = true;

    @track aggregateResult;


    @track dreamAccountClient = false;



    @track newSearch = '1';
    scrollType = 'NEXT';
    @track refSaleID;
    numTrans = '7';
    percentOnScroll = 95;
    openDetails = false;


    @track products;
    @track tableData = [];


    imagePlaceholder = imagesResource + '/images/imgUndefinedLV.png';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.dreamAccountClient = currentPageReference.state?.c__dreamAccountClient;

        }
    }

    connectedCallback() {
        this.tableData.headers = [
            { type: 'text', label: 'Date' },
            { type: 'text', label: 'Type' },
            { type: 'text', label: 'Store' },
            { type: 'text', label: 'Categorie' },
            { type: 'text', label: 'SKU' },
            { type: 'text', label: 'Size' },
            { type: 'text', label: 'Article' },
            { type: 'text', label: 'Client Advisor' },
            { type: 'text', label: 'Qty' },
            { type: 'text', label: 'Sales' },
            { type: 'text', label: 'Payment Method' },
            { type: 'text', label: 'Transac Number' },
            { type: 'image', label: 'Photo' }
        ]
        this.init();
    }



    async init() {
        if (!this.dreamAccountClient && this.recordId) {

            let responseDreamId = await this.getDreamId();



        }

        if (this.accountId) {


            let responsePurchase = await this.getPurchases();
            let responseAggregate = await this.getAggregate();
        }
        else {
            this.isLoading = false;
            this.products = [];
            // ToastError('No Dream ID for this Client.',this);
            const evt = new ShowToastEvent({
                title: 'WARNING : ' + 'No Dream ID for this Client',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    getDreamId() {
        return getDreamID({ accountId: this.recordId })
            .then(result => {
                this.accountId = result ? result : undefined;
                console.log(' dreamdId', this.accountId);

            })
            .catch(error => {


                const errorJSON = JSON.parse(error.body?.message);

                ToastError(errorJSON.errorMessage, this);

            })

    }


    getPurchases() {
        this.isMorePuchasesLoading = true;
        console.log(' before calling purchase ', this.accountId, this.newSearch, this.scrollType, this.refSaleID, this.numTrans)
        getPurchases({ dreamId: this.accountId, newSearch: this.newSearch, scrollType: this.scrollType, refSaleID: this.refSaleID, numTrans: this.numTrans })
            .then(result => {
                if (result.purchases) {

                    this.handleResultPurchase(result.purchases);

                    if (result.purchases.length < this.numTrans) {
                        this.isMorePurchasesRecords = false;
                    }
                    if (this.newSearch == '1') {
                        this.newSearch = '0';
                    }
                    this.refSaleID = result.refSaleID;
                    console.log(' this.refSaleID', this.refSaleID);
                    this.errorPurchases = undefined;
                }

                else {
                    const error = result;
                    console.error('error API purchases :', error.message);
                    const errorJSON = JSON.parse(error.message);
                    this.errorPurchases = errorJSON.errorMessage;

                    ToastError(this.errorPurchases, this);

                }

            })
            .catch(error => {
                console.error('error purchases :', error);

                this.errorPurchases = JSON.parse(error);
                ToastError(this.errorPurchases, this);

            })
            .finally(() => {
                this.isDataPurchasesProductsLoading = false;
                this.isMorePuchasesLoading = false;
                if (!this.products) {
                    this.products = [];
                    this.isMorePurchasesRecords = false;

                }

            });
    }


    getAggregate() {

        this.isLoading = true;

        getAggregate({ dreamId: this.accountId })
            .then(result => {
                if (result && !result.message) {

                    let resultJSON = result ? JSON.parse(result)[0] : undefined;
                    this.aggregateResult = JSON.stringify(resultJSON);

                    this.errAggregate = undefined;
                }
                else {
                    const error = result;
                    console.error('error aggregate :', error);
                    const errorJSON = JSON.parse(error.message);
                    if (errorJSON.statusCode == '404') {
                        this.errAggregate = 'Failed : Not Found';
                        ToastError(this.errAggregate, this);
                    } else {
                        this.errAggregate = errorJSON.errorMessage;
                        console.error(this.errAggregate);
                    }
                }



                //  if(resultJSON.last_transaction_date==null) 
                //  {

                //     //  this.OpenTable();
                //     //  this.loadDataPurchasesWithCategory2();
                //      this.errAggregate = 'no data';
                //      this.aggregateResult = undefined;

                //  }
                //  else{
                //     this.aggregateResult = resultJSON;

                //  }

            })
            .catch(error => {

                console.error('error aggregate :', error);
                this.errAggregate = JSON.parse(error);
                ToastError(this.errAggregate, this);

            })
            .finally(() => {
                this.isLoading = false;

                //not sure it is needed anymore
                // if(!this.aggregateResult)
                // {
                //     this.loadEmptyGlobal();
                // }

            });
    }


    handleResultPurchase(purchases) {
        console.log(' this.purchases', purchases)

        if (!this.products) {
            this.products = [];
        }

        for (let i = 0; i < purchases.length; i++) {
            this.products.push(purchases[i]);
        }


        this.tableData.rows = this.products.map(product => {
            return product = [
                // { value: product.purchasedProductDate?product.purchasedProductDate.slice(0,4) +'-'+product.purchasedProductDate.slice(4,6)+'-'+product.purchasedProductDate.slice(6):null, type: 'text', label: 'Date' },
                { value: product.purchasedProductDate ? dateFormat2(product.purchasedProductDate.slice(0, 4), product.purchasedProductDate.slice(4, 6), product.purchasedProductDate.slice(6)) : null, type: 'text', label: 'Date' },

                { value: product.type, type: 'text', label: 'Type' },
                { value: product.StoreName, type: 'text', label: 'Store' },
                { value: product.categorie, type: 'text', label: 'Categorie' },
                { value: product.sku, type: 'text', label: 'SKU' },
                { value: product.size, type: 'text', label: 'Size' },
                { value: product.article, type: 'text', label: 'Article' },
                { value: product.OwnerName, type: 'text', label: 'Client Advisor' },
                { value: product.quantity, type: 'text', label: 'Qty' },
                { value: product.sales, type: 'text', label: 'Sales' },
                { value: product.paymentMethod, type: 'text', label: 'Payment Method' },
                { value: product.transactionNumber, type: 'text', label: 'Transac Number' },
                { value: (product.productImage && product.productImage != " ") ? product.productImage : this.imagePlaceholder, type: 'image', label: 'Photo', isImageType: true }

            ]
        });

        this.productsCard = this.products.map(product => {
            let currentProduct = [];
            currentProduct.id = product.wwsid;
            currentProduct.name = product.productName;
            currentProduct.sku = product.sku;
            currentProduct.quantity = product.quantity;
            currentProduct.sales = product.sales;
            currentProduct.currencyCode = product.currencyCode;
            currentProduct.storeName = product.StoreName;
            currentProduct.purchasedProductDate = product.purchasedProductDate.slice(0, 4) + '.' + product.purchasedProductDate.slice(4, 6) + '.' + product.purchasedProductDate.slice(6);
            currentProduct.OwnerName = product.OwnerName;
            currentProduct.productImage = (product.productImage && product.productImage != " ") ? product.productImage : this.imagePlaceholder;
            return currentProduct;


        });


        this.tableData.idTransactionNumber = this.products.map(product => product.transactionNumber);

        console.log(' this.products', this.products)
        console.log(' this.tableData', this.tableData)


    }


    async checkScroll(event) {
        const elementScrolled = event.detail;
        // console.log('checkscroll event ',JSON.stringify(e))
        // const elementScrolled = this.template.querySelector(`[data-id="tablePurchasesContainer"]`);
        const heightScrolled = elementScrolled.scrollHeight;
        const totalHeightOfElement = elementScrolled.clientHeight;
        const heightToCallApi = (this.percentOnScroll / 100) * totalHeightOfElement;
        console.log('totalHeightOfElement Scroll ', totalHeightOfElement)

        console.log('heightToCallApi', heightToCallApi)
        console.log('heightScrolled', heightScrolled)


        if (heightScrolled >= heightToCallApi && this.isMorePurchasesRecords && !this.isMorePuchasesLoading) {
            console.log('The loading function is about to get triggred', heightScrolled)

            let responsePurchase = await this.getPurchases();
        }


    }
}