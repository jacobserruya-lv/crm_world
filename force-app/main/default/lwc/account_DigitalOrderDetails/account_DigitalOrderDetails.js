import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import myResource from '@salesforce/resourceUrl/iconics';
import font from '@salesforce/resourceUrl/LVFont';
import { loadStyle } from 'lightning/platformResourceLoader';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getProductMap from '@salesforce/apex/Account_DigitalOrderListControllerLWC.getProductMap'
import getStoreCountry from '@salesforce/apex/Account_DigitalOrderListControllerLWC.getStoreCountry'

const fields = [NAME_FIELD];



export default class Account_DigitalOrderDetails extends NavigationMixin(LightningElement) {
    @api orderNumber;
    @api orders;
    @api accountId;


    @track orderDetails ;
    @track caseObjInfo;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjInfo;
    @wire(getRecord, { recordId: '$accountId', fields })
    account;
    @wire(getProductMap,{SKUList:'$SKUList'})
    productMap;
    @wire (getStoreCountry,{storeId:'$orderDetails.StoreCode.Id'})
    storeCountry;

    get SKUList(){
        return this.orders.map(v=>{return v.Product.SKU;})
    }
    get accountName() {
        return getFieldValue(this.account.data, NAME_FIELD);
    }
    get operationExceptionRT(){
        const rtis = this.caseObjInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Operation Exception');
    }
    renderedCallback() {
        Promise.all([
            loadStyle(this, font + '/font-faces.css')
        ])
    }

    connectedCallback(){    

        loadStyle(this, font + '/font-faces.css')
        let orderDetails = {};
    
        this.orders =  Object.values(JSON.parse(decodeURIComponent(escape(atob(this.orders))))) ;
        if(this.orderNumber && this.orders){
            var value = this.orders.find(item => item.OrderNumber == this.orderNumber);
            orderDetails.OrderNumber = value.OrderNumber;
            orderDetails.AccountId = value.AccountId;
            orderDetails.StoreCode = value.StoreCode;
            orderDetails.OrderDate = value.OrderDate;
            orderDetails.OrderStatus = value.OrderStatus;

        }
        this.orderDetails = orderDetails ;  
    }
 
    navigateToStoreRecord(event){
        /*event.preventDefault();
        event.stopPropagation();*/
        var storeId = event.currentTarget.dataset.store;
        var sObject = 'Store__c';
        this.navigateToRecord(storeId, sObject);

    }
    navigateToAccountRecord(event){
        event.preventDefault();
        event.stopPropagation();
        var accountId = event.currentTarget.dataset.account;
        var sObject = 'Account';
        this.navigateToRecord(accountId, sObject);



    }
    navigateToRecord(Id, sObject){

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: Id,
                objectApiName: sObject,
                actionName: 'view',
            },
        })

    }
    openNewCaseHandler(event){
        let orderDet = this.orders.find(v=>v.OrderNumber == this.orderDetails.OrderNumber);
        const defaultValues = encodeDefaultFieldValues({
            Shipping_group__c: orderDet.ShippingNumber,
            Product_Sku__c: this.productMap.data[orderDet.Product.SKU],
            AccountId:this.orderDetails.AccountId,
            Country__c: this.storeCountry.data,
            Transaction_Id__c:this.orderDetails.OrderNumber,
            Origin_of_order__c: "Digital",
            Tracking_Number__c: orderDet.TrackingNumbers[0],
            Status:'Back Office New'
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                recordTypeId: this.operationExceptionRT

            }
        });
    }

    

}