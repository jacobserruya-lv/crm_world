import { LightningElement,api,wire,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord,getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserName from '@salesforce/schema/User.Name';
import currentUserRMSID from '@salesforce/schema/User.RMS_ID__c';
import { publish, MessageContext } from 'lightning/messageService';
import PING_PONG_CHANNEL from '@salesforce/messageChannel/CareServiceAppointment__c';
export default class ICX_TakeChargeCareService extends LightningElement {
    @api recordId;
    @track isExecuting = false;  
    subscription = null;
    selectedUser = null;

    @wire(MessageContext)    
    messageContext;
    sendMessage(event) {
        const payload = { 
            careId: this.recordId           
        };
        publish(this.messageContext, PING_PONG_CHANNEL, payload);
    }

    

    handleSelection(event){
        this.selectedUser = event.target.value;
    }

     closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }

      saveAction(){
        console.log('Execution Start');      

   
    this.isExecuting = true;
        let record = {
            
            fields: {
                Id: this.recordId,         
                Assigned_To__c:this.selectedUser                
            }
            
        };
     updateRecord(record)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Care Service has been assigned to selected user',
                    variant: 'success',
                    mode: 'pester'
                }),
            ); 
            this.dispatchEvent(new CloseActionScreenEvent());  
            this.sendMessage();         
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
       
       console.log('Execution Send msg');
      
}
}