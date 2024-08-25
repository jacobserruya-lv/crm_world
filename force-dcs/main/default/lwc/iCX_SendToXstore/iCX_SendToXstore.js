import { LightningElement,api,wire, track} from 'lwc';
import { getRecord,getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AMOUNT_FIELD from '@salesforce/schema/CareService__c.TotalAmount_Updated__c';
import CURRENCY_FIELD from '@salesforce/schema/CareService__c.CurrencyCode__c';
const fields = [AMOUNT_FIELD, CURRENCY_FIELD];

export default class ICX_SendToXstore extends LightningElement {  
    @api recordId;
    @api today;
    @track myAmount;
    @track myCurrency;

    @wire(getRecord, { recordId: '$recordId', fields })   
	currentRecord({error, data}){
        console.log('loadFields, recordId: ', this.recordId);
        if(error){
            console.log('error', JSON.parse(JSON.stringify(error)));
        }else if(data){
            console.log('data', JSON.parse(JSON.stringify(data)));
            this.myAmount = getFieldValue(data, AMOUNT_FIELD);
            this.myCurrency = getFieldValue(data, CURRENCY_FIELD);
            console.log('ammount', this.myAmount);
            console.log('currency', this.myCurrency);
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
            MyRepairStatus__c:'sentToRMS',
            Last_MyRepair_Status_Changed_Date__c:this.today.toISOString(),
            
        }
    };
    updateRecord(record)
    .then(() => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Care Service is sent to Xstore',
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