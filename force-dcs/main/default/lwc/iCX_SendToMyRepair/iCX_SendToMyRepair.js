import { LightningElement,api,wire, track} from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createRepairOrderMyRepair from '@salesforce/apex/ICX_WS_MyRepair.createRepairOrder';

export default class ICX_sendToMyRepair extends LightningElement {
    @track showConfirmation = true;
    @api recordId;
    @api today;
    @api arrayOfStrings;
    isExecuting = false;    
   /* @api async invoke() {
        if (this.isExecuting) {
            return;
        }  */
        closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }
     
      
    saveAction(){
        this.showConfirmation = false;
       this.today = new Date();

        console.log('Execution Start');
        
     createRepairOrderMyRepair ({
        careId:this.recordId
    })
    .then(result  => {
        console.log('Apex result '+ result);         
           if(result.includes("Error")||result==null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error on callout',
                    message: result,
                    variant: 'error',
                    mode: 'dismissable'
                }),
            ); 
                  this.dispatchEvent(new CloseActionScreenEvent()); 
           }else{
            this.arrayOfStrings = result.split(';');
            let record = {
                fields: {
                    Id: this.recordId, 
                    TransactionId__c : this.arrayOfStrings[0], 
                    ExternalId__c : this.arrayOfStrings[1],
                    MyRepair_Error__c : '',
                    MyRepairStatus__c : 'draft',
                    Last_MyRepair_Status_Changed_Date__c:this.today.toISOString(),
                    ICONiCS_Status_Detail__c : 'Initiated in MyRepairs as a Draft',        
                    Last_ICONiCS_Status_Changed_Date__c:this.today.toISOString(),
                    MyRepair_CreatedDate__c:this.today.toISOString()
                }
            };
           updateRecord(record)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Care Service has been sent to MyRepair',
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
                    this.dispatchEvent(new CloseActionScreenEvent()); 
                });
           }

    })
    .catch((error) => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error on data save',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            }),
        );
        this.dispatchEvent(new CloseActionScreenEvent());  
    });

   
      
       
    }  
}