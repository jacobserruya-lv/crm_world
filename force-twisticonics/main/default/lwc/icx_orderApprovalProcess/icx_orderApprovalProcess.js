import { LightningElement, api } from 'lwc';
import getRelatedApprovalCases from '@salesforce/apex/OrderNoteService.getRelatedApprovalCases'

export default class Icx_orderApprovalProcess extends LightningElement {
    @api orderdetailsapi;

    approvalProcesses;
    error;

    tableColumns = [
        {label: 'Number', fieldName: 'linkToCase', type: 'url', typeAttributes: {label: { fieldName: 'caseNumber' }}},
        {label: 'Type', fieldName: 'approvalType'},
        {label: 'Created Date', fieldName: 'createdDate', type: 'date', typeAttributes:{year: '2-digit', month: "2-digit", day: "2-digit"}},
        {label: 'Status', fieldName: 'status'}
    ]

    connectedCallback() { 
        getRelatedApprovalCases({orderNumbers: this.orderdetailsapi.order_id})
        .then(result => {
            console.log('result :'+result);
            console.log('result :'+JSON.stringify(result));

            let tempRecords = [];
            result.forEach( obj => {
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
        })
        .catch(error => {
            console.log('error.message: ' + error.message);
            this.error = error;
            this.approvalProcesses = undefined;
        })
    }
}