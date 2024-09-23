import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import imagesResource from "@salesforce/resourceUrl/iconics";
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import USER_ID from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import getProductSKUList from '@salesforce/apex/ICX_CampaignGeneralInformationController.getProductSKUList'


export default class Icx_campaignProductSkuList extends NavigationMixin(LightningElement) {

    @api campaignId;
    @track tableData = [];
    @track allProdcutList;
    @track isLoading = false;
    @track showMoreProduct = true;
    @track isLoadingMoreRecords = false;
    @track pageSize = 5;
    @track pageIndex = 0;
    percentOnScroll = 70;
    listskus = []

    // _tableData = [];
    // get tableData() {
    //     return this._tableData;
    // }
    // set tableData(data) {
    //     this._tableData = data;
    // }

    managerProfileList = ['ICONiCS_SA_Manager', 'System Administrator', 'System Admin_Corporate'];

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILE_NAME_FIELD]
    })
    user;


    connectedCallback() {
        this.isLoading = true;
        this.initHeader();
        console.log(this.campaignId)

        if (this.campaignId) {
            this.initProductList();
        }
    }

    renderedCallBack() {
        this.initHeader();
    }


    fetchProductSKUList() {
        if (this.showMoreProduct && !this.isLoadingMoreRecords) {
            {
                this.isLoadingMoreRecords = true;
                this.isLoading = true;

                getProductSKUList({ pageSize: this.pageSize, pageIndex: this.pageIndex, campaignId: this.campaignId })
                    .then(data => {
                        console.log('getProductSKUList: ' + JSON.stringify(data));
                        this.listskus = data;
                        const tableDataRows = this.handleProductFormat(data);

                        if (!this.tableData.rows || this.tableData.rows === null) {
                            this.tableData.rows = tableDataRows;
                        } else {
                            for (let i = 0; i < tableDataRows.length; i++) {
                                this.tableData.rows.push(tableDataRows[i]);
                            }
                        }
                        if (!this.tableData.idList) {
                            this.tableData.idList = data.map(product => product.Id);

                        } else {
                            for (let i = 0; i < data.length; i++) {
                                this.tableData.idList.push(data[i].Id);
                            }
                        }

                        if (data.length < this.pageSize) {
                            this.showMoreProduct = false;
                        }
                    })
                    .catch(e => {
                        console.error('Error occured in getProductSKUList: ' + e);
                    })
                    .finally(() => {
                        this.isLoadingMoreRecords = false;
                        this.isLoading = false;
                        this.pageIndex = parseInt(this.pageIndex) + parseInt(this.pageSize);
                    })

            }

        }
    }


    checkScroll() {
        const elementScrolled = this.template.querySelector(`[data-id="productTable"]`);
        const heightScrolled = elementScrolled.scrollHeight;
        const totalHeightOfElement = elementScrolled.clientHeight;
        const heightToCallApi = (this.percentOnScroll / 100) * totalHeightOfElement;

        if (heightScrolled >= heightToCallApi && this.showMoreProduct) {
            this.fetchProductSKUList();
        }
    }

    handleNavigation(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: event.detail,
                actionName: 'view',
            },
        });
    }



    handleProductFormat(data) {
        const userManager = this.getIsUserManager();
        let newData;
        if (userManager) {

            newData = data.map(product => {
                return product = [
                    { value: product.CampaignProduct__r.Name, type: "text", isLinkType: true, id: product.CampaignProduct__r.Id },
                    { value: product.SKU__c, type: "text" },
                    { value: imagesResource + '/images/trash.svg', type: 'image', isImageClickableType: true }
                ]
            });
        }
        else {
            newData = data.map(product => {
                return product = [
                    { value: product.CampaignProduct__r.Name, type: "text", isLinkType: true, id: product.CampaignProduct__r.Id },
                    { value: product.SKU__c, type: "text" },
                ]
            });
        }

        return newData;
    }

    handleDeletion(event) {
        let productId = this.tableData.idList[event.detail];
        this.deleteRecord(productId);
        const evt = new ShowToastEvent({
            title: "Sucess",
            message: "Product deleted",
            variant: "success",
        });
        this.dispatchEvent(evt);
        this.initProductList();
        setTimeout(this.reloadPage, 1000);
    }

    reloadPage() {
        return location.reload(true)
    }

    initProductList() {
        this.tableData = [];
        this.initHeader();
        this.pageIndex = 0;
        this.showMoreProduct = true;
        this.fetchProductSKUList();
    }

    initHeader() {
        const userManager = this.getIsUserManager()
        if (userManager) {
            this.tableData.headers = [
                { type: "text", label: "Product Name" },
                { type: "text", label: "Prduct SKU" },
                { type: "image", label: "" }
            ];
        }
        else {
            this.tableData.headers = [
                { type: "text", label: "Product Name" },
                { type: "text", label: "Prduct SKU" },
            ];
        }
    }

    getIsUserManager() {
        console.log('  profile name', getFieldValue(this.user.data, PROFILE_NAME_FIELD));
        return this.managerProfileList.includes(getFieldValue(this.user.data, PROFILE_NAME_FIELD));
    }

    async deleteRecord(recordId) {
        await deleteRecord(recordId);
    }



}