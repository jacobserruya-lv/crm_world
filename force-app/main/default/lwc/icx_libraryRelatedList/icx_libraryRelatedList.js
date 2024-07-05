import { LightningElement, api, track} from 'lwc';


export default class Icx_libraryRelatedList extends LightningElement {
    @api title;
    @api isloading; // boolean to display or not the loading spinner
    @api actions; // Object {label:'', click:''}
    @api actionlabel; // Object {label:'', click:''}
    //@api actionclick; // Object {label:'', click:''}
    @api records; // array of object
    @api tablecolumns; // array of object
    @api hasmore; // boolean
    @api actionvisible;

    // Sum of records displayed
    get totalRecords() {
        return this.records.length;
    }; 

    // Allow to manage dynamicly the height
    get setDatatableHeight() {
        // if no records
        if(this.totalRecords==0){//set the minimum height
            return 'height:2rem;';
        }
        // if more than 5 records
        else if(this.totalRecords>5){//set the max height
                return 'height:11rem;';
        }
        // in other cases
        return '';//don't set any height (height will be dynamic)
    }

    // 
    loadMoreData(event) {     
        const loadMoreDataEvent = new CustomEvent('loadmore', {
            detail: event
        });  
        this.dispatchEvent(loadMoreDataEvent);
    }

    // Executed when click on "actionLabel"
    handleClick() {
        // dispatch event
        const selectedEvent = new CustomEvent('actionclick', {
            detail: this.shippinggroup
        });  
        this.dispatchEvent(selectedEvent);
    }

}

// ---------------------------------------------------------------------------------------------------------------------------------------------

// import { LightningElement, wire, api } from 'lwc';
// import { NavigationMixin } from 'lightning/navigation';
// import { getRelatedListRecords} from 'lightning/uiRelatedListApi';
// import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// import CASE_OBJECT from '@salesforce/schema/Case';

// const tableColumns = [
//     {label: 'Number', fieldName: 'linkToCase', type: 'url', typeAttributes: {label: { fieldName: 'caseNumber' }, target: '_blank'}},
//     {label: 'Type', fieldName: 'type'},
//     {label: 'Created Date', fieldName: 'createdDate', type: 'date'},
//     {label: 'Status', fieldName: 'status'}
// ];

// export default class Icx_libraryRelatedList extends NavigationMixin(LightningElement)  {
//     @api accountid;
//     @api shippinggroup;
//     @api columntitles = ['Id', 'Name'];
//     @api columndataname = ['Case.Id', 'Case.AccountId'];

//     @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
//     caseObjInfo;

//     get operationExceptionRT(){
//         const rtis = this.caseObjInfo.data.recordTypeInfos;
//         return Object.keys(rtis).find(rti => rtis[rti].name === 'Operation Exception');
//     }

//     // Number => CaseNumber
//     // Type => RecordTypeId
//     // Created Date => CreatedDate
//     // Status => Status
//     tableColumns = tableColumns;

// // /?\ TODO /?\ https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/documentation#:~:text=Using%20Infinite%20Scrolling%20to%20Load%20More%20Rows

//     error;
//     records;
//     totalRecords = 0;
//     hasMore;
//     currentpageToken;
//     nextPageToken;
//     previousPageToken;
//     pageToken = null;    
//     dataLoading = false;

//     @wire(getRelatedListRecords, {
//         parentRecordId: '0010200000E9a9IAAR',
//         relatedListId: 'Cases',
//         fields: ['Case.CaseNumber', 'Case.RecordType.Name', 'Case.CreatedDate', 'Case.Status'],
//         pageSize: 25,
//         pageToken: '$pageToken'
//     })listInfo({ error, data }) {
//         if (data) {            
//             // console.log('JGU-RL Case | data: '+JSON.stringify(data));

//             console.log('JGU-@wire (dataLoading - before) : '+this.dataLoading);

//             let tempRecords = [];

