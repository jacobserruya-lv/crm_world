import { LightningElement,api,wire, track} from 'lwc';
import { getRecord,getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AMOUNT_FIELD from '@salesforce/schema/CareService__c.TotalAmount_Updated__c';
import CURRENCY_FIELD from '@salesforce/schema/CareService__c.CurrencyCode__c';
import updateCareService from '@salesforce/apex/ICX_RequestPaymentCtrl.requestPayment';

const fields = [AMOUNT_FIELD, CURRENCY_FIELD];
export default class ICX_RequestPayment extends LightningElement {
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
       /* let record = {
            fields: {
                Id: this.recordId,
                ICONiCS_Status_Detail__c:'Confirm Address',
                Last_ICONiCS_Status_Changed_Date__c:this.today.toISOString(),
                Confirm_Address_Send_Date__c:this.today.toISOString(),
                MyRepairStatus__c:'clientContacted',
                Last_MyRepair_Status_Changed_Date__c : this.today.toISOString()
            }
        };*/
        updateCareService ({careServiceId: this.recordId})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Payment request has been sent to the client',
                    variant: 'success',
                    mode: 'pester'
                }),
            );
            this.dispatchEvent(new CloseActionScreenEvent());  
            setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
       }, 1000); 
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