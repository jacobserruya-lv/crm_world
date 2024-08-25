import { LightningElement,api,track} from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ICX_SendQuotation extends LightningElement {
    @api recordId;
    @api today;
   
    isExecuting = false;  
      
        closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }

      saveAction(){
       this.today = new Date();
        console.log('Execution Start');               
        let record = {
            fields: {
                Id: this.recordId,
                ICONiCS_Status_Detail__c:'Preliminary Quote Pending Validation',
                Last_ICONiCS_Status_Changed_Date__c:this.today.toISOString(),
                Quotation_sent_date__c:this.today.toISOString(),
                MYLV_Care_Status__c:'preliminary_assessment',
                Last_MYLV_Care_Status_Changed_Date__c : this.today.toISOString()
            }
        };
        updateRecord(record)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Care Service is Preliminary Quote Pending Validation, an email has been sent to the client',
                    variant: 'success',
                    mode: 'pester'
                }),
            );
            this.dispatchEvent(new CloseActionScreenEvent());  
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error on data save',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                }),
            );
        });
      
        
    }  
}