//             data.records.forEach( obj => {
//                 let tempRecord = {};
//                 tempRecord.id = obj.id;
//                 tempRecord.linkToCase = '/'+tempRecord.id;
//                 tempRecord.caseNumber = obj.fields.CaseNumber.value;
//                 tempRecord.type = obj.fields.RecordType.value.fields.Name.value;
//                 tempRecord.createdDate = obj.fields.CreatedDate.value;
//                 tempRecord.status = obj.fields.Status.value;
//                 tempRecords.push( tempRecord );
//             } );

//             if (this.records ==  null) this.records = tempRecords;
//             else this.records = this.records.concat(tempRecords);

//             this.totalRecords = this.records.length;
//             console.log('JGU-@wire (totalRecords) : '+this.totalRecords);
//             this.currentpageToken = data.currentpageToken;
//             this.nextPageToken = data.nextPageToken;
//             this.previousPageToken = data.previousPageToken;
//             this.hasMore = (this.nextPageToken != null);
//             this.error = undefined;

//         } else if (error) {
//             console.log('JGU-@wire | error: '+ error );
//             this.error = 'Unknown error';
//             if (Array.isArray(error.body)) {
//                 this.error = error.body.map(e => e.message).join(', ');
//             } else if (typeof error.body.message === 'string') {
//                 this.error = error.body.message;
//             }
//             this.record = undefined;
//             this.records = undefined;
//         }
//         this.dataLoading = false;
//         console.log('JGU-@wire (dataLoading - after) : '+this.dataLoading);
//     }

//     handleNextPageClick() {
//         if(this.hasMore)
//             this.pageToken = this.nextPageToken;
//         else this.dataLoading = false;
//     }
    
//     // handlePreviousPageClick() {
//     //     this.pageToken = this.previousPageToken;
//     // }

//     handleClick() {
//         alert('JGU-handleClick()');
//         // dispatch event
//         const selectedEvent = new CustomEvent('actionclick', {
//             detail: this.shippinggroup
//         });  
//         this.dispatchEvent(selectedEvent);
//         // let orderDet = this.orders.find(v=>v.OrderNumber == this.orderDetails.OrderNumber);
//         // const defaultValues = encodeDefaultFieldValues({
//         //     Shipping_group__c: orderDet.ShippingNumber,
//         //     Product_Sku__c: this.productMap.data[orderDet.Product.SKU],
//         //     AccountId:this.orderDetails.AccountId,
//         //     Country__c: this.storeCountry.data,
//         //     Transaction_Id__c:this.orderDetails.OrderNumber,
//         //     Origin_of_order__c: "Digital",
//         //     Tracking_Number__c: orderDet.TrackingNumbers[0],
//         //     Status:'Back Office New'
//         // });
//         // this[NavigationMixin.Navigate]({
//         //     type: 'standard__objectPage',
//         //     attributes: {
//         //         objectApiName: 'Case',
//         //         actionName: 'new'
//         //     },
//         //     state: {
//         //         defaultFieldValues: defaultValues,
//         //         recordTypeId: this.operationExceptionRT

//         //     }
//         // });
//     }

//     loadMoreData(event) {
//         //Display a spinner to signal that data is being loaded
//         // if (this.pageLoaded == true) event.target.isLoading = true;
// //        setTimeout(handleNextPageClick(),1000);
//         //Display "Loading" when more data is being loaded
// //        this.loadMoreStatus = 'Loading';
// //        console.log('loadMoreData - begin');
//         if(this.hasMore && !this.dataLoading)  {
//             this.dataLoading = true;
            
//             console.log('JGU-loadMoreData (dataLoading - before) : ');
//             this.handleNextPageClick();
//             console.log('JGU-loadMoreData (dataLoading - after) : '+this.dataLoading);
//         }
        
//         //if (event.target.isLoading == true) event.target.isLoading = false;
// //        event.target.isLoading = false;
//         // fetchData(50).then((data) => {
//         //     if (data.length >= this.totalNumberOfRows) {
//         //         event.target.enableInfiniteLoading = false;
//         //         this.loadMoreStatus = 'No more data to load';
//         //     } else {
//         //         const currentData = this.data;
//         //         //Appends new data to the end of the table
//         //         const newData = currentData.concat(data);
//         //         this.data = newData;
//         //         this.loadMoreStatus = '';
//         //     }
//         //     event.target.isLoading = false;
//         // });
//     }
// }