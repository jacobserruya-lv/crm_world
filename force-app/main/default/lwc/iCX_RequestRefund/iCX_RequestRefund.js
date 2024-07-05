import { LightningElement,api,wire,track} from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { createRecord,getRecord,getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createRefund from '@salesforce/apex/ICX_WS_IXOPAY.createRefund';
import REFUND_AMOUNT_FIELD from '@salesforce/schema/CareService__c.Refund_Amount__c';
const fields = [REFUND_AMOUNT_FIELD];

export default class ICX_RequestRefund extends LightningElement {
    @track showConfirmation = true;
    @api recordId;
    @api now;
    @api arrayOfStrings;
    @track myUuid;
    @track myCurrency;
    @track myAmount;
    
   /* @api async invoke() {
        if (this.isExecuting) {
            return;
        }  */
        @wire(getRecord, { recordId: '$recordId', fields })   
        currentRecord({error, data}){
            console.log('loadFields, recordId: ', this.recordId);
            if(error){
                console.log('error', JSON.parse(JSON.stringify(error)));
            }else if(data){
                console.log('data', JSON.parse(JSON.stringify(data)));
                this.myAmount = getFieldValue(data, REFUND_AMOUNT_FIELD);
                this.myCurrency = getFieldValue(data, CURRENCY_FIELD);
                console.log('refund ammount', this.myAmount);
               
            }
        }

        @wire(getRelatedListRecords, {
            parentRecordId: '$recordId',
            relatedListId: 'Ixopay_Transactions__r',
            fields: ['Ixopay_Transaction__c.uuid__c','Ixopay_Transaction__c.Amount__c','Ixopay_Transaction__c.Currency__c'],
            where: "{ and: [{Status__c: {eq: \"Success\" }},{Transaction_Type__c: {eq: \"DEBIT\" }}]}"
        })       
        listInfo({ error, data }) {
            console.log('START');
            if (data) {
                this.myUuid = data.records[0].fields.uuid__c.value;
                this.myCurrency = data.records[0].fields.Currency__c.value;
                //this.myAmount = data.records[0].fields.Amount__c.value;
                console.log(JSON.stringify(data));
            } else if (error) {
                console.log('error', JSON.parse(JSON.stringify(error)));
            }
        }
        closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }
     
    saveAction(){
        this.showConfirmation = false;
       this.now = new Date();
       console.log('START CREATE REFUND');      
        
       createRefund ({
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
                  const fields = {               
                    Application__c:'Distant Care Service',
                    Record_Id__c:this.recordId,
                    Apex_Class__c:'ICX_WS_IXOPAY',                  
                    Has_Error__c:true,
                    Error__c:result
                }
                const recordInput = { apiName: 'Logs__c', fields };
                createRecord(recordInput)
                    .then(() => {
                        console.log('log insert success'); 
                    })
                    .catch(error => {
                        console.log('log insert error'+JSON.stringify(error));
                    });
           }else{
                /* this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Refund request has been sent.',
                            variant: 'success',
                            mode: 'pester'
                        }),
                    );
                    this.dispatchEvent(new CloseActionScreenEvent());    
             */
            const fields = {
                uuid__c:this.myUuid,
                Amount__c:this.myAmount,
                Currency__c:this.myCurrency,
                Status__c:'Initiated',
                Statut_Date__c:this.now.toISOString(),
                Transaction_Type__c:'REFUND',
                Care_Service__c:this.recordId
            }
            const recordInput = { apiName: 'Ixopay_Transaction__c', fields };
            createRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Refund request has been sent.',
                            variant: 'success',
                            mode: 'pester'
                        }),
                    );
                    this.dispatchEvent(new CloseActionScreenEvent());    
                })
                .catch(error => {
                    console.log('Refund insert error'+JSON.stringify(error));
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
        console.log('My error'+error); 
    });

   
      
       
    }  
}