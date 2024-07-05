import { LightningElement,api,wire,track } from 'lwc';
import { createRecord,getRecord,getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import currentRecordType from '@salesforce/schema/CareService__c.RecordTypeId';
import currentStore from '@salesforce/schema/CareService__c.Store__c';
import currentStoreRetailCode from '@salesforce/schema/CareService__c.StoreRetailCode__c';
import currentClient from '@salesforce/schema/CareService__c.Client__c';
import currentDescription from '@salesforce/schema/CareService__c.Description__c';
import currentFollowupBy_Call from '@salesforce/schema/CareService__c.FollowupBy_Call__c';
import currentFollowupBy_Email from '@salesforce/schema/CareService__c.FollowupBy_Email__c';
import currentFollowupBy_Video_Call from '@salesforce/schema/CareService__c.FollowupBy_Video_Call__c';
import currentName from '@salesforce/schema/CareService__c.Name';
import currentLanguageLocaleKey from '@salesforce/schema/CareService__c.LanguageLocaleKey__c';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class ICX_FastCreateCareService extends NavigationMixin( LightningElement )  {
    @track showConfirmation = true;
    @api recordId;
    @wire(getRecord, {
		recordId: "$recordId",
        fields: [currentRecordType, currentStore,currentStoreRetailCode,currentClient,currentDescription,currentFollowupBy_Call,currentFollowupBy_Email,currentFollowupBy_Video_Call,currentName,currentLanguageLocaleKey]
	})
	currentRecord;

    //NI-2646 New radio group for cancelling the initial case
    @track today;
    @track value = 'Yes';
    @track cancelOldCS = 'Yes';
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    handleChange(event) {
        this.cancelOldCS = event.detail.value;
    }
 
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }

    saveAction(){      
        this.today = new Date();
        this.showConfirmation = false;
                
        if(this.cancelOldCS === 'Yes'){
            let objRecordInputUpdate = { 
                fields : {
                    Id: this.recordId,
                    Cancellation_Reason__c: 'Request Cancelled by Care Expert',
                    ICONiCS_Status_Detail__c : 'Cancelled',
                    Last_ICONiCS_Status_Changed_Date__c : this.today.toISOString(),
                    Closed_after_Clone__c : true
            }};

            updateRecord(objRecordInputUpdate)
            .then(() => {
               console.log('CareService Cancelled');
            })
            .catch( err => {
                console.log('CareService Cancel Error'+ JSON.stringify(err));  
            })
        }

        var fields = {
            'RecordTypeId' : getFieldValue(this.currentRecord.data, currentRecordType),
            'Store__c' :getFieldValue(this.currentRecord.data, currentStore),
            'StoreRetailCode__c' : getFieldValue(this.currentRecord.data, currentStoreRetailCode),
            'Client__c' : getFieldValue(this.currentRecord.data, currentClient),
            'Description__c' : getFieldValue(this.currentRecord.data,currentDescription ),
            'FollowupBy_Call__c' : false,
            'FollowupBy_Email__c' : true,
            'FollowupBy_Video_Call__c' : false,         
            'Origin__c' : 'CSC Clone',
            'Iconics_Internal_Follow_up__c' : 'Initiated from '+ getFieldValue(this.currentRecord.data, currentName),
            'LanguageLocaleKey__c': getFieldValue(this.currentRecord.data, currentLanguageLocaleKey)
            };
     
        var objRecordInput = {'apiName' : 'CareService__c', fields};

        createRecord(objRecordInput).then(response => {
            console.log( 'CareService created ' +response.id);
             // View CareService record.
            this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: response.id,
                objectApiName: 'CareService__c',
                actionName: 'view'
            }
        });
        this.dispatchEvent(new CloseActionScreenEvent());
        }).catch(error => {
            console.log( 'CareService Creation Error' +JSON.stringify(error));         
        });

    }
    
}