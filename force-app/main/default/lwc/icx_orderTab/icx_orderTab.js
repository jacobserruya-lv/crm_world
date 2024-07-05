import {  LightningElement,wire,track,api } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';

import getOrders from '@salesforce/apex/ICX_Client360_SF.getOrders';
import {getGuidId,ToastError,dateFormat2} from 'c/utils';
import { NavigationMixin } from 'lightning/navigation';

export default class Icx_orderTab extends NavigationMixin(LightningElement) {


    @api recordId;
       
    myImageClass;
    pageSize =6;
    @track pageIndex = 0;

    @track isLoading = true;

    @track isMoreOrdersRecords = true;
    isLoadingMoreOrdersRecords = false;
    percentOnScroll = 95;

    recordsListlength=0;
    objectName = 'OrderLine__c';
    // condition = " WHERE Order__r.Account__c =: accountId AND ((OrderShipping__r.status__c='Fulfilled' AND  OrderShipping__r.StatusDate__c<= THIS_WEEK AND OrderShipping__r.StatusDate__c >=LAST_WEEK) OR OrderShipping__r.status__c!='Fulfilled')";
    // condition = " WHERE Order__r.Account__c =: accountId AND ((OrderShipping__r.status__c='Fulfilled' AND  OrderShipping__r.StatusDate__c<= THIS_WEEK AND OrderShipping__r.StatusDate__c >=LAST_N_MONTHS:2) OR OrderShipping__r.status__c!='Fulfilled')";
    condition = " WHERE Order__r.Account__c =: accountId AND ((OrderShipping__r.status__c='Fulfilled' AND  OrderShipping__r.StatusDate__c >=:threeMonthAgo) OR OrderShipping__r.status__c!='Fulfilled')";




    @track tableData = [];
    @track tableData2 = [];




    



    connectedCallback() {
    
     
        this.tableData.headers = [
            { type: 'image', label: 'Product Photo' },
            { type: 'text', label: 'Type'},
            { type: 'text', label: 'Order Date', },
            { type: 'text', label: 'Order Number',  },
            { type: 'text', label: 'Product SKU',  },
            { type: 'text', label: 'Store',  },
            { type: 'text', label: 'Store Code',  },
            { type: 'text', label: 'Status',  },
        ]
        this.tableData.hasHeaders = true;
        this.tableData2.title = {
            type: 'text',
            label: 'Orders',
            iconSrc: imagesResource + `/images/client360/ordersIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            titleClass: 'title-bold title-navigation cursor-pointer',
            hasLength: true,
            length: this.recordsListlength,
        }

        getrecordsListSize({accountId:this.recordId ,objectName:this.objectName,condition:this.condition})  
            .then(result => {
                this.recordsListlength = result;
                this.tableData2.title.length=this.recordsListlength;

            })
            .catch(error => {
                console.error('order list size error', error);
            });

        //no filter for mvp
        // this.tableData.headers = [
        //     { type: 'image', label: 'Product Photo' },
        //     // { type: 'text', label: 'Type', isWithFilter: true },
        //     { type: 'text', label: 'Order Date', isWithFilter: true },
        //     { type: 'text', label: 'Order Number', isWithFilter: true },
        //     { type: 'text', label: 'Product', isWithFilter: true },
        //     { type: 'text', label: 'Store', isWithFilter: true },
        //     { type: 'text', label: 'Store Code', isWithFilter: true },
        //     { type: 'text', label: 'Status', isWithFilter: true },
        // ]
        

        this.getOrdersSF();
   
    }

 


    getOrdersSF() {

       
        if (this.isMoreOrdersRecords && !this.isLoadingMoreOrdersRecords) {


          

            this.isLoadingMoreOrdersRecords=true;

           

            getOrders({accountId:this.recordId, pageSize: this.pageSize, pageIndex: this.pageIndex})
            .then((result)=>{

                console.log('result on getOrderSF', JSON.stringify(result));

           

                const newResults = this.handleResultOrder(result)

            

                console.log(' this.tableData.rows before ', this.tableData.rows)
           

                    if(!this.tableData.rows)
                    {
                        if(newResults.length>0)
                        {

                            this.tableData.rows=newResults;
                        }
                    }
                    else{
                        for(let i = 0; i<newResults.length;i++){
                            this.tableData.rows.push(newResults[i]);
                        }

                    }
                    if(!this.tableData.idList)
                    {
                        this.tableData.idList = result.map(order => order.Id);

                    }
                    else{
                        for(let i = 0; i<result.length;i++){
                            this.tableData.idList.push(result[i].Id);
                        }
                    }


                if( result.length < this.pageSize )
                {
                    this.isMoreOrdersRecords=false;
                }
             console.log(' this.tableData.rows after ', this.tableData.rows)
             

          


            })
            .catch((error) => {
                 console.error('more orders records error', error);
                 ToastError(error,this);

               

        })
        .finally(()=>{
            this.isLoadingMoreOrdersRecords=false;
            this.isLoading=false;
            this.pageIndex =parseInt(this.pageIndex) + parseInt(this.pageSize);       
            console.log('pageIndex new bis', this.pageIndex)
        })
      }
    
    }

    handleResultOrder(result)
    {
     
        console.log(' in handle result order tab',result)

         const imagePlaceholder = imagesResource+'/images/imgUndefinedLV.png';

         const newResults = result.map(order => {
            return order = [
                { value: order.productImage ? order.productImage : imagePlaceholder, type: 'image', label: 'Photo', isImageType: true },
                { value: order.type ? order.type : '-', type: 'text', label: 'Type' },

                // { value: order.orderDate ? order.orderDate.split('T')[0].replaceAll('-',' '): '-', type: 'text', label: 'Order Date' },
                { value: order.orderDate ? dateFormat2(order.orderDate?.split('T')[0].split('-')[0],order.orderDate.split('T')[0].split('-')[1],order.orderDate.split('T')[0].split('-')[2]):'-', type: 'text', label: 'Order Date' },

                { value: order.orderNumber ? order.orderNumber : '-', type: 'text', label: 'Order Number' },
                { value: order.sku ? order.sku : '-', type: 'text', label: 'Product' },
                { value: order.storeName ? order.storeName : '-', type: 'text', label: 'Store' },
                { value: order.retailStoreId ? order.retailStoreId : '-', type: 'text', label: 'Store Code' },
                { value: order.status ? order.status : '-', type: 'text', label: 'Status' },
            ]
        });

    console.log('new result order : ', newResults);
        return newResults;
    }

    checkScroll(e) {
        console.log('checkscroll event ',JSON.stringify(e))
        const elementScrolled = this.template.querySelector(`[data-id="tableOrderContainer"]`);
        const heightScrolled = elementScrolled.scrollHeight;
        const totalHeightOfElement = elementScrolled.clientHeight;
        const heightToCallApi = (this.percentOnScroll / 100) * totalHeightOfElement;
        console.log('totalHeightOfElement Scroll ', totalHeightOfElement)

        console.log('heightToCallApi', heightToCallApi)
        console.log('heightScrolled', heightScrolled)

      
        if(heightScrolled >= heightToCallApi && this.isMoreOrdersRecords && !this.isLoadingMoreOrdersRecords)
        {
            console.log('The loading function is about to get triggred', heightScrolled)

            this.getOrdersSF()
        }

        
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
    }

    navigateToViewListPage() {
        console.log('Try to navigate to a list')
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
            objectApiName: 'Account',
              recordId: this.recordId,
              relationshipApiName: 'Orders__r',
              actionName: 'view'
            },
        });

     
    }

}