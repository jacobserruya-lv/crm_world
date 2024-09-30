import { LightningElement, wire, api, track } from 'lwc';
import getRelatedApprovalCases from '@salesforce/apex/OrderNoteService.getRelatedApprovalCases'
import { refreshApex } from '@salesforce/apex';

export default class Icx_orderApprovalProcess extends LightningElement {
    
    @api     
    get orderdetailsapi() {
        return this._orderdetailsapi;
    }
    set orderdetailsapi(orderdetailsapi) {
        console.log('Icx_orderApprovalProcess - @api orderdetailsapi : ' + orderdetailsapi);
        this._orderdetailsapi = orderdetailsapi;
        refreshApex(this.wiredRelatedApprovalCasesList);
    };

    @api 
    get orderid() {
        return this.orderdetailsapi?.order_id;
    } 
    
    @track _orderdetailsapi;
    @track wiredRelatedApprovalCasesList;

    approvalProcesses;
    error;

    tableColumns = [
        {label: 'Number', fieldName: 'linkToCase', type: 'url', typeAttributes: {label: { fieldName: 'caseNumber' }}},
        {label: 'Type', fieldName: 'approvalType'},
        {label: 'Created Date', fieldName: 'createdDate', type: 'date', typeAttributes:{year: '2-digit', month: "2-digit", day: "2-digit"}},
        {label: 'Status', fieldName: 'status'}
    ]

    // connectedCallback() { 
    //     getRelatedApprovalCases({orderNumbers: this.orderdetailsapi.order_id})
    //     .then(result => {

    //         this.wiredRelatedApprovalCasesList = result;

    //         console.log('result :'+result);
    //         console.log('result :'+JSON.stringify(result));

    //         let tempRecords = [];
    //         result.forEach( obj => {
    //             let tempRecord = {};
    //             tempRecord.id = obj.Id;
    //             tempRecord.linkToCase = '/'+tempRecord.id;
    //             tempRecord.caseNumber = obj.CaseNumber;
    //             tempRecord.approvalType = obj.ApprovalTypeLabel;
    //             tempRecord.createdDate = obj.CreatedDate;
    //             tempRecord.status = obj.Status;
    //             tempRecords.push( tempRecord );
    //         } );

    //         console.log('result approval:'+tempRecords);
    //         console.log('result approval:'+JSON.stringify(tempRecords));

    //         if (tempRecords.length > 0) {
    //             this.approvalProcesses = tempRecords;
    //         }
    //     })
    //     .catch(error => {
    //         console.log('error.message: ' + error.message);
    //         this.error = error;
    //         this.approvalProcesses = undefined;
    //     })
    // }

    @wire(getRelatedApprovalCases, {orderNumbers: "$orderid"}) 
    relatedApprovalCasesRecords(result) {
        this.wiredRelatedApprovalCasesList = result;
        console.log('Icx_orderApprovalProcess - relatedApprovalCasesRecords : result ' + result);
        console.log('Icx_orderApprovalProcess - relatedApprovalCasesRecords : JSON.stringify(result) ' + JSON.stringify(result));
        console.log('Icx_orderApprovalProcess - relatedApprovalCasesRecords : result.data ' + result.data);
        console.log('Icx_orderApprovalProcess - relatedApprovalCasesRecords : JSON.stringify(result.data) ' + JSON.stringify(result.data));
        if (result.data) {
            console.log('Icx_orderApprovalProcess - relatedApprovalCasesRecords : result.data ' + result.data);
            let tempRecords = [];
            result.data.forEach( obj => {
                let tempRecord = {};
                tempRecord.id = obj.Id;
                tempRecord.linkToCase = '/'+tempRecord.id;
                tempRecord.caseNumber = obj.CaseNumber;
                tempRecord.approvalType = obj.ApprovalTypeLabel;
                tempRecord.createdDate = obj.CreatedDate;
                tempRecord.status = obj.Status;
                tempRecords.push( tempRecord );
            } );

            console.log('result approval:'+tempRecords);
            console.log('result approval:'+JSON.stringify(tempRecords));

            if (tempRecords.length > 0) {
                this.approvalProcesses = tempRecords;
            }
        } else if (result.error) {
            // console.log('JGU-@wire | error: '+ error );
            // console.log(error);
            console.log('Icx_orderApprovalProcess - relatedApprovalCasesRecords : result.error ' + result.error);
            console.log('Icx_orderApprovalProcess - relatedApprovalCasesRecords : JSON.stringify(result.error) ' + JSON.stringify(result.error));
            this.error = 'Unknown error';
            if (Array.isArray(result.error.body)) {
                this.error = result.error.body.map(e => e.message).join(', ');
            } else if (typeof result.error.body.message === 'string') {
                this.error = result.error.body.message;
            }
            this.records = undefined;
        }
   }
}