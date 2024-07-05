import { api, LightningElement, track, wire } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import getPurchases from '@salesforce/apex/icx_Client360_API.getPurchases';
import getAggregate from '@salesforce/apex/icx_Client360_API.getAggregate';
import { CurrentPageReference } from 'lightning/navigation';
import getDreamID from '@salesforce/apex/ICX_Client360_SF.getDreamID';
import { getGuidId, ToastError, dateFormat2 } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExportTracabilty from '@salesforce/apex/ICX_Client360_SF.getExportTracabilty';
//import createExportPurchase from '@salesforce/apex/ICX_PurchasesExport.createExportPurchase';

import LOCALE from '@salesforce/i18n/locale';


export default class Icx_purchasesClient360 extends LightningElement {

    @api dreamAccountClient;



    @track newSearch = '1';
    scrollType = 'NEXT';
    @track refSaleID;
    numTrans = '7';
    percentOnScroll = 95;


    imagePlaceholder = imagesResource + '/images/imgUndefinedLV.png';


    @api isLoading;
    @api errorPurchases;

    @track selectedCurrency = 'EUR';
    @track selectedCategoryId;


    @api accountId;
    @api recordId;
    @api openDetails;
    @api cardClass;
    @api myRowClass;
    @api products;
    @api productsCard;
    @api tableData = []; //need to put tableData here and not in the child component otherwise it does not rendered the child component...
    isDataHistoricalLoading = true;
    isDataCategoryLoading = true;
    @api isDataPurchasesProductsLoading;
    historicalCategories;
    historicalCategoriesALL;
    detailsCategories;
    productsListsOfTheMonth;
    @api isMorePurchasesRecords;
    @api isMorePuchasesLoading;

    @api aggregateResult;
    firstRerender = true;

    presentationTitle = 'Grid';
    presentationSrc = imagesResource + '/images/client360/gridIcon.svg';
    isPresentationTransaction = true;

    isTableOpen = false;

    classNameMoneySelected = 'button-container money-btns ';
    classNameCategorySelected = 'button-container ';

    // export tracability
    exportTracabilty = null;
    @track exportTracabilityRecord = false;
    @track exportTracabiltyButtonLabel;
    pollingInterval;
    isExportTracabiltyDisabledButton = false;


    @track resultHistoricalSales;
    @track resultHistoricalQuantity;
    categories = [];
    categoriesName = [
        // {
        //     title: 'Default',
        //     id: 'default',
        //     apiId: 'default',
        //     image: imagesResource + `/images/client360/ProductCategories/Global.svg`,
        // },
        {
            title: 'Global',
            apiId: 'global',
            image: imagesResource + `/images/client360/ProductCategories/Global.svg`,
        },
        {
            title: 'Women Ready to Wear',
            apiId: 'wmn_rtw',
            image: imagesResource + `/images/client360/ProductCategories/Men_Ready_to_Wear.svg`,
        },
        {
            title: 'Men Ready to Wear',
            apiId: 'men_rtw',
            image: imagesResource + `/images/client360/ProductCategories/Men_Ready_to_Wear.svg`,
        },
        {
            title: 'Leather Bags',
            apiId: 'leather_bag',
            image: imagesResource + `/images/client360/ProductCategories/Leather_Bags.svg`,
        },
        {
            title: 'Leather Goods',
            apiId: 'lg',
            image: imagesResource + `/images/client360/ProductCategories/Leather_Goods.svg`,
        },
        {
            title: 'Accessories',
            apiId: 'acc',
            image: imagesResource + `/images/client360/ProductCategories/Accessories.svg`,
        },
        {
            title: 'Watches',
            apiId: 'wat',
            image: imagesResource + `/images/client360/ProductCategories/Watches.svg`,
        },
        {
            title: 'Exotics',
            apiId: 'exotics',
            image: imagesResource + `/images/client360/ProductCategories/Exotics.svg`,
        },
        {
            title: 'Travel',
            apiId: 'travel',
            image: imagesResource + `/images/client360/ProductCategories/Travel.svg`,
        },
        {
            title: 'Women Shoes',
            apiId: 'wmn_sho',
            image: imagesResource + `/images/client360/ProductCategories/Women_Shoes.svg`,
        },
        {
            title: 'Men Shoes',
            apiId: 'men_sho',
            image: imagesResource + `/images/client360/ProductCategories/Men_Shoes.svg`,
        },
        {
            title: 'Perfume',
            apiId: 'pfm',
            image: imagesResource + `/images/client360/ProductCategories/Perfume.svg`,
        },
        {
            title: 'Jewelry',
            apiId: 'jew',
            image: imagesResource + `/images/client360/ProductCategories/Jewelry.svg`,
        },
        {
            title: 'High Watches & Jewelry ',
            apiId: 'watch_jewelry',
            image: imagesResource + `/images/client360/ProductCategories/Jewelry_High.svg`,
        },
        {
            title: 'Capucines',
            apiId: 'capucines',
            image: imagesResource + `/images/client360/ProductCategories/Capucines.svg`,
        },

        {
            title: 'Nomades/Hardsided',
            apiId: 'objnomade_hardsided',
            image: imagesResource + `/images/client360/ProductCategories/Objets_Nomades.svg`,
        },
    ]

