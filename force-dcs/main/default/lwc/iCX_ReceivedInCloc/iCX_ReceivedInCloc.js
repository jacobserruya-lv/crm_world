import { LightningElement,api,wire, track} from 'lwc';
import { getRecord,getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ICX_ReceivedInCloc extends LightningElement {  
    @api recordId;
    @api today;

    closeAction(){
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  saveAction(){
   this.today = new Date();
    console.log('Execution Start');               
    let record = {
        fields: {
            Id: this.recordId,
            ICONiCS_Status_Detail__c:'Received In E-Hub',
            Last_ICONiCS_Status_Changed_Date__c:this.today.toISOString(),
            
        }
    };
    updateRecord(record)
    .then(() => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Care Service is received in E-Hub',
                variant: 'success',
                mode: 'pester'
            }),
        );
        this.dispatchEvent(new CloseActionScreenEvent());  
 
    })
    .catch(error => {
        console.log('Error '+error.body); 
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error on update",
                message: error.body.message,
                variant: "error"
              }),
        );
        this.dispatchEvent(new CloseActionScreenEvent());  
    });
  
    
}  
}