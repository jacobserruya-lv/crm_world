import { LightningElement,api,track} from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ICX_AcceptQuotation extends LightningElement {
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
                MYLV_Care_Status__c:'preliminary_assessment_acc',
                Last_MYLV_Care_Status_Changed_Date__c : this.today.toISOString()
            }
        };
        updateRecord(record)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Quotation is accepted',
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