    @track selectedCategoryApiId = this.categoriesName[0].apiId;
    @track selectedCategory = this.categoriesName[0];

    currencies = [
        {
            title: 'EUR',
            id: 'EUR',
            image: imagesResource + '/images/client360/Devises/Euro.svg',
        },
        {
            title: 'USD',
            id: 'USD',
            image: imagesResource + '/images/client360/Devises/Dollar.svg',
        },
        {
            title: 'JPY',
            id: 'JPY',
            image: imagesResource + '/images/client360/Devises/Yen.svg',
        },
        {
            title: 'CNY',
            id: 'CNY',
            image: imagesResource + '/images/client360/Devises/Yen.svg',
        }
    ]

    detailsValues = [];

    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //    if (currentPageReference) {
    //     this.dreamAccountClient = currentPageReference.state?.c__dreamAccountClient;

    //    }
    // }

    connectedCallback() {

        console.log('connected child tableData', this.tableData);
        console.log('connected child aggregateResult', this.aggregateResult);

        this.selectedCurrency = 'EUR';
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


    renderedCallback() {
        console.log('rendered child accountid', this.accountId);

        console.log('rendered child tableData', this.tableData);
        console.log('rendered child products', this.products);
        console.log('rendered child aggregateResult', this.aggregateResult);


        if (this.aggregateResult) {
            if (this.firstRerender) {

                this.aggregateResult = JSON.parse(this.aggregateResult);
                if (this.aggregateResult.last_transaction_date != null) {

                    this.OpenTable();
                    this.loadDataPurchasesWithCategory2();

                    if (this.selectedCurrency) {
                        let elementSelected = this.template.querySelector(`[data-currency = ${this.selectedCurrency}]`)
                        elementSelected.myclass = this.classNameMoneySelected + 'is-selected'
                    }
                    if (this.selectedCategoryApiId) {
                        let elementSelected = this.template.querySelector(`[data-category = ${this.selectedCategoryApiId}]`)
                        elementSelected.myclass = this.classNameCategorySelected + ' is-selected__border'
                    }
                }
                else {
                    this.errAggregate = 'no data';
                    this.aggregateResult = undefined;


                }
                this.firstRerender = false;

            }


        }


    }


    getPurchases() {
        this.isMorePuchasesLoading = true;
        console.log(' before calling purchase ', this.accountId, this.newSearch, this.scrollType, this.refSaleID, this.numTrans)
        getPurchases({ dreamId: this.accountId, newSearch: this.newSearch, scrollType: this.scrollType, refSaleID: this.refSaleID, numTrans: this.numTrans })
            .then(result => {
                this.handleResultPurchase(result.purchases);




                if (result.purchases.length < this.numTrans) {
                    this.isMorePurchasesRecords = false;
                }
                if (this.newSearch == '1') {
                    this.newSearch = '0';
                }
                this.refSaleID = result.refSaleID;
                console.log('nao this.refSaleID', this.refSaleID);
                this.errorPurchases = undefined;

            })
            .catch(error => {

                const errorJSON = JSON.parse(error.body?.message);
                this.errorPurchases = errorJSON.errorMessage;

                if (errorJSON.statusCode != '404') {

                    ToastError(this.errorPurchases, this);
                }
                console.error('error purchases :', error);
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

    get isError() {
        return this.errAggregate && this.errorPurchases;
    }
    get noData() {
        return !this.aggregateResult && this.products?.length == 0;
    }
    get noProducts() {
        return this.products?.length == 0;
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
            currentProduct.productImage = product.productImage ? product.productImage : this.imagePlaceholder;
            return currentProduct;


        });


        this.tableData.idTransactionNumber = this.products.map(product => product.transactionNumber);

        console.log(' this.products', this.products)
        console.log(' this.tableData', this.tableData)


    }

    getAggregate() {

        this.isLoading = true;

        getAggregate({ dreamId: this.accountId })
            .then(result => {

                console.log(' aggregate purchases ', result);
                console.log(' aggregate purchases  json ', JSON.parse(result));

                let resultJSON = result ? JSON.parse(result)[0] : undefined;
                this.aggregateResult = resultJSON;

                this.errAggregate = undefined;


                if (this.aggregateResult.last_transaction_date != null) {

                    this.OpenTable();
                    this.loadDataPurchasesWithCategory2();

                    // this.loadCategoryName2(resultJSON.hst_nb_transaction_by_category);
                }
                else {
                    this.errAggregate = 'no data';
                    this.aggregateResult = undefined;


                }

            })
            .catch(error => {

                const errorJSON = JSON.parse(error.body?.message);
                this.errAggregate = errorJSON.errorMessage;
                if (errorJSON.statusCode != '404') {

                    ToastError(this.errAggregate, this);
                }
                console.error('error aggregate :', error);
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



    checkCurrency(selectedCurrency, price) {
        price = price.toLocaleString(LOCALE);
        if (selectedCurrency === 'EUR') return price = price + ' €'
        if (selectedCurrency === 'USD') return price =  '$ ' + price
        if (selectedCurrency === 'JPY') return price = ' ¥ ' + price
        if (selectedCurrency === 'CNY') return price = ' ¥ ' + price
    }


    //current version 
    loadHistoricalData2() {

        try {

            this.isDataHistoricalLoading = true;
            let resultHistoricalSalesByCurrency = this.aggregateResult ? this.aggregateResult.histo_turnover_by_category[this.selectedCurrency] : [];
            let resultHistoricalTurnoverByCurrency = this.aggregateResult ? this.aggregateResult.histo_turnover[this.selectedCurrency] : [];
            console.log(' resultHistoricalSalesByCurrency ', resultHistoricalSalesByCurrency)

            this.historicalCategories = [];
            for (let i = 0; i < this.categoriesName.length; i++) {

                let key = this.categoriesName[i].apiId;
                let key12 = '12mr_qte_purchased';
                if (this.aggregateResult) {
                    if (key == "global") {
                        this.historicalCategories.push({ "apiId": key, "label": this.categoriesName[i].title, "sales": resultHistoricalTurnoverByCurrency ? this.checkCurrency(this.selectedCurrency, resultHistoricalTurnoverByCurrency) : '0', "quantity": this.aggregateResult.histo_qte_purchased ? this.aggregateResult.histo_qte_purchased : '0' })
                    } else {
                        this.historicalCategories.push({ "apiId": key, "label": this.categoriesName[i].title, "sales": resultHistoricalSalesByCurrency[key] ? this.checkCurrency(this.selectedCurrency, resultHistoricalSalesByCurrency[key]) : '0', "quantity": this.aggregateResult.histo_qte_purchased_by_category[key] ? this.aggregateResult.histo_qte_purchased_by_category[key] : '0' })
                    }
                }
                else {
                    this.historicalCategories.push({ "apiId": key, "label": this.categoriesName[i].title, "sales": '0', "quantity": '0' })
                }

            }

        }
        catch (error) {
            ToastError(error, this);

            console.error('DataHistorical error', error)
        }
        finally {
            this.isLoading = false;
            this.isDataHistoricalLoading = false;

        }

    }

    async loadHistoricalData() {
        try {
            this.isDataHistoricalLoading = true;
            const result = await getPurchasesHistorical({ id: this.accountId ? this.accountId : this.recordId, currencyName: this.selectedCurrency });
            this.isDataHistoricalLoading = false;
            const resultHistorical = JSON.parse(result);

            this.historicalCategories = resultHistorical.map(category => {
                return {
                    ...category,
                    sales: category.sales ? this.checkCurrency(this.selectedCurrency, category.sales) : '-'
                }
            })

        } catch (error) {
            this.isDataHistoricalLoading = false;
            console.log('errorAPI', error)
        }
    }




    loadEmptyGlobal() {
        // this.categories.push({"id":'Global',"label":'Global',"title":'Global',"apiId":'global',  "image":  imagesResource + '/images/client360/ProductCategories/Global.svg',});
        this.categories.push({ "label": 'Global', "title": 'Global', "apiId": 'global', "image": imagesResource + '/images/client360/ProductCategories/Global.svg', });
        this.selectedCategoryId = this.categories[0].id;
        this.selectedCategoryApiId = this.categories[0].apiId;
        this.selectedCategory = this.categories[0];

        this.loadDataPurchasesWithCategory2();

    }
    //current version
    loadCategoryName2(transactionByCategory) {
        try {

            this.isLoading = true;

            console.log(' transactionByCategory ', transactionByCategory);
            console.log(' categoryName ', this.categoriesName);

            //global ?
            this.categories.push({ "label": 'Global', "title": 'Global', "apiId": 'global', "image": imagesResource + '/images/client360/ProductCategories/Global.svg', });

            for (let i = 0; i < Object.keys(transactionByCategory).length; i++) {
                let key = Object.keys(transactionByCategory)[i];
                let currentCategory = this.categoriesName.find(el => el.apiId == key);
                console.log(' selectedCategory ', currentCategory);
                if (!currentCategory) {
                    // this.categories.push({"id":'default',"label":key,"title":key,"apiId":key, "image": this.categoriesName.find(el => el.apiId == key)? this.categoriesName.find(el => el.apiId == key).image :this.categoriesName.find(el => el.apiId == 'default').image});
                    this.categories.push({ "label": key, "title": key, "apiId": key, "image": this.categoriesName.find(el => el.apiId == key) ? this.categoriesName.find(el => el.apiId == key).image : this.categoriesName.find(el => el.apiId == 'default').image });

                }
                else {
                    this.categories.push({ "label": currentCategory.title, "title": currentCategory.title, "apiId": key, "image": this.categoriesName.find(el => el.apiId == key) ? this.categoriesName.find(el => el.apiId == key).image : this.categoriesName.find(el => el.apiId == 'default').image });

                }



            }
            console.log(' category id ', this.categories);



            this.selectedCategoryId = this.categories[0].id;
            this.selectedCategoryApiId = this.categories[0].apiId;
            this.selectedCategory = this.categories[0];



            this.loadDataPurchasesWithCategory2();

        }
        catch (error) {
            ToastError(error, this);

            console.error('loadCategoryName2 error', error)
        }
        finally {
            this.isLoading = false;

        }
    }

    //old version
    async loadCategoryName() {
        try {
            this.isDataCategoryLoading = true;
            const result = await getPurchasesCategory({ id: this.accountId ? this.accountId : this.recordId })
            const resultCategory = JSON.parse(result);
            this.categories = resultCategory.map(category => {
                return category = {
                    title: category.label,
                    image: imagesResource + `/images/client360/ProductCategories/${category.id ? category.id : category.title}.svg`,
                    id: category.id ? category.id : category.title
                }
            })
            this.isDataCategoryLoading = false;
        } catch (error) {
            this.isDataCategoryLoading = false;
            console.log('errorAPI', error)
        }
    }


    //old version
    async loadPurchasesProducts() {
        try {
            this.isDataPurchasesProductsLoading = true;
            const result = await getPurchasesProducts({ id: this.accountId ? this.accountId : this.recordId, categoryId: this.selectedCategoryId })
            this.isDataPurchasesProductsLoading = false;
            const resultProducts = JSON.parse(result);
            this.products = resultProducts.records;


        } catch (error) {
            this.isDataPurchasesProductsLoading = false;
            console.log('errorAPI', error)

        }
    }

    //old version
    async loadDataPurchasesWithCategory() {
        try {
            this.isDataPurchasesProductsLoading = true;
            const result = await getPurchasesProductsWithCategories({ id: this.accountId ? this.accountId : this.recordId, categoryId: this.selectedCategoryId })
            this.isDataPurchasesProductsLoading = false;
            const resultProducts = JSON.parse(result);

            const { firstPurchasedDate, lastPurchasedDate, data } = resultProducts;

            this.selectedCategory = {
                ...this.selectedCategory,
                image: imagesResource + `/images/client360/ProductCategories/${this.selectedCategory.id}.svg`,
                firstDate: firstPurchasedDate,
                lastDate: lastPurchasedDate
            }

            this.detailsValues = data.map(result => {
                const { type, totalSales, totalProduct, totalReturn, totalTransaction } = result;
                return {
                    title: type,
                    subtitles: [
                        { label: 'Sales', value: totalSales },
                        { label: 'Product Number', value: totalProduct },
                        { label: 'Return Number', value: totalReturn },
                        { label: 'Transaction Number', value: totalTransaction }
                    ]
                }
            })

        } catch (error) {
            this.isDataPurchasesProductsLoading = false;
            console.log('errorAPI', error)

        }
    }


    OpenTable() {
        this.isTableOpen = !this.isTableOpen;
        if (this.isTableOpen) {
            this.loadHistoricalData2();
        }

    }

    //old version
    handleCurrencySelect(event) {
        try {

            this.isLoading = true;
            this.isDataHistoricalLoading = true;

            if (this.selectedCurrency) {
                let elementSelected = this.template.querySelector(`[data-currency = ${this.selectedCurrency}]`)
                elementSelected.myclass = this.classNameMoneySelected
            }

            this.selectedCurrency = event.currentTarget.dataset.id;

            let element = this.template.querySelector(`[data-currency = ${this.selectedCurrency}]`)
            element.myclass = element.myclass + 'is-selected'

            // this.loadHistoricalData();
            if (!this.isTableOpen) {

                this.OpenTable();
            }
            else {
                this.loadHistoricalData2();

            }
            this.loadDataPurchasesWithCategory2()

            this.isDataHistoricalLoading = false;
            this.isLoading = false;

        }
        catch (error) {
            this.isLoading = false;
            console.error('error handleCurrencySelect', error)
            ToastError(error, this);


        }

    }


    //current version
    handleCategorySelect2(event) {
        if (this.selectedCategoryApiId) {
            let elementSelected = this.template.querySelector(`[data-category = ${this.selectedCategoryApiId}]`)
            elementSelected.myclass = this.classNameCategorySelected
        }

        this.selectedCategoryApiId = event.currentTarget.dataset.apiid;
        // this.selectedCategory = this.categories.find(el => el.apiId == this.selectedCategoryApiId);        this.selectedCategory = this.categoriesName.find(el => el.apiId == this.selectedCategoryApiId);
        this.selectedCategory = this.categoriesName.find(el => el.apiId == this.selectedCategoryApiId);

        let element = this.template.querySelector(`[data-category = ${this.selectedCategoryApiId}]`);
        element.myclass = element.myclass + 'is-selected__border';

        this.loadDataPurchasesWithCategory2()


    }


    //current version
    loadDataPurchasesWithCategory2() {
        try {
            this.isLoading = true;
            //because there is a number in the name, need to use variables
            const lastMonthTurnover = '12mr_turnover_by_category';
            const lastMonthQuantity = '12mr_qte_purchased_by_category';
            const lastMonthReturn = '12mr_return_number_by_category';
            const lastMonthTransaction = '12mr_nb_transaction_by_category';


            if (this.aggregateResult) {
                console.log(' first date, last date ', this.aggregateResult.first_transaction_date, this.aggregateResult.last_transaction_date)



                if (this.selectedCategoryApiId != 'global') {
                    let firstDate = this.aggregateResult.first_transaction_date_by_category[this.selectedCategoryApiId];
                    let lastDate = this.aggregateResult.last_transaction_date_by_category[this.selectedCategoryApiId];

                    this.selectedCategory = {
                        ...this.selectedCategory,
                        firstDate: firstDate ? dateFormat2(firstDate.split('-')[0], firstDate.split('-')[1], firstDate.split('-')[2]) : 'N/A',
                        lastDate: lastDate ? dateFormat2(lastDate.split('-')[0], lastDate.split('-')[1], lastDate.split('-')[2]) : 'N/A'
                    }

                    this.detailsValues =
                        [
                            {
                                title: 'Historical',
                                subtitles: [
                                    { label: 'Sales', value: this.aggregateResult.histo_turnover_by_category ? this.aggregateResult.histo_turnover_by_category[this.selectedCurrency][this.selectedCategoryApiId] ? this.checkCurrency(this.selectedCurrency, this.aggregateResult.histo_turnover_by_category[this.selectedCurrency][this.selectedCategoryApiId]) : this.checkCurrency(this.selectedCurrency, 0) : this.checkCurrency(this.selectedCurrency, 0) },
                                    { label: 'Product Number', value: this.aggregateResult.histo_qte_purchased_by_category ? this.aggregateResult.histo_qte_purchased_by_category[this.selectedCategoryApiId] ? this.aggregateResult.histo_qte_purchased_by_category[this.selectedCategoryApiId] : '0' : '0' },
                                    { label: 'Return Number', value: this.aggregateResult.hst_return_number_by_category ? this.aggregateResult.hst_return_number_by_category[this.selectedCategoryApiId] ? this.aggregateResult.hst_return_number_by_category[this.selectedCategoryApiId] : '0' : '0' },
                                    { label: 'Transaction Number', value: this.aggregateResult.hst_nb_transaction_by_category ? this.aggregateResult.hst_nb_transaction_by_category[this.selectedCategoryApiId] ? this.aggregateResult.hst_nb_transaction_by_category[this.selectedCategoryApiId] : '0' : '0' }
                                ]
                            },
                            {
                                title: '12 Months Rolling',
                                subtitles: [
                                    { label: 'Sales', value: this.aggregateResult[lastMonthTurnover] ? this.aggregateResult[lastMonthTurnover][this.selectedCurrency][this.selectedCategoryApiId] ? this.checkCurrency(this.selectedCurrency, this.aggregateResult[lastMonthTurnover][this.selectedCurrency][this.selectedCategoryApiId]) : this.checkCurrency(this.selectedCurrency, 0) : this.checkCurrency(this.selectedCurrency, 0) },
                                    { label: 'Product Number', value: this.aggregateResult[lastMonthQuantity] ? this.aggregateResult[lastMonthQuantity][this.selectedCategoryApiId] ? this.aggregateResult[lastMonthQuantity][this.selectedCategoryApiId] : '0' : '0' },
                                    { label: 'Return Number', value: this.aggregateResult[lastMonthReturn] ? this.aggregateResult[lastMonthReturn][this.selectedCategoryApiId] ? this.aggregateResult[lastMonthReturn][this.selectedCategoryApiId] : '0' : '0' },
                                    { label: 'Transaction Number', value: this.aggregateResult[lastMonthTransaction] ? this.aggregateResult[lastMonthTransaction][this.selectedCategoryApiId] ? this.aggregateResult[lastMonthTransaction][this.selectedCategoryApiId] : '0' : '0' }
                                ]
                            },
                            {
                                title: 'Year To Date',
                                subtitles: [
                                    { label: 'Sales', value: this.aggregateResult.ytd_turnover_by_category ? this.aggregateResult.ytd_turnover_by_category[this.selectedCurrency][this.selectedCategoryApiId] ? this.checkCurrency(this.selectedCurrency, this.aggregateResult.ytd_turnover_by_category[this.selectedCurrency][this.selectedCategoryApiId]) : this.checkCurrency(this.selectedCurrency, 0) : this.checkCurrency(this.selectedCurrency, 0) },
                                    { label: 'Product Number', value: this.aggregateResult.ytd_qte_purchased_by_category ? this.aggregateResult.ytd_qte_purchased_by_category[this.selectedCategoryApiId] ? this.aggregateResult.ytd_qte_purchased_by_category[this.selectedCategoryApiId] : '0' : '0' },
                                    { label: 'Return Number', value: this.aggregateResult.ytd_return_number_by_category ? this.aggregateResult.ytd_return_number_by_category[this.selectedCategoryApiId] ? this.aggregateResult.ytd_return_number_by_category[this.selectedCategoryApiId] : '0' : '0' },
                                    { label: 'Transaction Number', value: this.aggregateResult.ytd_nb_transaction_by_category ? this.aggregateResult.ytd_nb_transaction_by_category[this.selectedCategoryApiId] ? this.aggregateResult.ytd_nb_transaction_by_category[this.selectedCategoryApiId] : '0' : '0' }
                                ]
                            }
                        ]
                }
                else {
                    this.calculateGlobalCategory();
                }
            }
            else {

                this.selectedCategory = {
                    ...this.selectedCategory,
                    firstDate: 'N/A',
                    lastDate: 'N/A'
                }

                this.detailsValues =
                    [
                        {
                            title: 'Historical',
                            subtitles: [
                                { label: 'Sales', value: '0' },
                                { label: 'Product Number', value: '0' },
                                { label: 'Return Number', value: '0' },
                                { label: 'Transaction Number', value: '0' }
                            ]
                        },
                        {
                            title: '12 Months Rolling',
                            subtitles: [
                                { label: 'Sales', value: '0' },
                                { label: 'Product Number', value: '0' },
                                { label: 'Return Number', value: '0' },
                                { label: 'Transaction Number', value: '0' }
                            ]
                        },
                        {
                            title: 'Year To Date',
                            subtitles: [
                                { label: 'Sales', value: '0' },
                                { label: 'Product Number', value: '0' },
                                { label: 'Return Number', value: '0' },
                                { label: 'Transaction Number', value: '0' }
                            ]
                        }
                    ]
            }

        } catch (error) {
            console.error('error Data with category', error)
            ToastError(error, this);


        }
        finally {
            this.isLoading = false;
        };
    }

    calculateGlobalCategory() {
        //because there is a number in the name, need to use variables
        const lastMonthTurnover = '12mr_turnover';
        const lastMonthQuantity = '12mr_qte_purchased';
        const lastMonthReturn = '12mr_return_number';
        const lastMonthTransaction = '12mr_nb_transaction';

        const last12MonthTurnover = '12mr_turnover';
        const last12MonthQuantity = '12mr_qte_purchased';
        const last12MonthReturn = '12mr_return_number';
        const last12MonthTransaction = '12mr_nb_transaction'

        //  const listCategoriesApiId = this.categories.map(category =>category.apiId);
        const listCategoriesApiId = this.categoriesName.map(category => category.apiId);
        this.selectedCategory = {
            ...this.selectedCategory,
            firstDate: dateFormat2(this.aggregateResult.first_transaction_date.split('-')[0], this.aggregateResult.first_transaction_date.split('-')[1], this.aggregateResult.first_transaction_date.split('-')[2]),
            lastDate: dateFormat2(this.aggregateResult.last_transaction_date.split('-')[0], this.aggregateResult.last_transaction_date.split('-')[1], this.aggregateResult.last_transaction_date.split('-')[2])
        }
        this.detailsValues =
            [
                {


                    title: 'Historical',
                    subtitles: [
                        { label: 'Sales', value: this.aggregateResult.histo_turnover ? this.aggregateResult.histo_turnover[this.selectedCurrency] ? this.checkCurrency(this.selectedCurrency, this.aggregateResult.histo_turnover[this.selectedCurrency]) : this.checkCurrency(this.selectedCurrency, 0) : this.checkCurrency(this.selectedCurrency, 0) },
                        { label: 'Product Number', value: this.aggregateResult.histo_qte_purchased ? this.aggregateResult.histo_qte_purchased ? this.aggregateResult.histo_qte_purchased : '0' : '0' },
                        { label: 'Return Number', value: this.aggregateResult.hst_return_number ? this.aggregateResult.hst_return_number ? this.aggregateResult.hst_return_number : '0' : '0' },
                        { label: 'Transaction Number', value: this.aggregateResult.hst_nb_transaction ? this.aggregateResult.hst_nb_transaction ? this.aggregateResult.hst_nb_transaction : '0' : '0' }
                    ]

                },
                {


                    title: '12 Months Rolling',
                    subtitles: [
                        { label: 'Sales', value: this.aggregateResult[lastMonthTurnover] ? this.aggregateResult[lastMonthTurnover][this.selectedCurrency] ? this.checkCurrency(this.selectedCurrency, this.aggregateResult[lastMonthTurnover][this.selectedCurrency]) : this.checkCurrency(this.selectedCurrency, 0) : this.checkCurrency(this.selectedCurrency, 0) },
                        { label: 'Product Number', value: this.aggregateResult[lastMonthQuantity] ? this.aggregateResult[lastMonthQuantity] ? this.aggregateResult[lastMonthQuantity] : '0' : '0' },
                        { label: 'Return Number', value: this.aggregateResult[lastMonthReturn] ? this.aggregateResult[lastMonthReturn] ? this.aggregateResult[lastMonthReturn] : '0' : '0' },
                        { label: 'Transaction Number', value: this.aggregateResult[lastMonthTransaction] ? this.aggregateResult[lastMonthTransaction] ? this.aggregateResult[lastMonthTransaction] : '0' : '0' }
                    ]
                },
                {


                    title: 'Year To Date',
                    subtitles: [
                        { label: 'Sales', value: this.aggregateResult.ytd_turnover ? this.aggregateResult.ytd_turnover[this.selectedCurrency] ? this.checkCurrency(this.selectedCurrency, this.aggregateResult.ytd_turnover[this.selectedCurrency]) : this.checkCurrency(this.selectedCurrency, 0) : this.checkCurrency(this.selectedCurrency, 0) },
                        { label: 'Product Number', value: this.aggregateResult.ytd_qte_purchased ? this.aggregateResult.ytd_qte_purchased ? this.aggregateResult.ytd_qte_purchased : '0' : '0' },
                        { label: 'Return Number', value: this.aggregateResult.ytd_return_number ? this.aggregateResult.ytd_return_number ? this.aggregateResult.ytd_return_number : '0' : '0' },
                        { label: 'Transaction Number', value: this.aggregateResult.ytd_nb_transaction ? this.aggregateResult.ytd_nb_transaction ? this.aggregateResult.ytd_nb_transaction : '0' : '0' }
                    ]
                }
            ]

    }
    //old version
    handleCategorySelect(event) {
        if (this.selectedCategoryId) {
            let elementSelected = this.template.querySelector(`[data-category = ${this.selectedCategoryId}]`)
            elementSelected.myclass = this.classNameCategorySelected
        }

        this.selectedCategoryId = event.currentTarget.dataset.id;
        this.selectedCategory = this.categories.find(el => el.id == event.currentTarget.dataset.id);

        let element = this.template.querySelector(`[data-category = ${this.selectedCategoryId}]`)
        element.myclass = element.myclass + 'is-selected__border'

        this.loadDataPurchasesWithCategory()
        this.loadPurchasesProducts();
    }

    //current version
    handleTablePresentation(event) {
        console.log('handleTablePresentation', event.currentTarget.dataset.title)
        if (event.currentTarget.dataset.title == 'Grid') {
            this.presentationSrc = imagesResource + '/images/client360/transactions.svg';
            this.presentationTitle = 'Transactions';
            this.isPresentationTransaction = false;
        }
        else {
            this.presentationSrc = imagesResource + '/images/client360/gridIcon.svg';
            this.presentationTitle = 'Grid';
            this.isPresentationTransaction = true;
        }
    }

    get getGuidId() {
        return getGuidId();
    }

    handleScroll(event) {
        this.dispatchEvent(new CustomEvent('tablescroll', { detail: this.template.querySelector(`[data-id="tablePurchasesContainer"]`) }));

    }
}