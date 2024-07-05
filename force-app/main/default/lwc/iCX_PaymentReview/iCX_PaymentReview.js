import { LightningElement,api,wire, track} from 'lwc';
import { createRecord,updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPBL from '@salesforce/apex/ICX_WS_IXOPAY.createPaymentReviewPBL';

export default class ICX_PaymentReview extends LightningElement {  
    @api recordId;
    @api today;
    @api now;
    @api arrayOfStrings;

    closeAction(){
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  saveAction(){
   this.today = new Date();
   this.now = new Date();
    console.log('Execution Start'); 
    
    createPBL ({
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
           }else {
            this.arrayOfStrings = result.split(';');
            //Insert Ixopay transaction
            const fields = {
                uuid__c:this.arrayOfStrings[0],
                Status__c:'Initiated',
                Statut_Date__c:this.now.toISOString(),
                Transaction_Type__c:'DEBIT',
                Care_Service__c:this.recordId
            }
            const recordInput = { apiName: 'Ixopay_Transaction__c', fields };
            createRecord(recordInput)
                .then(() => {
                    console.log('ixopay transaction insert success');      
                })
                .catch(error => {
                    console.log('ixopay transaction insert error'+JSON.stringify(error));
                   
                });

                //Update Care service 
            let record = {
                fields: {
                            Id: this.recordId,
                            ICONiCS_Status_Detail__c:'Payment Review',
                            MYLV_Care_Status__c : 'payment_contact',
                            MyRepairStatus__c :'receivedAndAcceptedInStore',
                            Payment_Review_Reason__c : 'Refused Payment',
                            Last_ICONiCS_Status_Changed_Date__c:this.today.toISOString(),
                            Last_MYLV_Care_Status_Changed_Date__c:this.today.toISOString(),
                            Last_MyRepair_Status_Changed_Date__c:this.today.toISOString(),
                            PBL_Number__c : this.arrayOfStrings[0],
                            PBL_Link__c : this.arrayOfStrings[1],
                            PBL_Status__c : 'Review'
                }
            };
           updateRecord(record)
                .then(() => {
                    console.log('careservice update success');   
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'A payment link has been successfully generated and emailed to the client',
                            variant: 'success',
                            mode: 'pester'
                        }),
                    );
                    this.dispatchEvent(new CloseActionScreenEvent());   
                })
                .catch(error => {                  
                    console.log('careservice update error'+JSON.stringify(error)); 
                });

           }

    })
    .catch((error) => {
        console.log('Error '+ error);         
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