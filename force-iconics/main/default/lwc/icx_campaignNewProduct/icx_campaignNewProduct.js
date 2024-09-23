import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getProductCatalog from '@salesforce/apex/ICX_CampaignNewProductController.getProductCatalog';
import getProductCatalogFromFile from '@salesforce/apex/ICX_CampaignNewProductController.getProductCatalogFromFile';

export default class Icx_campaignNewProduct extends LightningElement {

    @track productSKUListAll = [[]];
    @track productSKUList = [];
    @track productSKU;



    // handle func

    handleProductChange(event) {
        this.productSKU = event.target.value;
    }


    handleProductEntered(component, event, helper) {
        if (component.which == 13) {
            console.log('nao this.productSKU', this.productSKU);

            const constProductSKU = this.checkSKUDuplicate(this.productSKU);

            if (!constProductSKU) {

                getProductCatalog({ skuList: [this.productSKU] })
                    .then(result => {
                        if (result.length > 0) {
                            console.log('nao result product catalog', result);
                            this.productSKUList.push({ "skuName": result[0].SKU__c, "Id": result[0].Id })
                            this.intiateProductSKUListAll();
                            this.sendProductSKUList();
                            this.productSKU = '';
                            const evt = new ShowToastEvent({
                                title: "Success",
                                message: "SKU inserted",
                                variant: "success",
                            });
                            this.dispatchEvent(evt);
                        }
                        else {
                            const evt = new ShowToastEvent({
                                title: "SKU not found",
                                message: "This sku doesn't exist",
                                variant: "error",
                            });
                            this.dispatchEvent(evt);

                        }
                    })
                    .catch(error => {
                        console.error('nao get product catalog error', error);
                    })
            }
            else {
                const evt = new ShowToastEvent({
                    title: "Duplicate Value",
                    message: "This sku is already in the list",
                    variant: "error",
                });
                this.dispatchEvent(evt);
            }
            console.log('nao this.productSKUList', this.productSKUList);
        }
    }


    handleClearAll() {
        this.productSKUList = [];
        this.intiateProductSKUListAll();
        this.sendProductSKUList();
    }


    handleDeleteSKU(event) {
        this.productSKUList = this.productSKUList.filter(sku => sku.Id != event.target.dataset.id);

        this.intiateProductSKUListAll();
        this.sendProductSKUList();
        console.log('nao this.productSKUList remove', this.productSKUList)
    }


    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('nao product file  : ' + JSON.stringify(uploadedFiles));

        getProductCatalogFromFile({ ContentVersionId: uploadedFiles[0].contentVersionId })
            .then(result => {
                if (result.length > 0) {
                    console.log('nao result product catalog', result);
                    for (let i = 0; i < result.length; i++) {
                        const constProductSKU = this.checkSKUDuplicate(result[i].SKU__c);


                        if (!constProductSKU) {
                            this.productSKUList.push({ "skuName": result[i].SKU__c, "Id": result[i].Id })
                        }
                        else {
                            const evt = new ShowToastEvent({
                                title: "Duplicate Value",
                                message: "This sku " + result[i].SKU__c + " is already in the list",
                                variant: "error",
                            });
                            this.dispatchEvent(evt);
                        }
                    }
                    this.intiateProductSKUListAll();
                    this.sendProductSKUList();
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "List of SKU inserted",
                        variant: "success",
                    });
                    this.dispatchEvent(evt);
                }
                else {
                    const evt = new ShowToastEvent({
                        title: "SKU not found",
                        message: "Thoses skus doesn't exist",
                        variant: "error",
                    });
                    this.dispatchEvent(evt);

                }
            })
            .catch(error => {
                console.error('nao get product catalog error', error);
            })
    }


    //get func
    get acceptedFormats() {
        return ['.csv'];
    }


    get isProductListAvailable() {
        return this.productSKUListAll ? this.productSKUListAll[0] ? this.productSKUListAll[0].length > 0 ? true : false : false : false;
    }

    //help func 
    intiateProductSKUListAll() {
        this.productSKUListAll = [[]];
        this.productSKUList = this.productSKUList.sort((a, b) => a.skuName.localeCompare(b.skuName));
        for (let i = 0; i < this.productSKUList.length; i++) {
            if (this.productSKUListAll[this.productSKUListAll.length - 1].length == 9) {
                this.productSKUListAll.push([]);
            }
            this.productSKUListAll[this.productSKUListAll.length - 1].push(this.productSKUList[i]);

        }
    }


    checkSKUDuplicate(newSKU) {
        return this.productSKUList.filter(productSKU => productSKU.skuName.toLowerCase() == newSKU.toLowerCase()).length > 0;
    }


    sendProductSKUList() {
        this.dispatchEvent(new CustomEvent('productskulist', { detail: JSON.stringify(this.productSKUList) }));

    }
}