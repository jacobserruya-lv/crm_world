import { LightningElement , api,wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord,getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserName from '@salesforce/schema/User.Name';
import currentUserRMSID from '@salesforce/schema/User.RMS_ID__c';
import changeOnlineAppointmentOwner from '@salesforce/apex/ICX_OnlineAppointmentController.changeOnlineAppointmentOwner';

export default class ICX_ChangeOwnerCareService extends LightningElement {

    @api recordId;
    @api today;
    @api currentUserId = userId;
    isExecuting = false;  
      
    @wire(getRecord, {
		recordId: "$currentUserId",
		fields: [currentUserName, currentUserRMSID]
	})
	currentUser;

  /*  @api async invoke() {
        if (this.isExecuting) {
            return;
        }  */
     closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }

      saveAction(){        
        console.log('Execution Start');
        this.today = new Date();
        
        changeOnlineAppointmentOwner ({
            careServiceId: this.recordId,
            UserId:this.currentUserId
        })
        .then(() => {console.log('Appointment assigned to User'); })
        .catch(error => {          
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error on assignment of Appointment',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                }),
            );
        });
        let record = {
            fields: {
                Id: this.recordId,               
                Assigned_To__c:this.currentUserId,
                CA__c:this.currentUserId,
                CA_Code__c:getFieldValue(this.currentUser.data, currentUserRMSID),
                CA_Name__c:getFieldValue(this.currentUser.data, currentUserName)
            }
        };
        updateRecord(record)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Care Service is assigned to you',
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