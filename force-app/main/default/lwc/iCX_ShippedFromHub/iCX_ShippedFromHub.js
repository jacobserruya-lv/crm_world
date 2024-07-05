import { LightningElement,api,wire, track} from 'lwc';
import { getRecord,getFieldDisplayValue,updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DESTINATION_FIELD from '@salesforce/schema/CareService__c.destination__c';

const fields = [DESTINATION_FIELD];
export default class ICX_ShippedFromHub extends LightningElement {  
    @api recordId;
    @api today;
    @track myDestination;
    

    @wire(getRecord, { recordId: '$recordId', fields })   
	currentRecord({error, data}){
        console.log('loadFields, recordId: ', this.recordId);
        if(error){
            console.log('error', JSON.parse(JSON.stringify(error)));
        }else if(data){
            console.log('data', JSON.parse(JSON.stringify(data)));
            this.myDestination = getFieldDisplayValue(data, DESTINATION_FIELD);
           
            console.log('myDestination display', getFieldDisplayValue(data, DESTINATION_FIELD));
        }
    }

    closeAction(){
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  saveAction(){
   this.today = new Date();
    console.log('Execution Start');               
    let record = {
        fields: {
            Id: this.recordId,
            ICONiCS_Status_Detail__c:'Shipped from E-Hub',
            Last_ICONiCS_Status_Changed_Date__c:this.today.toISOString(),
            
        }
    };
    updateRecord(record)
    .then(() => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Care Service is shipped from E-Hub',
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