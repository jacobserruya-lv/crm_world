import { LightningElement,track,api ,wire} from 'lwc';
import sendEmailToIPD from '@salesforce/apex/ICX_IPDTransfer_CTL.sendEmailToIPD';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue,updateRecord  } from 'lightning/uiRecordApi';
import IPD_CaseCategory from '@salesforce/label/c.ICX_IPD_CaseCategory';
import IPD_CaseType from '@salesforce/label/c.ICX_IPD_CaseType';
import IPD_CaseResolution from '@salesforce/label/c.ICX_IPD_CaseResolution';
import IPD_ErrorMessage1 from '@salesforce/label/c.ICX_IPD_ErrorMessage1';
import IPD_ErrorMessage3 from '@salesforce/label/c.ICX_IPD_ErrorMessage3';


import CATEGORY_FIELD from '@salesforce/schema/Case.Category__c';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import RESOLUTION_FIELD from '@salesforce/schema/Case.Resolution__c';
import QUEUE_OWNER_FIELD from '@salesforce/schema/Case.TECH_Is_Queue_owner__c';


const fields = [CATEGORY_FIELD, TYPE_FIELD, RESOLUTION_FIELD,QUEUE_OWNER_FIELD];



export default class Icx_ipd_confirmation extends LightningElement {
    @track isDialogVisible = true;
    @api recordId

    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    handleConfirm(event){
            var message = '';

            if(this.case.data){

                let resolution =  getFieldValue(this.case.data, RESOLUTION_FIELD);
                let type = getFieldValue(this.case.data, TYPE_FIELD);
                let category = getFieldValue(this.case.data, CATEGORY_FIELD);
                let queueOwner = getFieldValue(this.case.data, QUEUE_OWNER_FIELD)  ;

                let  nosenttoIPD =  resolution != IPD_CaseResolution || category != IPD_CaseCategory || type != IPD_CaseType ;

                if(queueOwner == false && nosenttoIPD == true ){
                    sendEmailToIPD({
                        recordId : this.recordId
                    })
                    .then(() => {  
                        message = 'The request has been transferred to Intellectual Property Department'
                        this.showToast(message,'success');
                        updateRecord({fields: { Id: this.recordId }});
                    })
                    .catch(error => {
                        this.showToast(error.body.message,'error')
                    } );
                }else{   
                    message = nosenttoIPD == false ? IPD_ErrorMessage3 : IPD_ErrorMessage1;            
                    this.showToast(message,'error');
                }
            }else{
                 this.closeModal();
            }
           
    }
    handleCancel(evt){
        this.closeModal();
    }
    
    showToast(message,variant) {
        const evt = new ShowToastEvent({
            title: '',
            message: message,
            variant: variant,
            mode: 'pester'
        });
        this.dispatchEvent(evt);
        this.closeModal();
    }

    closeModal(){
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
   
}