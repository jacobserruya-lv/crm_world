import { LightningElement,track,api ,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Icx_deleeteModal extends NavigationMixin(LightningElement) {

    @api recordId;
    @api isDialogVisible;
    @api recordListEntered;
    @track header;
    @track message;
    @track confirm;
    @track cancel;
    @track name;

renderedCallback()
{
    this.header = 'Delete Record !';
    this.message = 'Are you sure you want to delete this record ? ';
    this.confirm = 'Confirm';
    this.cancel = 'Cancel';
    this.name = 'confirmModal';

}

    handleConfirm(event){
        console.log('The recordSelectedId',this.recordId);
        console.log('The recordList',JSON.stringify(this.recordListEntered));
       
    deleteRecord(this.recordId)
            .then(() => {
                this.isDialogVisible = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                // Navigate to a record home page after
                // the record is deleted, such as to the
                // contact home page
                // this[NavigationMixin.Navigate]({
                //     type: 'standard__objectPage',
                //     attributes: {
                //         objectApiName: 'Calling_Campaign__c',
                //         actionName: 'home',
                //     },
                // });
                 //return refreshApex(this.recordListEntered);
                 location.reload(true);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
          }

          handleCancel(evt){
            this.closeModal();
            console.log('cancel the modal',evt.detail);
            this.dispatchEvent(new CustomEvent('modalcanceled',{detail:evt.detail}));
             }

            
            closeModal(){
                this.isDialogVisible = false;
          }
        
}