import { LightningElement,api,track } from 'lwc';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import getOrders from '@salesforce/apex/ICX_Client360_SF.getOrders';
import imagesResource from '@salesforce/resourceUrl/iconics';
import { NavigationMixin } from 'lightning/navigation';
import {dateFormat2} from 'c/utils';


export default class Icx_orderTableOverview extends NavigationMixin(LightningElement) {

    @api sfRecordId;
    @api pageSize;
    @track pageIndex = 0;
    @track tableData = [];
    recordsListlength=0;
    isLoading = true;
    objectName = 'OrderLine__c';
    // condition = " WHERE Order__r.Account__c =: accountId AND ((OrderShipping__r.status__c='Fulfilled' AND  OrderShipping__r.StatusDate__c<= THIS_WEEK AND OrderShipping__r.StatusDate__c >=LAST_WEEK) OR OrderShipping__r.status__c!='Fulfilled')";
    // condition = " WHERE Order__r.Account__c =: accountId AND ((OrderShipping__r.status__c='Fulfilled' AND  OrderShipping__r.StatusDate__c =LAST_N_MONTHS:2) OR OrderShipping__r.status__c!='Fulfilled')";
    condition = " WHERE Order__r.Account__c =: accountId AND ((OrderShipping__r.status__c='Fulfilled' AND  OrderShipping__r.StatusDate__c >=:threeMonthAgo) OR OrderShipping__r.status__c!='Fulfilled')";


    connectedCallback()
    {
        
        this.tableData.title = {
            type: 'text',
            label: 'Orders',
            iconSrc: imagesResource + `/images/client360/ordersIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            titleClass: 'title-bold title-navigation cursor-pointer',
            hasLength: true,
            length: this.recordsListlength,
        }
        
        getrecordsListSize({accountId:this.sfRecordId ,objectName:this.objectName,condition:this.condition})  
            .then(result => {
                this.recordsListlength = result;
                this.tableData.title.length=this.recordsListlength;

            })
            .catch(error => {
                console.error('order list size error', error);
            });
        getOrders({ accountId: this.sfRecordId, pageSize: this.pageSize, pageIndex: this.pageIndex })
            .then((result) => {
                console.log(' connected order after', result);

                 
                    

                    this.tableData.rows = this.handleResultOrder(result);

                    console.log(' in global overview order',this.tableData.rows);
                    this.tableData.idList = result.map(order => order.Id);
                    this.isLoading= false;

                })
                .catch(error => {
                    console.error('get order global overview error', error);
                });
        }
    

    handleResultOrder(result)
    {
     
        console.log(' in handle result order',result)
        let newResults = result.map(order => {
                return order = [
                    // { value: order.orderDate.split('T')[0].replaceAll('-',' '), type: 'text', label: 'Order Date' },
                    { value: order.orderDate ? dateFormat2(order.orderDate?.split('T')[0].split('-')[0],order.orderDate.split('T')[0].split('-')[1],order.orderDate.split('T')[0].split('-')[2]):'-', type: 'text', label: 'Order Date' },

                    { value: order.orderNumber, type: 'text', label: 'Order Number' },
                    { value: order.sku, type: 'text', label: 'Product' },
                    { value: order.storeName, type: 'text', label: 'Store' },
                    { value: order.status, type: 'text', label: 'Status' },
                ]
            });
            return newResults;
    }

    navigateToOrder(event)
    {
        let orderId = this.tableData.idList[event.detail];
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: orderId,
                objectApiName: 'Order__c',
                actionName: 'view'
            },
        });
        
     //   slds-has-focus slds-is-active


    }

    navigateToViewListPage() {
        console.log('Try to navigate to a list')
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
            objectApiName: 'Account',
              recordId: this.sfRecordId,
              relationshipApiName: 'Orders__r',
              actionName: 'view'
            },
        });

     
    }
        
}