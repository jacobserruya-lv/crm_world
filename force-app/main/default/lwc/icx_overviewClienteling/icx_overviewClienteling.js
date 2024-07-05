import { LightningElement,api, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import imagesResource from "@salesforce/resourceUrl/iconics";
import getrecordsListSize from "@salesforce/apex/ICX_Client360_SF.getrecordsListSize";
import getClientelingRecords from "@salesforce/apex/ICX_Client360_SF.getClientelingRequests";
import { dateFormat2 } from "c/utils";

export default class Icx_overviewClienteling extends NavigationMixin(LightningElement){
    @api sfRecordId;
    @track tableData = [];
    @track recordsListLength;

    objectName = 'Case';
    condition = 'WHERE AccountId =: accountId AND recordType.Name = \'Clienteling\' AND Status = \'New\'';

    @wire(getrecordsListSize, {accountId: '$sfRecordId', objectName: '$objectName', condition: '$condition'})
    wiredRecordListSize({error, data}){
        if(data){
            this.recordsListLength = data;
        }else{
            this.recordsListLength = 0;
        }
        if(error){
            console.log('There is an error occured during getRecordsListSize: '+ error);
        }
    }

    @wire(getClientelingRecords, {accountId: '$sfRecordId'})
    wiredClientelingRecords({error, data}){
        this.tableData.title = {
            type: "text",
            label: "Clienteling Outreach",
            iconSrc: imagesResource + `/images/client360/requestIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            hasLength: true,            
            length: this.recordsListLength,
            titleClass: "title-bold"
        }
        if(data && data!==null){
            this.tableData.rows = data.map(request => {
                return (request = [
                    {  value: request.CaseNumber, type: "text-top", label: "Number" },
                    {  value: request.RecordType.Name, type: "text", label: "Type" },
                    {  value: dateFormat2(
                        request.CreatedDate.split("T")[0].split("-")[0],
                        request.CreatedDate.split("T")[0].split("-")[1],
                        request.CreatedDate.split("T")[0].split("-")[2]
                        ),type: "text",label: "Created Date"},
                    {  value: request.Status, type: "text", label: "Status" }
                ]);
            });

            this.tableData.idList = data.map((request) => request.Id);
            
        }

        if(error){
            console.log('There is an error occured during getClientelingRecords: '+ error);
        }
    }

    navigateToClientelingRecord(event) {
        let clientelingId = this.tableData.idList[event.detail];
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: clientelingId,
            objectApiName: "Case",
            actionName: "view"
          }
        });
  
      }
}