import {LightningElement, api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class iCX_CancelCareService extends LightningElement {
    @api recordId;
    @api today;

      closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }

      saveAction(){
        this.today = new Date();
        let record = {
                fields: {
                    Id: this.recordId,
                    ICONiCS_Status_Detail__c:'Cancelled',
                    Last_ICONiCS_Status_Changed_Date__c:this.today.toISOString(),
                    Cancellation_Reason__c:'Request Cancelled by Care Expert'
                }
            };
            updateRecord(record)
                // eslint-disable-next-line no-unused-vars
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Care Service is cancelled',
                            variant: 'warning',
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
                        }),
                    );
                });
               
        
        }
      }