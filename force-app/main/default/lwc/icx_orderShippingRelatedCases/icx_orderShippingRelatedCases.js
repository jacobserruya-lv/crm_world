import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRelatedListRecords} from 'lightning/uiRelatedListApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getUserInfo from '@salesforce/apex/ICX_Account_Highlight.getUserInfo';

import USER_ID from '@salesforce/user/Id';


const tableColumns = [
    {label: 'Number', fieldName: 'linkToCase', type: 'url', typeAttributes: {label: { fieldName: 'caseNumber' }}},
    {label: 'Type', fieldName: 'type'},
    {label: 'Created Date', fieldName: 'createdDate', type: 'date'},
    {label: 'Status', fieldName: 'status'}
];

export default class Icx_orderShippingRelatedCases extends NavigationMixin(LightningElement) {
    @api 
    get orderdetailsapi(){
        return this._orderdetailsapi;
    };
    set orderdetailsapi(orderdetailsapi){
        this._orderdetailsapi = orderdetailsapi;        
    };

    @track _product;
    @api 
    get product(){
        return this._product;
    };
    set product(product){
        if (this._product?.shippingNumber != product.shippingNumber) {
            this.records = null;
            this.pageToken=null;
            this._product = product;
        }
    }

    error;
    records;
    hasMore;
    currentpageToken;
    nextPageToken;
    pageToken = null;    
    dataLoading = false;
    tableColumns = tableColumns;
    @track isUserBO=false;
    @track isUserIconics = false;

    
    @wire(getUserInfo, { userId : USER_ID  })
    wiredgetUserInfo({ error, data }) {
 
  
 
        if (data) {
            
            this.userDetails = data;
            this.error = undefined;
 
            if (this.userDetails && this.userDetails.Profile.Name.includes('ICONiCS') ) {
             this.isUserIconics= true;
         }else if(this.userDetails && this.userDetails.Profile.Name.includes('Admin') ){
             this.isUserIconics= true;
             this.isUserBO = true;
         }
         else if(this.userDetails && this.userDetails.Profile.Name.includes('Back_Office') ){
            this.isUserBO = true;
         }
         else{
             this.isUserIconics= false;
             this.isUserBO= false;
         }
 
        } else if (error) {
            this.error = error;    
 
            console.error(' error',this.error);
            
        }

    }  

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjInfo;

    // Get Case RecordType : "Operation Exception" 
    get operationExceptionRT(){
        const rtis = this.caseObjInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Operation Exception');
    }

    // I didn't find a way to do work this string directly at the @wire level. (It's why i created this function...)
    get wireWhereClause(){
        return ' {and:[{Order_Shipping__r: {ShippingNumber__c :{eq: '+this.product.shippingNumber+'}}} ]}';

        // return ' {or:[{ Shipping_group__c: { eq: '+this.product.shippingNumber+' }},{Order_Shipping__r: {ShippingNumber__c :{eq: '+this.product.shippingNumber+'}}} ]}';

        // return '{ and: [{ Shipping_group__c: { eq: '+this.product.shippingNumber+' }}] }';
        }

    // Retrieve Data
    // sortBy : by default the order is the type of "ASC", currently there is no parameter to order by "DESC" :-(
    // but I found workaround... I let you see the code...
    @wire(getRelatedListRecords, {
        parentRecordId: '$orderdetailsapi.account.Id',
        relatedListId: 'Cases',
        fields: ['Case.CaseNumber', 'Case.RecordType.Name', 'Case.CreatedDate', 'Case.Status'],
        sortBy : ['Case.CreatedDate DESC, CaseNumber'],
        pageSize: 25,
        pageToken: '$pageToken'
        ,where: '$wireWhereClause'
    })listInfo({ error, data }) {
        if (data) {
        //     console.log('JGU-@wire (dataLoading - before) : '+this.dataLoading);
            console.log('JGU-@wire (dataLoading - data) : '+JSON.stringify(data));

            let tempRecords = [];

            data.records.forEach( obj => {
                let tempRecord = {};
                tempRecord.id = obj.id;
                tempRecord.linkToCase = '/'+tempRecord.id;
                tempRecord.caseNumber = obj.fields.CaseNumber.value;
                tempRecord.type = obj.fields.RecordType.value.fields.Name.value;
                tempRecord.createdDate = obj.fields.CreatedDate.value;
                tempRecord.status = obj.fields.Status.value;
                tempRecords.push( tempRecord );
            } );

            // Add retrieved records to the current list of records already displayed
            if (this.records ==  null) this.records = tempRecords;
            else this.records = this.records.concat(tempRecords);

            this.currentpageToken = data.currentpageToken;
            this.nextPageToken = data.nextPageToken;
            this.hasMore = (this.nextPageToken != null);
            this.error = undefined;

        } else if (error) {
            // console.log('JGU-@wire | error: '+ error );
            // console.log(error);
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;

            }
            console.log('nao error related case os', this.error);

            this.record = undefined;
            this.records = undefined;
        }
        this.dataLoading = false;
        // console.log('JGU-@wire (dataLoading - after) : '+this.dataLoading);
    }

    loadMoreData(event) {
        if(this.hasMore)  {
            if(!this.dataLoading) {
                this.dataLoading = true;            
                // console.log('JGU-loadMoreData (dataLoading - before) : '+event);
                this.pageToken = this.nextPageToken;
                // console.log('JGU-loadMoreData (dataLoading - after) : '+this.dataLoading);
            }
        }
        else this.dataLoading = false;
    }

    /**
     * Handler for when the action "New Request" in "related list" component is executed 
     */
     handleNewRequest(event){
        const defaultValues = encodeDefaultFieldValues({
            // Shipping_group__c:  this.product.shippingNumber
            Order_Shipping__c:  this.product.reason.Id

            // ,Product_Sku__c:    this.product.skuListMap[this.product.SKU] // Product.Id
            ,Product_Sku__c:    this.product.productCatalogue?.Id // ProductCatalogue__c.Id
            ,AccountId:         this.orderdetailsapi.account.Id
            ,Country__c:        this.orderdetailsapi.store.StoreCountry__c
            ,Transaction_Id__c: this.orderdetailsapi.order_id
            ,Origin_of_order__c: this.orderdetailsapi.store.StoreType__c == 'Store' ?'Retail' :'Digital'
            ,Tracking_Number__c: this.product.shipment.tracking_number
            ,Status:            'Back Office New'
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

    get actionVisible()
    {
        return this.isUserIconics || this.isUserBO;
    }
}